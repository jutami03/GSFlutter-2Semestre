import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/relato_provider.dart';
import 'repositories/relato_repository.dart';
import 'repositories/local_storage_relato_repository.dart';
import 'repositories/sqlite_relato_repository.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZeloApp());
}

class ZeloApp extends StatelessWidget {
  const ZeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Camada de dados (Opção B): SQLite no Android/iOS. No navegador,
        // onde o sqflite não existe, usa o armazenamento local equivalente.
        Provider<RelatoRepository>(
          create: (_) => kIsWeb
              ? LocalStorageRelatoRepository()
              : SqliteRelatoRepository(),
        ),
        // Estado da aplicação: já dispara o carregamento inicial.
        ChangeNotifierProvider<RelatoProvider>(
          create: (context) =>
              RelatoProvider(context.read<RelatoRepository>())..carregar(),
        ),
      ],
      child: MaterialApp(
        title: 'Zelo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.gerar,
      ),
    );
  }
}
