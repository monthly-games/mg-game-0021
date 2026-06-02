import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Capture Tests', () {
    testWidgets('Capture main menu screenshot', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MyApp),
        matchesGoldenFile('main_menu.png'),
      );
    });

    testWidgets('Capture gameplay screenshot', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to gameplay
      final startButton = find.byKey(const ValueKey('start-game'));
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle(Duration(seconds: 3));
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('gameplay.png'),
      );
    });

    testWidgets('Capture level select screenshot', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to level select
      final levelButton = find.byKey(const ValueKey('level-roadmap'));
      if (levelButton.evaluate().isNotEmpty) {
        await tester.tap(levelButton);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('level_select.png'),
      );
    });

    testWidgets('Capture rewards screenshot', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to rewards
      final rewardsButton = find.byKey(const ValueKey('rewards'));
      if (rewardsButton.evaluate().isNotEmpty) {
        await tester.tap(rewardsButton);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('rewards.png'),
      );
    });

    testWidgets('Full game flow screenshot capture', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Create screenshots directory
      final screenshotDir = Directory('D:/mg-games/repos/screenshots/mg-game-0021');
      if (!screenshotDir.existsSync()) {
        screenshotDir.createSync(recursive: true);
      }

      // 1. Main Menu
      await tester.pumpAndSettle();
      await binding.takeScreenshot('screenshots/mg-game-0021/01_main_menu');

      // 2. Start Game
      final startButton = find.byKey(const ValueKey('start-game'));
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle(Duration(seconds: 2));
        await binding.takeScreenshot('screenshots/mg-game-0021/02_gameplay');
      }

      // 3. Back to menu and navigate to levels
      await tester.pageBack();
      await tester.pumpAndSettle();

      final levelButton = find.byKey(const ValueKey('level-roadmap'));
      if (levelButton.evaluate().isNotEmpty) {
        await tester.tap(levelButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('screenshots/mg-game-0021/03_level_select');
      }

      // 4. Back to menu and navigate to rewards
      await tester.pageBack();
      await tester.pumpAndSettle();

      final rewardsButton = find.byKey(const ValueKey('rewards'));
      if (rewardsButton.evaluate().isNotEmpty) {
        await tester.tap(rewardsButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('screenshots/mg-game-0021/04_rewards');
      }
    });
  });
}
