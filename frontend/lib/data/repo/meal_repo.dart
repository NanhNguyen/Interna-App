import '../model/meal_model.dart';

abstract class MealRepo {
  Future<List<MealModel>> getMyMeals();
  Future<MealModel> createMeal(Map<String, dynamic> data);
  Future<void> deleteMeal(String id);
}
