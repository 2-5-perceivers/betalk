import 'dart:async';

import 'package:betalk/data_service.dart';
import 'package:betalk/message.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageTextController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    DataProvider.of(context).socket.listen((data) {
      String message = String.fromCharCodes(data).trim();
      int separatorIndex = message.indexOf("@");
      Message m = separatorIndex == -1
          ? Message(null, message)
          : Message(message.substring(0, separatorIndex),
              message.substring(separatorIndex + 1));
      setState(() {
        messages.add(m);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String nick = DataProvider.of(context).nickname;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person_outline),
                  maxRadius: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "betalk",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        DataProvider.of(context).nickname,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(160),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                bool serverMessage = messages[i].sender == null;
                return serverMessage
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.secondary),
                            padding: const EdgeInsets.all(10),
                            child: SelectableText(
                              messages[i].content,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 14),
                        child: Align(
                          alignment: (messages[i].sender != nick
                              ? Alignment.topLeft
                              : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (messages[i].sender != nick
                                  ? Colors.grey[600]
                                  : Theme.of(context).colorScheme.primary),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (messages[i].sender != nick)
                                  Text(
                                    messages[i].sender!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                SelectableText(
                                  messages[i].content,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                      controller: _messageTextController,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: _send,
                    mini: true,
                    child: const Icon(
                      Icons.send,
                      size: 19,
                    ),
                    elevation: 0,
                    hoverElevation: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Send message
  void _send() {
    DataProvider.of(context).send(_messageTextController.text);
    _messageTextController.clear();

    // This allows to move to the bottom after message is showed
    Timer(
      const Duration(milliseconds: 100),
      () =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
    );
  }
}
