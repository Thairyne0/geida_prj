class UserProfile {
  final double weight; // kg
  final double height; // cm
  final String name;
  final double dailyKcalGoal;

  UserProfile({
    required this.weight,
    required this.height,
    this.name = '',
    this.dailyKcalGoal = 2000,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Sottopeso';
    if (bmi < 25) return 'Normopeso';
    if (bmi < 30) return 'Sovrappeso';
    return 'Obeso';
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'height': height,
        'name': name,
        'dailyKcalGoal': dailyKcalGoal,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        weight: (json['weight'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        name: json['name'] as String? ?? '',
        dailyKcalGoal: (json['dailyKcalGoal'] as num?)?.toDouble() ?? 2000,
      );
}

