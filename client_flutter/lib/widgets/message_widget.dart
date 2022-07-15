import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({Key? key}) : super(key: key);

  //final AlignmentGeometry _alignmentGeometry;
  final double _messageLayoutPadding = 6;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 16,
      ),
      alignment: /* _alignmentGeometry */ Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
        padding: EdgeInsets.all(_messageLayoutPadding),
        child: const Text("Rares joined"),
      ),
    );
  }
}
