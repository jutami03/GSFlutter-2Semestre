import 'package:flutter/material.dart';

import '../models/relato.dart';
import '../screens/home_screen.dart';
import '../screens/relato_detail_screen.dart';
import '../screens/relato_form_screen.dart';
import '../screens/relato_list_screen.dart';
import '../screens/sobre_screen.dart';

/// Rotas nomeadas do app e passagem de argumentos entre telas:
///  - [formulario]: recebe um [Relato] (edição) ou nada (novo relato);
///  - [detalhes]: recebe o `id` (int) do relato.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String lista = '/relatos';
  static const String formulario = '/relatos/formulario';
  static const String detalhes = '/relatos/detalhes';
  static const String sobre = '/sobre';

  static Route<dynamic> gerar(RouteSettings settings) {
    final Widget tela;
    switch (settings.name) {
      case lista:
        tela = const RelatoListScreen();
        break;
      case formulario:
        final args = settings.arguments;
        tela = RelatoFormScreen(relato: args is Relato ? args : null);
        break;
      case detalhes:
        final args = settings.arguments;
        tela = args is int
            ? RelatoDetailScreen(relatoId: args)
            : const HomeScreen();
        break;
      case sobre:
        tela = const SobreScreen();
        break;
      case home:
      default:
        tela = const HomeScreen();
    }
    return MaterialPageRoute<void>(builder: (_) => tela, settings: settings);
  }
}
