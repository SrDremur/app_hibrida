class SaleProduct {
  final String idProduct;
  final int quantity;
  final double price;

  SaleProduct({
    required this.idProduct,
    required this.quantity,
    required this.price,
  });

  factory SaleProduct.fromJson(Map<String, dynamic> json) => SaleProduct(
    idProduct: json['id_product'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id_product': idProduct,
    'quantity': quantity,
    'price': price,
  };
}

class Sale {
  final String? id;
  final String idUser;
  final List<SaleProduct> products;
  final double totalPrice;
  final DateTime saleDate;

  Sale({
    this.id,
    required this.idUser,
    required this.products,
    required this.totalPrice,
    required this.saleDate,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: json['_id'],
    idUser: json['id_user'] ?? '',
    products: (json['products'] as List<dynamic>? ?? [])
        .map((p) => SaleProduct.fromJson(p))
        .toList(),
    totalPrice: (json['total_price'] ?? 0).toDouble(),
    saleDate: DateTime.tryParse(json['sale_date'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id_user': idUser,
    'products': products.map((p) => p.toJson()).toList(),
    'total_price': totalPrice,
    'sale_date': saleDate.toIso8601String(),
  };
}
