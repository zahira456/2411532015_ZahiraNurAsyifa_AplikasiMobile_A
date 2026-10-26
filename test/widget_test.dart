import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum5/models/transaction_model.dart';

void main() {
  test('formatRupiah menambahkan pemisah ribuan', () {
    expect(formatRupiah(5000000), 'Rp 5.000.000');
    expect(formatRupiah(0), 'Rp 0');
  });
}
