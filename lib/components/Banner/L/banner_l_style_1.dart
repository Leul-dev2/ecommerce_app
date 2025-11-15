import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ecommerce/components/Banner/L/banner_l.dart';
import '../../../constants.dart';

class BannerLStyle1 extends StatefulWidget {
  const BannerLStyle1({
    super.key,
    required this.image,
    required this.title,
    this.subtitle,
    required this.discountPercent,
    required this.press,
    this.showCountdown = false,
    this.countdownDuration,
  });

  final String image;
  final String title;
  final String? subtitle;
  final int discountPercent;
  final VoidCallback press;
  final bool showCountdown;
  final Duration? countdownDuration;

  @override
  State<BannerLStyle1> createState() => _BannerLStyle1State();
}

class _BannerLStyle1State extends State<BannerLStyle1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late Duration _remainingDuration;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // Setup entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Setup countdown timer if enabled
    if (widget.showCountdown && widget.countdownDuration != null) {
      _remainingDuration = widget.countdownDuration!;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingDuration.inSeconds <= 0) {
          timer.cancel();
        } else {
          setState(() {
            _remainingDuration = Duration(seconds: _remainingDuration.inSeconds - 1);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedCountdown {
    final h = _remainingDuration.inHours.toString().padLeft(2, '0');
    final m = (_remainingDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remainingDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: BannerL(
          image: widget.image,
          press: widget.press,
          children: [
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  _DiscountDisplay(percent: widget.discountPercent),

                  if (widget.subtitle != null)
                    Container(
                      margin: const EdgeInsets.only(top: defaultPadding / 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2,
                        vertical: defaultPadding / 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  if (widget.showCountdown && widget.countdownDuration != null) ...[
                    const SizedBox(height: defaultPadding / 2),
                    _CountdownTimer(text: _formattedCountdown),
                  ],

                  const SizedBox(height: defaultPadding),

                  Text(
                    widget.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: widget.press,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      elevation: 8,
                      shadowColor: Colors.black54,
                    ),
                    child: Text(
                      "Shop now",
                      style: TextStyle(
                        fontFamily: grandisExtendedFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountDisplay extends StatelessWidget {
  const _DiscountDisplay({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    TextStyle strokeStyle = TextStyle(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white70,
    );

    const fillStyle = TextStyle(color: Colors.white);

    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: grandisExtendedFont,
        fontSize: 64,
        height: 1.2,
        fontWeight: FontWeight.bold,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text("$percent", style: strokeStyle),
              Text("$percent", style: fillStyle),
            ],
          ),
          const SizedBox(width: defaultPadding / 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Text("%", style: strokeStyle),
              const Text("%", style: fillStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 1.5,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "Ends in $text",
        style: const TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
