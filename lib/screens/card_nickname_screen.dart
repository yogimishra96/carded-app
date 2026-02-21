import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CardNicknameScreen extends StatefulWidget {
  const CardNicknameScreen({super.key});
  @override
  State<CardNicknameScreen> createState() => _CardNicknameScreenState();
}

class _CardNicknameScreenState extends State<CardNicknameScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final card = ModalRoute.of(context)?.settings.arguments as VisitingCard?;
      if (card != null && card.nickname.isNotEmpty) _ctrl.text = card.nickname;
      _initialized = true;
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname'), backgroundColor: AppColors.error));
      return;
    }
    final card = ModalRoute.of(context)!.settings.arguments as VisitingCard;
    setState(() => _isLoading = true);
    final updatedCard = card.copyWith(nickname: _ctrl.text.trim());
    final result = await CardsService.instance.saveCard(updatedCard);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card saved!'), backgroundColor: AppColors.success));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else if (result.isLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card limit reached (max 5 cards)'), backgroundColor: AppColors.error));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to save'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text('Name Your Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const SectionHeader(title: 'Give it a nickname', subtitle: 'This helps you identify the card quickly (e.g. "Work Card", "Freelance")'),
          const SizedBox(height: 36),
          AppTextField(label: 'Card Nickname', hint: 'e.g. Work Card, Personal, Freelance...', controller: _ctrl),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ['Work Card', 'Personal', 'Freelance', 'Startup'].map((s) =>
            GestureDetector(
              onTap: () => setState(() => _ctrl.text = s),
              child: Chip(label: Text(s, style: const TextStyle(fontSize: 13)),
                backgroundColor: AppColors.accentLight, labelStyle: const TextStyle(color: AppColors.accent), side: BorderSide.none),
            )).toList()),
          const Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Card'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
