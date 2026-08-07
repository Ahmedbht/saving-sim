import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(44.6),
          child: TextField(
            decoration: InputDecoration(labelText: 'Monthly saving'),
          ),
        ),
      ),
    );
  }
}
