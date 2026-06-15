import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/rapid_aid_logo.dart';
import '../../../core/widgets/user_profile_avatar.dart';
import '../../../main.dart';
import '../../../features/auth/data/token_storage.dart';
import 'citizen_report_detail.dart';

import '../../../main.dart';
import '../../../core/network/network_client.dart';
import '../../../core/widgets/premium_empty_state.dart';

/// Citizen History Screen (Reports)
class CitizenHistoryScreen extends StatefulWidget {
  const CitizenHistoryScreen({super.key});

  @override
  State<CitizenHistoryScreen> createState() => _CitizenHistoryScreenState();
}

class _CitizenHistoryScreenState extends State<CitizenHistoryScreen> {
  String _selectedFilter = 'All';
  String _selectedStatusFilter = 'All';
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    final ts = getIt<TokenStorage>();
    final email = ts.getUserEmail() ?? 'Citizen';
    _userRole = ts.getUserRole() ?? 'CITIZEN';
    _userName = ts.getUserName() ?? email.split('@').first;
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final dio = getIt<NetworkClient>().dio;
      final response = await dio.get('/incidents/');
      
      final data = (response.data is List) 
          ? response.data as List<dynamic> 
          : (response.data['results'] as List<dynamic>?) ?? [];
      
      setState(() {
        _reports = data.map((json) {
          final type = json['category'] ?? 'OTHER';
          final displayType = type == 'CRIME' ? 'Security' : _capitalize(type);
          
          return {
            'id': json['id'] ?? '',
            'ref_id': json['ref_id'] ?? '',
            'type': 'Emergency: $displayType',
            'category': displayType,
            'icon': _getCategoryIcon(type),
            'color': _getCategoryColor(type),
            'date': _formatDate(json['created_at']),
            'created_at': json['created_at'] ?? '',
            'status': json['status'] == 'PENDING' ? 'ACTIVE' : (json['status'] ?? 'ACTIVE'),
            'statusColor': _getStatusColor(json['status']),
            'statusBg': _getStatusBg(json['status']),
            'address': (json['address'] != null && json['address'].toString().isNotEmpty) ? json['address'] : 'Unknown Location',
            'description': json['description'] ?? 'No description provided.',
            'evidences': json['evidences'] ?? [],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint("Fetch history error: $e");
      debugPrint("StackTrace: $st");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load history.';
      });
    }
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : '';

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return Icons.medical_services;
      case 'fire': return Icons.local_fire_department;
      case 'accident': return Icons.car_crash;
      case 'security': 
      case 'crime': return Icons.security;
      default: return Icons.emergency;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return AppTheme.emergencyUrl;
      case 'fire': return const Color(0xFFEA580C);
      case 'accident': return const Color(0xFF1E3A8A);
      case 'security': 
      case 'crime': return const Color(0xFF7E22CE);
      default: return Colors.grey.shade700;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'RESOLVED') return AppTheme.primary;
    if (status == 'CANCELLED') return Colors.grey.shade700;
    return Colors.orange.shade700;
  }

  Color _getStatusBg(String? status) {
    if (status == 'RESOLVED') return AppTheme.primary;
    if (status == 'CANCELLED') return Colors.grey.shade200;
    return Colors.orange.shade50;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Filter reports
    final filteredReports = _reports.where((r) {
      final matchesCategory = _selectedFilter == 'All' || r['category'] == _selectedFilter;
      final matchesStatus = _selectedStatusFilter == 'All' || r['status'].toString().toUpperCase() == _selectedStatusFilter.toUpperCase();
      return matchesCategory && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Topbar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RapidAidLogo(size: 32, iconSize: 30),
                  Text(
                    'REPORT HISTORY',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _userName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _userRole,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: cs.surfaceContainerHigh, width: 2),
                        ),
                        child: const UserProfileAvatar(radius: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search and Filter Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(Icons.search,
                              color: cs.onSurface.withOpacity(0.6)),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category Filter Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.grid_view_rounded,
                          color: cs.onSurface.withOpacity(0.8)),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (String result) {
                        setState(() {
                          _selectedFilter = result;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        Widget buildItem(String value, String text, String currentFilter) {
                          final isActive = currentFilter == value;
                          return Text(
                            text,
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? cs.primary : cs.onSurface,
                            ),
                          );
                        }
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'All',
                            child: buildItem('All', 'All Categories', _selectedFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Medical',
                            child: buildItem('Medical', 'Medical', _selectedFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Fire',
                            child: buildItem('Fire', 'Fire', _selectedFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Accident',
                            child: buildItem('Accident', 'Accident', _selectedFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Security',
                            child: buildItem('Security', 'Security', _selectedFilter),
                          ),
                        ];
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Filter Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list,
                          color: cs.onSurface.withOpacity(0.8)),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (String result) {
                        setState(() {
                          _selectedStatusFilter = result;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        Widget buildItem(String value, String text, String currentFilter) {
                          final isActive = currentFilter == value;
                          return Text(
                            text,
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? cs.primary : cs.onSurface,
                            ),
                          );
                        }
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'All',
                            child: buildItem('All', 'All Statuses', _selectedStatusFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Active',
                            child: buildItem('Active', 'Active', _selectedStatusFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Resolved',
                            child: buildItem('Resolved', 'Resolved', _selectedStatusFilter),
                          ),
                          PopupMenuItem<String>(
                            value: 'Cancelled',
                            child: buildItem('Cancelled', 'Cancelled', _selectedStatusFilter),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                  ? PremiumEmptyState(
                      icon: Icons.error_outline,
                      title: 'Failed to Load History',
                      message: _errorMessage,
                      actionLabel: 'Try Again',
                      onAction: _fetchHistory,
                    )
                  : filteredReports.isEmpty
                    ? PremiumEmptyState(
                        icon: Icons.history,
                        title: 'No Report History',
                        message: 'You have not reported any incidents yet. Emergencies you report will appear here.',
                        actionLabel: 'Refresh',
                        onAction: _fetchHistory,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        itemCount:
                            filteredReports.length + 1, // +1 for end indicator
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == filteredReports.length) {
                            // End of report history indicator
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32.0),
                              child: Column(
                                children: [
                                  Divider(color: cs.onSurface.withOpacity(0.1)),
                                  const SizedBox(height: 32),
                                  Icon(Icons.access_time,
                                      size: 48,
                                      color: cs.onSurface.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'End of report history',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 48), // Bottom padding
                                ],
                              ),
                            );
                          }

                          final report = filteredReports[index];
                          return _ReportCard(
                            report: report,
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CitizenReportDetail(report: report),
                                ),
                              );
                              if (result == true) {
                                _fetchHistory();
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = report['color'] as Color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  report['icon'] as IconData,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report['type'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: report['statusBg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            report['status'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: report['statusColor'] as Color,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Date Time
                    Text(
                      report['date'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: cs.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report['address'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
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
        ),
      ),
    );
  }
}
