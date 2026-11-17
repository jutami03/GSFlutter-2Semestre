import 'package:flutter/material.dart';

import '../models/relato.dart';

/// Identidade visual do Zelo (cores e tipografia padronizadas).
class AppTheme {
  AppTheme._();

  static const Color verde = Color(0xFF1B7F5C);

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: verde,
      brightness: Brightness.light,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: const Color(0xFFF4F7F5),
    );
    final texto = base.textTheme;

    return base.copyWith(
      textTheme: texto.copyWith(
        headlineSmall:
            texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: texto.bodyMedium?.copyWith(height: 1.35),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        centerTitle: false,
      ),
    );
  }
}

/// Decoração padrão dos campos de texto dos formulários.
InputDecoration campoDecoration(
  String rotulo, {
  String? dica,
  IconData? icone,
}) {
  return InputDecoration(
    labelText: rotulo,
    hintText: dica,
    prefixIcon: icone == null ? null : Icon(icone),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );
}

/// Cor associada a cada situação do relato.
Color corDoStatus(StatusRelato status) {
  switch (status) {
    case StatusRelato.aberto:
      return const Color(0xFFC62828);
    case StatusRelato.emAnalise:
      return const Color(0xFFB26A00);
    case StatusRelato.resolvido:
      return const Color(0xFF2E7D32);
  }
}