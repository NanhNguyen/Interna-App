import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../di/di_config.dart';
import '../../../../data/model/schedule_request_model.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/service/auth_service.dart';
import 'cubit/manager_requests_cubit.dart';
import 'cubit/manager_requests_state.dart';
import '../main/cubit/main_cubit.dart';
import '../../../resource/app_strings.dart';

@RoutePage()
class ManagerRequestPage extends StatelessWidget {
  const ManagerRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final userRole = authService.currentUser?.role ?? UserRole.INTERN;
    final isManager = userRole == UserRole.MANAGER;

    return BlocProvider(
      create: (context) => getIt<ManagerRequestsCubit>()..loadAllRequests(),
      child: DefaultTabController(
        length: isManager ? 1 : 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              isManager
                  ? AppStrings.manageRequests
                  : AppStrings.allRequestsView,
            ),
            bottom: isManager
                ? null
                : TabBar(
                    tabs: [
                      Tab(text: AppStrings.pending.toUpperCase()),
                      Tab(text: AppStrings.approved.toUpperCase()),
                      Tab(text: AppStrings.rejected.toUpperCase()),
                    ],
                  ),
          ),
          body: BlocConsumer<ManagerRequestsCubit, ManagerRequestsState>(
            listenWhen: (prev, curr) =>
                curr.actionResult != null &&
                curr.actionResult != prev.actionResult,
            listener: (context, state) {
              final isApproved = state.actionResult == 'APPROVED';
              final targetIndex = userRole == UserRole.MANAGER ? 2 : 1;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isApproved
                            ? 'Đã duyệt yêu cầu thành công!'
                            : 'Đã từ chối yêu cầu.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: isApproved
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                  action: isApproved
                      ? SnackBarAction(
                          label: 'Xem lịch',
                          textColor: Colors.white,
                          onPressed: () {
                            // Use getIt directly to avoid stale context issues
                            getIt<MainCubit>().setIndex(targetIndex);
                          },
                        )
                      : null,
                ),
              );

              // Auto-navigate to schedule tab after approval
              if (isApproved) {
                getIt<MainCubit>().setIndex(targetIndex);
              }
            },
            builder: (context, state) {
              if (state.status == BaseStatus.loading &&
                  state.requests.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (isManager) {
                return _buildManagerView(context, state);
              } else {
                return _buildHRView(context, state);
              }
            },
          ),
        ),
      ),
    );
  }

  // MANAGER view: only pending, with approve/reject buttons
  Widget _buildManagerView(BuildContext context, ManagerRequestsState state) {
    final pendingRequests = state.requests
        .where((r) => r.status == RequestStatus.PENDING)
        .toList();

    if (pendingRequests.isEmpty) {
      return const Center(child: Text(AppStrings.noPendingRequests));
    }

    final displayItems = pendingRequests.groupByGroupId();

    return RefreshIndicator(
      onRefresh: () => context.read<ManagerRequestsCubit>().loadAllRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          if (item is List<ScheduleRequestModel>) {
            return _buildGroupedCard(context, item, showActions: true);
          } else {
            return _buildRequestCard(
              context,
              item as ScheduleRequestModel,
              showActions: true,
            );
          }
        },
      ),
    );
  }

  // HR view: all requests in tabs, view only (no approve/reject)
  Widget _buildHRView(BuildContext context, ManagerRequestsState state) {
    final pendingRequests = state.requests
        .where((r) => r.status == RequestStatus.PENDING)
        .toList();
    final approvedRequests = state.requests
        .where((r) => r.status == RequestStatus.APPROVED)
        .toList();
    final rejectedRequests = state.requests
        .where((r) => r.status == RequestStatus.REJECTED)
        .toList();

    return TabBarView(
      children: [
        _buildRequestListView(context, pendingRequests, showActions: false),
        _buildRequestListView(context, approvedRequests, showActions: false),
        _buildRequestListView(context, rejectedRequests, showActions: false),
      ],
    );
  }

  Widget _buildRequestListView(
    BuildContext context,
    List<ScheduleRequestModel> requests, {
    required bool showActions,
  }) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ManagerRequestsCubit>().loadAllRequests(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const Text(AppStrings.noRequestsCategory),
          ),
        ),
      );
    }

    final displayItems = requests.groupByGroupId();

    return RefreshIndicator(
      onRefresh: () => context.read<ManagerRequestsCubit>().loadAllRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          if (item is List<ScheduleRequestModel>) {
            return _buildGroupedCard(context, item, showActions: showActions);
          } else {
            return _buildRequestCard(
              context,
              item as ScheduleRequestModel,
              showActions: showActions,
            );
          }
        },
      ),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context,
    List<ScheduleRequestModel> group, {
    required bool showActions,
  }) {
    final first = group.first;
    final isRecurring = first.isRecurring;
    final color = Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    isRecurring
                        ? Icons.repeat_rounded
                        : Icons.event_note_rounded,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first.userMetadata?['name'] ?? AppStrings.employee,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isRecurring
                            ? AppStrings.batchRecurringRequest
                            : AppStrings.batchIndividualDays,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              '${AppStrings.shift}: ${first.shift}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (isRecurring) ...[
              Text(
                '${AppStrings.duration}: ${DateFormat('dd/MM').format(first.startDate)} - ${DateFormat('dd/MM').format(first.endDate)}',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: group
                    .map(
                      (r) => Chip(
                        label: Text(
                          r.weekday?.substring(0, 3) ?? '',
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              const Text(AppStrings.datesLabel, style: TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: group
                    .map(
                      (r) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          DateFormat('dd/MM').format(r.startDate),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (first.description != null && first.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${AppStrings.note}: ${first.description}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],
            if (showActions && first.status == RequestStatus.PENDING) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context
                          .read<ManagerRequestsCubit>()
                          .rejectBatch(first.groupId!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(AppStrings.rejectAll),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context
                          .read<ManagerRequestsCubit>()
                          .approveBatch(first.groupId!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(AppStrings.approveAll),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    ScheduleRequestModel req, {
    required bool showActions,
  }) {
    final statusColor = req.status == RequestStatus.PENDING
        ? Colors.orange
        : (req.status == RequestStatus.APPROVED ? Colors.green : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req.userMetadata?['name'] ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('${AppStrings.shift}: ${req.shift}'),
            Text('${AppStrings.weekday}: ${req.weekday ?? ''}'),
            Text(
              '${AppStrings.datesLabel} ${DateFormat('yyyy-MM-dd').format(req.startDate)}',
            ),
            if (showActions && req.status == RequestStatus.PENDING) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context
                          .read<ManagerRequestsCubit>()
                          .rejectRequest(req.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(AppStrings.reject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context
                          .read<ManagerRequestsCubit>()
                          .approveRequest(req.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(AppStrings.approve),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
