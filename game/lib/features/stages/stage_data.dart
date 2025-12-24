import 'package:flutter/material.dart';

class StageData {
  final String id;
  final String name;
  final int width;
  final int height;
  final Color themeColor;
  final double pollutionSpreadRate; // Modifies interval
  final double initialPollutionDensity;

  StageData({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.themeColor,
    this.pollutionSpreadRate = 2.0,
    this.initialPollutionDensity = 0.3,
  });
}

class StageManager {
  static final List<StageData> stages = [
    StageData(
      id: 'stage_1_beach',
      name: 'Pristine Beach',
      width: 6,
      height: 8,
      themeColor: Colors.blueAccent,
      pollutionSpreadRate: 5.0, // Very Slow spread (Tutorial pace)
      initialPollutionDensity: 0.15,
    ),
    StageData(
      id: 'stage_2_city',
      name: 'Smog City',
      width: 8,
      height: 10,
      themeColor: Colors.grey,
      pollutionSpreadRate: 2.5, // Moderate
      initialPollutionDensity: 0.35,
    ),
    StageData(
      id: 'stage_3_factory',
      name: 'Toxic Factory',
      width: 8,
      height: 12,
      themeColor: Colors.deepOrange,
      pollutionSpreadRate: 1.2, // Fast
      initialPollutionDensity: 0.5,
    ),
  ];

  static StageData getStage(int index) {
    if (index >= 0 && index < stages.length) {
      return stages[index];
    }
    return stages[0]; // Default fallback
  }
}
