import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relato.dart';
import '../providers/relato_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ods.dart';
import '../widgets/error_state.dart';
import '../widgets/ods_badge.dart';
import '../widgets/stat_card.dart';

/// Tela inicial (Dashboard CitizenTech): apresenta a solução, mostra
/// indicadores (via Provider) e identifica os ODS atendidos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.location_city),
            SizedBox(width: 8),
            Text('Zelo'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sobre o projeto',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.sobre),
          ),
        ],
      ),
      body: Consumer<RelatoProvider>(
        builder: (context, provider, _) {
          if (provider.erro != null) {
            return ErrorState(
              mensagem: provider.erro!,
              onTentar: provider.carregar,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.carregando)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              const _Apresentacao(),
              const SizedBox(height: 16),
              _Indicadores(provider: provider),
              const SizedBox(height: 16),
              _Botoes(),
              const SizedBox(height: 20),
              _Ranking(provider: provider),
              const SizedBox(height: 20),
              Text(
                'ODS atendidos pelo Zelo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (final ods in odsDoZelo) ...[
                OdsBadge(ods: ods),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Apresentacao extends StatelessWidget {
  const _Apresentacao();

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            esquema.primary,
            Color.lerp(esquema.primary, Colors.black, 0.3)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cada morador é um sensor da cidade',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Reporte buracos, rampas bloqueadas, focos de dengue e bueiros '
            'entupidos. Seus vizinhos apoiam, e os problemas mais votados '
            'viram prioridade para o bairro.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({required this.provider});

  final RelatoProvider provider;

  @override
  Widget build(BuildContext context) {
    final percentual = (provider.percentualResolvido * 100).round();
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 96,
      ),
      children: [
        StatCard(
          icone: Icons.report_outlined,
          valor: '${provider.total}',
          rotulo: 'Relatos no bairro',
          cor: Theme.of(context).colorScheme.primary,
        ),
        StatCard(
          icone: Icons.error_outline,
          valor: '${provider.totalAbertos}',
          rotulo: 'Em aberto',
          cor: corDoStatus(StatusRelato.aberto),
        ),
        StatCard(
          icone: Icons.thumb_up_alt_outlined,
          valor: '${provider.totalApoios}',
          rotulo: 'Apoios da comunidade',
          cor: const Color(0xFF1565C0),
        ),
        StatCard(
          icone: Icons.check_circle_outline,
          valor: '$percentual%',
          rotulo: 'Resolvidos',
          cor: corDoStatus(StatusRelato.resolvido),
        ),
      ],
    );
  }
}

class _Botoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.lista),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver relatos'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.formulario),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Novo relato'),
          ),
        ),
      ],
    );
  }
}

class _Ranking extends StatelessWidget {
  const _Ranking({required this.provider});

  final RelatoProvider provider;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ranking = provider.ranking(limite: 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mais apoiados', style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (ranking.isEmpty)
          const Text('Ainda não há relatos. Seja o primeiro a reportar!')
        else
          Card(
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                for (var i = 0; i < ranking.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(
                      ranking[i].titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${ranking[i].bairro} • ${textoApoios(ranking[i].apoios)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.detalhes,
                      arguments: ranking[i].id,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}