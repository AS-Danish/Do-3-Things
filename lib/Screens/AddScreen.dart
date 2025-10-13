import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add New'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 50,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a new task or item',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}