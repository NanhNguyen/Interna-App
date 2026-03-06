import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as MongooseSchema } from 'mongoose';
import { Role } from './role.schema';

export enum UserRole {
    INTERN = 'INTERN',
    EMPLOYEE = 'EMPLOYEE',
    MANAGER = 'MANAGER',
    HR = 'HR',
}

@Schema({ timestamps: true })
export class User extends Document {
    @Prop({ required: true, unique: true })
    email: string;

    @Prop({ required: true })
    password_hash: string;

    @Prop({ required: true })
    name: string;

    @Prop({ type: String, enum: UserRole, default: UserRole.INTERN })
    role: UserRole;

    @Prop({ type: MongooseSchema.Types.ObjectId, ref: 'Role' })
    role_id: any;

    @Prop()
    refreshToken: string;

    @Prop()
    avatarUrl: string;

    @Prop({ type: MongooseSchema.Types.ObjectId, ref: 'User' })
    managerId: any;
}

export const UserSchema = SchemaFactory.createForClass(User);
