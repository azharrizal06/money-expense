import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_expense/home/controller/Home_controller.dart';

class Bycalender extends StatefulWidget {
  const Bycalender({super.key});

  @override
  State<Bycalender> createState() => _BycalenderState();
}

HomeController homeController = Get.put(HomeController());

class _BycalenderState extends State<Bycalender> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("pilih tanggal"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              /// 🔹 Input Tanggal
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  controller: homeController.dateController,
                  readOnly: true,
                  onTap: () => homeController.pilihTanggal(context),
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
                    homeController.transactionsbydate.isEmpty
                        ? const Center(child: Text("Tidak ada transaksi"))
                        : ListView.builder(
                          itemCount: homeController.transactionsbydate.length,
                          itemBuilder: (context, index) {
                            final txn =
                                homeController.transactionsbydate[index];
                            return Card(
                              color: Colors.white,
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
      ),
    );
  }
}
