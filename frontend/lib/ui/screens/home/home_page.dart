import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../data/constant/enums.dart';
import '../../../data/model/schedule_request_model.dart';
import '../../../data/service/auth_service.dart';
import '../../di/di_config.dart';
import '../../router/app_router.gr.dart';
import '../main/cubit/main_cubit.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import '../../../resource/app_strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.scheduleOverview),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 32),
                    onPressed: () =>
                        context.pushRoute(const NotificationRoute()),
                  ),
                  // Badge: only unread notifications (like Facebook bell)
                  if (state.unreadNotificationCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: _buildBadge(
                        state.unreadNotificationCount,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadData(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(state.user?.name ?? 'User'),
                      if (isWide)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildTodayStatus(state.todaySchedule),
                                    _buildQuickActions(context, isWide: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildQuickStats(state),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        top: 15,
                                      ),
                                      child: Text(
                                        AppStrings.recentUpdates,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(50),
                                        child: Text(
                                          AppStrings.noRecentUpdates,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTodayStatus(state.todaySchedule),
                            _buildQuickActions(context, isWide: false),
                            _buildQuickStats(state),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              child: Text(
                                AppStrings.recentUpdates,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Text(
                                  AppStrings.noRecentUpdates,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton: () {
            final role =
                getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
            if (role == UserRole.INTERN || role == UserRole.EMPLOYEE) {
              return FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.repeat,
                              color: Colors.blue,
                            ),
                            title: const Text(AppStrings.recurringLeave),
                            onTap: () {
                              Navigator.pop(context);
                              context.router.push(
                                ScheduleFormRoute(isInitialRecurring: true),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.event,
                              color: Colors.orange,
                            ),
                            title: const Text(AppStrings.adhocLeave),
                            onTap: () {
                              Navigator.pop(context);
                              context.router.push(
                                ScheduleFormRoute(isInitialRecurring: false),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              );
            }
            return null;
          }(),
        );
      },
    );
  }

  /// Shared badge widget used for notification bell and tab badges.
  /// Shows "99+" when count exceeds 99, like Facebook/iOS convention.
  Widget _buildBadge(int count, {Color color = Colors.red}) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.welcomeBack,
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 18, // Increased from 16
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12), // Increased spacing
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 36, // Increased from 32
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus(ScheduleRequestModel? todaySchedule) {
    if (todaySchedule == null) return const SizedBox.shrink();

    final isLeave = todaySchedule.type == ScheduleType.LEAVE;
    final color = Colors.blue; // Consistent blue

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLeave ? Icons.beach_access : Icons.work,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLeave ? AppStrings.onLeaveToday : AppStrings.workingToday,
                    style: TextStyle(
                      color: color.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: 14, // Increased from 12
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLeave
                        ? AppStrings.personalLeave
                        : 'Ca: ${todaySchedule.shift}',
                    style: const TextStyle(
                      fontSize: 22, // Increased from 20
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, {bool isWide = false}) {
    final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
    final isManagerOrHR = role == UserRole.MANAGER || role == UserRole.HR;

    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 0 : 20, 24, isWide ? 0 : 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.quickActions,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: isManagerOrHR
                ? [
                    _buildActionItem(
                      context,
                      AppStrings.requests,
                      Icons.pending_actions,
                      Colors.orange,
                      tabIndex: 1,
                    ),
                    _buildActionItem(
                      context,
                      AppStrings.schedule,
                      Icons.calendar_month,
                      Colors.blue,
                      tabIndex: 2,
                    ),
                    _buildActionItem(
                      context,
                      AppStrings.profile,
                      Icons.person,
                      Colors.green,
                      tabIndex: 3,
                    ),
                  ]
                : [
                    _buildActionItem(
                      context,
                      AppStrings.recurringLeave,
                      Icons.repeat,
                      Colors.blue,
                      onTap: () => context.router.push(
                        ScheduleFormRoute(isInitialRecurring: true),
                      ),
                    ),
                    _buildActionItem(
                      context,
                      AppStrings.adhocLeave,
                      Icons.event_note,
                      Colors.orange,
                      onTap: () => context.router.push(
                        ScheduleFormRoute(isInitialRecurring: false),
                      ),
                    ),
                    _buildActionItem(
                      context,
                      AppStrings.profile,
                      Icons.person,
                      Colors.green,
                      tabIndex: 3,
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    int? tabIndex,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap:
              onTap ??
              () {
                if (tabIndex != null) {
                  context.read<MainCubit>().setIndex(tabIndex);
                }
              },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 72, // Increased from 64
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 34), // Increased from 28
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuickStats(HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard(
            AppStrings.pendingRequests,
            state.pendingCount.toString(),
            Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            AppStrings.totalRequests,
            state.totalCount.toString(),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32, // Increased from 24
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 16, // Increased
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
