import 'dart:convert';

import 'package:betalk/classes/data_package.dart';
import 'package:betalk/data_service.dart';
import 'package:betalk/classes/message.dart';
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
  List<String> dataQueue = [];

  @override
  void initState() {
    super.initState();
    DataProvider.of(context).socket.listen((data) {
      dataQueue.add(utf8.decode(data));
      queuerProcessor();
    });
  }

  void queuerProcessor() {
    String eof = '\u001a';
    String newPack;
    bool foundEOF = false;
    int lastIndex = 0;

    do {
      for (var i = 0; i < dataQueue.length; i++) {
        foundEOF = dataQueue[i].contains(eof);
        if (foundEOF) {
          lastIndex = i;
          break;
        }
      }
      if (foundEOF) {
        newPack = "";
        for (var i = 0; i < lastIndex; i++) {
          newPack += dataQueue[i];
          dataQueue.removeAt(i);
        }
        int index = dataQueue.first.indexOf(eof);
        newPack += dataQueue.first.substring(0, index);
        if (index == dataQueue.first.length) {
          dataQueue.removeAt(0);
        } else {
          dataQueue.first = dataQueue.first.substring(index + 1);
        }

        DataPackage dp = DataPackage.fromJson(jsonDecode(newPack));
        assert(dp.type == DataPackageType.message);
        Message m = dp.message!;
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
      }
    } while (foundEOF);
  }

  @override
  Widget build(BuildContext context) {
    String username = DataProvider.of(context).username;
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
              return MessageWidget(message: messages[i]);
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
    Message m = Message.newMessage(
        messageAuthor: DataProvider.of(context).username,
        messageTextContent: _messageTextController.text);

    DataProvider.of(context).send(
      DataPackage.newMessagePackage(m),
    );
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
