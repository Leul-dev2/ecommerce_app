import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';
import '../../../../models/product_service.dart';
import '../../../../route/route_constants.dart';
import '../../../../components/product/product_card.dart';

class PopularProductsScreen extends StatefulWidget {
  const PopularProductsScreen({super.key});

  @override
  State<PopularProductsScreen> createState() => _PopularProductsScreenState();
}

class _PopularProductsScreenState extends State<PopularProductsScreen> {
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Products'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No popular products found'));
          }

          final products = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: defaultPadding,
                mainAxisSpacing: defaultPadding,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
