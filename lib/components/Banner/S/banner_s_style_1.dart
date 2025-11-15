import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../banner_discount_tag.dart';

import '../../../constants.dart';
import 'banner_s.dart';

class BannerSStyle1 extends StatefulWidget {
  const BannerSStyle1({
    super.key,
    this.image = "https://i.imgur.com/K41Mj7C.png",
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
  State<BannerSStyle1> createState() => _BannerSStyle1State();
}

class _BannerSStyle1State extends State<BannerSStyle1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BannerS(
      image: widget.image ?? "https://i.imgur.com/K41Mj7C.png",
      press: widget.press,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.15),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Texts + discount badge
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount badge pill style
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE84118), Color(0xFFFF6F45)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "${widget.discountPercent}% OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding / 2),

                        // Title
                        Text(
                          widget.title.toUpperCase(),
                          style: textTheme.headlineMedium?.copyWith(
                            fontFamily: grandisExtendedFont,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.1,
                            shadows: const [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black54,
                                offset: Offset(1, 2),
                              )
                            ],
                          ),
                        ),

                        // Optional Subtitle
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle!.toUpperCase(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: defaultPadding),

                  // Right: CTA Button with hover & tap animation
                  _AnimatedCTAButton(onTap: widget.press),
                ],
              ),
            ),
          ),
        ),

        // Positioned discount tag - optional fallback
        Align(
          alignment: Alignment.topCenter,
          child: BannerDiscountTag(
            percentage: widget.discountPercent,
            height: 48,
          ),
        ),
      ],
    );
  }
}

class _AnimatedCTAButton extends StatefulWidget {
  const _AnimatedCTAButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _animController.drive(
      Tween(begin: 1.0, end: 0.9),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _animController.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    _animController.forward();
    widget.onTap();
  }

  void _onTapCancel() {
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              "assets/icons/Arrow - Right.svg",
              colorFilter:
                  const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
