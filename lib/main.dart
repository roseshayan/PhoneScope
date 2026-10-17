import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/home/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhoneScopeApp());
}

class PhoneScopeApp extends StatefulWidget {
  const PhoneScopeApp({super.key});

  @override
  State<PhoneScopeApp> createState() => _PhoneScopeAppState();
}

class _PhoneScopeAppState extends State<PhoneScopeApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneScope • فون‌اسکوپ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: MainScreen(
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
