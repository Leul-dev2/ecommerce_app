import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'banner_m.dart';
import '../../../constants.dart';

class BannerMStyle4 extends StatelessWidget {
  const BannerMStyle4({
    super.key,
    this.image = "https://i.imgur.com/R4iKkDD.png",
    required this.title,
    required this.press,
    required this.discountPercent,
    this.subtitle,
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2,
                          vertical: defaultPadding / 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: defaultPadding / 2),
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
                    Text(
                      "UP TO $discountPercent% OFF",
                      style: const TextStyle(
                        fontFamily: grandisExtendedFont,
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: defaultPadding),
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
      ],
    );
  }
}
