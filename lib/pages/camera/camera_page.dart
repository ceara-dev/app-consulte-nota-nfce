// pages/camera/camera_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:teste/providers/camera_provider.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAMERA - QRCODE'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: _CameraPageContent(),
    );
  }
}

class _CameraPageContent extends StatefulWidget {
  @override
  State<_CameraPageContent> createState() => _CameraPageContentState();
}

class _CameraPageContentState extends State<_CameraPageContent> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final hasPermission = await cameraProvider.requestCameraPermission(context);
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        if (cameraProvider.result != null && cameraProvider.dialogShown) {
          Future.microtask(() {
            _showDialog(context, cameraProvider);
          });
        }

        if (!_hasPermission) {
          return Scaffold(
            appBar: AppBar(title: const Text('Permissão Necessária')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'A câmera é necessária para escanear QR Codes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkCameraPermission,
                    child: const Text('Solicitar Permissão'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              _buildQrView(context),
              Positioned(
                top: 48,
                left: 16,
                right: 16,
                child: Center(
                  child: Text(
                    cameraProvider.result != null
                        ? 'Código: ${cameraProvider.result!.code}'
                        : 'Aponte a câmera para um QR Code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'flash',
                onPressed: () async {
                  await cameraProvider.toggleFlash();
                },
                child: const Icon(Icons.flash_on),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'flip',
                onPressed: () async {
                  await cameraProvider.flipCamera();
                },
                child: const Icon(Icons.switch_camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final double scanArea =
        MediaQuery.of(context).size.shortestSide < 400 ? 200.0 : 300.0;

    if (cameraProvider.qrKey == null) {
      return const Center(child: Text('Erro ao inicializar a câmera.'));
    }

    return QRView(
      key: cameraProvider.qrKey,
      onQRViewCreated: cameraProvider.onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.greenAccent,
        borderRadius: 12,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) =>
          cameraProvider.onPermissionSet(context, ctrl, p),
    );
  }

  void _showDialog(BuildContext context, CameraProvider cameraProvider) {
    String? fullQrCode = cameraProvider.result!.code;

    String extractedCode = _extractQrCodeContent(fullQrCode!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        debugPrint("QRCODE: $extractedCode");
        return AlertDialog(
          title: const Text('QR Code Detectado'),
          content: Text('Conteúdo: $extractedCode'),
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.pushReplacementNamed(context, '/camera');
                cameraProvider.resetState();
              },
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () async {
                await cameraProvider.addQrcode(
                  codigo: extractedCode,
                  url: fullQrCode,
                );
                Navigator.of(context).pop();
                cameraProvider.resetState();
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  String _extractQrCodeContent(String qrCode) {
    if (qrCode.contains("qrcode?p=")) {
      int startIndex = qrCode.indexOf("qrcode?p=") + "qrcode?p=".length;
      return qrCode.substring(startIndex);
    }
    return qrCode;
  }
}
