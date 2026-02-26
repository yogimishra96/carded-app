import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/collected_card.dart';
import '../services/cards_service.dart';
import '../services/api_client.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});
  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen>
    with SingleTickerProviderStateMixin {
  final ms.MobileScannerController _ctrl = ms.MobileScannerController();
  bool _scanned = false;
  bool _success = false;
  bool _saving  = false;
  String _mode  = 'carded'; // 'carded' | 'photo' | 'qr_other'

  late AnimationController _animCtrl;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() { _ctrl.dispose(); _animCtrl.dispose(); super.dispose(); }

  // ── Mode switch ──────────────────────────────────────────────
  void _setMode(String mode) {
    setState(() { _mode = mode; _scanned = false; });
    if (mode == 'photo') {
      _ctrl.stop();
      _pickPhysicalCard();
    } else {
      _ctrl.start();
    }
  }

  // ════════════════════════════════════════════════════════════
  // TYPE 1 — Carded QR
  // ════════════════════════════════════════════════════════════
  Future<void> _onDetect(ms.BarcodeCapture capture) async {
    if (_scanned || _saving || _mode == 'photo') return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() { _scanned = true; _saving = true; });
    _ctrl.stop();

    if (_mode == 'carded') {
      final card = await CardsService.instance.decodeQRAndSave(raw);
      if (!mounted) return;
      setState(() => _saving = false);

      if (card != null) {
        setState(() { _success = true; });
        _animCtrl.forward();
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        // ← original feature: show save-to-contacts dialog
        _showSaveContactDialog(card);
      } else {
        // Not a Carded QR — offer to save as generic QR
        _showNotCardedDialog(raw);
      }
    } else {
      // qr_other mode
      await _handleOtherQR(raw);
    }
  }

  void _showNotCardedDialog(String raw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Not a Carded QR'),
        content: const Text('This doesn\'t look like a Carded QR. Save it as a generic QR code instead?'),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); setState(() { _scanned = false; }); _ctrl.start(); },
            child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _handleOtherQR(raw); },
            child: const Text('Save as QR', style: TextStyle(color: Color(0xFF6B21E8)))),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // TYPE 2 — Physical card photo
  // ════════════════════════════════════════════════════════════
  Future<void> _pickPhysicalCard() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        const Padding(padding: EdgeInsets.all(16),
          child: Text('Capture Physical Card',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B21E8)),
          title: const Text('Take Photo'),
          onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF6B21E8)),
          title: const Text('Choose from Gallery'),
          onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        const SizedBox(height: 8),
      ])),
    );

    if (!mounted) return;
    if (source == null) {
      setState(() { _mode = 'carded'; }); _ctrl.start(); return;
    }

    final xFile = await ImagePicker().pickImage(
        source: source, maxWidth: 1200, maxHeight: 1600, imageQuality: 85);
    if (!mounted) return;
    if (xFile == null) {
      setState(() { _mode = 'carded'; }); _ctrl.start(); return;
    }

    // Ask name BEFORE showing saving state
    final name = await _askName('Name this card', hint: 'e.g. John Smith — Business Card');
    if (!mounted) return;
    if (name == null || name.isEmpty) {
      setState(() { _mode = 'carded'; }); _ctrl.start(); return;
    }

    // Now show saving state — AFTER all dialogs closed
    if (!mounted) return;
    setState(() => _saving = true);

    // ── Upload image bytes ───────────────────────────────────
    CollectedCard? card;
    String? errorMsg;
    try {
      final token = await ApiClient.instance.getToken();
      debugPrint('[PhotoCard] token: ${token != null ? "present" : "NULL"}');
      if (token == null) throw Exception('Not authenticated — please log in again');

      // readAsBytes — safe on both iOS and Android (no file path needed)
      final bytes = await xFile.readAsBytes();
      debugPrint('[PhotoCard] bytes read: ${bytes.length}');
      if (bytes.isEmpty) throw Exception('Image is empty');

      final uri = Uri.parse('${ApiClient.baseUrl}/collected/photo-card');
      debugPrint('[PhotoCard] POST $uri  name="$name"');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..files.add(http.MultipartFile.fromBytes(
          'cardImage',
          bytes,
          filename: 'card_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),   // ← CRITICAL: prevents NullPointerException
        ));

      debugPrint('[PhotoCard] sending request...');
      final streamed = await request.send().timeout(const Duration(seconds: 45));
      final res      = await http.Response.fromStream(streamed);

      debugPrint('[PhotoCard] status: ${res.statusCode}');
      debugPrint('[PhotoCard] body:   ${res.body}');

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 && body['success'] == true) {
        card = CollectedCard.fromJson(body['card'] as Map<String, dynamic>);
        debugPrint('[PhotoCard] saved id: ${card.id}');
      } else {
        errorMsg = body['message'] as String? ?? 'Server error ${res.statusCode}';
        debugPrint('[PhotoCard] FAILED: $errorMsg');
      }
    } catch (e, stack) {
      errorMsg = e.toString();
      debugPrint('[PhotoCard] EXCEPTION: $e');
      debugPrint('[PhotoCard] STACK: $stack');
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $errorMsg'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4)));
    }

    if (card != null) {
      setState(() => _success = true);
      _animCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Navigator.pop(context, card);
    } else {
      setState(() { _mode = 'carded'; _scanned = false; });
      _ctrl.start();
    }
  }

  // ════════════════════════════════════════════════════════════
  // TYPE 3 — Any QR code
  // ════════════════════════════════════════════════════════════
  Future<void> _handleOtherQR(String raw) async {
    setState(() => _saving = true);
    final parsed  = _parseQrContent(raw);
    final hasName = (parsed['name'] as String? ?? '').isNotEmpty;

    String? name;
    if (hasName) {
      name = parsed['name'] as String;
    } else {
      if (!mounted) return;
      final hint = raw.startsWith('http') ? 'e.g. Company Website' : 'e.g. WiFi QR — Office';
      name = await _askName('Label this QR Code', hint: hint);
    }

    if (name == null || name.isEmpty) {
      setState(() { _saving = false; _scanned = false; }); _ctrl.start(); return;
    }

    final card = await CardsService.instance.saveQrOther(
        name: name, qrRawData: raw, parsedData: parsed);
    if (!mounted) return;
    setState(() => _saving = false);

    if (card != null) {
      setState(() => _success = true);
      _animCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Navigator.pop(context, card);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save QR. Please try again.'),
              backgroundColor: AppColors.error));
      setState(() => _scanned = false); _ctrl.start();
    }
  }

  // ── QR parser ────────────────────────────────────────────────
  Map<String, dynamic> _parseQrContent(String raw) {
    final r = <String, dynamic>{};
    if (raw.toUpperCase().startsWith('BEGIN:VCARD')) {
      for (final line in raw.split('\n')) {
        final l = line.trim();
        if (l.startsWith('FN:'))     r['name']        = l.substring(3);
        if (l.startsWith('ORG:'))    r['company']     = l.substring(4);
        if (l.startsWith('TEL'))     r['phone']       = l.replaceAll(RegExp(r'TEL[^:]*:'), '');
        if (l.startsWith('EMAIL'))   r['email']       = l.replaceAll(RegExp(r'EMAIL[^:]*:'), '');
        if (l.startsWith('URL:'))    r['website']     = l.substring(4);
        if (l.startsWith('TITLE:'))  r['designation'] = l.substring(6);
      }
      return r;
    }
    if (raw.toUpperCase().startsWith('MECARD:')) {
      for (final p in raw.substring(7).split(';')) {
        if (p.startsWith('N:'))    r['name']  = p.substring(2).replaceAll(',', ' ');
        if (p.startsWith('TEL:')) r['phone'] = p.substring(4);
        if (p.startsWith('EMAIL:')) r['email'] = p.substring(6);
        if (p.startsWith('URL:')) r['website'] = p.substring(4);
      }
      return r;
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      try {
        r['website'] = raw;
        r['name']    = Uri.parse(raw).host.replaceAll('www.', '');
      } catch (_) {}
      return r;
    }
    if (raw.startsWith('WIFI:')) {
      final m = RegExp(r'S:([^;]+)').firstMatch(raw);
      if (m != null) r['name'] = 'WiFi: ${m.group(1)}';
      return r;
    }
    if (raw.length < 60) r['name'] = raw;
    return r;
  }

  // ── Helpers ──────────────────────────────────────────────────
  Future<String?> _askName(String title, {String hint = '', String? prefill}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NameDialog(title: title, hint: hint, prefill: prefill ?? ''),
    );
  }

  void _showSaveContactDialog(CollectedCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => _SaveContactSheet(card: card),
    ).then((_) {
      if (mounted) Navigator.pop(context, card);
    });
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        if (_mode != 'photo')
          ms.MobileScanner(controller: _ctrl, onDetect: _onDetect),

        if (_mode != 'photo' && !_success)
          CustomPaint(size: MediaQuery.of(context).size,
              painter: _ScanOverlayPainter(color: _modeColor)),

        // AppBar
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _iconBtn(Icons.arrow_back_ios, () => Navigator.pop(context)),
            const SizedBox(width: 12),
            Text(_modeLabel,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (_mode != 'photo')
              _iconBtn(Icons.flash_on, () => _ctrl.toggleTorch()),
          ]),
        )),

        // Mode tabs
        if (!_success && !_saving)
          Positioned(bottom: 110, left: 0, right: 0,
            child: Center(child: _ModeTabs(current: _mode, onSelect: _setMode))),

        // Hint
        if (!_success && !_saving && _mode != 'photo')
          Positioned(bottom: 56, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: Text(_hintText,
                  style: const TextStyle(color: Colors.white, fontSize: 14))))),

        // Saving
        if (_saving && !_success)
          Container(color: Colors.black54,
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Saving...', style: TextStyle(color: Colors.white, fontSize: 14)),
            ]))),

        // Success tick
        if (_success)
          Center(child: ScaleTransition(scale: _scaleAnim,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4),
                    blurRadius: 30, spreadRadius: 10)]),
              child: const Icon(Icons.check, color: Colors.white, size: 56)))),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback cb) => GestureDetector(
    onTap: cb,
    child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white, size: 20)));

  String get _modeLabel {
    switch (_mode) {
      case 'photo':    return 'Photo Card';
      case 'qr_other': return 'Any QR Code';
      default:         return 'Scan Carded QR';
    }
  }

  String get _hintText {
    switch (_mode) {
      case 'qr_other': return 'Scan any QR code to save it';
      default:         return 'Point camera at a Carded QR code';
    }
  }

  Color get _modeColor {
    switch (_mode) {
      case 'photo':    return const Color(0xFF10B981);
      case 'qr_other': return const Color(0xFFF59E0B);
      default:         return const Color(0xFF6B21E8);
    }
  }
}

