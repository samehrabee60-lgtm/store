class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;
  final String? pdfUrl;
  final List<String> additionalImages;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.pdfUrl,
    this.additionalImages = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'additional_images': additionalImages,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? '',
      pdfUrl: map['pdf_url'],
      additionalImages: List<String>.from(map['additional_images'] ?? []),
    );
  }
}
