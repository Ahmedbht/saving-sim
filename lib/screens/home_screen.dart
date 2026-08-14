import 'package:flutter/material.dart';
import 'goal_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Simulator')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What are you saving for?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            _buildGoalButton(
              context,
              icon: Icons.directions_car,
              label: 'Save for a Car',
              goalName: 'Car',
            ),
            const SizedBox(height: 16),

            _buildGoalButton(
              context,
              icon: Icons.home,
              label: 'Save for a Home',
              goalName: 'Home',
            ),
            const SizedBox(height: 16),

            _buildGoalButton(
              context,
              icon: Icons.savings,
              label: 'General Savings',
              goalName: 'General',
            ),
          ],
        ),
      ),
    );
  }

  // A reusable button builder — avoids repeating the same style 3 times
  Widget _buildGoalButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String goalName,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalScreen(goalName: goalName)),
        );
      },
    );
  }
}