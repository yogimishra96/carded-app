import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import '../services/cards_service.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});
  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;
  bool _success = false;
  bool _saving = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _saving) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() { _scanned = true; _saving = true; });
    _ctrl.stop();

    final card = await CardsService.instance.decodeQRAndSave(barcode!.rawValue!);

    if (!mounted) return;
    setState(() => _saving = false);

    if (card != null) {
      setState(() => _success = true);
      _animCtrl.forward();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context, card);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code. Please scan a Carded QR.'), backgroundColor: AppColors.error));
      setState(() => _scanned = false);
      _ctrl.start();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        MobileScanner(controller: _ctrl, onDetect: _onDetect),
        CustomPaint(size: MediaQuery.of(context).size, painter: _ScanOverlayPainter()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Scan Card', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => _ctrl.toggleTorch(),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.flash_on, color: Colors.white, size: 20))),
            ]),
          ),
        ),
        if (_saving)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        if (!_success && !_saving)
          Positioned(bottom: 60, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: const Text('Point camera at a Carded QR code', style: TextStyle(color: Colors.white, fontSize: 14))))),
        if (_success)
          Center(child: ScaleTransition(scale: _scaleAnim,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4), blurRadius: 30, spreadRadius: 10)]),
              child: const Icon(Icons.check, color: Colors.white, size: 56)))),
      ]),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 260.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 40;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: cutoutSize, height: cutoutSize);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
    final cp = Paint()..color = AppColors.accent..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const l2 = 24.0;
    final l = rect.left; final t = rect.top; final r = rect.right; final b = rect.bottom;
    canvas.drawLine(Offset(l, t + l2), Offset(l, t), cp); canvas.drawLine(Offset(l, t), Offset(l + l2, t), cp);
    canvas.drawLine(Offset(r - l2, t), Offset(r, t), cp); canvas.drawLine(Offset(r, t), Offset(r, t + l2), cp);
    canvas.drawLine(Offset(l, b - l2), Offset(l, b), cp); canvas.drawLine(Offset(l, b), Offset(l + l2, b), cp);
    canvas.drawLine(Offset(r - l2, b), Offset(r, b), cp); canvas.drawLine(Offset(r, b), Offset(r, b - l2), cp);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
