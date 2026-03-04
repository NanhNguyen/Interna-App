# 📱 Màn hình 8: `NotificationPage` – Thông báo

**File:** `lib/ui/screens/notifications/notification_page.dart`  
**Loại widget:** `StatefulWidget`  
**State manager:** `BlocProvider.value` (dùng lại `NotificationCubit` từ `MainPage`) + `BlocBuilder`  
**Thư viện:** `intl` (DateFormat để format thời gian), `auto_route`  
**Route:** Push từ icon chuông trong AppBar của `HomePage`

---

## Cấu trúc cây widget

```
BlocProvider.value<NotificationCubit>
└── Scaffold (backgroundColor: Color(0xFFF0F2F5) – xám Facebook)
    ├── AppBar (backgroundColor: blue)
    └── body: BlocBuilder<NotificationCubit, NotificationState>
        └── RefreshIndicator
            └── CustomScrollView (physics: AlwaysScrollableScrollPhysics)
                └── slivers: [
                    // ── CHỈ MANAGER/HR ──
                    SliverToBoxAdapter (header "Yêu cầu chờ duyệt" + badge count),
                    SliverList (pending group cards → _buildPendingGroupCard),
                    SliverToBoxAdapter (SizedBox spacing),

                    // ── TẤT CẢ ROLE ──
                    SliverToBoxAdapter (header "Thông báo"),
                    SliverList (notification cards → _buildNotificationCard),
                    SliverToBoxAdapter (SizedBox padding cuối trang),
                ]
```

---

## Tại sao dùng `CustomScrollView` + Slivers?

`CustomScrollView` cho phép kết hợp nhiều loại content (header tĩnh, list động) trong cùng 1 scroll view:

- `SliverToBoxAdapter` – wrap widget thông thường (Text, Container) để đặt vào trong sliver scroll
- `SliverList` – list động dùng `SliverChildBuilderDelegate` để lazy build từng item

Nếu dùng `Column + ListView` lồng nhau sẽ gặp lỗi **infinite height**. Slivers giải quyết triệt để vấn đề này.

---

## Chi tiết từng widget

### `AppBar`
- `title: Text(AppStrings.notifications)` – "Thông báo", bold
- `backgroundColor: Colors.blue`
- `foregroundColor: Colors.white` – màu title và back button
- `elevation: 0.5` – bóng nhẹ phân cách với content

### `RefreshIndicator`
- `onRefresh: _onRefresh()` – gọi đồng thời:
  - `_loadPendingIfManager()` → reload pending requests nếu là MANAGER/HR
  - `notifCubit.loadNotifications()` → reload danh sách thông báo

### `SliverList`
- `delegate: SliverChildBuilderDelegate(builder, childCount: n)`
  - `builder`: hàm trả về widget cho mỗi index
  - `childCount`: tổng số item cần render

### Khởi tạo trong `initState`
```dart
_notifCubit = getIt<NotificationCubit>()
  ..loadNotifications().then((_) {
    _notifCubit.markAllAsRead();    // đánh dấu tất cả đã đọc
    getIt<HomeCubit>().loadData();  // cập nhật badge số thông báo trên Home
  });
_loadPendingIfManager();            // load pending request nếu MANAGER/HR
```

---

## Widget con: `_buildPendingGroupCard` – Pending card (Manager/HR)

Card hiển thị 1 nhóm request đang chờ duyệt, có avatar chữ cái:

```dart
Container(
  margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: 16,
    boxShadow: [BoxShadow(black.04%, blurRadius: 8, offset: Offset(0, 2))],
  ),
  child: Material(   // cần Material để InkWell có ripple effect
    color: Colors.transparent,
    borderRadius: 16,
    child: InkWell(
      onTap: () => _navigateToUserRequests(context, first, role),
      child: Padding(16, Row([
        Stack([
          CircleAvatar(radius: 28, text: avatarLetter),
          Positioned(bottom: 0, right: 0,  // badge cam pending ở góc avatar
            child: Container(20x20, circle, orange, border: white 2px,
              child: Icon(pending_actions, size: 10))),
        ]),
        SizedBox(width: 14),
        Expanded > Column([
          RichText(TextSpan([bold(userName), normal(description)])),
          Text('Ca: ${shift}  •  $timeAgo', orange.700, fontSize: 12.5, w600),
        ]),
        Icon(chevron_right, grey),
      ])),
    ),
  ),
)
```

