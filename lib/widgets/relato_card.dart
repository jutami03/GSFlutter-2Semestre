import 'package:flutter/material.dart';

import '../models/relato.dart';
import 'risco_chip.dart';
import 'status_chip.dart';
import 'visuals.dart';

/// Card de um relato (usado na listagem).
class RelatoCard extends StatelessWidget {
  const RelatoCard({
    super.key,
    required this.relato,
    required this.onTap,
    this.onApoiar,
    this.onEditar,
    this.onExcluir,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  final Relato relato;
  final VoidCallback onTap;
  final VoidCallback? onApoiar;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final temMenu = onEditar != null || onExcluir != null;

    return Card(
      margin: margin,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tema.colorScheme.primaryContainer,
                    foregroundColor: tema.colorScheme.onPrimaryContainer,
                    child: Icon(iconeDaCategoria(relato.categoria)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          relato.titulo,
                          style: tema.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${relato.categoria.label} • ${relato.bairro}',
                          style: tema.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (temMenu)
                    PopupMenuButton<String>(
                      tooltip: 'Mais opções',
                      onSelected: (acao) {
                        if (acao == 'editar') onEditar?.call();
                        if (acao == 'excluir') onExcluir?.call();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                relato.descricao,
                style: tema.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        StatusChip(status: relato.status),
                        if (relato.risco) const RiscoChip(),
                      ],
                    ),
                  ),
                  if (onApoiar != null)
                    TextButton.icon(
                      onPressed: onApoiar,
                      icon: Icon(
                        relato.apoiado
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 18,
                      ),
                      label: Text('${relato.apoios}'),
                    )
                  else
                    Text('${relato.apoios} apoios'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
