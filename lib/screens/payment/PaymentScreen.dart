import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/payment_provider.dart';

class PaymentScreen extends StatefulWidget {
  final int amountCents;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.amountCents,
    this.currency = 'usd',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();

  String? selectedPaymentMethod;

  final List<String> paymentMethods = [
    'Stripe (Card)',
    'Wallet',
    'Mobile Banking (Chapa)',
  ];

  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 1,
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay: \$${(widget.amountCents / 100).toStringAsFixed(2)} ${widget.currency.toUpperCase()}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Payment Method',
                border: OutlineInputBorder(),
              ),
              value: selectedPaymentMethod,
              items: paymentMethods
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (val) => setState(() => selectedPaymentMethod = val),
            ),

            if (selectedPaymentMethod == 'Mobile Banking (Chapa)')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                label: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: _isProcessing || selectedPaymentMethod == null
                    ? null
                    : () => _handlePayment(paymentProvider, user),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(PaymentProvider provider, User? user) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      bool success = false;

      if (selectedPaymentMethod == 'Stripe (Card)') {
        success = await provider.payWithStripe(
          context: context,
          amountCents: widget.amountCents,
          currency: widget.currency,
          customerEmail: user.email ?? 'no-email@example.com',
        );
      } else if (selectedPaymentMethod == 'Wallet') {
        success = await provider.payWithWallet(
          context: context,
          amountCents: widget.amountCents,
        );
      } else if (selectedPaymentMethod == 'Mobile Banking (Chapa)') {
        if (_phoneController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter phone number')),
          );
          setState(() => _isProcessing = false);
          return;
        }

        success = await provider.payWithChapa(
          context: context,
          amountCents: widget.amountCents,
          phoneNumber: _phoneController.text.trim(),
          email: user.email ?? '',
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Payment successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Payment failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
