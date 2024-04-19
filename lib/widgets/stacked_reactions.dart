import 'package:fluterchatpro/models/message_model.dart';
import 'package:fluterchatpro/utilities/global_methods.dart';
import 'package:flutter/material.dart';

class StackedReactionWidget extends StatelessWidget {
  const StackedReactionWidget({
    super.key,
    required this.message,
    required this.size,
    required this.onTap,
  });

  final MessageModel message;
  final double size;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final allReactions = reactions.asMap().map((index, reaction) {
      final value = Container(
        margin: EdgeInsets.only(left: index * 20.0),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Text(
            reaction,
            style: TextStyle(
              fontSize: size,
            ),
          ),
        ),
      );
      return MapEntry(index, value);
    }).values.toList();

    return GestureDetector(
      onTap: onTap(),
      child: Stack(
        children: allReactions,
      ),
    );
  }
}
