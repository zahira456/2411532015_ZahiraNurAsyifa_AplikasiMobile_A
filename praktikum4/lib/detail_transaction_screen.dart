import 'package:flutter/material.dart';

class DetailTransactionScreen extends StatelessWidget{
  final String title;
  final String amount;

  const DetailTransactionScreen({
    super.key, required this.title, required this.amount
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: Center(child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          Text(amount, style: TextStyle(fontSize: 20)),
        ],
      ),
      ),
    );
  }

}