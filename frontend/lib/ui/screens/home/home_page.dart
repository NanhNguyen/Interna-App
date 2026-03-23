import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/constant/enums.dart';
import '../../../data/model/schedule_request_model.dart';
import '../../../data/service/auth_service.dart';
import '../../di/di_config.dart';
import '../main/cubit/main_cubit.dart';
import '../schedule_form/schedule_form_modal.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import '../../../resource/app_strings.dart';
import '../accounts/create_account_modal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
        final isManagerOrHR = role == UserRole.MANAGER || role == UserRole.HR;

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text(
              AppStrings.scheduleOverview,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: const [SizedBox(width: 10)],
            elevation: 0,
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
                      _buildHeader(
                        state.user?.name ?? 'User',
                        isWide: isWide,
                        isManagerOrHR: isManagerOrHR,
                      ),
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
                                    _buildQuickActions(
                                      context,
                                      state,
                                      isWide: true,
                                    ),
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
                            _buildQuickActions(context, state, isWide: false),
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
            // Only Intern and Employee can register leave
            if (role == UserRole.INTERN || role == UserRole.EMPLOYEE) {
              return FloatingActionButton.extended(
                onPressed: () {
                  showScheduleFormModal(context, isInitialRecurring: false);
                },
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text(
                  AppStrings.registerLeave,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
            return null;
          }(),
        );
      },
    );
  }

  Widget _buildHeader(
    String name, {
    bool isWide = false,
    bool isManagerOrHR = false,
  }) {
    if (isWide) {
      return Container(
        padding: const EdgeInsets.fromLTRB(40, 32, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.welcomeBack}, $name!',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isManagerOrHR
                  ? 'Đây là tổng quan các yêu cầu và lịch trình cần quản lý.'
                  : 'Đây là tổng quan lịch trình và công việc của bạn.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.welcomeBack,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
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
    final color = const Color(0xFF8B5CF6); // Consistent blue

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
                      color: color,
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

  Widget _buildQuickActions(
    BuildContext context,
    HomeState state, {
    bool isWide = false,
  }) {
    final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;

    List<Widget> actions;
    if (role == UserRole.MANAGER) {
      actions = [
        _buildActionItem(
          context,
          AppStrings.requests,
          Icons.pending_actions,
          Colors.orange,
          tabIndex: 1,
          badgeCount: state.pendingCount,
        ),
        _buildActionItem(
          context,
          AppStrings.schedule,
          Icons.calendar_month,
          const Color(0xFF8B5CF6),
          tabIndex: 2,
        ),
        _buildActionItem(
          context,
          AppStrings.notifications,
          Icons.notifications,
          Colors.indigo,
          tabIndex: 3,
          badgeCount: state.unreadNotificationCount,
        ),
        _buildActionItem(
          context,
          AppStrings.profile,
          Icons.person,
          Colors.green,
          tabIndex: 4,
        ),
      ];
    } else if (role == UserRole.HR) {
      actions = [
        _buildActionItem(
          context,
          'Thống kê cơm',
          Icons.rice_bowl,
          Colors.deepOrange,
          tabIndex: 1,
        ),
        _buildActionItem(
          context,
          AppStrings.schedule,
          Icons.calendar_month,
          const Color(0xFF8B5CF6),
          tabIndex: 2,
        ),
        _buildActionItem(
          context,
          AppStrings.accounts,
          Icons.people,
          Colors.purple,
          onTap: () => showCreateAccountModal(context),
        ),
        _buildActionItem(
          context,
          'Bản tin HR',
          Icons.campaign,
          Colors.indigo,
          tabIndex: 4,
        ),
        _buildActionItem(
          context,
          AppStrings.notifications,
          Icons.notifications,
          Colors.teal,
          tabIndex: 5,
          badgeCount: state.unreadNotificationCount,
        ),
        _buildActionItem(
          context,
          AppStrings.profile,
          Icons.person,
          Colors.green,
          tabIndex: 6,
        ),
      ];
    } else {
      // Intern/Employee
      actions = [
        _buildActionItem(
          context,
          'Đặt cơm',
          Icons.rice_bowl,
          Colors.deepOrange,
          tabIndex: 1,
        ),
        _buildActionItem(
          context,
          AppStrings.status,
          Icons.assignment,
          Colors.teal,
          tabIndex: 3,
        ),
        _buildActionItem(
          context,
          AppStrings.announcements,
          Icons.campaign,
          Colors.indigo,
          tabIndex: 4,
        ),
        _buildActionItem(
          context,
          'Đăng ký nghỉ',
          Icons.event_note,
          Colors.orange,
          onTap: () =>
              showScheduleFormModal(context, isInitialRecurring: false),
        ),
        _buildActionItem(
          context,
          AppStrings.notifications,
          Icons.notifications,
          const Color(0xFF8B5CF6),
          tabIndex: 5,
          badgeCount: state.unreadNotificationCount,
        ),
        _buildActionItem(
          context,
          AppStrings.profile,
          Icons.person,
          Colors.green,
          tabIndex: 6,
        ),
      ];
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 0 : 20, 24, isWide ? 0 : 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.quickActions,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: actions,
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
    int badgeCount = 0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
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
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickStats(HomeState state) {
    final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
    final isManagerOrHR = role == UserRole.MANAGER || role == UserRole.HR;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard(
            isManagerOrHR ? 'Yêu cầu cần duyệt' : AppStrings.pendingRequests,
            state.pendingCount.toString(),
            Colors.orange,
          ),
          if (!isManagerOrHR) ...[
            const SizedBox(width: 16),
            _buildStatCard(
              AppStrings.totalRequests,
              state.totalCount.toString(),
              const Color(0xFF8B5CF6),
            ),
          ],
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
