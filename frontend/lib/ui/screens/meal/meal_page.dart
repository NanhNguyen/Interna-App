import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/constant/enums.dart';
import '../../../data/model/meal_model.dart';
import '../../di/di_config.dart';
import 'cubit/meal_cubit.dart';
import 'cubit/meal_state.dart';

@RoutePage()
class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  late final MealCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<MealCubit>()..loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          title: const Text(
            'Đăng ký cơm',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<MealCubit, MealState>(
          listener: (context, state) {
            if (state.submitStatus == BaseStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đăng ký cơm thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state.submitStatus == BaseStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Đăng ký thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _cubit.loadMeals(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildRegisterCard(context, state),
                        ),
                      ),
                      if (state.meals.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Lịch đăng ký của bạn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildMealCard(context, state.meals[index]),
                            childCount: state.meals.length,
                          ),
                        ),
                      ] else if (state.status == BaseStatus.success)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rice_bowl_outlined,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chưa có lịch đặt cơm nào',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMealFormSheet(context),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Đăng ký cơm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(BuildContext context, MealState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rice_bowl,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đăng ký suất cơm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Đặt cơm từ Thứ 2 – Thứ 6, có thể lặp lại theo tuần',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showMealFormSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Đăng ký ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, MealModel meal) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final shift = meal.shift.displayName;
    final isRecurring = meal.isRecurring;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isRecurring ? Icons.repeat : Icons.event,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isRecurring && meal.weekdays.isNotEmpty)
                    Text(
                      meal.weekdays.map((w) => w.displayName).join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      'Từ: ${dateFormat.format(meal.startDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (meal.endDate != null)
                    Text(
                      'Đến: ${dateFormat.format(meal.endDate!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  if (meal.note != null && meal.note!.isNotEmpty)
                    Text(
                      meal.note!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            if (isRecurring)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat, size: 12, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Hàng tuần',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _confirmDelete(context, meal.id),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa đăng ký cơm'),
        content: const Text('Bạn có muốn hủy đăng ký suất cơm này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteMeal(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMealFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: _cubit, child: const _MealFormSheet()),
    );
  }
}

class _MealFormSheet extends StatefulWidget {
  const _MealFormSheet();

  @override
  State<_MealFormSheet> createState() => _MealFormSheetState();
}

class _MealFormSheetState extends State<_MealFormSheet> {
  MealShift _selectedShift = MealShift.BOTH;
  bool _isRecurring = true;
  final Set<MealWeekday> _selectedWeekdays = {
    MealWeekday.MONDAY,
    MealWeekday.TUESDAY,
    MealWeekday.WEDNESDAY,
    MealWeekday.THURSDAY,
    MealWeekday.FRIDAY,
  };
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đăng ký cơm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Ca ăn
                  const Text(
                    'Ca ăn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: MealShift.values.map((shift) {
                      final selected = _selectedShift == shift;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedShift = shift),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.orange.shade700
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? Colors.orange.shade700
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: Text(
                              shift.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Toggle lặp lại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lặp lại hàng tuần',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isRecurring,
                        onChanged: (v) => setState(() => _isRecurring = v),
                        activeColor: Colors.orange.shade700,
                      ),
                    ],
                  ),

                  if (_isRecurring) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Chọn thứ (Thứ 2 – Thứ 6)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: MealWeekday.values.map((day) {
                        final selected = _selectedWeekdays.contains(day);
                        return FilterChip(
                          label: Text(day.displayName),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedWeekdays.add(day);
                              } else {
                                _selectedWeekdays.remove(day);
                              }
                            });
                          },
                          selectedColor: Colors.orange.shade700,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Ngày bắt đầu
                  _buildDatePicker(
                    'Từ ngày',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                  const SizedBox(height: 12),

                  // Ngày kết thúc
                  _buildDatePicker(
                    'Đến ngày',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                  const SizedBox(height: 16),

                  // Ghi chú
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú (tuỳ chọn)',
                      hintText: 'ví dụ: không ăn cay...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Nút gửi
                  BlocBuilder<MealCubit, MealState>(
                    buildWhen: (p, c) => p.submitStatus != c.submitStatus,
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.submitStatus == BaseStatus.loading
                              ? null
                              : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: state.submitStatus == BaseStatus.loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Xác nhận đăng ký',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime currentDate,
    ValueChanged<DateTime> onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(currentDate),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_isRecurring && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 ngày trong tuần'),
        ),
      );
      return;
    }

    final data = {
      'shift': _selectedShift.name,
      'isRecurring': _isRecurring,
      'weekdays': _selectedWeekdays.map((w) => w.name).toList(),
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'note': _noteController.text.trim(),
    };

    context.read<MealCubit>().submitMeal(data).then((success) {
      if (success && mounted) {
        Navigator.pop(context);
      }
    });
  }
}
