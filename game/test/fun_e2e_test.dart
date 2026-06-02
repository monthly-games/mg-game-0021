import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  Future<void> returnToMenu(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
  }

  testWidgets('MG-0021 fun e2e: Pollution Zero cleaning gameplay with environmental strategy', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
    expect(find.text('MG-0021'), findsOneWidget);
    expect(find.text('Pollution Zero: Cleaner Brigade'), findsOneWidget);
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('start-game')));
    await tester.pumpAndSettle();
    expect(find.text('Live Run'), findsOneWidget);
    // Pollution Zero specific: cleaning and environmental mechanics
    expect(find.textContaining('Difficulty'), findsWidgets);
    expect(find.textContaining('targets'), findsWidgets);
    expect(find.textContaining('cadence'), findsWidgets);
    expect(find.textContaining('gold /'), findsWidgets);
    expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('complete-action')));
    await tester.pumpAndSettle();
    // Verify level progression and rewards updated
    expect(find.textContaining('gold /'), findsWidgets);

    await returnToMenu(tester);

    await tester.tap(find.byKey(const ValueKey('level-roadmap')));
    await tester.pumpAndSettle();
    expect(find.text('Level Roadmap'), findsWidgets);
    expect(find.byKey(const ValueKey('level-list')), findsOneWidget);
    await returnToMenu(tester);

    await tester.tap(find.byKey(const ValueKey('rewards')));
    await tester.pumpAndSettle();
    expect(find.text('Rewards'), findsWidgets);
    await returnToMenu(tester);

    for (final entry in <String, String>{
      'daily-quests': 'Daily Quests',
      'guild-war': 'Guild War',
      'tournament': 'Tournament',
      'seasonal-event': 'Seasonal Event',
    }.entries) {
      await tester.tap(find.byKey(ValueKey(entry.key)));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
      await returnToMenu(tester);
    }
  });
}
