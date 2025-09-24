import 'package:flutter/material.dart';
import 'package:money_expense/DB%20helper/db_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryIcon;
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await getCategories();
    setState(() {
      _categories = data;
    });
  }

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
      });
    }
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCategoryGrid(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return InkWell(
            onTap: () {
              setState(() {
                _categoryController.text = category['name'];
                _selectedCategoryIcon = category['icon'];
              });
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    category['icon'],
                    width: 40,
                    height: 40,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 5),
                  Text(category['name']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Pengeluaran Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, texthint: 'Nama pengeluaran'),
            const SizedBox(height: 15),

            _buildReadOnlyTextField(
              _categoryController,
              hinttext: "Pilih kategori",
              prefik: true,
              onTap: () => _showCategoryPicker(context),
            ),
            const SizedBox(height: 15),

            _buildReadOnlyTextField(
              TextEditingController(
                text:
                    '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
              ),
              prefik: false,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),

            _buildTextField(
              _nominalController,
              keyboardType: TextInputType.number,
              texthint: "Nominal",
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _nominalController.text.isEmpty ||
                        _categoryController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lengkapi semua data!")),
                      );
                      return;
                    }

                    // Cari ID kategori yang sesuai dari database
                    final selectedCategory = _categories.firstWhere(
                      (cat) => cat['name'] == _categoryController.text,
                      orElse: () => {},
                    );

                    if (selectedCategory.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Kategori tidak ditemukan!"),
                        ),
                      );
                      return;
                    }

                    final txn = {
                      "title": _nameController.text,
                      "amount": int.tryParse(_nominalController.text) ?? 0,
                      "date": _selectedDate.toIso8601String().split('T').first,
                      "type": selectedCategory['type'],
                      "categoryId": selectedCategory['id'], // pakai relasi ID
                    };

                    await addTransaction(txn);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Transaksi berhasil disimpan!"),
                      ),
                    );

                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? texthint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: texthint,
        hintStyle: const TextStyle(color: Color(0xff828282), fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildReadOnlyTextField(
    TextEditingController controller, {
    bool prefik = true,
    VoidCallback? onTap,
    String? hinttext,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: const TextStyle(color: Color(0xff828282), fontSize: 14),
        prefixIcon:
            prefik && _selectedCategoryIcon != null
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    _selectedCategoryIcon!,
                    width: 24,
                    height: 24,
                    color: Colors.amber,
                  ),
                )
                : null,
        suffix:
            !prefik
                ? Image.asset("assets/kalender.png", color: Color(0xffE0E0E0))
                : const Icon(Icons.keyboard_arrow_right_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return monthNames[month];
  }
}
