import 'package:flutter/material.dart';

import '../constants.dart';

class ChatActiveDot extends StatelessWidget {
  const ChatActiveDot({
    super.key,
    this.dotColor = successColor,
    this.size = 12.0, // Adding a size parameter for flexibility
  });
  final Color dotColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
