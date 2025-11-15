import 'package:flutter/material.dart';

import '../../network_image_with_loader.dart';

class BannerS extends StatelessWidget {
  const BannerS({
    super.key,
    required this.image,
    required this.press,
    required this.children,
    this.aspectRatio = 2.56,
    this.overlayColor = Colors.black54,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
  });

  final String image;
  final VoidCallback press;
  final List<Widget> children;
  final double aspectRatio;
  final Color overlayColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: press,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkImageWithLoader(image, radius: 0),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      overlayColor.withOpacity(0.8),
                      overlayColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
