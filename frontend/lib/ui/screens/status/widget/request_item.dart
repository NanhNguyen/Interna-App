import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/model/schedule_request_model.dart';
import 'status_badge.dart';
import '../../../../resource/app_strings.dart';

class RequestItem extends StatelessWidget {
  final ScheduleRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RequestItem({
    super.key,
    required this.request,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLeave = request.type == ScheduleType.LEAVE;
    final typeColor = isLeave ? Colors.red : const Color(0xFF8B5CF6);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 6, color: typeColor),
            Expanded(
              child: ListTile(
                onTap: onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  request.description ??
                      (isLeave ? AppStrings.leave : AppStrings.work),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.shift}: ${request.shift}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(request.startDate),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(status: request.status),
                    if (request.status == RequestStatus.PENDING &&
                        onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
