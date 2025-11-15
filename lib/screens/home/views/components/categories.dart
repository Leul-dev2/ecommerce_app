import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../constants.dart';
import '../../../../route/screen_export.dart'; // Your route constants

// ✅ Category model
class CategoryModel {
  final String name;
  final String? svgSrc;

  CategoryModel({
    required this.name,
    this.svgSrc,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['title'],
      svgSrc: json['svgSrc'],
    );
  }
}

// ✅ Categories bar widget
class Categories extends StatelessWidget {
  const Categories({super.key});

  Future<List<CategoryModel>> fetchCategories() async {
    final res = await http.get(
      Uri.parse('https://backend-ecomm-jol4.onrender.com/api/categories'),
    );
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body) as List;
      return decoded.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final categories = snapshot.data!;
        final allCategories = [
          CategoryModel(name: "All Categories"),
          ...categories,
        ];
        final dropdownCategories = allCategories.sublist(1);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              /// ✅ "All Categories" with dropdown
              Padding(
                padding: const EdgeInsets.only(left: defaultPadding, right: 0),
                child: PopupMenuButton<CategoryModel>(
                  onSelected: (category) {
                    Navigator.pushNamed(
                      context,
                      categoryScreenRoute,
                      arguments: {'categoryName': category.name},
                    );
                  },
                  itemBuilder: (_) => dropdownCategories.map((category) {
                    return PopupMenuItem<CategoryModel>(
                      value: category,
                      child: Row(
                        children: [
                          if (category.svgSrc != null)
                            SvgPicture.network(
                              category.svgSrc!,
                              height: 20,
                              placeholderBuilder: (_) =>
                                  const Icon(Icons.category),
                            ),
                          if (category.svgSrc != null)
                            const SizedBox(width: defaultPadding / 2),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  child: CategoryBtn(
                    category: allCategories[0].name,
                    svgSrc: allCategories[0].svgSrc,
                    isActive: true,
                    press: null,
                  ),
                ),
              ),

              /// ✅ Individual category buttons
              ...dropdownCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: defaultPadding / 2,
                    right: category == dropdownCategories.last
                        ? defaultPadding
                        : 0,
                  ),
                  child: CategoryBtn(
                    category: category.name,
                    svgSrc: category.svgSrc,
                    isActive: false,
                    press: () {
                      Navigator.pushNamed(
                        context,
                        categoryScreenRoute,
                        arguments: {'categoryName': category.name},
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Single category button
class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.network(
                svgSrc!,
                height: 20,
                placeholderBuilder: (_) => const Icon(Icons.category),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
