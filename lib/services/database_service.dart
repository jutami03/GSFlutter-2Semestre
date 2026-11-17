import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'seed_data.dart';

/// Abre o banco SQLite local. As tabelas são criadas automaticamente na
/// primeira execução (onCreate) e já recebem a carga inicial (seed).
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String _nomeBanco = 'zelo.db';
  static const int _versao = 1;
  static const String tabelaRelatos = 'relatos';

  Future<Database>? _banco;

  Future<Database> get database => _banco ??= _abrir();

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      caminho,
      version: _versao,
      onCreate: _aoCriar,
    );
  }

  Future<void> _aoCriar(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $tabelaRelatos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        bairro TEXT NOT NULL,
        status TEXT NOT NULL,
        apoios INTEGER NOT NULL DEFAULT 0,
        risco INTEGER NOT NULL DEFAULT 0,
        apoiado INTEGER NOT NULL DEFAULT 0,
        dataCriacao INTEGER NOT NULL
      )
    ''');

    final lote = db.batch();
    for (final relato in SeedData.relatos()) {
      final mapa = relato.toMap()..remove('id');
      lote.insert(tabelaRelatos, mapa);
    }
    await lote.commit(noResult: true);
  }
}
