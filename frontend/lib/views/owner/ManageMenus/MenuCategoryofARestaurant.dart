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

    // Sort the list by position before displaying it
    final sortedCategories = List<MenuCategory>.from(categoryState.categories);
    sortedCategories.sort((a, b) => a.position.compareTo(b.position));

    Widget buildBody() {
      // FIX: Use sortedCategories for checks
      if (categoryState.isLoading && sortedCategories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (categoryState.errorMessage != null) {
        return Center(child: Text("Error: ${categoryState.errorMessage}"));
      }
      if (sortedCategories.isEmpty) {
        return const Center(
            child: Text("No categories found. Add one to get started!"));
      }

      return Expanded(
        child: ReorderableListView.builder(
          // FIX: Use sortedCategories for item count
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            // FIX: Use sortedCategories to get the item
            final category = sortedCategories[index];
            return Card(
              // FIX: A Unique Key is REQUIRED for ReorderableListView to work.
              key: ValueKey(category.id),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
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
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'))),
                        const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'))),
                      ],
                    ),
                    // Use a drag handle for better UX
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              ),
            );
          },
          // FIX: Implemented the onReorder callback.
          onReorder: (oldIndex, newIndex) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Reorder'),
                content:
                    const Text('Are you sure you want to save this new order?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        notifier.reorderCategories(oldIndex, newIndex);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Confirm')),
                ],
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
            const Text("Manage menus for restaurant:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(restaurantName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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

// Dialog functions remain unchanged below this line
void showAddCategoryDialog(
    {required BuildContext context,
    required String resID,
    required WidgetRef ref}) {
    // ... same as your code
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

void showEditCategoryDialog(
    {required BuildContext context,
    required WidgetRef ref,
    required MenuCategory category}) {
    // ... same as your code
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