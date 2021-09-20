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
import kotlin.concurrent.thread
import com.perceivers25.betalk.utils.BetalkLogger as Log

class Server(ip: String? = null) {
    private final val HOST: InetAddress = if (ip == null) InetAddress.getLocalHost() else InetAddress.getByName(ip);
    private final val PORT: Int = 9090;

    private lateinit var server: ServerSocket;

    private var clients: MutableList<Socket> = mutableListOf();

    fun startServer() {
        Log.logStatus("Server starting...");
        server = ServerSocket(PORT, 1000, HOST);
        Log.logStatus("Server started on ${server.inetAddress.hostAddress}\n", true);
        Log.logInfo("You can close by using Ctrl+C\n");

        while (true) {
            try {
                val client: Socket = server.accept();
                thread { handleClient(client) };
            } catch (s: SocketException) {

            }
        }
    }

    private fun handleClient(client: Socket) {
        client.receiveBufferSize = 1024;

        client.soTimeout = 3000

        val reader = BufferedReader(InputStreamReader(client.getInputStream()));

        val nickname: String = recv(reader);

        clients.add(client);

        Log.logClient("Connected with ${client.inetAddress.hostAddress}");
        Log.logClient("Nickname of client is $nickname");
        Log.logInfo("Total clients: ${clients.size}");

        broadcast("$nickname joined the chat\n");

        while (!client.isClosed and client.isConnected) {
            try {
                val m = recv(reader);
                Log.logClient("$nickname says $m");
                broadcast(m);
            } catch (ex: Exception) {
                reader.close();
                client.close();
                Log.logClient("${client.inetAddress.hostAddress} closed the connection");
                break;
            }
        }
    }

    private fun broadcast(message: String) {
        for (client in clients) {
            write(client.getOutputStream(), message);
        }
    }

    private fun write(writer: OutputStream, message: String) {
        writer.write(message.toByteArray(Charset.defaultCharset()));
    }

    private fun recv(reader: BufferedReader): String {
        var response = "";
        val chars = CharArray(1024);
        try {
            val input = reader.read(chars, 0, 1024);
            if (input > 0) {
                response = String(chars, 0, input);
            }
        } catch (ex: java.lang.Exception) {
        }
        return response;
    }

    fun stop() {
        for (client in clients)
            client.close();
        server.close();
        Log.logStatus("Server has closed");
    }
}