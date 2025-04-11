import '../models/nota_model.dart';
import '../database/database.dart';

class NotaDbController {
  final DatabaseApp databaseApp;

  NotaDbController(this.databaseApp);

  List<NotaModel> listNotas() {
    final result = databaseApp.db.select('SELECT * FROM notas_nfce');
    return result.map((row) {
      final map = <String, dynamic>{
        'id': row['id'],
        'url': row['url'],
        'codigo': row['codigo'],
        'uf': row['uf'],
        'disponivel': row['disponivel'],
        'dataLeitura': row['data_leitura_mobile'],
        'horaLeitura': row['hora_leitura_mobile'],
      };
      return NotaModel.fromMap(map);
    }).toList();
  }

  Future<void> addNota(NotaModel nota) async {
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
  }

  Future<void> deleteNota(int id) async {
    final stmt = databaseApp.db.prepare('DELETE FROM notas_nfce WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }
}
