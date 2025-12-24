import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../grid/grid_manager.dart';
import 'cleaner_base.dart';

class DefenderCleaner extends PositionComponent implements CleanerBase {
  @override
  final CleanerType type = CleanerType.defender;

  final GridManager gridManager;
  final int gridX;
  final int gridY;

  // Defender logic:
  // It doesn't clean actively.
  // It has high HP (or simple state) to block blobs.
  // For prototype: If a blob hits it, the blob dies and Defender loses HP.

  int health = 3;

  DefenderCleaner({
    required this.gridManager,
    required this.gridX,
    required this.gridY,
  }) {
    size = Vector2.all(48);
    position = Vector2((gridX * 64.0) + 8, (gridY * 64.0) + 8);
  }

  @override
  void render(Canvas canvas) {
    // Shield Visual
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.indigo,
    );

    // HP Indicator
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SHIELD ($health)',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(2, size.y / 2 - 5));
  }

  void takeDamage() {
    health--;
    if (health <= 0) {
      removeFromParent();
    }
  }
}
