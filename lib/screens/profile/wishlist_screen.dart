import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';
import '../product/views/product_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final wishlist = wishlistProvider.wishlist;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  const Text("Your wishlist is empty", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                final ProductModel product = wishlist[index];

                return Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    wishlistProvider.remove(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Removed from wishlist"),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () => wishlistProvider.add(product),
                        ),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black54 : Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                imageUrl: product.image,
                                placeholder: (_, __) =>
                                    Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                                errorWidget: (_, __, ___) => const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.brandName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 36,
                                  child: Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '\$${product.priceAfterDiscount?.toStringAsFixed(2) ?? product.price.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (product.priceAfterDiscount != null)
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 20,
                                    onPressed: () => wishlistProvider.remove(product),
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
