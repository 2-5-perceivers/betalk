import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataProvider {
  late BuildContext context;

  late String ip;
  late String nickname;

  late Socket socket;

  Future<void> init(String ip, String nickname) async {
    this.ip = ip;
    this.nickname = nickname;
    try {
      socket = await Socket.connect(ip, 9090);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
    socket.encoding = utf8;
    socket.write(nickname);
  }

  void send(String message) {
    socket.write("$nickname@$message");
  }

  void dispose() async {
    socket.destroy();
  }

  static DataProvider of(BuildContext context) =>
      Provider.of<DataProvider>(context, listen: false)..context = context;
}
