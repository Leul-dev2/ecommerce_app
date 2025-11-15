import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';

class BannerLSkelton extends StatelessWidget {
  const BannerLSkelton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return AspectRatio(
      aspectRatio: 1.1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            color: baseColor,
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Big title placeholder bar
                Container(
                  width: 160,
                  height: 28,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                SizedBox(height: defaultPadding / 2),

                // Subtitle placeholder bar
                Container(
                  width: 220,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                const Spacer(),

                // Button placeholder pill shape
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
