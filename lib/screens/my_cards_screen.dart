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
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      await CardsService.instance.deleteCard(card.id);
      _loadCards();
    }
  }

  void _goCreate() =>
      Navigator.pushNamed(context, '/create-template').then((_) => _loadCards());

  @override
  Widget build(BuildContext context) {
    final atLimit   = _cards.length >= CardsService.maxCards;
    final remaining = CardsService.maxCards - _cards.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context)),
        title: const Text('My Cards'),
        actions: [
          if (!atLimit)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _goCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? _EmptyState(onCreate: _goCreate)
              : Column(children: [

                  // ── Usage banner ────────────────────────────
                  _UsageBanner(used: _cards.length, total: CardsService.maxCards),

                  // ── Cards list ──────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      // SafeArea bottom padding — button ke peeche nahi jayega
                      padding: EdgeInsets.fromLTRB(
                        16, 12, 16,
                        MediaQuery.of(context).padding.bottom + (atLimit ? 16 : 88),
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (ctx, i) {
                        final card = _cards[i];
                        return MyCardTile(
                          card: card,
                          onView: () => Navigator.pushNamed(context, '/card-preview',
                              arguments: {'card': card, 'isView': true}),
                          onShare: () => Navigator.pushNamed(context, '/share',
                              arguments: card.id),
                          onEdit: () => Navigator.pushNamed(context, '/create-details',
                              arguments: card).then((_) => _loadCards()),
                          onDelete: () => _deleteCard(card),
                        );
                      },
                    ),
                  ),
                ]),

      // ── FAB-style bottom button — sirf tab jab limit nahi ──
      bottomNavigationBar: _cards.isNotEmpty && !atLimit
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: _goCreate,
                  icon: const Icon(Icons.add_card_outlined, size: 20),
                  label: Text('New Card  ($remaining left)'),
                ),
              ),
            )
          : null,
    );
  }
}

// ─── Usage Banner ─────────────────────────────────────────────

class _UsageBanner extends StatelessWidget {
  final int used, total;
  const _UsageBanner({required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final atLimit = used >= total;
    final color   = atLimit ? AppColors.warning : AppColors.accent;
    final bgColor = atLimit ? AppColors.warning.withOpacity(0.08) : AppColors.accentLight;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(atLimit ? Icons.warning_amber_outlined : Icons.credit_card_outlined,
          size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            atLimit
                ? 'Card limit reached — delete one to create new'
                : '$used of $total cards used',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
          ),
        ),
        // Dot indicators
        Row(children: List.generate(total, (i) => Container(
          margin: const EdgeInsets.only(left: 4),
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < used ? color : color.withOpacity(0.2),
          ),
        ))),
      ]),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.credit_card_outlined, size: 38, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          const Text('No cards yet', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          const Text(
            'Create your first visiting card\nand share it with anyone',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_card_outlined, size: 20),
            label: const Text('Create Your First Card'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50)),
          ),
        ]),
      ),
    );
  }
}