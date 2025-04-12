// providers/home_provider.dart
import 'package:flutter/material.dart';
import '../models/nota_model.dart';
import '../repository/nota_repository.dart';
import '../database/database.dart';
import '../services/helpers/console_log.dart';
import '../services/helpers/data_time_helper.dart';
import '../wigets/scaffold_messenger.dart';

class HomeProvider with ChangeNotifier {
  final DatabaseApp databaseApp;
  final notaRepository = NotaRepository();

  List<NotaModel> _tests = [];

  List<NotaModel> get tests => _tests;

  HomeProvider(this.databaseApp);

  Future<void> loadTests() async {
    try {
      _tests = await notaRepository.getAllNotas();
      notifyListeners();
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'loadTests',
      );
    }
  }

  Future<void> addTest(String testName) async {
    try {
      final databaseApp = DatabaseApp();
      await databaseApp.init();
      final newNota = NotaModel(
        id: _tests.length + 1,
        url: '',
        codigo: '',
        uf: '',
        disponivel: '',
        dataLeitura: DateTimeHelper.getCurrentDate(),
        horaLeitura: DateTimeHelper.getCurrentTime(),
      );

      await notaRepository.addNota(newNota);
      _tests.add(newNota);
      notifyListeners();
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'addTest',
      );
    }
  }

  Future<void> removeTest({required BuildContext context, required int index}) async {
    try {
      final notaToRemove = _tests[index];
      await notaRepository.deleteNota(notaToRemove.id);
      _tests.removeAt(index);
      notifyListeners();
     ScaffoldMessengerHelper.showSuccess(
        context,
        'Deletado com sucesso.',
      );
    } catch (e, stackTrace) {
      ConsoleLog.logError(
        error: e,
        stackTrace: stackTrace,
        className: runtimeType.toString(),
        methodName: 'removeTest',
      );
    }
  }
}
