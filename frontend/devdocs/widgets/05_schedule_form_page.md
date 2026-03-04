# 📱 Màn hình 5: `ScheduleFormPage` – Đăng ký nghỉ

**File:** `lib/ui/screens/schedule_form/schedule_form_page.dart`  
**Loại widget:** `StatelessWidget` (được bọc trong `BlocProvider`)  
**State manager:** `BlocProvider` tạo `ScheduleFormCubit` + `BlocConsumer`  
**Thư viện đặc biệt:** `flutter/cupertino.dart` (CupertinoDatePicker), `intl` (DateFormat)  
**Route param:** `isInitialRecurring: bool` – xác định mở ở chế độ Định kỳ hay Đột xuất  
**Chỉ dành cho:** INTERN / EMPLOYEE

---

## Cấu trúc cây widget

```
BlocProvider<ScheduleFormCubit>
└── BlocConsumer<ScheduleFormCubit, ScheduleFormState>
    └── Scaffold
        ├── AppBar (title thay đổi theo isRecurring)
        └── body: Container(gradient) > SingleChildScrollView > Column
            ├── _buildSectionTitle("THỜI GIAN" / "CHỌN NGÀY")
            ├── [Recurring] Row(DateCard start, Icon →, DateCard end)
            ├── [Adhoc]    _buildMultiDatePicker()
            ├── [Recurring] _buildSectionTitle + _buildWeekdaySelector()
            ├── _buildSectionTitle("CA") + _buildGlassDropdown()
            ├── _buildSectionTitle("GHI CHÚ") + TextField(description)
            └── ElevatedButton (submit)
```

---

## Chi tiết từng widget

### `BlocConsumer` – Lắng nghe kết quả submit
- Khi `status == success`:
  - Hiện `SnackBar` màu xanh lá với message thành công
  - Gọi `getIt<HomeCubit>().loadData()` để cập nhật badge trên Home
  - `router.maybePop(true)` để quay lại màn hình trước
- Khi `status == error`:
  - Hiện `SnackBar` màu đỏ với `state.errorMessage`

### `AppBar`
- `title`: `"Nghỉ định kỳ"` hoặc `"Nghỉ đột xuất"` tùy `state.isRecurring`
- `backgroundColor: Colors.blue.shade700`
- `foregroundColor: Colors.white` – màu title và icon back button

### `Container` body – Gradient nền
- `height: double.infinity` – phủ đầy chiều cao màn hình
- `decoration`: `LinearGradient` từ `Colors.white` → `blue.shade700.withOpacity(0.05)`
  → tạo hiệu ứng nền trắng nhạt dần sang xanh rất nhạt phía dưới

---

## Widget con: `_buildSectionTitle`

Text tiêu đề mỗi section, in hoa và màu xám:

```dart
Padding(
  padding: EdgeInsets.only(bottom: 12, left: 4),
  child: Text(
    title.toUpperCase(),
    style: TextStyle(fontSize: 16, w900, color: grey.600, letterSpacing: 1.1),
  ),
)
```

---

## Widget con: `_buildDateCard` – Chọn ngày (Recurring)

Card bấm vào để mở `CupertinoDatePicker`:

- Wrapper: `InkWell(borderRadius: 16)` để có ripple effect
- Bên trong: `Container` với `BoxDecoration(color: white, borderRadius: 16, border: grey.200)`
- Nội dung:
  - Dòng 1: label `"Bắt đầu"` / `"Đến"` (fontSize: 14, bold, grey.500)
  - Dòng 2: ngày tháng `DateFormat('dd/MM').format(date)` (fontSize: 20, w900, blue)
  - Dòng 3: năm `DateFormat('yyyy').format(date)` (fontSize: 16, grey.600)
- Bấm → gọi `_showScrollingDatePicker(context, initialDate, minimumDate?, onChanged)`

---

## `CupertinoDatePicker` – Picker kiểu iOS

Nằm trong `showModalBottomSheet`, dạng scroll drum:

- `mode: CupertinoDatePickerMode.date` – chỉ chọn ngày, không có giờ
- `initialDateTime: DateTime` – ngày mặc định hiển thị khi mở
- `minimumDate: DateTime?` – giới hạn ngày tối thiểu (dùng cho `endDate` để không được chọn trước `startDate`)
- `onDateTimeChanged: ValueChanged<DateTime>` – callback mỗi lần user lăn chọn ngày mới

**Container BottomSheet:**
- `shape`: bo góc trên 20px
- `height: 300`
- Header: `Row([TextButton("Hủy"), Text("Chọn ngày"), TextButton("Xong")])`
- Body: `Expanded(child: CupertinoDatePicker(...))`

---

## Widget con: `_buildWeekdaySelector` – Chọn thứ (Recurring)

Dùng `FilterChip` trong `Wrap` để chọn thứ lặp lại trong tuần:

