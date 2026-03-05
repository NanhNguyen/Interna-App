# ShiftFlow - Ứng Dụng Quản Lý Lịch Trình

ShiftFlow là một ứng dụng quản lý lịch trình toàn diện dành cho thực tập sinh và quản lý. Ứng dụng cho phép đăng ký ca làm việc và yêu cầu nghỉ phép một cách dễ dàng, cùng với quy trình phê duyệt tinh gọn cho quản lý.

## Cấu Trúc Dự Án

Đây là một monorepo chứa cả backend và frontend:

- `/backend`: Ứng dụng NestJS sử dụng Mongoose (MongoDB).
- `/frontend`: Ứng dụng Flutter cho Android, iOS và Web.

## Triển Khai trên Render

Để triển khai dự án này trên Render:

### Backend (NestJS)
1. Tạo một **Web Service** mới.
2. Kết nối với repository này.
3. Đặt **Root Directory** thành `backend`.
4. Đặt **Build Command** thành `npm install && npm run build`.
5. Đặt **Start Command** thành `node dist/main`.
6. Thêm các biến môi trường (ví dụ: `MONGO_URI`, `JWT_SECRET`).

### Frontend (Flutter Web - tùy chọn)
1. Tạo một **Static Site** mới.
2. Kết nối với repository này.
3. Đặt **Root Directory** thành `frontend`.
4. Đặt **Build Command** thành `flutter build web --release`.
5. Đặt **Publish Directory** thành `build/web`.

## Các Tính Năng Chính
- **Gom nhóm theo lô**: Các yêu cầu cho nhiều ngày được nhóm lại thành các mục dễ quản lý.
- **Số lượng nhân viên duy nhất**: Quản lý có thể xem chính xác số lượng người được xếp lịch theo từng ngày.
- **Truy cập dựa trên vai trò**: Giao diện chuyên biệt cho Thực tập sinh, Quản lý và Nhân sự.
- **Thông báo**: Thông báo thời gian thực về cập nhật trạng thái lịch trình và các yêu cầu mới.

## Tái cấu trúc thương hiệu
Ứng dụng gần đây đã được đổi tên từ "ShiftSync" thành **ShiftFlow**.
