---
name: document
description: Hướng dẫn toàn diện cho project Shiftly – dành cho người mới học Flutter và NestJS muốn vibe coding với AI. Dùng skill này khi cần hiểu cấu trúc project, cách thêm tính năng mới, debug lỗi, hoặc muốn giải thích bất kỳ phần code nào trong app.
---

# 📱 Shiftly – Hướng dẫn Project toàn diện

> **Dành cho ai?** Người mới học Flutter và NestJS, muốn **vibe coding** (code cùng AI)
> mà vẫn **hiểu được mình đang làm gì** thay vì chỉ copy-paste mù quáng.
>
> **Cách dùng skill này:** Khi bạn hỏi AI về project, AI sẽ đọc file này trước
> để hiểu rõ context – bạn sẽ nhận được câu trả lời chính xác hơn, phù hợp với
> code thực tế của mình hơn.

---

## 🗺️ Bức tranh toàn cảnh – App này làm gì?

**Shiftly** là app quản lý lịch nghỉ cho intern/nhân viên công ty.

```
                    ┌─────────────────────────────┐
                    │         SHIFTLY APP          │
                    └──────────────┬──────────────┘
                   ┌───────────────┴───────────────┐
           ┌───────▼──────┐               ┌────────▼────────┐
           │   Frontend   │               │    Backend      │
           │   Flutter    │◄─── HTTP ────►│    NestJS       │
           │  (ứng dụng   │               │   (máy chủ      │
           │   di động)   │               │    xử lý data)  │
           └──────────────┘               └─────────────────┘
```

**3 loại người dùng (role):**
- **INTERN / EMPLOYEE** – gửi request nghỉ, xem lịch của mình
- **MANAGER** – xem tất cả, duyệt hoặc từ chối request
- **HR** – xem tất cả nhưng không có quyền duyệt

---

## 📁 Cấu trúc thư mục – Mọi thứ nằm ở đâu?

```
Schedule Management For Intern/
├── frontend/                  ← App Flutter (người dùng thấy)
│   ├── lib/
│   │   ├── main.dart          ← Điểm khởi động app
│   │   ├── app.dart           ← Cấu hình routing chính
│   │   ├── data/              ← Tầng dữ liệu (gọi API, lưu trữ)
│   │   │   ├── api/           ← Cấu hình Dio (HTTP client)
│   │   │   ├── model/         ← Các kiểu dữ liệu (User, Schedule...)
│   │   │   ├── repo/          ← Repository (trung gian UI ↔ API)
│   │   │   ├── service/       ← AuthService (lưu token)
│   │   │   ├── constant/      ← Hằng số (role names...)
│   │   │   └── guard/         ← AuthGuard (check đăng nhập)
│   │   ├── ui/
│   │   │   └── screens/       ← Các màn hình
│   │   │       ├── login/
│   │   │       ├── main/      ← Shell navigation
│   │   │       ├── home/
│   │   │       ├── schedule/
│   │   │       ├── schedule_form/
│   │   │       ├── status/
│   │   │       ├── manager/
│   │   │       ├── notifications/
│   │   │       └── profile/
│   │   ├── foundation/        ← DI config, router config
│   │   └── resource/          ← AppStrings (chuỗi văn bản)
│   ├── devdocs/               ← Tài liệu kỹ thuật
│   │   ├── README.md          ← Tổng quan frontend
│   │   ├── 1.flutter_bloc.md  ← Giải thích flutter_bloc
│   │   ├── 2.get_it_injectable.md
│   │   ├── 3.auto_route.md
│   │   ├── 4.freezed.md
│   │   ├── 5.dio.md
│   │   ├── 6.table_calendar.md
│   │   └── widgets/           ← Docs từng màn hình (widget + argument)
│   └── pubspec.yaml           ← Danh sách thư viện Flutter
│
└── backend/                   ← Server NestJS
    └── src/
        ├── main.ts            ← Điểm khởi động server
        ├── app.module.ts      ← Module gốc
        ├── auth/              ← Đăng nhập, JWT, bảo mật
        ├── users/             ← Quản lý user
        ├── schedules/         ← Quản lý lịch nghỉ (core)
        └── notifications/     ← Thông báo
```

