import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../grid/grid_manager.dart';
import '../cleaners/cleaner_entity.dart';
import '../cleaners/defender_cleaner.dart';

class PollutionBlob extends PositionComponent {
  final GridManager gridManager;
  final Function(PollutionBlob) onKilled;

  Vector2 velocity = Vector2.zero();
  final double speed = 30.0;

  PollutionBlob({
    required this.gridManager,
    required this.onKilled,
    required Vector2 startPos,
  }) {
    position = startPos;
    size = Vector2.all(32);
  }

  @override
  void render(Canvas canvas) {
    // Draw Purple Blob
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = Colors.deepPurpleAccent,
    );
    // Eye
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 - 5),
      4,
      Paint()..color = Colors.yellow,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Simple AI: Move towards center of grid (approx)
    // In a real game, move towards nearest Cleaner

    final center = Vector2(
      (gridManager.width * 64.0) / 2,
      (gridManager.height * 64.0) / 2,
    );

    final dir = (center - position).normalized();
    velocity = dir * speed;
    position += velocity * dt;

    // Collision detection with Cleaners
    // For prototype, simple distance check against all components in parent (if accessible) or GridManager could track them.
    // Let's assume GridManager has a list or we query world.
    // Since we don't have easy access to cleaners list here without passing it,
    // let's just use a simple lifetime or check tile pollution.

    // Self-destruct if reached center or ran out of time
    // For now, let's just check if we are on a clean tile and pollute it
    final gx = (position.x / 64).floor();
    final gy = (position.y / 64).floor();
    final tile = gridManager.getTileAt(gx, gy);

    if (tile != null) {
      if (tile.pollutionValue < 50) {
        tile.addPollution(100 * dt); // Pollute as it walks
      }

      // Check for Defenders on this tile
      // In a real game, use Flame's collision system.
      // For prototype, we query GridManager's children (if possible) or just rely on passing list.
      // Since GridManager doesn't track entities directly in a list (just adds them to world),
      // we might need a better way.
      // WORKAROUND: CleanerGame passes a query callback or we scan siblings.

      final siblings = parent?.children.whereType<Component>();
      if (siblings != null) {
        for (final sibling in siblings) {
          if (sibling is DefenderCleaner) {
            final distance = (sibling.position - position).length;
            if (distance < 32) {
              // Hit
              sibling.takeDamage();
              onKilled(this); // Blob dies
              return;
            }
          }
        }
      }
    }
  }
}
