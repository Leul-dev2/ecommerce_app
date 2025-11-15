import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/product_model.dart';
import '../../models/category_model.dart';

class ElectronicsScreen extends StatefulWidget {
  const ElectronicsScreen({super.key});

  @override
  State<ElectronicsScreen> createState() => _ElectronicsScreenState();
}

class _ElectronicsScreenState extends State<ElectronicsScreen> {
  List<CategoryModel> electronicsCategories = [CategoryModel(title: "All")];
  List<ProductModel> electronicsProducts = [];

  String selectedCategory = "All";
  bool loadingCategories = true;
  bool loadingProducts = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await http
          .get(Uri.parse('https://backend-ecomm-jol4.onrender.com/api/categories'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);

        final electronicsCategory = decoded.firstWhere(
          (cat) => (cat['title'] as String).toLowerCase() == "electronics",
          orElse: () => null,
        );

        if (electronicsCategory != null) {
          List subs = electronicsCategory['subCategories'] ?? [];
          setState(() {
            electronicsCategories = [
              CategoryModel(title: "All"),
              ...subs.map<CategoryModel>(
                (sub) => CategoryModel(title: sub['title']),
              ),
            ];
            loadingCategories = false;
          });
        } else {
          setState(() {
            errorMessage = "Electronics category not found";
            loadingCategories = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load categories: HTTP ${res.statusCode}';
          loadingCategories = false;
        });
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
        loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        loadingCategories = false;
      });
    }
  }

  Future<void> fetchProducts({String? subcategory}) async {
    setState(() {
      loadingProducts = true;
    });

    try {
      String url = 'https://backend-ecomm-jol4.onrender.com/api/products?category=electronics';
      if (subcategory != null && subcategory != "All") {
        url += '&subcategory=${Uri.encodeComponent(subcategory)}';
      }

      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);
        setState(() {
          electronicsProducts = decoded
              .map<ProductModel>((json) => ProductModel.fromMap(json))
              .toList();
          loadingProducts = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products: HTTP ${res.statusCode}';
          loadingProducts = false;
        });
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Product request timed out.';
        loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        loadingProducts = false;
      });
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchProducts(subcategory: category == "All" ? null : category);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingCategories) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Electronics")),
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
      appBar: AppBar(title: const Text("Electronics")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: electronicsCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, index) {
                final category = electronicsCategories[index];
                final isSelected = category.title == selectedCategory;

                return GestureDetector(
                  onTap: () => onCategorySelected(category.title),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.title,
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
          Expanded(
            child: loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : electronicsProducts.isEmpty
                    ? const Center(child: Text("No products found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: electronicsProducts.length,
                        itemBuilder: (_, index) {
                          final product = electronicsProducts[index];
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
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image, size: 50),
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
                                            color: Colors.deepPurple,
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
