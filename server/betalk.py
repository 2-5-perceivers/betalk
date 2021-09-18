#!/usr/bin/python3

from server import Server
import signal
import sys

start_server: bool
start_help: bool
use_gui: bool

args = sys.argv

start_server = args.__contains__("run")
start_help = args.__contains__("help")
use_gui = not(args.__contains__("-n") or args.__contains__("--no-gui"))

if start_server:
    server_instance: Server = Server(use_gui)

    def on_exit(sig, frame):
        server_instance.dispose()

    # Set's on exit(Ctrl+C) function
    signal.signal(signal.SIGINT, on_exit)

    server_instance.startServer()
elif start_help:
    print(
'''Usage: python betalk.py <command> [arguments]
Available commands:
\trun\t\tStart the server
\thelp\t\tShow help

Global options:
\t-n, --no-gui\tRuns without a GUI'''
)
else:
    print("Select a command")