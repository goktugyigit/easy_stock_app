// lib/widgets/barcode_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kodu Okutun')), // 'Barkodu Okutun' idi, genel yaptım
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              _isProcessing = true;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? barcodeValue = barcodes.first.rawValue;
                if (barcodeValue != null && barcodeValue.isNotEmpty) {
                  if (kDebugMode) {
                    print('Okunan Kod (mobile_scanner): $barcodeValue');
                  }
                  Navigator.pop(context, barcodeValue);
                } else {
                  _isProcessing = false;
                }
              } else {
                _isProcessing = false;
              }
            },
            errorBuilder: (context, error) {
              String errorMessage = "Kamera hatası oluştu.";
              // ignore: unnecessary_type_check
              if (error is MobileScannerException) {
                errorMessage = error.errorDetails?.message ?? error.toString();
                if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                  errorMessage = "Kamera izni verilmedi. Lütfen ayarlardan izin verin.";
                }
              } else {
                errorMessage = error.toString();
              }
              if (kDebugMode) {
                print("MobileScanner errorBuilder: $errorMessage");
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final TorchState currentTorchState = controller.value.torchState;
                    IconData iconData; String tooltip; Color iconColor = Colors.white;
                    switch (currentTorchState) {
                      case TorchState.off: iconData = Icons.flash_off; iconColor = Colors.grey; tooltip = 'Flaş Aç'; break;
                      case TorchState.on: iconData = Icons.flash_on; iconColor = Colors.yellow; tooltip = 'Flaş Kapat'; break;
                      case TorchState.auto: iconData = Icons.flash_auto; iconColor = Colors.blue; tooltip = 'Flaş Otomatik'; break;
                      case TorchState.unavailable: iconData = Icons.no_flash; iconColor = Colors.red.shade300; tooltip = 'Flaş Kullanılamıyor'; break;
                    }
                    return IconButton(icon: Icon(iconData, color: iconColor, size: 32), onPressed: currentTorchState == TorchState.unavailable ? null : () => controller.toggleTorch(), tooltip: tooltip);
                  },
                ),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final CameraFacing currentCameraFacing = controller.value.cameraDirection;
                    IconData iconData; String tooltip;
                    switch (currentCameraFacing) {
                      case CameraFacing.front: iconData = Icons.camera_front_outlined; tooltip = 'Arka Kamera'; break;
                      case CameraFacing.back: iconData = Icons.camera_rear_outlined; tooltip = 'Ön Kamera'; break;
                      case CameraFacing.external: iconData = Icons.photo_camera_back_outlined; tooltip = 'Harici Kamera'; break;
                      case CameraFacing.unknown: iconData = Icons.camera_alt_outlined; tooltip = 'Kamera Durumu Bilinmiyor'; break;
                    }
                    return IconButton(icon: Icon(iconData, color: Colors.white, size: 32), onPressed: (currentCameraFacing == CameraFacing.unknown || currentCameraFacing == CameraFacing.external) ? null : () => controller.switchCamera(), tooltip: tooltip);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}