---

## 🧩 Kiến trúc Flutter – Frontend hoạt động như thế nào?

### Luồng dữ liệu (Data Flow)

Mỗi khi bạn bấm nút hoặc màn hình load lên, dữ liệu đi theo đường này:

```
UI Widget
   │ bấm nút / mount widget
   ▼
Cubit (logic layer)     ← đây là "bộ não" của từng màn hình
   │ gọi repository
   ▼
Repository              ← trung gian, không biết UI là gì
   │ gọi API
   ▼
Dio (HTTP Client)       ← gửi request thực sự lên server
   │
   ▼
NestJS Backend          ← server xử lý, trả về JSON
   │
   ▼ (response)
Repository → Cubit → UI tự động cập nhật
```

> **💡 Lý do tách như vậy:** Nếu ngày mai đổi API endpoint, chỉ cần sửa file trong `repo/`,
> không phải mở từng màn hình ra sửa. Cubit không biết API url là gì, UI không biết
> dữ liệu từ đâu về – mỗi tầng chỉ làm 1 việc.

### Mỗi màn hình thường có những file gì?

```
screens/home/
├── home_page.dart          ← Widget (chỉ xây dựng giao diện)
└── cubit/
    ├── home_cubit.dart     ← Logic (load data, xử lý event)
    └── home_state.dart     ← Trạng thái (loading, data, error)
```

**Quy tắc vàng:** `home_page.dart` **không được** gọi API trực tiếp. Nó chỉ được gọi `context.read<HomeCubit>().someMethod()` → để Cubit lo phần còn lại.

---

## 📚 Các thư viện quan trọng – Chúng làm gì?

### 1. `flutter_bloc` – Quản lý state

**State là gì?** Là tình trạng hiện tại của màn hình – đang loading? Có data? Lỗi?

```dart
// state_file.dart – định nghĩa "trạng thái có thể xảy ra"
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    UserModel? user,
    @Default(0) int pendingCount,
    String? errorMessage,
  }) = _HomeState;
}

// cubit_file.dart – logic thay đổi state
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo) : super(const HomeState());

  Future<void> loadData() async {
    emit(state.copyWith(status: HomeStatus.loading));  // → UI hiện loading
    try {
      final data = await _repo.getHomeData();
      emit(state.copyWith(status: HomeStatus.success, ...));  // → UI hiện data
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }
}

// page_file.dart – UI lắng nghe state và tự cập nhật
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    if (state.status == HomeStatus.loading) return CircularProgressIndicator();
    return Text(state.user?.name ?? '');
  },
)
```

**`BlocBuilder`** – rebuild UI mỗi khi state thay đổi  
**`BlocConsumer`** – vừa rebuild UI vừa có `listener` để chạy side-effect (navigate, snackbar)  
**`BlocProvider`** – cung cấp cubit xuống cây widget con

📖 Chi tiết: `devdocs/1.flutter_bloc.md`

---

### 2. `freezed` – Data class bất biến

**Vấn đề:** Dart không có built-in immutable class. `freezed` tạo tự động các phương thức `copyWith`, `==`, `toString`.

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

// Dùng:
final user = UserModel(id: '1', name: 'An', email: 'an@test.com', role: UserRole.intern);
final updatedUser = user.copyWith(name: 'Bình');  // tạo bản copy với name mới
```

📖 Chi tiết: `devdocs/4.freezed.md`

---

### 3. `get_it` + `injectable` – Dependency Injection

**Vấn đề:** Nếu `HomeCubit` cần `HomeRepo`, và `HomeRepo` cần `Dio`,
thì ai tạo ai? DI giải quyết bằng cách đăng ký một lần, dùng mọi nơi.

```dart
// Đăng ký:
@lazySingleton                  // chỉ tạo 1 instance duy nhất
class HomeRepo implements IHomeRepo { ... }

