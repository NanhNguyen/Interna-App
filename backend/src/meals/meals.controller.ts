import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { MealsService } from './meals.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';

@Controller('meals')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MealsController {
    constructor(private readonly mealsService: MealsService) { }

    @Post()
    @Roles(UserRole.INTERN, UserRole.EMPLOYEE)
    async create(@Request() req: any, @Body() data: any) {
        return this.mealsService.create(req.user._id.toString(), data);
    }

    @Get('my')
    async getMyMeals(@Request() req: any) {
        return this.mealsService.findMyMeals(req.user._id.toString());
    }

    @Get('all')
    @Roles(UserRole.MANAGER, UserRole.HR)
    async getAllMeals() {
        return this.mealsService.findAll();
    }

    @Delete(':id')
    @Roles(UserRole.INTERN, UserRole.EMPLOYEE)
    async remove(@Request() req: any, @Param('id') id: string) {
        return this.mealsService.remove(id, req.user._id.toString());
    }
}
