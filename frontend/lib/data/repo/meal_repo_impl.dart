import 'package:injectable/injectable.dart';
import '../api/meal_api.dart';
import '../model/meal_model.dart';
import 'meal_repo.dart';

@LazySingleton(as: MealRepo)
class MealRepoImpl implements MealRepo {
  final MealApi _mealApi;

  MealRepoImpl(this._mealApi);

  @override
  Future<List<MealModel>> getMyMeals() async {
    final response = await _mealApi.getMyMeals();
    final List<dynamic> data = response.data;
    return data.map((json) => MealModel.fromJson(json)).toList();
  }

  @override
  Future<MealModel> createMeal(Map<String, dynamic> data) async {
    final response = await _mealApi.createMeal(data);
    return MealModel.fromJson(response.data);
  }

  @override
  Future<void> deleteMeal(String id) async {
    await _mealApi.deleteMeal(id);
  }
}
