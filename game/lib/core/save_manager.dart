import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class SaveManager {
  static const String _saveKey = 'game_save_data';

  final SharedPreferences _prefs;

  SaveManager(this._prefs);

  static Future<SaveManager> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SaveManager(prefs);
  }

  Future<void> saveGame(GameState state) async {
    final jsonString = jsonEncode(state.toJson());
    await _prefs.setString(_saveKey, jsonString);
  }

  void loadGame(GameState state) {
    final jsonString = _prefs.getString(_saveKey);
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        state.fromJson(jsonMap);
        state.regenerateOfflineEnergy();
      } catch (e) {
        print('Error loading save: $e');
      }
    }
  }

  Future<void> clearSave() async {
    await _prefs.remove(_saveKey);
  }
}
