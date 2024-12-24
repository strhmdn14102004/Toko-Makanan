import 'package:equatable/equatable.dart';
import 'package:food_ninja/src/data/models/category.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddCategory extends CategoryEvent {
  final Category category;

  AddCategory({required this.category});

  @override
  List<Object?> get props => [category];
}
