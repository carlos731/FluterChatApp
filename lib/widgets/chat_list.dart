import 'package:date_format/date_format.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fluterchatpro/models/message_model.dart';
import 'package:fluterchatpro/models/message_reply_model.dart';
import 'package:fluterchatpro/providers/authentication_provider.dart';
import 'package:fluterchatpro/providers/chat_provider.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:fluterchatpro/widgets/contact_message_widget.dart';
import 'package:fluterchatpro/widgets/my_message_widget.dart';
import 'package:fluterchatpro/widgets/reactions_dialog.dart';
import 'package:fluterchatpro/widgets/stacked_reactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onContextMenuClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        // set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );

        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        // TODO delete message
        // context.read<ChatProvider>().deleteMessage(
        //   userId: uid,
        //   contactUID: widget.contactUID,
        //   messageId: message.messageId,
        //   groupId: widget.groupId,
        // );
        break;
    }
  }

  showReactionsDialog({required MessageModel message, required bool isMe}) {
    showDialog(
      context: context,
      builder: (context) => ReactionsDialog(
        isMyMessage: isMe,
        message: message,
        onReactionsTap: (reaction) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
            print('pressed $reaction');
            // if its a plus reaction show bottom with emoji keyboard
            if (reaction == '➕') {
              //   // TODO show emoji keyboard
              showEmojiContainer();
              //   showEmojiKeyboard(
              //     context: context,
              //     onEmojiSelected: (emoji) {
              //       // add emoji to message
              //       context
              //           .read<ChatProvider>()
              //           .addEmojiToMessage(emoji: emoji, message: message);
              //     },
              //   );
            } else {
              // TODO add reaction to message
              // context
              //     .read<ChatProvider>()
              //     .addReactionToMessage(reaction: reaction, messaage: message);
            }
          });
        },
        onContextMenuTap: (item) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
            // TODO handle context menu tap
            onContextMenuClicked(item: item, message: message);
          });
        },
      ),
    );
  }

  void showEmojiContainer() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            print(emoji);
            // TODO add emoji to message
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessageStream(
            userId: uid,
            contactUID: widget.contactUID,
            isGroup: widget.groupId,
          ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Start a conversation',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          );
        }

        // automatically scrool to the bottom on new message
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });

        if (snapshot.hasData) {
          final messagesList = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            reverse: true,
            controller: _scrollController,
            elements: messagesList,
            groupBy: (element) {
              return DateTime(
                element.timeSent!.year,
                element.timeSent!.month,
                element.timeSent!.day,
              );
            },
            groupHeaderBuilder: (dynamic groupedByValue) => SizedBox(
              height: 45,
              child: buildDateTime(groupedByValue),
            ),
            itemBuilder: (context, dynamic element) {
              // set message as seen
              if (!element.isSeen && element.senderUID != uid) {
                context.read<ChatProvider>().setMessageAsSeen(
                      userId: uid,
                      contactUID: widget.contactUID,
                      messageId: element.messageId,
                      groupId: widget.groupId,
                    );
              }

              // check if we sent the last message
              final isMe = element.senderUID == uid;
              return isMe
                  ? Stack(
                      children: [
                        InkWell(
                          onLongPress: () {
                            showReactionsDialog(message: element, isMe: isMe);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 20.0),
                            child: MyMessageWidget(
                              message: element,
                              onRightSwipe: () {
                                // set the message reply to true
                                final messageReply = MessageReplyModel(
                                  message: element.message,
                                  senderUID: element.senderUID,
                                  senderName: element.senderName,
                                  senderImage: element.senderImage,
                                  messageType: element.messageType,
                                  isMe: isMe,
                                );

                                context
                                    .read<ChatProvider>()
                                    .setMessageReplyModel(messageReply);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 90,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: StackedReactionWidget(
                              message: element,
                              size: 20,
                              onTap: () {
                                // TODO: show bottom sheet with list of people who reacted
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onLongPress: () {
                        showReactionsDialog(message: element, isMe: isMe);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: ContactMessageWidget(
                          message: element,
                          onRightSwipe: () {
                            // set the message reply to true
                            final messageReply = MessageReplyModel(
                              message: element.message,
                              senderUID: element.senderUID,
                              senderName: element.senderName,
                              senderImage: element.senderImage,
                              messageType: element.messageType,
                              isMe: isMe,
                            );

                            context
                                .read<ChatProvider>()
                                .setMessageReplyModel(messageReply);
                          },
                        ),
                      ),
                    );
            },
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) {
              var firstItem = item1.timeSent;

              var secondItem = item2.timeSent;

              return secondItem!.compareTo(firstItem!);
            }, // optional
            useStickyGroupSeparators: true, // optional
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
