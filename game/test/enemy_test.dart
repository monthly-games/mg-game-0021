import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_state.dart';
import 'package:game/features/enemies/pollution_blob.dart';
import 'package:game/features/grid/grid_manager.dart';
import 'package:game/features/stages/stage_data.dart';

void main() {
  group('Defense Mechanics Tests', () {
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

    test('PollutionBlob moves towards center', () {
      final center = Vector2(
        (gridManager.width * 64.0) / 2,
        (gridManager.height * 64.0) / 2,
      );

      final blob = PollutionBlob(
        gridManager: gridManager,
        onKilled: (_) {},
        startPos: Vector2(0, 0),
      );

      // Update logic
      blob.update(1.0);

      // Should move from 0,0 towards center (positive x, positive y)
      expect(blob.position.x, greaterThan(0));
      expect(blob.position.y, greaterThan(0));
    });

    test('PollutionBlob pollutes tile', () {
      final blob = PollutionBlob(
        gridManager: gridManager,
        onKilled: (_) {},
        startPos: Vector2(0, 0), // At 0,0
      );

      final tile = gridManager.getTileAt(0, 0)!;
      tile.pollutionValue = 0; // Clean tile

      blob.update(0.1);

      // Should have polluted the tile
      expect(tile.pollutionValue, greaterThan(0));
    });
  });
}
