import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CardPreviewScreen extends StatelessWidget {
  const CardPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final card = args['card'] as VisitingCard;
    final isView = args['isView'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isView ? card.nickname : 'Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Card Preview', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 20),
            VisitingCardWidget(card: card),
            const SizedBox(height: 28),
            // QR code placeholder / actual QR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text('QR Code', style: AppTextStyles.label),
                  const SizedBox(height: 14),
                  card.id.isNotEmpty
                      ? QrImageView(
                          data: CardsService.instance.encodeCardToQR(card),
                          version: QrVersions.auto,
                          size: 180,
                        )
                      : Container(
                          width: 180,
                          height: 180,
                          color: AppColors.border,
                          child: const Center(child: Text('QR will appear after saving', textAlign: TextAlign.center)),
                        ),
                  const SizedBox(height: 12),
                  Text(card.name, style: AppTextStyles.heading3),
                  Text(card.company, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Card details
            _DetailSection(label: 'Name', value: card.name),
            _DetailSection(label: 'Designation', value: card.designation),
            _DetailSection(label: 'Company', value: card.company),
            _DetailSection(label: 'Email', value: card.email1),
            if (card.email2.isNotEmpty) _DetailSection(label: 'Email 2', value: card.email2),
            _DetailSection(label: 'Phone', value: card.phone1),
            if (card.phone2.isNotEmpty) _DetailSection(label: 'Phone 2', value: card.phone2),
            if (card.website.isNotEmpty) _DetailSection(label: 'Website', value: card.website),
            if (card.address.isNotEmpty) _DetailSection(label: 'Address', value: card.address),
            const SizedBox(height: 24),
            if (!isView) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/card-nickname', arguments: card),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String value;

  const _DetailSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.label),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
