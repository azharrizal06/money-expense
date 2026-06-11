import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_expense/DB%20helper/db_helper.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    pemasukan();
  }

  @override
  void onReady() {
    super.onReady();
    refres();
  }

  void refres() async {
    await loadTransactions();
    await pemasukan();
  }

  var todayExpense = 0.0.obs;
  var transactions = <Map<String, dynamic>>[].obs;
  var categoryTotals = <String, double>{}.obs;
  var monthlyIncome = 0.0.obs;

  /// 🔹 Ambil semua transaksi + kategori
  Future<void> loadTransactions() async {
    final data = await getTransactionsWithCategory();

    transactions.value = data;

    // Hitung total pengeluaran hari ini
    final today = DateTime.now();
    todayExpense.value = transactions
        .where((t) {
          final date = DateTime.parse(t['date']);
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day &&
              t['type'] == "expense";
        })
        .fold(0.0, (sum, t) => sum + (t['amount'] as int).toDouble());

    // Hitung total per kategori
    categoryTotals.clear();
    for (var t in transactions) {
      if (t['type'] == "expense") {
        final cat = t['categoryName'] ?? "Lainnya";
        final amt = (t['amount'] as int).toDouble();
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
      }
    }
  }

  Future<void> pemasukan() async {
    final data = await getTransactionsWithCategory();
    final income = await getMonthlyIncome();
    transactions.value = data;
    monthlyIncome.value = income;
  }

  /// sercs
  var selectedDate = DateTime.now().obs;
  final dateController = TextEditingController();
  var transactionsbydate = <Map<String, dynamic>>[].obs;

  /// 🔹 Ubah tanggal jadi teks untuk TextField
  void _updateDateText() {
    dateController.text =
        '${selectedDate.value.day} ${_getMonthName(selectedDate.value.month)} ${selectedDate.value.year}';
  }

  /// 🔹 DatePicker
  Future<void> pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      _updateDateText();
      _loadTransactions();
    }
  }

  /// 🔹 Ambil transaksi sesuai tanggal
  Future<void> _loadTransactions() async {
    final data = await getTransactionsByDate(selectedDate.value);

    transactionsbydate.value = data.reversed.toList();
  }

  String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return months[month - 1];
  }
}
