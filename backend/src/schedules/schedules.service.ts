import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
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

    async findAll(user: any): Promise<ScheduleRequest[]> {
        const allRequests = await this.scheduleRequestModel.find().populate('employee_id', 'name role managerId').exec();
        const currentUserId = (user._id || user.id).toString();

        if (user.role === UserRole.HR) {
            // HR sees ALL Interns
            return allRequests.filter(req => {
                const owner = req.employee_id as any;
                return owner && owner.role === UserRole.INTERN;
            });
        }

        if (user.role === UserRole.MANAGER) {
            // Manager sees ONLY interns managed by them
            return allRequests.filter(req => {
                const owner = req.employee_id as any;
                if (!owner || owner.role !== UserRole.INTERN || !owner.managerId) return false;
                return owner.managerId.toString() === currentUserId;
            });
        }

        // Default: return user's own schedules
        return allRequests.filter(req => {
            const intern = req.employee_id as any;
            return intern && intern._id.toString() === currentUserId;
        });
    }

    async findByUser(employee_id: string): Promise<ScheduleRequest[]> {
        return this.scheduleRequestModel.find({ employee_id: employee_id as any }).populate('employee_id', 'name role').exec();
    }

    async updateStatus(id: string, status: RequestStatus, approvedById: string): Promise<ScheduleRequest> {
        const manager = await this.usersService.findById(approvedById);
        if (!manager) throw new NotFoundException('Manager not found');

        const request = await this.scheduleRequestModel.findById(id).populate('employee_id');
        if (!request) {
            throw new NotFoundException('Request not found');
        }

        // Authorization check: Manager must manage the intern
        if (manager.role === UserRole.MANAGER) {
            const intern = request.employee_id as any;

            console.log(`Checking permission for Manager: ${manager._id} (Name: ${manager.name})`);
            console.log(`Request Intern ID: ${intern._id} (Name: ${intern.name})`);
            console.log(`Intern assigned Manager ID: ${intern.managerId}`);

            const internManagerId = intern.managerId?.toString();
            const currentManagerId = manager._id.toString();

            if (!internManagerId || internManagerId !== currentManagerId) {
                console.warn(`Permission Denied: ${internManagerId} != ${currentManagerId}`);
                throw new ForbiddenException('Bạn không có quyền duyệt yêu cầu của thực tập sinh này.');
            }
        }

        request.status = status;
        request.approvedBy = approvedById as any;
        const savedRequest = await request.save();

        // Notify Intern
        const title = status === RequestStatus.APPROVED ? 'Request Approved' : 'Request Rejected';
        const message = `Yêu cầu lịch trình của bạn đã được ${status === RequestStatus.APPROVED ? 'chấp nhận' : 'từ chối'}.`;

        await this.notificationsService.create(
            (savedRequest.employee_id as any)._id.toString(),
            title,
            message,
            status === RequestStatus.APPROVED ? 'REQUEST_APPROVED' : 'REQUEST_REJECTED'
        );

        return savedRequest;
    }

    async updateBatchStatus(groupId: string, status: RequestStatus, approvedById: string): Promise<any> {
        const manager = await this.usersService.findById(approvedById);
        if (!manager) throw new NotFoundException('Manager not found');

        const firstRequest = await this.scheduleRequestModel.findOne({ groupId }).populate('employee_id');
        if (!firstRequest) {
            throw new NotFoundException('Request group not found');
        }

        // Authorization check
        if (manager.role === UserRole.MANAGER) {
            const intern = firstRequest.employee_id as any;
            const internManagerId = intern.managerId?.toString();
            const currentManagerId = manager._id.toString();

            if (!internManagerId || internManagerId !== currentManagerId) {
                throw new ForbiddenException('Bạn không có quyền duyệt yêu cầu của thực tập sinh này.');
            }
        }

        const result = await this.scheduleRequestModel.updateMany(
            { groupId },
            { status, approvedBy: approvedById as any },
        );

        const title = status === RequestStatus.APPROVED ? 'Batch Request Approved' : 'Batch Request Rejected';
        const message = `Yêu cầu đăng ký lịch hàng loạt của bạn đã được ${status === RequestStatus.APPROVED ? 'chấp nhận' : 'từ chối'}.`;

        await this.notificationsService.create(
            (firstRequest.employee_id as any)._id.toString(),
            title,
            message,
            status === RequestStatus.APPROVED ? 'REQUEST_APPROVED' : 'REQUEST_REJECTED'
        );

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

    async findApproved(user: any): Promise<ScheduleRequest[]> {
        const allApproved = await this.scheduleRequestModel.find({ status: RequestStatus.APPROVED }).populate('employee_id', 'name role managerId').exec();
        const currentUserId = (user._id || user.id).toString();

        if (user.role === UserRole.HR) {
            // HR sees ALL Interns
            return allApproved.filter(req => {
                const owner = req.employee_id as any;
                return owner && owner.role === UserRole.INTERN;
            });
        }

        if (user.role === UserRole.MANAGER) {
            // Manager sees ONLY interns managed by them
            return allApproved.filter(req => {
                const owner = req.employee_id as any;
                if (!owner || owner.role !== UserRole.INTERN || !owner.managerId) return false;
                return owner.managerId.toString() === currentUserId;
            });
        }

        // Default: return user's own approved schedules
        return allApproved.filter(req => {
            const intern = req.employee_id as any;
            return intern && intern._id.toString() === currentUserId;
        });
    }
}
