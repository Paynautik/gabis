import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'business_store.dart';

/// A branded, printable-looking receipt: gabis wordmark, invoice details,
/// nothing that only renders correctly inside WhatsApp's own markdown.
class ReceiptCard extends StatelessWidget {
  final Invoice invoice;
  final String company;
  final DateTime paidAt;

  const ReceiptCard({super.key, required this.invoice, required this.company, required this.paidAt});

  static const _ink = Color(0xFF16123A);
  static const _inkSoft = Color(0xFF5F5B73);
  static const _line = Color(0xFFE5DFD5);
  static const _mint = Color(0xFF0F9D6B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 28),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/gabis_logo.png', height: 30),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAYMENT RECEIVED',
                      style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.3)),
                  SizedBox(height: 4),
                  Text('Paid in full — nothing further is owed on this invoice.',
                      style: TextStyle(color: _inkSoft, fontSize: 12.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _mint.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
                child: const Text('PAID', style: TextStyle(color: _mint, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 20),
          _row('From', company),
          _row('Invoice', invoice.id),
          _row('For', invoice.description),
          _row('Date', _date(paidAt)),
          const SizedBox(height: 16),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount', style: TextStyle(color: _inkSoft, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(formatFull(invoice.amount),
                  style: const TextStyle(color: _ink, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.4)),
            ],
          ),
          const SizedBox(height: 28),
          Text('Thank you — $company.',
              style: const TextStyle(color: _inkSoft, fontSize: 12.5, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          const Text('Sent with gabis', style: TextStyle(color: Color(0xFFB8B4C8), fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: _inkSoft, fontSize: 13)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Renders [child] off-screen and rasterises it to PNG bytes, without
/// needing it mounted anywhere in the visible widget tree.
Future<Uint8List> captureWidgetAsPng(BuildContext context, Widget child, {double pixelRatio = 2.5}) async {
  final repaintKey = GlobalKey();
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: -10000,
      child: Material(
        color: Colors.transparent,
        child: RepaintBoundary(key: repaintKey, child: child),
      ),
    ),
  );
  overlay.insert(entry);
  try {
    // Two frames: one to build, one to guarantee layout/paint settled.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
