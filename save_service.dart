import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/brew_slot.dart';
import '../core/models/player.dart';
import '../main.dart';

class SaveService {
  static Future<void> load(GameState state) async {
    state.prefs = await SharedPreferences.getInstance();
    state.gold = state.prefs.getInt("gold") ?? 0;
    state.crystals = state.prefs.getInt("crystals") ?? 0;
    state.unlockedSlots = state.prefs.getInt("unlockedSlots") ?? 1;
    state.unlockedBrewSlots = state.prefs.getInt("unlockedBrewSlots") ?? 1;
    state.growSpeedLevel = state.prefs.getInt("growSpeedLevel") ?? 1;
    state.brewSpeedLevel = state.prefs.getInt("brewSpeedLevel") ?? 1;
    state.level = state.prefs.getInt("level") ?? 1;
    state.xp = state.prefs.getInt("xp") ?? 0;
    state.lastSaveTime = state.prefs.getInt("lastSaveTime") ?? DateTime.now().millisecondsSinceEpoch;
    state.lastLoginDay = state.prefs.getInt("lastLoginDay") ?? 0;
    state.consecutiveLogins = state.prefs.getInt("consecutiveLogins") ?? 0;
    state.lastShopResetDay = state.prefs.getInt("lastShopResetDay") ?? 0;

    if (state.unlockedBrewSlots < 1) {
      state.unlockedBrewSlots = 1;
      await state.prefs.setInt("unlockedBrewSlots", 1);
    }

    final boostsJson = state.prefs.getString("activeBoosts");
    if (boostsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(boostsJson);
        state.activeBoosts = decoded.map((j) => ActiveBoost.fromJson(j)).toList();
      } catch (e) {
        state.activeBoosts = [];
      }
    }

    final dailyJson = state.prefs.getString("dailyPurchases");
    if (dailyJson != null) {
      try {
        state.dailyPurchases = Map<String, int>.from(jsonDecode(dailyJson));
      } catch (e) {
        state.dailyPurchases = {};
      }
    }

    for (int i = 0; i < plants.length; i++) state.storage[i] = state.prefs.getInt("storage_$i") ?? 0;
    for (int i = 0; i < seeds.length; i++) state.seedStorage[i] = state.prefs.getInt("seeds_$i") ?? 0;

    for (int i = 0; i < GameState.maxGardenSlots; i++) {
      String? data = state.prefs.getString("garden_$i");
      if (data != null) {
        try {
          state.gardenSlots[i] = IdleGardenSlot.fromJson(jsonDecode(data));
        } catch (e) {
          state.gardenSlots[i] = null;
        }
      }
    }

    for (int i = 0; i < GameState.maxBrewSlots; i++) {
      String? data = state.prefs.getString("brew_$i");
      if (data != null) {
        try {
          state.brewSlots[i] = IdleBrewSlot.fromJson(jsonDecode(data));
        } catch (e) {
          state.brewSlots[i] = null;
        }
      }
    }
  }

  static Future<void> save(GameState state) async {
    state.lastSaveTime = DateTime.now().millisecondsSinceEpoch;
    await state.prefs.setInt("gold", state.gold);
    await state.prefs.setInt("crystals", state.crystals);
    await state.prefs.setInt("unlockedSlots", state.unlockedSlots);
    await state.prefs.setInt("unlockedBrewSlots", state.unlockedBrewSlots);
    await state.prefs.setInt("growSpeedLevel", state.growSpeedLevel);
    await state.prefs.setInt("brewSpeedLevel", state.brewSpeedLevel);
    await state.prefs.setInt("level", state.level);
    await state.prefs.setInt("xp", state.xp);
    await state.prefs.setInt("lastSaveTime", state.lastSaveTime);
    await state.prefs.setInt("lastLoginDay", state.lastLoginDay);
    await state.prefs.setInt("consecutiveLogins", state.consecutiveLogins);
    await state.prefs.setInt("lastShopResetDay", state.lastShopResetDay);
    await state.prefs.setString("activeBoosts", jsonEncode(state.activeBoosts.map((b) => b.toJson()).toList()));
    await state.prefs.setString("dailyPurchases", jsonEncode(state.dailyPurchases));

    for (int i = 0; i < plants.length; i++) await state.prefs.setInt("storage_$i", state.storage[i]);
    for (int i = 0; i < seeds.length; i++) await state.prefs.setInt("seeds_$i", state.seedStorage[i]);

    for (int i = 0; i < GameState.maxGardenSlots; i++) {
      if (state.gardenSlots[i] != null) {
        await state.prefs.setString("garden_$i", jsonEncode(state.gardenSlots[i]!.toJson()));
      } else {
        await state.prefs.remove("garden_$i");
      }
    }

    for (int i = 0; i < GameState.maxBrewSlots; i++) {
      if (state.brewSlots[i] != null) {
        await state.prefs.setString("brew_$i", jsonEncode(state.brewSlots[i]!.toJson()));
      } else {
        await state.prefs.remove("brew_$i");
      }
    }
  }
}
