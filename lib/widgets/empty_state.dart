import 'package:flutter/material.dart';

/// Mensagem amigável exibida quando não há itens para mostrar.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acaoRotulo,
    this.onAcao,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? acaoRotulo;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: tema.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAcao != null && acaoRotulo != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAcao, child: Text(acaoRotulo!)),
            ],
          ],
        ),
      ),
    );
  }
}
