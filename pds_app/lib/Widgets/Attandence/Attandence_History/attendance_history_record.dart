enum RecordStatus { complete, incomplete }

class AttendanceHistoryRecord {
  final int id;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String totalHours;
  final RecordStatus status;
  final String location;

  AttendanceHistoryRecord({
    required this.id,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.status,
    required this.location,
  });

  /// Build from DB map
  factory AttendanceHistoryRecord.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['date'] as String);
    final checkIn = DateTime.parse(map['check_in'] as String);

    DateTime? checkOut;
    if (map['check_out'] != null) {
      checkOut = DateTime.parse(map['check_out'] as String);
    }

    String totalHours;
    RecordStatus status;

    if (checkOut == null) {
      status = RecordStatus.incomplete;
      totalHours = 'Incomplete';
    } else {
      final diff = checkOut.difference(checkIn);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      status = RecordStatus.complete;
      totalHours = '${hours}h ${minutes}m';
    }

    return AttendanceHistoryRecord(
      id: map['id'] as int,
      date: date,
      checkInTime: checkIn,
      checkOutTime: checkOut,
      totalHours: totalHours,
      status: status,
      location: map['location'] as String,
    );
  }

  /// Convert to map for insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'check_in': checkInTime.toIso8601String(),
      'check_out': checkOutTime?.toIso8601String(),
      'location': location,
    };
  }
}
