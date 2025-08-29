
import 'dart:convert';


List<MenuItem> menuItemFromJson(String str) =>
    List<MenuItem>.from(json.decode(str).map((x) => MenuItem.fromJson(x)));


String menuItemToJson(MenuItem data) => json.encode(data.toJson());

class MenuItem {
  // Properties from your Mongoose schema
  final String id; // Corresponds to MongoDB's '_id'
  final String restaurantId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl; // Nullable as it's not required
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
  });

  /// **copyWith** method
  /// Creates a new instance of MenuItem with updated values.
  /// Useful for immutable state management (e.g., with Riverpod or BLoC).
  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json["_id"], // MongoDB uses '_id'
      restaurantId: json["restaurantId"],
      categoryId: json["categoryId"]["_id"],
      name: json["name"],
      description: json["description"],
      // Safely convert price, which might be an int or double in the JSON
      price: (json["price"] as num).toDouble(),
      imageUrl: json["imageUrl"],
      isAvailable: json["isAvailable"],
    );
  }
  factory MenuItem.fromJson1(Map<String, dynamic> json) {
    return MenuItem(
      id: json["_id"], // MongoDB uses '_id'
      restaurantId: json["restaurantId"],
      categoryId: json["categoryId"],
      name: json["name"],
      description: json["description"],
      // Safely convert price, which might be an int or double in the JSON
      price: (json["price"] as num).toDouble(),
      imageUrl: json["imageUrl"],
      isAvailable: json["isAvailable"],
    );
  }

  /// **toJson** method
  /// Converts a MenuItem instance back into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "restaurantId": restaurantId,
      "categoryId": categoryId,
      "name": name,
      "description": description,
      "price": price,
      "imageUrl": imageUrl,
      "isAvailable": isAvailable,
    };
  }
}