class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final int amount;
  // Nilai type hanya 'income' atau 'expense'.
  final String type;
  final String category;
  final DateTime date;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == 'income';

  String get signedAmount => '${isIncome ? '+' : '-'}${formatRupiah(amount)}';

  String get dateLabel => formatTanggal(date);

  Map<String, Object?> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'transaction_date':
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: (map['id'] as num).toInt(),
      userId: (map['user_id'] as num).toInt(),
      title: map['title'] as String,
      amount: (map['amount'] as num).toInt(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['transaction_date'] as String),
    );
  }
}

String formatRupiah(int amount) {
  final value = amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp $value';
}

String formatTanggal(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
