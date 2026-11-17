import '../models/relato.dart';

/// Carga inicial inserida na primeira execução do banco, para o app já
/// abrir "vivo" (sem nenhuma configuração manual).
class SeedData {
  SeedData._();

  static List<Relato> relatos() {
    final agora = DateTime.now();
    DateTime ha(int dias) => agora.subtract(Duration(days: dias));

    return [
      Relato(
        titulo: 'Buraco perigoso na avenida principal',
        descricao:
            'Buraco grande na faixa da direita, já causou queda de moto. '
            'Sem sinalização e muito perigoso à noite.',
        categoria: CategoriaRelato.buraco,
        bairro: 'Jardim das Flores',
        apoios: 42,
        risco: true,
        dataCriacao: ha(12),
      ),
      Relato(
        titulo: 'Rampa de acessibilidade bloqueada',
        descricao:
            'A rampa da esquina da praça está bloqueada por entulho, '
            'impedindo a passagem de cadeirantes.',
        categoria: CategoriaRelato.acessibilidade,
        bairro: 'Centro',
        status: StatusRelato.emAnalise,
        apoios: 27,
        dataCriacao: ha(9),
      ),
      Relato(
        titulo: 'Foco de dengue em terreno baldio',
        descricao:
            'Água parada em pneus e caixas num terreno abandonado. '
            'Moradores já viram muitos mosquitos na região.',
        categoria: CategoriaRelato.dengue,
        bairro: 'Vila Nova',
        apoios: 35,
        risco: true,
        dataCriacao: ha(7),
      ),
      Relato(
        titulo: 'Bueiro entupido causa alagamento',
        descricao:
            'Sempre que chove forte a rua alaga porque o bueiro da esquina '
            'está entupido de folhas e lixo.',
        categoria: CategoriaRelato.alagamento,
        bairro: 'Parque São José',
        apoios: 31,
        risco: true,
        dataCriacao: ha(6),
      ),
      Relato(
        titulo: 'Poste sem iluminação na praça',
        descricao:
            'Três postes apagados deixam a praça escura e insegura '
            'para quem volta do trabalho.',
        categoria: CategoriaRelato.iluminacao,
        bairro: 'Jardim das Flores',
        status: StatusRelato.resolvido,
        apoios: 18,
        dataCriacao: ha(20),
      ),
      Relato(
        titulo: 'Lixo acumulado na esquina',
        descricao:
            'O lixo está há dias sem coleta e já atrai ratos e '
            'mau cheiro para os vizinhos.',
        categoria: CategoriaRelato.lixo,
        bairro: 'Vila Nova',
        status: StatusRelato.emAnalise,
        apoios: 12,
        dataCriacao: ha(4),
      ),
      Relato(
        titulo: 'Calçada quebrada em frente à escola',
        descricao:
            'A calçada está esburacada e as crianças precisam descer para '
            'a rua para passar.',
        categoria: CategoriaRelato.acessibilidade,
        bairro: 'Centro',
        apoios: 9,
        risco: true,
        dataCriacao: ha(3),
      ),
      Relato(
        titulo: 'Descarte irregular de entulho',
        descricao:
            'Caminhões descartam entulho todo fim de semana no fim da '
            'rua, bloqueando parte da via.',
        categoria: CategoriaRelato.lixo,
        bairro: 'Parque São José',
        status: StatusRelato.resolvido,
        apoios: 6,
        dataCriacao: ha(15),
      ),
    ];
  }
}