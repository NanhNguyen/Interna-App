# 📱 Màn hình 3: `HomePage` – Trang chủ

**File:** `lib/ui/screens/home/home_page.dart`  
**Loại widget:** `StatelessWidget`  
**State manager:** `BlocBuilder<HomeCubit, HomeState>`  
**Route:** Không route riêng – nhúng vào `IndexedStack` của `MainPage`

---

## Cấu trúc cây widget

```
BlocBuilder<HomeCubit, HomeState>
└── Scaffold
    ├── AppBar
    │   └── actions: [Stack(🔔 + badge), SizedBox]
    ├── body: RefreshIndicator
    │   └── SingleChildScrollView
    │       └── Column
    │           ├── _buildHeader(name)
    │           ├── _buildTodayStatus(todaySchedule)
    │           ├── _buildQuickActions(context)
    │           ├── _buildQuickStats(state)
    │           └── Text ("Cập nhật gần đây")
    └── floatingActionButton: FloatingActionButton (chỉ INTERN)
```

---

## Chi tiết từng widget

### `AppBar`
- `title: Text(AppStrings.scheduleOverview)` – "Tổng quan lịch"
- `actions`: chứa `Stack` (icon chuông + badge) và `SizedBox(width: 10)`

### `Stack` + `Positioned` – Notification badge
Kỹ thuật đặt số badge đỏ lên trên icon chuông:

```dart
Stack(
  children: [
    IconButton(
      icon: Icon(Icons.notifications_none, size: 32),
      onPressed: () => context.pushRoute(const NotificationRoute()),
    ),
    Builder(builder: (context) {
      // Badge logic:
      // - INTERN: chỉ tính unreadNotificationCount
      // - MANAGER/HR: tính thêm pendingCount (số request chờ duyệt)
      final totalBadge = state.unreadNotificationCount
                       + (isManagerOrHR ? state.pendingCount : 0);
      if (totalBadge > 0) {
        return Positioned(
          right: 8, top: 8,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: 10),
            constraints: BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text('$totalBadge', style: TextStyle(color: white, fontSize: 10, bold)),
          ),
        );
      }
      return SizedBox.shrink(); // ẩn nếu = 0
    }),
  ],
)
```

### `RefreshIndicator`
- `onRefresh: () => context.read<HomeCubit>().loadData()` – pull xuống để reload toàn bộ dữ liệu
- Wrap `SingleChildScrollView` để kéo được dù content ngắn

### `SingleChildScrollView`
- `physics: AlwaysScrollableScrollPhysics()` – bắt buộc scroll dù content không đầy màn hình
  → **cần thiết** để `RefreshIndicator` luôn hoạt động

### `FloatingActionButton` – Chỉ INTERN/EMPLOYEE
- `backgroundColor: Colors.blue.shade700`
- `foregroundColor: Colors.white`
- `child: Icon(Icons.add)`
- `onPressed`: mở `showModalBottomSheet` với menu chọn loại nghỉ
- MANAGER và HR không có FAB (code trả về `null`)

### `showModalBottomSheet` – Menu chọn loại nghỉ
- `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))` – bo góc trên
- `builder`: trả về `Container > Column` chứa 2 `ListTile`

#### `ListTile` – Nghỉ định kỳ
- `leading: Icon(Icons.repeat, color: Colors.blue)`
- `title: Text(AppStrings.recurringLeave)` – "Nghỉ định kỳ"
- `onTap`: đóng sheet → `router.push(ScheduleFormRoute(isInitialRecurring: true))`

#### `ListTile` – Nghỉ đột xuất
- `leading: Icon(Icons.event, color: Colors.orange)`
- `title: Text(AppStrings.adhocLeave)` – "Nghỉ đột xuất"
- `onTap`: đóng sheet → `router.push(ScheduleFormRoute(isInitialRecurring: false))`

---

## Widget con: `_buildHeader`

Card chào mừng ở đầu trang, bo góc 2 phía dưới:

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(32),
      bottomRight: Radius.circular(32),
    ),
    boxShadow: [BoxShadow(color: black.05%, offset: Offset(0, 4), blurRadius: 20)],
  ),
  child: Column([
    Text('Chào mừng trở lại',   // fontSize: 18, w500, color: #444444
    Text(userName,               // fontSize: 36, w900, letterSpacing: -0.5
  ]),
)
```

---

## Widget con: `_buildTodayStatus`

Chỉ hiện khi `state.todaySchedule != null`. Hiển thị trạng thái làm việc hôm nay:

- Nền là `Container` với `LinearGradient` xanh nhạt (0.15 → 0.05 opacity)
- Bo góc `BorderRadius.circular(24)`, có viền xanh nhạt
- Bên trong là `Row` gồm:
  - Vòng tròn icon: `Container(BoxShape.circle)` với `padding: 12`
    - Icon: `Icons.beach_access` nếu đang nghỉ, `Icons.work` nếu đi làm
  - Cột text:
    - Dòng trên: `"ĐANG NGHỈ"` hoặc `"ĐANG ĐI LÀM"` (fontSize: 14, letterSpacing: 1.2)
    - Dòng dưới: `"Nghỉ phép"` hoặc `"Ca: ${shift}"` (fontSize: 22, bold)

---

## Widget con: `_buildActionItem`

Mỗi nút quick action gồm icon tròn + label bên dưới:

```dart
// params: label, icon, color, tabIndex?, onTap?
Column([
  InkWell(
    onTap: onTap ?? () => context.read<MainCubit>().setIndex(tabIndex),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 34),
    ),
  ),
  SizedBox(height: 10),
  Text(label, fontSize: 14, w600),
])
```

**Quick Actions theo role:**
- **INTERN/EMPLOYEE**:
  - "Nghỉ định kỳ" (`Icons.repeat`, xanh) → push `ScheduleFormRoute(isInitialRecurring: true)`
  - "Nghỉ đột xuất" (`Icons.event_note`, cam) → push `ScheduleFormRoute(isInitialRecurring: false)`
  - "Hồ sơ" (`Icons.person`, xanh lá) → `MainCubit.setIndex(3)`
- **MANAGER/HR**:
  - "Yêu cầu" (`Icons.pending_actions`, cam) → `MainCubit.setIndex(1)`
  - "Lịch" (`Icons.calendar_month`, xanh) → `MainCubit.setIndex(2)`
  - "Hồ sơ" (`Icons.person`, xanh lá) → `MainCubit.setIndex(3)`

---

## Widget con: `_buildStatCard`

2 card thống kê đặt cạnh nhau mỗi `Expanded` chiếm 50% ngang:

```dart
Expanded(
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column([
      Text(value,  fontSize: 32, bold, color: color),   // con số lớn
      SizedBox(height: 4),
      Text(label,  fontSize: 16, w500, color: color.80%), // nhãn nhỏ hơn
    ]),
  ),
)
```

- Card trái: `state.pendingCount` → "Đang chờ" (màu cam)
- Card phải: `state.totalCount` → "Tổng cộng" (màu xanh)

---

## File liên quan

- `home/cubit/home_cubit.dart` – load `pendingCount`, `totalCount`, `todaySchedule`, `unreadNotificationCount`
- `home/cubit/home_state.dart` – state: `user`, `pendingCount`, `totalCount`, `todaySchedule`, `unreadNotificationCount`
