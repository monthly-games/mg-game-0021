import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';

/// MG-0021 Cleaner Defense HUD
/// 청소 타워 디펜스 게임용 HUD - 에너지, 오염도, 웨이브, 클리너 선택
class MGCleanerHud extends StatelessWidget {
  final int energy;
  final double pollutionLevel;
  final int wave;
  final int maxWave;
  final String? selectedCleanerType;
  final List<CleanerOption> cleanerOptions;
  final bool isPlacementMode;
  final bool isStageClear;
  final bool isGameOver;
  final VoidCallback? onPause;
  final VoidCallback? onNextStage;
  final Function(String)? onSelectCleaner;

  const MGCleanerHud({
    super.key,
    required this.energy,
    required this.pollutionLevel,
    required this.wave,
    required this.maxWave,
    this.selectedCleanerType,
    this.cleanerOptions = const [],
    this.isPlacementMode = false,
    this.isStageClear = false,
    this.isGameOver = false,
    this.onPause,
    this.onNextStage,
    this.onSelectCleaner,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 에너지 & 오염도
                Expanded(child: _buildStatusPanel()),
                const SizedBox(width: MGSpacing.sm),
                // 중앙: 웨이브 정보
                _buildWaveInfo(),
                const SizedBox(width: MGSpacing.sm),
                // 오른쪽: 일시정지
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    size: MGIconButtonSize.small,
                  ),
              ],
            ),
            const Spacer(),
            // 하단: 클리너 선택 또는 결과 표시
            if (isStageClear)
              _buildStageClearPanel()
            else if (isGameOver)
              _buildGameOverPanel()
            else if (isPlacementMode && cleanerOptions.isNotEmpty)
              _buildCleanerSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.xs),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 에너지
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 16),
              const SizedBox(width: MGSpacing.xs),
              Text(
                'Energy: $energy',
                style: MGTextStyles.buttonSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.xs),
          // 오염도
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.purple, size: 16),
              const SizedBox(width: MGSpacing.xs),
              Expanded(
                child: MGLinearProgress(
                  value: pollutionLevel,
                  height: 10,
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  progressColor: _getPollutionColor(),
                ),
              ),
              const SizedBox(width: MGSpacing.xs),
              Text(
                '${(pollutionLevel * 100).toInt()}%',
                style: MGTextStyles.caption.copyWith(
                  color: _getPollutionColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPollutionColor() {
    if (pollutionLevel > 0.8) return Colors.red;
    if (pollutionLevel > 0.5) return Colors.orange;
    if (pollutionLevel > 0.3) return Colors.yellow;
    return Colors.purple;
  }

  Widget _buildWaveInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.8),
            Colors.teal.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WAVE',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            '$wave / $maxWave',
            style: MGTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanerSelection() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: cleanerOptions.map((option) {
          final bool isSelected = selectedCleanerType == option.type;
          final bool canAfford = energy >= option.cost;

          return GestureDetector(
            onTap: canAfford ? () => onSelectCleaner?.call(option.type) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MGSpacing.md,
                vertical: MGSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withOpacity(0.3)
                    : canAfford
                        ? MGColors.surface
                        : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MGSpacing.sm),
                border: Border.all(
                  color: isSelected
                      ? option.color
                      : canAfford
                          ? MGColors.border
                          : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    color: canAfford ? option.color : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: MGSpacing.xxs),
                  Text(
                    option.name,
                    style: MGTextStyles.buttonSmall.copyWith(
                      color: canAfford ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${option.cost} E',
                    style: MGTextStyles.caption.copyWith(
                      color: canAfford ? Colors.yellow : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStageClearPanel() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(MGSpacing.md),
        border: Border.all(color: Colors.greenAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: MGSpacing.sm),
          Text(
            'STAGE CLEARED!',
            style: MGTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MGSpacing.md),
          if (onNextStage != null)
            ElevatedButton(
              onPressed: onNextStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
              child: const Text('Next Region'),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverPanel() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(MGSpacing.md),
        border: Border.all(color: Colors.redAccent, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 48),
          const SizedBox(height: MGSpacing.sm),
          Text(
            'POLLUTION CRITICAL',
            style: MGTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Mission Failed',
            style: MGTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class CleanerOption {
  final String type;
  final String name;
  final int cost;
  final IconData icon;
  final Color color;

  const CleanerOption({
    required this.type,
    required this.name,
    required this.cost,
    required this.icon,
    required this.color,
  });
}
