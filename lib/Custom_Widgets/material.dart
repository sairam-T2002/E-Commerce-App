import 'package:flutter/material.dart';

class LearnMaterialAppWidget extends StatelessWidget {
  const LearnMaterialAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.cyanAccent,
          child: const Center(
            child: Column(
              children: [
                Text(
                  'Hello',
                  style: TextStyle(color: Colors.amber),
                ),
                Text('World!')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
