import 'package:flutter/material.dart';

/// Selo de alerta para relatos que oferecem risco às pessoas.
class RiscoChip extends StatelessWidget {
  const RiscoChip({super.key});

  @override
  Widget build(BuildContext context) {
    const cor = Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 14, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'Risco',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
