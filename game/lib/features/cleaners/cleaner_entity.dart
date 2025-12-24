import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../grid/grid_manager.dart';
import 'cleaner_base.dart';

class CleanerEntity extends PositionComponent implements CleanerBase {
  @override
  final CleanerType type = CleanerType.purifier;

  final GridManager gridManager;
  final int gridX;
  final int gridY;

  double _cleanTimer = 0.0;
  final double _cleanInterval = 1.0;
  final double _cleanPower = 10.0;

  CleanerEntity({
    required this.gridManager,
    required this.gridX,
    required this.gridY,
  }) {
    size = Vector2.all(48); // Smaller than tile
    // Center in tile
    position = Vector2(
      (gridX * 64.0) + 8, // 64 is tileSize, 8 is padding ((64-48)/2)
      (gridY * 64.0) + 8,
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw Cleaner Visual (Blue Circle for prototype)
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = Colors.cyan,
    );

    // Icon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'C',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _cleanTimer += dt;
    if (_cleanTimer >= _cleanInterval) {
      _cleanTimer = 0;
      _performClean();
    }
  }

  void _performClean() {
    // Clean current tile strongly
    final tile = gridManager.getTileAt(gridX, gridY);
    tile?.cleanse(_cleanPower);

    // Clean neighbors weakly
    final dirs = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)];

    for (final dir in dirs) {
      final nx = gridX + dir.x.toInt();
      final ny = gridY + dir.y.toInt();
      final neighbor = gridManager.getTileAt(nx, ny);
      neighbor?.cleanse(_cleanPower * 0.5);
    }
  }
}
