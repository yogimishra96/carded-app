import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/collected_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CollectedCardDetailScreen extends StatefulWidget {
  const CollectedCardDetailScreen({super.key});
  @override
  State<CollectedCardDetailScreen> createState() => _CollectedCardDetailScreenState();
}

class _CollectedCardDetailScreenState extends State<CollectedCardDetailScreen> {
  late CollectedCard _card;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _card = ModalRoute.of(context)!.settings.arguments as CollectedCard;
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Card'),
        content: Text('Delete "${_card.name}"? Cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await CardsService.instance.deleteCollectedCard(_card.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _copy(String val) {
    Clipboard.setData(ClipboardData(text: val));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
        title: Text(_card.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Type-specific header ─────────────────────────────
          if (_card.scanType == ScanType.carded)    _CardedHeader(card: _card),
          if (_card.scanType == ScanType.photoCard) _PhotoCardHeader(card: _card),
          if (_card.scanType == ScanType.qrOther)   _QrOtherHeader(card: _card, onCopy: _copy),

          const SizedBox(height: 20),

          // ── Contact Details (show for carded & qr_other if has data) ──
          if (_card.scanType != ScanType.photoCard) ...[
            if (_card.designation.isNotEmpty || _card.company.isNotEmpty ||
                _card.email1.isNotEmpty || _card.phone1.isNotEmpty ||
                _card.website.isNotEmpty || _card.address.isNotEmpty)
              _Section(title: 'Contact Info', children: [
                if (_card.designation.isNotEmpty)
                  _InfoRow(icon: Icons.work_outline, label: _card.designation, onCopy: () => _copy(_card.designation)),
                if (_card.company.isNotEmpty)
                  _InfoRow(icon: Icons.business_outlined, label: _card.company, onCopy: () => _copy(_card.company)),
                if (_card.email1.isNotEmpty)
                  _InfoRow(icon: Icons.email_outlined, label: _card.email1, onCopy: () => _copy(_card.email1)),
                if (_card.email2.isNotEmpty)
                  _InfoRow(icon: Icons.email_outlined, label: _card.email2, onCopy: () => _copy(_card.email2)),
                if (_card.phone1.isNotEmpty)
                  _InfoRow(icon: Icons.phone_outlined, label: _card.phone1, onCopy: () => _copy(_card.phone1)),
                if (_card.phone2.isNotEmpty)
                  _InfoRow(icon: Icons.phone_outlined, label: _card.phone2, onCopy: () => _copy(_card.phone2)),
                if (_card.website.isNotEmpty)
                  _InfoRow(icon: Icons.language_outlined, label: _card.website, onCopy: () => _copy(_card.website)),
                if (_card.address.isNotEmpty)
                  _InfoRow(icon: Icons.location_on_outlined, label: _card.address, onCopy: () => _copy(_card.address)),
              ]),
          ],

          const SizedBox(height: 16),

          // ── Notes ────────────────────────────────────────────
          _NotesSection(card: _card, onSaved: (updated) => setState(() => _card = updated)),

          const SizedBox(height: 20),

          // ── Meta ─────────────────────────────────────────────
          _Section(title: 'Info', children: [
            _InfoRow(icon: Icons.calendar_today_outlined,
              label: 'Scanned ${_formatDate(_card.scannedAt)}'),
            _InfoRow(icon: Icons.label_outline,
              label: 'Type: ${_card.scanTypeLabel}'),
          ]),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ─── TYPE 1: Carded Header ────────────────────────────────────

class _CardedHeader extends StatelessWidget {
  final CollectedCard card;
  const _CardedHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B21E8), Color(0xFF9333EA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF6B21E8).withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        // Avatar
        Container(width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)),
          child: card.photoUrl.isNotEmpty
              ? ClipOval(child: Image.network(card.photoUrl, fit: BoxFit.cover))
              : Center(child: Text(
                  card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(card.name, style: const TextStyle(color: Colors.white, fontSize: 17,
              fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (card.designation.isNotEmpty)
            Text(card.designation, style: TextStyle(color: Colors.white.withOpacity(0.8),
                fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (card.company.isNotEmpty)
            Text(card.company, style: TextStyle(color: Colors.white.withOpacity(0.7),
                fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
          child: const Text('Carded', style: TextStyle(color: Colors.white,
              fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

// ─── TYPE 2: Photo Card Header ────────────────────────────────

class _PhotoCardHeader extends StatelessWidget {
  final CollectedCard card;
  const _PhotoCardHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Card image
      if (card.cardImageUrl.isNotEmpty)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(card.cardImageUrl,
            width: double.infinity, height: 200, fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null ? child
                : Container(height: 200, color: AppColors.border,
                    child: const Center(child: CircularProgressIndicator())),
            errorBuilder: (_, __, ___) => Container(height: 200,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: AppColors.textHint))),
          ),
        ),
      const SizedBox(height: 14),
      // Name + badge
      Row(children: [
        Expanded(child: Text(card.name, style: const TextStyle(fontSize: 22,
            fontWeight: FontWeight.w800, color: Color(0xFF0F172A)))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.camera_alt_outlined, size: 12, color: Color(0xFF059669)),
            SizedBox(width: 4),
            Text('Photo Card', style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w700, color: Color(0xFF059669))),
          ])),
      ]),
      if (card.company.isNotEmpty)
        Text(card.company, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    ]);
  }
}

// ─── TYPE 3: QR Other Header ──────────────────────────────────

class _QrOtherHeader extends StatelessWidget {
  final CollectedCard card;
  final void Function(String) onCopy;
  const _QrOtherHeader({required this.card, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.qr_code_rounded, color: Color(0xFFD97706), size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
            const Text('QR Code', style: TextStyle(fontSize: 11,
                color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
          ])),
        ]),
        if (card.qrRawData.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('QR Content', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => onCopy(card.qrRawData),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A))),
              child: Row(children: [
                Expanded(child: Text(card.qrRawData, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF0F172A), fontFamily: 'monospace'),
                  maxLines: 3, overflow: TextOverflow.ellipsis)),
                const Icon(Icons.copy_outlined, size: 16, color: AppColors.textHint),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─── Notes Section ────────────────────────────────────────────

class _NotesSection extends StatefulWidget {
  final CollectedCard card;
  final void Function(CollectedCard) onSaved;
  const _NotesSection({required this.card, required this.onSaved});
  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late TextEditingController _remarksCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _remarksCtrl = TextEditingController(text: widget.card.remarks);
  }

  @override
  void dispose() { _remarksCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    await CardsService.instance.updateCollectedCard(widget.card.id,
        remarks: _remarksCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return _Section(title: 'Notes', children: [
      TextField(
        controller: _remarksCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Add notes about this contact...',
          fillColor: Colors.white, filled: true,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6B21E8), width: 1.5))),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B21E8), elevation: 0,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Notes', style: TextStyle(fontSize: 13, color: Colors.white)),
        ),
      ),
    ]);
  }
}

// ─── Shared Widgets ───────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.0)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10), child: w)).toList()),
      ),
      const SizedBox(height: 4),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onCopy;
  const _InfoRow({required this.icon, required this.label, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)))),
      if (onCopy != null)
        GestureDetector(onTap: onCopy,
          child: const Icon(Icons.copy_outlined, size: 14, color: AppColors.textHint)),
    ]);
  }
}