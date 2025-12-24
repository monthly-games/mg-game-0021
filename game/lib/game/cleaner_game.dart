import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../core/game_state.dart';
import '../core/save_manager.dart';
import '../features/grid/grid_manager.dart';
import '../features/cleaners/cleaner_entity.dart';
import '../features/cleaners/defender_cleaner.dart';
import '../features/grid/pollution_tile.dart';
import '../features/enemies/wave_manager.dart';
import '../features/stages/stage_data.dart';
import '../features/vfx/vfx_manager.dart';

class CleanerGame extends FlameGame with TapDetector {
  final AudioManager audio = GetIt.I<AudioManager>();
  final GameState gameState = GameState();
  late GridManager gridManager;
  late SaveManager saveManager;
  late TimerComponent autoSaveTimer;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    // Initialize Camera
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.anchor = Anchor.topLeft;

    // Initialize SaveManager
    saveManager = await SaveManager.init();
    saveManager.loadGame(gameState);

    // Setup Auto-Save (Every 30 seconds)
    autoSaveTimer = TimerComponent(
      period: 30,
      repeat: true,
      onTick: () => saveManager.saveGame(gameState),
    );
    world.add(autoSaveTimer);

    startStage();

    // Listen for Game Over or Stage Clear or Stage Change
    gameState.addListener(_onGameStateChanged);

    // Show HUD
    overlays.add('hud');
  }

  @override
  void onRemove() {
    saveManager.saveGame(gameState);
    super.onRemove();
  }

  int _lastStageIndex = 0;

  void startStage() {
    // Clear existing entities (grids, waves, cleaners, blobs)
    world.removeAll(world.children);

    final currentStage = StageManager.getStage(gameState.currentStageIndex);

    // Initialize Grid
    gridManager = GridManager(gameState, stageData: currentStage);
    world.add(gridManager);

    // Initialize Waves
    final waveManager = WaveManager(gridManager: gridManager, world: world);
    world.add(waveManager);

    gameState.isGameOver = false;
    gameState.isStageClear = false;

    // Play BGM
    // audio.playBgm('bgm_stage_${currentStage.id}');
    // For prototype, just one track
    audio.playBgm('bgm_main');
  }

  void _onGameStateChanged() {
    if (gameState.currentStageIndex != _lastStageIndex) {
      _lastStageIndex = gameState.currentStageIndex;
      startStage();
      resumeEngine();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameState.update(dt);

    // Check Game Over / Win conditions to show dialogs (simple print for prototype)
    if (gameState.isGameOver) {
      // Overlays.add('details') could go here
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameState.isGameOver || gameState.isStageClear) return;

    // Convert screen coordinates to world coordinates
    final worldPos = info
        .eventPosition
        .widget; // Assuming simple camera mapping or using proper conversion
    // For simple FlameGame without complex CameraComponent usage in World, widget pos ~= world pos if zoom is 1 and anchor TopLeft
    // But since we use CameraComponent in Flame 1.x usually, let's just use `info.eventPosition.global` or similar if attached to GameWidget

    // In Flame 1.18+, we usually use world.screenToWorld or similar.
    // Assuming default viewport/camera setup for this simple prototype.
    // For cleaner_game extending FlameGame (which has a default world/camera in new versions), inputs are usually relative to viewport.

    // Simple Grid Mapping
    final int gx = (worldPos.x / PollutionTile.tileSize).floor();
    final int gy = (worldPos.y / PollutionTile.tileSize).floor();

    if (gx >= 0 &&
        gx < GameState.gridWidth &&
        gy >= 0 &&
        gy < GameState.gridHeight) {
      if (gameState.isPlacementMode) {
        _tryPlaceCleaner(gx, gy);
      } else {
        _tryManualClean(gx, gy);
      }
    }
  }

  void _tryManualClean(int gx, int gy) {
    const cost = 5;
    if (gameState.energy >= cost) {
      final matches = gridManager.checkMatch(gx, gy);
      if (matches.length >= 3) {
        gameState.consumeEnergy(cost);
        gridManager.triggerPurification(matches);
        audio.playSfx('clean_burst');
      }
    }
  }

  void _tryPlaceCleaner(int gx, int gy) {
    if (gameState.selectedCleanerType == 'Defender') {
      const cost = 20; // Defender Cost
      if (gameState.energy >= cost) {
        gameState.consumeEnergy(cost);
        final cleaner = DefenderCleaner(
          gridManager: gridManager,
          gridX: gx,
          gridY: gy,
        );
        world.add(cleaner);
        VfxManager.spawnPlacementEffect(world, cleaner.position);
        audio.playSfx('place_cleaner');
      }
    } else {
      const cost = 10; // Purifier Cost
      if (gameState.energy >= cost) {
        gameState.consumeEnergy(cost);
        final cleaner = CleanerEntity(
          gridManager: gridManager,
          gridX: gx,
          gridY: gy,
        );
        world.add(cleaner);
        VfxManager.spawnPlacementEffect(world, cleaner.position);
        audio.playSfx('place_cleaner');
      }
    }
  }
}
