import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:image_picker/image_picker.dart';

class AddRestaurantScreen extends ConsumerStatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  ConsumerState<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends ConsumerState<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  Future<void> _pickImages() async {
    log("called here to pick images");
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((x) => File(x.path)).toList();
      });
    }
    log(pickedFiles!.length.toString());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one image")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(restaurantProvider.notifier).addRestaurant(
            name: _nameController.text,
            description: _descController.text,
            address: _addressController.text,
            lat: double.parse(_latController.text),
            lng: double.parse(_lngController.text),
            images: _selectedImages,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant added successfully!")),
      );

      Navigator.pop(context); // go back to manage screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add restaurant: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Restaurant"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Restaurant Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? "Enter restaurant name" : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? "Enter address" : null,
              ),
              const SizedBox(height: 16),

              // Lat & Lng
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? "Enter latitude" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? "Enter longitude" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Images
              Text(
                "Images",
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              _selectedImages.isEmpty
                  ? TextButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo),
                      label: const Text("Select Images"),
                    )
                  : SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Restaurant", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
