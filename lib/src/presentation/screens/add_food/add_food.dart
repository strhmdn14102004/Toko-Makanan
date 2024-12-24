import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_ninja/src/data/services/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ninja/src/data/models/food.dart';
import 'package:food_ninja/src/data/repositories/food_repository.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({Key? key}) : super(key: key);

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodRepository = FoodRepository();
  final _firebaseStorageService =
      FirebaseStorageService(FirebaseStorage.instance);

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();

  DocumentReference? _selectedCategory;
  DocumentReference? _selectedRestaurant;
  File? _selectedImage;

  Future<List<QueryDocumentSnapshot>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchRestaurants() async {
    final snapshot = await FirebaseFirestore.instance.collection('restaurants').get();
    return snapshot.docs;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_selectedImage != null) {
          final imagePath =
              'foods/${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await _firebaseStorageService.uploadImage(
            imagePath,
            _selectedImage!,
          );
        }

        final food = Food(
          category: _selectedCategory!,
          restaurant: _selectedRestaurant!,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          ingredients: _ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
          createdAt: DateTime.now(),
          image: imageUrl,
          discount: _discountController.text.isEmpty
              ? null
              : double.tryParse(_discountController.text.trim()),
          description: _descriptionController.text.trim(),
          quantity: 0,
        );

        await _foodRepository.addFood(food);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Food Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter food name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter price' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: 'Ingredients (comma separated)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter ingredients' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(width: 16),
                    _selectedImage != null
                        ? const Text('Image Selected',
                            style: TextStyle(color: Colors.green))
                        : const Text('No image selected'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'Discount (%)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<DocumentReference>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: snapshot.data!
                          .map(
                            (doc) => DropdownMenuItem(
                              value: doc.reference,
                              child: Text(doc['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        _selectedCategory = value;
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchRestaurants(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<DocumentReference>(
                      decoration: const InputDecoration(labelText: 'Restaurant'),
                      items: snapshot.data!
                          .map(
                            (doc) => DropdownMenuItem(
                              value: doc.reference,
                              child: Text(doc['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        _selectedRestaurant = value;
                      },
                      validator: (value) =>
                          value == null ? 'Please select a restaurant' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Food'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
