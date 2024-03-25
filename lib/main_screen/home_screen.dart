import 'package:fluterchatpro/main_screen/chats_list_screen.dart';
import 'package:fluterchatpro/main_screen/groups_screen.dart';
import 'package:fluterchatpro/main_screen/people_screen.dart';
import 'package:fluterchatpro/providers/authentication_provider.dart';
import 'package:fluterchatpro/utilities/assets_manager.dart';
import 'package:fluterchatpro/utilities/constants.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    ChatsListScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Chat Pro"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(
              imageUrl: authProvider.userModel!.image,
              radius: 20,
              onTap: () {
                // navigate to user profile with uis as arguments
                Navigator.pushNamed(
                  context,
                  Constants.profileScreen,
                  arguments: authProvider.userModel!.uid,
                );
              },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: "Group",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: "People",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          // animate to the page
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );

          setState(() {
            currentIndex = index;
          });

          //print('index: $currentIndex');
        },
      ),
    );
  }
}
