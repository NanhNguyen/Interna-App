# 📱 Màn hình 9: `ProfilePage` – Hồ sơ cá nhân

**File:** `lib/ui/screens/profile/profile_page.dart`  
**Loại widget:** `StatelessWidget`  
**State manager:** `BlocProvider` tạo `ProfileCubit` + `BlocConsumer<ProfileCubit, ProfileState>`  
**Mục đích:** Xem thông tin cá nhân, đổi mật khẩu, đăng xuất

---

## Cấu trúc cây widget

```
BlocProvider<ProfileCubit>
└── BlocConsumer<ProfileCubit, ProfileState>
    └── Scaffold
        ├── AppBar (title: "Hồ sơ của tôi")
        └── body: SingleChildScrollView > Padding(24) > Column
            ├── CircleAvatar (avatar icon)
            ├── Text (tên người dùng)
            ├── Text (email)
            ├── Container (role badge – hình pill)
            ├── SizedBox(height: 48)
            ├── _buildOptionTile("Đổi mật khẩu")
            ├── Divider
            └── _buildOptionTile("Đăng xuất" – màu đỏ)
```

---

## Chi tiết từng widget

### `BlocConsumer` – Lắng nghe kết quả
- Khi `status == success`:
  - Hiện `SnackBar` màu xanh lá
  - `router.replace(LoginRoute())` – **bắt buộc dùng `replace`** để người dùng không thể back về sau khi đăng xuất
- Khi `status == error`:
  - Hiện `SnackBar` màu đỏ với `state.errorMessage ?? AppStrings.anErrorOccurred`

### `AppBar`
- `title: Text(AppStrings.myProfile)` – "Hồ sơ của tôi"

### `SingleChildScrollView`
- `padding: EdgeInsets.all(24)` – khoảng cách đều 4 phía

### `CircleAvatar` – Avatar
- `radius: 60` – đường kính 120px, khá lớn để nhìn rõ
- `backgroundColor: Colors.blue` – nền xanh
- `child: Icon(Icons.person, size: 60, color: Colors.white)` – icon người trắng trên nền xanh

### `Text` – Tên người dùng
- `data: user?.name ?? 'User Name'` – hiển thị tên hoặc fallback
- `style.fontSize: 28`, `fontWeight: bold`

### `Text` – Email
- `data: user?.email ?? 'email@example.com'` – fallback phòng trường hợp chưa load
- `style.color: Colors.grey`, `style.fontSize: 18`

### `Container` – Role badge (hình pill)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.1),     // nền xanh rất nhạt
    borderRadius: BorderRadius.circular(20), // bo tròn hoàn toàn → pill shape
  ),
  child: Text(
    user?.role.displayName ?? 'Role',        // "Intern" / "Manager" / "HR" / "Employee"
    style: TextStyle(color: Colors.blue, bold, fontSize: 16),
  ),
)
```

---

## Widget con: `_buildOptionTile`

```dart
// params: icon, title, onTap, isDestructive (default: false)
ListTile(
  onTap: onTap,
  leading: Icon(
    icon,
    color: isDestructive ? Colors.red : Colors.blue,
    size: 30,
  ),
  title: Text(
    title,
    style: TextStyle(
      color: isDestructive ? Colors.red : Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  trailing: Icon(Icons.chevron_right, size: 24),
  contentPadding: EdgeInsets.symmetric(vertical: 8),
)
```

**2 option tile hiện có:**
- `"Đổi mật khẩu"`:
  - `icon: Icons.lock_outline`, `isDestructive: false` → màu xanh
  - `onTap: () => _showChangePasswordDialog(context)`
- `"Đăng xuất"`:
  - `icon: Icons.logout`, `isDestructive: true` → màu đỏ
  - `onTap: () => context.read<ProfileCubit>().logout()`

---

## `AlertDialog` – Đổi mật khẩu

Hiện qua `showDialog(...)` khi bấm "Đổi mật khẩu":

```dart
AlertDialog(
  title: Text(AppStrings.changePassword),  // "Đổi mật khẩu"
  content: Column(
    mainAxisSize: MainAxisSize.min,          // co lại theo nội dung, không chiếm full height
    children: [
      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: AppStrings.newPassword,    // "Mật khẩu mới"
          hintText: 'Minimum 6 characters',
        ),
      ),
      SizedBox(height: 16),
      TextField(
        controller: confirmController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: AppStrings.confirmPassword, // "Xác nhận mật khẩu"
        ),
      ),
    ],
  ),
  actions: [
    TextButton("Hủy") → Navigator.pop(context),
    ElevatedButton("Cập nhật") → validate rồi gọi API,
  ],
)
```

### Validation trong nút "Cập nhật"
- Nếu `password.length < 6` → đóng dialog + hiện SnackBar `AppStrings.passwordTooShort`
- Nếu `password != confirmPassword` → đóng dialog + hiện SnackBar `AppStrings.passwordsDoNotMatch`
- Nếu hợp lệ → `Navigator.pop` + `context.read<ProfileCubit>().changePassword(password)`

---

## Luồng hoạt động

### Đăng xuất:
```
Bấm "Đăng xuất"
  → ProfileCubit.logout()
  → xóa token khỏi AuthService / FlutterSecureStorage
  → emit success
  → BlocConsumer listener
  → SnackBar xanh + router.replace(LoginRoute())
```

### Đổi mật khẩu:
```
Bấm "Đổi mật khẩu"
  → showDialog(AlertDialog)
  → nhập mật khẩu mới + xác nhận
  → validate (>= 6 ký tự, 2 field phải khớp nhau)
  → ProfileCubit.changePassword(newPassword)
  → API PATCH /auth/change-password
  → emit success → SnackBar xanh
```

---

## File liên quan

- `profile/cubit/profile_cubit.dart` – `logout()`, `changePassword(newPassword)`
- `profile/cubit/profile_state.dart` – state: `user`, `status`, `errorMessage`
- `data/service/auth_service.dart` – lưu và xóa token/user info trong `FlutterSecureStorage`
