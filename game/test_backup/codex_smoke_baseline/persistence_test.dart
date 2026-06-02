import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';

void main() {
  group('Persistence Tests', () {
    test('GameState Serialization', () {
      final state = GameState();
      state.addEnergy(
        50,
      ); // From 100 -> 150 (max 100, clamped) -> wait, max is 100.
      state.consumeEnergy(50); // 100 - 50 = 50.
      state.unlockedCleaners.add('Defender');
      state.currentStageIndex = 2;

      final json = state.toJson();

      final newState = GameState();
      newState.fromJson(json);

      expect(newState.energy, 50);
      expect(newState.unlockedCleaners, contains('Defender'));
      expect(newState.currentStageIndex, 2);
    });

    test('Offline Energy Regeneration', () {
      final state = GameState();
      state.energy = 50;

      // Simulate save 60 minutes ago
      final now = DateTime.now();
      state.lastSaveTime = now.subtract(const Duration(minutes: 60));

      state.regenerateOfflineEnergy();

      // Should regain 60 energy: 50 + 60 = 110 -> Clamped to 100
      expect(state.energy, 100);
    });

    test('Offline Energy Partial Regeneration', () {
      final state = GameState();
      state.energy = 10;

      // Simulate save 10 minutes ago
      final now = DateTime.now();
      state.lastSaveTime = now.subtract(const Duration(minutes: 10));

      state.regenerateOfflineEnergy();

      // Should regain 10 energy: 10 + 10 = 20
      expect(state.energy, 20);
    });
  });
}
