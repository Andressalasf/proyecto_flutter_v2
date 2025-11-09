class Product {
  final int? id;
  final String? productId;
  final String name;
  final String description;
  final int unitPrice;
  final int stock;
  final String productType;

  Product({
    this.id,
    this.productId,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.stock,
    required this.productType,
  });

  // De JSON a Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unitPrice'],
      stock: json['stock'],
      productType: json['productType'],
    );
  }

  // De Product a JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'unitPrice': unitPrice,
      'stock': stock,
      'productType': productType,
    };
  }
}
