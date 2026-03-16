import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/repo/meal_repo.dart';
import 'meal_state.dart';

@injectable
class MealCubit extends Cubit<MealState> {
  final MealRepo _mealRepo;

  MealCubit(this._mealRepo) : super(const MealState());

  Future<void> loadMeals() async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final meals = await _mealRepo.getMyMeals();
      emit(state.copyWith(status: BaseStatus.success, meals: meals));
    } catch (e) {
      emit(
        state.copyWith(status: BaseStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> submitMeal(Map<String, dynamic> data) async {
    emit(state.copyWith(submitStatus: BaseStatus.loading));
    try {
      final newMeal = await _mealRepo.createMeal(data);
      emit(
        state.copyWith(
          submitStatus: BaseStatus.success,
          meals: [newMeal, ...state.meals],
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: BaseStatus.error,
          errorMessage: 'Đăng ký thất bại: $e',
        ),
      );
      return false;
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await _mealRepo.deleteMeal(id);
      final updatedMeals = state.meals.where((m) => m.id != id).toList();
      emit(state.copyWith(meals: updatedMeals));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Không thể xóa: $e'));
    }
  }
}
