/// 가챠 시스템 어댑터 - MG-0021 Cleaner Game
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/gacha/gacha_pool.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';

/// 게임 내 Tool 모델
class Tool {
  final String id;
  final String name;
  final GachaRarity rarity;
  final Map<String, dynamic> stats;

  const Tool({
    required this.id,
    required this.name,
    required this.rarity,
    this.stats = const {},
  });
}

/// Cleaner Game 가챠 어댑터
class ToolGachaAdapter extends ChangeNotifier {
  final GachaManager _gachaManager = GachaManager(
    pityConfig: const PityConfig(
      softPityStart: 70,
      hardPity: 80,
      softPityBonus: 6.0,
    ),
    multiPullGuarantee: const MultiPullGuarantee(
      minRarity: GachaRarity.rare,
    ),
  );

  static const String _poolId = 'cleaner_pool';

  ToolGachaAdapter() {
    _initPool();
  }

  void _initPool() {
    final pool = GachaPool(
      id: _poolId,
      nameKr: 'Cleaner Game 가챠',
      items: _generateItems(),
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
    _gachaManager.registerPool(pool);
  }

  List<GachaItem> _generateItems() {
    return [
      // UR (0.6%)
      GachaItem(id: 'ur_cleaner_001', nameKr: '전설의 Tool', rarity: GachaRarity.ultraRare),
      GachaItem(id: 'ur_cleaner_002', nameKr: '신화의 Tool', rarity: GachaRarity.ultraRare),
      // SSR (2.4%)
      GachaItem(id: 'ssr_cleaner_001', nameKr: '영웅의 Tool', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_cleaner_002', nameKr: '고대의 Tool', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_cleaner_003', nameKr: '황금의 Tool', rarity: GachaRarity.superRare),
      // SR (12%)
      GachaItem(id: 'sr_cleaner_001', nameKr: '희귀한 Tool A', rarity: GachaRarity.superRare),
      GachaItem(id: 'sr_cleaner_002', nameKr: '희귀한 Tool B', rarity: GachaRarity.superRare),
      GachaItem(id: 'sr_cleaner_003', nameKr: '희귀한 Tool C', rarity: GachaRarity.superRare),
      GachaItem(id: 'sr_cleaner_004', nameKr: '희귀한 Tool D', rarity: GachaRarity.superRare),
      // R (35%)
      GachaItem(id: 'r_cleaner_001', nameKr: '우수한 Tool A', rarity: GachaRarity.rare),
      GachaItem(id: 'r_cleaner_002', nameKr: '우수한 Tool B', rarity: GachaRarity.rare),
      GachaItem(id: 'r_cleaner_003', nameKr: '우수한 Tool C', rarity: GachaRarity.rare),
      GachaItem(id: 'r_cleaner_004', nameKr: '우수한 Tool D', rarity: GachaRarity.rare),
      GachaItem(id: 'r_cleaner_005', nameKr: '우수한 Tool E', rarity: GachaRarity.rare),
      // N (50%)
      GachaItem(id: 'n_cleaner_001', nameKr: '일반 Tool A', rarity: GachaRarity.normal),
      GachaItem(id: 'n_cleaner_002', nameKr: '일반 Tool B', rarity: GachaRarity.normal),
      GachaItem(id: 'n_cleaner_003', nameKr: '일반 Tool C', rarity: GachaRarity.normal),
      GachaItem(id: 'n_cleaner_004', nameKr: '일반 Tool D', rarity: GachaRarity.normal),
      GachaItem(id: 'n_cleaner_005', nameKr: '일반 Tool E', rarity: GachaRarity.normal),
      GachaItem(id: 'n_cleaner_006', nameKr: '일반 Tool F', rarity: GachaRarity.normal),
    ];
  }

  /// 단일 뽑기
  Tool? pullSingle() {
    final result = _gachaManager.pull(_poolId);
    if (result == null) return null;
    notifyListeners();
    return _convertToItem(result.item);
  }

  /// 10연차
  List<Tool> pullTen() {
    final results = _gachaManager.multiPull(_poolId, count: 10);
    notifyListeners();
    return results.map((r) => _convertToItem(r.item)).toList();
  }

  Tool _convertToItem(GachaItem item) {
    return Tool(
      id: item.id,
      name: item.nameKr,
      rarity: item.rarity,
    );
  }

  /// 천장까지 남은 횟수
  int get pullsUntilPity => _gachaManager.remainingPity(_poolId);

  /// 총 뽑기 횟수
  int get totalPulls => _gachaManager.getPityState(_poolId)?.totalPulls ?? 0;

  /// 통계
  GachaStats get stats => _gachaManager.getStats(_poolId);

  Map<String, dynamic> toJson() => _gachaManager.toJson();
  void loadFromJson(Map<String, dynamic> json) {
    _gachaManager.loadFromJson(json);
    notifyListeners();
  }
}
