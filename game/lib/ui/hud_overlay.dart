import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import '../core/game_state.dart';
import '../game/cleaner_game.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


class HudOverlay extends StatelessWidget {
  final CleanerGame game;
  final GameState gameState;

  const HudOverlay({super.key, required this.game, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.md),
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
                            color: MGColors.textHighEmphasis,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: MGSpacing.xxs),
                        Row(
                          children: [
                            const Text(
                              'Pollution: ',
                              style: TextStyle(color: MGColors.textHighEmphasis),
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
                              style: const TextStyle(color: MGColors.textHighEmphasis),
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
                          color: MGColors.success.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(MGSpacing.mdLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'STAGE CLEARED!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: MGColors.textHighEmphasis,
                                  ),
                                ),
                                const SizedBox(height: MGSpacing.mdLg),
                                ElevatedButton(
                                  onPressed: () => gameState.nextStage(),
                                  child: Text('ui_general_next_region'.tr),
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
                        padding: const EdgeInsets.all(MGSpacing.xs),
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
                                      : MGColors.common,
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
