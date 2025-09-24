class TransactionModel {
  final int? id;
  final String title;
  final int amount;
  final String date; // format yyyy-MM-dd
  final String type; // income / expense
  final String category; // contoh: Makan, Transportasi, Gaji

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'type': type,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      type: map['type'],
      category: map['category'],
    );
  }
}
