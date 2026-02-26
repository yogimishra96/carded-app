import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/collected_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CollectedCardsScreen extends StatefulWidget {
  const CollectedCardsScreen({super.key});
  @override
  State<CollectedCardsScreen> createState() => _CollectedCardsScreenState();
}

class _CollectedCardsScreenState extends State<CollectedCardsScreen>
    with SingleTickerProviderStateMixin {
  List<CollectedCard> _all      = [];
  List<CollectedCard> _filtered = [];
  final _searchCtrl = TextEditingController();
  bool _isLoading   = true;
  // Filter: null = all, 'carded', 'photo_card', 'qr_other'
  ScanType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchCtrl.addListener(_search);
  }

  Future<void> _loadCards() async {
    final cards = await CardsService.instance.getCollectedCards();
    if (!mounted) return;
    setState(() { _all = cards; _isLoading = false; });
    _search();
  }

  void _search() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((c) {
        final matchType = _filterType == null || c.scanType == _filterType;
        final matchQ    = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.company.toLowerCase().contains(q) ||
          c.qrRawData.toLowerCase().contains(q);
        return matchType && matchQ;
      }).toList();
    });
  }

  void _setFilter(ScanType? type) {
    setState(() => _filterType = type);
    _search();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Collected Cards'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 8),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${_filtered.length}',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))))),
        ],
      ),
      body: Column(children: [

        // ── Search ───────────────────────────────────────────
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name, website...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
              fillColor: Colors.white, filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent))),
          )),

        // ── Filter Tabs ──────────────────────────────────────
        _FilterTabs(current: _filterType, onSelect: _setFilter, all: _all),

        // ── List ─────────────────────────────────────────────
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
                ? _EmptyState(hasFilter: _filterType != null || _searchCtrl.text.isNotEmpty,
                    onScan: () => Navigator.pushNamed(context, '/scan').then((_) => _loadCards()))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final card = _filtered[i];
                      return _CollectedTile(
                        card: card,
                        onTap: () => Navigator.pushNamed(context, '/collected-card-detail',
                            arguments: card).then((_) => _loadCards()),
                      );
                    })),
      ]),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/scan').then((_) => _loadCards()),
        backgroundColor: const Color(0xFF6B21E8),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Filter Tabs ─────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final ScanType? current;
  final void Function(ScanType?) onSelect;
  final List<CollectedCard> all;
  const _FilterTabs({required this.current, required this.onSelect, required this.all});

  int _count(ScanType? type) =>
    type == null ? all.length : all.where((c) => c.scanType == type).length;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(null, 'All', Icons.apps_rounded),
          const SizedBox(width: 8),
          _chip(ScanType.carded,    'Carded',     Icons.qr_code_rounded),
          const SizedBox(width: 8),
          _chip(ScanType.photoCard, 'Photo Cards', Icons.camera_alt_outlined),
          const SizedBox(width: 8),
          _chip(ScanType.qrOther,   'QR Codes',   Icons.qr_code_scanner_rounded),
        ],
      ),
    );
  }

  Widget _chip(ScanType? type, String label, IconData icon) {
    final active = current == type;
    final count  = _count(type);
    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6B21E8) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF6B21E8) : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
            color: active ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 5),
          Text('$label ($count)', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Collected Card Tile ──────────────────────────────────────

class _CollectedTile extends StatelessWidget {
  final CollectedCard card;
  final VoidCallback onTap;
  const _CollectedTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [

          // Avatar / thumbnail
          _TileAvatar(card: card),
          const SizedBox(width: 12),

          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(card.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              _ScanTypeBadge(type: card.scanType),
            ]),
            if (card.company.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(card.company, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            if (card.scanType == ScanType.qrOther && card.isUrl) ...[
              const SizedBox(height: 2),
              Text(card.qrRawData, style: const TextStyle(fontSize: 11, color: AppColors.accent),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Text(_formatDate(card.scannedAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ])),

          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _TileAvatar extends StatelessWidget {
  final CollectedCard card;
  const _TileAvatar({required this.card});

  @override
  Widget build(BuildContext context) {
    // Photo card — show thumbnail
    if (card.scanType == ScanType.photoCard && card.cardImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(card.cardImageUrl, width: 48, height: 48, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials()),
      );
    }
    // Carded with photo
    if (card.scanType == ScanType.carded && card.photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(card.photoUrl, width: 48, height: 48, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials()),
      );
    }
    return _initials();
  }

  Widget _initials() {
    Color bg;
    IconData icon = Icons.person_outline;
    switch (card.scanType) {
      case ScanType.photoCard:
        bg = const Color(0xFFECFDF5); icon = Icons.camera_alt_outlined; break;
      case ScanType.qrOther:
        bg = const Color(0xFFFFFBEB); icon = Icons.qr_code_rounded; break;
      default:
        bg = const Color(0xFFF3E8FF);
    }
    if (card.scanType == ScanType.carded) {
      return Container(width: 48, height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Center(child: Text(
          card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: Color(0xFF6B21E8)))));
    }
    return Container(width: 48, height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 22, color: const Color(0xFF6B21E8)));
  }
}

class _ScanTypeBadge extends StatelessWidget {
  final ScanType type;
  const _ScanTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label;
    switch (type) {
      case ScanType.carded:
        bg = const Color(0xFFF3E8FF); fg = const Color(0xFF6B21E8); label = 'Carded'; break;
      case ScanType.photoCard:
        bg = const Color(0xFFECFDF5); fg = const Color(0xFF059669); label = 'Photo'; break;
      case ScanType.qrOther:
        bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); label = 'QR'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onScan;
  const _EmptyState({required this.hasFilter, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inbox_outlined, size: 60, color: AppColors.textHint),
      const SizedBox(height: 16),
      Text(hasFilter ? 'No results' : 'No collected cards yet',
        style: AppTextStyles.heading3),
      const SizedBox(height: 6),
      Text(hasFilter ? 'Try a different filter or search' : 'Scan a card to get started',
        style: AppTextStyles.bodySecondary),
      if (!hasFilter) ...[
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B21E8),
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: const Text('Scan a Card', style: TextStyle(color: Colors.white))),
      ],
    ]));
  }
}