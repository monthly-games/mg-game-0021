import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'game/cleaner_game.dart';
import 'game/tower_manager.dart';
import 'game/wave_manager.dart';
import 'game/strategy_manager.dart';
import 'ui/hud_overlay.dart';

// ============================================================
// Puzzle Defense — MG-0021 (Zero Pollution: Cleaner Brigade)
// Genre: Puzzle (tower defense hybrid) · Region: SEA
// Phase 1 Week 4: Mechanic Enhancement
//
// Core loop: Place Cleaners → Match Pollution → Defend Grid
// Subsystems: Tower upgrades, Wave scaling, Strategy bonuses
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();

  // Initialize upgrade persistence
  final upgradeManager = GetIt.I<UpgradeManager>();
  await upgradeManager.loadUpgrades();
  _applyUpgradeEffects(upgradeManager);

  runApp(const CleanerApp());
}

void _setupDI() {
  final di = GetIt.I;

  // ── mg_common_game core systems ──────────────────────────
  if (!di.isRegistered<AudioManager>()) {
    di.registerSingleton<AudioManager>(AudioManager());
  }

  // ── Upgrade system ───────────────────────────────────────
  if (!di.isRegistered<UpgradeManager>()) {
    final upgrades = UpgradeManager();
    di.registerSingleton<UpgradeManager>(upgrades);
    _registerUpgrades(upgrades);
  }

  // ── Game-specific managers ───────────────────────────────
  if (!di.isRegistered<TowerManager>()) {
    di.registerSingleton<TowerManager>(TowerManager());
  }

  if (!di.isRegistered<WaveUpgradeManager>()) {
    di.registerSingleton<WaveUpgradeManager>(
      WaveUpgradeManager(),
    );
  }

  if (!di.isRegistered<StrategyManager>()) {
    di.registerSingleton<StrategyManager>(StrategyManager());
  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  _registerAchievements();
  _registerDailyQuests();
  }
}

// ============================================================
// Upgrade Registration — 8 puzzle-defense upgrades
// Categories: Tower (3), Wave (2), Strategy (3)
// ============================================================

void _registerUpgrades(UpgradeManager manager) {
  // ── Tower upgrades (3) ─────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'tower_damage',
    name: 'Purification Power',
    description:
        'Increases cleaner damage output by 15% per level.',
    maxLevel: 15,
    baseCost: 50,
    costMultiplier: 1.4,
    valuePerLevel: 0.15,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'tower_range',
    name: 'Extended Reach',
    description:
        'Expands cleaner effective range by 10% per level.',
    maxLevel: 10,
    baseCost: 80,
    costMultiplier: 1.5,
    valuePerLevel: 0.10,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'attack_speed',
    name: 'Rapid Clean',
    description:
        'Increases cleaner attack speed by 12% per level.',
    maxLevel: 12,
    baseCost: 60,
    costMultiplier: 1.45,
    valuePerLevel: 0.12,
  ));

  // ── Wave upgrades (2) ──────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'wave_rewards',
    name: 'Eco Bounty',
    description:
        'Boosts energy rewards per completed wave by 20% per level.',
    maxLevel: 10,
    baseCost: 100,
    costMultiplier: 1.5,
    valuePerLevel: 0.20,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'difficulty_bonus',
    name: 'Challenge Master',
    description:
        'Earn bonus rewards from harder waves, +15% per level.',
    maxLevel: 8,
    baseCost: 150,
    costMultiplier: 1.6,
    valuePerLevel: 0.15,
  ));

  // ── Strategy upgrades (3) ──────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'tower_slots',
    name: 'Deployment Grid',
    description: 'Unlocks additional cleaner deployment slots.',
    maxLevel: 5,
    baseCost: 200,
    costMultiplier: 2.0,
    valuePerLevel: 1.0, // +1 slot per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'synergy_bonus',
    name: 'Team Synergy',
    description:
        'Boosts damage when multiple cleaner types are active, '
        '+10% per level.',
    maxLevel: 10,
    baseCost: 120,
    costMultiplier: 1.5,
    valuePerLevel: 0.10,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'ability_cooldown',
    name: 'Quick Response',
    description:
        'Reduces special ability cooldown by 8% per level.',
    maxLevel: 8,
    baseCost: 180,
    costMultiplier: 1.7,
    valuePerLevel: 0.08,
  ));
}

