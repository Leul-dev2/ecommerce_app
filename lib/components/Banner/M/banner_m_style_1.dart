import 'package:flutter/material.dart';

import 'banner_m.dart';
import '../../../constants.dart';

class BannerMStyle1 extends StatelessWidget {
  const BannerMStyle1({
    super.key,
    this.image,
    required this.text,
    required this.press,
  });

  final String? image;
  final String text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: BannerM(
        image: image ?? 'assets/images/women-orn.jpg',
        press: press,
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding / 2),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: press,
                  child: const Text("Shop now"),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
