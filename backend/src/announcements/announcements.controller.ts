import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
import { AnnouncementsService } from './announcements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';

@Controller('announcements')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AnnouncementsController {
    constructor(private readonly announcementsService: AnnouncementsService) { }

    // HR: tạo bài thông báo mới
    @Post()
    @Roles(UserRole.HR)
    async create(@Request() req: any, @Body() data: { title: string; content: string }) {
        return this.announcementsService.create(
            req.user._id.toString(),
            req.user.name,
            data,
        );
    }

    // Tất cả: xem danh sách thông báo
    @Get()
    async findAll() {
        return this.announcementsService.findAll();
    }

    // Đánh dấu đã xem
    @Patch(':id/seen')
    async markSeen(@Request() req: any, @Param('id') id: string) {
        return this.announcementsService.markSeen(id, req.user._id.toString());
    }
}
