class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String state;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.state,
  });

  bool get isActive => state.toLowerCase() == 'activo';

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? imageUrl,
    String? state,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      state: state ?? this.state,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['product_id'] ?? json['id'];
    final rawPrice = json['product_price'];
    double price;
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice) ?? 0;
    } else {
      price = 0;
    }

    return Product(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      name: (json['product_name'] ?? '').toString(),
      price: price,
      imageUrl: (json['product_image'] ?? '').toString(),
      state: (json['product_state'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toEditPayload() {
    return {
      'product_id': id,
      'product_name': name,
      'product_price': price.round(),
      'product_image': imageUrl,
      'product_state': state,
    };
  }
}