> **Tại sao dùng `Material` + `InkWell` thay vì `InkWell` trực tiếp lên `Container`?**  
> `InkWell` cần nền `Material` mới render được ripple effect. Đặt thẳng lên `Container` sẽ không thấy hiệu ứng bấm.

### `CircleAvatar` – Avatar chữ cái
- `radius: 28`
- `backgroundColor: Colors.blue.shade100` – nền xanh nhạt
- `child: Text(avatarLetter, fontSize: 20, bold, color: blue.700)` – chữ cái đầu tên nhân viên

### `RichText` + `TextSpan` – Text ghép nhiều style
- Cấu trúc:
  ```dart
  RichText(text: TextSpan(
    children: [
      TextSpan(text: userName, style: TextStyle(bold, color: black)),
      TextSpan(text: description),   // style mặc định: black87, fontSize 14.5
    ],
  ))
  ```
- Giúp in đậm tên nhân viên trong câu mô tả mà không cần tách thành nhiều `Text` widget riêng

---

## Widget con: `_buildNotificationCard` – Thông báo approved/rejected

```dart
Container(
  margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
  decoration: BoxDecoration(
    color: isUnread ? Color(0xFFE7F3FF) : Colors.white,  // xanh nhạt nếu chưa đọc
    borderRadius: 16,
    boxShadow: [BoxShadow(black.04%, blurRadius: 6)],
  ),
  child: Material > InkWell(
    onTap: () {
      if (isUnread) { markAsRead(id); HomeCubit.loadData(); }
      // MANAGER/HR → push ManagerRequestRoute
      // INTERN    → setIndex(2) + popUntilRoot (về tab Status)
    },
    child: Padding(14, Row([
      Container(46x46, circle, color: iconColor.12%, child: Icon(iconData, iconColor)),
      SizedBox(12),
      Expanded > Column([
        Text(title, bold nếu unread, fontSize: 14.5),
        Text(message, maxLines: 2, ellipsis, grey.600, fontSize: 13),
        Text(timeAgo, color: blue.600 (unread) / grey.400 (read), fontSize: 12),
      ]),
      if (isUnread) Container(10x10, circle, color: Color(0xFF1877F2)),  // chấm xanh báo chưa đọc
    ])),
  ),
)
```

**Icon và màu theo loại thông báo:**
- `REQUEST_CREATED` → `Icons.add_circle_outline`, màu `Colors.blue`
- `REQUEST_APPROVED` → `Icons.check_circle_outline`, màu `Colors.green`
- `REQUEST_REJECTED` → `Icons.cancel_outlined`, màu `Colors.red`
- Mặc định → `Icons.notifications_outlined`, màu `Colors.grey`

**Màu background theo trạng thái đọc:**
- Chưa đọc → `Color(0xFFE7F3FF)` xanh nhạt (giống Facebook Messenger)
- Đã đọc → `Colors.white`

---

## `_formatTimeAgo` – Format thời gian

```dart
String _formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1)  return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24)   return '${diff.inHours} giờ trước';
  if (diff.inDays < 7)     return '${diff.inDays} ngày trước';
  return DateFormat('dd/MM/yyyy').format(dateTime);  // dùng package intl
}
```

---

## File liên quan

- `notifications/cubit/notification_cubit.dart` – `loadNotifications`, `markAsRead`, `markAllAsRead`
- `notifications/cubit/notification_state.dart` – state: `notifications`, `status`
- `data/model/notification_model.dart` – model: `id`, `title`, `message`, `type`, `isRead`, `createdAt`
- `home/cubit/home_cubit.dart` – `loadData()` gọi sau khi đánh dấu đã đọc để cập nhật badge
