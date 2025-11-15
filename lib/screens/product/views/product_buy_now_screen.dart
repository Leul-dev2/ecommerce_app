import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/components/cart_button.dart';
import 'package:ecommerce/components/custom_modal_bottom_sheet.dart';
import 'package:ecommerce/components/network_image_with_loader.dart';
import 'package:ecommerce/screens/product/views/components/product_list_tile.dart';
import 'package:ecommerce/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/providers/cart_provider.dart';

import 'package:ecommerce/route/route_constants.dart';

import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';
import 'size_guide_screen.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final ProductModel product;

  const ProductBuyNowScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductBuyNowScreen> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int quantity = 1;
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0;
  bool isBookmarked = false;

  final List<Color> availableColors = const [
    Color(0xFFEA6262),
    Color(0xFFB1CC63),
    Color(0xFFFFBF5F),
    Color(0xFF9FE1DD),
    Color(0xFFC482DB),
  ];

  final List<String> availableSizes = const ["S", "M", "L", "XL", "XXL"];

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final product = widget.product;

    final selectedColor = availableColors[selectedColorIndex];
    final selectedColorHex = '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}';
    final selectedSize = availableSizes[selectedSizeIndex];

    cartProvider.addItem(
      productId: product.id,
      title: product.title,
      imageUrl: product.image,
      price: product.priceAfterDiscount ?? product.price,
      color: selectedColorHex,
      size: selectedSize,
      quantity: quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushNamed(context, cartScreenRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = (widget.product.priceAfterDiscount ?? widget.product.price) * quantity;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                /// ✅ Hero Sliver App Bar
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 320,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.product.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    background: Hero(
                      tag: 'product_${widget.product.id}',
                      child: Container(
                        margin: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: NetworkImageWithLoader(widget.product.image),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => setState(() => isBookmarked = !isBookmarked),
                      icon: Icon(
                        isBookmarked ? Icons.favorite : Icons.favorite_border,
                        color: isBookmarked ? Colors.redAccent : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                /// ✅ Price & Quantity
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.product.price,
                            priceAfterDiscount: widget.product.priceAfterDiscount,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: () => setState(() => quantity++),
                          onDecrement: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: Divider()),

                /// ✅ Colors
                SliverToBoxAdapter(
                  child: SelectedColors(
                    colors: availableColors,
                    selectedColorIndex: selectedColorIndex,
                    press: (index) => setState(() => selectedColorIndex = index),
                  ),
                ),

                /// ✅ Sizes
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: availableSizes,
                    selectedIndex: selectedSizeIndex,
                    press: (index) => setState(() => selectedSizeIndex = index),
                  ),
                ),

                /// ✅ Size Guide
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Size Guide",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SizeGuideScreen(),
                        ),
                      );
                    },
                  ),
                ),

                /// ✅ Store Availability
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Store Pickup Availability",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text("Selected Size: ${availableSizes[selectedSizeIndex]}"),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Check Stores",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            /// ✅ Sticky Bottom Add To Cart
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CartButton(
                price: totalPrice,
                title: "Add to Cart",
                subTitle: "Total",
                press: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
