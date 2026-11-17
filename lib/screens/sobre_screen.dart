import 'package:flutter/material.dart';

import '../utils/ods.dart';
import '../widgets/ods_badge.dart';

/// Tela "Sobre": problema, solução, como funciona e ODS atendidos.
class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    Widget secao(String titulo, String texto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: tema.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(texto, style: tema.textTheme.bodyMedium),
          const SizedBox(height: 20),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Zelo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          secao(
            'O problema',
            'Canais oficiais de prefeituras costumam ser burocráticos e pouco '
                'transparentes. Quando há um buraco perigoso, uma rampa '
                'bloqueada, um foco de dengue ou um bueiro entupido, ninguém '
                'sabe se o problema já foi reportado nem se a prefeitura '
                'está ciente.',
          ),
          secao(
            'A solução',
            'O Zelo (Zeladoria Colaborativa Comunitária) é um "Waze dos '
                'problemas urbanos": o morador registra o problema, os vizinhos '
                'apoiam o relato e os mais votados ganham destaque, funcionando '
                'como um termômetro de prioridades para associações de bairro, '
                'ONGs e o poder público.',
          ),
          secao(
            'Como funciona',
            '1. Reporte o problema com categoria, local e descrição.\n'
                '2. Vizinhos apoiam o relato (um apoio por morador).\n'
                '3. Os problemas mais apoiados sobem no ranking.\n'
                '4. O status evolui: Aberto → Em análise → Resolvido.',
          ),
          Text('Objetivos de Desenvolvimento Sustentável',
              style: tema.textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final ods in odsDoZelo) ...[
            OdsBadge(ods: ods, mostrarDescricao: true),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          secao(
            'Tecnologias',
            'Flutter, Provider (gerenciamento de estado) e uma API REST '
                'publicada em nuvem, consumida com package:http.',
          ),
        ],
      ),
    );
  }
}
