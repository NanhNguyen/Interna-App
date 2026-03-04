# 📱 Màn hình 1: `LoginPage` – Đăng nhập

**File:** `lib/ui/screens/login/login_page.dart`  
**Loại widget:** `StatefulWidget`  
**State manager:** `BlocProvider` + `BlocConsumer<LoginCubit, LoginState>`  
**Route:** Route đầu tiên khi mở app

---

## Cấu trúc cây widget

```
BlocProvider<LoginCubit>
└── BlocConsumer<LoginCubit, LoginState>
    └── Scaffold
        └── Container (gradient nền xanh)
            └── Center
                └── SingleChildScrollView
                    └── Card (bo góc, đổ bóng)
                        └── Padding
                            └── Column
                                ├── Icon (logo lịch)
                                ├── Text ("Shiftly")
                                ├── TextField (email)
                                ├── TextField (password)
                                └── ElevatedButton (đăng nhập)
```

---

## Chi tiết từng widget

### `BlocProvider`
- `create: (context) => getIt<LoginCubit>()` – lấy instance từ GetIt DI container

### `BlocConsumer<LoginCubit, LoginState>`
- **`listener`**: lắng nghe thay đổi state
  - Nếu `state.status == success` → điều hướng sang `MainRoute` bằng `router.replace`
  - Nếu `state.status == error` → hiện `SnackBar` với `state.errorMessage`
- **`builder`**: rebuild UI mỗi khi state thay đổi, truy cập `state.obscurePassword` và `state.status`

### `Scaffold`
- `backgroundColor: Colors.blue.shade900` – màu nền fallback (hiện phía sau Container gradient)

### `Container` – Nền gradient
- `decoration`: dùng `BoxDecoration` với `LinearGradient`
  - Màu từ `Colors.blue.shade900` → `Colors.blue.shade700`
  - Hướng: `Alignment.topCenter` → `Alignment.bottomCenter`

### `SingleChildScrollView`
- `padding: EdgeInsets.all(32)` – khoảng cách tất cả phía trong

### `Card`
- `elevation: 8` – đổ bóng mạnh, tạo cảm giác card nổi lên khỏi nền gradient
- `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))` – bo góc 24px

### `Icon` – Logo app
- `icon: Icons.calendar_month`
- `size: 64`
- `color: Colors.blue`

### `Text` – Tên app
- `data: AppStrings.appName` → hiện text `"Shiftly"`
- `style.fontSize: 28`, `fontWeight: bold`, `color: Colors.blue`

### `TextField` – Email
- `controller: _emailController` – `TextEditingController`, đọc giá trị khi submit
- `decoration.labelText: AppStrings.email` – label nổi lên khi focus
- `decoration.prefixIcon: Icon(Icons.email_outlined)` – icon email bên trái
- `decoration.border: OutlineInputBorder(borderRadius: 12)` – border bo góc

### `TextField` – Password
- `controller: _passwordController` – `TextEditingController` riêng cho password
- `obscureText: state.obscurePassword` – `true` thì ẩn ký tự, `false` thì hiện
- `decoration.prefixIcon: Icon(Icons.lock_outline)` – icon khóa
- `decoration.suffixIcon`: `IconButton` toggle hiện/ẩn password
  - Khi `obscurePassword == true` → hiện `Icons.visibility_off`
  - Khi `obscurePassword == false` → hiện `Icons.visibility`
  - Bấm → gọi `context.read<LoginCubit>().togglePasswordVisibility()`

### `ElevatedButton` – Nút đăng nhập
- `onPressed`:
  - Khi `state.status == loading` → `null` (disable button, tránh double-submit)
  - Khi rảnh → gọi `context.read<LoginCubit>().login(email, password)`
- `style.backgroundColor: Colors.blue`
- `style.foregroundColor: Colors.white`
- `style.shape: RoundedRectangleBorder(borderRadius: 12)`
- `child`:
  - Khi loading → `CircularProgressIndicator(color: Colors.white)`
  - Khi rảnh → `Text(AppStrings.login, fontSize: 16, bold)`
- Wrap ngoài: `SizedBox(width: double.infinity, height: 50)` để button full width

### `SnackBar` – Thông báo lỗi
- `content: Text(state.errorMessage ?? AppStrings.loginFailed)` – lỗi từ API hoặc fallback text
- Hiện qua `ScaffoldMessenger.of(context).showSnackBar(...)`

---

## Luồng hoạt động

```
User nhập email + password
    → bấm nút Đăng nhập
    → LoginCubit.login(email, password)
    → AuthRepo.login() gọi API POST /auth/login
    → Thành công: lưu token vào AuthService → emit success
                  → BlocConsumer listener → router.replace(MainRoute)
    → Thất bại:   emit error → BlocConsumer listener → SnackBar hiện lỗi
```

---

## File liên quan

- `login/cubit/login_cubit.dart` – xử lý logic đăng nhập, toggle password visibility
- `login/cubit/login_state.dart` – chứa `status`, `obscurePassword`, `errorMessage`
- `data/repo/auth_repo.dart` – interface gọi API đăng nhập
- `data/service/auth_service.dart` – lưu token và thông tin user sau đăng nhập
