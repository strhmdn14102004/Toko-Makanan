part of 'restaurant_bloc.dart';

@immutable
abstract class RestaurantEvent {}

class LoadRestaurants extends RestaurantEvent {
  // limit, lastDocument
  final int limit;
  final DocumentSnapshot? lastDocument;

  LoadRestaurants({
    required this.limit,
    required this.lastDocument,
  });
}

class LoadRestaurantFoods extends RestaurantEvent {
  final String restaurantId;

  LoadRestaurantFoods({required this.restaurantId});
}

class SearchRestaurants extends RestaurantEvent {}

class FetchOrderCount extends RestaurantEvent {
  final String restaurantId;

  FetchOrderCount({required this.restaurantId});
}

class AddRestaurant extends RestaurantEvent {
  final String name;
  final String location;
  final String description;
  final File? image;
  final DateTime createdAt;

  AddRestaurant({
    required this.name,
    required this.location,
    this.description = '',
    this.image,
    required this.createdAt,
  });
}
