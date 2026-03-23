import '../models/brew_slot.dart';
import '../models/player.dart';
import '../../main.dart';

class BrewingService {
  static bool processIdleBrew(GameState state) {
    bool changed = false;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < GameState.maxBrewSlots; i++) {
      final slot = state.brewSlots[i];
      if (slot == null || !slot.isActive) continue;

      final recipe = getRecipeByKey(slot.recipeKey);
      if (recipe == null) continue;

      final brewTime = state.getBrewTime(recipe).inSeconds;
      final elapsed = (now - slot.startTime) ~/ 1000;
      int possibleCycles = elapsed ~/ brewTime;

      int plantId = recipe.plantTier;
      int available = state.storage[plantId] ~/ 3;
      int affordableCycles = possibleCycles.clamp(0, available);

      for (int c = 0; c < affordableCycles; c++) {
        state.storage[plantId] -= 3;
        int sellPrice = recipe.sellPrice;
        double goldMult = state.getBoostMultiplier(BoostType.gold150, BoostType.gold200, 1.5, 2.0);
        sellPrice = (sellPrice * goldMult).round();
        state.gold += sellPrice;

        int xpGain = recipe.xpValue;
        double xpMult = state.getBoostMultiplier(BoostType.xp150, BoostType.xp200, 1.5, 2.0);
        xpGain = (xpGain * xpMult).round();
        state.gainXP(xpGain);
        slot.cyclesCompleted++;
        changed = true;
      }

      if (affordableCycles > 0) slot.startTime += affordableCycles * brewTime * 1000;
      if (state.storage[recipe.plantTier] < 3) slot.isActive = false;
    }

    return changed;
  }

  static double getBrewSlotProgress(GameState state, int slotIndex) {
    final slot = state.brewSlots[slotIndex];
    if (slot == null) return 0;
    final recipe = getRecipeByKey(slot.recipeKey);
    if (recipe == null) return 0;
    final brewTime = state.getBrewTime(recipe).inSeconds;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = (now - slot.startTime) / 1000;
    return (elapsed / brewTime).clamp(0.0, 1.0);
  }

  static String getBrewSlotTimeLeft(GameState state, int slotIndex) {
    final slot = state.brewSlots[slotIndex];
    if (slot == null) return "";
    final recipe = getRecipeByKey(slot.recipeKey);
    if (recipe == null) return "";
    final brewTime = state.getBrewTime(recipe).inSeconds;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = (now - slot.startTime) ~/ 1000;
    final remaining = brewTime - (elapsed % brewTime);
    return formatTime(remaining);
  }

  static double getBrewGoldPerHour(GameState state, int slotIndex) {
    final slot = state.brewSlots[slotIndex];
    if (slot == null) return 0;
    final recipe = getRecipeByKey(slot.recipeKey);
    if (recipe == null) return 0;
    final brewTime = state.getBrewTime(recipe).inSeconds;
    if (brewTime <= 0) return 0;
    double cyclesPerHour = 3600.0 / brewTime;
    double goldMult = state.getBoostMultiplier(BoostType.gold150, BoostType.gold200, 1.5, 2.0);
    return (recipe.sellPrice * goldMult) * cyclesPerHour;
  }

  static void startIdleBrew(GameState state, int slotIndex, String recipeKey) {
    if (slotIndex >= state.unlockedBrewSlots) return;
    state.brewSlots[slotIndex] = IdleBrewSlot(
      recipeKey: recipeKey,
      startTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static void stopIdleBrew(GameState state, int slotIndex) {
    state.brewSlots[slotIndex] = null;
  }

  static void processOfflineProgress(GameState state, int now, int offlineSeconds) {
    for (int i = 0; i < GameState.maxBrewSlots; i++) {
      final slot = state.brewSlots[i];
      if (slot == null || !slot.isActive) continue;

      final recipe = getRecipeByKey(slot.recipeKey);
      if (recipe == null) continue;

      final brewTime = state.getBrewTime(recipe).inSeconds;
      if (brewTime <= 0) continue;

      int possibleCycles = offlineSeconds ~/ brewTime;
      int plantId = recipe.plantTier;
      int available = state.storage[plantId] ~/ 3;
      possibleCycles = possibleCycles.clamp(0, available);

      for (int c = 0; c < possibleCycles; c++) {
        state.storage[plantId] -= 3;
        int sellPrice = recipe.sellPrice;
        double goldMult = state.getBoostMultiplier(BoostType.gold150, BoostType.gold200, 1.5, 2.0);
        sellPrice = (sellPrice * goldMult).round();
        state.gold += sellPrice;
        slot.cyclesCompleted++;
        int xpGain = recipe.xpValue;
        double xpMult = state.getBoostMultiplier(BoostType.xp150, BoostType.xp200, 1.5, 2.0);
        xpGain = (xpGain * xpMult).round();
        state.gainXP(xpGain);
      }
      slot.startTime = now - (offlineSeconds % brewTime) * 1000;
    }
  }
}
