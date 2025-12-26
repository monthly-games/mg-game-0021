/// VFX Manager for MG-0021 Zero Pollution (Cleaner Game)
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
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.green,
        particleCount: 12,
        duration: 0.4,
        spreadRadius: 25.0,
      ),
    );
  }

  /// Show recycle complete effect
  void showRecycleComplete(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.blue,
        particleCount: 18,
        duration: 0.5,
        spreadRadius: 35.0,
      ),
    );
  }

  /// Show pollution clear effect
  void showPollutionClear(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.cyan,
        particleCount: 25,
        duration: 0.7,
        spreadRadius: 45.0,
      ),
    );
  }

  /// Show area cleaned effect
  void showAreaCleaned(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.lightGreen,
        particleCount: 30,
        duration: 0.8,
        spreadRadius: 50.0,
      ),
    );
  }

  /// Show eco boost effect
  void showEcoBoost(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.teal,
        particleCount: 20,
        duration: 0.5,
        spreadRadius: 40.0,
      ),
    );
  }

  /// Show level complete celebration
  void showLevelComplete(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.amber,
        particleCount: 40,
        duration: 1.0,
        spreadRadius: 60.0,
      ),
    );
  }
}
