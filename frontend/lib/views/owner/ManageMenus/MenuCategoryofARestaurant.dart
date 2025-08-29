import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/views/owner/ManageMenus/MenuItemManagaement.dart';

import 'package:frontend/models/menuCatefory-model.dart';
import 'package:frontend/providers/menuCategories_provider.dart';


class MenuCategoriesPage extends ConsumerWidget {
  final String restaurantID;
  final String restaurantName;

  const MenuCategoriesPage(
      {super.key, required this.restaurantID, required this.restaurantName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(menuCategoriesProvider(restaurantID));
    final List<MenuCategory> categories = categoryState.categories;

    // A helper to show loading or errors while the main list is being built
    Widget buildBody() {
      if (categoryState.isLoading && categories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (categoryState.errorMessage != null) {
        return Center(child: Text("Error: ${categoryState.errorMessage}"));
      }
      if (categories.isEmpty) {
        return const Center(
            child: Text("No categories found. Add one to get started!"));
      }
      // The main list of categories
      return Expanded(
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    category.position.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // 4. MINOR FIX: Corrected the Row widget
                subtitle: Text("Position: ${category.position}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                
                // 2. & 3. ADD NAVIGATION LOGIC HERE
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MenuItemsPage(
                        restaurantId: restaurantID,
                        categoryId: category.id, // Pass the category's ID
                        categoryName: category.name, // Pass the category's name
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Management"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Manage menus for restaurant:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              restaurantName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showAddCategoryDialog(
                      context: context, ref: ref, resID: restaurantID);
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildBody(), // Use the helper to build the body
          ],
        ),
      ),
    );
  }
}

// The dialog function remains the same
void showAddCategoryDialog({
  required BuildContext context,
  required String resID,
  required WidgetRef ref,
}) {
  final nameController = TextEditingController();
  final positionController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add New Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
                hintText: "Enter category name",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: positionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Position",
                hintText: "Enter category position",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final position = int.tryParse(positionController.text.trim());

              if (name.isEmpty || position == null) {
                return;
              }
              await ref
                  .read(menuCategoriesProvider(resID).notifier)
                  .addCategory(catname: name, resID: resID, pos: position);

              Navigator.of(context).pop();
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}