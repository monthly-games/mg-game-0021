import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'game/cleaner_game.dart';
import 'game/tower_manager.dart';
import 'game/wave_manager.dart';
import 'game/strategy_manager.dart';
import 'ui/hud_overlay.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/collection_screen.dart';
// // import 'game/tutorial_config.dart'; // TutorialManager not available
// import 'game/balancing_config.dart'; // BalancingManager not available
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:mg_common_game/systems/quests/daily_quest_v2.dart';
// import 'package:mg_common_game/core/ui/screens/daily_quest_screen_v2.dart';
// import 'package:mg_common_game/l10n/localization.dart';
import 'package:mg_common_game/l10n/extensions.dart';
// 
// ============================================================
// Puzzle Defense -- MG-0021 (Zero Pollution: Cleaner Brigade)
// Genre: Puzzle (tower defense hybrid) · Region: SEA
// Phase 1 Week 4: Mechanic Enhancement
// //
// Core loop: Place Cleaners → Match Pollution → Defend Grid
// Subsystems: Tower upgrades, Wave scaling, Strategy bonuses
// ============================================================
// 
void main() async {
WidgetsFlutterBinding.ensureInitialized();
// Initialize Firebase Remote Config
// Initialize Firebase Core
try {
// await // // Firebase.initializeApp(
options: // DefaultFirebaseOptions.currentPlatform,
);
print('Firebase Core initialized successfully');
} catch (e) {
print('Failed to initialize Firebase Core: $e');
}
try {
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setDefaults({
'feature_iap_enabled': true,
'feature_new_ui_enabled': false,
'feature_daily_rewards_enabled': true,
'feature_tutorial_enabled': true,
'min_app_version': '1.0.0',

      'feature_battlepass': true,
      'feature_gacha': true,});
await remoteConfig.fetchAndActivate();
print('Remote Config initialized successfully');
} catch (e) {
print('Failed to initialize Remote Config: $e');
}
_setupDI();
await GetIt.I<AudioManager>().initialize();
// Initialize upgrade persistence
final upgradeManager = GetIt.I<UpgradeManager>();
await upgradeManager.loadUpgrades();
_applyUpgradeEffects(upgradeManager);
// ── Tutorial & Balancing ──────────────────────────────────
if (!GetIt.I.isRegistered<TutorialManager>()) {
final tutorialManager = TutorialManager();
await tutorialManager.initialize();
tutorialManager.registerTutorial(
kOnboardingTutorial.id,
kOnboardingTutorial.steps,
);
GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
}
if (!GetIt.I.isRegistered<BalancingManager>()) {
GetIt.I.registerSingleton<BalancingManager>(
BalancingManager(defaultConfig: kDefaultBalancingConfig),
);
}
// ── Q7 DI Fix: Missing Systems ──────────────────────────
if (!GetIt.I.isRegistered<BattlePassManager>()) {
GetIt.I.registerSingleton<BattlePassManager>(BattlePassManager());
}
if (!GetIt.I.isRegistered<GachaManager>()) {
GetIt.I.registerSingleton<GachaManager>(GachaManager());
}
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
}
// DailyQuest 시스템
if (!GetIt.I.isRegistered<DailyQuestManager>()) {
// Daily Quest V2 - 7 Quest System with Streak Bonuses
if (!GetIt.I.isRegistered<DailyQuestManagerV2>()) {
final questManager = DailyQuestManagerV2();
// Slot 0: Login Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_0',
title: 'Daily Login',
description: 'Ready, set, play!',
type: QuestType.login,
tier: QuestTier.easy,
targetValue: 1,
baseGoldReward: 50,
baseXpReward: 20,
),
slotIndex: 0,
);
// Slot 1: Play Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_1',
title: 'Arcade Session',
description: 'Play 10 rounds',
type: QuestType.play,
tier: QuestTier.easy,
targetValue: 10,
baseGoldReward: 100,
baseXpReward: 40,
),
slotIndex: 1,
);
// Slot 2: Win Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_2',
title: 'Score Attack',
description: 'Score 10,000 points total',
type: QuestType.win,
tier: QuestTier.medium,
targetValue: 10000,
baseGoldReward: 150,
baseXpReward: 60,
),
slotIndex: 2,
);
// Slot 3: Upgrade Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_3',
title: 'Power Up',
description: 'Use 5 power-ups',
type: QuestType.upgrade,
tier: QuestTier.easy,
targetValue: 5,
baseGoldReward: 120,
baseXpReward: 50,
),
slotIndex: 3,
);
// Slot 4: Social Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_4',
title: 'Compete',
description: 'Beat 3 friend scores',
type: QuestType.social,
tier: QuestTier.medium,
targetValue: 3,
baseGoldReward: 150,
baseXpReward: 60,
),
slotIndex: 4,
);
// Slot 5: Achievement Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_5',
title: 'High Scorer',
description: 'Set a new high score',
type: QuestType.achievement,
tier: QuestTier.medium,
targetValue: 1,
baseGoldReward: 250,
baseXpReward: 100,
),
slotIndex: 5,
);
// Slot 6: Bonus Quest
questManager.registerQuest(
DailyQuestV2(
id: 'quest_slot_6',
title: 'Survival Master',
description: 'Survive for 5 minutes',
type: QuestType.bonus,
tier: QuestTier.special,
targetValue: 300,
baseGoldReward: 400,
baseXpReward: 150,
baseGemReward: 15,
),
slotIndex: 6,
);
// Setup streak bonus callbacks
questManager.onStreakMilestoneReached = (streak) {
if (GetIt.I.isRegistered<SettingsManager>()) {
GetIt.I<SettingsManager>().triggerVibration(
intensity: VibrationIntensity.heavy,
);
}
};
if (!GetIt.I.isRegistered<questManager>()) {
    GetIt.I.registerSingleton(questManager);
  };
