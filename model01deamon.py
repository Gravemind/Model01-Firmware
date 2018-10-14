#!/usr/bin/env python

import i3
import serial

# Kaleidoscope-Hardware-Model01/src/Kaleidoscope-Hardware-Model01.cpp
WSNUM_TO_LEDID=[4, 11, 12, 19, 20, 43, 44, 51, 52, 59]

def update_workspaces_leds(workspaces):
    indexedws = [ None for _ in range(10) ]

    for ws in workspaces:
        wsnum = int(ws['name'])
        if wsnum < 0 or wsnum > 10:
            continue
        indexedws[wsnum-1]=ws

    for num in range(10):
        ws = indexedws[num]
        blue = b'0 100 255'
        black = b'100 100 100'
        green = b'100 255 100'
        red = b'255 100 100'
        if ws is None:
            color = black
        elif ws['urgent']:
            color = red
        elif ws['focused']:
            color = green
        elif ws['visible']:
            color = green
        else:
            color = blue

        ledid = WSNUM_TO_LEDID[num]

        keyboardio_focus_command(b'led.at %d %b' % (ledid, color))

def keyboardio_focus_command(cmd):
    print("command> "+str(cmd));
    hadOutput = False
    with serial.Serial ("/dev/ttyACM0", 9600, timeout = 1) as ser:
        ser.write (cmd)
        ser.write (b"\n")
        while True:
            resultLine = ser.readline()
            if resultLine == b"\r\n" or resultLine == b"\n":
                resultLine = b" "
            else:
                resultLine = resultLine.rstrip()
            if resultLine == b".":
                break
            if resultLine:
                hadOutput = True
                print("<"+str(resultLine))
    if hadOutput:
        print("")


def workspace_subscription(event, data, subscription):
    print(data)
    update_workspaces_leds(data)

workspaces = i3.get_workspaces()
for workspace in workspaces:
    print(workspace['name'])

update_workspaces_leds(workspaces)

subscription = i3.Subscription(workspace_subscription, 'workspace')

