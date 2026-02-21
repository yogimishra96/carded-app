import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/visiting_card.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  int _selected = 0;

  VisitingCard get _previewCard => VisitingCard(
        id: 'preview',
        nickname: 'Preview',
        name: 'Yogesh Sharma',
        designation: 'Senior Product Designer',
        company: 'Creative Labs Jaipur',
        email1: 'yogesh@creativelabs.in',
        phone1: '+91 98765 43210',
        website: 'www.yogesh.design',
        address: 'Jaipur, RJ',
        templateIndex: _selected,
        createdAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Template'),
      ),
      body: Column(
        children: [
          // ── Live Preview Section ────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE PREVIEW',
                  style: AppTextStyles.label.copyWith(fontSize: 10, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: VisitingCardWidget(
                      key: ValueKey(_selected),
                      card: _previewCard,
                      scale: 0.9, // thoda chhota rakh sakte ho agar bada lage
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.border),

         Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          CardTemplates.templates[_selected]['name'] as String,
          key: ValueKey(_selected),
          style: AppTextStyles.heading2.copyWith(fontSize: 22),
        ),
      ),
      Text(
        '${_selected + 1} / ${CardTemplates.templates.length}',
        style: AppTextStyles.caption.copyWith(fontSize: 14),
      ),
    ],
  ),
),

// ── Carousel Style Horizontal Pager ──────────────────────────────────────
SizedBox(
  height: 220, // adjust according to your card scale
  child: PageView.builder(
    controller: PageController(
      viewportFraction: 0.75, // 75% width center card, 25% peek left/right
      initialPage: _selected,
    ),
    onPageChanged: (index) {
      setState(() => _selected = index);
    },
    itemCount: CardTemplates.templates.length,
    itemBuilder: (context, i) {
      final t = CardTemplates.templates[i];
      final isActive = _selected == i;

      return AnimatedScale(
        scale: isActive ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () {
              // Optional: tap pe center kar do
              // PageController().animateToPage(i, duration: ..., curve: ...)
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: _tileColors[i],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isActive ? Colors.white : Colors.transparent,
                  width: isActive ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive ? _tileAccentColors[i].withOpacity(0.5) : Colors.black.withOpacity(0.2),
                    blurRadius: isActive ? 20 : 8,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t['name'].toString().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: _tileTextColors[i],
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t['name'] as String,
                      style: TextStyle(
                        color: _tileTextColors[i],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
),

// Dots indicator (optional lekin premium feel deta hai)
Padding(
  padding: const EdgeInsets.only(top: 16, bottom: 24),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(CardTemplates.templates.length, (index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _selected == index ? 12 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _selected == index ? AppColors.accent : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  ),
),

// Bottom Button
Padding(
  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
  child: SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.arrow_forward, size: 20),
      label: const Text('Select & Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      onPressed: () => Navigator.pushNamed(context, '/create-details', arguments: _selected),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  ),
),
          
        ],
      ),
    );
  }

  // ── Tile Colors (same as before) ────────────────────────────────────────
  static const List<List<Color>> _tileColors = [
    [Color(0xFFF8F8FB), Color(0xFFF8F8FB)],   // Minimal
    [Color(0xFF2D2D2D), Color(0xFF0A0A0A)],   // Dark Gold
    [Color(0xFF2563EB), Color(0xFFD946EF)],   // Gradient
    [Color(0xFF9BA8D4), Color(0xFFD6A8C9)],   // Glass
    [Color(0xFFF4F1EA), Color(0xFFEAE6DC)],   // Editorial
    [Color(0xFF0A0AC2), Color(0xFF0A0AC2)],   // Corporate
    [Color(0xFF0F0C29), Color(0xFF302B63)],   // Midnight
    [Color(0xFF0077B6), Color(0xFF023E8A)],   // Ocean
    [Color(0xFF0A001F), Color(0xFF1A0033)],
    [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
  ];

  static const List<Color> _tileTextColors = [
    Color(0xFF0F172A),
    Colors.white,
    Colors.white,
    Color(0xFF0F172A),
    Colors.black,
    Colors.white,
    Colors.white,
    Colors.white,
    Color(0xFFDBEAFE),  // neon
Color(0xFF1F2937),  // sunset
  ];

  static const List<Color> _tileAccentColors = [
    Color(0xFF94A3B8),
    Color(0xFFD4AF37),
    Color(0xFFF0ABFC),
    Color(0xFF6366F1),
    Colors.black,
    Color(0xFF60A5FA),
    Color(0xFF818CF8),
    Color(0xFF90E0EF),
    Color(0xFFEC4899),  // neon pink
Color(0xFFF59E0B),  // amber
  ];
}