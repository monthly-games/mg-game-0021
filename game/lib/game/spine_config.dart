// import 'package:mg_common_game/core/assets/asset_types.dart'; // SpineAssetMeta not available

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Cleaner Leader ───────────────────────────────────────────

// const kCleanerLeaderMeta = SpineAssetMeta(
//   key: 'cleaner_leader',
//   path: 'spine/characters/cleaner_leader',
//   atlasPath:
//       'assets/spine/characters/cleaner_leader/cleaner_leader.atlas',
//   skeletonPath:
//       'assets/spine/characters/cleaner_leader/cleaner_leader.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Eco Drone ────────────────────────────────────────────────

// const kEcoDroneMeta = SpineAssetMeta(
//   key: 'eco_drone',
//   path: 'spine/characters/eco_drone',
//   atlasPath: 'assets/spine/characters/eco_drone/eco_drone.atlas',
//   skeletonPath: 'assets/spine/characters/eco_drone/eco_drone.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Recycle Bot ──────────────────────────────────────────────

// const kRecycleBotMeta = SpineAssetMeta(
//   key: 'recycle_bot',
//   path: 'spine/characters/recycle_bot',
//   atlasPath:
//       'assets/spine/characters/recycle_bot/recycle_bot.atlas',
//   skeletonPath:
//       'assets/spine/characters/recycle_bot/recycle_bot.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );
