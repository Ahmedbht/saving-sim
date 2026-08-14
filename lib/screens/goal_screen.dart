import 'package:flutter/material.dart';

class GoalScreen extends StatefulWidget {
  final String goalName;

  const GoalScreen({super.key, required this.goalName});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _result = '';
  bool _hasResult = false;
  String? _errirText;
  void _calculate() {
    final double monthly = double.tryParse(_monthlyController.text) ?? 0;
    final double target = double.tryParse(_targetController.text) ?? 0;

    if (monthly <= 0 || target <= 0) {
      setState(() {
        _result = 'Please enter valid numbers';
        _hasResult = true;
      });
      return;
    }

    final double monthsNeeded = target / monthly;
    final int years = (monthsNeeded / 12).floor();
    final int remainingMonths = (monthsNeeded % 12).round();

    setState(() {
      _result = '$years years and $remainingMonths months';
      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save for ${widget.goalName}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${widget.goalName} price (\$)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _monthlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly savings (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.savings),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _calculate,
              child: const Text('Calculate', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            if (_hasResult)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Time needed',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
