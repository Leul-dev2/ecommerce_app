import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/payment_method_model.dart';

class StripeService {
  static const String _baseUrl = 'https://backend-ecomm-jol4.onrender.com/api/payment';
  static const Duration _timeout = Duration(seconds: 10);

  static Future<Map<String, dynamic>> _postJson(String url, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('❌ Request failed (${response.statusCode}): ${response.body}');
    }
  }

  static Future<String> createCustomer(String email, String userId) async {
    final json = await _postJson('$_baseUrl/create-customer', {
      'email': email,
      'userId': userId,
    });
    return json['customerId'] as String;
  }

  static Future<String> createSetupIntent(String customerId) async {
    final json = await _postJson('$_baseUrl/create-setup-intent', {
      'customerId': customerId,
    });
    return json['clientSecret'] as String;
  }

  static Future<String> createPaymentIntent({
    required String customerId,
    required String paymentMethodId,
    required int amount,
    String currency = 'usd',
  }) async {
    final json = await _postJson('$_baseUrl/create-payment-intent', {
      'customerId': customerId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
    });
    return json['clientSecret'] as String;
  }

  static Future<String> createSimplePaymentIntent({
    required int amount,
    String currency = 'usd',
  }) async {
    final json = await _postJson('$_baseUrl/create-payment-intent', {
      'amount': amount,
      'currency': currency,
    });
    return json['clientSecret'] as String;
  }

  static Future<List<PaymentMethodModel>> listPaymentMethods(String customerId) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/list-payment-methods?customerId=$customerId'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PaymentMethodModel.fromJson(e)).toList();
    } else {
      throw Exception('❌ Failed to list payment methods: ${response.statusCode} ${response.body}');
    }
  }
}
