import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  // 0.0 means 0% pollution, 1.0 means 100% pollution (Game Over)
  double pollutionLevel = 0.5;
  int energy = 100;
  int maxEnergy = 100;

  // Grid Dimensions
  static const int gridWidth = 8;
  static const int gridHeight = 10;

  // Game Status
  bool isPlacementMode = true;
  bool isGameOver = false;
  bool isStageClear = false;

  int currentStageIndex = 0;
  List<String> unlockedCleaners = ['Purifier'];
  String selectedCleanerType = 'Purifier'; // 'Purifier' or 'Defender'
  DateTime? lastSaveTime;

  void selectCleaner(String type) {
    if (unlockedCleaners.contains(type)) {
      selectedCleanerType = type;
      notifyListeners();
    }
  }

  void nextStage() {
    currentStageIndex++;
    // Unlocking logic could go here
    if (currentStageIndex == 1 && !unlockedCleaners.contains('Defender')) {
      unlockedCleaners.add('Defender');
    }
    resetForStage();
  }

  void resetForStage() {
    isGameOver = false;
    isStageClear = false;
    // Reset energy/resources if needed
    notifyListeners();
  }

  void reset() {
    energy = 100;
    pollutionLevel = 0.5;
    isGameOver = false;
    isStageClear = false;
    notifyListeners();
  }

  void toggleMode() {
    isPlacementMode = !isPlacementMode;
    notifyListeners();
  }

  void update(double dt) {
    if (isGameOver || isStageClear) return;

    // Global pollution decay or passive growth could happen here
    // but usually handled by GridManager spreading
  }

  void addEnergy(int amount) {
    energy = (energy + amount).clamp(0, maxEnergy);
    notifyListeners();
  }

  void consumeEnergy(int amount) {
    if (energy >= amount) {
      energy -= amount;
      notifyListeners();
    }
  }

  void setPollutionLevel(double level) {
    pollutionLevel = level.clamp(0.0, 1.0);
    if (pollutionLevel >= 1.0) {
      isGameOver = true;
    } else if (pollutionLevel <= 0.0) {
      isStageClear = true;
    }
    notifyListeners();
  }

  void regenerateOfflineEnergy() {
    if (lastSaveTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSaveTime!);
      final minutesPassed = difference.inMinutes;
      if (minutesPassed > 0) {
        addEnergy(minutesPassed); // 1 Energy per minute
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'pollutionLevel': pollutionLevel,
      'currentStageIndex': currentStageIndex,
      'unlockedCleaners': unlockedCleaners,
      'lastSaveTime': DateTime.now().toIso8601String(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    energy = json['energy'] as int? ?? 100;
    pollutionLevel = (json['pollutionLevel'] as num?)?.toDouble() ?? 0.5;
    currentStageIndex = json['currentStageIndex'] as int? ?? 0;
    unlockedCleaners = List<String>.from(
      json['unlockedCleaners'] as List? ?? ['Purifier'],
    );
    if (json['lastSaveTime'] != null) {
      lastSaveTime = DateTime.tryParse(json['lastSaveTime'] as String);
    }
    notifyListeners();
  }
}
