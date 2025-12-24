import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/cleaners/cleaner_entity.dart';
import 'package:game/features/grid/grid_manager.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('CleanerEntity Tests', () {
    late GridManager gridManager;
    late GameState gameState;

    setUp(() async {
      gameState = GameState();
      final stage = StageData(
        id: 'test',
        name: 'Test',
        width: 3,
        height: 3,
        themeColor: const Color(0xFF000000),
      );
      gridManager = GridManager(gameState, stageData: stage);
      await gridManager.onLoad();
    });

    test('Cleaning Logic', () {
      final centerTile = gridManager.getTileAt(1, 1)!;
      centerTile.pollutionValue = 50;

      final cleaner = CleanerEntity(
        gridManager: gridManager,
        gridX: 1,
        gridY: 1,
      );

      // Simulate 1.1 seconds (cleaning interval is 1.0)
      cleaner.update(1.1);

      expect(centerTile.pollutionValue, lessThan(50));
    });
  });
}
