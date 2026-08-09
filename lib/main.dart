import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _monthlycontroller = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _totalSavings = 0.0;

  void _calculate() {
    final double monthly = double.tryParse(_monthlycontroller.text) ?? 0;
    final int years = int.tryParse(_yearsController.text) ?? 0;

    setState(() {
      _totalSavings = monthly * 12 * years;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Saving Simulator')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _monthlycontroller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Savings (\$)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of Years'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 20),
              Text(
                'Total Savings: \$${_totalSavings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