### `Wrap`
- `spacing: 8` – khoảng cách ngang giữa các chip
- `runSpacing: 8` – khoảng cách dọc khi xuống hàng

### `FilterChip`
- `label: Text('Th 2')` đến `Text('Th 6')` – nhãn hiển thị
- `selected: state.selectedWeekdays.contains(dbKey)` – so sánh với key tiếng Anh
- `onSelected: (_) => ScheduleFormCubit.toggleWeekday(dbKey)` – toggle chọn/bỏ
- `selectedColor: Colors.blue.shade700` – nền xanh khi selected
- `checkmarkColor: Colors.white` – dấu tích ✓ màu trắng
- `labelStyle`:
  - Khi selected → `color: white, bold, fontSize: 16`
  - Khi unselected → `color: black87, bold, fontSize: 16`
- `shape: RoundedRectangleBorder(borderRadius: 12)` – bo góc chip

**Mapping label ↔ DB key:**
- "Th 2" ↔ `MONDAY`, "Th 3" ↔ `TUESDAY`, "Th 4" ↔ `WEDNESDAY`
- "Th 5" ↔ `THURSDAY`, "Th 6" ↔ `FRIDAY`

---

## Widget con: `_buildMultiDatePicker` – Chọn nhiều ngày (Adhoc)

Gồm 2 phần:

### 1. Danh sách ngày đã chọn – `Wrap` + `Chip`
```dart
Chip(
  label: Text(DateFormat('EEE, MMM dd').format(date)),  // "Mon, Jan 01"
  onDeleted: () => ScheduleFormCubit.toggleDate(date),   // xóa ngày này
  backgroundColor: color.withOpacity(0.1),
  deleteIconColor: color,
  labelStyle: TextStyle(color: color, bold, fontSize: 13),
  shape: RoundedRectangleBorder(borderRadius: 12),
)
```

### 2. Nút thêm ngày – `InkWell` → `showDatePicker`
- Giao diện: `Container` có nét đứt màu xanh, bên trong `Row([Icon, Text("Thêm ngày")])`
- `showDatePicker`:
  - `firstDate`: 30 ngày trước đây
  - `lastDate`: 365 ngày tới
  - `builder`: custom theme bằng `ColorScheme.light(primary: color)` để đổi màu xanh

---

## Widget con: `_buildGlassDropdown` – Chọn ca

`DropdownButtonFormField<String>`:

- `value: state.shift` – giá trị đang chọn hiện tại
- `decoration`:
  - `contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18)` – padding bên trong
  - `filled: true`, `fillColor: Colors.white` – nền trắng
  - `border: OutlineInputBorder(borderRadius: 16, borderSide: none)` – ẩn border mặc định
  - `enabledBorder: OutlineInputBorder(borderSide: grey.200)` – viền xám nhạt
- `items: ['Buổi sáng', 'Buổi chiều', 'Cả ngày']` – các lựa chọn ca
- `onChanged: (v) => ScheduleFormCubit.updateField(shift: v)` – cập nhật state

---

## `TextField` – Ghi chú

- `maxLines: 2` – cho phép tối đa 2 dòng
- `onChanged: (v) => ScheduleFormCubit.updateField(description: v)` – cập nhật realtime
- `decoration.hintText: AppStrings.addNotes` – "Thêm ghi chú..."
- `decoration.prefixIcon: Icon(Icons.notes_rounded)` – icon ghi chú bên trái
- `decoration.filled: true`, `fillColor: Colors.white`
- `decoration.border: OutlineInputBorder(borderRadius: 16, borderSide: none)` – không có border mặc định
- `decoration.enabledBorder`: viền xám nhạt `grey.200`

---

## `ElevatedButton` – Submit

- `onPressed`: `null` khi loading (disable), `ScheduleFormCubit.submit()` khi rảnh
- `style.backgroundColor: Colors.blue.shade700`
- `style.foregroundColor: Colors.white`
- `style.elevation: 4` với `shadowColor: color.withOpacity(0.4)` – đổ bóng nhẹ
- `style.shape: RoundedRectangleBorder(borderRadius: 16)`
- `child`:
  - Khi loading → `CircularProgressIndicator(color: white, strokeWidth: 2)` trong `SizedBox(24x24)`
  - Khi rảnh → `Text(submitLabel, fontSize: 20, bold)`
- Wrapper: `SizedBox(width: double.infinity, height: 56)`

---

## File liên quan

- `schedule_form/cubit/schedule_form_cubit.dart` – `setInitialMode`, `updateField`, `toggleWeekday`, `toggleDate`, `submit`
- `schedule_form/cubit/schedule_form_state.dart` – state: `isRecurring`, `startDate`, `endDate`, `selectedWeekdays`, `selectedDates`, `shift`, `description`, `status`
- `home/cubit/home_cubit.dart` – `loadData()` gọi sau submit để cập nhật badge
