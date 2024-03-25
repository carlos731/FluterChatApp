import 'package:fluterchatpro/enums/enums.dart';
import 'package:fluterchatpro/models/user_model.dart';
import 'package:fluterchatpro/providers/authentication_provider.dart';
import 'package:fluterchatpro/utilities/constants.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
  });

  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    final future = viewType == FriendViewType.friends
        ? context.read<AuthenticationProvider>().getFriendsList(uid)
        : viewType == FriendViewType.friendRequests
            ? context.read<AuthenticationProvider>().getFriendRequestsList(uid)
            : context.read<AuthenticationProvider>().getFriendsList(uid);

    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(child: Text('No Friends yet'));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return ListTile(
                contentPadding: const EdgeInsets.only(left: -10),
                leading: userImageWidget(
                  imageUrl: data.image,
                  radius: 40,
                  onTap: () {
                    // navigate to this friends profile with uid as argument
                    Navigator.pushNamed(
                      context,
                      Constants.profileScreen,
                      arguments: data.uid,
                    );
                  },
                ),
                title: Text(data.name),
                subtitle: Text(
                  data.aboutMe,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (viewType == FriendViewType.friends) {
                      // Navigate to chat screen with uid as argument
                      // Navigator.pushNamed(context, Constants.chatScreen, arguments: data.uid,);
                    } else if (viewType == FriendViewType.friendRequests) {
                      await context
                          .read<AuthenticationProvider>()
                          .acceptFriendRequest(friendID: data.uid)
                          .whenComplete(() {
                        showSnackBar(context,
                            'You are now friends with ${data.name}');
                      });
                    } else {
                      // check the check box
                    }
                  },
                  child: viewType == FriendViewType.friends
                      ? const Text('Chat')
                      : const Text('Accept'),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
