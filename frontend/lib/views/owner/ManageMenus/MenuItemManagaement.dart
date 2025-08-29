import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menu_item_model.dart';
import 'package:frontend/providers/menu_item_providers.dart';
import 'package:image_picker/image_picker.dart';

class MenuItemsPage extends ConsumerWidget {
  final String restaurantId;
  final String categoryId;
  final String categoryName;

  const MenuItemsPage({
    super.key,
    required this.restaurantId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsState = ref.watch(menuItemsProvider(categoryId));
    final notifier = ref.read(menuItemsProvider(categoryId).notifier);

    return Scaffold(
      // The FloatingActionButton is the primary action button for adding new items.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUpsertMenuItemDialog(context, ref),
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadItems(categoryId),
        child: CustomScrollView(
          slivers: [
            // A SliverAppBar gives a modern, collapsible header effect.
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(categoryName),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            // Displays a loading spinner while data is being fetched.
            if (itemsState.isLoading && itemsState.items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            
            // Displays an error message if something goes wrong.
            if (itemsState.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    "Error: ${itemsState.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),

            // Displays a message if there are no items in the category.
            if (!itemsState.isLoading && itemsState.items.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_food_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No items in this category yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text("Tap 'Add Item' to get started.",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            // The main list of menu item cards.
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = itemsState.items[index];
                  return MenuItemCard(item: item);
                },
                childCount: itemsState.items.length,
              ),
            ),
             // Add some padding at the bottom for the FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            )
          ],
        ),
      ),
    );
  }

  // This single dialog is used for both creating and editing a menu item.
  void showUpsertMenuItemDialog(BuildContext context, WidgetRef ref,
      {MenuItem? itemToEdit}) {
    // Controller setup
    final nameController = TextEditingController(text: itemToEdit?.name);
    final descriptionController =
        TextEditingController(text: itemToEdit?.description);
    final priceController =
        TextEditingController(text: itemToEdit?.price.toString());
    
    final formKey = GlobalKey<FormState>();
    bool isAvailable = itemToEdit?.isAvailable ?? true;
    XFile? pickedImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // StatefulBuilder is used to manage the state of the dialog itself (like the switch and image preview).
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(itemToEdit == null ? "Add New Item" : "Edit Item"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Picker and Preview
                      InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() => pickedImage = image);
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (itemToEdit?.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        itemToEdit!.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.add_a_photo,
                                          color: Colors.grey),
                                    )),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: "Item Name"),
                        validator: (v) =>
                            v!.isEmpty ? "Name is required" : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Description"),
                        validator: (v) =>
                            v!.isEmpty ? "Description is required" : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration:
                            const InputDecoration(labelText: "Price", prefixText: "₹"),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return "Price is required";
                          if (double.tryParse(v) == null) {
                            return "Invalid price";
                          }
                          return null;
                        },
                      ),
                      SwitchListTile(
                        title: const Text("Available for order"),
                        value: isAvailable,
                        onChanged: (val) => setState(() => isAvailable = val),
                        contentPadding: EdgeInsets.zero,
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final notifier =
                          ref.read(menuItemsProvider(categoryId).notifier);
                      if (itemToEdit == null) {
                        // Create new item
                        notifier.createMenuItem(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          categoryId: categoryId,
                          restaurantId: restaurantId,
                          imagePath: pickedImage?.path,
                        );
                      } else {
                        // Update existing item
                        notifier.updateMenuItem(
                          id: itemToEdit.id,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          isAvailable: isAvailable,
                          imagePath: pickedImage?.path,
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// A dedicated widget for the menu item card for better organization.
class MenuItemCard extends ConsumerWidget {
  final MenuItem item;
  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            SizedBox(
              width: 120,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.fastfood,
                              size: 50, color: Colors.grey),
                    )
                  : const Center(
                      child: Icon(Icons.fastfood_outlined,
                          size: 50, color: Colors.grey)),
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        // Availability indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: item.isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Popup Menu for Edit/Delete
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  MenuItemsPage(
                    restaurantId: item.restaurantId,
                    categoryId: item.categoryId,
                    categoryName: '', // Not needed for the dialog
                  ).showUpsertMenuItemDialog(context, ref, itemToEdit: item);
                } else if (value == 'delete') {
                  // Confirmation dialog for delete
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Text('Do you want to delete "${item.name}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('No')),
                        TextButton(
                            onPressed: () {
                              ref
                                  .read(menuItemsProvider(item.categoryId)
                                      .notifier)
                                  .deleteMenuItem(item.id);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Yes')),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                      leading: Icon(Icons.edit), title: Text('Edit')),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                      leading: Icon(Icons.delete), title: Text('Delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}