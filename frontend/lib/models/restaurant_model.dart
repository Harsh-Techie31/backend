import 'dart:convert';

class Restaurant {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final double averageRating;
  final bool isApproved;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.averageRating,
    required this.isApproved,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to parse JSON -> Dart object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      isApproved: json['isApproved'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert Dart object -> JSON (for API calls)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'lat': lat,
      'lng': lng,
      'averageRating': averageRating,
      'isApproved': isApproved,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper to parse list of restaurants
  static List<Restaurant> listFromJson(String str) =>
      List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));
}
