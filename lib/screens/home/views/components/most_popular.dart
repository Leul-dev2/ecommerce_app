import 'package:flutter/material.dart';
import 'package:ecommerce/components/product/secondary_product_card.dart';
import 'package:ecommerce/models/product_model.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';
import '../../../../models/product_service.dart';

class MostPopular extends StatefulWidget {
  const MostPopular({super.key});

  @override
  _MostPopularState createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
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
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Most Popular",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 114,
          child: FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              final allProducts = snapshot.data!;

              // ✅ Filter only products marked as popular
              final popularProducts = allProducts
                  .where((product) =>
                      product.isPopular == true ||
                      (product.rating != null && product.rating! >= 4.0))
                  .toList();

              if (popularProducts.isEmpty) {
                return const Center(
                    child: Text('No popular products found.'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularProducts.length,
                itemBuilder: (context, index) {
                  final product = popularProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == popularProducts.length - 1
                          ? defaultPadding
                          : 0,
                    ),
                    child: SecondaryProductCard(
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
        )
      ],
    );
  }
}
