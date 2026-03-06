import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ScheduleRequest, RequestStatus } from './schemas/schedule-request.schema';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { User, UserRole } from '../users/schemas/user.schema';

@Injectable()
export class SchedulesService {
    constructor(
        @InjectModel(ScheduleRequest.name)
        private scheduleRequestModel: Model<ScheduleRequest>,
        private notificationsService: NotificationsService,
        private usersService: UsersService,
    ) { }

    private async notifyManagers(employee: any, type: string) {
        if (!employee) return;

        let targetManagers: User[] = [];

        if (employee.managerId) {
            const directManager = await this.usersService.findById(employee.managerId.toString());
            if (directManager) {
                targetManagers.push(directManager);
            }
        } else {
            const allUsers = await this.usersService.findAll();
            targetManagers = allUsers.filter(u => u.role === UserRole.MANAGER);
        }

        const employeeName = employee.name || 'an employee';
        for (const manager of targetManagers) {
            await this.notificationsService.create(
                manager._id.toString(),
                'Yêu cầu mới',
                `${employeeName} vừa gửi lên lịch trình / xin nghỉ. Hãy duyệt ngay.`,
                type
            );
        }
    }

    async create(employee_id: string, data: any): Promise<ScheduleRequest> {
        const request = new this.scheduleRequestModel({
            ...data,
            employee_id,
        });
        const savedRequest = await request.save();

        // Notify Managers
        const employee = await this.usersService.findById(employee_id);
        await this.notifyManagers(employee, 'REQUEST_CREATED');

        return savedRequest;
    }

    async createMany(employee_id: string, requests: any[]): Promise<any> {
        const docs = requests.map(data => ({
            ...data,
            employee_id,
        }));
        const savedRequests = await this.scheduleRequestModel.insertMany(docs);

        // Notify Managers
        const employee = await this.usersService.findById(employee_id);
        await this.notifyManagers(employee, 'REQUEST_CREATED');

        return savedRequests;
    }

    async findAll(query: any = {}): Promise<ScheduleRequest[]> {
        return this.scheduleRequestModel.find(query).populate('employee_id', 'name role').exec();
    }

    async findByUser(employee_id: string): Promise<ScheduleRequest[]> {
        return this.scheduleRequestModel.find({ employee_id: employee_id as any }).populate('employee_id', 'name role').exec();
    }

    async updateStatus(id: string, status: RequestStatus, approvedBy: string): Promise<ScheduleRequest> {
        const request = await this.scheduleRequestModel.findByIdAndUpdate(
            id,
            { status, approvedBy },
            { new: true },
        ).populate('employee_id', 'name');

        if (!request) {
            throw new NotFoundException('Request not found');
        }

        // Notify Intern
        const title = status === RequestStatus.APPROVED ? 'Request Approved' : 'Request Rejected';
        const message = `Your schedule request has been ${status.toLowerCase()}.`;

        await this.notificationsService.create(
            (request.employee_id as any)._id.toString(),
            title,
            message,
            status === RequestStatus.APPROVED ? 'REQUEST_APPROVED' : 'REQUEST_REJECTED'
        );

        return request;
    }

    async updateBatchStatus(groupId: string, status: RequestStatus, approvedBy: string): Promise<any> {
        const result = await this.scheduleRequestModel.updateMany(
            { groupId },
            { status, approvedBy },
        );

        // Find one request to get employee_id
        const firstRequest = await this.scheduleRequestModel.findOne({ groupId });
        if (firstRequest) {
            const title = status === RequestStatus.APPROVED ? 'Request Approved' : 'Request Rejected';
            const message = `Your batch schedule request has been ${status.toLowerCase()}.`;

            await this.notificationsService.create(
                firstRequest.employee_id.toString(),
                title,
                message,
                status === RequestStatus.APPROVED ? 'REQUEST_APPROVED' : 'REQUEST_REJECTED'
            );
        }

        return result;
    }

    async remove(id: string, employee_id: string): Promise<any> {
        const result = await this.scheduleRequestModel.deleteOne({
            _id: id as any,
            employee_id: employee_id as any,
            status: RequestStatus.PENDING,
        } as any);
        if (result.deletedCount === 0) {
            throw new NotFoundException('Request not found or not in PENDING status');
        }
        return result;
    }

    async removeBatch(groupId: string, employee_id: string): Promise<any> {
        return this.scheduleRequestModel.deleteMany({
            groupId,
            employee_id: employee_id as any,
            status: RequestStatus.PENDING,
        } as any);
    }

    async findApproved(): Promise<ScheduleRequest[]> {
        return this.scheduleRequestModel.find({ status: RequestStatus.APPROVED }).populate('employee_id', 'name role').exec();
    }
}
