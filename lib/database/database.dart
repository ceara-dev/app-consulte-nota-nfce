// database/database.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseApp {
  static final DatabaseApp _instance = DatabaseApp._internal();
  late final Database _db;
  bool _isInitialized = false;

  DatabaseApp._internal();

  factory DatabaseApp() {
    return _instance;
  }

  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('[✓] Banco de dados já foi inicializado.');
      return;
    }

    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDocumentsDir.path}/app.db';
      debugPrint('dbPath: $dbPath');

      _db = sqlite3.open(dbPath);
      _isInitialized = true;
      debugPrint('[✓] Banco de dados aberto com sucesso em: $dbPath');

      await _createTables();
    } catch (e) {
      _handleError("[Erro] Falha ao inicializar o banco de dados", e);
    }
  }

  Future<void> _createTables() async {
    try {
      final String createTableCommand = '''
        CREATE TABLE IF NOT EXISTS notas_nfce (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL,
          codigo TEXT NOT NULL,
          uf TEXT NOT NULL,
          disponivel TEXT NOT NULL,
          data_leitura_mobile TEXT NOT NULL,
          hora_leitura_mobile TEXT NOT NULL
        );
      ''';

      _db.execute(createTableCommand);
      debugPrint('[✓] Tabelas criadas (ou já existentes).');
    } catch (e) {
      _handleError("[Erro] Falha ao criar tabelas", e);
    }
  }

  void close() {
    try {
      _db.dispose();
      debugPrint('[✓] Banco de dados fechado.');
    } catch (e) {
      _handleError("[Erro] Falha ao fechar o banco de dados", e);
    }
  }

  Database get db => _db;

  void _handleError(String message, Object error) {
    debugPrint('$message: $error');
  }
}
