import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class SimpleCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;

  const SimpleCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
  });

  @override
  State<SimpleCalendar> createState() => _SimpleCalendarState();
}

class _SimpleCalendarState extends State<SimpleCalendar> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        _buildDayLabels(),
        const SizedBox(height: 4),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime.now();
                });
              },
              child: Text(
                'today',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                    _currentMonth.year,
                    _currentMonth.month - 1,
                  );
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                    _currentMonth.year,
                    _currentMonth.month + 1,
                  );
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayLabels() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final isCurrentMonth =
        today.year == _currentMonth.year && today.month == _currentMonth.month;

    List<Widget> dayWidgets = [];

    // Previous month days
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);
    for (int i = startingWeekday - 1; i >= 0; i--) {
      dayWidgets.add(_buildDayCell(
        prevMonth.day - i,
        isCurrentMonth: false,
      ));
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday = isCurrentMonth && day == today.day;
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;

      dayWidgets.add(_buildDayCell(
        day,
        isCurrentMonth: true,
        isToday: isToday,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateSelected?.call(date);
        },
      ));
    }

    // Next month days
    final remainingCells = 42 - dayWidgets.length;
    for (int day = 1; day <= remainingCells && dayWidgets.length < 42; day++) {
      dayWidgets.add(_buildDayCell(
        day,
        isCurrentMonth: false,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(
    int day, {
    bool isCurrentMonth = true,
    bool isToday = false,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primaryLight.withOpacity(0.2)
                  : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected
                  ? AppColors.white
                  : isCurrentMonth
                      ? AppColors.textPrimary
                      : AppColors.textHint,
              fontWeight:
                  isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
