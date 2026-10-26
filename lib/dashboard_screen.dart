import 'package:flutter/material.dart';

import 'add_transaction_screen.dart';
import 'database/database_helper.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _balance = 0;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final balance = await DatabaseHelper.instance
          .getBalanceByUserId(widget.user.id);
      final transactions = await DatabaseHelper.instance
          .getTransactionsByUserId(widget.user.id, limit: 3);
      if (!mounted) return;
      setState(() {
        _balance = balance;
        _recentTransactions = transactions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Dashboard gagal dimuat.')),
      );
    }
  }

  Future<void> _openAddTransaction() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(userId: widget.user.id),
      ),
    );
    await _loadData();
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${widget.user.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTransactionList(),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo Utama',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                IconButton(
                  tooltip: _isBalanceVisible
                      ? 'Sembunyikan saldo'
                      : 'Tampilkan saldo',
                  onPressed: () => setState(
                    () => _isBalanceVisible = !_isBalanceVisible,
                  ),
                  icon: Icon(
                    _isBalanceVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isLoading
                  ? 'Memuat saldo...'
                  : _isBalanceVisible
                      ? formatRupiah(_balance)
                      : 'Rp ********',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_recentTransactions.isEmpty) {
      return const Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.receipt_long, color: Colors.white),
          ),
          title: Text('Belum ada transaksi'),
          subtitle: Text('Tekan tombol + untuk mencatat transaksi.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          for (int i = 0; i < _recentTransactions.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _buildTransactionTile(_recentTransactions[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    final color = transaction.isIncome ? Colors.green : Colors.orange;
    final icon = transaction.isIncome
        ? Icons.attach_money
        : _iconForCategory(transaction.category);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(transaction.title),
      subtitle: Text(transaction.dateLabel),
      trailing: Text(
        transaction.signedAmount,
        style: TextStyle(
          color: transaction.isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => _openDetail(transaction),
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

  void _openDetail(TransactionModel transaction) {
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
  }
}
