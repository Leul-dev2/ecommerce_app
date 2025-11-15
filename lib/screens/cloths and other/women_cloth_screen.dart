import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../models/product_model.dart';

// ✅ Model for Category with subcategories
class CategoryModel {
  final String title;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.title,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var subs = <SubCategoryModel>[];
    if (json['subCategories'] != null) {
      subs = List.from(json['subCategories'])
          .map((e) => SubCategoryModel.fromJson(e))
          .toList();
    }
    return CategoryModel(
      title: json['title'],
      subCategories: subs,
    );
  }
}

class SubCategoryModel {
  final String title;
  final String? thumbnail;

  SubCategoryModel({required this.title, this.thumbnail});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      title: json['title'],
      thumbnail: json['thumbnail'],
    );
  }
}

class WomenClothScreen extends StatefulWidget {
  const WomenClothScreen({super.key});

  @override
  State<WomenClothScreen> createState() => _WomenClothScreenState();
}

class _WomenClothScreenState extends State<WomenClothScreen> {
  String selectedCategory = "All";
  CategoryModel? womenCategory;

  String errorMessage = '';
  bool loading = true;

  final List<ProductModel> allProducts = [
    ProductModel(
      id: "w1",
      image: "https://i.imgur.com/8z5eVSl.jpg",
      brandName: "Zara",
      title: "Summer Dress",
      price: 45.0,
    ),
    ProductModel(
      id: "w2",
      image: "https://i.imgur.com/Az2ZP5Y.jpg",
      brandName: "H&M",
      title: "Casual Top",
      price: 25.0,
    ),
    ProductModel(
      id: "w3",
      image: "https://i.imgur.com/JrPZuz2.jpg",
      brandName: "Uniqlo",
      title: "Skinny Jeans",
      price: 40.0,
    ),
    ProductModel(
      id: "w4",
      image: "https://i.imgur.com/4AyFZk7.jpg",
      brandName: "Gucci",
      title: "Heels",
      price: 120.0,
    ),
  ];

  List<ProductModel> get filteredProducts {
    if (selectedCategory == "All") {
      return allProducts;
    } else {
      return allProducts.where((product) {
        return product.title
            .toLowerCase()
            .contains(selectedCategory.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchWomenCategory() async {
    try {
      final res = await http
          .get(Uri.parse('https://backend-ecomm-jol4.onrender.com/api/categories'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as List;
        final mainCategory = decoded.firstWhere(
          (c) => c['title'].toString().toLowerCase().contains("women"),
          orElse: () => null,
        );

        if (mainCategory != null) {
          setState(() {
            womenCategory = CategoryModel.fromJson(mainCategory);
            loading = false;
          });
        } else {
          throw Exception("Women's category not found");
        }
      } else {
        throw Exception('Failed to load categories: HTTP ${res.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out.';
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWomenCategory();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Women's Clothing")),
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Women's Clothing")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Subcategory horizontal selector
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (womenCategory?.subCategories.length ?? 0) + 1,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, index) {
                final isAll = index == 0;
                final title = isAll ? "All" : womenCategory!.subCategories[index - 1].title;

                final isSelected = title == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = title;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pink : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ✅ Product grid
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, index) {
                      final product = filteredProducts[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  product.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.brandName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "\$${product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
