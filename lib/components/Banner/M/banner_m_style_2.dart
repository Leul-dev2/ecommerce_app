import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../banner_discount_tag.dart';
import 'banner_m.dart';

import '../../../constants.dart';

class BannerMStyle2 extends StatelessWidget {
  const BannerMStyle2({
    super.key,
    this.image = "https://i.imgur.com/J1Qjut7.png",
    required this.title,
    required this.press,
    this.subtitle,
    required this.discountPercent,
  });

  final String? image;
  final String title;
  final String? subtitle;
  final int discountPercent;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return BannerM(
      image: image!,
      press: press,
      children: [
        // Gradient overlay for readability
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Texts
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: grandisExtendedFont,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    if (subtitle != null)
                      Text(
                        subtitle!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: defaultPadding),
              // CTA Button
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/Arrow - Right.svg",
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: press,
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),
        // Discount Tag
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BannerDiscountTag(percentage: discountPercent),
          ),
        ),
      ],
    );
  }
}
