import 'package:flutter/material.dart';

import '../models/goal_category.dart';

/// Rounded tinted tile with the category icon.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 48});

  final GoalCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}
