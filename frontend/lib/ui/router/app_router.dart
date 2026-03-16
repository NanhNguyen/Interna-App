import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:schedule_management_frontend/data/guard/auth_guard.dart';
import 'package:schedule_management_frontend/ui/router/app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: '/login'),
    CustomRoute(
      page: MainRoute.page,
      path: '/main',
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 400,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ManagerRequestRoute.page,
      path: '/manager-requests',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ScheduleFormRoute.page,
      path: '/schedule-form',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: NotificationRoute.page,
      path: '/notifications',
      guards: [AuthGuard()],
    ),
    AutoRoute(page: MealRoute.page, path: '/meals', guards: [AuthGuard()]),
    AutoRoute(
      page: AnnouncementRoute.page,
      path: '/announcements',
      guards: [AuthGuard()],
    ),
  ];
}
