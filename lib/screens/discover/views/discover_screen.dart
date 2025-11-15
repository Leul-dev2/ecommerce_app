
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/models/category_model.dart';
import '../../product/views/product_details_screen.dart'; // ✅ Import your detail screen
import 'components/category_card.dart';
import 'components/flash_sale_card.dart';
import 'components/recommended_card.dart';

class DiscoverScreen extends StatelessWidget {
  final List<ProductModel> allProducts;
  final List<CategoryModel> allCategories;

  const DiscoverScreen({
    super.key,
    required this.allProducts,
    required this.allCategories,
  });

  @override
  Widget build(BuildContext context) {
    final featuredBanners =
        allProducts.where((p) => (p.discountPercent ?? 0) > 30).toList();
    final flashDeals =
        allProducts.where((p) => (p.discountPercent ?? 0) >= 10).toList();
    final recommended =
        allProducts.where((p) => (p.rating ?? 0) >= 4.0).toList();
    final topCategories = allCategories.take(8).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🔥 Removed SearchBar — clean header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  "Discover",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCarousel(context, featuredBanners),
                  const SizedBox(height: defaultPadding),
                  _buildSectionHeader("Top Categories", context,
                      icon: Icons.category),
                  _buildCategoriesGrid(topCategories),
                  const SizedBox(height: defaultPadding),
                  _buildSectionHeader("Flash Deals", context,
                      icon: Icons.flash_on),
                  _buildFlashDealsRow(context, flashDeals),
                  const SizedBox(height: defaultPadding),
                  _buildSectionHeader("Recommended For You", context,
                      icon: Icons.star),
                ],
              ),
            ),

            // ✅ Grid for recommended products
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = recommended[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: RecommendedCard(product: product),
                    );
                  },
                  childCount: recommended.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  /// ✅ Hero Carousel
  Widget _buildHeroCarousel(BuildContext context, List<ProductModel> banners) {
    if (banners.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text("No featured banners")),
      );
    }

    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
      ),
      itemBuilder: (context, index, _) {
        final product = banners[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "🔥 ${product.title} - ${product.discountPercent}% OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Section Header
  Widget _buildSectionHeader(String title, BuildContext context,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              debugPrint("See All tapped for $title");
            },
            child: const Text("See All"),
          ),
        ],
      ),
    );
  }

  /// ✅ Categories Grid
  Widget _buildCategoriesGrid(List<CategoryModel> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: defaultPadding,
          crossAxisSpacing: defaultPadding,
        ),
        itemBuilder: (context, index) {
          return CategoryCard(category: categories[index]);
        },
      ),
    );
  }

  /// ✅ Flash Deals Horizontal
  Widget _buildFlashDealsRow(BuildContext context, List<ProductModel> deals) {
    if (deals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No flash deals")),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: defaultPadding / 2),
        itemBuilder: (context, index) {
          final product = deals[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              );
            },
            child: FlashSaleCard(product: product),
          );
        },
      ),
    );
  }
}
