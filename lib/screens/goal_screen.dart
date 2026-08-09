import 'package:flutter/material.dart';

class GoalScreen extends StatefulWidget {
  // This screen accepts a "goal name" from whoever opens it (e.g. "Car", "Home")
  final String goalName;

  const GoalScreen({super.key, required this.goalName});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _result = '';

  void _calculate() {
    final double monthly = double.tryParse(_monthlyController.text) ?? 0;
    final double target = double.tryParse(_targetController.text) ?? 0;

    if (monthly <= 0) {
      setState(() {
        _result = 'Enter a valid monthly amount';
      });
      return;
    }

    final double monthsNeeded = target / monthly;
    final int years = (monthsNeeded / 12).floor();
    final int remainingMonths = (monthsNeeded % 12).round();

    setState(() {
      _result = 'You need $years years and $remainingMonths months';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save for ${widget.goalName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${widget.goalName} price (\$)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly savings (\$)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}