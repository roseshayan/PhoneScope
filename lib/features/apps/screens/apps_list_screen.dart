import 'package:flutter/material.dart';

import '../models/app_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/status_badge.dart';

class AppsListScreen extends StatefulWidget {
  const AppsListScreen({super.key});

  @override
  State<AppsListScreen> createState() => _AppsListScreenState();
}

class _AppsListScreenState extends State<AppsListScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  List<AppInfoModel> _allApps = [];
  List<AppInfoModel> _filteredApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _filterType = 0; // 0: All, 1: User Only, 2: System Only

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.getInstalledApps(includeSystem: true);
      list.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
      );
      if (mounted) {
        setState(() {
          _allApps = list;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var result = _allApps;
    if (_filterType == 1) {
      result = result.where((a) => !a.isSystemApp).toList();
    } else if (_filterType == 2) {
      result = result.where((a) => a.isSystemApp).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((a) {
        return a.appName.toLowerCase().contains(q) ||
            a.packageName.toLowerCase().contains(q);
      }).toList();
    }

    setState(() => _filteredApps = result);
  }

  void _showAppDetailsDialog(AppInfoModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    app.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    app.packageName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StatusBadge(
                        label: 'نسخه: ${app.versionName}',
                        type: BadgeType.info,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: 'Target SDK: ${app.targetSdk}',
                        type: BadgeType.neutral,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'مجوزهای اعلام‌شده (${app.permissionsCount}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (app.permissions.isEmpty)
                    const Text(
                      'این برنامه مجوزی درخواست نکرده است.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else
                    ...app.permissions.map((p) {
                      final short = p.replaceFirst('android.permission.', '');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $short',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('برنامه‌های نصب‌شده (${_filteredApps.length})'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجوی نام یا پکیج برنامه...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(0, 'همه (${_allApps.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(1, 'برنامه‌های کاربر'),
                const SizedBox(width: 8),
                _buildFilterChip(2, 'سیستمی'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_filteredApps.isEmpty
                      ? const Center(child: Text('برنامه‌ای یافت نشد.'))
                      : ListView.builder(
                          itemCount: _filteredApps.length,
                          itemBuilder: (context, idx) {
                            final app = _filteredApps[idx];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF06B6D4)
                                      .withValues(alpha: 0.15),
                                  child: Icon(
                                    app.isSystemApp
                                        ? Icons.settings
                                        : Icons.apps,
                                    color: const Color(0xFF06B6D4),
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  app.appName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${app.packageName} • v${app.versionName} • Target ${app.targetSdk}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.chevron_left,
                                  size: 18,
                                ),
                                onTap: () => _showAppDetailsDialog(app),
                              ),
                            );
                          },
                        )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int type, String label) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (sel) {
        if (sel) {
          setState(() {
            _filterType = type;
            _applyFilters();
          });
        }
      },
    );
  }
}
