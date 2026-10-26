// pages/camera/camera_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../providers/camera_provider.dart';
import '../../services/helpers/nfce_qr_parser.dart';
import '../../theme/app_colors.dart';
import '../../wigets/brand_logo.dart';
import '../../wigets/nota_qr_sheet.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: const _CameraPageContent(),
    );
  }
}

class _CameraPageContent extends StatefulWidget {
  const _CameraPageContent();

  @override
  State<_CameraPageContent> createState() => _CameraPageContentState();
}

class _CameraPageContentState extends State<_CameraPageContent> {
  bool _hasPermission = false;
  bool _verificando = true;
  bool _sheetAberta = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final hasPermission = await cameraProvider.requestCameraPermission(context);
    if (!mounted) return;
    setState(() {
      _hasPermission = hasPermission;
      _verificando = false;
    });
  }

  Future<void> _abrirNota(
    BuildContext context,
    CameraProvider cameraProvider,
    NfceQrInfo info,
  ) async {
    if (_sheetAberta || !mounted) return;

    setState(() => _sheetAberta = true);

    final resultado = await showNotaQrSheet(context: context, info: info);

    if (!mounted) return;

    if (resultado?.salvar == true) {
      await cameraProvider.addQrcode(info, detalhes: resultado?.detalhes);
      await cameraProvider.resetState();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      await cameraProvider.resetState();
      if (mounted) setState(() => _sheetAberta = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        final codigo = cameraProvider.result?.code;
        if (codigo != null && !_sheetAberta) {
          final info = NfceQrInfo.parse(codigo);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _abrirNota(context, cameraProvider, info);
          });
        }

        if (_verificando) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (!_hasPermission) {
          return _PermissaoCamera(onSolicitar: _checkCameraPermission);
        }

        return _CameraScanner(
          onQrViewCreated: cameraProvider.onQRViewCreated,
          onPermissionSet: (ctrl, granted) => cameraProvider.onPermissionSet(
            context,
            ctrl,
            granted,
          ),
          qrKey: cameraProvider.qrKey,
          onFlash: cameraProvider.toggleFlash,
          onFlip: cameraProvider.flipCamera,
        );
      },
    );
  }
}

class _CameraScanner extends StatelessWidget {
  final GlobalKey qrKey;
  final void Function(QRViewController) onQrViewCreated;
  final void Function(QRViewController, bool) onPermissionSet;
  final Future<void> Function() onFlash;
  final Future<void> Function() onFlip;

  const _CameraScanner({
    required this.qrKey,
    required this.onQrViewCreated,
    required this.onPermissionSet,
    required this.onFlash,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final double scanArea =
        MediaQuery.of(context).size.shortestSide < 400 ? 210.0 : 290.0;
    final double topo = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: onQrViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.white,
            borderRadius: 22,
            borderLength: 28,
            borderWidth: 4,
            cutOutSize: scanArea,
            overlayColor: Colors.black.withValues(alpha: 0.52),
          ),
          onPermissionSet: onPermissionSet,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topo + 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topo + 6,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 19,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Aponte para o QR Code impresso no cupom fiscal.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      height: 1.3,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 72, bottom: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CameraAction(
                    icon: Icons.flash_on_rounded,
                    label: 'Flash',
                    onPressed: onFlash,
                  ),
                  const SizedBox(width: 32),
                  _CameraAction(
                    icon: Icons.cameraswitch_rounded,
                    label: 'Virar',
                    onPressed: onFlip,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  const _CameraAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.14),
          shape: const CircleBorder(
            side: BorderSide(color: Color(0x33FFFFFF)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PermissaoCamera extends StatelessWidget {
  final Future<void> Function() onSolicitar;

  const _PermissaoCamera({required this.onSolicitar});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandMark(size: 78, elevated: true),
                const SizedBox(height: 24),
                Text(
                  'Precisamos da câmera',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'A câmera é usada apenas para ler o QR Code do cupom fiscal. '
                  'Nenhuma imagem é armazenada.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onSolicitar,
                  icon: const Icon(Icons.photo_camera_outlined, size: 20),
                  label: const Text('Permitir acesso'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
