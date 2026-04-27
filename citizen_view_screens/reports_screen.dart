import 'package:flutter/material.dart';
import '/core/theme.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _reports = [
    {
      'type': 'Medical Emergency',
      'status': 'RESOLVED',
      'date': 'Oct 24, 2023 • 14:02',
      'location': '123 Third Mainland Bridge, Lagos',
      'icon': Icons.medical_services,
      'iconColor': const Color(0xFFDC2626),
      'iconBg': const Color(0xFFFEE2E2),
    },
    {
      'type': 'Road Accident',
      'status': 'RESOLVED',
      'date': 'Oct 21, 2023 • 09:15',
      'location': 'Ikeja City Mall, Obafemi Awolowo Way',
      'icon': Icons.car_crash,
      'iconColor': const Color(0xFF2563EB),
      'iconBg': const Color(0xFFDBEAFE),
    },
    {
      'type': 'Fire Outbreak',
      'status': 'CANCELLED',
      'date': 'Oct 18, 2023 • 23:45',
      'location': 'Block 4, 1004 Estate, Victoria Island',
      'icon': Icons.local_fire_department,
      'iconColor': const Color(0xFFEA580C),
      'iconBg': const Color(0xFFFED7AA),
    },
    {
      'type': 'Security Concern',
      'status': 'RESOLVED',
      'date': 'Oct 12, 2023 • 18:20',
      'location': 'Lekki Phase 1, Admiralty Way',
      'icon': Icons.security,
      'iconColor': const Color(0xFF7C3AED),
      'iconBg': const Color(0xFFEDE9FE),
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports
        .where(
          (r) =>
              r['type'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              r['location'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'REPORT HISTORY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Search reports...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Reports list
          Expanded(
            child: _filteredReports.isEmpty
                ? const Center(
                    child: Text(
                      'No reports found.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredReports.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _filteredReports.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 40,
                                color: AppColors.textMuted.withOpacity(0.4),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'End of report history',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final report = _filteredReports[index];
                      return _ReportItem(report: report);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportItem({required this.report});

  Color get _statusColor {
    switch (report['status']) {
      case 'RESOLVED':
        return AppColors.resolved;
      case 'CANCELLED':
        return AppColors.cancelled;
      default:
        return AppColors.accent;
    }
  }

  Color get _statusBg {
    switch (report['status']) {
      case 'RESOLVED':
        return AppColors.successLight;
      case 'CANCELLED':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFFEE2E2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: report['iconBg'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: report['iconColor'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report['type'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report['status'] as String,
                        style: TextStyle(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  report['date'] as String,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        report['location'] as String,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
