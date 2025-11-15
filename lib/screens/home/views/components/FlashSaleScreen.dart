import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';
import '../../../../models/product_service.dart';
import '../../../../route/route_constants.dart';
import '../../../../components/product/product_card.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductService().fetchProducts();
  }

  void _retryFetch() {
    setState(() {
      _futureProducts = ProductService().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Sale'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
            // ✅ If using shimmer:
            // return ShimmerGridPlaceholder();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Something went wrong.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retryFetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No products found.'),
            );
          }

          final products = snapshot.data!;

          // ✅ Filter products for flash sale only
          final flashSaleProducts = products
              .where((p) => p.discountPercent != null && p.discountPercent! > 0)
              .toList();

          if (flashSaleProducts.isEmpty) {
            return const Center(
              child: Text('No flash sale products found.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: GridView.builder(
              itemCount: flashSaleProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: defaultPadding,
                mainAxisSpacing: defaultPadding,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = flashSaleProducts[index];
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
