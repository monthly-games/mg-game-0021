/// VFX Manager for MG-0021 Zero Pollution (Cleaner Game)
library;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';

class VfxManager extends Component {
  VfxManager();

  Component? _gameRef;

  void setGame(Component game) {
    _gameRef = game;
  }

  void _addEffect(Component effect) {
    _gameRef?.add(effect);
  }

  /// Show trash collect effect
  void showTrashCollect(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.green,
          radius: 25.0,
        ),
    );
  }

  /// Show recycle complete effect
  void showRecycleComplete(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.blue,
          radius: 35.0,
        ),
    );
  }

  /// Show pollution clear effect
  void showPollutionClear(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.cyan,
          radius: 45.0,
        ),
    );
  }

  /// Show area cleaned effect
  void showAreaCleaned(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.lightGreen,
          radius: 50.0,
        ),
    );
  }

  /// Show eco boost effect
  void showEcoBoost(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.teal,
          radius: 40.0,
        ),
    );
  }

  /// Show level complete celebration
  void showLevelComplete(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.amber,
          radius: 60.0,
        ),
    );
  }
}
