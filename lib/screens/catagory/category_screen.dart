import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/product_model.dart';
import '../../screens/product/views/product_details_screen.dart'; // Import your product details screen

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool loading = true;
  String error = '';

  List<String> subcategories = ["All"];
  String selectedSubcategory = "All";

  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    fetchSubcategoriesAndProducts();
  }

  Future<void> fetchSubcategoriesAndProducts() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final categoryRes = await http.get(
        Uri.parse('https://backend-ecomm-jol4.onrender.com/api/categories'),
      );

      if (categoryRes.statusCode == 200) {
        final List decoded = json.decode(categoryRes.body);

        // Using firstWhere with orElse returning an empty map safely
        final catData = decoded.cast<Map<String, dynamic>>().firstWhere(
              (cat) =>
                  cat['title'].toString().toLowerCase() ==
                  widget.categoryName.toLowerCase(),
              orElse: () => <String, dynamic>{},
            );

        if (catData.isEmpty) {
          throw Exception("Category not found");
        }

        final fetchedSubs = (catData['subCategories'] as List?)
                ?.map((sub) => sub['title'].toString())
                .toList() ??
            [];

        setState(() {
          subcategories = ["All", ...fetchedSubs];
        });

        await fetchProducts();
      } else {
        throw Exception("Failed to fetch category");
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        loading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      loading = true;
    });

    try {
      String url =
          'https://backend-ecomm-jol4.onrender.com/api/products?category=${Uri.encodeComponent(widget.categoryName)}';

      if (selectedSubcategory != "All") {
        url += '&subcategory=${Uri.encodeComponent(selectedSubcategory)}';
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);

        setState(() {
          products = decoded
              .map<ProductModel>((json) => ProductModel.fromMap(json))
              .toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load products';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  void onSubcategorySelected(String sub) {
    setState(() {
      selectedSubcategory = sub;
    });
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(error)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subcategory filter list
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subcategories.length,
              itemBuilder: (_, index) {
                final sub = subcategories[index];
                final isSelected = sub == selectedSubcategory;

                return GestureDetector(
                  onTap: () => onSubcategorySelected(sub),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sub,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Products grid
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: product,
                                categoryTitle: widget.categoryName,
                                subcategoryTitle: selectedSubcategory == "All"
                                    ? null
                                    : selectedSubcategory,
                              ),
                            ),
                          );
                        },
                        child: Card(
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
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.brandName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(product.title),
                                    Text("\$${product.price}",
                                        style: const TextStyle(color: Colors.blue)),
                                  ],
                                ),
                              )
                            ],
                          ),
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
