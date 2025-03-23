import 'package:betalk/classes/message.dart';
import 'package:betalk/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    bool systemMessage, myMessage;
    DateTime time = DateTime.parse(message.time).toLocal();

    systemMessage = message.type == MessageType.systemMessage;
    myMessage = message.author == DataProvider.of(context).username;

    AlignmentGeometry alignmentGeometry = systemMessage
        ? Alignment.center
        : (myMessage ? Alignment.centerRight : Alignment.centerLeft);
    double messageLayoutPadding = systemMessage ? 6 : 2;
    double messageRadius = 15;

    ThemeData th = Theme.of(context);
    ColorScheme cs = th.colorScheme;
    TextTheme txth = th.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 16,
      ),
      alignment: alignmentGeometry,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 700
              ? 630
              : MediaQuery.of(context).size.width - 70,
          minWidth: 64,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(messageRadius),
          color: systemMessage
              ? cs.tertiaryContainer
              : ElevationOverlay.applySurfaceTint(
                  myMessage ? cs.secondaryContainer : cs.surface,
                  cs.surfaceTint,
                  myMessage ? 16 : 2,
                ),
        ),
        padding: EdgeInsets.all(messageLayoutPadding),
        child: systemMessage
            ? Tooltip(
                message: _dateTimeToHuman(time),
                child: Text(message.textContent!),
              )
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!myMessage)
                        Padding(
                          padding: const EdgeInsets.only(left: 6, top: 6),
                          child: Text(
                            message.author!,
                            style: txth.labelMedium,
                          ),
                        ),
                      if (message.textContent != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 6),
                          child: SelectableText(message.textContent!),
                        ),
                      if (message.fileContent != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(messageRadius),
                          ),
                          child: Image.memory(
                            message.fileContent!,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      const SizedBox(
                        height: 16,
                      ), //Space for Time label
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: Text(
                      DateFormat.Hm().format(time),
                      style: txth.labelSmall,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static _dateTimeToHuman(DateTime dateTime) =>
      DateFormat.Hm().add_d().add_MMM().add_y().format(dateTime);
}
