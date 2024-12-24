import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ninja/src/bloc/category/bloc/category_bloc.dart';
import 'package:food_ninja/src/bloc/category/bloc/category_event.dart';
import 'package:food_ninja/src/bloc/category/bloc/category_state.dart';
import 'package:food_ninja/src/data/models/category.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitCategory(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final categoryName = _nameController.text.trim();

      final category = Category(name: categoryName);

      context.read<CategoryBloc>().add(AddCategory(category: category));

      // Reset form after submission
      _nameController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              BlocConsumer<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  if (state is CategoryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CategoryAdding) {
                    return CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () => _submitCategory(context),
                    child: Text('Add Category'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
