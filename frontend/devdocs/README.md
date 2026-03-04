# 📱 Shiftly – Frontend Developer Guide

> Dành cho người mới bắt đầu với **Flutter**. Đọc từ trên xuống dưới.

---

## 🗂 Mục lục

1. [Tổng quan](#tổng-quan)
2. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
3. [Kiến trúc ứng dụng](#kiến-trúc-ứng-dụng)
4. [Hệ thống phân quyền](#hệ-thống-phân-quyền)
5. [Các màn hình chính](#các-màn-hình-chính)
6. [Quản lý trạng thái – Cubit/BLoC](#quản-lý-trạng-thái--cubitbloc)
7. [Dependency Injection – GetIt](#dependency-injection--getit)
8. [Điều hướng – AutoRoute](#điều-hướng--autoroute)
9. [Gọi API – Repository Pattern](#gọi-api--repository-pattern)
10. [Luồng hoạt động chính](#luồng-hoạt-động-chính)
11. [Chạy ứng dụng](#chạy-ứng-dụng)

---

## Tổng quan

**Shiftly** là ứng dụng quản lý lịch nghỉ cho nhân viên và intern. Frontend được viết bằng **Flutter** (Dart), giao tiếp với backend NestJS qua REST API.

### Công nghệ sử dụng

| Thư viện | Mục đích |
|---|---|
| `flutter_bloc` | Quản lý trạng thái (Cubit pattern) |
| `get_it` + `injectable` | Dependency Injection |
| `auto_route` | Điều hướng màn hình |
| `dio` | Gọi HTTP API |
| `freezed` | Tạo immutable data class |
| `table_calendar` | Hiển thị lịch |
| `intl` | Định dạng ngày tháng |

---

## Cấu trúc thư mục

```
frontend/lib/
├── main.dart                    # Điểm khởi đầu ứng dụng
├── app.dart                     # MaterialApp + Router setup
├── data/
│   ├── constant/
│   │   └── enums.dart           # Định nghĩa các enum (UserRole, RequestStatus, ...)
│   ├── model/                   # Data models (Freezed)
│   │   ├── user_model.dart
│   │   ├── schedule_request_model.dart
│   │   └── notification_model.dart
│   ├── repo/                    # Abstract interfaces cho API calls
│   │   ├── auth_repo.dart
│   │   ├── schedule_request_repo.dart
│   │   └── notification_repo.dart
│   └── service/
│       └── auth_service.dart    # Lưu thông tin user đang đăng nhập
├── resource/
│   └── app_strings.dart         # Toàn bộ chuỗi văn bản trong app
└── ui/
    ├── cubit/
    │   └── base_cubit.dart      # BaseCubit dùng chung cho mọi Cubit
    ├── di/
    │   ├── di_config.dart       # Khởi tạo GetIt
    │   └── di_config.config.dart # Tự sinh bởi injectable (KHÔNG sửa tay)
    ├── router/
    │   ├── app_router.dart      # Định nghĩa routes
    │   └── app_router.gr.dart   # Tự sinh bởi auto_route (KHÔNG sửa tay)
    └── screens/
        ├── login/               # Màn hình đăng nhập
        ├── main/                # Shell chứa bottom navigation bar
        ├── home/                # Trang chủ (thống kê nhanh)
        ├── schedule/            # Xem lịch (calendar view)
        ├── schedule_form/       # Form đăng ký lịch nghỉ
        ├── status/              # Intern: xem trạng thái request của mình
        ├── manager/             # Manager/HR: duyệt request
        ├── notifications/       # Màn hình thông báo
        └── profile/             # Thông tin cá nhân
```

---

## Kiến trúc ứng dụng

Ứng dụng theo mô hình **Clean Architecture** đơn giản hóa:

```
UI (Widgets)
    ↕
Cubit (Business Logic)
    ↕
Repository (abstract interface)
    ↕
Repository Impl (gọi API thực tế qua Dio)
    ↕
Backend NestJS API
```

### Luồng dữ liệu điển hình:

1. Widget gọi `context.read<MyCubit>().doSomething()`
2. Cubit gọi `_repo.fetchData()`
3. Repo Impl gọi `dio.get('/api/endpoint')`
4. Kết quả trả về, Cubit `emit()` state mới
5. Widget `BlocBuilder` rebuild với data mới

---

## Hệ thống phân quyền

Có 3 role chính, được định nghĩa trong `enums.dart`:

```dart
enum UserRole { INTERN, EMPLOYEE, MANAGER, HR }
```

| Role | Quyền hạn |
|---|---|
| **INTERN / EMPLOYEE** | Đăng ký lịch nghỉ, xem trạng thái request của mình |
| **MANAGER** | Xem tất cả request, duyệt/từ chối request |
| **HR** | Xem tất cả request và lịch (read-only, không duyệt) |

Role được lưu trong `AuthService` sau khi đăng nhập:

```dart
final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
final isManagerOrHR = role == UserRole.MANAGER || role == UserRole.HR;
```

Bottom navigation bar thay đổi theo role (xem `main_page.dart`).

---

## Các màn hình chính

### 1. `LoginPage` – Đăng nhập
- Nhập email + password → gọi `AuthRepo.login()`
- Lưu token vào `AuthService`
- Navigate đến `MainPage`

### 2. `MainPage` – Shell điều hướng
- Chứa `IndexedStack` để giữ state của từng tab
- Bottom navigation bar khác nhau theo role
- Khởi tạo `HomeCubit.loadData()` khi mở app

### 3. `HomePage` – Trang chủ
- Hiển thị: lịch hôm nay, quick actions, số request đang chờ
- Badge chuông = unread notifications + pending count (cho manager)
- Intern: pending count = số request của mình chờ duyệt
- Manager/HR: pending count = tổng request chờ duyệt của toàn bộ nhân viên

### 4. `SchedulePage` – Lịch
- **Tab "Nghỉ định kỳ"**: Week view, mỗi ô hiển thị số người có lịch ngày đó
- **Tab "Nghỉ đột xuất"**: Month view với dot markers
- Bấm vào ngày → xem danh sách lịch bên dưới
- Manager/HR thấy toàn bộ nhân viên; Intern chỉ thấy lịch của mình

### 5. `ScheduleFormPage` – Đăng ký lịch nghỉ (chỉ INTERN)
- **Định kỳ**: chọn khoảng thời gian + các thứ trong tuần
- **Đột xuất**: chọn nhiều ngày cụ thể
- Sau khi submit → tự động refresh HomeCubit (cập nhật badge)

### 6. `StatusPage` – Trạng thái request (chỉ INTERN)
- 3 tabs: Pending / Approved / Rejected
- Có thể xóa request đang PENDING
- Xóa xong → tự động refresh HomeCubit

### 7. `ManagerRequestPage` – Duyệt request (MANAGER/HR)
- **Manager**: chỉ thấy PENDING, có nút Duyệt/Từ chối
- **HR**: xem tất cả status (read-only)
- Hỗ trợ duyệt/từ chối theo nhóm (batch bằng `groupId`)
- Duyệt/từ chối xong → tự động refresh HomeCubit

### 8. `NotificationPage` – Thông báo (giống Facebook)
- **Manager/HR**: thấy danh sách request đang chờ duyệt ở đầu trang
  - Mỗi card hiển thị tên nhân viên, loại request, thời gian
  - Bấm → chuyển đến `ManagerRequestPage`
- **Intern**: thấy thông báo approved/rejected
  - Bấm → chuyển về tab Status
- Pull-to-refresh để tải lại

---

## Quản lý trạng thái – Cubit/BLoC

### BaseCubit

Tất cả cubit kế thừa từ `BaseCubit`:

```dart
class BaseCubit<S> extends Cubit<S> {
  void setLoading() { /* emit loading state */ }
  void setSuccess() { /* emit success state */ }
  void setError(String msg) { /* emit error state */ }
}
```

### Ví dụ: HomeCubit

```dart
// Tạo instance: getIt<HomeCubit>() (lazySingleton – tạo 1 lần duy nhất)
@lazySingleton
class HomeCubit extends BaseCubit<HomeState> {
  Future<void> loadData() async {
    setLoading();
    // ... fetch data
    emit(state.copyWith(pendingCount: pending, ...));
  }
}
```

### Cách dùng trong Widget

```dart
// Đọc state
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    return Text('Pending: ${state.pendingCount}');
  },
)

// Gọi action
context.read<HomeCubit>().loadData();

// Dùng getIt để gọi outside context
getIt<HomeCubit>().loadData();
```

### State dùng Freezed

```dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(BaseStatus.initial) BaseStatus status,
    @Default(0) int pendingCount,
    // ...
  }) = _HomeState;
}
```

> Sau khi sửa class Freezed, cần chạy: `dart run build_runner build`

---

## Dependency Injection – GetIt

GetIt là service locator: đăng ký dependencies một lần, lấy ra bất cứ đâu.

### Đăng ký dependency

```dart
// Singleton (tạo 1 lần, dùng mãi):
@lazySingleton
class HomeCubit extends BaseCubit<HomeState> { ... }

// Transient (tạo mới mỗi lần gọi getIt<>):
@injectable
class ScheduleFormCubit extends BaseCubit<ScheduleFormState> { ... }
```

### Lấy dependency

```dart
final cubit = getIt<HomeCubit>();
final authService = getIt<AuthService>();
```

### Sau khi thêm/sửa dependency

```bash
dart run build_runner build --delete-conflicting-outputs
```

File `di_config.config.dart` sẽ được tự động cập nhật.

---

## Điều hướng – AutoRoute

### Định nghĩa route

File `app_router.dart`:
```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: MainRoute.page),
    AutoRoute(page: NotificationRoute.page),
    // ...
  ];
}
```

### Điều hướng

```dart
// Push màn hình mới (có thể back về)
context.router.push(const NotificationRoute());
context.pushRoute(const NotificationRoute()); // shorthand

// Replace (không back về)
context.router.replace(const MainRoute());

// Back về root
context.router.popUntilRoot();

// Truyền tham số
context.router.push(ScheduleFormRoute(isInitialRecurring: true));
```

> Sau khi thêm/sửa route, cần chạy: `dart run build_runner build`

---

## Gọi API – Repository Pattern

### Abstract interface

```dart
// lib/data/repo/schedule_request_repo.dart
abstract class ScheduleRequestRepo {
  Future<List<ScheduleRequestModel>> getMySchedules();
  Future<void> updateStatus(String id, String status);
  // ...
}
```

### Implementation

```dart
// lib/data/repo/schedule_repo_impl.dart
@Injectable(as: ScheduleRequestRepo)
class ScheduleRepoImpl implements ScheduleRequestRepo {
  final Dio _dio;
  
  @override
  Future<List<ScheduleRequestModel>> getMySchedules() async {
    final res = await _dio.get('/schedules/my');
    return (res.data as List)
        .map((e) => ScheduleRequestModel.fromJson(e))
        .toList();
  }
}
```

### Trong Cubit

```dart
class StatusCubit extends BaseCubit<StatusState> {
  final ScheduleRequestRepo _scheduleRepo; // inject qua constructor
  
  Future<void> loadRequests() async {
    final res = await _scheduleRepo.getMySchedules();
    emit(state.copyWith(requests: res));
  }
}
```

---

## Luồng hoạt động chính

### Intern đăng ký nghỉ:
```
HomePage → FAB/QuickAction
  → ScheduleFormPage (chọn loại, ngày, ca)
  → submit() → ScheduleRequestRepo.createSchedule()
  → HomeCubit.loadData() [auto refresh badge]
  → Navigate back
```

### Manager duyệt request:
```
NotificationPage (thấy pending card)
  → tap → ManagerRequestPage
  → approveBatch() / rejectBatch()
  → HomeCubit.loadData() [auto refresh badge]
  → Notification được gửi đến Intern
```

### Intern nhận thông báo:
```
Badge 🔔 xuất hiện (unread count)
  → tap chuông → NotificationPage
  → tap thông báo → markAsRead() + navigate về StatusPage
```

---

## Chạy ứng dụng

### Yêu cầu
- Flutter SDK >= 3.x
- Dart SDK >= 3.x
- Android Studio / VS Code với Flutter extension
- Backend đang chạy (xem `backend/devdocs/README.md`)

### Cài dependencies

```bash
cd frontend
flutter pub get
```

### Sinh code tự động (Freezed, Injectable, AutoRoute)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Chạy app

```bash
flutter run
```

### Cấu hình API base URL

Tìm file cấu hình Dio (thường trong `di_config.config.dart` hoặc repo impl):
```dart
// Đổi thành địa chỉ backend của bạn
const baseUrl = 'http://localhost:3000';
// Trên thiết bị Android emulator:
const baseUrl = 'http://10.0.2.2:3000';
// Trên thiết bị thật:
const baseUrl = 'http://<IP_máy_tính>:3000';
```

### Build release APK

```bash
flutter build apk --release
```

---

## ⚠️ Lưu ý quan trọng

- Sau khi sửa bất kỳ file `*.dart` có annotation `@freezed`, `@injectable`, `@RoutePage` → **phải** chạy lại `build_runner`
- Không sửa tay các file `*.freezed.dart`, `*.g.dart`, `app_router.gr.dart`, `di_config.config.dart`
- `HomeCubit` là `@lazySingleton` – tức là toàn app chỉ có 1 instance, dùng `getIt<HomeCubit>()` từ bất cứ đâu để cập nhật badge
