import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AnnouncementsService } from './announcements.service';
import { AnnouncementsController } from './announcements.controller';
import { Announcement, AnnouncementSchema } from './schemas/announcement.schema';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        MongooseModule.forFeature([{ name: Announcement.name, schema: AnnouncementSchema }]),
        NotificationsModule,
        UsersModule,
    ],
    providers: [AnnouncementsService],
    controllers: [AnnouncementsController],
})
export class AnnouncementsModule { }
