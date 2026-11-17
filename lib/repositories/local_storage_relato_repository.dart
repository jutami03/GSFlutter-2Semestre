import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/relato.dart';
import '../services/seed_data.dart';
import 'relato_repository.dart';

/// Persistência local equivalente ao SQLite para o NAVEGADOR (o sqflite
/// não roda na web). Guarda a lista de relatos em JSON no armazenamento
/// do próprio navegador, de forma assíncrona, e também carrega os dados
/// iniciais (seed) na primeira execução, sem nenhuma configuração.
class LocalStorageRelatoRepository implements RelatoRepository {
  static const String _chaveRelatos = 'zelo_relatos';
  static const String _chaveProximoId = 'zelo_proximo_id';

  @override
  Future<List<Relato>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    await _garantirSeed(prefs);
    return _ler(prefs);
  }

  @override
  Future<Relato> inserir(Relato relato) async {
    final prefs = await SharedPreferences.getInstance();
    await _garantirSeed(prefs);

    final id = prefs.getInt(_chaveProximoId) ?? 1;
    final salvo = relato.copyWith(id: id);
    final lista = _ler(prefs)..add(salvo);

    await prefs.setInt(_chaveProximoId, id + 1);
    await _gravar(prefs, lista);
    return salvo;
  }

  @override
  Future<void> atualizar(Relato relato) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = _ler(prefs);
    final indice = lista.indexWhere((r) => r.id == relato.id);
    if (indice < 0) return;
    lista[indice] = relato;
    await _gravar(prefs, lista);
  }

  @override
  Future<void> excluir(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = _ler(prefs)..removeWhere((r) => r.id == id);
    await _gravar(prefs, lista);
  }

  // --------------------------------------------------------------- helpers

  /// Na primeira execução (chave ainda inexistente) grava o seed.
  /// Se o usuário excluir tudo depois, a chave existe e a lista fica vazia.
  Future<void> _garantirSeed(SharedPreferences prefs) async {
    if (prefs.containsKey(_chaveRelatos)) return;

    var proximo = 1;
    final lista = <Relato>[];
    for (final exemplo in SeedData.relatos()) {
      lista.add(exemplo.copyWith(id: proximo++));
    }
    await prefs.setInt(_chaveProximoId, proximo);
    await _gravar(prefs, lista);
  }

  List<Relato> _ler(SharedPreferences prefs) {
    final texto = prefs.getString(_chaveRelatos);
    if (texto == null || texto.isEmpty) return <Relato>[];
    final bruto = jsonDecode(texto) as List<dynamic>;
    return bruto
        .map((item) => Relato.fromMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> _gravar(SharedPreferences prefs, List<Relato> lista) {
    final texto = jsonEncode(lista.map((r) => r.toMap()).toList());
    return prefs.setString(_chaveRelatos, texto);
  }
}
