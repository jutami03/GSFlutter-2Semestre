import '../models/relato.dart';

/// Validações dos campos do formulário (usadas nos `validator` dos
/// TextFormField e testadas isoladamente).
class Validators {
  Validators._();

  static String? titulo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe um título para o relato';
    if (texto.length < 5) return 'Use pelo menos 5 caracteres';
    if (texto.length > 60) return 'Use no máximo 60 caracteres';
    return null;
  }

  static String? descricao(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Descreva o problema';
    if (texto.length < 10) return 'Descreva com pelo menos 10 caracteres';
    if (texto.length > 300) return 'Use no máximo 300 caracteres';
    return null;
  }

  static String? bairro(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o bairro';
    if (texto.length < 3) return 'Use pelo menos 3 caracteres';
    if (texto.length > 40) return 'Use no máximo 40 caracteres';
    return null;
  }

  static String? categoria(CategoriaRelato? valor) {
    if (valor == null) return 'Escolha uma categoria';
    return null;
  }
}