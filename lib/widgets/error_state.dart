import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Tela de erro com opção de tentar novamente.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.mensagem, required this.onTentar});

  final String mensagem;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icone: Icons.error_outline,
      titulo: 'Algo deu errado',
      mensagem: mensagem,
      acaoRotulo: 'Tentar novamente',
      onAcao: onTentar,
    );
  }
}
