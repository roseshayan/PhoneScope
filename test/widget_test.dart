import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phonescope/core/widgets/metric_card.dart';
import 'package:phonescope/core/widgets/status_badge.dart';
import 'package:phonescope/core/widgets/section_header.dart';
import 'package:phonescope/app/theme/app_theme.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('MetricCard displays title, value, and subtitle properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: MetricCard(
              title: 'پردازنده',
              value: '8 هسته',
              subtitle: 'معماری arm64-v8a',
              icon: Icons.memory,
            ),
          ),
        ),
      );

      expect(find.text('پردازنده'), findsOneWidget);
      expect(find.text('8 هسته'), findsOneWidget);
      expect(find.text('معماری arm64-v8a'), findsOneWidget);
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('StatusBadge renders correct badge label and icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'سالم',
              type: BadgeType.success,
              icon: Icons.check,
            ),
          ),
        ),
      );

      expect(find.text('سالم'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('SectionHeader renders title and subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'مشخصات باتری',
              subtitle: 'داده‌های زنده حسگر',
              icon: Icons.battery_full,
            ),
          ),
        ),
      );

      expect(find.text('مشخصات باتری'), findsOneWidget);
      expect(find.text('داده‌های زنده حسگر'), findsOneWidget);
      expect(find.byIcon(Icons.battery_full), findsOneWidget);
    });
  });
}