// ─── Mode Tabs ────────────────────────────────────────────────
class _ModeTabs extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;
  const _ModeTabs({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _tab('carded',   Icons.qr_code_rounded,         'Carded QR'),
        const SizedBox(width: 4),
        _tab('photo',    Icons.camera_alt_outlined,     'Photo Card'),
        const SizedBox(width: 4),
        _tab('qr_other', Icons.qr_code_scanner_rounded, 'Any QR'),
      ]),
    );
  }

  Widget _tab(String mode, IconData icon, String label) {
    final active = current == mode;
    return GestureDetector(
      onTap: () => onSelect(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15,
            color: active ? const Color(0xFF6B21E8) : Colors.white70),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF6B21E8) : Colors.white70)),
        ]),
      ),
    );
  }
}

// ─── Save Contact Bottom Sheet ────────────────────────────────
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

    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied.')));
      return;
    }

    final nameParts = widget.card.name.split(' ');
    final contact = Contact()
      ..name.first = nameParts.first
      ..name.last  = nameParts.skip(1).join(' ');

    if (widget.card.phone1.isNotEmpty)
      contact.phones.add(Phone(widget.card.phone1, label: PhoneLabel.mobile));
    if (widget.card.phone2.isNotEmpty)
      contact.phones.add(Phone(widget.card.phone2, label: PhoneLabel.work));
    if (widget.card.email1.isNotEmpty)
      contact.emails.add(Email(widget.card.email1, label: EmailLabel.work));
    if (widget.card.email2.isNotEmpty)
      contact.emails.add(Email(widget.card.email2, label: EmailLabel.home));
    if (widget.card.company.isNotEmpty || widget.card.designation.isNotEmpty)
      contact.organizations.add(Organization(
          company: widget.card.company, title: widget.card.designation));
    if (widget.card.website.isNotEmpty)
      contact.websites.add(Website(widget.card.website, label: WebsiteLabel.work));
    if (widget.card.address.isNotEmpty)
      contact.addresses.add(Address(widget.card.address, label: AddressLabel.work));

    try {
      await contact.insert();
      if (!mounted) return;
      setState(() { _saving = false; _saved = true; });
    } catch (e) {
      debugPrint('[SaveContact] ERROR: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save contact: $e'),
              backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(width: 56, height: 56,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 30)),
        const SizedBox(height: 12),
        const Text('Card Saved!',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(card.name, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        if (card.designation.isNotEmpty || card.company.isNotEmpty)
          Text(
            [card.designation, card.company].where((s) => s.isNotEmpty).join(' @ '),
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),

        if (!_saved)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveToContacts,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: Text(_saving ? 'Saving...' : 'Save to Phone Contacts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),

        if (_saved)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('Saved to Contacts!',
                  style: TextStyle(color: AppColors.success,
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ]),
          ),

        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip', style: TextStyle(color: Colors.white38, fontSize: 14))),
      ]),
    );
  }
}

