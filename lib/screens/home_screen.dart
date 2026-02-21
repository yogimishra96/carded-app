import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _myCardsCount = 0;
  int _collectedCount = 0;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final user = await AuthService.instance.getUser();
    final myCards = await CardsService.instance.getMyCards();
    final collected = await CardsService.instance.getCollectedCards();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName.split(' ').first ?? '';
      _myCardsCount = myCards.length;
      _collectedCount = collected.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hey, $_userName 👋', style: AppTextStyles.bodySecondary),
                  const Text('Your Dashboard', style: AppTextStyles.heading1),
                ])),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings').then((_) => _loadData()),
                  child: Container(width: 42, height: 42,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
                    child: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20)),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(children: [
                _StatChip(label: 'My Cards', value: '$_myCardsCount / 5'),
                const SizedBox(width: 10),
                _StatChip(label: 'Collected', value: '$_collectedCount'),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Actions', style: AppTextStyles.label),
                const SizedBox(height: 12),
                HomeActionCard(icon: Icons.qr_code_scanner, title: 'Scan Card', subtitle: 'Scan & collect someone\'s card',
                  color: AppColors.accent, onTap: () => Navigator.pushNamed(context, '/scan').then((_) => _loadData()), isLarge: true),
                const SizedBox(height: 10),
                HomeActionCard(icon: Icons.qr_code, title: 'Share My Card', subtitle: 'Show your QR instantly',
                  color: const Color(0xFF10B981), onTap: () => Navigator.pushNamed(context, '/share').then((_) => _loadData()), isLarge: true),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Manage', style: AppTextStyles.label),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: HomeActionCard(icon: Icons.add_card_outlined, title: 'Create Card', subtitle: 'Design a new card',
                    color: const Color(0xFF8B5CF6), onTap: () => Navigator.pushNamed(context, '/create-template').then((_) => _loadData()))),
                  const SizedBox(width: 12),
                  Expanded(child: HomeActionCard(icon: Icons.credit_card_outlined, title: 'My Cards', subtitle: 'View & manage',
                    color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, '/my-cards').then((_) => _loadData()))),
                ]),
                const SizedBox(height: 12),
                HomeActionCard(icon: Icons.people_outline, title: 'Collected Cards', subtitle: 'Browse your contact collection',
                  color: const Color(0xFFEF4444), onTap: () => Navigator.pushNamed(context, '/collected-cards').then((_) => _loadData()), isLarge: true),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.heading3),
        ]),
      ),
    );
  }
}
