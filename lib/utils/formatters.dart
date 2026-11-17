/// Formata a data como dd/MM/aaaa.
String formatarData(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year}';
}

/// Texto do contador de apoios, com singular/plural.
String textoApoios(int apoios) {
  return apoios == 1 ? '1 morador apoia' : '$apoios moradores apoiam';
}