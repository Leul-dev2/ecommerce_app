import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'stripe_service.dart';

class StripePaymentHandler {
  /// Save a card
  static Future<bool> handleSaveCardFlow({
    required BuildContext context,
    required String customerId,
    String? email,
    String? phone,
    String? name,
  }) async {
    try {
      final clientSecret = await StripeService.createSetupIntent(customerId);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your Shop',
          billingDetails: BillingDetails(email: email, phone: phone, name: name),
          allowsDelayedPaymentMethods: true,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (context.mounted) _showSnackbar(context, '✅ Card saved!');
      return true;

    } catch (e) {
      debugPrint('Save card error: $e');
      if (context.mounted) _showSnackbar(context, 'Error: $e');
      return false;
    }
  }

  /// Pay with a saved card
  static Future<bool> handlePaymentWithSavedCard({
    required BuildContext context,
    required String customerId,
    required String paymentMethodId,
    required int amountInCents,
    String currency = 'usd',
  }) async {
    try {
      final clientSecret = await StripeService.createPaymentIntent(
        customerId: customerId,
        paymentMethodId: paymentMethodId,
        amount: amountInCents,
        currency: currency,
      );

      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(paymentMethodId: paymentMethodId),
        ),
      );

      if (result.status == PaymentIntentsStatus.Succeeded) {
        if (context.mounted) _showSnackbar(context, '✅ Payment succeeded!');
        return true;
      } else {
        if (context.mounted) _showSnackbar(context, 'Payment failed or pending.');
        return false;
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (context.mounted) _showSnackbar(context, 'Error: $e');
      return false;
    }
  }

  /// Pay with a NEW card in real time
  static Future<bool> handlePaymentWithNewCard({
    required BuildContext context,
    required int amountInCents,
    String currency = 'usd',
  }) async {
    try {
      final clientSecret = await StripeService.createSimplePaymentIntent(
        amount: amountInCents,
        currency: currency,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your Shop',
          allowsDelayedPaymentMethods: false,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (context.mounted) _showSnackbar(context, '✅ Payment successful!');
      return true;

    } catch (e) {
      debugPrint('New card payment error: $e');
      if (context.mounted) _showSnackbar(context, 'Error: $e');
      return false;
    }
  }

  static void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
