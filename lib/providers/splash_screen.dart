import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/route/route_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, logInScreenRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black for Netflix look
      body: Center(
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
            color: Color(0xFFE50914), // Netflix red
            fontFamily: 'BebasNeue', // Use a bold block font
          ),
          child: AnimatedTextKit(
            totalRepeatCount: 1,
            animatedTexts: [
              FadeAnimatedText(
                'LUXCART',
                duration: Duration(milliseconds: 2500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
