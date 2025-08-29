// MenuCategoriesPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menuCatefory-model.dart';
import 'package:frontend/providers/menuCategories_provider.dart';
import 'package:frontend/views/owner/ManageMenus/MenuItemManagaement.dart';


class MenuCategoriesPage extends ConsumerWidget {
  final String restaurantID;
  final String restaurantName;

  const MenuCategoriesPage(
      {super.key, required this.restaurantID, required this.restaurantName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(menuCategoriesProvider(restaurantID));
    final notifier = ref.read(menuCategoriesProvider(restaurantID).notifier);

    Widget buildBody() {
      if (categoryState.isLoading && categoryState.categories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (categoryState.errorMessage != null) {
        return Center(child: Text("Error: ${categoryState.errorMessage}"));
      }
      if (categoryState.categories.isEmpty) {
        return const Center(
            child: Text("No categories found. Add one to get started!"));
      }
      return Expanded(
        child: ListView.builder(
          itemCount: categoryState.categories.length,
          itemBuilder: (context, index) {
            final category = categoryState.categories[index];
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
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text("Position: ${category.position}"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MenuItemsPage(
                        restaurantId: restaurantID,
                        categoryId: category.id,
                        categoryName: category.name,
                      ),
                    ),
                  );
                },
                // --- NEW: POPUP MENU FOR EDIT AND DELETE ---
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showEditCategoryDialog(
                          context: context, ref: ref, category: category);
                    } else if (value == 'delete') {
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: const Text('Are you sure?'),
                                content: Text(
                                    'Do you want to delete "${category.name}"?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('No')),
                                  TextButton(
                                      onPressed: () {
                                        notifier.deleteCategory(category.id);
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text('Yes')),
                                ],
                              ));
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                            leading: Icon(Icons.edit), title: Text('Edit'))),
                    const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'))),
                  ],
                ),
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
            Text("Manage menus for restaurant:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(restaurantName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => showAddCategoryDialog(
                    context: context, ref: ref, resID: restaurantID),
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildBody(),
          ],
        ),
      ),
    );
  }
}

// Add Dialog (no changes)
void showAddCategoryDialog(
    {required BuildContext context, required String resID, required WidgetRef ref}) {
  // ... (this function remains the same as your original)
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add New Category"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Category Name")),
        const SizedBox(height: 12),
        TextField(
            controller: positionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Position")),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final position = int.tryParse(positionController.text.trim());
              if (name.isNotEmpty && position != null) {
                ref
                    .read(menuCategoriesProvider(resID).notifier)
                    .addCategory(catname: name, resID: resID, pos: position);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add")),
      ],
    ),
  );
}

// --- NEW: EDIT DIALOG ---
void showEditCategoryDialog(
    {required BuildContext context,
    required WidgetRef ref,
    required MenuCategory category}) {
  final nameController = TextEditingController(text: category.name);
  final positionController =
      TextEditingController(text: category.position.toString());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Edit ${category.name}"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Category Name")),
        const SizedBox(height: 12),
        TextField(
            controller: positionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Position")),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final position = int.tryParse(positionController.text.trim());
              if (name.isNotEmpty && position != null) {
                ref.read(menuCategoriesProvider(category.restaurantId).notifier)
                    .updateCategory(
                        categoryId: category.id,
                        name: name,
                        position: position);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Save")),
      ],
    ),
  );
}