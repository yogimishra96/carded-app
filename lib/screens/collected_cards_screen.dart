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

class _CollectedCardsScreenState extends State<CollectedCardsScreen> {
  List<CollectedCard> _all = [];
  List<CollectedCard> _filtered = [];
  final _searchCtrl = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadCards(); _searchCtrl.addListener(_search); }

  Future<void> _loadCards() async {
    final cards = await CardsService.instance.getCollectedCards();
    if (!mounted) return;
    setState(() { _all = cards; _filtered = cards; _isLoading = false; });
  }

  void _search() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _all : _all.where((c) =>
      c.name.toLowerCase().contains(q) || c.company.toLowerCase().contains(q) || c.autoName.toLowerCase().contains(q)).toList(); });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text('Collected Cards'),
        actions: [Padding(padding: const EdgeInsets.only(right: 8),
          child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)),
            child: Text('${_all.length}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)))))],
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(controller: _searchCtrl, style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(hintText: 'Search by name, company...', prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
              fillColor: Colors.white, filled: true, contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent))))),
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.people_outline, size: 60, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text(_searchCtrl.text.isEmpty ? 'No collected cards yet' : 'No results found', style: AppTextStyles.heading3),
                    const SizedBox(height: 6),
                    Text(_searchCtrl.text.isEmpty ? 'Scan someone\'s card to get started' : 'Try a different search term', style: AppTextStyles.bodySecondary),
                    if (_searchCtrl.text.isEmpty) ...[const SizedBox(height: 24),
                      ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/scan').then((_) => _loadCards()),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)), child: const Text('Scan a Card'))],
                  ]))
                : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => CollectedCardTile(card: _filtered[i],
                      onTap: () => Navigator.pushNamed(context, '/collected-card-detail', arguments: _filtered[i]).then((_) => _loadCards())))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/scan').then((_) => _loadCards()),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
