import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/cards_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _userName  = '';
  String _fullName  = '';
  int _myCardsCount = 0;
  int _collectedCount = 0;
  bool _loading = true;
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _loadData();
  }

  Future<void> _loadData() async {
    final user      = await AuthService.instance.getUser();
    final myCards   = await CardsService.instance.getMyCards();
    final collected = await CardsService.instance.getCollectedCards();
    if (!mounted) return;
    setState(() {
      _fullName       = user?.fullName ?? '';
      _userName       = user?.fullName.split(' ').first ?? '';
      _myCardsCount   = myCards.length;
      _collectedCount = collected.length;
      _loading        = false;
    });
    _ctrl.forward();
  }

  void _nav(String route) =>
      Navigator.pushNamed(context, route).then((_) => _loadData());

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(slivers: [

                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(child: _Header(
                  userName: _userName,
                  fullName: _fullName,
                  onSettings: () => _nav('/settings'),
                )),

                // ── Stats row ───────────────────────────────────
                SliverToBoxAdapter(child: _StatsRow(
                  myCards: _myCardsCount,
                  collected: _collectedCount,
                )),

                // ── Primary actions ──────────────────────────────
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const _SectionLabel('Quick Actions'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _PrimaryAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan Card',
                        sub: 'Collect contact',
                        gradient: const [Color(0xFF6B21E8), Color(0xFFB45EF5)],
                        onTap: () => _nav('/scan'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _PrimaryAction(
                        icon: Icons.qr_code_rounded,
                        label: 'Share Card',
                        sub: 'Show your QR',
                        gradient: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                        onTap: () => _nav('/share'),
                      )),
                    ]),
                  ]),
                )),

                // ── Secondary actions ────────────────────────────
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const _SectionLabel('Manage'),
                    const SizedBox(height: 12),
                    _SecondaryAction(
                      icon: Icons.add_card_outlined,
                      label: 'Create Card',
                      sub: 'Design a new visiting card',
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFF3E8FF),
                      onTap: () => _nav('/create-template'),
                    ),
                    const SizedBox(height: 10),
                    _SecondaryAction(
                      icon: Icons.credit_card_outlined,
                      label: 'My Cards',
                      sub: '$_myCardsCount of 5 cards created',
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: const Color(0xFFFFFBEB),
                      onTap: () => _nav('/my-cards'),
                    ),
                    const SizedBox(height: 10),
                    _SecondaryAction(
                      icon: Icons.people_outline_rounded,
                      label: 'Collected Cards',
                      sub: '$_collectedCount contacts in your collection',
                      iconColor: const Color(0xFF10B981),
                      iconBg: const Color(0xFFECFDF5),
                      onTap: () => _nav('/collected-cards'),
                    ),
                  ]),
                )),

                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ]),
            ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String userName, fullName;
  final VoidCallback onSettings;
  const _Header({required this.userName, required this.fullName, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        // Avatar
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF6B21E8), Color(0xFFB45EF5)],
            ),
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Greeting
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good ${_greeting()},', style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
          Text(
            userName.isNotEmpty ? userName : 'Welcome',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A), letterSpacing: -0.3),
          ),
        ])),

        // Settings
        GestureDetector(
          onTap: onSettings,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF64748B)),
          ),
        ),
      ]),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int myCards, collected;
  const _StatsRow({required this.myCards, required this.collected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Expanded(child: _StatItem(
            value: '$myCards / 5',
            label: 'My Cards',
            icon: Icons.credit_card_outlined,
            color: const Color(0xFF7C3AED),
          )),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(child: _StatItem(
            value: '$collected',
            label: 'Collected',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF10B981),
          )),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
            color: color, letterSpacing: -0.3)),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8))),
        ]),
      ]),
    );
  }
}

// ─── Primary Action (gradient card) ──────────────────────────────────────────

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _PrimaryAction({required this.icon, required this.label,
    required this.sub, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w700)),
            Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.7),
              fontSize: 11, fontWeight: FontWeight.w400)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Secondary Action (list row) ─────────────────────────────────────────────

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color iconColor, iconBg;
  final VoidCallback onTap;
  const _SecondaryAction({required this.icon, required this.label, required this.sub,
    required this.iconColor, required this.iconBg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8))),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFCBD5E1)),
        ]),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: Color(0xFF94A3B8), letterSpacing: 1.2));
  }
}