class Product {
  final String id;
  final String name;
  final String imageUrl; // Main thumbnail
  final List<String> images; // Multiple images
  final double price;
  final double oldPrice; 
  final double rating;
  final String category;
  final String description;
  final String brand;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.images = const [],
    required this.price,
    this.oldPrice = 0.0,
    required this.rating,
    required this.category,
    required this.description,
    this.brand = 'Generic',
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      oldPrice: (data['oldPrice'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      brand: data['brand'] ?? 'ProMart Exclusive',
    );
  }

  // Returns all images combining main thumbnail and the images list
  List<String> get allImages {
    List<String> list = [];
    if (imageUrl.isNotEmpty) list.add(imageUrl);
    // Add other images while avoiding duplicates
    for (var img in images) {
      if (img != imageUrl) list.add(img);
    }
    return list.isEmpty ? [] : list;
  }

  int get discountPercentage {
    if (oldPrice <= price) return 0;
    return (((oldPrice - price) / oldPrice) * 100).round();
  }
}