// Dùng ở bất kỳ đâu:
final repo = getIt<HomeRepo>(); // tự động inject đúng instance
```

📖 Chi tiết: `devdocs/2.get_it_injectable.md`

---

### 4. `auto_route` – Navigation

**Vấn đề:** Flutter có `Navigator.push()` nhưng không type-safe, dễ truyền sai tham số.

```dart
// Định nghĩa route 1 lần trong app_router.dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: MainRoute.page),
    AutoRoute(page: ScheduleFormRoute.page),  // có param isInitialRecurring
  ];
}

// Navigate:
context.router.replace(const MainRoute());             // thay thế màn hình hiện tại
context.pushRoute(ScheduleFormRoute(isInitialRecurring: true));  // push lên stack
context.router.maybePop(true);                         // pop nếu có thể
```

📖 Chi tiết: `devdocs/3.auto_route.md`

---

### 5. `dio` – HTTP Client

**Thay thế** cho `http` package mặc định, mạnh hơn nhiều:

```dart
// Cấu hình 1 lần trong data/api/
final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
dio.interceptors.add(AuthInterceptor());  // tự động đính token JWT

// Dùng trong repository:
final response = await _dio.get('/schedules/my');
final schedules = (response.data as List)
    .map((e) => ScheduleRequestModel.fromJson(e))
    .toList();
```

📖 Chi tiết: `devdocs/5.dio.md`

---

### 6. `table_calendar` – Widget lịch

Widget phức tạp nhất trong app. Xem chi tiết trong:
- `devdocs/6.table_calendar.md` – cách dùng thư viện
- `devdocs/widgets/04_schedule_page.md` – cách app này dùng cụ thể

---

## 🏗️ Kiến trúc NestJS – Backend hoạt động như thế nào?

### Luồng một request

```
Flutter gửi GET /schedules/my
          │
          ▼
     Controller          ← nhận request, validate input
     (schedules.controller.ts)
          │
          ▼
     Service             ← logic nghiệp vụ (ai được xem gì?)
     (schedules.service.ts)
          │
          ▼
     MongoDB Schema      ← đọc/ghi database
     (schemas/)
          │
          ▼ (response JSON)
     Flutter nhận và parse
```

### Cấu trúc mỗi module

```
schedules/
├── schedules.controller.ts  ← định nghĩa API endpoints (@Get, @Post, @Patch...)
├── schedules.service.ts     ← business logic
├── schedules.module.ts      ← kết nối controller + service + schema
└── schemas/
    └── schedule.schema.ts   ← cấu trúc document trong MongoDB
```

### Decorators quan trọng (NestJS)

```typescript
// Controller
@Controller('schedules')        // prefix URL: /schedules/...
@UseGuards(JwtAuthGuard)        // yêu cầu đăng nhập mới vào được
export class SchedulesController {

  @Get('my')                    // GET /schedules/my
  findMySchedules(@Request() req) {
    return this.service.findByUser(req.user.id);
  }

  @Post()                       // POST /schedules
  @Roles('INTERN', 'EMPLOYEE')  // chỉ intern/employee mới tạo được
  create(@Body() dto: CreateScheduleDto, @Request() req) {
    return this.service.create(dto, req.user);
  }

  @Patch('batch-approve/:groupId')  // PATCH /schedules/batch-approve/:groupId
  @Roles('MANAGER')                 // chỉ manager mới duyệt được
  approveBatch(@Param('groupId') groupId: string) {
    return this.service.approveBatch(groupId);
  }
}
```

### MongoDB Schema (dữ liệu trông như thế nào)

```typescript
@Schema()
export class Schedule {
  @Prop({ required: true })
  userId: string;             // ai đăng ký

  @Prop({ required: true })
  isRecurring: boolean;       // định kỳ (true) hay đột xuất (false)

  @Prop()
  weekday: string;            // 'MONDAY', 'TUESDAY'... (chỉ khi recurring)

  @Prop()
  startDate: Date;
  
  @Prop()
  endDate: Date;

  @Prop({ required: true })
  shift: string;              // 'Buổi sáng', 'Buổi chiều', 'Cả ngày'

  @Prop({ default: 'PENDING' })
  status: string;             // 'PENDING' | 'APPROVED' | 'REJECTED'

