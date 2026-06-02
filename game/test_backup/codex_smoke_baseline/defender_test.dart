import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/cleaners/defender_cleaner.dart';
import 'package:game/features/grid/grid_manager.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('Defender Cleaner Tests', () {
    late GridManager gridManager;
    late GameState gameState;

    setUp(() async {
      gameState = GameState();
      final stage = StageData(
        id: 'test',
        name: 'Test',
        width: 5,
        height: 5,
        themeColor: const Color(0xFF000000),
      );
      gridManager = GridManager(gameState, stageData: stage);
      await gridManager.onLoad();
    });

    test('Defender Initialization', () {
      final defender = DefenderCleaner(
        gridManager: gridManager,
        gridX: 2,
        gridY: 2,
      );
      expect(defender.health, 3);
      expect(defender.gridX, 2);
    });

    // Note: Testing actual collision requires adding both to a parent component/game or mocking the parent.
    // Since PollutionBlob looks for siblings in parent.children, we can simulate this environment.

    test('Defender takes damage', () {
      final defender = DefenderCleaner(
        gridManager: gridManager,
        gridX: 2,
        gridY: 2,
      );

      defender.takeDamage();
      expect(defender.health, 2);

      defender.takeDamage();
      defender.takeDamage();
      expect(defender.health, 0);
      // We can't easily check removeFromParent() without a game loop, but checking health is good enough for logic.
    });
  });
}
