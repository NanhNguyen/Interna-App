# 📱 Màn hình 4: `SchedulePage` – Xem lịch

**File:** `lib/ui/screens/schedule/schedule_page.dart`  
**Loại widget:** `StatefulWidget`  
**State manager:** `BlocProvider` tạo `ScheduleCubit` + `BlocBuilder<ScheduleCubit, ScheduleState>`  
**Thư viện đặc biệt:** `table_calendar ^3.2.0`, `intl`

---

## Cấu trúc cây widget

```
BlocProvider<ScheduleCubit>
└── Scaffold
    ├── AppBar
    │   └── actions: [IconButton(today), IconButton(refresh)]
    └── body: DefaultTabController(length: 2)
        └── Column
            ├── [Manager/HR only] _buildSearchBar()
            ├── Container(xanh) > TabBar
            │   ├── Tab("Nghỉ định kỳ")  → Week view
            │   └── Tab("Nghỉ đột xuất") → Month view
            └── Expanded > BlocBuilder
                └── TabBarView
                    ├── _buildCalendarTab(isRecurring: true)
                    └── _buildCalendarTab(isRecurring: false)
```

### Cây con mỗi `_buildCalendarTab`

```
RefreshIndicator
└── SingleChildScrollView(AlwaysScrollableScrollPhysics)
    └── Column
        ├── _buildLegend()
        ├── Card > TableCalendar
        ├── Divider
        └── SizedBox(height: 400) > _buildEventList()
```

---

## Chi tiết từng widget

### `DefaultTabController`
- `length: 2` – điều phối 2 tab mà không cần quản lý state thủ công

### `TabBar`
- `indicatorColor: Colors.white` – gạch dưới tab active màu trắng
- `indicatorWeight: 3` – độ dày gạch 3px
- `labelStyle: TextStyle(fontWeight: bold, color: white, fontSize: 18)` – tab active
- `unselectedLabelStyle: TextStyle(fontWeight: bold, color: white60, fontSize: 17)` – tab inactive

### `RefreshIndicator`
- `onRefresh: () => context.read<ScheduleCubit>().loadSchedules(_userRole)` – reload dữ liệu

---

## `TableCalendar` (thư viện `table_calendar`)

Widget lịch chính. Tab "Định kỳ" dùng **week view**, tab "Đột xuất" dùng **month view**.

### Arguments cơ bản
- `firstDay: DateTime(2020)` – ngày sớm nhất có thể scroll đến
- `lastDay: DateTime(2030)` – ngày muộn nhất có thể scroll đến
- `focusedDay: _focusedDay` – ngày đang được focus, cập nhật qua `setState`
- `calendarFormat`:
  - `CalendarFormat.week` → Tab "Định kỳ"
  - `CalendarFormat.month` → Tab "Đột xuất"
- `availableCalendarFormats: {CalendarFormat.week: 'Week', CalendarFormat.month: 'Month'}`
- `locale: 'vi'` – ngôn ngữ tiếng Việt cho tên thứ, tên tháng
- `rowHeight`:
  - `180` khi week view – cao để chứa 2 badge SA/CH
  - `80` khi month view – chiều cao vừa đủ
- `daysOfWeekHeight: 45` – chiều cao hàng tên thứ

### Arguments sự kiện
- `selectedDayPredicate: (day) => isSameDay(_selectedDay, day)` – xác định ngày nào đang selected
- `onDaySelected: (selectedDay, focusedDay)` – cập nhật `_selectedDay` và `_focusedDay` trong `setState`
- `onPageChanged: (focusedDay)` – cập nhật `_focusedDay` khi lật tháng/tuần
- `eventLoader: (day) => List<ScheduleRequestModel>` – cung cấp event cho mỗi ngày

### `HeaderStyle`
- `formatButtonVisible: false` – ẩn nút switch format (đã cố định theo tab)
- `titleCentered: true` – căn giữa tiêu đề tháng/tuần
- `titleTextStyle: TextStyle(fontSize: 20, bold, color: Colors.blueAccent)`

### `DaysOfWeekStyle`
- `weekdayStyle: TextStyle(fontSize: 16, bold, color: Colors.grey.shade700)` – T2 đến T6
- `weekendStyle: TextStyle(fontSize: 16, bold, color: Colors.redAccent)` – T7 và CN

### `CalendarBuilders` – Tuỳ chỉnh render từng thành phần

