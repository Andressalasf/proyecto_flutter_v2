class Product {
  final int? id;
  final String title;
  final double price;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? categoryImage;
  final List<String>? images;

  Product({
    this.id,
    required this.title,
    required this.price,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryImage,
    this.images,
  });

  // De JSON a Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      price: _parsePrice(json['price']),
      description: json['description'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryImage: json['category_image'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  // Método auxiliar para convertir el precio
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  // De Product a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category_id': categoryId,
      'images': images ?? [],
    };
  }
}
