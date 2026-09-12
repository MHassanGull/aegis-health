// Widget test for the RiskGauge — a pure widget with no backend/plugin needs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_medical_assist/widgets/risk_gauge.dart';

void main() {
  testWidgets('RiskGauge shows percentage, title and tier', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskGauge(
            title: 'Diabetes',
            percent: 52,
            tier: 'High',
            icon: Icons.water_drop_outlined,
          ),
        ),
      ),
    );

    expect(find.text('52%'), findsOneWidget);
    expect(find.text('Diabetes'), findsOneWidget);
    expect(find.text('High risk'), findsOneWidget);
  });
}
