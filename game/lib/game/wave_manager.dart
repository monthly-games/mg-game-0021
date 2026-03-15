import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

/// Wave upgrade management for Cleaner Brigade
class WaveUpgradeManager extends ChangeNotifier {
  double _rewardMultiplier = 1.0;
  double _difficultyBonusMultiplier = 1.0;

  double get rewardMultiplier => _rewardMultiplier;
  double get difficultyBonusMultiplier => _difficultyBonusMultiplier;

  void applyUpgrades(UpgradeManager upgradeManager) {
    _rewardMultiplier = 1.0 + (upgradeManager.getUpgrade('wave_rewards')?.currentValue ?? 0.0);
    _difficultyBonusMultiplier = 1.0 + (upgradeManager.getUpgrade('difficulty_bonus')?.currentValue ?? 0.0);
    notifyListeners();
  }
}
