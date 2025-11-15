import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final DocumentReference orderRef;
  bool _isCancelling = false;

  final List<String> statuses = [
    'Placed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    orderRef = FirebaseFirestore.instance.collection('orders').doc(widget.orderId);
  }

  int getCurrentStep(String status) => statuses.indexOf(status).clamp(0, statuses.length - 1);

  bool canCancel(String status) => status == 'Placed' || status == 'Processing';

  bool canReorder(String status) => status == 'Delivered' || status == 'Cancelled';

  Future<void> _confirmCancelOrder(String currentStatus) async {
    if (!canCancel(currentStatus)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cannot be cancelled at this stage.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel and delete this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      final doc = await orderRef.get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order no longer exists.')),
        );
        setState(() => _isCancelling = false);
        return;
      }

      final orderData = doc.data() as Map<String, dynamic>;
      final currentStatus = orderData['status'] ?? 'Placed';

      if (canCancel(currentStatus)) {
        await orderRef.delete();
        if (!mounted) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Order cancelled successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _handleReorder(List<Map<String, dynamic>> items) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (var item in items) {
      cart.addItem(
        productId: item['id'],
        title: item['title'],
        imageUrl: item['imageUrl'],
        price: (item['price'] ?? 0).toDouble(),
        color: item['color'],
        size: item['size'],
        quantity: (item['quantity'] ?? 1),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🛒 Items added to cart for reorder.')),
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Pending';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  String formatEstimatedDelivery(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) return DateFormat.yMMMMd().format(timestamp.toDate());
    if (timestamp is DateTime) return DateFormat.yMMMMd().format(timestamp);
    if (timestamp is String) {
      try {
        final dt = DateTime.parse(timestamp);
        return DateFormat.yMMMMd().format(dt);
      } catch (_) {
        return 'N/A';
      }
    }
    return 'N/A';
  }

  Future<void> _refresh() async {
    // Just rebuild to refresh the stream subscription
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Order Tracking'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: orderRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final order = snapshot.data!.data()! as Map<String, dynamic>;
          final status = (order['status'] ?? 'Placed') as String;
          final currentStep = getCurrentStep(status);
          final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
          final address = Map<String, dynamic>.from(order['shippingAddress'] ?? {});
          final total = (order['total'] ?? 0).toDouble();
          final estimatedDelivery = formatEstimatedDelivery(order['estimatedDelivery']);
          final statusHistoryRaw = List<Map<String, dynamic>>.from(order['statusHistory'] ?? []);

          statusHistoryRaw.sort((a, b) {
            final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
            return aTime.compareTo(bTime);
          });

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderStatusStepper(currentStep: currentStep, statuses: statuses, estimatedDelivery: estimatedDelivery),
                  const SizedBox(height: 16),
                  InfoCard(title: 'Timeline', child: StatusTimeline(history: statusHistoryRaw, formatDate: formatDate)),
                  InfoCard(title: 'Items', child: OrderItemList(items: items)),
                  InfoCard(title: 'Shipping', child: ShippingAddress(address: address)),
                  InfoCard(title: 'Total', child: TotalAmount(total: total)),
                  if (_isCancelling) const Center(child: CircularProgressIndicator()),
                  if (!_isCancelling && canCancel(status))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel Order'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _confirmCancelOrder(status),
                      ),
                    ),
                  if (!_isCancelling && canReorder(status))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.replay),
                        label: const Text('Reorder Items'),
                        onPressed: () => _handleReorder(items),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderStatusStepper extends StatelessWidget {
  final int currentStep;
  final List<String> statuses;
  final String estimatedDelivery;

  const OrderStatusStepper({
    super.key,
    required this.currentStep,
    required this.statuses,
    required this.estimatedDelivery,
  });

  Color _getStepColor(int index, int currentStep) {
    if (index < currentStep) return Colors.green;
    if (index == currentStep) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStepIcon(int index, int currentStep) {
    if (index < currentStep) return Icons.check_circle;
    if (index == currentStep) return Icons.timelapse;
    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final color = _getStepColor(index, currentStep);
              final icon = _getStepIcon(index, currentStep);

              String subtitle;
              if (index < currentStep) {
                subtitle = '✔ Completed';
              } else if (index == currentStep) {
                subtitle = 'In Progress...';
              } else {
                subtitle = 'Pending';
              }

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                subtitle: Text(subtitle),
              );
            }).toList(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text('Estimated Delivery: $estimatedDelivery'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final String Function(Timestamp?) formatDate;

  const StatusTimeline({super.key, required this.history, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No timeline available.');
    }
    return Column(
      children: history.map((entry) {
        final status = entry['status'] ?? 'Unknown';
        final timestamp = entry['timestamp'] as Timestamp?;
        return ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(formatDate(timestamp)),
        );
      }).toList(),
    );
  }
}

class OrderItemList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrderItemList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('No items in this order.');
    }
    return Column(
      children: items.map((item) {
        return OrderItemTile(
          imageUrl: item['imageUrl'] ?? '',
          title: item['title'] ?? 'No title',
          quantity: item['quantity'] ?? 1,
          size: item['size'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
        );
      }).toList(),
    );
  }
}

class OrderItemTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int quantity;
  final String size;
  final double price;

  const OrderItemTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.quantity,
    required this.size,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      ),
      title: Text(title),
      subtitle: Text('Qty: $quantity | Size: $size'),
      trailing: Text('\$${price.toStringAsFixed(2)}'),
    );
  }
}

class ShippingAddress extends StatelessWidget {
  final Map<String, dynamic> address;

  const ShippingAddress({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    if (address.isEmpty) return const Text('No shipping address provided.');

    return Text(
      '${address['firstName'] ?? ''} ${address['lastName'] ?? ''},\n'
      '${address['street'] ?? ''}, ${address['city'] ?? ''},\n'
      '${address['state'] ?? ''}, ${address['country'] ?? ''}\nPhone: ${address['phone'] ?? ''}',
      style: const TextStyle(fontSize: 16),
    );
  }
}

class TotalAmount extends StatelessWidget {
  final double total;

  const TotalAmount({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Total: \$${total.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const InfoCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
