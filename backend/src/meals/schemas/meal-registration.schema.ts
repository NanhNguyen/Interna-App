import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as MongooseSchema } from 'mongoose';

export enum MealShift {
    MORNING = 'MORNING',
    AFTERNOON = 'AFTERNOON',
    BOTH = 'BOTH',
}

export enum MealWeekday {
    MONDAY = 'MONDAY',
    TUESDAY = 'TUESDAY',
    WEDNESDAY = 'WEDNESDAY',
    THURSDAY = 'THURSDAY',
    FRIDAY = 'FRIDAY',
}

@Schema({ timestamps: true })
export class MealRegistration extends Document {
    @Prop({ type: MongooseSchema.Types.ObjectId, ref: 'User', required: true })
    userId: any;

    @Prop({ type: String, enum: MealShift, required: true })
    shift: MealShift;

    @Prop({ default: false })
    isRecurring: boolean;

    // Nếu isRecurring = true: danh sách các thứ lặp lại (MONDAY, TUESDAY...)
    @Prop({ type: [String], enum: MealWeekday, default: [] })
    weekdays: MealWeekday[];

    // Ngày bắt đầu hiệu lực
    @Prop({ required: true })
    startDate: Date;

    // Ngày kết thúc (nếu isRecurring, bắt buộc có endDate)
    @Prop()
    endDate: Date;

    // Nếu isRecurring = false: danh sách ngày cụ thể đặt cơm
    @Prop({ type: [Date], default: [] })
    specificDates: Date[];

    @Prop()
    note: string;
}

export const MealRegistrationSchema = SchemaFactory.createForClass(MealRegistration);
