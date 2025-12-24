import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PollutionTile extends PositionComponent {
  final int gridX;
  final int gridY;

  // 0 to 100
  double pollutionValue;

  static const double tileSize = 64.0;

  PollutionTile({
    required this.gridX,
    required this.gridY,
    this.pollutionValue = 0,
  }) {
    size = Vector2.all(tileSize);
    position = Vector2(gridX * tileSize, gridY * tileSize);
  }

  @override
  void render(Canvas canvas) {
    // Determine color based on pollution
    // Green (Clean) -> Purple/Grey (Polluted)
    final color =
        Color.lerp(
          Colors.greenAccent,
          Colors.purple[900]!,
          pollutionValue / 100,
        ) ??
        Colors.grey;

    canvas.drawRect(
      size.toRect().deflate(1.0), // Slight padding for grid look
      Paint()..color = color,
    );

    // Draw Nature if fully clean
    if (pollutionValue <= 0) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 4,
        Paint()..color = Colors.lightGreenAccent,
      );
      // Petals (Simple flower representation)
      canvas.drawCircle(
        Offset(size.x / 2 - 5, size.y / 2 - 5),
        4,
        Paint()..color = Colors.pinkAccent,
      );
      canvas.drawCircle(
        Offset(size.x / 2 + 5, size.y / 2 - 5),
        4,
        Paint()..color = Colors.pinkAccent,
      );
      canvas.drawCircle(
        Offset(size.x / 2 - 5, size.y / 2 + 5),
        4,
        Paint()..color = Colors.pinkAccent,
      );
      canvas.drawCircle(
        Offset(size.x / 2 + 5, size.y / 2 + 5),
        4,
        Paint()..color = Colors.pinkAccent,
      );
    }

    // Debug Text
    // final textPainter = TextPainter(
    //   text: TextSpan(
    //     text: '${pollutionValue.toInt()}',
    //     style: const TextStyle(color: Colors.white, fontSize: 10),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );
    // textPainter.layout();
    // textPainter.paint(canvas, Offset(5, 5));
  }

  void addPollution(double amount) {
    pollutionValue = (pollutionValue + amount).clamp(0, 100);
  }

  void cleanse(double amount) {
    pollutionValue = (pollutionValue - amount).clamp(0, 100);
  }
}
