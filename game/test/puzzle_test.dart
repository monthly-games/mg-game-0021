import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/grid/grid_manager.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('Puzzle Mechanics Tests', () {
    late GridManager gridManager;
    late GameState gameState;

    setUp(() async {
      gameState = GameState();
      final stage = StageData(
        id: 'test',
        name: 'Test',
        width: 4,
        height: 4,
        themeColor: const Color(0xFF000000),
      );
      gridManager = GridManager(gameState, stageData: stage);
      await gridManager.onLoad();
    });

    test('Match Logic finds connected tiles', () {
      // Setup a match scenario
      // 0,0 and 0,1 and 1,0 have similar high pollution
      final t1 = gridManager.getTileAt(0, 0)!..pollutionValue = 80;
      final t2 = gridManager.getTileAt(0, 1)!..pollutionValue = 85;
      final t3 = gridManager.getTileAt(1, 0)!..pollutionValue = 75;

      // Isolate them
      gridManager.getTileAt(1, 1)!..pollutionValue = 10;

      final matches = gridManager.checkMatch(0, 0);

      // Should find at least 3
      expect(matches.length, greaterThanOrEqualTo(3));
      expect(matches, contains(t1));
      expect(matches, contains(t2));
      expect(matches, contains(t3));
    });

    test('Trigger Purification cleans tiles', () {
      final t1 = gridManager.getTileAt(0, 0)!..pollutionValue = 100;
      final t2 = gridManager.getTileAt(0, 1)!..pollutionValue = 100;

      gridManager.triggerPurification([t1, t2]);

      expect(t1.pollutionValue, 0);
      expect(t2.pollutionValue, 0);
    });
  });
}
