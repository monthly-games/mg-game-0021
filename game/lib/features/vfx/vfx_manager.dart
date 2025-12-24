import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class VfxManager {
  static final Random _rnd = Random();

  static void spawnCleanBurst(World world, Vector2 position) {
    // A burst of green/cyan particles
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        count: 15,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: Vector2(
            _rnd.nextDouble() * 200 - 100,
            _rnd.nextDouble() * 200 - 200,
          ),
          position: position,
          child: CircleParticle(
            radius: 3.0,
            paint: Paint()
              ..color = i % 2 == 0
                  ? Colors.cyanAccent
                  : Colors.lightGreenAccent,
          ),
        ),
      ),
    );

    world.add(particle);
  }

  static void spawnPlacementEffect(World world, Vector2 position) {
    final particle = ParticleSystemComponent(
      particle:
          Particle.generate(
              count: 10,
              lifespan: 0.4,
              generator: (i) => ComputedParticle(
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = Colors.white.withOpacity(1 - particle.progress);
                  canvas.drawCircle(
                    Offset.zero,
                    (particle.progress * 10) + 2,
                    paint,
                  );
                },
              ),
            )
            ..position =
                position, // ComputedParticle doesn't move itself usually unless nested
    );
    world.add(particle);
  }
}
