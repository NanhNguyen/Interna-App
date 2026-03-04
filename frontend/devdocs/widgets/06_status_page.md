# 📱 Màn hình 6: `StatusPage` – Trạng thái request

**File:** `lib/ui/screens/status/status_page.dart`  
**Loại widget:** `StatelessWidget`  
**State manager:** `BlocProvider` tạo `StatusCubit` + `BlocBuilder<StatusCubit, StatusState>`  
**Chỉ dành cho:** INTERN / EMPLOYEE  
**Mục đích:** Intern xem lại các request đã gửi, phân theo 3 trạng thái

---

## Cấu trúc cây widget

```
BlocProvider<StatusCubit>
└── DefaultTabController(length: 3)
    └── Scaffold
        ├── AppBar
        │   └── bottom: TabBar
        │       ├── Tab("ĐANG CHỜ")
        │       ├── Tab("ĐÃ DUYỆT")
        │       └── Tab("ĐÃ TỪ CHỐI")
        └── body: BlocBuilder<StatusCubit, StatusState>
            └── TabBarView
                ├── _buildRequestList(pendingRequests)
                ├── _buildRequestList(approvedRequests)
                └── _buildRequestList(rejectedRequests)
```

### Cây con `_buildRequestList`

```
RefreshIndicator
├── [Rỗng] SingleChildScrollView(AlwaysScrollable)
│          └── Center > Container (thông báo trống)
└── [Có data] ListView.builder
              └── items[i] là:
                  ├── SizedBox.shrink (placeholder index 0)
                  ├── _buildGroupedItem(List<Request>) → Card > ExpansionTile
                  └── RequestItem(Request) → widget riêng
```

---

## Chi tiết từng widget

### `AppBar`
- `backgroundColor: Colors.blue` – nền xanh đậm
- `elevation: 0` – không đổ bóng, tạo cảm giác phẳng liền với TabBar
- `title: Text(AppStrings.myRequestStatus)` – màu trắng, bold
- `bottom: TabBar(...)` – tab bar nhúng trực tiếp vào AppBar

### `TabBar` (trong `AppBar.bottom`)
- `labelColor: Colors.white` – tab active màu trắng
- `unselectedLabelColor: Colors.white.withOpacity(0.6)` – tab inactive trắng mờ 60%
- `indicatorColor: Colors.white` – gạch underline màu trắng
- `indicatorWeight: 3` – độ dày gạch 3px
- `labelStyle: TextStyle(fontWeight: bold, fontSize: 16)` – tab active
- `unselectedLabelStyle: TextStyle(fontWeight: bold, fontSize: 15)` – tab inactive
- `tabs: [Tab("ĐANG CHỜ"), Tab("ĐÃ DUYỆT"), Tab("ĐÃ TỪ CHỐI")]`

### `RefreshIndicator`
- `onRefresh: () => context.read<StatusCubit>().loadRequests()` – reload API
- **Lưu ý:** khi list rỗng, phải dùng `SingleChildScrollView(physics: AlwaysScrollableScrollPhysics)`
  bên trong thay vì `Center` trực tiếp, để `RefreshIndicator` vẫn nhận được gesture

### `ListView.builder`
- `padding: EdgeInsets.all(20)` – khoảng cách ngoài toàn bộ danh sách
- `itemCount: items.length + 1` – +1 cho placeholder `SizedBox.shrink` ở index 0
- `itemBuilder`: phân biệt item group hay đơn lẻ:
  - `item is List<...>` → render `_buildGroupedItem(group)`
  - Còn lại → render `RequestItem(request)`

---

## Widget con: `_buildGroupedItem` – Request nhóm

Dùng khi nhiều request cùng `groupId` (ví dụ 1 lần đăng ký định kỳ gồm nhiều thứ):

- Wrapper: `Card` với `margin: EdgeInsets.only(bottom: 12)` và border màu theo status
- `shape: RoundedRectangleBorder(borderRadius: 16, side: BorderSide(statusColor.20%))`

### `ExpansionTile`
- `title: Text(first.description ?? AppStrings.batchRequest)` – fontSize 18, bold
- `subtitle: Text(subtitle)` – fontSize 16
  - Nếu INTERN: chỉ hiện `first.status.displayName`
  - Nếu khác: `'${group.length} mục • ${first.status.displayName}'`
- `leading: Icon(Icons.repeat / Icons.event_note, size: 28)` – loại request
- `trailing`:
  - Chỉ hiện khi `isPending == true` → `IconButton(Icons.delete_outline, color: red, size: 28)`
  - Bấm → gọi `_confirmDelete(context, onConfirm: () => cubit.deleteBatchRequests(groupId))`
- `children`: danh sách `RequestItem` widget (các item con khi expand)

**Màu viền Card theo status:**
- PENDING → `Colors.orange`
- APPROVED → `Colors.green`
- REJECTED → `Colors.red`

---

## `AlertDialog` – Xác nhận xóa

Hiện qua `showDialog(...)` khi bấm icon thùng rác:

- `title: Text(AppStrings.confirmDelete)` – "Xác nhận xóa"
- `content: Text(AppStrings.deleteMessage)` – mô tả hậu quả của việc xóa
- `actions`:
  - `TextButton("Hủy")` → `Navigator.pop(context)` – đóng dialog
  - `TextButton("Xóa")` – `color: Colors.red` → đóng dialog rồi gọi `onConfirm()`

---

## Widget liên quan: `RequestItem`

File riêng `status/widget/request_item.dart`, hiển thị 1 request đơn lẻ:

- `request: ScheduleRequestModel` – dữ liệu request
- `onDelete: VoidCallback?` – callback xóa, chỉ truyền vào nếu status == PENDING

---

## Luồng hoạt động

```
StatusPage load
  → StatusCubit.loadRequests()
  → API GET /schedules/my
  → nhóm request theo groupId (groupByGroupId())
  → hiện 3 tab theo status

Intern xóa request PENDING:
  → bấm icon 🗑️
  → AlertDialog xác nhận hiện lên
  → bấm "Xóa" → StatusCubit.deleteRequest(id) hoặc deleteBatchRequests(groupId)
  → reload danh sách
```

---

## File liên quan

- `status/cubit/status_cubit.dart` – `loadRequests`, `deleteRequest`, `deleteBatchRequests`
- `status/cubit/status_state.dart` – state: `requests`, `status`
- `status/widget/request_item.dart` – widget 1 request item
- `data/model/schedule_request_model.dart` – extension `groupByGroupId()`
