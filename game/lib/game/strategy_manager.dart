import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

/// Strategy management for Cleaner Brigade
class StrategyManager extends ChangeNotifier {
  double _towerSlots = 0;
  double _synergyBonus = 1.0;
  double _abilityCooldownReduction = 0.0;

  double get towerSlots => _towerSlots;
  double get synergyBonus => _synergyBonus;
  double get abilityCooldownReduction => _abilityCooldownReduction;

  void applyUpgrades(UpgradeManager upgradeManager) {
    _towerSlots = upgradeManager.getUpgrade('tower_slots')?.currentValue ?? 0.0;
    _synergyBonus = 1.0 + (upgradeManager.getUpgrade('synergy_bonus')?.currentValue ?? 0.0);
    _abilityCooldownReduction = upgradeManager.getUpgrade('ability_cooldown')?.currentValue ?? 0.0;
    notifyListeners();
  }
}
