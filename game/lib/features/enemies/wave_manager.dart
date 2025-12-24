import 'dart:math';
import 'package:flame/components.dart';
import '../grid/grid_manager.dart';
import 'pollution_blob.dart';

class WaveManager extends Component {
  final GridManager gridManager;
  final World world;

  double _spawnTimer = 0.0;
  final double _spawnInterval = 5.0; // Every 5 seconds
  final Random _rng = Random();

  WaveManager({required this.gridManager, required this.world});

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnWave();
    }
  }

  void _spawnWave() {
    // Spawn 1-2 blobs at random edge
    int count = 1 + _rng.nextInt(2);
    for (int i = 0; i < count; i++) {
      _spawnBlob();
    }
  }

  void _spawnBlob() {
    // Pick random edge position
    double x, y;
    if (_rng.nextBool()) {
      // Horizontal edge
      x = _rng.nextDouble() * (gridManager.width * 64.0);
      y = _rng.nextBool() ? -50 : (gridManager.height * 64.0) + 50;
    } else {
      // Vertical edge
      x = _rng.nextBool() ? -50 : (gridManager.width * 64.0) + 50;
      y = _rng.nextDouble() * (gridManager.height * 64.0);
    }

    final blob = PollutionBlob(
      gridManager: gridManager,
      onKilled: (b) => b.removeFromParent(),
      startPos: Vector2(x, y),
    );

    world.add(blob);
  }
}
