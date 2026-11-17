import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relato.dart';
import '../providers/relato_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/confirmar_exclusao.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/relato_card.dart';

/// Listagem dinâmica (ListView.builder) com busca e filtros, e com
/// tratamento de loading, lista vazia e erro.
class RelatoListScreen extends StatefulWidget {
  const RelatoListScreen({super.key});

  @override
  State<RelatoListScreen> createState() => _RelatoListScreenState();
}

class _RelatoListScreenState extends State<RelatoListScreen> {
  late final TextEditingController _buscaCtrl;

  @override
  void initState() {
    super.initState();
    _buscaCtrl = TextEditingController(
      text: context.read<RelatoProvider>().busca,
    );
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario([Relato? relato]) {
    Navigator.pushNamed(context, AppRoutes.formulario, arguments: relato);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatos do bairro'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RelatoProvider>().carregar(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo relato'),
      ),
      body: Consumer<RelatoProvider>(
        builder: (context, provider, _) {
          // 1) Carregando
          if (provider.carregando && provider.relatos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2) Erro
          if (provider.erro != null) {
            return ErrorState(
              mensagem: provider.erro!,
              onTentar: provider.carregar,
            );
          }
          // 3) Conteúdo (com filtros)
          return Column(
            children: [
              _Filtros(provider: provider, buscaCtrl: _buscaCtrl),
              Expanded(child: _Lista(provider: provider, onEditar: _abrirFormulario)),
            ],
          );
        },
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.provider, required this.buscaCtrl});

  final RelatoProvider provider;
  final TextEditingController buscaCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: buscaCtrl,
            onChanged: provider.definirBusca,
            decoration: InputDecoration(
              hintText: 'Buscar por título, bairro ou descrição',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.busca.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        buscaCtrl.clear();
                        provider.definirBusca('');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: provider.filtroCategoria == null,
                onSelected: (_) => provider.definirFiltroCategoria(null),
              ),
              for (final categoria in CategoriaRelato.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(categoria.label),
                  selected: provider.filtroCategoria == categoria,
                  onSelected: (selecionado) => provider
                      .definirFiltroCategoria(selecionado ? categoria : null),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              ChoiceChip(
                label: const Text('Qualquer status'),
                selected: provider.filtroStatus == null,
                onSelected: (_) => provider.definirFiltroStatus(null),
              ),
              for (final status in StatusRelato.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(status.label),
                  selected: provider.filtroStatus == status,
                  onSelected: (selecionado) =>
                      provider.definirFiltroStatus(selecionado ? status : null),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.provider, required this.onEditar});

  final RelatoProvider provider;
  final void Function(Relato relato) onEditar;

  @override
  Widget build(BuildContext context) {
    final itens = provider.relatosFiltrados;

    // Lista vazia: nenhum relato cadastrado ainda
    if (provider.relatos.isEmpty) {
      return EmptyState(
        icone: Icons.inbox_outlined,
        titulo: 'Nenhum relato por aqui ainda',
        mensagem:
            'Toque em "Novo relato" para reportar um problema ou carregue '
            'relatos de exemplo para conhecer o app.',
        acaoRotulo: 'Carregar relatos de exemplo',
        onAcao: provider.carregarExemplos,
      );
    }

    // Lista vazia: filtros não encontraram nada
    if (itens.isEmpty) {
      return EmptyState(
        icone: Icons.search_off,
        titulo: 'Nada encontrado',
        mensagem: 'Nenhum relato combina com a busca ou os filtros atuais.',
        acaoRotulo: 'Limpar filtros',
        onAcao: provider.limparFiltros,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 88),
        itemCount: itens.length,
        itemBuilder: (context, indice) {
          final relato = itens[indice];
          return RelatoCard(
            relato: relato,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detalhes,
              arguments: relato.id,
            ),
            onApoiar: relato.id == null
                ? null
                : () => provider.alternarApoio(relato.id!),
            onEditar: () => onEditar(relato),
            onExcluir: () => confirmarEExcluir(context, relato),
          );
        },
      ),
    );
  }
}