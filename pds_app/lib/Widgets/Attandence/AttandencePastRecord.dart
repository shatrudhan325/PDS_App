import 'package:flutter/material.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_db.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_history_record.dart';

class PastRecordsScreen extends StatefulWidget {
  const PastRecordsScreen({super.key});

  @override
  State<PastRecordsScreen> createState() => _PastRecordsScreenState();
}

class _PastRecordsScreenState extends State<PastRecordsScreen> {
  List<AttendanceHistoryRecord> _allRecords = [];
  List<AttendanceHistoryRecord> _filteredRecords = [];
  String _searchQuery = '';
  String _filterMonth = 'all';
  String _filterStatus = 'all';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await AttendanceDb.instance.getAllRecords();
    setState(() {
      _allRecords = records;
      _filteredRecords = records;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        // Search filter
        final searchLower = _searchQuery.toLowerCase();
        final matchesSearch =
            _formatDate(record.date).toLowerCase().contains(searchLower) ||
            record.location.toLowerCase().contains(searchLower);

        // Month filter
        final matchesMonth =
            _filterMonth == 'all' || _getMonthYear(record.date) == _filterMonth;

        // Status filter
        final matchesStatus =
            _filterStatus == 'all' ||
            (_filterStatus == 'complete' &&
                record.status == RecordStatus.complete) ||
            (_filterStatus == 'incomplete' &&
                record.status == RecordStatus.incomplete);

        return matchesSearch && matchesMonth && matchesStatus;
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '—';
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  List<String> _getUniqueMonths() {
    final months = _allRecords
        .map((r) => _getMonthYear(r.date))
        .toSet()
        .toList();
    months.sort();
    return months;
  }

  int get _totalDays =>
      _filteredRecords.where((r) => r.status == RecordStatus.complete).length;

  int get _totalHours {
    return _filteredRecords
        .where((r) => r.status == RecordStatus.complete)
        .fold(0, (sum, record) {
          // record.totalHours is like "7h 30m" or "Incomplete"
          final hours = int.tryParse(record.totalHours.split('h')[0]) ?? 0;
          return sum + hours;
        });
  }

  int get _incompleteDays =>
      _filteredRecords.where((r) => r.status == RecordStatus.incomplete).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// App Bar
      appBar: AppBar(
        backgroundColor: Color(0xFF1A57D8),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Past Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 253, 253, 253),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 253, 253, 254),
            ),
            onPressed: () => _loadRecords(),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.calendar_today,
                            color: const Color(0xFF007BFF),
                            value: '$_totalDays',
                            label: 'Days',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.access_time,
                            color: const Color(0xFF28A745),
                            value: '${_totalHours}h',
                            label: 'Hours',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cancel,
                            color: const Color(0xFFFFC107),
                            value: '$_incompleteDays',
                            label: 'Incomplete',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Search and Filters Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            /// Search Bar
                            TextField(
                              onChanged: (value) {
                                _searchQuery = value;
                                _applyFilters();
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by date or location...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF717182),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// Filter Dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterDropdown(
                                    value: _filterMonth,
                                    items: ['all', ..._getUniqueMonths()],
                                    labels: const {'all': 'All Months'},
                                    onChanged: (value) {
                                      setState(() => _filterMonth = value!);
                                      _applyFilters();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    value: _filterStatus,
                                    items: const [
                                      'all',
                                      'complete',
                                      'incomplete',
                                    ],
                                    labels: const {
                                      'all': 'All Status',
                                      'complete': 'Complete',
                                      'incomplete': 'Incomplete',
                                    },
                                    onChanged: (value) {
                                      setState(() => _filterStatus = value!);
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Records Count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        'Showing ${_filteredRecords.length} record${_filteredRecords.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717182),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Records List
                    if (_filteredRecords.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredRecords.map(
                        (record) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRecordCard(record),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF030213),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF717182)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Map<String, String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.filter_list,
            size: 18,
            color: Color(0xFF717182),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF030213)),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(labels[item] ?? item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFECECF0),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 32,
                color: Color(0xFF717182),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No records found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF030213),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or search query',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(AttendanceHistoryRecord record) {
    final isComplete = record.status == RecordStatus.complete;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Color(0xFF007BFF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(record.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF030213),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? const Color(0xFF28A745).withOpacity(0.1)
                        : const Color(0xFFFFC107).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isComplete ? 'Complete' : 'Incomplete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isComplete
                          ? const Color(0xFF28A745)
                          : const Color(0xFFFFC107),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),

            /// Time Details
            _buildTimeEntry(
              icon: Icons.check_circle,
              iconColor: const Color(0xFF28A745),
              label: 'Check-in',
              value: _formatTime(record.checkInTime),
            ),

            const SizedBox(height: 12),

            _buildTimeEntry(
              icon: isComplete ? Icons.cancel : Icons.access_time,
              iconColor: isComplete
                  ? const Color(0xFFDC3545)
                  : const Color(0xFFFFC107),
              label: 'Check-out',
              value: isComplete ? _formatTime(record.checkOutTime) : '—',
              valueColor: isComplete
                  ? const Color(0xFF030213)
                  : const Color(0xFFFFC107),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),

            /// Total and Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Hours',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF717182),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.totalHours,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF030213),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  record.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717182),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeEntry({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF030213),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
