import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ninja/src/bloc/restaurant/restaurant_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddRestaurantPage extends StatefulWidget {
  @override
  _AddRestaurantPageState createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final restaurantBloc = BlocProvider.of<RestaurantBloc>(context);

      restaurantBloc.add(
        AddRestaurant(
          name: _nameController.text,
          location: _locationController.text,
          description: _descriptionController.text,
          image: _selectedImage,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Restaurant')),
      body: BlocListener<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantAddedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Restaurant added successfully')),
            );
            Navigator.pop(context);
          } else if (state is RestaurantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add restaurant')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Restaurant Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                    validator: (value) =>
                        value!.isEmpty ? 'Location cannot be empty' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!,
                            height: 200, fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.camera_alt, size: 50),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Add Restaurant'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
