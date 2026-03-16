import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { MealsService } from './meals.service';
import { MealsController } from './meals.controller';
import { MealRegistration, MealRegistrationSchema } from './schemas/meal-registration.schema';

@Module({
    imports: [
        MongooseModule.forFeature([{ name: MealRegistration.name, schema: MealRegistrationSchema }]),
    ],
    providers: [MealsService],
    controllers: [MealsController],
    exports: [MealsService],
})
export class MealsModule { }