// ─── Name Dialog — proper StatefulWidget so controller lifecycle is managed ──
class _NameDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String prefill;
  const _NameDialog({required this.title, required this.hint, required this.prefill});
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.prefill);
  }

  @override
  void dispose() {
    _ctrl.dispose(); // Flutter manages this — no use-after-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6B21E8), width: 1.5)),
        ),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B21E8), elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Save', style: TextStyle(color: Colors.white))),
      ],
    );
  }
}

// ─── Scan Overlay Painter ─────────────────────────────────────
class _ScanOverlayPainter extends CustomPainter {
  final Color color;
  const _ScanOverlayPainter({this.color = const Color(0xFF6B21E8)});

  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 260.0;
    final cx   = size.width / 2;
    final cy   = size.height / 2 - 60;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: cutoutSize, height: cutoutSize);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));

    final cp = Paint()..color = color..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const l2 = 24.0;
    final l = rect.left; final t = rect.top; final r = rect.right; final b = rect.bottom;
    canvas.drawLine(Offset(l, t + l2), Offset(l, t), cp);
    canvas.drawLine(Offset(l, t), Offset(l + l2, t), cp);
    canvas.drawLine(Offset(r - l2, t), Offset(r, t), cp);
    canvas.drawLine(Offset(r, t), Offset(r, t + l2), cp);
    canvas.drawLine(Offset(l, b - l2), Offset(l, b), cp);
    canvas.drawLine(Offset(l, b), Offset(l + l2, b), cp);
    canvas.drawLine(Offset(r - l2, b), Offset(r, b), cp);
    canvas.drawLine(Offset(r, b), Offset(r, b - l2), cp);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter old) => old.color != color;
}