- `dowBuilder` (cả 2 tab): custom tên thứ – CN hiện màu đỏ
- `defaultBuilder` (chỉ week view): cell ngày thường → gọi `_buildWeekDayCell(isSelected: false, isToday: false)`
- `todayBuilder` (chỉ week view): cell ngày hôm nay → gọi `_buildWeekDayCell(isToday: true)`
- `selectedBuilder` (chỉ week view): cell ngày được chọn → gọi `_buildWeekDayCell(isSelected: true)`
- `markerBuilder` (chỉ month view): dot/badge dưới ngày → gọi `_buildMonthMarkerDots()`

---

## Widget con: `_buildWeekDayCell`

Cell tuỳ chỉnh cho Week view, hiển thị badge SA / CH mỗi ngày:

```dart
GestureDetector(
  onTap: () => setState(() { _selectedDay = day; _focusedDay = day; }),
  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor, width: 1.5),
    ),
    child: Column([
      Text('${day.day}', fontSize: 18, bold),   // số ngày
      Container(height: 1, color: dividerColor), // đường kẻ ngang
      _buildShiftBadge('SA', morningCount, ...),
      _buildShiftBadge('CH', afternoonCount, ...),
    ]),
  ),
)
```

**Màu cell theo trạng thái:**
- `isSelected: true` → nền `blue.shade700`, chữ trắng, border xanh đậm
- `isToday: true` → nền `blue.shade50`, chữ `blue.shade800`, border `blue.shade300`
- Weekend → nền `grey.shade50`, chữ `grey.shade400`, không border
- Bình thường → nền trong suốt, chữ `black87`, không border

---

## Widget con: `_buildShiftBadge`

Badge nhỏ hiển thị ca Sáng (SA) hoặc Chiều (CH):

- `label: String` – `'SA'` hoặc `'CH'`
- `count: int` – số người có ca đó trong ngày
- `color: Color` – màu chữ và icon: `blue.600` (SA), `orange.700` (CH)
- `bgColor: Color` – màu nền: `blue.50` / `orange.50`
- `isSelected: bool` – khi cell đang selected, chữ đổi sang màu trắng
- `isEmpty: bool` – khi không có ai, badge mờ dùng làm placeholder giữ layout

**Logic hiển thị:**
- **INTERN**: chỉ hiện label `SA`/`CH`, không hiện số count (vì chỉ có lịch của bản thân)
- **MANAGER/HR**: hiện cả label và số count bên phải

---

## Widget con: `_buildSearchBar` – Chỉ Manager/HR

`TextField` filter realtime theo tên nhân viên (áp dụng cả 2 tab):

- `onChanged: setState(() => _filterEmployee = value)` – filter realtime
- `decoration.hintText: 'Tìm theo tên thực tập sinh...'`
- `decoration.hintStyle: TextStyle(fontSize: 18, color: grey.400)`
- `decoration.prefixIcon: Icon(Icons.person_search_rounded, size: 30, color: blue.500)`
- `decoration.suffixIcon`: `IconButton(Icons.clear)` chỉ hiện khi đang có text trong filter
- `decoration.filled: true`, `fillColor: Colors.grey.shade50` – nền xám rất nhạt
- `decoration.border: OutlineInputBorder(borderRadius: 12)` – border bình thường
- `decoration.focusedBorder: OutlineInputBorder(borderSide: blue.400, width: 1.5)` – border xanh khi focus

---

## Widget con: `_buildEventList` – Danh sách lịch dưới calendar

`ListView.builder` hiển thị các event của ngày đang chọn:

- `padding: EdgeInsets.symmetric(horizontal: 16)`
- Mỗi item là `Card > ListTile`:
  - `leading`: Column gồm Icon loại (nghỉ/làm) + Text tên ca
  - `title`: tên nhân viên (Manager/HR) hoặc "Nghỉ phép" / "Ca của tôi" (Intern)
  - `subtitle`: Column gồm mô tả + Row (chấm màu status + tên status + weekday nếu recurring)
  - `trailing`: `IconButton(Icons.info_outline)` – chỉ Manager/HR

**Màu chấm status:**
- APPROVED → `Colors.green`
- PENDING → `Colors.orange`
- REJECTED → `Colors.red`

---

## Widget con: `_buildMonthMarkerDots`

Hiện dot/badge nhỏ dưới ngày trong month view (dùng `Positioned`):

- Nếu có người nghỉ (LEAVE):
  - MANAGER/HR: badge xanh hình chữ nhật có số đếm người nghỉ
  - INTERN: chấm tròn `Colors.blue`
- Nếu có WORK: chấm tròn `Colors.blue.shade300`

---

## File liên quan

- `schedule/cubit/schedule_cubit.dart` – `loadSchedules(userRole)`, gọi API theo role
- `schedule/cubit/schedule_state.dart` – state: `approvedSchedules`, `status`
- `data/model/schedule_request_model.dart` – model: `isRecurring`, `shift`, `weekday`, `startDate`, `endDate`
