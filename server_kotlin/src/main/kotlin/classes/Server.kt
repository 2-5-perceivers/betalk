@file:Suppress("PrivatePropertyName")

package com.perceivers25.betalk.classes

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStream
import java.net.InetAddress
import java.net.ServerSocket
import java.net.Socket
import java.net.SocketException
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import kotlin.concurrent.thread
import com.perceivers25.betalk.utils.BetalkLogger as Log

class Server(ip: String? = null) {
    private val HOST: InetAddress = if (ip == null) InetAddress.getLocalHost() else InetAddress.getByName(ip)
    private val PORT: Int = 9090

    private lateinit var server: ServerSocket

    private var clients: MutableList<Socket> = mutableListOf()

    fun startServer() {
        Log.logStatus("Server starting...")
        server = ServerSocket(PORT, 1000, HOST)
        Log.logStatus("Server started on ${server.inetAddress.hostAddress}\n", true)
        Log.logInfo("You can close by using Ctrl+C\n")

        while (true) {
            try {
                val client: Socket = server.accept()
                thread { handleClient(client) }
            } catch (s: SocketException) {

            }
        }
    }

    private fun handleClient(client: Socket) {
        client.receiveBufferSize = 1024

        val reader = BufferedReader(InputStreamReader(client.getInputStream()))

        val nickname: String = recv(reader)

        clients.add(client)

        Log.logClient("Connected with ${client.inetAddress.hostAddress}")
        Log.logClient("Nickname of client is $nickname")
        Log.logInfo("Total clients: ${clients.size}")

        broadcast("$nickname joined the chat\n")

        while (!client.isClosed and client.isConnected) {
            try {
                val m = recv(reader)
                if (m.isBlank())
                    break
                Log.logClient(m.replace("@", " says: "))
                broadcast(m)
            } catch (ex: Exception) {
                break
            }
        }
        reader.close()
        client.close()
        clients.remove(client)
        broadcast("$nickname left\n")
        Log.logClient("${client.inetAddress.hostAddress} closed the connection")
    }

    private fun broadcast(message: String) {
        for (client in clients) {
            write(client.getOutputStream(), message)
        }
    }

    private fun write(writer: OutputStream, message: String) {
        writer.write(message.encodeToByteArray())
    }

    private fun recv(reader: BufferedReader): String {
        var response = ""
        val chars = CharArray(1024)
        try {
            val input = reader.read(chars, 0, 1024)
            if (input > 0) {
                response = String(chars, 0, input)
            }
        } catch (ex: java.lang.Exception) {
        }
        return response
    }

    fun stop() {
        for (client in clients)
            client.close()
        server.close()
        Log.logStatus("Server has closed")
    }
}