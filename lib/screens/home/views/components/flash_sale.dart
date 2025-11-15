import 'package:flutter/material.dart';
import 'package:ecommerce/route/route_constants.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';
import '../../../../models/product_service.dart';

class FlashSale extends StatefulWidget {
  const FlashSale({super.key});

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    _futureProducts = ProductService().fetchProducts();
  }

  void _retryFetch() {
    setState(() => _fetchProducts());
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Flash Sale",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, flashSaleScreenRoute),
            child: const Text(
              "See All",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _retryFetch,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
      // or replace with shimmer horizontal loader
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    final flashSaleProducts = products
        .where((p) => p.discountPercent != null && p.discountPercent! > 0)
        .toList();

    if (flashSaleProducts.isEmpty) {
      return const Center(child: Text('No flash sale products.'));
    }

    final displayProducts = flashSaleProducts.length > 6
        ? flashSaleProducts.sublist(0, 6)
        : flashSaleProducts;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return Padding(
          padding: EdgeInsets.only(
            left: defaultPadding,
            right: index == displayProducts.length - 1 ? defaultPadding : 0,
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Banner with countdown
        BannerMWithCounter(
          duration: const Duration(hours: 8),
          text: "Super Flash Sale\n50% Off",
          press: () {
            Navigator.pushNamed(context, flashSaleScreenRoute);
          },
        ),

        const SizedBox(height: defaultPadding / 2),

        // ✅ Section header
        _buildSectionHeader(),

        // ✅ Flash sale product list
        SizedBox(
          height: 220,
          child: FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              } else if (snapshot.hasError) {
                return _buildError('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found.'));
              } else {
                return _buildProductList(snapshot.data!);
              }
            },
          ),
        ),
      ],
    );
  }
}
