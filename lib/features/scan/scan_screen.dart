import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


/// What a gabis QR code carries.
///
/// Three shapes are accepted, because people paste what they have: a gabis
/// link (`https://…/pay?to=…`), the short `gabis:` scheme, and a bare account
/// number, which is what most Nigerian bank apps put on a receipt.
class ScannedPayee {
  final String account;
  final String? name;
  final int? amountMinor;

  const ScannedPayee({required this.account, this.name, this.amountMinor});

  static ScannedPayee? parse(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    // A bare account number.
    if (RegExp(r'^\d{10}$').hasMatch(value)) {
      return ScannedPayee(account: value);
    }

    // gabis:0123456789?name=Ada&amount=5000
    final normalised =
        value.startsWith('gabis:') ? 'https://gabis/${value.substring(6)}' : value;

    final uri = Uri.tryParse(normalised);
    if (uri == null) return null;

    final account = uri.queryParameters['to'] ??
        uri.queryParameters['account'] ??
        (uri.pathSegments.isEmpty ? null : uri.pathSegments.last);
    if (account == null || !RegExp(r'^\d{6,}$').hasMatch(account)) return null;

    final amount = double.tryParse(uri.queryParameters['amount'] ?? '');

    return ScannedPayee(
      account: account,
      name: uri.queryParameters['name'],
      amountMinor: amount == null ? null : (amount * 100).round(),
    );
  }
}

/// The camera, a torch, and one job: read a payment code and hand it back.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  /// Set the moment a code is accepted, so a second frame of the same code
  /// cannot pop the screen twice.
  bool _handled = false;

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      final payee = ScannedPayee.parse(raw);
      if (payee == null) {
        setState(() => _error = 'That code is not a gabis payment code.');
        continue;
      }

      _handled = true;
      Navigator.pop(context, payee);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan to pay',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Torch',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_rounded),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            // A camera that cannot start is the common case on the web, where
            // the browser may refuse or the page may not be on https.
            errorBuilder: (context, error) => _CameraProblem(error: error),
          ),
          // The frame people aim with.
          IgnorePointer(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B876), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12.5)),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Point at a gabis code, or any code holding an account number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Camera refused, missing, or blocked. Says which, rather than showing a
/// black rectangle.
class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.error});

  final MobileScannerException error;

  String get _message {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'gabis needs camera permission to scan. Allow it in your browser or system settings, then try again.';
      case MobileScannerErrorCode.unsupported:
        return 'This device or browser cannot open a camera for scanning.';
      default:
        return 'The camera could not start. Check that nothing else is using it, then try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_rounded,
              color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(_message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45)),
        ],
      ),
    );
  }
}
