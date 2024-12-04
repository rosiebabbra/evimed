import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConditionDetailPage extends StatelessWidget {
  final String condition;

  ConditionDetailPage({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(condition),
      ),
      body: Center(
        child: Text(
          'Details for $condition',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
