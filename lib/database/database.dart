import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseApp {
  late final Database _db;

  /// Inicializa o banco de dados e cria as tabelas necessárias.
  Future<void> init() async {
    try {
      _db = sqlite3.open('app_database.db');

      // Cria as tabelas no banco de dados
      await tables();
    } catch (e) {
      debugPrint("database-app-init: $e");
      rethrow; // Relança o erro para ser tratado em outro lugar, se necessário
    }
  }

  /// Cria a tabela `notas_nfce` se ela ainda não existir.
  Future<void> tables() async {
    try {
      _db.execute('''
        CREATE TABLE IF NOT EXISTS notas_nfce (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL,
          codigo TEXT NOT NULL,
          uf TEXT NOT NULL,
          disponivel TEXT NOT NULL,
          data_leitura_mobile TEXT NOT NULL,
          hora_leitura_mobile TEXT NOT NULL
        );
      ''');
      debugPrint(
          '[x] - Tabela "notas_nfce" criada ou já existe.'.toUpperCase());
    } catch (e) {
      debugPrint("Erro ao criar tabela: $e");
      rethrow; // Relança o erro para ser tratado em outro lugar, se necessário
    }
  }

  /// Fecha a conexão com o banco de dados.
  void close() {
    _db.dispose();
    debugPrint('Banco de dados fechado.');
  }

  /// Obtém a instância do banco de dados.
  Database get db => _db;
}
