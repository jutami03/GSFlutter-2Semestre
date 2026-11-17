import '../models/relato.dart';

/// Contrato da camada de dados. O Provider depende apenas desta
/// interface, o que permite trocar o SQLite pelo armazenamento da web ou por
/// um repositório falso nos testes de unidade.
abstract class RelatoRepository {
  Future<List<Relato>> listar();

  Future<Relato> inserir(Relato relato);

  Future<void> atualizar(Relato relato);

  Future<void> excluir(int id);
}
