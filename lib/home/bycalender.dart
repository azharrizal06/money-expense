import 'package:flutter/material.dart';
import 'package:money_expense/DB%20helper/db_helper.dart';

class Bycalender extends StatefulWidget {
  const Bycalender({super.key});

  @override
  State<Bycalender> createState() => _BycalenderState();
}

class _BycalenderState extends State<Bycalender> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _updateDateText();
    _loadTransactions(); // default hari ini
  }

  /// 🔹 Ubah tanggal jadi teks untuk TextField
  void _updateDateText() {
    _dateController.text =
        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
  }

  /// 🔹 DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateText();
      });
      _loadTransactions(); // load ulang transaksi sesuai tanggal
    }
  }

  /// 🔹 Ambil transaksi sesuai tanggal
  Future<void> _loadTransactions() async {
    final data = await getTransactionsByDate(_selectedDate);
    setState(() {
      _transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("pilih tanggal")),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Input Tanggal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: "Pilih tanggal",
                  hintStyle: const TextStyle(
                    color: Color(0xff828282),
                    fontSize: 14,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.white,
                ),
              ),
            ),

            /// 🔹 List transaksi sesuai tanggal
            Expanded(
              child:
                  _transactions.isEmpty
                      ? const Center(child: Text("Tidak ada transaksi"))
                      : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final txn = _transactions[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Image.asset(
                                  txn['categoryIcon'] ?? "assets/default.png",
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(txn['title']),
                              subtitle: Text(txn['categoryName'] ?? ""),
                              trailing: Text(
                                "Rp ${txn['amount']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Helper nama bulan
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
