import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/di_config.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/model/schedule_request_model.dart';
import '../../../../data/service/auth_service.dart';
import 'cubit/status_cubit.dart';
import 'cubit/status_state.dart';
import 'widget/request_item.dart';
import '../../../resource/app_strings.dart';
import '../main/cubit/main_cubit.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StatusCubit>()..loadRequests(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
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
            elevation: 0,
            title: const Text(
              AppStrings.myRequestStatus,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.read<MainCubit>().setIndex(0),
            ),
            centerTitle: true,
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ), // Increased
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ), // Increased
              tabs: [
                Tab(text: AppStrings.pending.toUpperCase()),
                Tab(text: AppStrings.approved.toUpperCase()),
                Tab(text: AppStrings.rejected.toUpperCase()),
              ],
            ),
          ),
          body: BlocBuilder<StatusCubit, StatusState>(
            builder: (context, state) {
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
                  _buildRequestList(context, state, pendingRequests),
                  _buildRequestList(context, state, approvedRequests),
                  _buildRequestList(context, state, rejectedRequests),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestList(
    BuildContext context,
    StatusState state,
    List<ScheduleRequestModel> requests,
  ) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<StatusCubit>().loadRequests(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const Text(AppStrings.noRequestsFound),
          ),
        ),
      );
    }

    final items = requests.groupByGroupId();

    return RefreshIndicator(
      onRefresh: () => context.read<StatusCubit>().loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length + 1, // +1 for status bar
        itemBuilder: (context, index) {
          if (index == 0) {
            // Only show status bar in "ALL" tab or as a summary?
            // Let's keep it simple and just show the list
            return const SizedBox.shrink();
          }
          final item = items[index - 1];
          if (item is List<ScheduleRequestModel>) {
            return _buildGroupedItem(context, item);
          } else {
            final req = item as ScheduleRequestModel;
            return RequestItem(
              request: req,
              onDelete: req.status == RequestStatus.PENDING
                  ? () => _confirmDelete(context, () {
                      context.read<StatusCubit>().deleteRequest(req.id);
                    })
                  : null,
            );
          }
        },
      ),
    );
  }

  Widget _buildGroupedItem(
    BuildContext context,
    List<ScheduleRequestModel> group,
  ) {
    final first = group.first;
    final isPending = first.status == RequestStatus.PENDING;
    final color = first.status == RequestStatus.PENDING
        ? Colors.orange
        : (first.status == RequestStatus.APPROVED ? Colors.green : Colors.red);

    // For interns, hide the count since they only have their own schedules
    final role = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
    final isIntern = role == UserRole.INTERN || role == UserRole.EMPLOYEE;
    final subtitle = isIntern
        ? first.status.displayName
        : '${group.length} ${AppStrings.itemsCount} • ${first.status.displayName}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          first.description ?? AppStrings.batchRequest,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ), // Increased from 16
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 16),
        ), // Increased from 14
        leading: Icon(
          first.isRecurring ? Icons.repeat : Icons.event_note,
          color: const Color(0xFF8B5CF6),
          size: 28, // Increased
        ),
        trailing: isPending
            ? IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 28,
                ), // Increased
                onPressed: () => _confirmDelete(context, () {
                  context.read<StatusCubit>().deleteBatchRequests(
                    first.groupId!,
                  );
                }),
              )
            : null,
        children: group
            .map(
              (req) => RequestItem(
                request: req,
                onDelete: isPending
                    ? () => _confirmDelete(context, () {
                        context.read<StatusCubit>().deleteRequest(req.id);
                      })
                    : null,
              ),
            )
            .toList(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
