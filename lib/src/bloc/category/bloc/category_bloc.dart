import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<AddCategory>((event, emit) async {
      emit(CategoryAdding());
      try {
        await categoryRepository.addCategory(event.category);
        emit(CategoryAddedSuccess());
      } catch (e) {
        emit(CategoryError(message: e.toString()));
      }
    });
  }
}
