import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:frontend/views/owner/ManageMenus/MenuCategoryofARestaurant.dart';

class ManageMenusPage extends ConsumerWidget {
  //final List<Restaurant> restaurants;

  const ManageMenusPage({super.key});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);
    List<Restaurant> restaurants = restaurantState.restaurants;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Menus"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage menus for restaurant :",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return GestureDetector(
                    onTap: () {
                      // 👉 Navigate to restaurant's menu categories page
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MenuCategoriesPage(restaurantName: restaurant.name,restaurantID: restaurant.id,)));
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                restaurant.images.isNotEmpty
                                    ? restaurant.images.first
                                    : "https://via.placeholder.com/100",
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Restaurant Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    restaurant.address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        restaurant.averageRating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Categories: {restaurant.menuCategoriesCount} | Items: {restaurant.menuItemsCount}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );


    
  }
  
}
