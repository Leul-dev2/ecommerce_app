import 'package:flutter/foundation.dart';

class ProductModel {
  final String id;
  final String image;
  final String brandName;
  final String title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String? description;
  final double? rating;
  final List<String>? reviews;
  final List<ProductModel>? relatedProducts;

  // NEW fields for detailed product info
  final String? material;
  final String? origin;
  final double? weight;
  final String? sku;
  final String? sellerName;

  // ✅ ✅ ✅ Add this!
  final bool? isPopular;

  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.description,
    this.rating,
    this.reviews,
    this.relatedProducts,
    this.material,
    this.origin,
    this.weight,
    this.sku,
    this.sellerName,
    this.isPopular, // ✅ ✅ ✅ Add to constructor
  }) : assert(id.isNotEmpty, 'Product id cannot be empty');

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final dynamic idSource = map['_id'] ?? map['id'];
    final String parsedId = idSource?.toString() ?? '';

    if (parsedId.isEmpty) {
      debugPrint('⚠️ WARNING: Product missing ID in map: $map');
    }

    return ProductModel(
      id: parsedId,
      image: map['image'] ?? '',
      brandName: map['brandName'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      priceAfterDiscount: (map['priceAfterDiscount'] as num?)?.toDouble(),
      discountPercent: map['discountPercent'] as int?,
      description: map['description'],
      rating: (map['rating'] as num?)?.toDouble(),
      reviews: (map['reviews'] as List?)?.map((e) => e.toString()).toList(),
      relatedProducts: (map['relatedProducts'] as List?)
          ?.map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      material: map['material'],
      origin: map['origin'],
      weight: (map['weight'] as num?)?.toDouble(),
      sku: map['sku'],
      sellerName: map['sellerName'],
      isPopular: map['isPopular'] == true, // ✅ ✅ ✅ Parse from JSON
    );
  }

  get shippingInfo => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'brandName': brandName,
      'title': title,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'discountPercent': discountPercent,
      'description': description,
      'rating': rating,
      'reviews': reviews,
      'relatedProducts': relatedProducts?.map((e) => e.toMap()).toList(),
      'material': material,
      'origin': origin,
      'weight': weight,
      'sku': sku,
      'sellerName': sellerName,
      'isPopular': isPopular, // ✅ ✅ ✅ Add to output
    };
  }
}
