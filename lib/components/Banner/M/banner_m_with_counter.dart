import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../blur_container.dart';
import 'banner_m.dart';

class BannerMWithCounter extends StatefulWidget {
  const BannerMWithCounter({
    super.key,
    this.image = "https://i.imgur.com/pRgcbpS.png",
    required this.text,
    required this.duration,
    required this.press,
    this.onFinished,
  });

  final String image, text;
  final Duration duration;
  final VoidCallback press;

  /// ✅ Optional callback when timer hits zero
  final VoidCallback? onFinished;

  @override
  State<BannerMWithCounter> createState() => _BannerMWithCounterState();
}

class _BannerMWithCounterState extends State<BannerMWithCounter> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = Duration(seconds: _duration.inSeconds - 1);
        } else {
          _timer?.cancel();
          widget.onFinished?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _duration.inHours.toString().padLeft(2, '0');
    final minutes = _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return BannerM(
      image: widget.image,
      press: widget.press,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlurContainer(text: hours),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
                    child: SvgPicture.asset(
                      "assets/icons/dot.svg",
                      height: 12,
                      width: 12,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  BlurContainer(text: minutes),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
                    child: SvgPicture.asset(
                      "assets/icons/dot.svg",
                      height: 12,
                      width: 12,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  BlurContainer(text: seconds),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
