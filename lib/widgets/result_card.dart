// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final int errorCount;
  final String description;
  final Color baseColor;

  const ResultCard({
    super.key,
    required this.title,
    required this.errorCount,
    required this.description,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: baseColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Found $errorCount error(s)',
            style: TextStyle(
              color: baseColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: baseColor.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
