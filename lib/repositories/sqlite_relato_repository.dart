import '../models/relato.dart';
import '../services/database_service.dart';
import 'relato_repository.dart';

/// Implementação do repositório usando SQLite (sqflite), usada no
/// Android e no iOS. Todas as operações são assíncronas (async/await).
class SqliteRelatoRepository implements RelatoRepository {
  SqliteRelatoRepository({DatabaseService? servico})
      : _servico = servico ?? DatabaseService.instance;

  final DatabaseService _servico;

  @override
  Future<List<Relato>> listar() async {
    final db = await _servico.database;
    final linhas = await db.query(
      DatabaseService.tabelaRelatos,
      orderBy: 'apoios DESC, dataCriacao DESC',
    );
    return linhas.map(Relato.fromMap).toList();
  }

  @override
  Future<Relato> inserir(Relato relato) async {
    final db = await _servico.database;
    final mapa = relato.toMap()..remove('id');
    final id = await db.insert(DatabaseService.tabelaRelatos, mapa);
    return relato.copyWith(id: id);
  }

  @override
  Future<void> atualizar(Relato relato) async {
    final db = await _servico.database;
    await db.update(
      DatabaseService.tabelaRelatos,
      relato.toMap(),
      where: 'id = ?',
      whereArgs: [relato.id],
    );
  }

  @override
  Future<void> excluir(int id) async {
    final db = await _servico.database;
    await db.delete(
      DatabaseService.tabelaRelatos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
