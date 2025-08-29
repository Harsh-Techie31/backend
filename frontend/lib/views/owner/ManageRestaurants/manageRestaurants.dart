import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:frontend/views/owner/ManageRestaurants/addNewRestaurant.dart';
import 'package:frontend/views/owner/ManageRestaurants/editRestaurant.dart';

class ManageRestaurantsScreen extends ConsumerWidget {
  const ManageRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Restaurants"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // lively app color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add new restaurant button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRestaurantScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Restaurant"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Handle states
            if (restaurantState.isLoading) ...[
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ] else if (restaurantState.errorMessage != null) ...[
              Expanded(
                child: Center(
                  child: Text(
                    restaurantState.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ] else if (restaurantState.restaurants.isEmpty) ...[
              const Expanded(
                  child: Center(
                      child: Text(
                "No restaurants found",
                style: TextStyle(fontSize: 16),
              ))),
            ] else ...[
              // Restaurant list
              Expanded(
                child: ListView.separated(
                  itemCount: restaurantState.restaurants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final restaurant = restaurantState.restaurants[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        onTap: () {
                          // Optional: Navigate to restaurant details
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Restaurant Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: restaurant.images.isNotEmpty
                                    ? Image.network(
                                        restaurant.images.first,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 40,
                                          color: Colors.white70,
                                        ),
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
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            restaurant.address ?? "No address",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            size: 16,
                                            color: Colors.amber[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.averageRating.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800]),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: restaurant.isApproved
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            restaurant.isApproved
                                                ? "Approved"
                                                : "Pending",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: restaurant.isApproved
                                                  ? Colors.green[800]
                                                  : Colors.orange[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action Buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditRestaurantScreen(
                                              restaurant: restaurant),
                                        ),
                                      );
                                    },
                                  ),
                                  //Optional: more actions like delete
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: ()=> showDeleteConfirmationDialog(context: context, ref: ref,id:restaurant.id ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String id, // the id of the item to delete
//  required VoidCallback onConfirm, // function to call on Yes
  String title = "Confirm Delete",
  String message = "Are you sure you want to delete this item?",
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // cannot dismiss by tapping outside
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // just close dialog
          },
          child: const Text("No"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog first
            ref.read(restaurantProvider.notifier).deleteRestaurant(id: id) ;// call the function
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text("Yes"),
        ),
      ],
    ),
  );
}
}