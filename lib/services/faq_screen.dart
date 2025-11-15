import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _faqData = [
    {
      "category": "Orders",
      "icon": Icons.local_shipping,
      "faqs": [
        {
          "q": "How can I track my order?",
          "a": "Go to 'Orders' in your profile and click 'Track Order'.",
          "votesUp": 10,
          "votesDown": 2,
        },
        {
          "q": "Can I cancel my order?",
          "a": "Yes, orders can be canceled before shipping.",
          "votesUp": 8,
          "votesDown": 1,
        },
      ],
    },
    {
      "category": "Payments",
      "icon": Icons.account_balance_wallet,
      "faqs": [
        {
          "q": "What payment methods do you accept?",
          "a": "Credit/debit cards, PayPal, Mobile Money.",
          "votesUp": 15,
          "votesDown": 0,
        },
      ],
    },
    {
      "category": "Shipping",
      "icon": Icons.flight_takeoff,
      "faqs": [
        {
          "q": "Do you ship internationally?",
          "a": "Currently, we only ship within the country.",
          "votesUp": 5,
          "votesDown": 0,
        },
      ],
    },
  ];

  late TabController _tabController;
  String _searchText = "";
  int _expandedIndex = -1; // Only one tile open at a time

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _faqData.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ Pro"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.redAccent,
          unselectedLabelColor: theme.textTheme.bodyLarge?.color,
          indicatorColor: Colors.redAccent,
          tabs: _faqData.map((e) {
            return Tab(
              text: e["category"],
              icon: Icon(e["icon"], size: 18),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchText = value),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _faqData.map((category) {
                final faqs = category["faqs"] as List;
                final filteredFaqs = faqs.where((faq) {
                  final q = faq["q"].toString().toLowerCase();
                  final a = faq["a"].toString().toLowerCase();
                  return q.contains(_searchText.toLowerCase()) || a.contains(_searchText.toLowerCase());
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, index) {
                    final item = filteredFaqs[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        key: Key("${category['category']}_$index"),
                        initiallyExpanded: _expandedIndex == index,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _expandedIndex = expanded ? index : -1;
                          });
                        },
                        title: Text(
                          item["q"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: RotationTransition(
                          turns: AlwaysStoppedAnimation(
                              _expandedIndex == index ? 0.5 : 0.0),
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item["a"]),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() => item["votesUp"]++);
                                      },
                                      icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                                    ),
                                    Text("${item["votesUp"]}"),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => item["votesDown"]++);
                                      },
                                      icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                                    ),
                                    Text("${item["votesDown"]}"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
