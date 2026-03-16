import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as MongooseSchema } from 'mongoose';

@Schema({ timestamps: true })
export class Announcement extends Document {
    @Prop({ type: MongooseSchema.Types.ObjectId, ref: 'User', required: true })
    authorId: any;

    @Prop({ required: true })
    authorName: string;

    @Prop({ required: true })
    title: string;

    @Prop({ required: true })
    content: string;

    // Số lượng người đã xem (giống Facebook: seen count)
    @Prop({ type: [MongooseSchema.Types.ObjectId], ref: 'User', default: [] })
    seenBy: any[];
}

export const AnnouncementSchema = SchemaFactory.createForClass(Announcement);
