import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/components/cart_button.dart';
import 'package:ecommerce/components/custom_modal_bottom_sheet.dart';
import 'package:ecommerce/components/product/product_card.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/route/screen_export.dart';
import 'package:ecommerce/screens/product/views/product_returns_screen.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/providers/bookmark_provider.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  final String? categoryTitle;
  final String? subcategoryTitle;
  final bool isProductAvailable;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.categoryTitle,
    this.subcategoryTitle,
    this.isProductAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final relatedProducts = product.relatedProducts ?? [];

    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: product.priceAfterDiscount ?? product.price,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: product),
                );
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            if (categoryTitle != null) _buildCategoryRow(context),
            ProductImages(images: [product.image]),
            ProductInfo(
              brand: product.brandName,
              title: product.title,
              isAvailable: isProductAvailable,
              description: product.description ?? "No description available.",
              rating: product.rating ?? 0.0,
              numOfReviews: product.reviews?.length ?? 0,
            ),

            // Full Specs, Shipping, Returns, Seller info
            _buildSectionTile(context,
                title: "Full Specifications",
                svgSrc: "assets/icons/Product.svg", onTap: () {
              customModalBottomSheet(
                context,
                height: MediaQuery.of(context).size.height * 0.65,
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Specifications",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _buildSpecRow("Material", product.material ?? "Unknown"),
                      _buildSpecRow("Brand", product.brandName),
                      _buildSpecRow("Origin", product.origin ?? "China"),
                      _buildSpecRow("Weight", "${product.weight ?? "0.5"} kg"),
                      _buildSpecRow("SKU", product.sku ?? "N/A"),
                    ],
                  ),
                ),
              );
            }),
            _buildSectionTile(
              context,
              title: "Shipping & Delivery",
              svgSrc: "assets/icons/Delivery.svg",
              onTap: () {
                final estimatedDays = 3 + (product.price % 5).toInt();
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Shipping Information",
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          "• Estimated Delivery: ${DateTime.now().add(Duration(days: estimatedDays)).toLocal().toString().split(' ')[0]}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "• Ships from: Warehouse A (International)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "• Free shipping on orders over \$50.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Note: Delivery times may vary during peak seasons.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildSectionTile(
              context,
              title: "Returns & Guarantee",
              svgSrc: "assets/icons/Return.svg",
              onTap: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            _buildSectionTile(
              context,
              title: "Seller Information",
              svgSrc: "assets/icons/Profile.svg",
              onTap: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.sellerName ?? "Official Store",
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          "Contact seller for more details or bulk orders. Verified seller with 98% positive feedback.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat),
                          label: const Text("Contact Seller"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (product.reviews != null && product.reviews!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: ReviewCard(
                    rating: product.rating ?? 0.0,
                    numOfReviews: product.reviews!.length,
                    numOfFiveStar: 80,
                    numOfFourStar: 30,
                    numOfThreeStar: 5,
                    numOfTwoStar: 4,
                    numOfOneStar: 1,
                  ),
                ),
              ),

            _buildSectionTile(
              context,
              title: "Customer Reviews",
              svgSrc: "assets/icons/Chat.svg",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  productReviewsScreenRoute,
                  arguments: product,
                );
              },
            ),

            // Related Products
            if (relatedProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    defaultPadding,
                    defaultPadding,
                    4,
                  ),
                  child: Text(
                    "You May Also Like",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            if (relatedProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    itemCount: relatedProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = relatedProducts[index];
                      return ProductCard(
                        image: item.image,
                        title: item.title,
                        brandName: item.brandName,
                        price: item.price,
                        priceAfterDiscount: item.priceAfterDiscount,
                        discountPercent: item.discountPercent,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(product: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: true,
      elevation: 0,
      centerTitle: true,
      title: Text(
        product.title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlist, _) {
            final isWishlisted = wishlist.isInWishlist(product);
            return IconButton(
              onPressed: () {
                wishlist.toggle(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isWishlisted
                        ? "Removed from wishlist"
                        : "Added to wishlist"),
                  ),
                );
              },
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : null,
              ),
            );
          },
        ),
        Consumer<BookmarkProvider>(
          builder: (context, bookmark, _) {
            final isBookmarked = bookmark.isBookmarked(product);
            return IconButton(
              onPressed: () {
                bookmark.toggleBookmark(product);
                final isNowBookmarked = bookmark.isBookmarked(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isNowBookmarked
                          ? "Added to bookmarks"
                          : "Removed from bookmarks",
                    ),
                  ),
                );
              },
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? Colors.blueAccent : null,
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------- CATEGORY ROW ----------------
  Widget _buildCategoryRow(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: 8,
        ),
        child: Row(
          children: [
            Text(
              "Category: ",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(categoryTitle!),
            if (subcategoryTitle != null) ...[
              const SizedBox(width: 16),
              Text(
                "Subcategory: ",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(subcategoryTitle!),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- SECTION TILE ----------------
  Widget _buildSectionTile(
      BuildContext context, {
        required String title,
        required String svgSrc,
        required VoidCallback onTap,
      }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: SvgPicture.asset(svgSrc, width: 22),
            title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  // ---------------- SPEC ROW ----------------
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
