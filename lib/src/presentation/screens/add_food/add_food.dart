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
          const SnackBar(content: Text('Barang berhasil ditambahkan!')),
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
        title: const Text('Tambah Data Barang'),
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
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                  validator: (value) =>
                      value!.isEmpty ? 'Masukan nama barang' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Tolong masukan harga barang' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: 'Bahan-bahan (pisahkan dengan koma)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Tolong masukan bahan bahan' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pilih Gambar'),
                    ),
                    const SizedBox(width: 16),
                    _selectedImage != null
                        ? const Text('Gambar Terpilih',
                            style: TextStyle(color: Colors.green))
                        : const Text('Tidak ada gambar yang dipilih'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'Diskon Rupiah'),
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
                      decoration: const InputDecoration(labelText: 'Kategori Barang'),
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
                          value == null ? 'Tolong pilih kategori barang' : null,
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
                      decoration: const InputDecoration(labelText: 'Toko'),
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
                          value == null ? 'Tolong pilih asal toko barang' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Tambahkan Barang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
