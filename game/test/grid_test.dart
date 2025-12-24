import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/grid/grid_manager.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('GridManager Tests', () {
    test('Initialization', () async {
      final gameState = GameState();
      final stage = StageData(
        id: 'test',
        name: 'Test',
        width: 5,
        height: 5,
        themeColor: const Color(0xFF000000),
      );
      final grid = GridManager(gameState, stageData: stage);
      await grid.onLoad();

      expect(grid.getTileAt(0, 0), isNotNull);
      expect(grid.getTileAt(4, 4), isNotNull);
      expect(grid.getTileAt(5, 5), isNull);
    });

    // Test depends on _spreadPollution being triggered or accessible
    // Since _spreadPollution is private, we can only test side effects or make it public/visible for testing.
    // For now, we tested initialization.
  });
}
