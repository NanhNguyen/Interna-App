import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../di/di_config.dart';
import '../../../data/constant/enums.dart';
import 'cubit/schedule_form_cubit.dart';
import 'cubit/schedule_form_state.dart';
import '../../../resource/app_strings.dart';
import '../home/cubit/home_cubit.dart';

/// Shows the schedule registration form as a modal dialog.
/// Returns `true` if the form was submitted successfully, `null` otherwise.
Future<bool?> showScheduleFormModal(
  BuildContext context, {
  required bool isInitialRecurring,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) =>
        ScheduleFormModal(isInitialRecurring: isInitialRecurring),
  );
}

class ScheduleFormModal extends StatelessWidget {
  final bool isInitialRecurring;

  const ScheduleFormModal({super.key, required this.isInitialRecurring});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ScheduleFormCubit>()
            ..setInitialMode(isRecurring: isInitialRecurring),
      child: BlocConsumer<ScheduleFormCubit, ScheduleFormState>(
        listener: (context, state) {
          if (state.status == BaseStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.requestSubmitted),
                backgroundColor: Colors.green,
              ),
            );
            getIt<HomeCubit>().loadData();
            Navigator.of(context).pop(true);
          } else if (state.status == BaseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? AppStrings.submissionFailed,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final color = Colors.blue.shade700;
          final isRecurring = state.isRecurring;
          final isLoading = state.status == BaseStatus.loading;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 480,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isRecurring ? Icons.repeat : Icons.event_note,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isRecurring
                                ? AppStrings.recurringLeave
                                : AppStrings.adhocLeave,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle recurring / adhoc
                          _buildToggleRow(context, state, color),
                          const SizedBox(height: 24),

                          // Date section
                          _buildSectionTitle(
                            isRecurring
                                ? AppStrings.recurringDuration
                                : AppStrings.chooseDays,
                          ),
                          if (isRecurring)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateCard(
                                    context,
                                    label: AppStrings.start,
                                    date: state.startDate ?? DateTime.now(),
                                    color: color,
                                    onTap: () => _showScrollingDatePicker(
                                      context,
                                      initialDate:
                                          state.startDate ?? DateTime.now(),
                                      onChanged: (date) => context
                                          .read<ScheduleFormCubit>()
                                          .updateField(startDate: date),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildDateCard(
                                    context,
                                    label: AppStrings.until,
                                    date: state.endDate ?? DateTime.now(),
                                    color: color,
                                    onTap: () => _showScrollingDatePicker(
                                      context,
                                      initialDate:
                                          state.endDate ?? DateTime.now(),
                                      minimumDate: state.startDate,
                                      onChanged: (date) => context
                                          .read<ScheduleFormCubit>()
                                          .updateField(endDate: date),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            _buildMultiDatePicker(context, state, color),
                          const SizedBox(height: 24),

                          // Weekday selector (recurring only)
                          if (isRecurring) ...[
                            _buildSectionTitle(AppStrings.repeatOn),
                            _buildWeekdaySelector(context, state, color),
                            const SizedBox(height: 24),
                          ],

                          // Shift dropdown
                          _buildSectionTitle(AppStrings.shift),
                          _buildGlassDropdown(
                            value: state.shift,
                            items: [
                              AppStrings.morning,
                              AppStrings.afternoon,
                              AppStrings.allDay,
                            ],
                            onChanged: (v) => context
                                .read<ScheduleFormCubit>()
                                .updateField(shift: v),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          _buildSectionTitle(AppStrings.descriptionLabel),
                          TextField(
                            onChanged: (v) => context
                                .read<ScheduleFormCubit>()
                                .updateField(description: v),
                            maxLines: 2,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: AppStrings.addNotes,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Icon(Icons.notes_rounded),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),

                  // ── Footer / Submit button ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<ScheduleFormCubit>().submit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: color.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isRecurring
                                    ? AppStrings.submitLeave
                                    : AppStrings.confirmRegistration,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────
  // Helper widgets
  // ──────────────────────────────────

  Widget _buildToggleRow(
    BuildContext context,
    ScheduleFormState state,
    Color color,
  ) {
    final isRecurring = state.isRecurring;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showIcons = constraints.maxWidth > 200;
          return Row(
            children: [
              _buildToggleBtn(
                context,
                label: AppStrings.recurringLeave,
                icon: Icons.repeat,
                selected: isRecurring,
                color: color,
                showIcon: showIcons,
                onTap: () => context.read<ScheduleFormCubit>().updateField(
                  isRecurring: true,
                ),
              ),
              _buildToggleBtn(
                context,
                label: AppStrings.adhocLeave,
                icon: Icons.event_note,
                selected: !isRecurring,
                color: color,
                showIcon: showIcons,
                onTap: () => context.read<ScheduleFormCubit>().updateField(
                  isRecurring: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
    bool showIcon = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector(
    BuildContext context,
    ScheduleFormState state,
    Color color,
  ) {
    final weekdayOptions = {
      'MONDAY': 'Th 2',
      'TUESDAY': 'Th 3',
      'WEDNESDAY': 'Th 4',
      'THURSDAY': 'Th 5',
      'FRIDAY': 'Th 6',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weekdayOptions.entries.map((entry) {
        final dbKey = entry.key;
        final label = entry.value;
        final isSelected = state.selectedWeekdays.contains(dbKey);
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) =>
              context.read<ScheduleFormCubit>().toggleWeekday(dbKey),
          selectedColor: color,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiDatePicker(
    BuildContext context,
    ScheduleFormState state,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.selectedDates.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedDates
                .map(
                  (date) => Chip(
                    label: Text(DateFormat('EEE, dd/MM').format(date)),
                    onDeleted: () =>
                        context.read<ScheduleFormCubit>().toggleDate(date),
                    backgroundColor: color.withOpacity(0.1),
                    deleteIconColor: color,
                    labelStyle: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(colorScheme: ColorScheme.light(primary: color)),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              // ignore: use_build_context_synchronously
              context.read<ScheduleFormCubit>().toggleDate(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.addDate,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required String label,
    required DateTime date,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd/MM').format(date),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              DateFormat('yyyy').format(date),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showScrollingDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minimumDate,
    required ValueChanged<DateTime> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                    const Text(
                      AppStrings.selectDate,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.done),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime:
                      initialDate.isBefore(minimumDate ?? initialDate)
                      ? (minimumDate ?? initialDate)
                      : initialDate,
                  minimumDate: minimumDate,
                  onDateTimeChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
