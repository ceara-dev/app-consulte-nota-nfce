// repository/nota_repository.dart
import '../models/nota_model.dart';
import '../database/nota_db_controller.dart';
import '../database/database.dart';
import '../services/helpers/console_log.dart';

class NotaRepository {
  late final NotaDbController notaDbController;

  NotaRepository() {
    final databaseApp = DatabaseApp();
    notaDbController = NotaDbController(databaseApp);
  }

  Future<List<NotaModel>> getAllNotas() async {
    try {
      return notaDbController.listNotas();
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'getAllNotas',
      );
      return [];
    }
  }

  Future<void> addNota(NotaModel nota) async {
    try {
      await notaDbController.addNota(nota);
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
      await notaDbController.deleteNota(id);
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
