import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _angka1Controller = TextEditingController();
  final TextEditingController _angka2Controller = TextEditingController();

  String hasil = 'Hasil: ';

  void tambah() {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    setState(() {
      hasil = 'Hasil: ${angka1 + angka2}';
    });
  }

  void kurang() {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    setState(() {
      hasil = 'Hasil: ${angka1 - angka2}';
    });
  }

  void kali() {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    setState(() {
      hasil = 'Hasil: ${angka1 * angka2}';
    });
  }

  void bagi() {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    setState(() {
      if (angka2 == 0) {
        hasil = 'Hasil: Tidak dapat dibagi dengan 0';
      } else {
        hasil = 'Hasil: ${angka1 / angka2}';
      }
    });
  }

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _angka1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Angka pertama',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _angka2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Angka kedua',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: tambah,
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: kurang,
                  child: const Text('-'),
                ),
                ElevatedButton(
                  onPressed: kali,
                  child: const Text('×'),
                ),
                ElevatedButton(
                  onPressed: bagi,
                  child: const Text('÷'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              hasil,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}