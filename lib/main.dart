import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'services/push_service.dart';

// Providers
import 'providers/bookmark_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/login_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/notifications_provider.dart';

// Models
import 'models/payment_method_model.dart';

// Routing + Theme
import 'route/router.dart';
import 'route/route_constants.dart';
import 'theme/app_theme.dart';

// Localization

// Hive box names
const String wishlistBoxName = 'wishlist';
const String paymentMethodsBoxName = 'payment_methods';

// Global navigator key for FCM navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background handler (required for Android)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PaymentMethodModelAdapter());
  await Hive.openBox(wishlistBoxName);
  await Hive.openBox(paymentMethodsBoxName);
  await Hive.openBox('notifications_cache');
  await Hive.openBox<PaymentMethodModel>('cardsBox');

  // Setup Stripe
  Stripe.publishableKey =
      'pk_test_51RhzlhQtBgkl1YqBg8X9XXy9JFC8W4YSGZcOKJoM2Du1TGWPwP03Nvj8BbrTiJmMRAU1YTTH5JW6hoWWSzUKEn9T00jlXiL82l';
  await Stripe.instance.applySettings();

  // Notifications provider
  final notifProvider = NotificationsProvider();
  notifProvider.loadFromCache();

  // Initialize PushService AFTER providers exist
  Future<void> initPushService(NotificationsProvider notifProvider) async {
    await PushService.init(notifProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      notifProvider.listenToNotifications(user.uid);
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    initPushService(notifProvider);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(
            create: (_) => LoginProvider()..loadRememberedPrefs()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: notifProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _setupMessaging();
  }

  Future<void> _setupMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Ask permission (iOS)
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Token for backend
    final token = await messaging.getToken();
    debugPrint('Firebase Messaging Token: $token');

    // Refresh token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('Refreshed Firebase Token: $newToken');
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.messageId}');
      if (message.notification != null && mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(
              content: Text(message.notification!.title ?? 'Notification')),
        );
      }
    });

    // Notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened: ${message.messageId}');
      if (message.data['orderId'] != null) {
        navigatorKey.currentState?.pushNamed(
          '/order_tracking',
          arguments: {'orderId': message.data['orderId']},
        );
      } else {
        navigatorKey.currentState?.pushNamed('/notifications');
      }
    });

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Shop Template',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: themeProvider.themeMode,
      locale: langProvider.selectedLanguage != null
          ? Locale(langProvider.selectedLanguage!.code)
          : const Locale('en'),
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
      initialRoute: splashScreenRoute,
      onGenerateRoute: generateRoute,
    );
  }
}
