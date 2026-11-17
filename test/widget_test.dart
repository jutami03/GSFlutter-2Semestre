import 'package:flutter_test/flutter_test.dart';
import 'package:zelo/models/relato.dart';
import 'package:zelo/providers/relato_provider.dart';
import 'package:zelo/repositories/local_storage_relato_repository.dart';
import 'package:zelo/repositories/relato_repository.dart';
import 'package:zelo/utils/formatters.dart';
import 'package:zelo/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// Testes de unidade do Zelo (arquivo único).
// Rodar com: flutter test
// =============================================================================

// ----------------------------------------------------------------- helpers

/// Cria um relato de teste com valores padrão.
Relato criarRelato({
  int? id,
  String titulo = 'Buraco na rua principal',
  String descricao = 'Buraco grande que atrapalha o trânsito do bairro.',
  CategoriaRelato categoria = CategoriaRelato.buraco,
  String bairro = 'Centro',
  StatusRelato status = StatusRelato.aberto,
  int apoios = 0,
  bool risco = false,
  bool apoiado = false,
  DateTime? data,
}) {
  return Relato(
    id: id,
    titulo: titulo,
    descricao: descricao,
    categoria: categoria,
    bairro: bairro,
    status: status,
    apoios: apoios,
    risco: risco,
    apoiado: apoiado,
    dataCriacao: data ?? DateTime(2026, 11, 1),
  );
}

/// Repositório em memória para testar o Provider sem acessar o banco.
class FakeRelatoRepository implements RelatoRepository {
  FakeRelatoRepository([List<Relato>? iniciais])
      : itens = List<Relato>.of(iniciais ?? []);

  final List<Relato> itens;

  /// Quando true, toda operação lança erro (simula falha).
  bool falhar = false;

  int _proximoId = 100;

  void _checar() {
    if (falhar) throw Exception('falha simulada');
  }

  @override
  Future<List<Relato>> listar() async {
    _checar();
    return List<Relato>.of(itens);
  }

  @override
  Future<Relato> inserir(Relato relato) async {
    _checar();
    final salvo = relato.copyWith(id: _proximoId++);
    itens.add(salvo);
    return salvo;
  }

  @override
  Future<void> atualizar(Relato relato) async {
    _checar();
    final indice = itens.indexWhere((r) => r.id == relato.id);
    if (indice >= 0) itens[indice] = relato;
  }

  @override
  Future<void> excluir(int id) async {
    _checar();
    itens.removeWhere((r) => r.id == id);
  }
}

