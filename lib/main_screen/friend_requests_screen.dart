import 'package:fluterchatpro/enums/enums.dart';
import 'package:fluterchatpro/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: Column(
        children: [
          // cupertinosearchbar
          CupertinoSearchTextField(
            placeholder: 'Search',
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              print(value);
            },
          ),

          const Expanded(
            child: FriendsList(
              viewType: FriendViewType.friendRequests,
            ),
          ),
        ],
      ),
    );
  }
}
