import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menuCatefory-model.dart';
import 'package:frontend/providers/menuCategories_provider.dart';

class MenuCategoriesPage extends ConsumerWidget {
  final String restaurantID;
  final String restaurantName;

  const MenuCategoriesPage({super.key, required this.restaurantID, required this.restaurantName});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    final categoryState = ref.watch(menuCategoriesProvider(restaurantID));
    final List<MenuCategory> categories = categoryState.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Management"),
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
                fontWeight: FontWeight.bold,               // color: Colors.teal.shade900
              ),
            ),
            const SizedBox(height: 6),
            Text(
              restaurantName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                //color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Add category button
            // Add category button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showAddCategoryDialog(context: context, ref: ref , resID: restaurantID);
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  //backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of categories
            Expanded(
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
                        //backgroundColor: Colors.teal.shade100,
                        child: Text(
                          category.position.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                           //
                           // color: Colors.teal,
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
                      subtitle: Row(
                        spacing: 10,
                        children: [
                          Text("Position: ${category.position}"),
                          Text("Items : {menuItems.len}"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        // TODO: open menu items under this category
                      },
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




  void showAddCategoryDialog({
  required BuildContext context,
  //required Function(String name, int position) onAdd,
  required String resID,
  required WidgetRef ref,
}) {
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, // cannot dismiss by tapping outside
    builder: (context) {
      return AlertDialog(
        title: const Text("Add New Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
                hintText: "Enter category name",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _positionController,
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
              Navigator.of(context).pop(); // close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async{
              final name = _nameController.text.trim();
              final position = int.tryParse(_positionController.text.trim());

              if (name.isEmpty || position == null) {
                // Optional: show error
                return;
              }
              await ref.read(menuCategoriesProvider(resID).notifier).addCategory(catname: name, resID: resID, pos: position);
        
              Navigator.of(context).pop(); // close dialog
              // call function passed in
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}

}
