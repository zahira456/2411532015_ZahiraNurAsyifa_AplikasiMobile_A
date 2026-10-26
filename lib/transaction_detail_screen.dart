import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String title;
  final String amount;
  final String category;
  final String date;
  final String type;

  const TransactionDetailScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.type = 'expense',
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: isIncome ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const Divider(height: 40, thickness: 2),
            _buildDetailRow('Jenis Transaksi', isIncome ? 'Pemasukan' : 'Pengeluaran'),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', category),
            const SizedBox(height: 16),
            _buildDetailRow('Tanggal', date),
            const SizedBox(height: 16),
            _buildDetailRow('Status', 'Berhasil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
