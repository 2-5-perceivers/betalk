@file:Suppress("PrivatePropertyName")

package com.perceivers25.betalk.classes

import kotlinx.serialization.SerializationException
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStream
import java.net.InetAddress
import java.net.ServerSocket
import java.net.Socket
import java.net.SocketException
import java.util.*
import kotlin.concurrent.thread
import com.perceivers25.betalk.utils.BetalkLogger as Log

class Server(ip: String? = null) {
    private val HOST: InetAddress = if (ip == null) InetAddress.getLocalHost() else InetAddress.getByName(ip)
    private val PORT: Int = 9090

    private lateinit var server: ServerSocket

    private var clients: MutableList<Client> = mutableListOf()
    private var messages: MutableList<Message> = mutableListOf()

    fun startServer() {
        Log.logStatus("Server starting...")
        server = ServerSocket(PORT, 1000, HOST)
        Log.logStatus("Server started on ${server.inetAddress.hostAddress}\n", true)
        Log.logInfo("You can close by using Ctrl+C\n")

        while (true) {
            try {
                val client = Client(server.accept())
                thread { handleClient(client) }
            } catch (s: SocketException) {
                Log.logError(s.message ?: "Something happened")
            }
        }
    }

    private fun handleClient(client: Client) {
        client.socket.receiveBufferSize = 16384

        client.reader = BufferedReader(InputStreamReader(client.socket.inputStream))
        var dp: DataPackage = receive(client.reader)

        if (dp.type == DataPackage.DataPackageType.Login) {
            client.clientName = dp.loginName!!
        } else {
            client.close()
            return
        }
        clients.add(client)
        client.messageQueue.addAll(messages)

        Log.logClient("Connected with ${client.socket.inetAddress.hostAddress}")
        Log.logClient("Nickname of client is ${client.clientName}")
        Log.logInfo("Total clients: ${clients.size}")

        broadcast(Message.newSystemMessage("${client.clientName} joined the chat"))

        thread {
            while (!client.socket.isClosed and client.socket.isConnected) {
                val m: Message? = client.messageQueue.poll()
                if (m != null)
                    send(client.socket.outputStream, DataPackage.newMessageDataPackage(m))
            }
        }

        while (!client.socket.isClosed and client.socket.isConnected) {
            try {
                try {
                    dp = receive(client.reader)
                } catch (_: Throwable) {
                    break
                }
                if (dp.type == DataPackage.DataPackageType.Message) {
                    var details: String = dp.message!!.messageAuthor!!
                    if (dp.message!!.messageTextContent != null) {
                        details += " says: " + dp.message!!.messageTextContent
                    }
                    if (dp.message!!.messageFileContent != null) {
                        if (dp.message!!.messageTextContent != null) {
                            details += " and"
                        }
                        details += " sent a file"
                    }
                    Log.logClient(details)
                }
                broadcast(dp.message!!)
            } catch (ex: Exception) {
                break
            }
        }
        client.close()
        clients.remove(client)
        broadcast(Message.newSystemMessage("${client.clientName} left"))
        Log.logClient("${client.socket.inetAddress.hostAddress} closed the connection. Remaining clients: ${clients.size}")
    }

    private fun broadcast(message: Message) {
        messages.add(message)
        for (client in clients) {
            client.messageQueue.add(message)
        }
    }

    /**
     * Sends a data package to a client using its OutputStream
     */
    private fun send(writer: OutputStream, dataPackage: DataPackage) {
        writer.write("${dataPackage.toJson()} \u001a".encodeToByteArray())
    }

    /**
     * Receives a data package.
     *
     * @throws SerializationException if value is empty
     */
    private fun receive(reader: BufferedReader): DataPackage {
        var response = ""
        val chars = CharArray(16384)
        try {
            val input = reader.read(chars, 0, 16384)
            if (input > 0) {
                response = String(chars, 0, input)
            }
        } catch (_: java.lang.Exception) {
        }
        try {
            return DataPackage.fromJson(response)
        } catch (e: SerializationException) {
            throw e
        }
    }

    fun stop() {
        for (client in clients) client.close()
        server.close()
        Log.logStatus("Server has closed")
    }

    class Client(var socket: Socket) {
        var clientName: String = ""
        var messageQueue: LinkedList<Message> = LinkedList<Message>()
        lateinit var reader: BufferedReader
        fun close() {
            socket.close()
            reader.close()
        }
    }

}