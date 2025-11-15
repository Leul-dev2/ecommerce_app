import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Order categories with distinct colors
  final List<Map<String, dynamic>> orderCategories = [
    {
      'title': 'Awaiting Payment',
      'icon': LucideIcons.wallet,
      'count': 0,
      'color': Colors.amber,
    },
    {
      'title': 'Processing',
      'icon': LucideIcons.packageOpen,
      'count': 1,
      'color': Colors.blue,
    },
    {
      'title': 'Delivered',
      'icon': LucideIcons.truck,
      'count': 5,
      'color': Colors.green,
    },
    {
      'title': 'Returned',
      'icon': LucideIcons.undo2,
      'count': 3,
      'color': Colors.orange,
    },
    {
      'title': 'Canceled',
      'icon': LucideIcons.xCircle,
      'count': 2,
      'color': Colors.redAccent,
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter order categories by search query (case-insensitive)
    final filteredCategories = orderCategories.where((item) {
      final title = item['title'].toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            const Text(
              'Orders history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Show a message if no orders match the search
            if (filteredCategories.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filteredCategories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredCategories[index];
                    return ListTile(
                      leading: Tooltip(
                        message: item['title'],
                        child: Icon(
                          item['icon'],
                          size: 28,
                          color: item['color'],
                        ),
                      ),
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Show count badge if count > 0 or always show for "Awaiting Payment"
                          if ((item['count'] != null && item['count'] > 0) ||
                              item['title'] == 'Awaiting Payment')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${item['count']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          const SizedBox(width: 10),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tapped on ${item['title']}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Search bar widget with onChanged updating the search query
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Find an order...',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.tune, color: Colors.grey),
        ],
      ),
    );
  }
}
