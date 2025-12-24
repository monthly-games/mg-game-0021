import 'dart:math';
import 'package:flame/components.dart';
import '../../core/game_state.dart';
import '../stages/stage_data.dart';
import '../vfx/vfx_manager.dart';
import 'pollution_tile.dart';

class GridManager extends Component {
  final GameState gameState;
  final StageData stageData;
  late int width;
  late int height;

  late List<List<PollutionTile>> _grid;

  // Timer for spreading pollution
  double _spreadTimer = 0.0;
  late double _spreadInterval; // Seconds

  GridManager(this.gameState, {required this.stageData}) {
    width = stageData.width;
    height = stageData.height;
    _spreadInterval = stageData.pollutionSpreadRate;
  }

  @override
  Future<void> onLoad() async {
    _grid = List.generate(height, (y) {
      return List.generate(width, (x) {
        // Initial random pollution pattern based on stage density
        double startPollution =
            (Random().nextDouble() < stageData.initialPollutionDensity)
            ? (Random().nextDouble() * 50) + 30
            : 0;

        final tile = PollutionTile(
          gridX: x,
          gridY: y,
          pollutionValue: startPollution,
        );
        add(tile); // Add as child component to render
        return tile;
      });
    });

    _updateGlobalPollution();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _spreadTimer += dt;
    if (_spreadTimer >= _spreadInterval) {
      _spreadTimer = 0;
      _spreadPollution();
    }
  }

  void _spreadPollution() {
    // Simple Cellular Automata:
    // If a tile is very polluted (>80), it spreads to neighbors
    // If a tile is clean (<10), it helps neighbors slightly (nature recovery)

    // Use a temp grid to avoid cascading updates in same frame
    // For simplicity in prototype, direct update but randomized order could work.
    // Let's do a 2-pass or just iterate.

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final tile = _grid[y][x];

        if (tile.pollutionValue > 80) {
          _affectNeighbors(x, y, 2.0); // Spread visual pollution
        }
      }
    }

    _updateGlobalPollution();
  }

  void _affectNeighbors(int cx, int cy, double amount) {
    final dirs = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)];

    for (final dir in dirs) {
      final nx = cx + dir.x;
      final ny = cy + dir.y;

      if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
        _grid[ny.toInt()][nx.toInt()].addPollution(amount);
      }
    }
  }

  void _updateGlobalPollution() {
    double total = 0;
    for (var row in _grid) {
      for (var tile in row) {
        total += tile.pollutionValue;
      }
    }
    // Normalize: Average pollution (0-100) -> 0.0-1.0
    gameState.setPollutionLevel((total / (width * height)) / 100.0);
  }

  PollutionTile? getTileAt(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return _grid[y][x];
    }
    return null;
  }

  // Puzzle Logic: Find connected tiles with similar pollution (> 50)
  List<PollutionTile> checkMatch(int startX, int startY) {
    final startTile = getTileAt(startX, startY);
    if (startTile == null || startTile.pollutionValue < 30)
      return []; // Too clean to match

    List<PollutionTile> matches = [];
    Set<PollutionTile> visited = {};
    List<PollutionTile> queue = [startTile];
    visited.add(startTile);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      matches.add(current);

      final dirs = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)];

      for (final dir in dirs) {
        final nx = current.gridX + dir.x;
        final ny = current.gridY + dir.y;
        final neighbor = getTileAt(nx.toInt(), ny.toInt());

        if (neighbor != null && !visited.contains(neighbor)) {
          // Similarity check: Both polluted enough and within 20 unit range
          if (neighbor.pollutionValue >= 30 &&
              (neighbor.pollutionValue - startTile.pollutionValue).abs() < 30) {
            visited.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }
    return matches;
  }

  void triggerPurification(List<PollutionTile> tiles) {
    for (final tile in tiles) {
      tile.cleanse(100); // Instant clean
      // Visual feedback
      // Need reference to world. GridManager is a Component in World, so `parent` might be World?
      // Or we can assume GridManager is added to world.
      final worldRef = parent;
      if (worldRef is World) {
        VfxManager.spawnCleanBurst(
          worldRef,
          tile.position + Vector2.all(PollutionTile.tileSize / 2),
        );
      }
    }
  }
}
