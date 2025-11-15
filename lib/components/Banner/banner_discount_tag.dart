import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';

class BannerDiscountTag extends StatelessWidget {
  const BannerDiscountTag({
    super.key,
    this.width = 40,
    this.height = 70,
    required this.percentage,
    this.percentageFontSize = 12,
    this.backgroundGradient,
    this.textColor = Colors.white,
  });

  final double width, height;
  final int percentage;
  final double percentageFontSize;
  final Gradient? backgroundGradient;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background SVG with gradient overlay
          SvgPicture.asset(
            "assets/icons/Discount_tag.svg",
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0), // Hide original color to show gradient
              BlendMode.dst,
            ),
          ),

          // Gradient background with rounded corners to mimic tag shape
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: backgroundGradient ??
                  LinearGradient(
                    colors: [
                      Colors.redAccent.shade700,
                      Colors.red.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          // Text with shadow for readability
          Text(
            "$percentage%\noff",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: grandisExtendedFont,
              color: textColor,
              fontSize: percentageFontSize,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black45,
                  offset: Offset(1, 1),
                )
              ],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