void main() {
  // ------------------------------------------------------------------ Modelo
  group('Relato (modelo)', () {
    test('toMap e fromMap preservam todos os dados', () {
      final original = criarRelato(
        id: 7,
        titulo: 'Foco de dengue',
        categoria: CategoriaRelato.dengue,
        status: StatusRelato.emAnalise,
        apoios: 12,
        risco: true,
        apoiado: true,
        data: DateTime(2026, 5, 20, 10, 30),
      );

      final mapa = original.toMap();
      final copia = Relato.fromMap(mapa);

      expect(mapa['risco'], 1);
      expect(mapa['categoria'], 'dengue');
      expect(copia.id, 7);
      expect(copia.categoria, CategoriaRelato.dengue);
      expect(copia.status, StatusRelato.emAnalise);
      expect(copia.apoios, 12);
      expect(copia.risco, isTrue);
      expect(copia.apoiado, isTrue);
      expect(copia.dataCriacao, DateTime(2026, 5, 20, 10, 30));
    });

    test('fromMap usa valores padrão para categoria e status desconhecidos', () {
      final relato = Relato.fromMap({
        'id': 1,
        'titulo': 'Teste',
        'descricao': 'Descrição qualquer',
        'categoria': 'nao_existe',
        'bairro': 'Centro',
        'status': 'invalido',
        'apoios': 0,
        'risco': 0,
        'apoiado': 0,
        'dataCriacao': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      });

      expect(relato.categoria, CategoriaRelato.outro);
      expect(relato.status, StatusRelato.aberto);
    });

    test('copyWith altera apenas os campos informados', () {
      final original = criarRelato(id: 1, titulo: 'Original', apoios: 3);

      final alterado = original.copyWith(status: StatusRelato.resolvido);

      expect(alterado.status, StatusRelato.resolvido);
      expect(alterado.resolvido, isTrue);
      expect(alterado.titulo, 'Original');
      expect(alterado.apoios, 3);
      expect(original.resolvido, isFalse);
    });

    test('alternarApoio apoia, desfaz e nunca deixa o contador negativo', () {
      final apoiado = criarRelato(apoios: 5).alternarApoio();
      expect(apoiado.apoios, 6);
      expect(apoiado.apoiado, isTrue);

      final desfeito = apoiado.alternarApoio();
      expect(desfeito.apoios, 5);
      expect(desfeito.apoiado, isFalse);

      expect(criarRelato(apoios: 0, apoiado: true).alternarApoio().apoios, 0);
    });
  });

  // ------------------------------------------------------ Validações / utils
  group('Validações e formatação', () {
    test('título: rejeita vazio, curto e longo; aceita válido', () {
      expect(Validators.titulo(null), isNotNull);
      expect(Validators.titulo('     '), isNotNull);
      expect(Validators.titulo('Oi'), isNotNull);
      expect(Validators.titulo('a' * 61), isNotNull);
      expect(Validators.titulo('Buraco na avenida'), isNull);
    });

    test('descrição, bairro e categoria validam campos obrigatórios', () {
      expect(Validators.descricao('curta'), isNotNull);
      expect(Validators.descricao('Buraco grande na faixa direita.'), isNull);
      expect(Validators.bairro(''), isNotNull);
      expect(Validators.bairro('Centro'), isNull);
      expect(Validators.categoria(null), isNotNull);
      expect(Validators.categoria(CategoriaRelato.lixo), isNull);
    });

    test('formatarData e textoApoios', () {
      expect(formatarData(DateTime(2026, 3, 5)), '05/03/2026');
      expect(textoApoios(1), '1 morador apoia');
      expect(textoApoios(42), '42 moradores apoiam');
    });
  });

  // ---------------------------------------------------------------- Provider
  group('RelatoProvider', () {
    late FakeRelatoRepository repositorio;
    late RelatoProvider provider;

    setUp(() {
      repositorio = FakeRelatoRepository([
        criarRelato(id: 1, titulo: 'Buraco na avenida', apoios: 10),
        criarRelato(
          id: 2,
          titulo: 'Lixo na esquina',
          categoria: CategoriaRelato.lixo,
          bairro: 'Vila Nova',
          status: StatusRelato.emAnalise,
          apoios: 30,
        ),
        criarRelato(
          id: 3,
          titulo: 'Poste apagado na praça',
          categoria: CategoriaRelato.iluminacao,
          status: StatusRelato.resolvido,
          apoios: 5,
        ),
      ]);
      provider = RelatoProvider(repositorio);
    });

    test('carregar popula a lista ordenada por apoios', () async {
      await provider.carregar();

      expect(provider.carregando, isFalse);
      expect(provider.erro, isNull);
      expect(provider.relatos.map((r) => r.id), [2, 1, 3]);
    });

    test('carregar define erro quando o repositório falha', () async {
      repositorio.falhar = true;

      await provider.carregar();

      expect(provider.erro, isNotNull);
      expect(provider.relatos, isEmpty);
      expect(provider.carregando, isFalse);
    });

    test('adicionar insere o relato e gera id', () async {
      await provider.carregar();

      final ok = await provider.adicionar(criarRelato(titulo: 'Novo relato'));

      expect(ok, isTrue);
      expect(provider.total, 4);
      expect(repositorio.itens.length, 4);
    });

    test('atualizar altera o relato; id inexistente retorna false', () async {
      await provider.carregar();

      final ok = await provider.atualizar(
        provider.buscarPorId(1)!.copyWith(titulo: 'Título editado'),
      );

      expect(ok, isTrue);
      expect(provider.buscarPorId(1)!.titulo, 'Título editado');
      expect(await provider.atualizar(criarRelato(id: 999)), isFalse);
    });

    test('excluir remove o relato da lista e do repositório', () async {
      await provider.carregar();

      final ok = await provider.excluir(2);

      expect(ok, isTrue);
      expect(provider.buscarPorId(2), isNull);
      expect(repositorio.itens.any((r) => r.id == 2), isFalse);
    });

    test('alternarApoio apoia e desfaz, e alterarStatus muda a situação',
        () async {
      await provider.carregar();

      await provider.alternarApoio(1);
      expect(provider.buscarPorId(1)!.apoios, 11);
      expect(provider.buscarPorId(1)!.apoiado, isTrue);

      await provider.alternarApoio(1);
      expect(provider.buscarPorId(1)!.apoios, 10);
      expect(provider.buscarPorId(1)!.apoiado, isFalse);

      await provider.alterarStatus(1, StatusRelato.resolvido);
      expect(provider.buscarPorId(1)!.status, StatusRelato.resolvido);
    });

    test('indicadores: contagens, apoios, percentual e ranking', () async {
      await provider.carregar();

      expect(provider.total, 3);
      expect(provider.totalAbertos, 1);
      expect(provider.totalEmAnalise, 1);
      expect(provider.totalResolvidos, 1);
      expect(provider.totalApoios, 45);
      expect(provider.percentualResolvido, closeTo(1 / 3, 0.001));
      expect(provider.ranking(limite: 2).map((r) => r.id), [2, 1]);
    });

    test('filtros por categoria e por situação', () async {
      await provider.carregar();

      provider.definirFiltroCategoria(CategoriaRelato.lixo);
      expect(provider.relatosFiltrados.map((r) => r.id), [2]);
      expect(provider.temFiltroAtivo, isTrue);

      provider.limparFiltros();
      provider.definirFiltroStatus(StatusRelato.resolvido);
      expect(provider.relatosFiltrados.map((r) => r.id), [3]);
    });

    test('busca ignora maiúsculas e limparFiltros restaura a lista', () async {
      await provider.carregar();

      provider.definirBusca('VILA NOVA');
      expect(provider.relatosFiltrados.map((r) => r.id), [2]);

      provider.limparFiltros();
      expect(provider.temFiltroAtivo, isFalse);
      expect(provider.relatosFiltrados.length, 3);
    });
  });

  // ------------------------------------- Repositório de armazenamento local
  group('LocalStorageRelatoRepository', () {
    late LocalStorageRelatoRepository repositorio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repositorio = LocalStorageRelatoRepository();
    });

    test('na primeira execução carrega os 8 relatos de exemplo (seed)',
        () async {
      final relatos = await repositorio.listar();

      expect(relatos.length, 8);
      expect(relatos.every((r) => r.id != null), isTrue);
    });

    test('inserir, atualizar e excluir persistem as alterações', () async {
      final novo = await repositorio.inserir(criarRelato(titulo: 'Novo'));
      expect((await repositorio.listar()).length, 9);

      await repositorio.atualizar(novo.copyWith(titulo: 'Editado', apoios: 9));
      final editado =
          (await repositorio.listar()).firstWhere((r) => r.id == novo.id);
      expect(editado.titulo, 'Editado');
      expect(editado.apoios, 9);

      await repositorio.excluir(novo.id!);
      expect((await repositorio.listar()).length, 8);
    });

    test('os dados persistem entre instâncias do repositório', () async {
      await repositorio.inserir(criarRelato(titulo: 'Relato persistido'));

      final relatos = await LocalStorageRelatoRepository().listar();

      expect(relatos.any((r) => r.titulo == 'Relato persistido'), isTrue);
    });
  });
}