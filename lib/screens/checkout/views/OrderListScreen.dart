import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.blue;
      case 'shipped':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading orders: ${snapshot.error}'),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders found.', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final status = (order['status'] as String?)?.toLowerCase() ?? 'placed';
              final total = (order['total'] ?? 0).toDouble();
              final timestamp = order['timestamp'] as Timestamp?;
              final date = timestamp?.toDate();

              final formattedDate = date != null
                  ? DateFormat.yMMMd().format(date)
                  : 'Unknown date';

              final formattedTotal =
                  NumberFormat.currency(locale: 'en_US', symbol: '\$')
                      .format(total);

              final statusColor = _getStatusColor(status);

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                shadowColor: Colors.black26,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  title: Text(
                    'Order #$orderId',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Total: $formattedTotal',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Date: $formattedDate',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/order_tracking', // replace with your route name constant
                      arguments: {'orderId': orderId},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
