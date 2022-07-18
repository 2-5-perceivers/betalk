import 'dart:convert';
import 'dart:io';

import 'package:betalk/classes/data_package.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataProvider {
  late BuildContext context;

  late String ip;
  late String username;

  late Socket socket;

  Future<bool> init(String ip, String nickname) async {
    this.ip = ip;
    username = nickname;
    try {
      socket = await Socket.connect(ip, 9090);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
      return false;
    }
    socket.setOption(SocketOption.tcpNoDelay, true);
    socket.encoding = utf8;
    send(DataPackage.newLoginPackage(username));
    return true;
  }

  void send(DataPackage dataPackage) {
    socket.write(jsonEncode(dataPackage));
  }

  void dispose() async {
    socket.destroy();
  }

  static DataProvider of(BuildContext context) =>
      Provider.of<DataProvider>(context, listen: false)..context = context;
}
