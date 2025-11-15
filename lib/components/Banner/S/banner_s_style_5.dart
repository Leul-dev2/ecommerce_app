import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import 'banner_s.dart';

class BannerSStyle5 extends StatelessWidget {
  const BannerSStyle5({
    super.key,
    this.image = "https://i.imgur.com/wQ0sNHT.png",
    required this.title,
    required this.press,
    this.subtitle,
    this.bottomText,
  });
  final String? image;
  final String title;
  final String? subtitle, bottomText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return BannerS(
      image: image!,
      press: press,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.15),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Important to avoid vertical overflow
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 40), // limit height to avoid overflow
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding / 1.5,
                            vertical: defaultPadding / 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,  // Limit lines to prevent overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: grandisExtendedFont,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 5,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (bottomText != null) ...[
                      const SizedBox(height: defaultPadding / 3),
                      Text(
                        bottomText!,
                        style: const TextStyle(
                          fontFamily: grandisExtendedFont,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(width: defaultPadding),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: press,
                splashColor: Colors.white24,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/miniRight.svg",
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.black87,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
