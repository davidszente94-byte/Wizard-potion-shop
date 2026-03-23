class IdleGardenSlot {
  int seedId;
  int startTime;
  int cyclesCompleted;
  bool isActive;

  IdleGardenSlot({
    required this.seedId,
    required this.startTime,
    this.cyclesCompleted = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    "seedId": seedId,
    "start": startTime,
    "cycles": cyclesCompleted,
    "active": isActive,
  };

  factory IdleGardenSlot.fromJson(Map<String, dynamic> json) => IdleGardenSlot(
    seedId: json["seedId"],
    startTime: json["start"],
    cyclesCompleted: json["cycles"] ?? 0,
    isActive: json["active"] ?? true,
  );
}

class IdleBrewSlot {
  String recipeKey;
  int startTime;
  int cyclesCompleted;
  bool isActive;

  IdleBrewSlot({
    required this.recipeKey,
    required this.startTime,
    this.cyclesCompleted = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    "recipe": recipeKey,
    "start": startTime,
    "cycles": cyclesCompleted,
    "active": isActive,
  };

  factory IdleBrewSlot.fromJson(Map<String, dynamic> json) => IdleBrewSlot(
    recipeKey: json["recipe"],
    startTime: json["start"],
    cyclesCompleted: json["cycles"] ?? 0,
    isActive: json["active"] ?? true,
  );
}
