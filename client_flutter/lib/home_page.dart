import 'dart:convert';

import 'package:betalk/data_service.dart';
import 'package:betalk/message.dart';
import 'package:betalk/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageTextController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageTextFieldFocus = FocusNode();

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    DataProvider.of(context).socket.listen((data) {
      String message =
          utf8.decode(data).trim(); //String.fromCharCodes(data).trim();
      int separatorIndex = message.indexOf("@");
      Message m = separatorIndex == -1
          ? Message(null, message)
          : Message(message.substring(0, separatorIndex),
              message.substring(separatorIndex + 1));
      setState(() {
        messages.add(m);
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.position.maxScrollExtent -
                _scrollController.offset <
            100) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String username = DataProvider.of(context).nickname;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            const SizedBox(
              width: 16,
            ),
            Column(
              children: [
                const Text("Betalk"),
                Text(
                  username,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, i) {
              return const MessageWidget();
            },
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 76),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageTextController,
                            focusNode: _messageTextFieldFocus,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: null,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Message",
                              border: InputBorder.none,
                            ),
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
                          ),
                          elevation: 0,
                          hoverElevation: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Send message
  void _send() {
    DataProvider.of(context).send(_messageTextController.text);
    _messageTextController.clear();
    _messageTextFieldFocus.requestFocus();
  }

  @override
  void dispose() {
    _messageTextFieldFocus.dispose();
    _messageTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
