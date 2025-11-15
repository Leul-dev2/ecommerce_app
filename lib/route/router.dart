import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ecommerce/screens/checkout/views/order_tracking_screen.dart' as order_tracking_view;
import 'package:ecommerce/screens/checkout/views/OrderListScreen.dart' as order_list_view;
import 'package:ecommerce/screens/checkout/views/cart_screen.dart';
import 'package:ecommerce/screens/checkout/views/checkout_screen.dart';

import 'package:ecommerce/screens/address/views/addresses_screen.dart';
import 'package:ecommerce/screens/languge/select_languge.dart';
import 'package:ecommerce/screens/reviews/view/product_reviews_screen.dart';
import 'package:ecommerce/screens/search/views/search_screen.dart';
import 'package:ecommerce/entry_point.dart';
import 'screen_export.dart';
import 'package:ecommerce/services/faq_screen.dart';

import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/models/category_model.dart';

import 'package:ecommerce/screens/payment/PaymentScreen.dart';
import 'package:ecommerce/providers/splash_screen.dart';
import 'package:ecommerce/screens/get_help.dart/GetHelpScreen.dart';

import 'package:ecommerce/screens/home/views/components/BestSellersScreen.dart';
import 'package:ecommerce/screens/home/views/components/FlashSaleScreen.dart';
import 'package:ecommerce/screens/home/views/components/PopularProductsScreen.dart';

import 'package:ecommerce/screens/cloths%20and%20other/electronics_screen.dart';
import 'package:ecommerce/screens/product/views/product_returns_screen.dart';
import 'package:ecommerce/screens/profile/wishlist_screen.dart';
import 'package:ecommerce/screens/catagory/category_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Splash / Entry
    case '/':
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const EntryPoint());

    // Auth
    case logInScreenRoute:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case signUpScreenRoute:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case forgotPasswordScreenRoute:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

    // Product returns
    case productReturnsScreenRoute:
      return MaterialPageRoute(builder: (_) => const ProductReturnsScreen());
    case faqScreenRoute:
      return MaterialPageRoute(builder: (_) => const FaqScreen());
    // Product listings
    case flashSaleScreenRoute:
      return MaterialPageRoute(builder: (_) => const FlashSaleScreen());
    case popularProductsScreenRoute:
      return MaterialPageRoute(builder: (_) => const PopularProductsScreen());
    case bestSellersScreenRoute:
      return MaterialPageRoute(builder: (_) => const BestSellersScreen());

    // Electronics category
    case electronicsScreenRoute:
      return MaterialPageRoute(builder: (_) => const ElectronicsScreen());

    // Wishlist
    case WishlistScreenRoute:
      return MaterialPageRoute(builder: (_) => const WishlistScreen());

    // Dynamic category
    case categoryScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      final categoryName = args?['categoryName'] as String? ?? '';
      if (categoryName.isEmpty) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Category not specified')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => CategoryScreen(categoryName: categoryName),
      );

    // Discover — ✅ FIXED with both args
    case discoverScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      final allProducts = args?['allProducts'] as List<ProductModel>?;
      final allCategories = args?['allCategories'] as List<CategoryModel>?;

      if (allProducts == null || allCategories == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Missing products or categories!')),
          ),
        );
      }
      // Fixed: Use the class constructor with `const` and `()`
      return MaterialPageRoute(
        builder: (_) => DiscoverScreen(
          allProducts: allProducts,
          allCategories: allCategories,
        ),
      );
    // Cart & Checkout
    case cartScreenRoute:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case checkoutScreenRoute:
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());

    // Product details
    case productDetailsScreenRoute:
      final product = settings.arguments as ProductModel?;
      if (product == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Missing product!')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      );

    // Product reviews
    case productReviewsScreenRoute:
      final product = settings.arguments as ProductModel?;
      final user = FirebaseAuth.instance.currentUser;

      if (product == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Missing product for reviews!')),
          ),
        );
      }

      return MaterialPageRoute(
        builder: (_) => ProductReviewsScreen(
          productId: product.id,
          userId: user?.uid ?? '',
          userName: user?.displayName ?? 'Anonymous',
          userAvatar: user?.photoURL ?? '',
        ),
      );

    // Search
    case searchScreenRoute:
      return MaterialPageRoute(builder: (_) => const SearchScreen());

    // Payment
    case paymentScreenRoute:
      return MaterialPageRoute(builder: (_) => PaymentScreen(amountCents: 1));

    // Notifications
    case notificationsScreenRoute:
      return MaterialPageRoute(builder: (_) => const NotificationsScreen());

    // Help & Orders
    case getHelpScreenRoute:
      return MaterialPageRoute(builder: (_) => const GetHelpScreen());

    case orderListScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const order_list_view.OrderListScreen(),
      );

    case addressesScreenRoute:
      return MaterialPageRoute(builder: (_) => const AddressesScreen());

    // Order tracking
    case orderTrackingScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      final orderId = args?['orderId'] as String?;
      if (orderId == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Missing order ID!')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => order_tracking_view.OrderTrackingScreen(orderId: orderId),
      );

    // Profile
    case profileScreenRoute:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case userInfoScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserInfoScreen());
    case preferencesScreenRoute:
      return MaterialPageRoute(builder: (_) => const PreferencesScreen());

    // Wallet
    case walletScreenRoute:
      return MaterialPageRoute(builder: (_) => const WalletScreen());
    case emptyWalletScreenRoute:
      return MaterialPageRoute(builder: (_) => const EmptyWalletScreen());

    // Language
    case selectLanguageScreenRoute:
      return MaterialPageRoute(builder: (_) => const SelectLanguageScreen());

    // 404 fallback
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('404 - Route not found')),
        ),
      );
  }
}