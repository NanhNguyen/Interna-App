import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../resource/app_strings.dart';
import '../../../data/constant/enums.dart';
import '../../../data/model/meal_model.dart';
import '../../../data/service/auth_service.dart';
import '../../di/di_config.dart';
import 'cubit/meal_cubit.dart';
import 'cubit/meal_state.dart';

import '../main/cubit/main_cubit.dart';

@RoutePage()
class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage>
    with SingleTickerProviderStateMixin {
  late final MealCubit _cubit;
  TabController? _tabController;
  DateTime _overviewDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _overviewDate = DateTime.now();
    _selectedDay = _overviewDate;
    _focusedDay = _overviewDate;

    _cubit = getIt<MealCubit>()..loadMeals();
    final role = getIt<AuthService>().currentUser?.role;
    if (role == UserRole.HR) {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
      _cubit.loadAllRegistrations();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  bool get _isHR => getIt<AuthService>().currentUser?.role == UserRole.HR;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
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
          foregroundColor: Colors.white,
          title: const Text(
            'Lịch ăn cơm',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.read<MainCubit>().setIndex(0),
          ),
          centerTitle: true,
          bottom: _isHR
              ? TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Của tôi'),
                    Tab(text: 'Thống kê'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                )
              : null,
          elevation: 0,
        ),
        body: _isHR
            ? TabBarView(
                controller: _tabController,
                children: [_buildMyMealsView(), _buildOverviewView()],
              )
            : _buildMyMealsView(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMealFormSheet(context),
          backgroundColor: const Color(0xFF8B5CF6),
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

  // --- HR Overview View ---
  Widget _buildOverviewView() {
    return BlocBuilder<MealCubit, MealState>(
      builder: (context, state) {
        final filteredMeals = _getMealsForDay(
          state.allRegistrations,
          _overviewDate,
        );
        return RefreshIndicator(
          onRefresh: () => _cubit.loadAllRegistrations(),
          child: Column(
            children: [
              _buildCustomCalendarHeader(),
              _buildCalendarRibbon(state.allRegistrations),
              if (state.status == BaseStatus.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade50,
                  width: double.infinity,
                  child: Text(
                    'Lỗi: ${state.errorMessage}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child:
                    state.status == BaseStatus.loading &&
                        state.allRegistrations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _buildSummaryCard(filteredMeals),
                          Expanded(child: _buildOverviewList(filteredMeals)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarRibbon(List<MealModel> allMeals) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: TableCalendar(
        headerVisible: false,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.week,
        availableCalendarFormats: const {CalendarFormat.week: 'Week'},
        locale: 'vi',
        rowHeight: 110,
        daysOfWeekHeight: 40,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
          weekendStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _overviewDate = selectedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final text = DateFormat.E('vi').format(day);
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  color: day.weekday == DateTime.sunday
                      ? Colors.redAccent
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) => _buildWeekDayCell(
            day,
            allMeals,
            isSelected: false,
            isToday: false,
          ),
          todayBuilder: (context, day, focusedDay) => _buildWeekDayCell(
            day,
            allMeals,
            isSelected: false,
            isToday: true,
          ),
          selectedBuilder: (context, day, focusedDay) => _buildWeekDayCell(
            day,
            allMeals,
            isSelected: true,
            isToday: false,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCalendarHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              DateFormat.yMMMM('vi').format(_focusedDay).toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                    _overviewDate = DateTime.now();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    AppStrings.today,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white, // Changed from indigo
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildNavBtn(
                Icons.chevron_left,
                () => setState(() {
                  _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                }),
              ),
              const SizedBox(width: 8),
              _buildNavBtn(
                Icons.chevron_right,
                () => setState(() {
                  _focusedDay = _focusedDay.add(const Duration(days: 7));
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildWeekDayCell(
    DateTime day,
    List<MealModel> allMeals, {
    required bool isSelected,
    required bool isToday,
  }) {
    final dayMeals = _getMealsForDay(allMeals, day);
    final count = dayMeals.length;
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color dayNumColor;
    Color bgColor;
    Color borderColor;
    if (isSelected) {
      bgColor = const Color(0xFF8B5CF6);
      dayNumColor = Colors.white;
      borderColor = const Color(0xFF8B5CF6);
    } else if (isToday) {
      bgColor = const Color(0xFF8B5CF6);
      dayNumColor = Colors.white; // Changed from indigo
      borderColor = const Color(0xFF8B5CF6);
    } else if (isWeekend) {
      bgColor = Colors.grey.shade50;
      dayNumColor = Colors.grey.shade400;
      borderColor = Colors.transparent;
    } else {
      bgColor = Colors.transparent;
      dayNumColor = Colors.black87;
      borderColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: dayNumColor,
            ),
          ),
          const SizedBox(height: 4),
          _buildShiftBadge(
            label: 'Trưa',
            count: count,
            color: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFF8B5CF6).withOpacity(0.12), // Added opacity for contrast
            isSelected: isSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftBadge({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required bool isSelected,
  }) {
    final hasMark = count > 0;
    final bColor = !hasMark
        ? (isSelected ? Colors.white.withOpacity(0.1) : Colors.grey.shade100)
        : (isSelected ? Colors.white.withOpacity(0.25) : bgColor);

    final lColor = !hasMark
        ? (isSelected ? Colors.white24 : Colors.grey.shade300)
        : (isSelected ? Colors.white : color);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 28,
      decoration: BoxDecoration(
        color: bColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          hasMark ? '$count' : label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: lColor,
          ),
        ),
      ),
    );
  }

  List<MealModel> _getMealsForDay(List<MealModel> meals, DateTime day) {
    return meals.where((m) {
      final date = DateTime(day.year, day.month, day.day);
      final start = DateTime(
        m.startDate.year,
        m.startDate.month,
        m.startDate.day,
      );
      final end = m.endDate != null
          ? DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day)
          : start;

      bool isInRange =
          (date.isAtSameMomentAs(start) ||
          (date.isAfter(start) &&
              date.isBefore(end.add(const Duration(days: 1)))) ||
          date.isAtSameMomentAs(end));

      if (!isInRange) return false;

      if (m.isRecurring) {
        return m.weekdays.any((w) => w.weekdayNumber == day.weekday);
      }

      return true;
    }).toList();
  }

  Widget _buildSummaryCard(List<MealModel> items) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng suất cơm cần đặt',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hôm nay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${items.length}',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewList(List<MealModel> items) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_meals_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không có ai đăng ký cơm ngày này',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử chọn ngày khác hoặc kéo xuống để tải lại',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final meal = items[index];
        final name = meal.userMetadata?['name'] ?? 'Ẩn danh';
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white, // Changed from indigo
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              meal.isRecurring ? 'Đăng ký lặp lại' : 'Đăng ký một lần',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (meal.note != null && meal.note!.isNotEmpty)
                  Tooltip(
                    message: meal.note,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.note,
                        size: 18,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context, meal.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- My Meals View ---
  Widget _buildMyMealsView() {
    return BlocConsumer<MealCubit, MealState>(
      listener: (context, state) {
        if (state.submitStatus == BaseStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.submitStatus == BaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Thất bại'),
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
                              style: TextStyle(color: Colors.grey.shade600),
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
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rice_bowl,
                    color: Colors.white, // Changed from indigo
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đăng ký cơm trưa',
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
                  backgroundColor: const Color(0xFF8B5CF6),
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
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isRecurring ? Icons.repeat : Icons.event,
                color: Colors.white, // Changed from indigo
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B5CF6),
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
              _cubit.deleteMeal(id).then((_) {
                // If HR, reload overview after deleting
                if (_isHR) _cubit.loadMealOverview(_overviewDate);
              });
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
  final MealShift _selectedShift = MealShift.LUNCH;
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
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
              'Đăng ký cơm trưa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Bạn đang đăng ký cơm cho buổi trưa',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Chọn các thứ trong tuần',
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
                              if (val)
                                _selectedWeekdays.add(day);
                              else
                                _selectedWeekdays.remove(day);
                            });
                          },
                          selectedColor: Colors.indigo.shade700,
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
                  _buildDatePicker(
                    _isRecurring ? 'Từ ngày' : 'Ngày đăng ký',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      'Đến ngày',
                      _endDate,
                      (date) => setState(() => _endDate = date),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                  BlocBuilder<MealCubit, MealState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.submitStatus == BaseStatus.loading
                              ? null
                              : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
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
            Icon(Icons.calendar_today, size: 18, color: Colors.indigo.shade300),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_isRecurring && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chọn ít nhất 1 thứ')));
      return;
    }
    final note = _noteController.text.trim();

    // If not recurring, end date should be same as start date
    final finalEndDate = _isRecurring ? _endDate : _startDate;

    final data = {
      'shift': _selectedShift.name,
      'isRecurring': _isRecurring,
      'weekdays': _isRecurring
          ? _selectedWeekdays.map((w) => w.name).toList()
          : [],
      'startDate': _startDate.toIso8601String(),
      'endDate': finalEndDate.toIso8601String(),
      'note': note,
    };

    context.read<MealCubit>().submitMeal(data).then((success) {
      if (success && mounted) Navigator.pop(context);
    });
  }
}
