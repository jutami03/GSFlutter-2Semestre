/// Configuração da API REST publicada (Opção A do enunciado).
///
/// A API é criada no MockAPI.io (veja o README). Depois de criar o projeto
/// e o recurso `relatos`, cole abaixo a URL base exibida no painel, SEM a
/// barra final e SEM o nome do recurso. Exemplo:
///   https://6543abcd1234ef567890.mockapi.io/api/v1
class ApiConfig {
  ApiConfig._();

  /// URL base da API publicada em nuvem.
  static const String baseUrl = 'https://SEU_PROJETO.mockapi.io/api/v1';

  /// Nome do recurso (coleção) na API.
  static const String recurso = 'relatos';

  /// Tempo máximo de espera por resposta.
  static const Duration tempoLimite = Duration(seconds: 15);

  /// Indica se a URL ainda é o valor de exemplo.
  static bool urlConfigurada(String url) => !url.contains('SEU_PROJETO');
}