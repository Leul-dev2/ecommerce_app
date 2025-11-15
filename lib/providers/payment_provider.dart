import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PaymentProvider with ChangeNotifier {
  /// ✅ Stripe payment (real production flow)
  Future<bool> payWithStripe({
    required BuildContext context,
    required int amountCents,
    required String currency,
    required String customerEmail,
  }) async {
    try {
      // 1️⃣ Call your Node/Firebase backend to create PaymentIntent
      final response = await http.post(
        Uri.parse('https://backend-ecomm-jol4.onrender.com/api/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountCents,
          'currency': currency,
          'customerEmail': customerEmail,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('PaymentIntent failed: ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // 2️⃣ Init PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'My Shop',
        
        ),
      );

      // 3️⃣ Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Payment successful!')),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Stripe error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stripe error: $e')),
        );
      }
      return false;
    }
  }

  /// ✅ Wallet payment (mock)
  Future<bool> payWithWallet({
    required BuildContext context,
    required int amountCents,
  }) async {
    debugPrint('Simulating wallet charge of $amountCents cents...');
    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Wallet payment successful!')),
      );
    }
    return true;
  }

  /// ✅ Chapa payment (mock)
Future<bool> payWithChapa({
  required BuildContext context,
  required int amountCents,
  required String phoneNumber,
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse('https://backend-ecomm-jol4.onrender.com/api/chapa/create-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amountCents / 100).toString(), // ETB is usually decimal
        'currency': 'ETB',
        'email': email,
        'phone': phoneNumber,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('Chapa failed: ${response.body}');
      return false;
    }

    final data = jsonDecode(response.body);
    final checkoutUrl = data['checkoutUrl'];

    if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
      await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      return true;
    } else {
      throw Exception('Could not launch Chapa checkout');
    }
  } catch (e) {
    debugPrint('Chapa error: $e');
    return false;
  }
}
}