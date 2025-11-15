import 'package:flutter/material.dart';

import '../../network_image_with_loader.dart';

class BannerM extends StatelessWidget {
  const BannerM({
    super.key,
    required this.image,
    required this.press,
    required this.children,
    this.borderRadius = 16.0,
    this.showGradient = true,
  });

  final String image;
  final VoidCallback press;
  final List<Widget> children;
  final double borderRadius;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithLoader(
              image,
              radius: 0,
            ),
            if (showGradient)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: press,
                splashColor: Colors.white24,
                highlightColor: Colors.white10,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Stack(children: children),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
