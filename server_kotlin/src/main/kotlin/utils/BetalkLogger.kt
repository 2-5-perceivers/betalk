package com.perceivers25.betalk.utils

@Suppress("MemberVisibilityCanBePrivate")
class BetalkLogger {
    companion object {
        const val ANSI_RESET = "\u001B[0m";
        const val ANSI_RED = "\u001B[31m";
        const val ANSI_GREEN = "\u001B[32m";
        const val ANSI_CYAN = "\u001B[36m";

        fun logStatus(message: String, success: Boolean? = null) {
            if (success != null && success)
                println("$ANSI_GREEN[STATUS] $message$ANSI_RESET");
            else if (success == null)
                println("[STATUS] $message");
            else
                println("$ANSI_RED[STATUS] $message$ANSI_RESET");
        }

        fun logClient(message: String) {
            println("[CLIENT] $message");
        }

        fun logInfo(message: String) {
            println("$ANSI_CYAN[INFO] $message$ANSI_RESET");
        }

        fun logError(message: String) {
            println("$ANSI_RED[ERROR] $message$ANSI_RESET");
        }
    }
}