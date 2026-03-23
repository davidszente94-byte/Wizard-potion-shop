import '../../main.dart';
import '../models/player.dart';

class XPService {
  static final List<int> expRequirements = [
    100, 400, 1000, 5000, 12000, 14000, 15000, 16000, 17000, 18000,
    24000, 32000, 45000, 60000, 80000, 110000, 140000, 170000, 220000, 286000,
    371800, 483340, 628342, 816845, 1061898, 1380467, 1794608, 2332990, 3032887, 3942753,
    4139891, 4346885, 4564229, 4792441, 5032063, 5283666, 5547849, 5825242, 6116504, 6422329,
    6743445, 7080618, 7434649, 7806381, 8196700, 8606535
  ];

  static int neededExp(int lvl) {
    if (lvl < 1) return 100;
    if (lvl > expRequirements.length) return expRequirements.last * 2;
    return expRequirements[lvl - 1];
  }

  static double xpProgress(GameState state) => (state.xp / neededExp(state.level)).clamp(0.0, 1.0);

  static List<String> gainXP(
    GameState state,
    int amount, {
    required void Function() notifyLeveled,
  }) {
    int xp = state.xp;
    int level = state.level;

    xp += amount;
    List<String> rewards = [];
    bool leveled = false;

    while (xp >= neededExp(level)) {
      xp -= neededExp(level);
      level++;
      leveled = true;
      final gift = getLevelUpGift(level);
      if (gift.isNotEmpty) {
        final giftText = gift.values.first;
        rewards.add("Level $level: $giftText");
        if (giftText.contains("crystal")) {
          final match = RegExp(r'\+(\d+)').firstMatch(giftText);
          if (match != null) {
            state.crystals = state.crystals + int.parse(match.group(1)!);
          }
        } else if (giftText.contains("Gold Boost Token")) {
          final now = DateTime.now().millisecondsSinceEpoch;
          state.activeBoosts.add(ActiveBoost(type: BoostType.gold150, endTime: now + (4 * 60 * 60 * 1000)));
        } else if (giftText.contains("XP Boost Token")) {
          final now = DateTime.now().millisecondsSinceEpoch;
          state.activeBoosts.add(ActiveBoost(type: BoostType.xp150, endTime: now + (4 * 60 * 60 * 1000)));
        } else if (giftText.contains("gardenslot") && state.unlockedSlots < GameState.maxGardenSlots) {
          state.unlockedSlots++;
        } else if (giftText.contains("brewingslot") && state.unlockedBrewSlots < GameState.maxBrewSlots) {
          state.unlockedBrewSlots++;
        }
      }
    }

    state.xp = xp;
    state.level = level;

    if (leveled) notifyLeveled();
    return rewards;
  }
}
