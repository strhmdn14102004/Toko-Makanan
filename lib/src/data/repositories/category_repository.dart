import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ninja/src/data/models/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toMap());
  }
}
