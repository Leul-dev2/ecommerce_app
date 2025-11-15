import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({
    super.key,
    this.radius = 8.0,
    this.activeColor = primaryColor,
    this.iconColor = Colors.white,
    this.padding = const EdgeInsets.all(2),
    this.iconPath = "assets/icons/Singlecheck.svg",
  });

  final double radius;
  final Color activeColor;
  final Color iconColor;
  final EdgeInsets padding;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: activeColor,
      child: Padding(
        padding: padding,
        child: SvgPicture.asset(
          iconPath,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
