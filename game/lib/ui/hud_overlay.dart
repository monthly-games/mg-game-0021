import 'package:flutter/material.dart';
import '../core/game_state.dart';
import '../game/cleaner_game.dart';

class HudOverlay extends StatelessWidget {
  final CleanerGame game;
  final GameState gameState;

  const HudOverlay({super.key, required this.game, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Bar: Energy and Pollution
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListenableBuilder(
                  listenable: gameState,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Energy: ${gameState.energy}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Pollution: ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              width: 100,
                              height: 10,
                              color: Colors.grey[800],
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: gameState.pollutionLevel,
                                child: Container(color: Colors.purple),
                              ),
                            ),
                            Text(
                              ' ${(gameState.pollutionLevel * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for future functionality (Settings/Pause)
                  },
                  child: const Icon(Icons.pause),
                ),
              ],
            ),

            const Spacer(),

            // Bottom Bar: Cleaner Selection
            // For prototype, just a text saying "Tap to Place Cleaner (Cost: 20)"
            // Bottom Bar: Cleaner Selection
            ListenableBuilder(
              listenable: gameState,
              builder: (context, _) {
                return Column(
                  children: [
                    if (gameState.isStageClear)
                      Center(
                        child: Card(
                          color: Colors.green.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'STAGE CLEARED!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => gameState.nextStage(),
                                  child: const Text('Next Region'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (!gameState.isStageClear &&
                        !gameState.isGameOver &&
                        gameState.isPlacementMode)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: gameState.unlockedCleaners.map((type) {
                            final isSelected =
                                gameState.selectedCleanerType == type;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () => gameState.selectCleaner(type),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Colors.cyan
                                      : Colors.grey,
                                ),
                                child: Text(
                                  type == 'Defender'
                                      ? 'Defender (20)'
                                      : 'Purifier (10)',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
