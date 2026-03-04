# 📱 Màn hình 7: `ManagerRequestPage` – Duyệt Request

**File:** `lib/ui/screens/manager/manager_request_page.dart`  
**Loại widget:** `StatelessWidget`  
**State manager:** `BlocProvider` tạo `ManagerRequestsCubit` + `BlocConsumer`  
**Chỉ dành cho:** MANAGER / HR  

**Hiển thị khác nhau theo role:**
- **MANAGER**: 1 tab (chỉ PENDING), có nút Duyệt / Từ chối
- **HR**: 3 tab (Pending / Approved / Rejected), chỉ xem, không có nút action

---

## Cấu trúc cây widget

### Manager view
```
BlocProvider<ManagerRequestsCubit>
└── DefaultTabController(length: 1)
    └── Scaffold
        ├── AppBar (title: "Quản lý yêu cầu")
        └── body: BlocConsumer
            └── _buildManagerView(context, state)
                └── RefreshIndicator
                    └── ListView.builder
                        └── _buildGroupedCard() hoặc _buildRequestCard()
```

### HR view
```
BlocProvider<ManagerRequestsCubit>
└── DefaultTabController(length: 3)
    └── Scaffold
        ├── AppBar
        │   └── bottom: TabBar (PENDING / APPROVED / REJECTED)
        └── body: BlocConsumer
            └── _buildHRView(context, state)
                └── TabBarView
                    ├── _buildRequestListView(pending,  showActions: false)
                    ├── _buildRequestListView(approved, showActions: false)
                    └── _buildRequestListView(rejected, showActions: false)
```

---

## Chi tiết từng widget

### `BlocConsumer` – Lắng nghe kết quả duyệt/từ chối
- `listenWhen`: chỉ trigger khi `actionResult` thực sự thay đổi
  ```dart
  listenWhen: (prev, curr) =>
      curr.actionResult != null && curr.actionResult != prev.actionResult
  ```
- Khi `actionResult == 'APPROVED'`:
  - Hiện `SnackBar` màu xanh lá với `SnackBarAction("Xem lịch")`
  - Sau 500ms → navigate sang tab Schedule
- Khi `actionResult == 'REJECTED'`:
  - Hiện `SnackBar` màu đỏ

### `SnackBar` – Approve/Reject feedback
- `content: Row([Icon, SizedBox, Text(message)])`
- `backgroundColor`:
  - Approve → `Colors.green.shade600`
  - Reject → `Colors.red.shade600`
- `behavior: SnackBarBehavior.floating` – nổi lên trên content, không dính đáy màn hình
- `shape: RoundedRectangleBorder(borderRadius: 12)`
- `duration: Duration(seconds: 3)` – tự ẩn sau 3 giây
- `action: SnackBarAction(label: "Xem lịch", textColor: white)` – chỉ hiện khi APPROVED

### `RefreshIndicator`
- `onRefresh: () => ManagerRequestsCubit.loadAllRequests()`

### `ListView.builder`
- `padding: EdgeInsets.all(16)`
- `itemBuilder`: phân biệt item group hay đơn lẻ
  - `item is List<...>` → `_buildGroupedCard(group, showActions)` 
  - Còn lại → `_buildRequestCard(request, showActions)`

---

## Widget con: `_buildGroupedCard` – Nhóm request

```dart
Card(
  margin: EdgeInsets.only(bottom: 16),
  elevation: 4,
  shadowColor: blue.withOpacity(0.2),
  shape: RoundedRectangleBorder(
    borderRadius: 16,
    side: BorderSide(blue.withOpacity(0.1)),
  ),
  child: Padding(16, Column([
    // Header: avatar icon + tên nhân viên
    Row([
      CircleAvatar(...),
      Expanded > Column([employeeName, requestTypeLabel]),
    ]),
    Divider(height: 24),

    // Thông tin ca
    Text('Ca: ${first.shift}', w500),

    // Nếu Recurring: thời gian + weekday chips
    Text('Thời gian: dd/MM – dd/MM'),
    Wrap(children: [Chip(weekday abbr), ...]),

    // Nếu Adhoc: date chips  
    Wrap(children: [Container(date), ...]),

    // Ghi chú nếu có
    Text(note, italic, grey),

    // Action buttons – chỉ khi showActions == true && PENDING
    Row([OutlinedButton("Từ chối tất cả"), ElevatedButton("Duyệt tất cả")]),
  ])),
)
```

### `CircleAvatar` – Avatar icon
- `backgroundColor: Colors.blue.withOpacity(0.1)` – nền tròn xanh rất nhạt
- `child`:
  - `Icons.repeat_rounded` → loại Định kỳ
  - `Icons.event_note_rounded` → loại Đột xuất

### `Chip` – Weekday abbreviations (Recurring)
- `label: Text(r.weekday?.substring(0, 3) ?? '')` – lấy 3 ký tự đầu, ví dụ `"MON"`
- `padding: EdgeInsets.zero`
- `visualDensity: VisualDensity.compact` – thu nhỏ tối đa

### `OutlinedButton` – Từ chối tất cả
- `style.foregroundColor: Colors.red` – màu text và border đỏ
- `style.side: BorderSide(color: Colors.red)` – viền đỏ
- `style.shape: RoundedRectangleBorder(borderRadius: 10)`
- `onPressed: () => ManagerRequestsCubit.rejectBatch(first.groupId!)`

### `ElevatedButton` – Duyệt tất cả
- `style.backgroundColor: Colors.green`
- `style.foregroundColor: Colors.white`
- `style.shape: RoundedRectangleBorder(borderRadius: 10)`
- `onPressed: () => ManagerRequestsCubit.approveBatch(first.groupId!)`

---

## Widget con: `_buildRequestCard` – Request đơn lẻ

- Nền: `Card(elevation: 2, shape: borderRadius 12)`
- Header: `Row` gồm tên nhân viên (bold, fontSize 18) + status badge pill (màu theo status)
- Body: thông tin ca, thứ, ngày
- Footer: `Row([OutlinedButton("Từ chối"), ElevatedButton("Duyệt")])` – chỉ khi `showActions && PENDING`

**Màu status badge:**
- PENDING → `Colors.orange`
- APPROVED → `Colors.green`
- REJECTED → `Colors.red`

---

## Luồng hoạt động

```
ManagerRequestPage load
  → ManagerRequestsCubit.loadAllRequests()
  → API GET /schedules/all
  → Lọc PENDING, nhóm theo groupId

Manager bấm "Duyệt tất cả":
  → approveBatch(groupId)
  → API PATCH /schedules/batch-approve/${groupId}
  → BlocConsumer listener
  → SnackBar xanh + sau 500ms navigate sang tab Schedule
  → HomeCubit.loadData() cập nhật badge
```

---

## File liên quan

- `manager/cubit/manager_requests_cubit.dart` – `loadAllRequests`, `approveRequest`, `rejectRequest`, `approveBatch`, `rejectBatch`
- `manager/cubit/manager_requests_state.dart` – state: `requests`, `actionResult`, `status`
- `data/model/schedule_request_model.dart` – extension `groupByGroupId()`
