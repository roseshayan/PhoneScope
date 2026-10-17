import 'package:flutter/material.dart';

import '../dashboard/screens/dashboard_screen.dart';
import '../device/screens/device_screen.dart';
import '../thermal/screens/thermal_monitor_screen.dart';
import '../hardware_tests/screens/hardware_tests_screen.dart';
import '../tools/screens/tools_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const MainScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTabIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const DeviceScreen(),
      const ThermalMonitorScreen(),
      const HardwareTestsScreen(),
      ToolsScreen(onToggleTheme: widget.onToggleTheme, isDark: widget.isDark),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentTabIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_other_outlined),
            activeIcon: Icon(Icons.devices_other),
            label: 'سخت‌افزار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'پایش زنده',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'تست‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction_outlined),
            activeIcon: Icon(Icons.construction),
            label: 'ابزارها',
          ),
        ],
      ),
    );
  }
}
