import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { MealRegistration } from './schemas/meal-registration.schema';

@Injectable()
export class MealsService {
    constructor(
        @InjectModel(MealRegistration.name)
        private mealModel: Model<MealRegistration>,
    ) { }

    async create(userId: string, data: any): Promise<MealRegistration> {
        const meal = new this.mealModel({ userId, ...data });
        return meal.save();
    }

    async findMyMeals(userId: string): Promise<MealRegistration[]> {
        return this.mealModel
            .find({ userId })
            .sort({ startDate: -1 })
            .exec();
    }

    // HR/Manager: xem cơm của toàn bộ nhân viên
    async findAll(): Promise<MealRegistration[]> {
        return this.mealModel
            .find()
            .populate('userId', 'name email role')
            .sort({ startDate: -1 })
            .exec();
    }

    async remove(id: string, userId: string): Promise<void> {
        const meal = await this.mealModel.findById(id);
        if (!meal) throw new NotFoundException('Không tìm thấy đăng ký cơm');
        if (meal.userId.toString() !== userId) {
            throw new ForbiddenException('Bạn không có quyền xóa đăng ký này');
        }
        await this.mealModel.findByIdAndDelete(id);
    }
}
