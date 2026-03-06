import { Controller, Post, Body, UseGuards, Request, UseInterceptors, UploadedFile, UnauthorizedException, Get } from '@nestjs/common';
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
    async changePassword(
        @Request() req,
        @Body('oldPassword') oldPassword: string,
        @Body('newPassword') newPassword: string
    ) {
        await this.usersService.changePassword(req.user.id, oldPassword, newPassword);
        return { message: 'Đổi mật khẩu thành công' };
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

    @UseGuards(JwtAuthGuard)
    @Get('managers')
    async getManagers() {
        return this.usersService.getManagers();
    }

    @UseGuards(JwtAuthGuard)
    @Post('create-account')
    async createAccount(@Request() req, @Body() createUserDto: any) {
        if (req.user.role !== 'HR') {
            throw new UnauthorizedException('Chỉ HR mới có quyền tạo tài khoản.');
        }

        let roleId = '69649755edf9b4ac54f3c596'; // default INTERN
        if (createUserDto.role === 'INTERN') roleId = '69649755edf9b4ac54f3c596';
        if (createUserDto.role === 'MANAGER') roleId = '69649765edf9b4ac54f3c598';
        if (createUserDto.role === 'HR') roleId = '6964978cedf9b4ac54f3c59a';

        const userData: any = {
            email: createUserDto.email,
            password_hash: createUserDto.password,
            name: createUserDto.name,
            role_id: roleId,
        };

        if (createUserDto.role === 'INTERN' && createUserDto.managerId) {
            userData.managerId = createUserDto.managerId;
        }

        const user = await this.usersService.create(userData);
        // remove password_hash from response
        const userObj = user.toObject();
        delete userObj.password_hash;
        return { message: 'Tạo tài khoản thành công', user: userObj };
    }
}
