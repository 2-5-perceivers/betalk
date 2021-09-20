package com.perceivers25.betalk

import com.perceivers25.betalk.classes.Server
import sun.misc.Signal
import sun.misc.SignalHandler
import kotlin.system.exitProcess

fun shutdown(server: Server) {
    server.stop()
    exitProcess(0)
}

fun main(args: Array<String>) {
    var startServer = args.contains("run");
    var startHelp = args.contains("help");
    var specifiedIpAddress = args.contains("-i");

    if (startServer) {
        val serverInstance = Server(if (specifiedIpAddress) args[args.indexOf("-i") + 1] else null);
        Signal.handle(Signal("INT"), SignalHandler {
            shutdown(serverInstance)
        })
        serverInstance.startServer();
    } else if (startHelp) {
        print(
            "Usage: betalk <command> [arguments]\n\n" +
                    "Available commands:\n" +
                    "\trun\t\tStart the server\n" +
                    "\thelp\tShow help\n" +
                    "\nAvailable arguments:\n" +
                    "-i \t\tSpecify the ip address"
        );
    } else {
        println("Invalid command");
    }
}