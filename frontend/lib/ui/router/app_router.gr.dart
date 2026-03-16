// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/cupertino.dart' as _i9;
import 'package:schedule_management_frontend/ui/screens/announcements/announcement_page.dart'
    as _i1;
import 'package:schedule_management_frontend/ui/screens/login/login_page.dart'
    as _i2;
import 'package:schedule_management_frontend/ui/screens/main/main_page.dart'
    as _i3;
import 'package:schedule_management_frontend/ui/screens/manager/manager_request_page.dart'
    as _i4;
import 'package:schedule_management_frontend/ui/screens/meal/meal_page.dart'
    as _i5;
import 'package:schedule_management_frontend/ui/screens/notifications/notification_page.dart'
    as _i6;
import 'package:schedule_management_frontend/ui/screens/schedule_form/schedule_form_page.dart'
    as _i7;

/// generated route for
/// [_i1.AnnouncementPage]
class AnnouncementRoute extends _i8.PageRouteInfo<void> {
  const AnnouncementRoute({List<_i8.PageRouteInfo>? children})
    : super(AnnouncementRoute.name, initialChildren: children);

  static const String name = 'AnnouncementRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.AnnouncementPage();
    },
  );
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i8.PageRouteInfo<void> {
  const LoginRoute({List<_i8.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.LoginPage();
    },
  );
}

/// generated route for
/// [_i3.MainPage]
class MainRoute extends _i8.PageRouteInfo<void> {
  const MainRoute({List<_i8.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.MainPage();
    },
  );
}

/// generated route for
/// [_i4.ManagerRequestPage]
class ManagerRequestRoute extends _i8.PageRouteInfo<void> {
  const ManagerRequestRoute({List<_i8.PageRouteInfo>? children})
    : super(ManagerRequestRoute.name, initialChildren: children);

  static const String name = 'ManagerRequestRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.ManagerRequestPage();
    },
  );
}

/// generated route for
/// [_i5.MealPage]
class MealRoute extends _i8.PageRouteInfo<void> {
  const MealRoute({List<_i8.PageRouteInfo>? children})
    : super(MealRoute.name, initialChildren: children);

  static const String name = 'MealRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i5.MealPage();
    },
  );
}

/// generated route for
/// [_i6.NotificationPage]
class NotificationRoute extends _i8.PageRouteInfo<void> {
  const NotificationRoute({List<_i8.PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.NotificationPage();
    },
  );
}

/// generated route for
/// [_i7.ScheduleFormPage]
class ScheduleFormRoute extends _i8.PageRouteInfo<ScheduleFormRouteArgs> {
  ScheduleFormRoute({
    _i9.Key? key,
    bool isInitialRecurring = false,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         ScheduleFormRoute.name,
         args: ScheduleFormRouteArgs(
           key: key,
           isInitialRecurring: isInitialRecurring,
         ),
         initialChildren: children,
       );

  static const String name = 'ScheduleFormRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScheduleFormRouteArgs>(
        orElse: () => const ScheduleFormRouteArgs(),
      );
      return _i7.ScheduleFormPage(
        key: args.key,
        isInitialRecurring: args.isInitialRecurring,
      );
    },
  );
}

class ScheduleFormRouteArgs {
  const ScheduleFormRouteArgs({this.key, this.isInitialRecurring = false});

  final _i9.Key? key;

  final bool isInitialRecurring;

  @override
  String toString() {
    return 'ScheduleFormRouteArgs{key: $key, isInitialRecurring: $isInitialRecurring}';
  }
}
