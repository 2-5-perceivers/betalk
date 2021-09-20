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

if start_server:
    server_instance: Server = Server()

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
\thelp\t\tShow help'''
)
else:
    print("Select a command")