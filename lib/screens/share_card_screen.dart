import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({super.key});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  List<VisitingCard> _cards = [];
  VisitingCard? _selected;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await CardsService.instance.getMyCards();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      final card = cards.where((c) => c.id == args).firstOrNull;
      if (card != null) setState(() => _selected = card);
    } else if (cards.isNotEmpty) {
      setState(() => _selected = cards.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Share Card'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.credit_card_off_outlined, size: 60, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('No cards to share', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      const Text('Create a card first', style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/create-template'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                        child: const Text('Create Card'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Card selector chips
                    if (_cards.length > 1) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select a card to share', style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _cards.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  final card = _cards[i];
                                  final isSelected = _selected?.id == card.id;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selected = card),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.accent : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? AppColors.accent : AppColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        card.nickname,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // QR area — scrollable to prevent overflow
                    Expanded(
                      child: _selected == null
                          ? const Center(child: Text('Select a card'))
                          : _QRDisplay(card: _selected!),
                    ),
                  ],
                ),
    );
  }
}

class _QRDisplay extends StatelessWidget {
  final VisitingCard card;
  const _QRDisplay({required this.card});

  @override
  Widget build(BuildContext context) {
    final qrData = CardsService.instance.encodeCardToQR(card);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          VisitingCardWidget(card: card),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 170,
                ),
                const SizedBox(height: 12),
                Text(card.nickname, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(card.name, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Ask the other person to scan',
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}