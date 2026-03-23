import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/constant/enums.dart';
import '../../../data/service/auth_service.dart';
import '../../di/di_config.dart';
import '../home/home_page.dart';
import '../schedule/schedule_page.dart';
import '../status/status_page.dart';
import '../profile/profile_page.dart';
import '../manager/manager_request_page.dart';
import '../notifications/notification_page.dart';
import '../meal/meal_page.dart';
import '../announcements/announcement_page.dart';
import '../schedule/cubit/schedule_cubit.dart';
import 'cubit/main_cubit.dart';
import 'cubit/main_state.dart';
import '../home/cubit/home_cubit.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../notifications/cubit/notification_state.dart';
import 'widget/in_app_notification_banner.dart';
import '../../../resource/app_strings.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final HomeCubit _homeCubit;
  late final MainCubit _mainCubit;
  late final NotificationCubit _notifCubit;

  late final UserRole _userRole;
  late final List<Widget> _pages;
  late final Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final authService = getIt<AuthService>();
    _userRole = authService.currentUser?.role ?? UserRole.INTERN;

    _mainCubit = getIt<MainCubit>()..setIndex(0); // always start at Home tab
    _homeCubit = getIt<HomeCubit>()..loadData();
    _notifCubit = getIt<NotificationCubit>()..loadNotifications();

    _pages = _getPagesForRole(_userRole);
    _selectedColor = _getColorForRole(_userRole);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _mainCubit),
        BlocProvider.value(value: _homeCubit),
        BlocProvider.value(value: _notifCubit),
      ],
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          return BlocBuilder<MainCubit, MainState>(
            builder: (context, state) {
              final unreadNotifications = notifState.notifications
                  .where((n) => !n.isRead)
                  .toList();

              final isWideScreen = MediaQuery.of(context).size.width >= 800;
              final currentNavItems = _userRole == UserRole.MANAGER
                  ? _getManagerNavItemsWithBadge(
                      context,
                      unreadNotifications.length,
                    )
                  : _getNavItemsWithBadge(unreadNotifications.length);

              return InAppNotificationOverlay(
                notifications: notifState.notifications,
                unreadCount: unreadNotifications.length,
                child: Scaffold(
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isWideScreen)
                        Container(
                          width: 250,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 32,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      AppStrings.appName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  itemCount: currentNavItems.length,
                                  itemBuilder: (context, index) {
                                    final item = currentNavItems[index];
                                    final isSelected =
                                        _getNavIndexFromPage(
                                          state.currentIndex,
                                        ) ==
                                        index;
                                    return ListTile(
                                      leading: isSelected
                                          ? item.activeIcon
                                          : item.icon,
                                      title: Text(
                                        item.label ?? '',
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? _selectedColor
                                              : Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedTileColor: _selectedColor
                                          .withOpacity(0.1),
                                      iconColor: isSelected
                                          ? _selectedColor
                                          : Colors.grey.shade600,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 4,
                                          ),
                                      onTap: () {
                                        final pageIndex = _getPageIndexFromNav(
                                          index,
                                        );
                                        _mainCubit.setIndex(pageIndex);
                                        if (_isScheduleIndex(pageIndex)) {
                                          getIt<ScheduleCubit>().loadSchedules(
                                            _userRole,
                                          );
                                          getIt<ScheduleCubit>().resetDate();
                                        }
                                        if (pageIndex ==
                                            _getNotificationIndex(_userRole)) {
                                          _notifCubit.markAllAsRead();
                                          getIt<HomeCubit>().loadData();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isWideScreen)
                        const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: IndexedStack(
                          index: state.currentIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: isWideScreen
                      ? null
                      : Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BottomNavigationBar(
                              currentIndex: _getNavIndexFromPage(
                                state.currentIndex,
                              ),
                              onTap: (index) {
                                final pageIndex = _getPageIndexFromNav(index);
                                _mainCubit.setIndex(pageIndex);
                                if (_isScheduleIndex(pageIndex)) {
                                  getIt<ScheduleCubit>().loadSchedules(
                                    _userRole,
                                  );
                                  getIt<ScheduleCubit>().resetDate();
                                }
                                if (pageIndex ==
                                    _getNotificationIndex(_userRole)) {
                                  _notifCubit.markAllAsRead();
                                  getIt<HomeCubit>().loadData();
                                }
                              },
                              type: BottomNavigationBarType.fixed,
                              selectedItemColor: _selectedColor,
                              unselectedItemColor: Colors.grey,
                              showSelectedLabels: false,
                              showUnselectedLabels: false,
                              iconSize: 28,
                              selectedLabelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 12,
                              ),
                              items: currentNavItems,
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build manager nav items with live pending-request badge on tab 1 and notifications on tab 2.
  List<BottomNavigationBarItem> _getManagerNavItemsWithBadge(
    BuildContext context,
    int unreadNotifCount,
  ) {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: AppStrings.home,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: AppStrings.schedule,
      ),
      BottomNavigationBarItem(
        icon: _withBadge(
          Icons.notifications_outlined,
          unreadNotifCount,
          active: false,
        ),
        activeIcon: _withBadge(
          Icons.notifications,
          unreadNotifCount,
          active: true,
        ),
        label: AppStrings.notifications,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: AppStrings.profile,
      ),
    ];
  }

  /// Overlay a red badge on top-right of an icon.
  Widget _withBadge(IconData iconData, int count, {required bool active}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.MANAGER:
        return [
          const HomePage(),
          const ManagerRequestPage(),
          const SchedulePage(),
          const NotificationPage(),
          const ProfilePage(),
        ];
      case UserRole.HR:
        return [
          const HomePage(),
          const MealPage(),
          const SchedulePage(),
          const AnnouncementPage(),
          const NotificationPage(),
          const ProfilePage(),
        ];
      case UserRole.INTERN:
      case UserRole.EMPLOYEE:
        return [
          const HomePage(),
          const MealPage(),
          const SchedulePage(),
          const StatusPage(),
          const AnnouncementPage(),
          const NotificationPage(),
          const ProfilePage(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsWithBadge(int unreadCount) {
    switch (_userRole) {
      case UserRole.MANAGER:
        return _getManagerNavItemsWithBadge(context, unreadCount);
      default:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: AppStrings.schedule,
          ),
          BottomNavigationBarItem(
            icon: _withBadge(
              Icons.notifications_outlined,
              unreadCount,
              active: false,
            ),
            activeIcon: _withBadge(
              Icons.notifications,
              unreadCount,
              active: true,
            ),
            label: AppStrings.notifications,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ];
    }
  }

  int _getPageIndexFromNav(int navIndex) {
    if (navIndex == 0) return 0; // Home
    if (navIndex == 1) return 2; // Schedule (universal index 2)
    if (_userRole == UserRole.MANAGER) {
      if (navIndex == 2) return 3; // Notifications
      if (navIndex == 3) return 4; // Profile
    } else if (_userRole == UserRole.HR) {
      if (navIndex == 2) return 4; // Notifications
      if (navIndex == 3) return 5; // Profile
    } else {
      if (navIndex == 2) return 5; // Notifications
      if (navIndex == 3) return 6; // Profile
    }
    return 0;
  }

  int _getNavIndexFromPage(int pageIndex) {
    if (pageIndex == 0) return 0; // Home
    if (pageIndex == 2) return 1; // Schedule
    if (_userRole == UserRole.MANAGER) {
      if (pageIndex == 3) return 2; // Notifications
      if (pageIndex == 4) return 3; // Profile
    } else if (_userRole == UserRole.HR) {
      if (pageIndex == 4) return 2; // Notifications
      if (pageIndex == 5) return 3; // Profile
    } else {
      if (pageIndex == 5) return 2; // Notifications
      if (pageIndex == 6) return 3; // Profile
    }
    return 0; // Default to home if on quick action tabs
  }

  bool _isScheduleIndex(int index) => index == 2;

  int _getNotificationIndex([UserRole? role]) {
    final r = role ?? _userRole;
    if (r == UserRole.MANAGER) return 3;
    if (r == UserRole.HR) return 4;
    return 5;
  }

  Color _getColorForRole(UserRole role) {
    return const Color(0xFF8B5CF6);
  }
}
