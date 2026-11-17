import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relato.dart';
import '../providers/relato_provider.dart';
import '../routes/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/confirmar_exclusao.dart';
import '../widgets/empty_state.dart';
import '../widgets/risco_chip.dart';
import '../widgets/status_chip.dart';
import '../widgets/visuals.dart';

/// Detalhes de um relato. Recebe o `id` pela rota e observa o Provider,
/// então qualquer mudança (apoio, status, edição) aparece na hora.
class RelatoDetailScreen extends StatelessWidget {
  const RelatoDetailScreen({super.key, required this.relatoId});

  final int relatoId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelatoProvider>();
    final relato = provider.buscarPorId(relatoId);

    if (relato == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relato')),
        body: const EmptyState(
          icone: Icons.search_off,
          titulo: 'Relato não encontrado',
          mensagem: 'Ele pode ter sido excluído.',
        ),
      );
    }

    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do relato'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.formulario,
              arguments: relato,
            ),
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _excluir(context, relato),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: tema.colorScheme.primaryContainer,
                foregroundColor: tema.colorScheme.onPrimaryContainer,
                child: Icon(iconeDaCategoria(relato.categoria)),
              ),
              const SizedBox(width: 10),
              Text(relato.categoria.label, style: tema.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(relato.titulo, style: tema.textTheme.headlineSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(status: relato.status),
              if (relato.risco) const RiscoChip(),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Bairro / local'),
                  subtitle: Text(relato.bairro),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Reportado em'),
                  subtitle: Text(formatarData(relato.dataCriacao)),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição', style: tema.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(relato.descricao, style: tema.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apoio da comunidade', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(textoApoios(relato.apoios)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: relato.apoiado
                        ? OutlinedButton.icon(
                            onPressed: () => provider.alternarApoio(relatoId),
                            icon: const Icon(Icons.thumb_up),
                            label: const Text('Você apoiou (toque para desfazer)'),
                          )
                        : FilledButton.icon(
                            onPressed: () => provider.alternarApoio(relatoId),
                            icon: const Icon(Icons.thumb_up_outlined),
                            label: const Text('Apoiar este relato'),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Situação do relato', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Atualize conforme o problema avança até ser resolvido.',
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<StatusRelato>(
                      showSelectedIcon: false,
                      segments: [
                        for (final status in StatusRelato.values)
                          ButtonSegment(value: status, label: Text(status.label)),
                      ],
                      selected: {relato.status},
                      onSelectionChanged: (selecao) =>
                          provider.alterarStatus(relatoId, selecao.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.formulario,
              arguments: relato,
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Editar relato'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: tema.colorScheme.error,
            ),
            onPressed: () => _excluir(context, relato),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir relato'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluir(BuildContext context, Relato relato) async {
    final navigator = Navigator.of(context);
    final excluiu = await confirmarEExcluir(context, relato);
    if (excluiu) navigator.pop();
  }
}
