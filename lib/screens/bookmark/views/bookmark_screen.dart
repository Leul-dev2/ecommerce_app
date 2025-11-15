import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ecommerce/route/route_constants.dart';
import 'package:ecommerce/providers/bookmark_provider.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        centerTitle: true,
        title: Consumer<BookmarkProvider>(
          builder: (_, bookmark, __) {
            final count = bookmark.bookmarkedProducts.length;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Bookmarks", style: TextStyle(fontWeight: FontWeight.bold)),
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmark, _) {
          List products = bookmark.bookmarkedProducts;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  Text("No bookmarked products found.", style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => bookmark.refreshBookmarks(),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

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
                    bookmark.toggleBookmark(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Removed from bookmarks"),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () => bookmark.toggleBookmark(product),
                        ),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: product,
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
                          // Product Image
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
                          // Product Info
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
                                    if (product.discountPercent != null)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '-${product.discountPercent!.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
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
                                    onPressed: () => bookmark.toggleBookmark(product),
                                    icon: Icon(
                                      bookmark.isBookmarked(product)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: bookmark.isBookmarked(product) ? Colors.blueAccent : null,
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
        },
      ),
    );
  }
}
