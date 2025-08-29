// file: menu_items_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: REPLACE these placeholders with your actual model and provider imports.
// import 'package:frontend/models/menuItem_model.dart';
// import 'package:frontend/providers/menuItems_provider.dart';

// --- Placeholder Model and Provider (for demonstration) ---
// You should replace this with your actual implementation.
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isVeg;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVeg,
  });
}

class MenuItemsState {
  final List<MenuItem> items;
  MenuItemsState({this.items = const []});
}

class MenuItemsNotifier extends StateNotifier<MenuItemsState> {
  MenuItemsNotifier() : super(MenuItemsState(items: _dummyItems));
  static final List<MenuItem> _dummyItems = [
    MenuItem(id: '1', name: 'Paneer Tikka', description: 'Spicy grilled cottage cheese', price: 250.0, isVeg: true),
    MenuItem(id: '2', name: 'Chicken Biryani', description: 'Aromatic rice with chicken', price: 350.0, isVeg: false),
  ];
  Future<void> addItem({ required String name, required String description, required double price, required bool isVeg, required String categoryId }) async {
    // TODO: Implement your API call to add the item.
    final newItem = MenuItem(id: DateTime.now().toString(), name: name, description: description, price: price, isVeg: isVeg);
    state = MenuItemsState(items: [...state.items, newItem]);
  }
}

final menuItemsProvider = StateNotifierProvider.family<MenuItemsNotifier, MenuItemsState, String>((ref, categoryId) {
  // The categoryId would be used to fetch data from your API.
  return MenuItemsNotifier();
});
// --- End of Placeholder Code ---


class MenuItemsPage extends ConsumerWidget {
  final String categoryID;
  final String categoryName;

  const MenuItemsPage({
    super.key,
    required this.categoryID,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for the given categoryID
    final itemsState = ref.watch(menuItemsProvider(categoryID));
    final List<MenuItem> menuItems = itemsState.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Manage items for category:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Add item button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showAddMenuItemDialog(context: context, ref: ref, categoryID: categoryID);
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Item"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of menu items
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.isVeg ? Colors.green.shade100 : Colors.red.shade100,
                        child: Icon(
                          Icons.circle,
                          size: 14,
                          color: item.isVeg ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
      trailing: Text(
        // Assuming your app uses INR, otherwise change the currency symbol
        '₹${item.price.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

                      onTap: () {
                        // TODO: Open item details or an edit dialog
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
}

void showAddMenuItemDialog({
  required BuildContext context,
  required String categoryID,
  required WidgetRef ref,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  bool isVeg = true; // Default to veg

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      // Use StatefulBuilder to update the Switch state inside the dialog
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add New Menu Item"),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      validator: (value) => value!.isEmpty ? 'Description cannot be empty' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price", prefixText: "₹"),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Price cannot be empty';
                        if (double.tryParse(value) == null) return 'Enter a valid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Vegetarian"),
                        Switch(
                          value: isVeg,
                          onChanged: (value) => setState(() => isVeg = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await ref.read(menuItemsProvider(categoryID).notifier).addItem(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: double.parse(priceController.text.trim()),
                          isVeg: isVeg,
                          categoryId: categoryID,
                        );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    },
  );
}