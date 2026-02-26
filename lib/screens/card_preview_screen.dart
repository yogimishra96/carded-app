import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CardPreviewScreen extends StatefulWidget {
  const CardPreviewScreen({super.key});
  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  bool _saving = false;

  // ── Save: create card → then upload photo ──────────────────
  //
  // Yahi asli flow hai:
  //   1. POST /cards        → server se card + id milta hai
  //   2. POST /cards/:id/photo → Cloudinary pe upload hoti hai
  //
  // Dono ek hi button press pe hote hain, user ko sirf loader dikhta hai.

  Future<void> _saveCard(VisitingCard card, File? photo) async {
    setState(() => _saving = true);

    final result = await CardsService.instance.saveCard(card, photo: photo);

    if (!mounted) return;
    setState(() => _saving = false);

    if (result.success) {
      // Saari screens pop karo aur my-cards pe jao
      Navigator.pushNamedAndRemoveUntil(
          context, '/my-cards', (route) => route.settings.name == '/home');
    } else if (result.isLimitReached) {
      _showError('Card limit reached (max 5). Please delete an existing card first.');
    } else {
      _showError(result.message ?? 'Could not save card. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    final args   = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final card   = args['card'] as VisitingCard;
    final isView = args['isView'] as bool? ?? false;
    final photo  = args['photo'] as File?; // local File picked in details screen

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
        title: Text(isView ? card.nickname : 'Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Text('Card Preview', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 20),
          VisitingCardWidget(card: card),
          const SizedBox(height: 28),

          // QR code — sirf saved card pe dikhao
          if (isView && card.id.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
              ),
              child: Column(children: [
                const Text('QR Code', style: AppTextStyles.label),
                const SizedBox(height: 14),
                QrImageView(
                    data: CardsService.instance.encodeCardToQR(card),
                    version: QrVersions.auto,
                    size: 180),
                const SizedBox(height: 12),
                Text(card.name, style: AppTextStyles.heading3),
                Text(card.company, style: AppTextStyles.bodySecondary),
              ]),
            ),
            const SizedBox(height: 28),
          ],

          // Card details
          _DetailRow('Name', card.name),
          _DetailRow('Designation', card.designation),
          _DetailRow('Company', card.company),
          _DetailRow('Email', card.email1),
          if (card.email2.isNotEmpty) _DetailRow('Email 2', card.email2),
          _DetailRow('Phone', card.phone1),
          if (card.phone2.isNotEmpty) _DetailRow('Phone 2', card.phone2),
          if (card.website.isNotEmpty) _DetailRow('Website', card.website),
          if (card.address.isNotEmpty) _DetailRow('Address', card.address),

          const SizedBox(height: 24),

          // Confirm/Edit buttons — sirf create/edit mode mein
          if (!isView)
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : () => _saveCard(card, photo),
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check, size: 18),
                  label: Text(_saving ? 'Saving...' : 'Save Card'),
                ),
              ),
            ]),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

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
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: AppTextStyles.label)),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ]),
    );
  }
}