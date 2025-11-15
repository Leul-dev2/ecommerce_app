import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'components/wallet_balance_card.dart';
import 'components/wallet_history_card.dart';
import '../../../constants.dart';
import '../../../models/product_model.dart';
import 'empty_wallet_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view your wallet.")),
      );
    }

    final walletRef = FirebaseFirestore.instance.collection('wallet').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: walletRef.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const EmptyWalletScreen();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
            final rawHistory = data['history'];

            final transactions = rawHistory is List
                ? rawHistory
                    .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map))
                    .toList()
                : [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                    sliver: SliverToBoxAdapter(
                      child: WalletBalanceCard(
                        balance: balance,
                        onTabChargeBalance: () async {
                          await FirebaseFirestore.instance.runTransaction((transaction) async {
                            final freshSnap = await transaction.get(walletRef);
                            final freshBalance = (freshSnap['balance'] as num?)?.toDouble() ?? 0.0;
                            transaction.update(walletRef, {'balance': freshBalance + 50});
                          });
                        },
                      ),
                    ),
                  ),
                  if (transactions.isEmpty) ...[
                    const SliverToBoxAdapter(child: EmptyWalletScreen()),
                  ] else ...[
                    SliverPadding(
                      padding: const EdgeInsets.only(top: defaultPadding / 2),
                      sliver: SliverToBoxAdapter(
                        child: Text("Wallet history",
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = transactions[index];
                          final date = tx['date'];
                          final parsedDate = date is Timestamp
                              ? date.toDate()
                              : DateTime.tryParse(date.toString());
                          final formattedDate = parsedDate != null
                              ? DateFormat.yMMMd().format(parsedDate)
                              : 'Unknown Date';

                          return Padding(
                            padding: const EdgeInsets.only(top: defaultPadding),
                            child: WalletHistoryCard(
                              isReturn: tx['isReturn'] ?? false,
                              date: formattedDate,
                              amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
                              products: (tx['products'] as List<dynamic>? ?? [])
                                  .map<ProductModel>((item) {
                                return ProductModel.fromMap(Map<String, dynamic>.from(item));
                              }).toList(),
                            ),
                          );
                        },
                        childCount: transactions.length,
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
