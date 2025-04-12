// database/nota_db_controller.dart
import 'package:flutter/material.dart';
import '../models/nota_model.dart';
import '../database/database.dart';
import '../services/helpers/console_log.dart';

class NotaDbController {
  final DatabaseApp databaseApp;

  NotaDbController(this.databaseApp);

  Future<List<NotaModel>> listNotas() async {
    try {
      await databaseApp.init();
      final result = databaseApp.db.select('SELECT * FROM notas_nfce');
      return result.map((row) {
        return NotaModel.fromMap({
          'id': row['id'],
          'url': row['url'],
          'codigo': row['codigo'],
          'uf': row['uf'],
          'disponivel': row['disponivel'],
          'dataLeitura': row['data_leitura_mobile'],
          'horaLeitura': row['hora_leitura_mobile'],
        });
      }).toList();
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'listNotas',
      );
      return [];
    }
  }

  /// Adiciona uma nova nota ao banco de dados.
  Future<void> addNota(NotaModel nota) async {
    try {
      await databaseApp.init();
      final stmt = databaseApp.db.prepare('''
      INSERT INTO notas_nfce (url, codigo, uf, disponivel, data_leitura_mobile, hora_leitura_mobile)
      VALUES (?, ?, ?, ?, ?, ?)
    ''');
      stmt.execute([
        nota.url,
        nota.codigo,
        nota.uf,
        nota.disponivel,
        nota.dataLeitura,
        nota.horaLeitura,
      ]);
      stmt.dispose();
      debugPrint("Nota adicionada com sucesso.");
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'addNota',
      );
    }
  }

  Future<void> deleteNota(int id) async {
    try {
      await databaseApp.init();
      final stmt =
          databaseApp.db.prepare('DELETE FROM notas_nfce WHERE id = ?');
      stmt.execute([id]);
      stmt.dispose();
      debugPrint("Nota com ID $id removida com sucesso.");
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'deleteNota',
      );
    }
  }
}
