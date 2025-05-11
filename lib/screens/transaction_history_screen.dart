import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we have dummy transactions
    List<String> transactions = [
      '0.01 BTC to Charity A',
      '0.02 ETH to Charity B',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(transactions[index]),
          );
        },
      ),
    );
  }
}
