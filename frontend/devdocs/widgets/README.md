# 🎨 UI Widgets – Tài liệu từng màn hình

> Mỗi file trong thư mục này mô tả chi tiết **thư viện**, **widget**, và **các argument**
> được sử dụng tại từng màn hình trong app **Shiftly**.

---

## 📦 Thư viện UI đang dùng

- **`flutter/material.dart`** (Flutter SDK) – Toàn bộ Material Design widget: Scaffold, AppBar, Card, Button, TextField, ...
- **`flutter/cupertino.dart`** (Flutter SDK) – Widget kiểu iOS, hiện chỉ dùng `CupertinoDatePicker` trong form lịch
- **`flutter_bloc ^9.1.0`** – Quản lý state theo pattern Cubit: `BlocProvider`, `BlocBuilder`, `BlocConsumer`, `MultiBlocProvider`
- **`table_calendar ^3.2.0`** – Widget lịch tháng/tuần có nhiều tính năng tùy chỉnh cao
- **`intl ^0.20.2`** – Định dạng ngày tháng (`DateFormat`) và hỗ trợ locale tiếng Việt
- **`auto_route ^9.2.2`** – Điều hướng có type-safe, dùng `context.router.push()`, `context.pushRoute()`
- **`google_fonts ^8.0.2`** – Custom font (hiện chưa áp dụng fonts cụ thể, dùng system default)

---

## 📂 Danh sách màn hình

- [01_login_page.md](./01_login_page.md) – `LoginPage` – Màn hình đăng nhập (tất cả role)
- [02_main_page.md](./02_main_page.md) – `MainPage` – Shell navigation + BottomNavigationBar (tất cả role)
- [03_home_page.md](./03_home_page.md) – `HomePage` – Trang chủ tổng quan (tất cả role)
- [04_schedule_page.md](./04_schedule_page.md) – `SchedulePage` – Xem lịch (tất cả role)
- [05_schedule_form_page.md](./05_schedule_form_page.md) – `ScheduleFormPage` – Đăng ký nghỉ (INTERN / EMPLOYEE)
- [06_status_page.md](./06_status_page.md) – `StatusPage` – Trạng thái request (INTERN / EMPLOYEE)
- [07_manager_request_page.md](./07_manager_request_page.md) – `ManagerRequestPage` – Duyệt request (MANAGER / HR)
- [08_notification_page.md](./08_notification_page.md) – `NotificationPage` – Thông báo (tất cả role)
- [09_profile_page.md](./09_profile_page.md) – `ProfilePage` – Hồ sơ cá nhân (tất cả role)

---

## 📊 Widget nào dùng ở màn hình nào

- **`BlocProvider`** → tất cả màn hình
- **`BlocBuilder`** → Home, Schedule, Status, Manager, Notification
- **`BlocConsumer`** → Login, ScheduleForm, Profile
- **`MultiBlocProvider`** → Main (shell)
- **`Scaffold` + `AppBar`** → tất cả màn hình
- **`TabBar` + `TabBarView` + `DefaultTabController`** → Schedule, Status, Manager (HR)
- **`TableCalendar`** → Schedule
- **`IndexedStack`** → Main (shell)
- **`BottomNavigationBar`** → Main (shell)
- **`RefreshIndicator`** → Home, Schedule, Status, Manager, Notification
- **`CustomScrollView` + Slivers** → Notification
- **`ListView.builder`** → Schedule (event list), Status, Manager
- **`FloatingActionButton`** → Home (chỉ INTERN/EMPLOYEE)
- **`showModalBottomSheet`** → Home (FAB menu), ScheduleForm (date picker)
- **`CupertinoDatePicker`** → ScheduleForm (chọn ngày recurring)
- **`showDatePicker`** → ScheduleForm (chọn ngày adhoc)
- **`FilterChip` + `Wrap`** → ScheduleForm (chọn thứ trong tuần)
- **`Chip` + `Wrap`** → ScheduleForm (ngày adhoc đã chọn), Manager (weekday chips)
- **`DropdownButtonFormField`** → ScheduleForm (chọn ca)
- **`ExpansionTile`** → Status (grouped requests)
- **`CircleAvatar`** → Notification, Manager
- **`RichText` + `TextSpan`** → Notification
- **`AlertDialog`** → Status (confirm xóa), Profile (đổi mật khẩu)
- **`SnackBar`** → Login (lỗi), ScheduleForm (submit), Manager (duyệt/từ chối), Profile
- **`CircularProgressIndicator`** → Login, ScheduleForm, Notification (loading state)
- **`Card`** → Schedule (event list), Status (grouped), Manager (requests)
- **`ListTile`** → Home (BottomSheet menu), Profile (options)
- **`Stack` + `Positioned`** → Home (notification badge), Notification (avatar badge)
- **`LinearGradient`** → Login (background), Home (header card), ScheduleForm (body)
- **`InkWell`** → Home (action items), Notification (cards), ScheduleForm (date card)
- **`GestureDetector`** → Schedule (bấm vào cell tuần)
