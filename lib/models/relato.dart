/// Categorias possíveis de um relato urbano.
enum CategoriaRelato {
  buraco('Buraco na via'),
  iluminacao('Iluminação pública'),
  lixo('Lixo e entulho'),
  alagamento('Bueiro / alagamento'),
  dengue('Foco de dengue'),
  acessibilidade('Acessibilidade'),
  outro('Outro');

  const CategoriaRelato(this.label);

  final String label;

  /// Converte o texto salvo no banco de volta para o enum.
  static CategoriaRelato fromName(String? nome) {
    return CategoriaRelato.values.firstWhere(
      (c) => c.name == nome,
      orElse: () => CategoriaRelato.outro,
    );
  }
}

/// Situação de um relato (fechamento do ciclo).
enum StatusRelato {
  aberto('Aberto'),
  emAnalise('Em análise'),
  resolvido('Resolvido');

  const StatusRelato(this.label);

  final String label;

  static StatusRelato fromName(String? nome) {
    return StatusRelato.values.firstWhere(
      (s) => s.name == nome,
      orElse: () => StatusRelato.aberto,
    );
  }
}

/// Um problema urbano reportado por um morador.
class Relato {
  const Relato({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.bairro,
    this.status = StatusRelato.aberto,
    this.apoios = 0,
    this.risco = false,
    this.apoiado = false,
    required this.dataCriacao,
  });

  final int? id;
  final String titulo;
  final String descricao;
  final CategoriaRelato categoria;
  final String bairro;
  final StatusRelato status;

  /// Quantidade de moradores que apoiaram (upvotes).
  final int apoios;

  /// Indica risco para a segurança das pessoas.
  final bool risco;

  /// Se este aparelho já apoiou o relato (evita voto repetido).
  final bool apoiado;

  final DateTime dataCriacao;

  bool get resolvido => status == StatusRelato.resolvido;

  Relato copyWith({
    int? id,
    String? titulo,
    String? descricao,
    CategoriaRelato? categoria,
    String? bairro,
    StatusRelato? status,
    int? apoios,
    bool? risco,
    bool? apoiado,
    DateTime? dataCriacao,
  }) {
    return Relato(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      bairro: bairro ?? this.bairro,
      status: status ?? this.status,
      apoios: apoios ?? this.apoios,
      risco: risco ?? this.risco,
      apoiado: apoiado ?? this.apoiado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  /// Regra de negócio do upvote: apoia se ainda não apoiou; caso
  /// contrário remove o apoio. O contador nunca fica negativo.
  Relato alternarApoio() {
    if (apoiado) {
      return copyWith(apoios: apoios > 0 ? apoios - 1 : 0, apoiado: false);
    }
    return copyWith(apoios: apoios + 1, apoiado: true);
  }

  /// Converte para o formato salvo no banco / armazenamento local.
  /// Booleanos viram 0/1 e as datas viram milissegundos.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'bairro': bairro,
      'status': status.name,
      'apoios': apoios,
      'risco': risco ? 1 : 0,
      'apoiado': apoiado ? 1 : 0,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
    };
  }

  factory Relato.fromMap(Map<String, Object?> map) {
    return Relato(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: CategoriaRelato.fromName(map['categoria'] as String?),
      bairro: map['bairro'] as String,
      status: StatusRelato.fromName(map['status'] as String?),
      apoios: (map['apoios'] as int?) ?? 0,
      risco: ((map['risco'] as int?) ?? 0) == 1,
      apoiado: ((map['apoiado'] as int?) ?? 0) == 1,
      dataCriacao:
          DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] as int),
    );
  }
}
