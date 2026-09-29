import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
 const AddTransactionScreen({super.key});

 @override

 State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // controller untuk input field
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  //state untuk dropdown
  String? _selectedCategory = 'Makanan';
  final List<String> _categories = ['Makanan', 'Transportasi', 'Hiburan', 'Lainnya'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Transaksi Baru'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // input 1: Judul Transaksi
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Judul transaksi tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // input 2: Jumlah Transaksi
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nomninal(Rp)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
               
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nominal wajib diisi";
                  }
                  if (int.tryParse(value) == null) {
                    return "Harus berupa angka bulat yang valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // input 3: Kategori Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String?newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // input 4: tanggal transaksi
              TextFormField(
                controller: _dateController,

                decoration: const InputDecoration(
                  labelText: "Tanggal Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tanggal transaksi tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              //tombol simpan transaksi
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //jika lolos valisdasi, tampilkan pop-up snackbar sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tersimpan: ${_titleController.text} (Rp ${_amountController.text})',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                    );
                  }
                },
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}