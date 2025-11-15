import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'route/screen_export.dart';
import 'providers/notifications_provider.dart';
import 'models/product_model.dart';
import 'models/product_service.dart';
import 'models/category_model.dart';

import 'screens/profile/wishlist_screen.dart';

const defaultPadding = 16.0;
const defaultDuration = Duration(milliseconds: 300);
const primaryColor = Colors.blue;

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _currentIndex = 0;
  late Future<List<ProductModel>> _productsFuture;
  final List<CategoryModel> _categories = []; // This should be populated from a service

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().fetchProducts();
  }

  // Helper method for building SVG icons
  SvgPicture _buildSvgIcon(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // Improved helper for building bottom navigation bar items
  Widget _buildNavItem(int index, String label, String iconPath, {String? activeIconPath}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    final activeColor = primaryColor;
    final inactiveColor = theme.brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[400]!;

    final iconColor = isSelected ? activeColor : inactiveColor;
    final labelColor = isSelected ? activeColor : inactiveColor;
    final containerColor = isSelected ? activeColor.withOpacity(0.1) : Colors.transparent;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSvgIcon(
              isSelected && activeIconPath != null ? activeIconPath : iconPath,
              iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: labelColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New, more "AliExpress-like" search bar widget
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Expanded( // Use Expanded to ensure it fills the available space
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, searchScreenRoute);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isLight ? Colors.grey[200] : Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "What are you looking for?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New location button for a more "AliExpress" feel
  Widget _buildLocationButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // You can add logic here to open a location selection screen
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 4),
          Text(
            "Ship to",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: _buildLocationButton(context),
        actions: [
          _buildSearchBar(context),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: defaultPadding),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, notificationsScreenRoute),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset("assets/icons/Notification.svg", colorFilter: ColorFilter.mode(theme.textTheme.bodyLarge!.color!, BlendMode.srcIn)),
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Consumer<NotificationsProvider>(
                      builder: (_, provider, __) {
                        final count = provider.unreadCount;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            final pages = [
              const HomeScreen(),
              DiscoverScreen(allProducts: products, allCategories: _categories),
              const WishlistScreen(),
              const CartScreen(),
              const ProfileScreen(),
            ];

            return PageTransitionSwitcher(
              duration: defaultDuration,
              transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              ),
              child: pages[_currentIndex],
            );
          } else {
            return const Center(child: Text('No products found.'));
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2, bottom: defaultPadding / 2),
        color: isLight ? Colors.white : const Color(0xFF101015),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, "Shop", "assets/icons/Shop.svg"),
            _buildNavItem(1, "Discover", "assets/icons/Category.svg"),
            _buildNavItem(2, "Wishlist", "assets/icons/Bookmark.svg"),
            _buildNavItem(3, "Cart", "assets/icons/Bag.svg"),
            _buildNavItem(4, "Profile", "assets/icons/Profile.svg"),
          ],
        ),
      ),
    );
  }
}