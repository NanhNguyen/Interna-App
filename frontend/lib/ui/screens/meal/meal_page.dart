import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
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
        final filteredMeals = _getMealsForDay(state.allRegistrations, _overviewDate);
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            
            if (isWide) {
              return Column(
                children: [
                   _buildMealStatsHeader(filteredMeals),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 12,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildCustomCalendarHeader(),
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: _buildCalendarRibbon(state.allRegistrations),
                                ),
                                const SizedBox(height: 24),
                                _buildSummaryCard(filteredMeals),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.people_outline, color: Color(0xFF8B5CF6)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Danh sách đăng ký',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFF9FAFB),
                                  child: _buildOverviewList(filteredMeals),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

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
                    child: state.status == BaseStatus.loading && state.allRegistrations.isEmpty
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
      },
    );
  }

  Widget _buildMealStatsHeader(List<MealModel> filteredMeals) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
           _buildOverviewStatCard(
            'Tổng suất cơm',
            '${filteredMeals.length}',
            'Hôm nay',
            Icons.restaurant_rounded,
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 20),
          _buildOverviewStatCard(
            'Cơm trưa',
            '${filteredMeals.where((m) => m.shift == MealShift.LUNCH).length}',
            'Hệ thống đang hỗ trợ',
            Icons.lunch_dining_rounded,
            const Color(0xFF0EA5E9),
          ),
          const SizedBox(width: 20),
          _buildOverviewStatCard(
            'Lặp lại',
            '${filteredMeals.where((m) => m.isRecurring).length}',
            'Đăng ký hàng tuần',
            Icons.loop_rounded,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStatCard(String title, String value, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
                Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarRibbon(List<MealModel> allMeals) {
    return TableCalendar(
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
                      color: Colors.white,
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
      dayNumColor = Colors.white;
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
            bgColor: const Color(0xFF8B5CF6).withOpacity(0.12),
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
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  'Số suất cần đặt',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Hệ thống tổng hợp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${items.length}',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 28,
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
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              meal.isRecurring ? 'Đăng ký lặp lại hàng tuần' : 'Đăng ký một lần',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 22,
              ),
              onPressed: () => _confirmDelete(context, meal.id),
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
                          'Đăng ký của tôi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMealItem(state.meals[index]),
                        childCount: state.meals.length,
                      ),
                    ),
                  ] else if (state.status != BaseStatus.loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Bạn chưa đăng ký suất ăn nào.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
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
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.restaurant_menu, size: 48, color: Color(0xFF8B5CF6)),
            const SizedBox(height: 16),
            const Text(
              'Đăng ký cơm cho nhân viên',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng ký suất ăn để bộ phận HR chuẩn bị chu đáo nhất nhé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _showMealFormSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Bắt đầu đăng ký',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(MealModel meal) {
    final isRecurring = meal.isRecurring;
    final shift = meal.shift.displayName;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRecurring ? Icons.repeat : Icons.calendar_today,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (isRecurring && meal.weekdays.isNotEmpty)
                  Text(
                    meal.weekdays.map((w) => w.displayName).join(', '),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
                  )
                else
                  Text(
                    'Từ: ${dateFormat.format(meal.startDate)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa đăng ký cơm'),
        content: const Text('Bạn có muốn hủy đăng ký suất cơm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteMeal(id).then((_) {
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
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: const _MealFormSheet(),
      ),
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
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
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
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                const Text('Đăng ký cơm trưa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildInfoBox(),
                      const SizedBox(height: 24),
                      _buildRecurringToggle(),
                      if (_isRecurring) ...[
                        const SizedBox(height: 20),
                        _buildWeekdaySelector(),
                      ],
                      const SizedBox(height: 24),
                      _buildDateSection(
                        _isRecurring ? 'Ngày bắt đầu' : 'Ngày đăng ký',
                        _startDate,
                        (date) => setState(() => _startDate = date),
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: 16),
                        _buildDateSection(
                          'Ngày kết thúc',
                          _endDate,
                          (date) => setState(() => _endDate = date),
                          minDate: _startDate,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildNoteField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF8B5CF6), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hệ thống hiện tại áp dụng cho suất cơm buổi trưa.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lặp lại hàng tuần', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Tự động đăng ký cho tương lai', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Switch(
          value: _isRecurring,
          onChanged: (v) => setState(() => _isRecurring = v),
          activeColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn các thứ trong tuần', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MealWeekday.values.map((day) {
            final selected = _selectedWeekdays.contains(day);
            return FilterChip(
              label: Text(day.displayName),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) _selectedWeekdays.add(day); else _selectedWeekdays.remove(day);
                });
              },
              selectedColor: const Color(0xFF8B5CF6),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection(String label, DateTime date, ValueChanged<DateTime> onPicked, {DateTime? minDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _pickDateResponsive(context, initialDate: date, minimumDate: minDate, onChanged: onPicked),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 12),
                Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickDateResponsive(BuildContext context, {required DateTime initialDate, DateTime? minimumDate, required ValueChanged<DateTime> onChanged}) {
    final isMobileView = MediaQuery.of(context).size.width < 600;
    if (isMobileView) {
      _showScrollingDatePicker(context, initialDate: initialDate, minimumDate: minimumDate, onChanged: onChanged);
    } else {
      _showPremiumDatePickerDialog(context, initialDate: initialDate, minimumDate: minimumDate, onChanged: onChanged);
    }
  }

  void _showPremiumDatePickerDialog(BuildContext context, {required DateTime initialDate, DateTime? minimumDate, required ValueChanged<DateTime> onChanged}) {
    DateTime tempDate = initialDate;
    final primaryColor = const Color(0xFF8B5CF6);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            height: 480,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Sidebar
                Container(
                  width: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CHỌN NGÀY',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE,', 'vi').format(tempDate),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
                            Text(DateFormat('dd MMMM', 'vi').format(tempDate),
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                            Text(DateFormat('yyyy', 'vi').format(tempDate),
                                style: const TextStyle(color: Colors.white60, fontSize: 22, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_month_outlined, color: Colors.white38, size: 54),
                    ],
                  ),
                ),
                // Calendar section
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TableCalendar(
                          focusedDay: tempDate,
                          firstDay: DateTime.now().subtract(const Duration(days: 365)),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          selectedDayPredicate: (day) => isSameDay(tempDate, day),
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                          rowHeight: 52,
                          daysOfWeekHeight: 32,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            headerPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            if (minimumDate != null && selectedDay.isBefore(minimumDate)) return;
                            setDialogState(() => tempDate = selectedDay);
                          },
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.12), shape: BoxShape.circle),
                            todayTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  onChanged(tempDate);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScrollingDatePicker(BuildContext context, {required DateTime initialDate, DateTime? minimumDate, required ValueChanged<DateTime> onChanged}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const Text('Chọn ngày', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Xong')),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate.isBefore(minimumDate ?? initialDate) ? (minimumDate ?? initialDate) : initialDate,
                minimumDate: minimumDate,
                onDateTimeChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ghi chú', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'ví dụ: không ăn cay...',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<MealCubit, MealState>(
      builder: (context, state) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: state.submitStatus == BaseStatus.loading ? null : () => _submit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: state.submitStatus == BaseStatus.loading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Xác nhận đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_isRecurring && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn ít nhất 1 thứ')));
      return;
    }
    final note = _noteController.text.trim();
    final finalEndDate = _isRecurring ? _endDate : _startDate;

    final data = {
      'shift': _selectedShift.name,
      'isRecurring': _isRecurring,
      'weekdays': _isRecurring ? _selectedWeekdays.map((w) => w.name).toList() : [],
      'startDate': _startDate.toIso8601String(),
      'endDate': finalEndDate.toIso8601String(),
      'note': note,
    };

    context.read<MealCubit>().submitMeal(data).then((success) {
      if (success && mounted) Navigator.pop(context);
    });
  }
}
