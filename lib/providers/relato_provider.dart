import 'package:flutter/foundation.dart';

import '../models/relato.dart';
import '../repositories/relato_repository.dart';
import '../services/seed_data.dart';

/// Estado da aplicação (Provider). Concentra toda a regra de negócio;
/// as telas apenas observam (Consumer / context.watch) e disparam ações.
class RelatoProvider extends ChangeNotifier {
  RelatoProvider(this._repository);

  final RelatoRepository _repository;

  final List<Relato> _relatos = [];
  bool _carregando = false;
  String? _erro;

  String _busca = '';
  CategoriaRelato? _filtroCategoria;
  StatusRelato? _filtroStatus;

  // ---------------------------------------------------------------- estado

  List<Relato> get relatos => List.unmodifiable(_relatos);

  bool get carregando => _carregando;

  String? get erro => _erro;

  String get busca => _busca;

  CategoriaRelato? get filtroCategoria => _filtroCategoria;

  StatusRelato? get filtroStatus => _filtroStatus;

  bool get temFiltroAtivo =>
      _busca.trim().isNotEmpty ||
      _filtroCategoria != null ||
      _filtroStatus != null;

  // ------------------------------------------------------------ indicadores

  int get total => _relatos.length;

  int get totalAbertos => _contar(StatusRelato.aberto);

  int get totalEmAnalise => _contar(StatusRelato.emAnalise);

  int get totalResolvidos => _contar(StatusRelato.resolvido);

  int get totalApoios => _relatos.fold(0, (soma, r) => soma + r.apoios);

  /// Fração (0 a 1) de relatos já resolvidos.
  double get percentualResolvido => total == 0 ? 0 : totalResolvidos / total;

  Relato? get maisApoiado => _relatos.isEmpty ? null : _relatos.first;

  /// Relatos mais apoiados (a lista já é mantida ordenada por apoios).
  List<Relato> ranking({int limite = 3}) => _relatos.take(limite).toList();

  Relato? buscarPorId(int id) {
    for (final relato in _relatos) {
      if (relato.id == id) return relato;
    }
    return null;
  }

  /// Relatos após aplicar busca por texto, categoria e status.
  List<Relato> get relatosFiltrados {
    final termo = _busca.trim().toLowerCase();
    return _relatos.where((r) {
      if (_filtroCategoria != null && r.categoria != _filtroCategoria) {
        return false;
      }
      if (_filtroStatus != null && r.status != _filtroStatus) {
        return false;
      }
      if (termo.isEmpty) return true;
      return r.titulo.toLowerCase().contains(termo) ||
          r.bairro.toLowerCase().contains(termo) ||
          r.descricao.toLowerCase().contains(termo);
    }).toList();
  }

  // --------------------------------------------------------------- filtros

  void definirBusca(String texto) {
    _busca = texto;
    notifyListeners();
  }

  void definirFiltroCategoria(CategoriaRelato? categoria) {
    _filtroCategoria = categoria;
    notifyListeners();
  }

  void definirFiltroStatus(StatusRelato? status) {
    _filtroStatus = status;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _filtroCategoria = null;
    _filtroStatus = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------ CRUD

  /// READ: carrega todos os relatos do repositório.
  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final lista = await _repository.listar();
      _relatos
        ..clear()
        ..addAll(lista);
      _ordenar();
    } catch (_) {
      _erro = 'Não foi possível carregar os relatos. Tente novamente.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Cria os relatos de exemplo (usado quando a lista está vazia, por
  /// exemplo depois de excluir tudo). Retorna false se falhar.
  Future<bool> carregarExemplos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      for (final exemplo in SeedData.relatos()) {
        await _repository.inserir(exemplo);
      }
    } catch (_) {
      _erro = 'Não foi possível criar os relatos de exemplo. Tente novamente.';
      _carregando = false;
      notifyListeners();
      return false;
    }
    await carregar();
    return _erro == null;
  }

  /// CREATE: insere um novo relato. Retorna false se falhar.
  Future<bool> adicionar(Relato relato) async {
    try {
      final salvo = await _repository.inserir(relato);
      _relatos.add(salvo);
      _ordenar();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// UPDATE: atualiza um relato existente. Retorna false se falhar.
  Future<bool> atualizar(Relato relato) async {
    final id = relato.id;
    if (id == null) return false;
    final indice = _relatos.indexWhere((r) => r.id == id);
    if (indice < 0) return false;
    try {
      await _repository.atualizar(relato);
      _relatos[indice] = relato;
      _ordenar();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// DELETE: remove um relato. Retorna false se falhar.
  Future<bool> excluir(int id) async {
    try {
      await _repository.excluir(id);
      _relatos.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Apoia (upvote) ou remove o apoio de um relato.
  Future<bool> alternarApoio(int id) async {
    final relato = buscarPorId(id);
    if (relato == null) return false;
    return atualizar(relato.alternarApoio());
  }

  /// Muda a situação do relato (Aberto → Em análise → Resolvido).
  Future<bool> alterarStatus(int id, StatusRelato status) async {
    final relato = buscarPorId(id);
    if (relato == null) return false;
    if (relato.status == status) return true;
    return atualizar(relato.copyWith(status: status));
  }

  // --------------------------------------------------------------- helpers

  int _contar(StatusRelato status) =>
      _relatos.where((r) => r.status == status).length;

  void _ordenar() {
    _relatos.sort((a, b) {
      final porApoios = b.apoios.compareTo(a.apoios);
      if (porApoios != 0) return porApoios;
      return b.dataCriacao.compareTo(a.dataCriacao);
    });
  }
}
