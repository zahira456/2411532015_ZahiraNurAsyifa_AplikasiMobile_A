import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database/database_helper.dart';
import 'models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;
  final String initialType;

  const AddTransactionScreen({
    super.key,
    required this.userId,
    this.initialType = 'expense',
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Makanan';
  DateTime? _selectedDate;
  bool _isSaving = false;

  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType == 'income' ? 'income' : 'expense';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      _dateController.text = formatTanggal(_selectedDate!);
    });
  }


Future<void> _saveTransaction() async {
  if (!_formKey.currentState!.validate()) return;
  if (_selectedDate == null) return;

  setState(() => _isSaving = true);

  try {
    final amount = int.parse(_amountController.text.trim());

    // Cek saldo sebelum menyimpan pengeluaran.
    if (_selectedType == 'expense') {
      final currentBalance = await DatabaseHelper.instance
          .getBalanceByUserId(widget.userId);

      if (!mounted) return;

      if (amount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo tidak mencukupi untuk pengeluaran ini.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final transaction = TransactionModel(
      userId: widget.userId,
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate!,
    );

    await DatabaseHelper.instance.insertTransaction(transaction);

    if (!mounted) return;
    Navigator.pop(context, true);
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi gagal disimpan: $error')),
    );
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final amount = int.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Nominal harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Transaksi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Pemasukan'),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Pengeluaran'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _chooseDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Transaksi',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Tanggal wajib diisi'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSaving ? null : _saveTransaction,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
