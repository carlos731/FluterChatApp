import 'package:animate_do/animate_do.dart';
import 'package:fluterchatpro/enums/enums.dart';
import 'package:fluterchatpro/models/message_model.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:fluterchatpro/widgets/display_message_type.dart';
import 'package:flutter/material.dart';

class ReactionsDialog extends StatefulWidget {
  const ReactionsDialog({
    super.key,
    required this.isMyMessage,
    required this.message,
    required this.onReactionsTap,
    required this.onContextMenuTap,
  });

  final bool isMyMessage;
  final MessageModel message;
  final Function(String) onReactionsTap;
  final Function(String) onContextMenuTap;

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  bool reactionClicked = false;
  bool contextMenuClicked = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;

  @override
  Widget build(BuildContext context) {
    

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final reaction in reactions)
                          InkWell(
                            onTap: () {
                              widget.onReactionsTap(reaction);
                              setState(() {
                                reactionClicked = true;
                                clickedReactionIndex =
                                    reactions.indexOf(reaction);
                              });
                              // set back to false after milliseconds second
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  setState(() {
                                    reactionClicked = false;
                                  });
                                },
                              );
                            },
                            child: reactionClicked &&
                                    clickedReactionIndex ==
                                        reactions.indexOf(reaction)
                                ? Pulse(
                                    infinite: false,
                                    duration: const Duration(milliseconds: 500),
                                    animate: reactionClicked,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        reaction,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      reaction,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.isMyMessage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade800,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.message.messageType == MessageEnum.text
                          ? Text(
                              widget.message.message,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )
                          : DisplayMessageType( // Exibe o arquivo audio/imagem/video da mensagem!!
                              message: widget.message.message,
                              type: widget.message.messageType,
                              color: Colors.white,
                              isReply: true,
                            ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final menu in contextMenu)
                          InkWell(
                            onTap: () {
                              widget.onContextMenuTap(menu);
                              setState(() {
                                contextMenuClicked = true;
                                clickedContextMenuIndex =
                                    contextMenu.indexOf(menu);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    menu,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  contextMenuClicked &&
                                          clickedContextMenuIndex ==
                                              contextMenu.indexOf(menu)
                                      ? Pulse(
                                          infinite: false,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Icon(menu == 'Reply'
                                              ? Icons.reply
                                              : menu == 'Copy'
                                                  ? Icons.copy
                                                  : Icons.delete),
                                        )
                                      : Icon(menu == 'Reply'
                                          ? Icons.reply
                                          : menu == 'Copy'
                                              ? Icons.copy
                                              : Icons.delete),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
