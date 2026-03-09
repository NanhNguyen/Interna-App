import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, ForbiddenException } from '@nestjs/common';
import { SchedulesService } from './schedules.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { RequestStatus } from './schemas/schedule-request.schema';

@Controller('schedules')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SchedulesController {
    constructor(private readonly schedulesService: SchedulesService) { }

    @Post()
    @Roles(UserRole.INTERN, UserRole.EMPLOYEE)
    async create(@Request() req: any, @Body() data: any) {
        if (Array.isArray(data)) {
            return this.schedulesService.createMany(req.user._id, data);
        }
        return this.schedulesService.create(req.user._id, data);
    }

    @Get('my')
    async getMySchedules(@Request() req: any) {
        return this.schedulesService.findByUser(req.user._id);
    }

    @Get('all')
    @Roles(UserRole.MANAGER, UserRole.HR)
    async getAllSchedules(@Request() req: any) {
        return this.schedulesService.findAll(req.user);
    }

    @Get('approved')
    async getApprovedSchedules(@Request() req: any) {
        return this.schedulesService.findApproved(req.user);
    }

    @Patch('batch/status')
    @Roles(UserRole.MANAGER, UserRole.HR)
    async updateBatchStatus(
        @Request() req: any,
        @Body('groupId') groupId: string,
        @Body('status') status: RequestStatus,
    ) {
        return this.schedulesService.updateBatchStatus(groupId, status, req.user._id);
    }

    @Patch(':id/status')
    @Roles(UserRole.MANAGER, UserRole.HR)
    async updateStatus(
        @Request() req: any,
        @Param('id') id: string,
        @Body('status') status: RequestStatus,
    ) {
        return this.schedulesService.updateStatus(id, status, req.user._id);
    }

    @Delete('batch/:groupId')
    @Roles(UserRole.INTERN, UserRole.EMPLOYEE)
    async removeBatch(@Request() req: any, @Param('groupId') groupId: string) {
        return this.schedulesService.removeBatch(groupId, req.user._id);
    }

    @Delete(':id')
    @Roles(UserRole.INTERN, UserRole.EMPLOYEE)
    async remove(@Request() req: any, @Param('id') id: string) {
        return this.schedulesService.remove(id, req.user._id);
    }
}
