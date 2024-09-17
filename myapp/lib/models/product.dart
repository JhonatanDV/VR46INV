class Product {
  final int? id;
  final String name;
  final int quantity;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}