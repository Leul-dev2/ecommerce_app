import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/cart_provider.dart';
import '../../../route/route_constants.dart';

// Currency formatter
final currencyFormatter =NumberFormat.simpleCurrency(locale: 'en_US', name: 'USD');
// Hex color helper with short hex support
Color colorFromHex(String hexColor) {
  try {
    var cleanedHex = hexColor.replaceAll('#', '');
    if (cleanedHex.length == 3) {
      cleanedHex = cleanedHex.split('').map((c) => '$c$c').join();
    }
    return Color(int.parse(cleanedHex.length == 6 ? 'FF$cleanedHex' : cleanedHex, radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (items.isEmpty)
            IconButton(
              icon: const Icon(Icons.storefront_outlined),
              tooltip: 'Shop Now',
              onPressed: () => Navigator.pushNamed(context, '/'),
            ),
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) => CartItemTile(
                      keyId: items[i].key,
                      cartItem: items[i].value,
                    ),
                  ),
                ),
                const _CouponSection(),
                _CartSummarySection(totalAmount: cart.totalAmount),
              ],
            ),
    );
  }
}

class _CouponSection extends StatefulWidget {
  // ignore: unused_element_parameter
  const _CouponSection({super.key});

  @override
  State<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<_CouponSection> {
  final _controller = TextEditingController();
  bool _applying = false;

  void _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() => _applying = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _applying = false);

    final valid = code == 'SAVE10';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valid ? 'Promo code applied! ✅' : 'Invalid promo code ❌'),
        backgroundColor: valid ? Colors.green : Colors.red,
      ),
    );
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 48,
            child: ElevatedButton(
              onPressed: _applying ? null : _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: _applying
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummarySection extends StatelessWidget {
  final double totalAmount;

  const _CartSummarySection({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Subtotal',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Text(
                  currencyFormatter.format(totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Free delivery · Est. 3-7 days',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: totalAmount > 0
                    ? () {
                        Navigator.pushNamed(context, checkoutScreenRoute);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 100, color: theme.disabledColor),
            const SizedBox(height: 20),
            Text(
              'Oops! Your cart is empty.',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse products and add them to your cart.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, homeScreenRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final String keyId;
  final CartItem cartItem;

  const CartItemTile({super.key, required this.keyId, required this.cartItem});

  Future<bool?> _showRemoveConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: cartItem.imageUrl.startsWith('http')
                    ? NetworkImage(cartItem.imageUrl)
                    : AssetImage('assets/images/placeholder.jpg') as ImageProvider,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorFromHex(cartItem.color),
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Size: ${cartItem.size}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${currencyFormatter.format(cartItem.price)} each',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantitySelector(
                        quantity: cartItem.quantity,
                        onIncrement: () => cart.updateQuantity(keyId, cartItem.quantity + 1),
                        onDecrement: cartItem.quantity > 1
                            ? () => cart.updateQuantity(keyId, cartItem.quantity - 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        color: Colors.red,
                        tooltip: 'Remove item',
                        onPressed: () async {
                          final confirmed = await _showRemoveConfirmation(context);
                          if (confirmed == true) {
                            cart.removeItem(keyId);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrement,
            splashRadius: 18,
            tooltip: 'Decrease quantity',
            color: onDecrement == null ? Colors.grey : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(quantity.toString(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            splashRadius: 18,
            tooltip: 'Increase quantity',
          ),
        ],
      ),
    );
  }
}