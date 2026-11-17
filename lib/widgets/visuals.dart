import 'package:flutter/material.dart';

import '../models/relato.dart';

/// Ícone de cada categoria de relato.
IconData iconeDaCategoria(CategoriaRelato categoria) {
  switch (categoria) {
    case CategoriaRelato.buraco:
      return Icons.warning_amber_rounded;
    case CategoriaRelato.iluminacao:
      return Icons.lightbulb_outline;
    case CategoriaRelato.lixo:
      return Icons.delete_outline;
    case CategoriaRelato.alagamento:
      return Icons.water_drop_outlined;
    case CategoriaRelato.dengue:
      return Icons.bug_report_outlined;
    case CategoriaRelato.acessibilidade:
      return Icons.accessible;
    case CategoriaRelato.outro:
      return Icons.report_problem_outlined;
  }
}

/// Ícone de cada situação do relato.
IconData iconeDoStatus(StatusRelato status) {
  switch (status) {
    case StatusRelato.aberto:
      return Icons.error_outline;
    case StatusRelato.emAnalise:
      return Icons.hourglass_top;
    case StatusRelato.resolvido:
      return Icons.check_circle_outline;
  }
}
