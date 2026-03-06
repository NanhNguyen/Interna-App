import 'package:auto_route/auto_route.dart';
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

@RoutePage()
class ScheduleFormPage extends StatelessWidget {
  final bool isInitialRecurring;

  const ScheduleFormPage({super.key, this.isInitialRecurring = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
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
            // Refresh home data so badge & pending count update
            getIt<HomeCubit>().loadData();
            context.router.maybePop(true);
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
          final color = Colors.blue.shade700; // Consistent blue
          final isRecurring = state.isRecurring;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isRecurring ? AppStrings.recurringLeave : AppStrings.adhocLeave,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: color,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, color.withOpacity(0.05)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const SizedBox.shrink(),
                        const SizedBox(height: 32),
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
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
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
                        const SizedBox(height: 32),
                        if (isRecurring) ...[
                          _buildSectionTitle(AppStrings.repeatOn),
                          _buildWeekdaySelector(context, state, color),
                          const SizedBox(height: 32),
                        ],
                        _buildSectionTitle(AppStrings.shift),
                        _buildGlassDropdown(
                          label: AppStrings.workingShift,
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
                        const SizedBox(height: 32),
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
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.status == BaseStatus.loading
                                ? null
                                : () => context
                                      .read<ScheduleFormCubit>()
                                      .submit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: color.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.status == BaseStatus.loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
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
                                      fontSize: 20, // Increased from 18
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector(
    BuildContext context,
    ScheduleFormState state,
    Color color,
  ) {
    // Keys are DB values (English), labels are display text (Vietnamese)
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
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                    label: Text(DateFormat('EEE, MMM dd').format(date)),
                    onDeleted: () =>
                        context.read<ScheduleFormCubit>().toggleDate(date),
                    backgroundColor: color.withOpacity(0.1),
                    deleteIconColor: color,
                    labelStyle: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
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
              context.read<ScheduleFormCubit>().toggleDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: color),
                const SizedBox(width: 8),
                Text(
                  AppStrings.addDate,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
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
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
