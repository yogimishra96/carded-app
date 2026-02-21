import 'package:flutter/material.dart';
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
  final _categoryCtrl = TextEditingController();
  final _leadTypeCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  static const List<String> _categories = ['Client', 'Partner', 'Investor', 'Vendor', 'Colleague', 'Friend', 'Other'];
  static const List<String> _leadTypes = ['Hot', 'Warm', 'Cold', 'Qualified', 'Not Applicable'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _card = ModalRoute.of(context)!.settings.arguments as CollectedCard;
      _categoryCtrl.text = _card.category;
      _leadTypeCtrl.text = _card.leadType;
      _remarksCtrl.text = _card.remarks;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final success = await CardsService.instance.updateCollectedCard(
      _card.id,
      category: _categoryCtrl.text.trim(),
      leadType: _leadTypeCtrl.text.trim(),
      remarks: _remarksCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Card'), content: const Text('Remove this card from your collection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Delete')),
        ]));
    if (confirm == true) {
      await CardsService.instance.deleteCollectedCard(_card.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() { _categoryCtrl.dispose(); _leadTypeCtrl.dispose(); _remarksCtrl.dispose(); super.dispose(); }

  Widget _chipSelector({required String label, required List<String> options, required TextEditingController controller}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 6, children: options.map((opt) {
        final selected = controller.text == opt;
        return GestureDetector(
          onTap: () => setState(() => controller.text = selected ? '' : opt),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: selected ? AppColors.accent : Colors.white, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: selected ? AppColors.accent : AppColors.border)),
            child: Text(opt, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textPrimary))));
      }).toList()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: Text(_card.autoName),
        actions: [IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: _delete)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(_card.name.isNotEmpty ? _card.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_card.name, style: AppTextStyles.heading3),
                  Text(_card.designation, style: AppTextStyles.bodySecondary),
                  Text(_card.company, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500, fontSize: 13)),
                ])),
              ]),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              if (_card.phone1.isNotEmpty) _ContactRow(icon: Icons.phone_outlined, text: _card.phone1),
              if (_card.phone2.isNotEmpty) _ContactRow(icon: Icons.phone_outlined, text: _card.phone2),
              if (_card.email1.isNotEmpty) _ContactRow(icon: Icons.email_outlined, text: _card.email1),
              if (_card.email2.isNotEmpty) _ContactRow(icon: Icons.email_outlined, text: _card.email2),
              if (_card.website.isNotEmpty) _ContactRow(icon: Icons.language_outlined, text: _card.website),
              if (_card.address.isNotEmpty) _ContactRow(icon: Icons.location_on_outlined, text: _card.address),
            ])),
          const SizedBox(height: 24),
          const Text('Tags & Notes', style: AppTextStyles.label),
          const SizedBox(height: 16),
          _chipSelector(label: 'Category', options: _categories, controller: _categoryCtrl),
          const SizedBox(height: 16),
          _chipSelector(label: 'Lead Type', options: _leadTypes, controller: _leadTypeCtrl),
          const SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Remarks', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(controller: _remarksCtrl, maxLines: 3, style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(hintText: 'Add notes about this contact...')),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _isSaving ? null : _save,
            child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save')),
          const SizedBox(height: 12),
          Text('Scanned on ${_card.scannedAt.day}/${_card.scannedAt.month}/${_card.scannedAt.year}', style: AppTextStyles.caption),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon; final String text;
  const _ContactRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [Icon(icon, size: 16, color: AppColors.textSecondary), const SizedBox(width: 10), Expanded(child: Text(text, style: AppTextStyles.body))]));
}
