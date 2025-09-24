class CategoryModel {
  final int? id;
  final String name;
  final String type; // income / expense
  final String icon; // simpan nama icon (contoh "fastfood")

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'icon': icon};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
    );
  }
}
