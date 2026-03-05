import { Controller, Post, Body, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @UseGuards(JwtAuthGuard)
    @Post('change-password')
    async changePassword(@Request() req, @Body('newPassword') newPassword: string) {
        await this.usersService.changePassword(req.user.sub, newPassword);
        return { message: 'Password changed successfully' };
    }

    @UseGuards(JwtAuthGuard)
    @Post('update-profile')
    async updateProfile(@Request() req, @Body('name') name: string) {
        const user = await this.usersService.update(req.user.id, { name });
        return user;
    }

    @UseGuards(JwtAuthGuard)
    @Post('upload-avatar')
    @UseInterceptors(FileInterceptor('file', {
        storage: diskStorage({
            destination: './uploads',
            filename: (req, file, cb) => {
                const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
                return cb(null, `${randomName}${extname(file.originalname)}`);
            }
        })
    }))
    async uploadAvatar(@Request() req, @UploadedFile() file: Express.Multer.File) {
        const avatarUrl = `/uploads/${file.filename}`;
        const user = await this.usersService.update(req.user.id, { avatarUrl });
        return user;
    }
}
