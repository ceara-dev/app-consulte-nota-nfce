import 'package:flutter/material.dart';
import '../models/nota_model.dart';
import '../repository/nota_repository.dart';
import '../database/database.dart';
import '../services/helps/console_log.dart';

class HomeProvider with ChangeNotifier {
  final DatabaseApp databaseApp;
  final notaRepository = NotaRepository();

  List<NotaModel> _tests = [];

  List<NotaModel> get tests => _tests;

  HomeProvider(this.databaseApp);

  Future<void> loadTests() async {
    try {
      final databaseApp = DatabaseApp();
      await databaseApp.init();
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
        dataLeitura: '',
        horaLeitura: '',
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

  Future<void> removeTest(int index) async {
    try {
      final notaToRemove = _tests[index];
      await notaRepository.deleteNota(notaToRemove.id);
      _tests.removeAt(index);
      notifyListeners();
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
