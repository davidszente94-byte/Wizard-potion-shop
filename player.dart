enum BoostType {
  gold150,
  gold200,
  xp150,
  xp200,
  plantSpeed150,
  plantSpeed200,
  potionSpeed150,
  potionSpeed200
}

class ActiveBoost {
  final BoostType type;
  final int endTime;

  ActiveBoost({required this.type, required this.endTime});

  Map<String, dynamic> toJson() => {'type': type.index, 'endTime': endTime};

  factory ActiveBoost.fromJson(Map<String, dynamic> json) => ActiveBoost(
    type: BoostType.values[json['type']],
    endTime: json['endTime'],
  );
}
