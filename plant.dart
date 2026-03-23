import 'package:flutter/material.dart';

class Plant {
  final int id;
  final String name;
  final int sellPrice;
  final Duration baseGrowTime;
  final String icon;
  final Color color;
  final int xpValue;
  final int unlockLevel;

  const Plant({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.baseGrowTime,
    required this.xpValue,
    required this.icon,
    required this.color,
    required this.unlockLevel,
  });
}
