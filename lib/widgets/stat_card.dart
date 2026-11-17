import 'package:flutter/material.dart';

/// Cartão de indicador rápido do dashboard (ex.: total de relatos).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 8),
                Text(valor, style: tema.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              rotulo,
              style: tema.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
