import 'package:flutter/material.dart';

/// Objetivo de Desenvolvimento Sustentável atendido pelo Zelo.
class OdsInfo {
  const OdsInfo({
    required this.numero,
    required this.titulo,
    required this.descricao,
    required this.cor,
  });

  final int numero;
  final String titulo;
  final String descricao;
  final Color cor;
}

/// ODS conectados ao projeto.
const List<OdsInfo> odsDoZelo = [
  OdsInfo(
    numero: 11,
    titulo: 'Cidades e Comunidades Sustentáveis',
    descricao:
        'Empodera o cidadão para tornar a cidade mais segura e inclusiva, '
        'mapeando riscos como buracos, rampas bloqueadas e alagamentos.',
    cor: Color(0xFFE08A00),
  ),
  OdsInfo(
    numero: 3,
    titulo: 'Saúde e Bem-Estar',
    descricao:
        'Permite identificar focos de dengue, lixo acumulado e locais sem '
        'iluminação, que afetam a saúde e a segurança dos moradores.',
    cor: Color(0xFF3F8F2E),
  ),
  OdsInfo(
    numero: 9,
    titulo: 'Indústria, Inovação e Infraestrutura',
    descricao:
        'Usa tecnologia acessível para que os próprios moradores mapeiem '
        'a infraestrutura local e priorizem o que precisa de reparo.',
    cor: Color(0xFFE5502A),
  ),
];