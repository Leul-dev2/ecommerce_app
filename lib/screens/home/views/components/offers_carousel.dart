import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecommerce/components/Banner/M/banner_m_style_1.dart';
import 'package:ecommerce/components/Banner/M/banner_m_style_2.dart';
import 'package:ecommerce/components/Banner/M/banner_m_style_3.dart';
import 'package:ecommerce/components/Banner/M/banner_m_style_4.dart';

import '../../../../constants.dart';

const _carouselInterval = Duration(seconds: 5);
const _carouselAnimation = Duration(milliseconds: 800);
const _dotAnimation = Duration(milliseconds: 300);

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({super.key});

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final PageController _pageController;
  Timer? _timer;

  final List<Widget> offers = [
    BannerMStyle1(
      text: "New items with \nFree shipping",
      press: () {
        debugPrint("Free shipping banner tapped");
      },
    ),
    BannerMStyle2(
      title: "Black \nFriday",
      subtitle: "Collection",
      discountPercent: 50,
      press: () {
        debugPrint("Black Friday banner tapped");
      },
    ),
    BannerMStyle3(
      title: "Grab \nYours Now",
      discountPercent: 50,
      press: () {
        debugPrint("Grab yours banner tapped");
      },
    ),
    BannerMStyle4(
      title: "SUMMER \nSALE",
      subtitle: "SPECIAL OFFER",
      discountPercent: 80,
      press: () {
        debugPrint("Summer sale banner tapped");
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addObserver(this);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(_carouselInterval, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_selectedIndex + 1) % offers.length;
        _pageController.animateToPage(
          nextPage,
          duration: _carouselAnimation,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopAutoPlay();
    } else if (state == AppLifecycleState.resumed) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: _dotAnimation,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white70,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ]
            : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTapDown: (_) => _stopAutoPlay(),
        onTapUp: (_) => _startAutoPlay(),
        onPanDown: (_) => _stopAutoPlay(),
        onPanEnd: (_) => _startAutoPlay(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: offers.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final isActive = index == _selectedIndex;

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.hasClients && _pageController.page != null) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                    }

                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 300,
                        width: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width * 0.8,
                        child: child,
                      ),
                    );
                  },
                  child: Material(
                    elevation: isActive ? 8 : 2,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black54,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: offers[index],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: defaultPadding / 1.5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  offers.length,
                  (index) => _buildDotIndicator(_selectedIndex == index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
