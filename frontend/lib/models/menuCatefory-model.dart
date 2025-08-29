import 'dart:convert';

class MenuCategory {
  final String id;
  final String restaurantId;
  final String name;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuCategory({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static List<MenuCategory> listFromJson(String str) {
    final jsonData = json.decode(str) as List;
    return jsonData.map((item) => MenuCategory.fromJson(item)).toList();
  }

  static String listToJson(List<MenuCategory> categories) {
    final jsonData = categories.map((cat) => cat.toJson()).toList();
    return json.encode(jsonData);
  }

  // --- CORRECTED copyWith METHOD ---
  MenuCategory copyWith({
    String? id,
    String? restaurantId,
    String? name,
    int? position,
    DateTime? createdAt, // Added createdAt
    DateTime? updatedAt, // Added updatedAt
  }) {
    return MenuCategory(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt, // Added createdAt
      updatedAt: updatedAt ?? this.updatedAt, // Added updatedAt
    );
  }
}