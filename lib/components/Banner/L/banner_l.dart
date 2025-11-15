import 'package:flutter/material.dart';
import '../../network_image_with_loader.dart';

class BannerL extends StatelessWidget {
  const BannerL({
    super.key,
    required this.image,
    required this.press,
    required this.children,
    this.aspectRatio = 1.1,
    this.overlayColor,
    this.borderRadius = 12,
    this.boxShadow,
    this.contentPadding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.fit = StackFit.expand,
    this.semanticLabel,
  });

  /// Background image URL
  final String image;

  /// On tap callback
  final VoidCallback press;

  /// Foreground content widgets
  final List<Widget> children;

  /// Aspect ratio of the banner
  final double aspectRatio;

  /// Overlay color on top of image (default with opacity based on theme)
  final Color? overlayColor;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Optional box shadow
  final List<BoxShadow>? boxShadow;

  /// Padding around content children
  final EdgeInsets contentPadding;

  /// Clip behavior for rounded corners
  final Clip clipBehavior;

  /// How the children fill the banner
  final StackFit fit;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final defaultOverlay = overlayColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.black26);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: GestureDetector(
          onTap: press,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            clipBehavior: clipBehavior,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadow,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Stack(
                fit: fit,
                children: [
                  NetworkImageWithLoader(image, radius: 0),
                  Container(color: defaultOverlay),
                  Padding(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
