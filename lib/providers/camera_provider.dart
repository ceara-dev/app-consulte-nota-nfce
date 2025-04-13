// providers/camera_provider.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/database.dart';
import '../models/nota_model.dart';
import '../repository/nota_repository.dart';
import '../services/helpers/console_log.dart';
import '../services/helpers/data_time_helper.dart';

class CameraProvider with ChangeNotifier {
  final DatabaseApp databaseApp;
  final notaRepository = NotaRepository();

  List<NotaModel> _tests = [];

  List<NotaModel> get tests => _tests;

  CameraProvider(this.databaseApp);
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  Barcode? _result;
  bool _dialogShown = false;

  QRViewController? get controller => _controller;
  Barcode? get result => _result;
  bool get dialogShown => _dialogShown;

  Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão negada para a câmera')),
        );
        return false;
      }
    }
    return false;
  }

  void onQRViewCreated(QRViewController controller) {
    _controller = controller;
    notifyListeners();

    controller.scannedDataStream.listen((scanData) {
      if (!_dialogShown) {
        _dialogShown = true;
        _result = scanData;

        notifyListeners();
      }
    });
  }

  void resetState() {
    _dialogShown = false;
    _result = null;
    notifyListeners();
  }

  void pauseCamera() {
    _controller?.pauseCamera();
    notifyListeners();
  }

  void resumeCamera() {
    _controller?.resumeCamera();
    notifyListeners();
  }

  Future<void> toggleFlash() async {
    await _controller?.toggleFlash();
    notifyListeners();
  }

  Future<void> flipCamera() async {
    await _controller?.flipCamera();
    notifyListeners();
  }

  void disposeController() {
    _controller?.dispose();
    _controller = null;
    notifyListeners();
  }

  // Callback para permissões da câmera
  void onPermissionSet(
      BuildContext context, QRViewController ctrl, bool granted) {
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão negada para a câmera')),
      );
    }
  }

   Future<void> addQrcode({required String codigo, required  String url}) async {
    try {
      final databaseApp = DatabaseApp();
      await databaseApp.init();
      final newNota = NotaModel(
        id: _tests.length + 1,
        url: url,
        codigo: codigo,
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
}
