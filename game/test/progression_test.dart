import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('Progression Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Initial State', () {
      expect(gameState.currentStageIndex, 0);
      expect(gameState.unlockedCleaners, contains('Purifier'));
      expect(
        gameState.unlockedCleaners,
        contains('Defender'),
      ); // Unlocked by default in current impl for testing
      // Wait, I changed it to unlock after stage 1 in nextStage(), but initialized with both in GameState definition?
      // Let's check GameState definition.
    });

    test('Stage Completion and Unlocking', () {
      // Manually modify unlocked cleaners to test unlocking logic if needed
      gameState.unlockedCleaners = ['Purifier'];

      gameState.nextStage(); // Moves to Stage 1 (Index 1)

      expect(gameState.currentStageIndex, 1);
      expect(gameState.unlockedCleaners, contains('Defender'));
    });

    test('Stage Data Retrieval', () {
      final stage0 = StageManager.getStage(0);
      expect(stage0.id, 'stage_1_beach');

      final stage1 = StageManager.getStage(1);
      expect(stage1.id, 'stage_2_city');
    });

    test('Stage Clear Condition', () {
      gameState.setPollutionLevel(0.0);
      expect(gameState.isStageClear, true);
    });
  });
}
