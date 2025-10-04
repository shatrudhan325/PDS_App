/// Model class for attendance data
class AttendanceRecord {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isCheckedIn;

  AttendanceRecord({
    this.checkInTime,
    this.checkOutTime,
    this.isCheckedIn = false,
  });

  /// Calculate elapsed time between check-in and check-out (or current time if still checked in)
  String getElapsedTime() {
    if (checkInTime == null) {
      return '0 hours, 0 minutes';
    }

    final endTime = isCheckedIn
        ? DateTime.now()
        : (checkOutTime ?? checkInTime!);
    final duration = endTime.difference(checkInTime!);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours hours, $minutes minutes';
  }

  /// Format time to 12-hour format
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '—';

    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Get current date formatted as "DayName, Month Date"
  static String getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
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
      'December',
    ];

    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  AttendanceRecord copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isCheckedIn,
  }) {
    return AttendanceRecord(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}
