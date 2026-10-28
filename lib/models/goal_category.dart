import 'package:flutter/material.dart';

enum GoalCategory {
  car('Car', Icons.directions_car_rounded, Color(0xFF3B82F6)),
  home('Home', Icons.home_rounded, Color(0xFF8B5CF6)),
  travel('Travel', Icons.flight_takeoff_rounded, Color(0xFF06B6D4)),
  emergency('Emergency fund', Icons.health_and_safety_rounded, Color(0xFF10B981)),
  education('Education', Icons.school_rounded, Color(0xFFF59E0B)),
  tech('Tech', Icons.laptop_mac_rounded, Color(0xFF6366F1)),
  wedding('Wedding', Icons.favorite_rounded, Color(0xFFF43F5E)),
  retirement('Retirement', Icons.beach_access_rounded, Color(0xFF14B8A6)),
  other('Other', Icons.savings_rounded, Color(0xFF64748B));

  const GoalCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static GoalCategory fromName(String? name) => GoalCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => GoalCategory.other,
      );
}
