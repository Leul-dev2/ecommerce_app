import 'package:flutter/material.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search products, categories...",
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
