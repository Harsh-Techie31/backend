import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:frontend/views/owner/addNewRestaurant.dart'; // adjust import if needed

class ManageRestaurantsScreen extends ConsumerWidget {
  const ManageRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Restaurants"),
        centerTitle: true,
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
                  Navigator.push(context, MaterialPageRoute( builder : (context) => const AddRestaurantScreen()));
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Restaurant"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Handle states
            if (restaurantState.isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (restaurantState.errorMessage != null) ...[
              Center(
                child: Text(
                  restaurantState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ] else if (restaurantState.restaurants.isEmpty) ...[
              const Center(child: Text("No restaurants found")),
            ] else ...[
              // Restaurant list
              Expanded(
                child: ListView.separated(
                  itemCount: restaurantState.restaurants.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final restaurant = restaurantState.restaurants[index];
                    return ListTile(
                      title: Text(restaurant.name),
                      subtitle: Text(restaurant.address ?? "No address"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Navigate to edit page
                        },
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
}
