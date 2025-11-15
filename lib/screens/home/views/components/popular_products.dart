import 'package:flutter/material.dart';
import 'package:ecommerce/components/product/product_card.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/route/route_constants.dart'; // make sure this import is correct

import '../../../../constants.dart';
import '../../../../models/product_service.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  _PopularProductsState createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
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
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular Products",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, popularProductsScreenRoute);
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
                      left: defaultPadding,
                      right: index == displayProducts.length - 1
                          ? defaultPadding
                          : 0,
                    ),
                    child: ProductCard(
                      image: product.image,
                      brandName: product.brandName,
                      title: product.title,
                      price: product.price,
                      priceAfterDiscount: product.priceAfterDiscount,
                      discountPercent: product.discountPercent,
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