// ============================================================
// Apply current upgrade levels to game managers
// ============================================================

void _applyUpgradeEffects(UpgradeManager upgradeManager) {
  final di = GetIt.I;

  di<TowerManager>().applyUpgrades(upgradeManager);
  di<WaveUpgradeManager>().applyUpgrades(upgradeManager);
  di<StrategyManager>().applyUpgrades(upgradeManager);
}

// ============================================================
// App Root — Puzzle Defense with upgrade overlay
// ============================================================

class CleanerApp extends StatelessWidget {
  const CleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Pollution',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: GameWidget(
        game: CleanerGame(),
        overlayBuilderMap: {
          'hud': (BuildContext context, CleanerGame game) {
            return HudOverlay(
              game: game,
              gameState: game.gameState,
            );
          },
          'upgrades': (BuildContext context, CleanerGame game) {
            return UpgradePanel(game: game);
          },
        },
      ),
    );
  }
}

// ============================================================
// Upgrade Panel — displays all 8 upgrades with purchase UI
// ============================================================

class UpgradePanel extends StatefulWidget {
  final CleanerGame game;

  const UpgradePanel({super.key, required this.game});

  @override
  State<UpgradePanel> createState() => _UpgradePanelState();
}

class _UpgradePanelState extends State<UpgradePanel> {
  final UpgradeManager _upgradeManager =
      GetIt.I<UpgradeManager>();

  static const _categoryLabels = <String, String>{
    'tower': 'Tower',
    'wave': 'Wave',
    'strategy': 'Strategy',
  };

  static const _upgradeCategories = <String, String>{
    'tower_damage': 'tower',
    'tower_range': 'tower',
    'attack_speed': 'tower',
    'wave_rewards': 'wave',
    'difficulty_bonus': 'wave',
    'tower_slots': 'strategy',
    'synergy_bonus': 'strategy',
    'ability_cooldown': 'strategy',
  };

  @override
  void initState() {
    super.initState();
    _upgradeManager.addListener(_onUpgradeChanged);
  }

  @override
  void dispose() {
    _upgradeManager.removeListener(_onUpgradeChanged);
    super.dispose();
  }

  void _onUpgradeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final upgrades = _upgradeManager.allUpgrades;
    final grouped = <String, List<Upgrade>>{};
    for (final upgrade in upgrades) {
      final cat =
          _upgradeCategories[upgrade.id] ?? 'other';
      grouped.putIfAbsent(cat, () => []).add(upgrade);
    }

    return SafeArea(
      child: Material(
        color: Colors.black87,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                children: grouped.entries.map((entry) {
                  final label =
                      _categoryLabels[entry.key] ??
                      entry.key;
                  return _buildCategory(
                    label,
                    entry.value,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'UPGRADES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.bolt,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.game.gameState.energy}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              widget.game.overlays.remove('upgrades');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String label,
    List<Upgrade> upgrades,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: Text(
            '── $label ──',
            style: TextStyle(
              color: _categoryColor(label),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...upgrades.map(_buildUpgradeTile),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildUpgradeTile(Upgrade upgrade) {
    final isMaxed =
        upgrade.currentLevel >= upgrade.maxLevel;
    final cost = upgrade.costForNextLevel;
    final canAfford =
        !isMaxed && widget.game.gameState.energy >= cost;

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    upgrade.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    upgrade.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lv. ${upgrade.currentLevel}'
                    ' / ${upgrade.maxLevel}',
                    style: TextStyle(
                      color: isMaxed
                          ? Colors.greenAccent
                          : Colors.tealAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: canAfford
                    ? () => _purchaseUpgrade(upgrade)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford
                      ? const Color(0xFF20B2AA)
                      : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  isMaxed ? 'MAX' : '$cost',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseUpgrade(Upgrade upgrade) {
    final success = _upgradeManager.purchaseUpgrade(
      upgrade.id,
      () => widget.game.gameState.energy,
      (cost) => widget.game.gameState.consumeEnergy(cost),
    );

    if (success) {
      _applyUpgradeEffects(_upgradeManager);
      _upgradeManager.saveUpgrades();
      setState(() {});
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Tower':
        return Colors.orangeAccent;
      case 'Wave':
        return Colors.cyanAccent;
      case 'Strategy':
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}
