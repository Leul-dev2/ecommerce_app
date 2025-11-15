import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double shippingFee = 5.99;

  String? selectedPaymentMethod;
  String? mobilePhoneNumber;

  final List<String> paymentMethods = [
    'Cash on Delivery',
    'Wallet',
    'Credit/Debit Card',
    'Mobile Banking',
  ];

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.entries.toList();
    final user = FirebaseAuth.instance.currentUser;
    final addressRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('addresses');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.redAccent,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getDefaultAddress(addressRef),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final defaultAddress = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShippingAddressSection(defaultAddress),
                const SizedBox(height: 16),
                const Divider(),

                _buildOrderItemsSection(cartItems),
                const SizedBox(height: 16),
                const Divider(),

                _buildPaymentMethodSection(),
                const SizedBox(height: 16),
                const Divider(),

                _buildOrderSummarySection(cart),
                const SizedBox(height: 24),

                _buildPlaceOrderButton(cart, defaultAddress, user),
              ],
            ),
          );
        },
      ),
    );
  }

  /// -------------------------------
  /// Build UI sections
  /// -------------------------------

  Widget _buildShippingAddressSection(Map<String, dynamic>? defaultAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Address',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (defaultAddress != null)
          _AddressCard(
            data: defaultAddress,
            onChanged: () => setState(() {}),
          )
        else
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/addresses')
                .then((_) => setState(() {})),
            icon: const Icon(Icons.add_location_alt),
            label: const Text("Add Shipping Address"),
          ),
      ],
    );
  }

  Widget _buildOrderItemsSection(List<MapEntry<String, dynamic>> cartItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...cartItems.map((entry) {
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              title: Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Qty: ${item.quantity} | Size: ${item.size}'),
              trailing: Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedPaymentMethod,
          decoration: const InputDecoration(
            labelText: 'Select Payment Method',
            border: OutlineInputBorder(),
          ),
          items: paymentMethods.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          onChanged: (value) => setState(() => selectedPaymentMethod = value),
        ),
        if (selectedPaymentMethod == 'Mobile Banking')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Phone Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => mobilePhoneNumber = val,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderSummarySection(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _PriceRow(label: 'Subtotal', value: cart.totalAmount),
        const SizedBox(height: 4),
        _PriceRow(label: 'Shipping Fee', value: shippingFee),
        const Divider(),
        _PriceRow(
          label: 'Total',
          value: cart.totalAmount + shippingFee,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(
      CartProvider cart, Map<String, dynamic>? defaultAddress, User user) {
    final cartItems = cart.items.entries.toList();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.lock),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.redAccent,
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: _isProcessing ||
                cartItems.isEmpty ||
                cart.totalAmount <= 0 ||
                defaultAddress == null
            ? null
            : () => _confirmAndCheckout(cart, defaultAddress, user),
        label: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Place Order'),
      ),
    );
  }

  /// -------------------------------
  /// Logic
  /// -------------------------------

  Future<Map<String, dynamic>?> getDefaultAddress(
      CollectionReference ref) async {
    try {
      final snapshot =
          await ref.where('isDefault', isEqualTo: true).limit(1).get();
      return snapshot.docs.isNotEmpty
          ? snapshot.docs.first.data() as Map<String, dynamic>
          : null;
    } catch (e) {
      debugPrint('Error fetching default address: $e');
      return null;
    }
  }

  Future<void> _confirmAndCheckout(
      CartProvider cart, Map<String, dynamic> address, User user) async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method.")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _handleCheckout(cart, address, user);
    }
  }

  Future<void> _handleCheckout(
      CartProvider cart, Map<String, dynamic> address, User user) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      // Get customer email from Firebase user
      final customerEmail = user.email ?? 'no-email@example.com';

      // Validate Mobile Banking number
      if (selectedPaymentMethod == 'Mobile Banking' &&
          (mobilePhoneNumber == null || mobilePhoneNumber!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter mobile number.")),
        );
        setState(() => _isProcessing = false);
        return;
      }

      // Stripe payment
      if (selectedPaymentMethod == 'Credit/Debit Card') {
        final success = await paymentProvider.payWithStripe(
          context: context,
          amountCents: ((cart.totalAmount + shippingFee) * 100).toInt(),
          currency: 'usd',
          customerEmail: customerEmail,
        );
        if (!success) throw Exception('Stripe payment failed.');
      }

      // Wallet payment
      if (selectedPaymentMethod == 'Wallet') {
        final success = await paymentProvider.payWithWallet(
          context: context,
          amountCents: ((cart.totalAmount + shippingFee) * 100).toInt(),
        );
        if (!success) throw Exception('Wallet payment failed.');
      }

      // Chapa (Mobile Banking) payment
   // Chapa (Mobile Banking) payment
if (selectedPaymentMethod == 'Mobile Banking') {
  final int totalAmountInCents = ((cart.totalAmount + shippingFee) * 100).toInt();

  final success = await paymentProvider.payWithChapa(
    context: context,
    amountCents: totalAmountInCents,
    phoneNumber: mobilePhoneNumber!,
    email: user.email ?? '',
  );
  if (!success) throw Exception('Chapa payment failed.');
}



      await _placeOrder(cart, address, user.uid, selectedPaymentMethod!);
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _placeOrder(
    CartProvider cart,
    Map<String, dynamic> address,
    String userId,
    String paymentMethod,
  ) async {
    final docRef = FirebaseFirestore.instance.collection('orders').doc();

    final orderData = {
      'id': docRef.id,
      'userId': userId,
      'shippingAddress': address,
      'items': cart.items.entries.map((e) {
        final item = e.value;
        return {
          'title': item.title,
          'price': item.price,
          'quantity': item.quantity,
          'size': item.size,
          'color': item.color,
          'imageUrl': item.imageUrl,
        };
      }).toList(),
      'subtotal': cart.totalAmount,
      'shippingFee': shippingFee,
      'total': cart.totalAmount + shippingFee,
      'paymentMethod': paymentMethod,
      'status': 'Placed',
      'timestamp': FieldValue.serverTimestamp(),
      'estimatedDelivery':
          DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    };

    await docRef.set(orderData);
    cart.clear();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      '/order_tracking',
      arguments: {'orderId': docRef.id},
    );
  }
}

/// -------------------------------------
/// Helpers
/// -------------------------------------

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  const _AddressCard({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.location_pin, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${data['firstName']} ${data['lastName']}\n${data['street']}, ${data['city']}, ${data['state']}\n${data['phone']}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/addresses').then((_) => onChanged()),
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
