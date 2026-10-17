import 'package:flutter/material.dart';

class DisplayTestScreen extends StatefulWidget {
  const DisplayTestScreen({super.key});

  @override
  State<DisplayTestScreen> createState() => _DisplayTestScreenState();
}

class _DisplayTestScreenState extends State<DisplayTestScreen> {
  final List<Color> _testColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.cyan,
    const Color(0xFFFF00FF),
  ];

  int _currentIndex = 0;
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showBanner = false);
      }
    });
  }

  void _nextColor() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _testColors.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _testColors[_currentIndex];

    return Scaffold(
      backgroundColor: currentColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextColor,
        child: Stack(
          children: [
            if (_showBanner)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'برای تغییر رنگ ضربه بزنید. به دنبال پیکسل‌های سوخته یا تغییر رنگ غیرعادی بگردید.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'رنگ ${_currentIndex + 1} از ${_testColors.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('اتمام تست'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
