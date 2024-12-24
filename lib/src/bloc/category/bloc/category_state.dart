import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryAdding extends CategoryState {}

class CategoryAddedSuccess extends CategoryState {}

class CategoryError extends CategoryState {
  final String message;

  CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
