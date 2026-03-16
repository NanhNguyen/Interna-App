import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Announcement } from './schemas/announcement.schema';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/schemas/user.schema';

@Injectable()
export class AnnouncementsService {
    constructor(
        @InjectModel(Announcement.name)
        private announcementModel: Model<Announcement>,
        private readonly notificationsService: NotificationsService,
        private readonly usersService: UsersService,
    ) { }

    async create(authorId: string, authorName: string, data: { title: string; content: string }): Promise<Announcement> {
        // 1. Lưu bài thông báo
        const announcement = new this.announcementModel({
            authorId,
            authorName,
            title: data.title,
            content: data.content,
        });
        const saved = await announcement.save();

        // 2. Gửi thông báo đến tất cả intern và employee
        const allUsers = await this.usersService.findAll();
        const targets = allUsers.filter(
            (u) => u.role === UserRole.INTERN || u.role === UserRole.EMPLOYEE,
        );

        await Promise.all(
            targets.map((user) =>
                this.notificationsService.create(
                    user._id.toString(),
                    `📢 Thông báo từ HR: ${data.title}`,
                    data.content,
                    'ANNOUNCEMENT',
                ),
            ),
        );

        return saved;
    }

    async findAll(): Promise<Announcement[]> {
        return this.announcementModel
            .find()
            .sort({ createdAt: -1 })
            .exec();
    }

    async markSeen(announcementId: string, userId: string): Promise<void> {
        await this.announcementModel.findByIdAndUpdate(
            announcementId,
            { $addToSet: { seenBy: userId } },
        );
    }
}
