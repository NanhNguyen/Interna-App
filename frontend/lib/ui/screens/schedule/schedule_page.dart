import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../di/di_config.dart';
import '../../../../data/model/schedule_request_model.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/service/auth_service.dart';
import 'cubit/schedule_cubit.dart';
import 'cubit/schedule_state.dart';
import '../../../resource/app_strings.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final UserRole _userRole;
  final TextEditingController _searchController = TextEditingController();
  String _filterEmployee = '';

  @override
  void initState() {
    super.initState();
    _userRole = getIt<AuthService>().currentUser?.role ?? UserRole.INTERN;
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isManagerOrHR =
        _userRole == UserRole.MANAGER || _userRole == UserRole.HR;

    return BlocProvider(
      create: (context) => getIt<ScheduleCubit>()..loadSchedules(_userRole),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isManagerOrHR
                ? AppStrings.staffSchedule
                : AppStrings.myWorkSchedule,
          ),
          elevation: 0,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.today_rounded),
                tooltip: 'Hôm nay',
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                },
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<ScheduleCubit>().loadSchedules(_userRole),
              ),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Global search bar — filters both tabs simultaneously
              if (isManagerOrHR) _buildSearchBar(),
              Container(
                color: Colors.blue,
                child: const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18, // Increased from default
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                    fontSize: 17, // Increased from default
                  ),
                  tabs: [
                    Tab(text: AppStrings.recurringLeave),
                    Tab(text: AppStrings.adhocLeave),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) {
                    if (state.status == BaseStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return TabBarView(
                      children: [
                        _buildCalendarTab(context, state, isManagerOrHR, true),
                        _buildCalendarTab(context, state, isManagerOrHR, false),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTab(
    BuildContext context,
    ScheduleState state,
    bool isManagerOrHR,
    bool isRecurringTab,
  ) {
    final format = isRecurringTab ? CalendarFormat.week : CalendarFormat.month;

    // Filter the schedules by employee name if search is active
    final filteredSchedules = isManagerOrHR && _filterEmployee.isNotEmpty
        ? state.approvedSchedules.where((s) {
            final name = (s.userMetadata?['name'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(_filterEmployee.toLowerCase());
          }).toList()
        : state.approvedSchedules;

    return RefreshIndicator(
      onRefresh: () => context.read<ScheduleCubit>().loadSchedules(_userRole),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final calendarWidget = Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: format,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              locale: 'vi',
              rowHeight: format == CalendarFormat.week ? 180 : 80,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              daysOfWeekHeight: 45,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                weekendStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              eventLoader: (day) => _getSchedulesForDay(
                filteredSchedules,
                day,
              ).where((s) => s.isRecurring == isRecurringTab).toList(),
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
                        fontSize: 15,
                      ),
                    ),
                  );
                },
                defaultBuilder: format == CalendarFormat.week
                    ? (context, day, focusedDay) => _buildWeekDayCell(
                        day,
                        filteredSchedules
                            .where((s) => s.isRecurring == isRecurringTab)
                            .toList(),
                        isSelected: false,
                        isToday: false,
                        isManagerOrHR: isManagerOrHR,
                      )
                    : null,
                todayBuilder: format == CalendarFormat.week
                    ? (context, day, focusedDay) => _buildWeekDayCell(
                        day,
                        filteredSchedules
                            .where((s) => s.isRecurring == isRecurringTab)
                            .toList(),
                        isSelected: false,
                        isToday: true,
                        isManagerOrHR: isManagerOrHR,
                      )
                    : null,
                selectedBuilder: format == CalendarFormat.week
                    ? (context, day, focusedDay) => _buildWeekDayCell(
                        day,
                        filteredSchedules
                            .where((s) => s.isRecurring == isRecurringTab)
                            .toList(),
                        isSelected: true,
                        isToday: false,
                        isManagerOrHR: isManagerOrHR,
                      )
                    : null,
                markerBuilder: (context, date, events) {
                  if (format == CalendarFormat.week) {
                    return const SizedBox();
                  }
                  if (events.isEmpty) return const SizedBox();
                  final items = events
                      .cast<ScheduleRequestModel>()
                      .where((s) => s.isRecurring == isRecurringTab)
                      .toList();
                  if (items.isEmpty) return const SizedBox();
                  return _buildMonthMarkerDots(items, isManagerOrHR);
                },
              ),
            ),
          );

          final eventListWidget = _buildEventList(
            filteredSchedules
                .where((s) => s.isRecurring == isRecurringTab)
                .toList(),
            isManagerOrHR,
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [_buildLegend(isManagerOrHR), calendarWidget],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Text(
                          _selectedDay != null
                              ? 'Lịch trình ngày ${DateFormat('dd/MM', 'vi').format(_selectedDay!)}'
                              : 'Chọn một ngày',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(child: eventListWidget),
                    ],
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildLegend(isManagerOrHR),
                calendarWidget,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                SizedBox(
                  height: 400, // Fixed height on mobile for scrollable list
                  child: eventListWidget,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _filterEmployee = value),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên thực tập sinh...',
          hintStyle: TextStyle(fontSize: 18, color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.person_search_rounded,
            color: Colors.blue.shade500,
            size: 30, // Increased
          ),
          suffixIcon: _filterEmployee.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filterEmployee = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDayCell(
    DateTime day,
    List<ScheduleRequestModel> allSchedules, {
    required bool isSelected,
    required bool isToday,
    bool isManagerOrHR = false,
  }) {
    final daySchedules = _getSchedulesForDay(allSchedules, day);
    final hasSchedules = daySchedules.isNotEmpty;

    final morningCount = daySchedules
        .where(
          (s) =>
              s.shift == 'MORNING' ||
              s.shift == 'SÁNG' ||
              s.shift == 'ALL_DAY' ||
              s.shift == 'CẢ NGÀY',
        )
        .length;
    final afternoonCount = daySchedules
        .where(
          (s) =>
              s.shift == 'AFTERNOON' ||
              s.shift == 'CHIỀU' ||
              s.shift == 'ALL_DAY' ||
              s.shift == 'CẢ NGÀY',
        )
        .length;

    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color dayNumColor;
    Color bgColor;
    Color borderColor;
    if (isSelected) {
      bgColor = Colors.blue.shade700;
      dayNumColor = Colors.white;
      borderColor = Colors.blue.shade700;
    } else if (isToday) {
      bgColor = Colors.blue.shade50;
      dayNumColor = Colors.blue.shade800;
      borderColor = Colors.blue.shade300;
    } else if (isWeekend) {
      bgColor = Colors.grey.shade50;
      dayNumColor = Colors.grey.shade400;
      borderColor = Colors.transparent;
    } else {
      bgColor = Colors.transparent;
      dayNumColor = Colors.black87;
      borderColor = Colors.transparent;
    }

    // Divider color
    final dividerColor = isSelected ? Colors.white24 : Colors.grey.shade200;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
          _focusedDay = day;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Day number header -- same size always
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dayNumColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Always render divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: dividerColor,
            ),
            const SizedBox(height: 8),
            // Always render shift rows (SizedBox.shrink when count = 0)
            _buildShiftBadge(
              label: 'SA',
              count: hasSchedules ? morningCount : 0,
              color: Colors.blue.shade600,
              bgColor: Colors.blue.shade50,
              isSelected: isSelected,
              isEmpty: !hasSchedules,
            ),
            const SizedBox(height: 6),
            _buildShiftBadge(
              label: 'CH',
              count: hasSchedules ? afternoonCount : 0,
              color: Colors.orange.shade700,
              bgColor: Colors.orange.shade50,
              isSelected: isSelected,
              isEmpty: !hasSchedules,
            ),
          ],
        ),
      ),
    );
  }

  /// Compact square badge for SA/CH in week day cells
  Widget _buildShiftBadge({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required bool isSelected,
    bool isEmpty = false,
  }) {
    final isIntern = _userRole == UserRole.INTERN;
    final hasMark = count > 0;

    // Faded placeholder when empty
    final badgeColor = isEmpty || !hasMark
        ? (isSelected ? Colors.white.withOpacity(0.1) : Colors.grey.shade100)
        : (isSelected ? Colors.white.withOpacity(0.22) : bgColor);

    final labelColor = isEmpty || !hasMark
        ? (isSelected ? Colors.white24 : Colors.grey.shade300)
        : (isSelected ? Colors.white : color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: isIntern || !hasMark
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: (isIntern || !hasMark) ? 0 : 6),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
            if (!isIntern && hasMark)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthMarkerDots(
    List<ScheduleRequestModel> items,
    bool isManagerOrHR,
  ) {
    final leaveItems = items
        .where((s) => s.type == ScheduleType.LEAVE)
        .toList();
    final hasLeave = leaveItems.isNotEmpty;
    final hasWork = items.any((s) => s.type == ScheduleType.WORK);

    // Count unique employees on leave (for manager/HR view)
    final leaveCount = isManagerOrHR
        ? leaveItems.map((s) => s.employeeId).toSet().length
        : 0;

    return Positioned(
      bottom: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLeave) ...[
            if (isManagerOrHR && leaveCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue, // Changed from red
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$leaveCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ] else
              _dot(Colors.blue), // Changed from red
          ],
          if (hasWork) _dot(Colors.blue.shade300),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isManagerOrHR) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simplified legend as requested, only showing colors
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  List<ScheduleRequestModel> _getSchedulesForDay(
    List<ScheduleRequestModel> schedules,
    DateTime day,
  ) {
    return schedules.where((s) {
      final date = DateTime(day.year, day.month, day.day);
      final start = DateTime(
        s.startDate.year,
        s.startDate.month,
        s.startDate.day,
      );
      final end = DateTime(s.endDate.year, s.endDate.month, s.endDate.day);

      bool isInRange =
          (date.isAtSameMomentAs(start) ||
          (date.isAfter(start) && date.isBefore(end)) ||
          date.isAtSameMomentAs(end));

      if (!isInRange) return false;

      if (s.isRecurring) {
        return _weekdayMatches(s.weekday, day.weekday);
      }

      return true;
    }).toList();
  }

  /// This MUST match the values stored in the database (English)
  String _getWeekdayString(int day) {
    switch (day) {
      case DateTime.monday:
        return 'MONDAY';
      case DateTime.tuesday:
        return 'TUESDAY';
      case DateTime.wednesday:
        return 'WEDNESDAY';
      case DateTime.thursday:
        return 'THURSDAY';
      case DateTime.friday:
        return 'FRIDAY';
      case DateTime.saturday:
        return 'SATURDAY';
      case DateTime.sunday:
        return 'SUNDAY';
      default:
        return '';
    }
  }

  /// Display-only: convert DB weekday value to short Vietnamese label
  String _weekdayDisplayName(String dbValue) {
    switch (dbValue.toUpperCase()) {
      case 'MONDAY':
      case 'THỨ 2':
        return 'ThỨ 2';
      case 'TUESDAY':
      case 'THỨ 3':
        return 'ThỨ 3';
      case 'WEDNESDAY':
      case 'THỨ 4':
        return 'ThỨ 4';
      case 'THURSDAY':
      case 'THỨ 5':
        return 'ThỨ 5';
      case 'FRIDAY':
      case 'THỨ 6':
        return 'ThỨ 6';
      case 'SATURDAY':
      case 'THỨ 7':
        return 'ThỨ 7';
      case 'SUNDAY':
      case 'CHỦ NHẬT':
        return 'Chủ nhật';
      default:
        return dbValue;
    }
  }

  /// Match s.weekday (DB value, may be English or Vietnamese) against a DateTime weekday int
  bool _weekdayMatches(String? storedWeekday, int dateWeekday) {
    if (storedWeekday == null) return false;
    final engName = _getWeekdayString(dateWeekday); // e.g. 'MONDAY'
    final viMap = <String, String>{
      'MONDAY': 'THỨ 2',
      'TUESDAY': 'THỨ 3',
      'WEDNESDAY': 'THỨ 4',
      'THURSDAY': 'THỨ 5',
      'FRIDAY': 'THỨ 6',
      'SATURDAY': 'THỨ 7',
      'SUNDAY': 'CHỦ NHẬT',
    };
    final viName = viMap[engName] ?? '';
    final upper = storedWeekday.toUpperCase();
    return upper == engName || upper == viName;
  }

  Widget _buildEventList(
    List<ScheduleRequestModel> events,
    bool isManagerOrHR,
  ) {
    final filteredEvents = _selectedDay != null
        ? _getSchedulesForDay(events, _selectedDay!)
        : <ScheduleRequestModel>[];

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.noSchedulesFor} ${DateFormat('EEEE, d/M', 'vi').format(_selectedDay ?? _focusedDay)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final req = filteredEvents[index];
        final isLeave = req.type == ScheduleType.LEAVE;
        final color = Colors.blue; // Consistent blue
        final statusColor = req.status == RequestStatus.APPROVED
            ? Colors.green
            : (req.status == RequestStatus.PENDING
                  ? Colors.orange
                  : Colors.red);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLeave ? Icons.beach_access : Icons.work_outline,
                  color: color,
                ),
                Text(
                  req.shift,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            title: Text(
              isManagerOrHR
                  ? (req.userMetadata?['name'] ?? AppStrings.staff)
                  : (isLeave ? AppStrings.personalLeave : AppStrings.myShift),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (req.description != null && req.description!.isNotEmpty)
                  Text(
                    req.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      req.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (req.isRecurring && req.weekday != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.repeat, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Text(
                        _weekdayDisplayName(req.weekday!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: isManagerOrHR
                ? IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showRequestDetails(context, req);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showRequestDetails(BuildContext context, ScheduleRequestModel req) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(req.userMetadata?['name'] ?? AppStrings.details),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppStrings.type}: ${req.type.name}'),
            Text('${AppStrings.shift}: ${req.shift}'),
            Text('${AppStrings.requestStatus}: ${req.status.name}'),
            if (req.description != null)
              Text('${AppStrings.note}: ${req.description}'),
            Text(
              '${AppStrings.registeredAt}: ${DateFormat('yyyy-MM-dd HH:mm').format(req.createdAt)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}
