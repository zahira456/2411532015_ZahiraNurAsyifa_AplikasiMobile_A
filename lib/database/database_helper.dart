import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = join(databaseDirectory, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL CHECK (amount > 0),
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            category TEXT NOT NULL,
            transaction_date TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_user_date '
          'ON transactions (user_id, transaction_date DESC)',
        );
      },
    );
  }

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('Email sudah terdaftar. Gunakan email lain.');
    }

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final passwordHash = await _hashPassword(password, salt);

    final id = await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': base64Encode(passwordHash),
      'password_salt': base64Encode(salt),
      'created_at': DateTime.now().toIso8601String(),
    });

    return UserModel(id: id, name: name.trim(), email: normalizedEmail);
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final salt = base64Decode(row['password_salt'] as String);
    final enteredHash = base64Encode(await _hashPassword(password, salt));
    if (enteredHash != row['password_hash']) return null;

    return UserModel(
      id: (row['id'] as num).toInt(),
      name: row['name'] as String,
      email: row['email'] as String,
    );
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(Map<String, Object?>.from(rows.first));
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactionsByUserId(
    int userId, {
    int? limit,
  }) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC, id DESC',
      limit: limit,
    );
    return rows
        .map((row) => TransactionModel.fromMap(Map<String, Object?>.from(row)))
        .toList();
  }

  Future<int> getBalanceByUserId(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0
      ) AS balance
      FROM transactions
      WHERE user_id = ?
      ''',
      [userId],
    );
    return (result.first['balance'] as num?)?.toInt() ?? 0;
  }

  Future<List<int>> _hashPassword(String password, List<int> salt) async {
    // PBKDF2 dengan salt acak; kata sandi tidak disimpan dalam teks biasa.
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 60000,
      bits: 256,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }
}
