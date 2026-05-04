import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnt/core/c_visual_effects.dart';

void main() {
  testWidgets('TnTPressable invokes tap callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TnTPressable(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('TnTPremiumCard renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TnTPremiumCard(
            child: Text('Premium surface'),
          ),
        ),
      ),
    );

    expect(find.text('Premium surface'), findsOneWidget);
  });
}
