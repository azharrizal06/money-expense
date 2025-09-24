import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_expense/DB%20helper/db_helper.dart';
import 'package:money_expense/home/addScreen.dart';

import 'bycalender.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _todayExpense = 0;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, double> _categoryTotals = {};
  double monthlyIncome = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // panggil saat awal
    pemasukan();
  }

  /// 🔹 Ambil semua transaksi + kategori
  Future<void> _loadTransactions() async {
    final data = await getTransactionsWithCategory();

    setState(() {
      _transactions = data;

      // Hitung total pengeluaran hari ini
      final today = DateTime.now();
      _todayExpense = _transactions
          .where((t) {
            final date = DateTime.parse(t['date']);
            return date.year == today.year &&
                date.month == today.month &&
                date.day == today.day &&
                t['type'] == "expense";
          })
          .fold(0.0, (sum, t) => sum + (t['amount'] as int).toDouble());

      // Hitung total per kategori
      _categoryTotals.clear();
      for (var t in _transactions) {
        if (t['type'] == "expense") {
          final cat = t['categoryName'] ?? "Lainnya";
          final amt = (t['amount'] as int).toDouble();
          _categoryTotals[cat] = (_categoryTotals[cat] ?? 0) + amt;
        }
      }
    });
  }

  Future<void> pemasukan() async {
    final data = await getTransactionsWithCategory();
    final income = await getMonthlyIncome();

    setState(() {
      _transactions = data;
      monthlyIncome = income;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, User!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                'Jangan lupa catat keuanganmu setiap hari!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /// 🔹 Kartu Ringkasan
              Row(
                children: [
                  ExpenseCard(
                    'Pemasuka\nbulan ini',
                    'Rp. ${monthlyIncome.toStringAsFixed(0)}',
                    Colors.cyan,
                  ),
                  const SizedBox(width: 15),
                  ExpenseCard(
                    'Pengeluaranmu\nbulan ini',
                    'Rp. ${_getMonthlyExpense().toStringAsFixed(0)}',
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// 🔹 Total per kategori
              const Text(
                'Pengeluaran berdasarkan kategori',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildCategoryList(context),
              const SizedBox(height: 30),

              /// 🔹 Transaksi hari ini
              Row(
                children: [
                  const Text(
                    'Hari ini',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => Get.to(Bycalender()),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ..._buildDailyList(DateTime.now()),

              const SizedBox(height: 20),

              /// 🔹 Transaksi kemarin
              const Text(
                'Kemarin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._buildDailyList(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _loadTransactions();
          pemasukan();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔹 Hitung total bulanan
  double _getMonthlyExpense() {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          final date = DateTime.parse(t['date']);
          return date.year == now.year &&
              date.month == now.month &&
              t['type'] == "expense";
        })
        .fold(0.0, (sum, t) => sum + (t['amount'] as int).toDouble());
  }

  Expanded ExpenseCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 List kategori dinamis dari DB
  SizedBox _buildCategoryList(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height / 6,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _categoryTotals.entries.map((entry) {
              final catName = entry.key;
              final total = entry.value;

              final tx = _transactions.firstWhere(
                (t) => t['categoryName'] == catName,
                orElse: () => {},
              );

              return _buildCategoryItem(
                catName,
                "Rp. ${total.toStringAsFixed(0)}",
                tx['categoryIcon'] ?? "assets/default.png",
                Colors.blue,
                context,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    String amount,
    String asset,
    Color color,
    context,
  ) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Container(
        width: width / 3,
        height: height / 2,
        padding: const EdgeInsets.only(top: 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Image.asset(
                  asset,
                  color: Colors.white,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Buat list transaksi harian (Hari ini / Kemarin)
  List<Widget> _buildDailyList(DateTime date) {
    final dailyTx =
        _transactions.where((t) {
          final d = DateTime.parse(t['date']);
          return d.year == date.year &&
              d.month == date.month &&
              d.day == date.day;
        }).toList();

    if (dailyTx.isEmpty) {
      return [const Text("Tidak ada transaksi"), const SizedBox(height: 10)];
    }

    return dailyTx.map((txn) {
      return Card(
        color: Colors.white,
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Image.asset(
                  txn['categoryIcon'],
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  txn['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                "Rp ${txn['amount']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
