
BOARD?=keyboardio:avr:model01

PORT?=/dev/serial/by-id/usb-Keyboardio_Model_*

ifneq ("$(wildcard ${PORT})","")
	override PORT:=$(realpath $(wildcard ${PORT}))
else
	override PORT:=$(error Invalid PORT env, no such file: ${PORT})
endif

VERBOSE?=0

ARDUINO_CLI_COMPILE_FLAGS=--fqbn ${BOARD} --warnings all
ARDUINO_CLI_UPLOAD_FLAGS=--fqbn ${BOARD} --verify --port ${PORT}

ifeq (${VERBOSE},1)
ARDUINO_CLI_COMPILE_FLAGS+=--verbose
ARDUINO_CLI_UPLOAD_FLAGS+=--verbose
endif

all: compile

help: info
info:
	@echo ""
	@echo "usage: make -c Makefile_arduin-cli.make [VERBOSE=1] [PORT=/dev/...] [help|info|build|compile|verify|flash|upload]"
	@echo ""
	@echo " REQUIRE FIX/PATCH in Kaleidoscope-Bundle-Keyboardio/avr/boards.txt:"
	@echo " change **ALL** occurrencies of:"
	@echo "   ...upload.tool=avrdude"
	@echo " to:"
	@echo "   ...upload.tool=arduino:avrdude"
	@echo ""
	@echo "Env:"
	@echo "  VERBOSE=${VERBOSE}"
	@echo "  PORT=${PORT}"
	@echo "  BOARD=${BOARD}"
	@echo ""
	@echo "USB model ID of ${PORT}: $(shell udevadm info ${PORT} | sed -nE 's/.* ID_MODEL[^=]*=(.*)/\1/gp' | tr $$'\n' ' ')"
	@echo ""
	@echo "$(shell arduino-cli version)"
	@echo "  $(shell which arduino-cli)"
	@echo "  compile ${ARDUINO_CLI_COMPILE_FLAGS}"
	@echo "  upload ${ARDUINO_CLI_UPLOAD_FLAGS}"
	@echo ""


build: compile
verify: compile
compile: info
	arduino-cli compile ${ARDUINO_CLI_COMPILE_FLAGS}

flash: upload
upload: compile
	arduino-cli upload ${ARDUINO_CLI_UPLOAD_FLAGS}
	sleep 0.1

# Send build commands to rtags
# (patches commands to add -I/path/to/avr-gcc/avr/include)
SHELL=/bin/bash
rtags:
	arduino-cli compile ${ARDUINO_CLI_COMPILE_FLAGS} --verbose | \
		sed -nE 's#^([^ ]+)(/bin/avr-g[^ /]+)#\1\2 -I\1/avr/include#gp' | \
		tee >(rc -c -)

.PHONY: all help info compile build verify upload flash
