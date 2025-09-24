import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'expenses.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // 🔹 Tabel kategori
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          type TEXT,
          icon TEXT
        )
      ''');

      // 🔹 Tabel transaksi (relasi categoryId → categories.id)
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          amount INTEGER,
          date TEXT,
          type TEXT,
          categoryId INTEGER,
          FOREIGN KEY (categoryId) REFERENCES categories(id)
        )
      ''');

      // 🔹 Seed data kategori default
      final defaultCategories = [
        {"name": "Makan", "type": "expense", "icon": "assets/makanan.png"},
        {"name": "Internet", "type": "expense", "icon": "assets/Internet.png"},
        {"name": "Edukasi", "type": "expense", "icon": "assets/edukasi.png"},
        {"name": "Hadiah", "type": "expense", "icon": "assets/hadiah.png"},
        {
          "name": "Transport",
          "type": "expense",
          "icon": "assets/transport.png",
        },
        {"name": "Belanja", "type": "expense", "icon": "assets/Belanja.png"},
        {
          "name": "Alat Rumah",
          "type": "expense",
          "icon": "assets/alat_rumah.png",
        },
        {"name": "Olahraga", "type": "expense", "icon": "assets/olahraga.png"},
        {"name": "Hiburan", "type": "expense", "icon": "assets/hiburan.png"},
        {"name": "Gaji", "type": "income", "icon": "assets/gaji.png"},
      ];

      for (var cat in defaultCategories) {
        await db.insert("categories", cat);
      }
    },
  );
}

/// 🔹 Ambil semua kategori
Future<List<Map<String, dynamic>>> getCategories() async {
  final db = await initDB();
  return await db.query("categories", orderBy: "name ASC");
}

/// 🔹 Tambah transaksi
Future<int> addTransaction(Map<String, dynamic> txn) async {
  final db = await initDB();
  return await db.insert("transactions", txn);
}

/// 🔹 Ambil semua transaksi
Future<List<Map<String, dynamic>>> getTransactions() async {
  final db = await initDB();
  return await db.query("transactions", orderBy: "date DESC");
}

/// 🔹 Ambil transaksi + kategori (JOIN)
Future<List<Map<String, dynamic>>> getTransactionsWithCategory() async {
  final db = await initDB();
  return await db.rawQuery('''
    SELECT t.id, t.title, t.amount, t.date, t.type,
           c.name as categoryName, c.icon as categoryIcon
    FROM transactions t
    LEFT JOIN categories c ON t.categoryId = c.id
    ORDER BY t.date DESC
  ''');
}

/// 🔹 Ambil total pemasukan bulan ini
Future<double> getMonthlyIncome() async {
  final db = await initDB();
  final now = DateTime.now();

  final start =
      DateTime(now.year, now.month, 1).toIso8601String().split("T").first;
  final end =
      DateTime(now.year, now.month + 1, 0).toIso8601String().split("T").first;

  final result = await db.rawQuery(
    '''
    SELECT SUM(amount) as total
    FROM transactions
    WHERE type = 'income'
      AND date >= ? 
      AND date <= ?
    ''',
    [start, end],
  );
  final test = await db.rawQuery(
    "SELECT id, title, amount, date, type FROM transactions",
  );
  print(test);
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
}

Future<List<Map<String, dynamic>>> getTransactionsByDate(DateTime date) async {
  final db = await initDB();
  final start = DateTime(date.year, date.month, date.day);
  final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

  return await db.rawQuery(
    '''
    SELECT t.id, t.title, t.amount, t.date, t.type,
           c.name as categoryName, c.icon as categoryIcon
    FROM transactions t
    LEFT JOIN categories c ON t.categoryId = c.id
    WHERE date(t.date) BETWEEN date(?) AND date(?)
    ORDER BY t.date DESC
  ''',
    [start.toIso8601String(), end.toIso8601String()],
  );
}

/// 🔹 Reset database (hapus semua)
Future<void> resetDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'expenses.db');
  await deleteDatabase(path);
  print("Database deleted!");
}
