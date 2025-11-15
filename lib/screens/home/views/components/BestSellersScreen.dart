import 'package:flutter/material.dart';
import 'package:ecommerce/components/product/product_card.dart';
import 'package:ecommerce/models/product_model.dart';
import '../../../../constants.dart';
import '../../../../models/product_service.dart';
import '../../../../route/route_constants.dart';

class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _BestSellersScreenState();
}

class _BestSellersScreenState extends State<BestSellersScreen> {
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
        title: const Text('Best Sellers'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
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
            return const Center(child: Text('No products found'));
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
                childAspectRatio: 0.65, // Adjust height/width ratio as needed
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
                  // Optionally, you can add elevation, shadows inside ProductCard
                );
              },
            ),
          );
        },
      ),
    );
  }
}
