import 'package:flutter/material.dart';

import '../models/relato.dart';
import '../theme/app_theme.dart';
import 'visuals.dart';

/// Selo colorido com a situação do relato.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final StatusRelato status;

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconeDoStatus(status), size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: cor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
