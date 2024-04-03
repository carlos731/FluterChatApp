import 'package:date_format/date_format.dart';
import 'package:fluterchatpro/models/last_messaage_model.dart';
import 'package:fluterchatpro/providers/authentication_provider.dart';
import 'package:fluterchatpro/providers/chat_provider.dart';
import 'package:fluterchatpro/utilities/assets_manager.dart';
import 'package:fluterchatpro/utilities/constants.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),

            Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatsListStream(uid),
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
                  if (snapshot.hasData) {
                    final chatsList = snapshot.data!;
                    if (chatsList.isEmpty) {
                      return const Center(
                        child: Text('No chats yet'),
                      );
                    }

                    return ListView.builder(
                      itemCount: chatsList.length,
                      itemBuilder: (context, index) {
                        final chat = chatsList[index];
                        final dateTime =
                            formatDate(chat.timeSent, [HH, ':', nn, ' ', am]);
                        // check if we sent the last message
                        final isMe = chat.senderUID == uid;
                        // dis the last message correctly
                        final lastMessage =
                            isMe ? 'You: ${chat.message}' : chat.message;

                        return ListTile(
                          leading: userImageWidget(
                            imageUrl: chat.contactImage,
                            radius: 40,
                            onTap: () {},
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Text(chat.contactName),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(dateTime),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: chat.contactUID,
                                Constants.contactName: chat.contactName,
                                Constants.contactImage: chat.contactImage,
                                Constants.groupId: '',
                              },
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No chats yet'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
