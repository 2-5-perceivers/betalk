package com.perceivers25.betalk

import com.perceivers25.betalk.classes.Server
import sun.misc.Signal
import kotlin.system.exitProcess

fun shutdown(server: Server) {
    println()
    server.stop()
    exitProcess(0)
}

fun main(args: Array<String>) {
    val startServer = args.contains("run")
    val startHelp = args.contains("help")
    val specifiedIpAddress = args.contains("-i")

    if (startServer) {
        val serverInstance = Server(if (specifiedIpAddress) args[args.indexOf("-i") + 1] else null)
        Signal.handle(Signal("INT")) {
            shutdown(serverInstance)
        }
        serverInstance.startServer()
    } else if (startHelp) {
        println(
            "Usage: betalk <command> [arguments]\n\n" +
                    "Available commands:\n" +
                    "\trun\tStart the server\n" +
                    "\thelp\tShow help\n" +
                    "\nAvailable arguments:\n" +
                    "\t-i \tSpecify the ip address"
        )
    } else {
        println("Invalid command")
    }
}