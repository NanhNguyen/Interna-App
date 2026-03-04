# 📱 Màn hình 2: `MainPage` – Shell Navigation

**File:** `lib/ui/screens/main/main_page.dart`  
**Loại widget:** `StatefulWidget`  
**State manager:** `MultiBlocProvider` + `BlocBuilder<MainCubit>` + `BlocBuilder<NotificationCubit>`  
**Vai trò:** Shell bao toàn bộ app sau đăng nhập – chứa `BottomNavigationBar` và các tab page

---

## Cấu trúc cây widget

```
MultiBlocProvider
└── BlocBuilder<NotificationCubit, NotificationState>
    └── BlocBuilder<MainCubit, MainState>
        └── InAppNotificationOverlay (custom widget)
            └── Scaffold
                ├── body: IndexedStack
                │   └── [các page theo role]
                └── bottomNavigationBar: BottomNavigationBar
```

---

## Chi tiết từng widget

### `MultiBlocProvider`
- Inject 3 cubit xuống toàn bộ cây widget con:
  - `BlocProvider.value(value: _mainCubit)` – quản lý tab index hiện tại
  - `BlocProvider.value(value: _homeCubit)` – quản lý badge, pending count
  - `BlocProvider.value(value: _notifCubit)` – quản lý danh sách thông báo
- Dùng `BlocProvider.value` (không phải `BlocProvider`) vì các cubit đã được tạo sẵn trong `initState`,
  tránh bị dispose khi widget rebuild

### Khởi tạo trong `initState`
```dart
_mainCubit  = getIt<MainCubit>()..setIndex(0);          // luôn bắt đầu ở Home
_homeCubit  = getIt<HomeCubit>()..loadData();            // load badge ngay khi mở app
_notifCubit = getIt<NotificationCubit>()..loadNotifications();
```

### `IndexedStack`
- `index: state.currentIndex` – chỉ định tab nào đang hiện
- `children`: danh sách page theo role, tạo bởi `_getPagesForRole(userRole)`
- **Tại sao dùng `IndexedStack` thay `PageView`?**
  `IndexedStack` giữ nguyên toàn bộ widget tree và state của **tất cả** tab trong bộ nhớ.
  Khi switch tab, chỉ thay đổi visibility, không dispose/rebuild widget.
  Điều này giữ nguyên scroll position, dữ liệu đã load, trạng thái cubit của mỗi tab.

### Pages theo role

- **INTERN / EMPLOYEE**: `[HomePage, SchedulePage, StatusPage, ProfilePage]`
- **MANAGER**: `[HomePage, ManagerRequestPage, SchedulePage, ProfilePage]`
- **HR**: `[HomePage, ManagerRequestPage, SchedulePage, ProfilePage]`

### `BottomNavigationBar`
- `currentIndex: state.currentIndex` – tab đang active
- `onTap: (index)`:
  - Gọi `MainCubit.setIndex(index)` để đổi tab
  - Nếu switch sang tab Schedule → tự động gọi `ScheduleCubit.loadSchedules(userRole)` để reload lịch
- `type: BottomNavigationBarType.fixed` – hiện label cho **tất cả** item, không ẩn khi có nhiều tab
- `selectedItemColor`: màu tab active – khác nhau theo role:
  - INTERN/EMPLOYEE → `Colors.blue.shade700`
  - MANAGER → `Colors.deepPurple`
  - HR → `Colors.teal`
- `unselectedItemColor: Colors.grey`
- `iconSize: 30` – tăng so với mặc định 24
- `selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: bold)`
- `unselectedLabelStyle: TextStyle(fontSize: 13)`
- `items`: danh sách `BottomNavigationBarItem` tạo bởi `_getNavItemsForRole(userRole)`

### `BottomNavigationBarItem`
- `icon`: icon khi tab **chưa** active – dùng loại outline (ví dụ `Icons.home_outlined`)
- `activeIcon`: icon khi tab **đang** active – dùng loại filled (ví dụ `Icons.home`)
- `label`: chuỗi nhãn hiển thị dưới icon

#### Items theo role:

**INTERN / EMPLOYEE:**
- Tab 0: `home_outlined` / `home` → "Trang chủ"
- Tab 1: `calendar_month_outlined` / `calendar_month` → "Lịch"
- Tab 2: `assignment_outlined` / `assignment` → "Trạng thái"
- Tab 3: `person_outline` / `person` → "Hồ sơ"

**MANAGER:**
- Tab 0: `home_outlined` / `home` → "Trang chủ"
- Tab 1: `admin_panel_settings_outlined` / `admin_panel_settings` → "Quản lý"
- Tab 2: `calendar_month_outlined` / `calendar_month` → "Lịch nhân viên"
- Tab 3: `person_outline` / `person` → "Hồ sơ"

**HR:**
- Tab 0: `home_outlined` / `home` → "Trang chủ"
- Tab 1: `visibility_outlined` / `visibility` → "Xem tất cả"
- Tab 2: `calendar_month_outlined` / `calendar_month` → "Lịch nhân viên"
- Tab 3: `person_outline` / `person` → "Hồ sơ"

### `InAppNotificationOverlay` (custom widget)
- File: `main/widget/in_app_notification_banner.dart`
- Wrap ngoài `Scaffold` để hiện banner khi app đang mở mà có notification mới
- Nhận `notifications` và `unreadCount` từ `notifState`

---

## File liên quan

- `main/cubit/main_cubit.dart` – quản lý `currentIndex` (tab active)
- `main/cubit/main_state.dart` – state chứa `currentIndex`
- `main/widget/in_app_notification_banner.dart` – widget hiển thị banner thông báo in-app
- `home/cubit/home_cubit.dart` – được khởi tạo tại đây (lazySingleton)
- `notifications/cubit/notification_cubit.dart` – được khởi tạo tại đây (lazySingleton)
