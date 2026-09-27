import 'package:flutter/foundation.dart';
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

  /// Laptops and desktops point the webcam at the user, which cannot scan a
  /// code on a phone screen. They start with typing or pasting instead.
  late bool _manual = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);
  final _entry = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _entry.dispose();
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
        // Explicit colour: the app theme's title style would otherwise paint
        // dark text on this black bar.
        title: const Text('Scan to pay',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
        actions: _manual
            ? null
            : [
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
      body: _manual ? _manualEntry(context) : _camera(context),
    );
  }

  void _submitEntry() {
    final payee = ScannedPayee.parse(_entry.text);
    if (payee == null) {
      setState(() => _error = 'Enter a 10-digit account number or paste a gabis payment link.');
      return;
    }
    Navigator.pop(context, payee);
  }

  Widget _manualEntry(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(28),
          children: [
            const Icon(Icons.smartphone_rounded, color: Colors.white54, size: 44),
            const SizedBox(height: 14),
            const Text('Scanning works best on your phone',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Open gabis on your phone to scan a code, or enter the account number or payment link here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _entry,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onSubmitted: (_) => _submitEntry(),
              decoration: InputDecoration(
                hintText: '0123456789 or https://…/pay?to=…',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submitEntry,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _manual = false;
                _error = null;
              }),
              child: const Text('Use this computer\'s camera instead', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _camera(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          // A camera that cannot start is the common case on the web, where
          // the browser may refuse or the page may not be on https.
          errorBuilder: (context, error) => _CameraProblem(error: error),
        ),
        // The frame, with the instruction right under it where the eye
        // already is, and clear of messages that pop up at the bottom.
        IgnorePointer(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B876), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error ?? 'Point at a gabis code, or any code holding an account number.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _error != null ? const Color(0xFFFFB4A6) : Colors.white, fontSize: 13, height: 1.4),
              ),
            ),
          ]),
        ),
      ],
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
