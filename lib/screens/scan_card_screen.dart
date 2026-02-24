import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import '../theme/app_theme.dart';
import '../services/cards_service.dart';
import '../models/collected_card.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});
  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> with SingleTickerProviderStateMixin {
  final ms.MobileScannerController _ctrl = ms.MobileScannerController();
  bool _scanned = false;
  bool _success = false;
  bool _saving = false;
  CollectedCard? _scannedCard;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));
  }

  Future<void> _onDetect(ms.BarcodeCapture capture) async {
    if (_scanned || _saving) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() { _scanned = true; _saving = true; });
    _ctrl.stop();

    final card = await CardsService.instance.decodeQRAndSave(barcode!.rawValue!);

    if (!mounted) return;
    setState(() => _saving = false);

    if (card != null) {
      setState(() { _success = true; _scannedCard = card; });
      _animCtrl.forward();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      // Collected card mila — contacts save ka option dikhao
      _showSaveContactDialog(card);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code. Please scan a Carded QR.'), backgroundColor: AppColors.error));
      setState(() => _scanned = false);
      _ctrl.start();
    }
  }

  /// Phone contacts mein save karne ka dialog
  void _showSaveContactDialog(CollectedCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _SaveContactSheet(card: card),
    ).then((_) {
      if (mounted) Navigator.pop(context, card);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        ms.MobileScanner(controller: _ctrl, onDetect: _onDetect),
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

// ─── Bottom Sheet Widget ──────────────────────────────────────────────────────

class _SaveContactSheet extends StatefulWidget {
  final CollectedCard card;
  const _SaveContactSheet({required this.card});

  @override
  State<_SaveContactSheet> createState() => _SaveContactSheetState();
}

class _SaveContactSheetState extends State<_SaveContactSheet> {
  bool _saving = false;
  bool _saved  = false;

  Future<void> _saveToContacts() async {
    setState(() => _saving = true);

    // Permission check
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission nahi mili')));
      return;
    }

    // Contact build karo
    final contact = Contact()
      ..name.first = widget.card.name.split(' ').first
      ..name.last  = widget.card.name.split(' ').skip(1).join(' ');

    // Phone numbers
    if (widget.card.phone1.isNotEmpty) {
      contact.phones.add(Phone(widget.card.phone1, label: PhoneLabel.mobile));
    }
    if (widget.card.phone2?.isNotEmpty == true) {
      contact.phones.add(Phone(widget.card.phone2!, label: PhoneLabel.work));
    }

    // Emails
    if (widget.card.email1.isNotEmpty) {
      contact.emails.add(Email(widget.card.email1, label: EmailLabel.work));
    }
    if (widget.card.email2?.isNotEmpty == true) {
      contact.emails.add(Email(widget.card.email2!, label: EmailLabel.home));
    }

    // Company & designation
    if (widget.card.company.isNotEmpty || widget.card.designation.isNotEmpty) {
      contact.organizations.add(Organization(
        company: widget.card.company,
        title: widget.card.designation,
      ));
    }

    // Website
    if (widget.card.website?.isNotEmpty == true) {
      contact.websites.add(Website(widget.card.website!, label: WebsiteLabel.work));
    }

    // Address
    if (widget.card.address?.isNotEmpty == true) {
      contact.addresses.add(Address(widget.card.address!, label: AddressLabel.work));
    }

    try {
      await contact.insert();
      if (!mounted) return;
      setState(() { _saving = false; _saved = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save nahi ho saka: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle bar
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),

        // Check icon
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 30)),
        const SizedBox(height: 12),

        Text('Card Saved!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(card.name, style: TextStyle(color: Colors.white70, fontSize: 15)),
        if (card.designation.isNotEmpty || card.company.isNotEmpty)
          Text(
            [card.designation, card.company].where((s) => s.isNotEmpty).join(' @ '),
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),

        // Save to contacts button
        if (!_saved)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveToContacts,
              icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: Text(_saving ? 'Saving...' : 'Phone Contacts mein Save karo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

        if (_saved)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('Contacts mein Save ho gaya!',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 15)),
            ]),
          ),

        const SizedBox(height: 12),

        // Skip button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ),
      ]),
    );
  }
}

// ─── Overlay Painter ─────────────────────────────────────────────────────────

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