class Sale {
  final int? id;
  final int productId;
  final int quantitySold;
  final double totalAmount;
  final double discountPercentage; // Nuevo campo para el porcentaje de descuento
  final DateTime saleDate;

  Sale({
    this.id,
    required this.productId,
    required this.quantitySold,
    required this.totalAmount,
    required this.discountPercentage, // Inicializa el nuevo campo
    required this.saleDate,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productId: map['productId'],
      quantitySold: map['quantitySold'],
      totalAmount: map['totalAmount'],
      discountPercentage: map['discountPercentage'] ?? 0.0, // Lee el nuevo campo
      saleDate: map['saleDate'] != null ? DateTime.parse(map['saleDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantitySold': quantitySold,
      'totalAmount': totalAmount,
      'discountPercentage': discountPercentage, // Incluye el nuevo campo
      'saleDate': saleDate.toIso8601String(),
    };
  }
}