  @Prop()
  groupId: string;            // nhiều request cùng group (1 lần đăng ký nhiều thứ)
}
```

---

## 🔐 Authentication hoạt động thế nào?

```
1. User đăng nhập: POST /auth/login { email, password }
         │
         ▼
2. Server verify → trả về JWT token
         │
         ▼
3. Flutter lưu token vào FlutterSecureStorage (an toàn hơn SharedPreferences)
         │
         ▼
4. Mỗi request sau đó, Dio Interceptor tự động thêm:
   Authorization: Bearer <token>
         │
         ▼
5. Server đọc token → biết user là ai, role là gì
```

**File quan trọng:**
- `frontend/lib/data/service/auth_service.dart` – lưu/xóa token
- `frontend/lib/data/api/` – Dio interceptor đính token
- `backend/src/auth/` – JWT strategy, login endpoint

---

## 📋 Tài liệu UI từng màn hình

Chi tiết widget + argument ở `devdocs/widgets/`:

- `01_login_page.md` – Đăng nhập
- `02_main_page.md` – Shell navigation (BottomNavBar)
- `03_home_page.md` – Trang chủ (badge, FAB, stats)
- `04_schedule_page.md` – Xem lịch (TableCalendar, week/month view)
- `05_schedule_form_page.md` – Đăng ký nghỉ (form, date picker, chip)
- `06_status_page.md` – Trạng thái (ExpansionTile, tab)
- `07_manager_request_page.md` – Duyệt request (approve/reject)
- `08_notification_page.md` – Thông báo (Slivers, RichText)
- `09_profile_page.md` – Hồ sơ (AlertDialog, logout)

---

## 🛠️ Quy trình làm việc với AI (Vibe Coding Guide)

### Khi muốn thêm tính năng mới

**Bước 1 – Nói rõ bạn muốn gì và ở tầng nào:**
> ❌ "Thêm tính năng thống kê"
> ✅ "Thêm màn hình thống kê cho MANAGER hiển thị tổng số request mỗi tháng,
>    cần thêm API endpoint GET /schedules/stats và màn hình Flutter mới"

**Bước 2 – Hỏi AI giải thích trước khi code:**
> "Trước khi code, hãy giải thích cho tôi kế hoạch sẽ làm gì, tạo file nào,
>  sửa file nào, và tại sao?"

**Bước 3 – Code từng bước, hiểu từng bước:**
> "Chỉ làm bước 1 thôi, giải thích từng dòng để tôi hiểu"

---

### Pattern thêm màn hình mới (Frontend)

AI cần biết để tạo đúng pattern khi bạn yêu cầu thêm màn hình:

```
1. Tạo file state:    lib/ui/screens/[tên]/cubit/[tên]_state.dart
2. Tạo file cubit:    lib/ui/screens/[tên]/cubit/[tên]_cubit.dart
3. Tạo file page:     lib/ui/screens/[tên]/[tên]_page.dart
4. Thêm route:        lib/foundation/di_config/app_router.dart
5. Nếu cần API mới:   lib/data/repo/[tên]_repo.dart
```

---

### Pattern thêm API mới (Backend)

```
1. Thêm method vào:   src/[module]/[module].service.ts
2. Thêm endpoint vào: src/[module]/[module].controller.ts
3. Nếu cần schema:    src/[module]/schemas/[tên].schema.ts
```

---

### Câu hỏi hay để hỏi AI

**Hiểu code đang có:**
- "File `home_cubit.dart` làm gì? Giải thích từng method"
- "Tại sao `SchedulePage` dùng `StatefulWidget` thay vì `StatelessWidget`?"
- "Giải thích flow từ khi user bấm 'Duyệt' đến khi database được cập nhật"

**Khi gặp lỗi:**
- "Tôi gặp lỗi [paste lỗi ở đây], file liên quan là [tên file], hãy giải thích nguyên nhân và cách fix"
- "Widget rebuild quá nhiều lần, có thể do `BlocBuilder` không tối ưu không?"

**Khi thêm tính năng:**
- "Tôi muốn thêm [tính năng]. Hãy đề xuất kế hoạch theo kiến trúc hiện tại của project (đọc skill document để hiểu pattern)"
- "Tôi muốn thêm filter theo tháng cho SchedulePage, cần sửa những file nào?"

**Học khái niệm:**
- "Giải thích `BlocConsumer` vs `BlocBuilder` bằng ví dụ trong project này"
- "JWT hoạt động thế nào trong project này? Hiển thị bằng sơ đồ"

---

## ⚡ Chạy project

### Frontend (Flutter)
```bash
cd frontend
flutter pub get          # cài thư viện
flutter pub run build_runner build  # generate code (freezed, injectable, auto_route)
flutter run              # chạy app
```

### Backend (NestJS)
```bash
cd backend
npm install              # cài thư viện
npm run start:dev        # chạy server (port 3000, hot reload)
```

> **Lưu ý:** Backend cần MongoDB đang chạy. Xem file `backend/.env` để biết connection string.

---

## 🔍 Tra cứu nhanh – "Muốn sửa X thì mở file nào?"

- **Đổi màu, kích thước chữ trong màn hình** → `lib/ui/screens/[tên]/[tên]_page.dart`
- **Đổi chuỗi text (label, button, message)** → `lib/resource/app_strings.dart`
- **Thêm/sửa logic xử lý dữ liệu** → `lib/ui/screens/[tên]/cubit/[tên]_cubit.dart`
- **Thêm/sửa API endpoint** → `backend/src/[module]/[module].controller.ts`
- **Thêm/sửa business logic backend** → `backend/src/[module]/[module].service.ts`
- **Thêm route màn hình mới** → `lib/foundation/di_config/app_router.dart`
- **Thêm thư viện Flutter** → `frontend/pubspec.yaml` → chạy `flutter pub get`
- **Thêm package Node** → `backend/package.json` → chạy `npm install`
- **Sửa cấu trúc dữ liệu MongoDB** → `backend/src/[module]/schemas/`
- **Sửa model Flutter** → `lib/data/model/`
- **Sửa URL server** → `lib/data/api/` (tìm `baseUrl`)

---

## 🚨 Những lỗi thường gặp và cách fix

### Flutter: `Could not find the correct Provider`
→ Widget đang dùng `context.read<SomeCubit>()` nhưng `BlocProvider` chưa được đặt ở trên cây  
→ Kiểm tra xem `BlocProvider` đã wrap đúng chỗ chưa

### Flutter: `setState() called after dispose()`  
→ Đang gọi `setState` trong `async` function nhưng widget đã bị destroy  
→ Thêm `if (!mounted) return;` trước `setState`

### Flutter: Màn hình không cập nhật sau khi data thay đổi  
→ Cubit đang `emit` state giống hệt state trước (Equatable compare bằng nhau)  
→ Kiểm tra `copyWith` có thực sự tạo object mới không

### Flutter: `build_runner` lỗi sau khi sửa model  
→ Chạy `flutter pub run build_runner build --delete-conflicting-outputs`

### NestJS: `UnauthorizedException` khi gọi API  
→ Token JWT chưa được gửi, hoặc token hết hạn  
→ Kiểm tra header `Authorization: Bearer <token>` trong request

### NestJS: `Cannot read property of undefined`  
→ Thường do MongoDB document không có field đó  
→ Kiểm tra schema và kiểm tra `if (!doc) throw new NotFoundException()`

---

## 📖 Tài liệu thư viện chi tiết

| Tên thư viện | Vị trí tài liệu |
|---|---|
| `flutter_bloc` | `frontend/devdocs/1.flutter_bloc.md` |
| `get_it` + `injectable` | `frontend/devdocs/2.get_it_injectable.md` |
| `auto_route` | `frontend/devdocs/3.auto_route.md` |
| `freezed` | `frontend/devdocs/4.freezed.md` |
| `dio` | `frontend/devdocs/5.dio.md` |
| `table_calendar` | `frontend/devdocs/6.table_calendar.md` |
| Cấu trúc tổng quan | `frontend/devdocs/README.md` |
| Widget từng màn hình | `frontend/devdocs/widgets/` |
