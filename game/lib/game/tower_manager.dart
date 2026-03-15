import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

/// Tower management for Cleaner Brigade
class TowerManager extends ChangeNotifier {
  double _damageMultiplier = 1.0;
  double _rangeMultiplier = 1.0;
  double _attackSpeedMultiplier = 1.0;

  double get damageMultiplier => _damageMultiplier;
  double get rangeMultiplier => _rangeMultiplier;
  double get attackSpeedMultiplier => _attackSpeedMultiplier;

  void applyUpgrades(UpgradeManager upgradeManager) {
    _damageMultiplier = 1.0 + (upgradeManager.getUpgrade('tower_damage')?.currentValue ?? 0.0);
    _rangeMultiplier = 1.0 + (upgradeManager.getUpgrade('tower_range')?.currentValue ?? 0.0);
    _attackSpeedMultiplier = 1.0 + (upgradeManager.getUpgrade('attack_speed')?.currentValue ?? 0.0);
    notifyListeners();
  }
}
