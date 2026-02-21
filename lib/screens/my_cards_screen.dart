import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});
  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  List<VisitingCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadCards(); }

  Future<void> _loadCards() async {
    final cards = await CardsService.instance.getMyCards();
    if (!mounted) return;
    setState(() { _cards = cards; _isLoading = false; });
  }

  Future<void> _deleteCard(VisitingCard card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Card'),
        content: Text('Delete "${card.nickname}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      await CardsService.instance.deleteCard(card.id);
      _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text('My Cards'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _cards.length >= 5 ? AppColors.warning.withOpacity(0.1) : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(_cards.length >= 5 ? Icons.warning_amber_outlined : Icons.info_outline,
                    size: 16, color: _cards.length >= 5 ? AppColors.warning : AppColors.accent),
                  const SizedBox(width: 8),
                  Text('${_cards.length} / ${CardsService.maxCards} cards used',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: _cards.length >= 5 ? AppColors.warning : AppColors.accent)),
                ]),
              ),
              Expanded(
                child: _cards.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.credit_card_outlined, size: 60, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text('No cards yet', style: AppTextStyles.heading3),
                        const SizedBox(height: 6),
                        const Text('Create your first visiting card', style: AppTextStyles.bodySecondary),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/create-template').then((_) => _loadCards()),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                          child: const Text('Create Card')),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cards.length,
                        itemBuilder: (ctx, i) {
                          final card = _cards[i];
                          return MyCardTile(
                            card: card,
                            onView: () => Navigator.pushNamed(context, '/card-preview', arguments: {'card': card, 'isView': true}),
                            onShare: () => Navigator.pushNamed(context, '/share', arguments: card.id),
                            onEdit: () => Navigator.pushNamed(context, '/create-details', arguments: card).then((_) => _loadCards()),
                            onDelete: () => _deleteCard(card),
                          );
                        }),
              ),
              if (_cards.length < CardsService.maxCards)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/create-template').then((_) => _loadCards()),
                    icon: const Icon(Icons.add), label: const Text('Create New Card')),
                ),
            ]),
    );
  }
}
