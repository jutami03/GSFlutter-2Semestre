import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relato.dart';
import '../providers/relato_provider.dart';

/// Pergunta se o usuário quer excluir o relato e, se confirmar, exclui
/// e mostra um SnackBar. Retorna true quando o relato foi excluído.
Future<bool> confirmarEExcluir(BuildContext context, Relato relato) async {
  final provider = context.read<RelatoProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final id = relato.id;

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir relato?'),
      content: Text(
        'O relato "${relato.titulo}" será removido permanentemente.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );

  if (confirmou != true || id == null) return false;

  final ok = await provider.excluir(id);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok ? 'Relato excluído.' : 'Não foi possível excluir o relato.',
      ),
    ),
  );
  return ok;
}
