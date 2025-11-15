import 'package:flutter/material.dart';
import 'package:ecommerce/components/product/product_card.dart';
import 'package:ecommerce/models/product_model.dart';
import '../../../../route/route_constants.dart';
import '../../../../models/product_service.dart';

class BestSellers extends StatefulWidget {
  const BestSellers({super.key});

  @override
  _BestSellersState createState() => _BestSellersState();
}

class _BestSellersState extends State<BestSellers> {
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0), // Use fixed padding for clarity
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Best sellers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, bestSellersScreenRoute);
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              final products = snapshot.data!;
              final displayProducts =
                  products.length > 6 ? products.sublist(0, 6) : products;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: index == displayProducts.length - 1 ? 16.0 : 0,
                    ),
                    child: ProductCard(
                      image: product.image,
                      brandName: product.brandName,
                      title: product.title,
                      price: product.price,
                      priceAfterDiscount: product.priceAfterDiscount, // fixed typo
                      discountPercent: product.discountPercent, // fixed typo
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