await questManager.loadQuestData();
await questManager.checkAndResetIfNeeded();
}
}
// Achievement 시스템
if (!GetIt.I.isRegistered<AchievementManager>()) {
if (!GetIt.I.isRegistered<AchievementManager(>()) {
    GetIt.I.registerSingleton(AchievementManager();
  });
}
// Collection 시스템
if (!GetIt.I.isRegistered<CollectionManager>()) {
if (!GetIt.I.isRegistered<CollectionManager(>()) {
    GetIt.I.registerSingleton(CollectionManager();
  });
_registerCollections();
}
// ── Retention Systems for DailyHub ────────────────────────
if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
if (!GetIt.I.isRegistered<LoginRewardsManager(>()) {
    GetIt.I.registerSingleton(LoginRewardsManager();
  });
}
if (!GetIt.I.isRegistered<StreakManager>()) {
if (!GetIt.I.isRegistered<StreakManager(>()) {
    GetIt.I.registerSingleton(StreakManager();
  });
}
if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
if (!GetIt.I.isRegistered<DailyChallengeManager(>()) {
    GetIt.I.registerSingleton(DailyChallengeManager();
  });
}
// ── P3 Engine Systems ─────────────────────────────────────
if (!GetIt.I.isRegistered<GuildWarManager>()) {
if (!GetIt.I.isRegistered<GuildWarManager(>()) {
    GetIt.I.registerSingleton(GuildWarManager();
  });
}
if (!GetIt.I.isRegistered<TournamentManager>()) {
if (!GetIt.I.isRegistered<TournamentManager(>()) {
    GetIt.I.registerSingleton(TournamentManager();
  });
}
if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
if (!GetIt.I.isRegistered<SeasonalContentManager(>()) {
    GetIt.I.registerSingleton(SeasonalContentManager();
  });
}
_registerAchievements();
_registerDailyQuests();
}
// 
// ============================================================
// Upgrade Registration -- 8 puzzle-defense upgrades
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
// App Root -- Puzzle Defense with upgrade overlay
// ============================================================

class CleanerApp extends StatelessWidget {
  const CleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {
        // Settings updated
      },
      child: MaterialApp(
      title: 'Zero Pollution',
      supportedLocales: mgSupportedLocales,
      localizationsDelegates: mgLocalizationDelegates,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      routes: {
        '/daily-quests': (_) => const DailyQuestScreen(),
        '/achievements': (_) => const AchievementScreen(),
          '/daily_quest': (_) => const DailyQuestScreen(),
          '/achievement': (_) => const AchievementScreen(),
          '/battlepass': (_) => const BattlePassScreen(),
          '/gacha': (_) => const GachaScreen(),
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
        
        '/collection': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        '/guild-war': (context) => GuildWarScreen(
          guildWarManager: GetIt.I<GuildWarManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/tournament': (context) => TournamentScreen(
          tournamentManager: GetIt.I<TournamentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/seasonal-event': (context) => SeasonalEventScreen(
          seasonalContentManager: GetIt.I<SeasonalContentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
      },
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
    ),
    );
  }
}

// ============================================================
// Upgrade Panel -- displays all 8 upgrades with purchase UI
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
              color: MGColors.textHighEmphasis,
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
              color: MGColors.textHighEmphasis,
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
                      color: MGColors.textHighEmphasis,
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
                  foregroundColor: MGColors.textHighEmphasis,
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
        return MGColors.textHighEmphasis;
    }
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();

  dailyQuest.registerQuest(DailyQuest(
    id: 'clean_areas',
    title: '구역 청소',
    description: '오염 구역 5개 청소',
    targetValue: 5,
    goldReward: 500,
    xpReward: 10,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'survive_waves',
    title: '웨이브 생존',
    description: '웨이브 10회 생존',
    targetValue: 10,
    goldReward: 300,
    xpReward: 5,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'restore_eco',
    title: '생태계 복원',
    description: '에코 포인트 100 획득',
    targetValue: 100,
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

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: const CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: const CollectionReward(type: RewardType.gold, amount: 1000),
      50: const CollectionReward(type: RewardType.gold, amount: 3000),
      75: const CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}
