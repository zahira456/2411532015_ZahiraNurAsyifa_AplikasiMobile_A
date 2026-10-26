import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  final UserModel user;

  const HistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: DatabaseHelper.instance.getTransactionsByUserId(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Riwayat transaksi gagal dimuat.'));
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat transaksi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Transaksi yang kamu simpan akan muncul di sini.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.isIncome;
              final icon = isIncome
                  ? Icons.attach_money
                  : _iconForCategory(transaction.category);
              final color = isIncome ? Colors.green : Colors.orange;

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text('${transaction.category} • ${transaction.dateLabel}'),
                  trailing: Text(
                    transaction.signedAmount,
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(
                          title: transaction.title,
                          amount: transaction.signedAmount,
                          category: transaction.category,
                          date: transaction.dateLabel,
                          type: transaction.type,
                        ),
                      ),
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

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.fastfood;
      case 'Transportasi':
        return Icons.directions_bus;
      case 'Hiburan':
        return Icons.movie;
      default:
        return Icons.receipt_long;
    }
  }
}
