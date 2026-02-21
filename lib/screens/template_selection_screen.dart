import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../models/collected_card.dart';

// ─── Card Templates ───────────────────────────────────────────────────────────

class CardTemplates {
  static const List<Map<String, dynamic>> templates = [
    {
      'name': 'Midnight',
      'style': 'dark',
      'bg1': Color(0xFF0F0C29),
      'bg2': Color(0xFF302B63),
      'text': Colors.white,
      'accent': Color(0xFF818CF8),
      'sub': Color(0xFFE0E7FF),
    },
    {
      'name': 'Ocean',
      'style': 'dark',
      'bg1': Color(0xFF0077B6),
      'bg2': Color(0xFF023E8A),
      'text': Colors.white,
      'accent': Color(0xFF90E0EF),
      'sub': Color(0xFFCAF0F8),
    },
    {
      'name': 'Forest',
      'style': 'dark',
      'bg1': Color(0xFF134E4A),
      'bg2': Color(0xFF064E3B),
      'text': Colors.white,
      'accent': Color(0xFF6EE7B7),
      'sub': Color(0xFFD1FAE5),
    },
    {
      'name': 'Blush',
      'style': 'light',
      'bg1': Color(0xFFFFF0F3),
      'bg2': Color(0xFFFFCCD5),
      'text': Color(0xFF6B0F1A),
      'accent': Color(0xFFE63946),
      'sub': Color(0xFF9D0208),
    },
    {
      'name': 'Slate',
      'style': 'dark',
      'bg1': Color(0xFF1E293B),
      'bg2': Color(0xFF0F172A),
      'text': Colors.white,
      'accent': Color(0xFF38BDF8),
      'sub': Color(0xFFBAE6FD),
    },
    {
      'name': 'Gold',
      'style': 'light',
      'bg1': Color(0xFFFFFBEB),
      'bg2': Color(0xFFFEF3C7),
      'text': Color(0xFF451A03),
      'accent': Color(0xFFD97706),
      'sub': Color(0xFF78350F),
    },
  ];
}

// ─── Visiting Card Widget ─────────────────────────────────────────────────────

class VisitingCardWidget extends StatelessWidget {
  final VisitingCard card;
  final double scale;

  const VisitingCardWidget({super.key, required this.card, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final t = CardTemplates.templates[card.templateIndex % CardTemplates.templates.length];
    final bg1        = t['bg1'] as Color;
    final bg2        = t['bg2'] as Color;
    final textColor  = t['text'] as Color;
    final accent     = t['accent'] as Color;
    final sub        = t['sub'] as Color;
    final isDark     = t['style'] == 'dark';

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: Container(
        width: 340,
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg1, bg2],
          ),
          boxShadow: [
            BoxShadow(
              color: bg2.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── Background decorative elements ──
              Positioned(
                right: -36,
                top: -36,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(isDark ? 0.18 : 0.22),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -48,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(isDark ? 0.10 : 0.15),
                  ),
                ),
              ),
              // thin diagonal stripe
              Positioned(
                left: -10,
                bottom: 30,
                child: Transform.rotate(
                  angle: -math.pi / 6,
                  child: Container(
                    width: 180,
                    height: 1.5,
                    color: accent.withOpacity(0.15),
                  ),
                ),
              ),

              // ── Card Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: avatar + name/designation
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: accent.withOpacity(isDark ? 0.22 : 0.18),
                            border: Border.all(color: accent.withOpacity(0.35), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              card.name.isNotEmpty ? card.name[0].toUpperCase() : 'C',
                              style: TextStyle(
                                color: accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card.designation,
                                style: TextStyle(
                                  color: sub.withOpacity(0.85),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Company pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.18 : 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        card.company,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Divider
                    Container(height: 1, color: accent.withOpacity(0.2)),
                    const SizedBox(height: 10),

                    // Contact row
                    Row(
                      children: [
                        if (card.phone1.isNotEmpty) ...[
                          Icon(Icons.phone_rounded, size: 11, color: sub.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            card.phone1,
                            style: TextStyle(
                              color: sub.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (card.phone1.isNotEmpty && card.email1.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sub.withOpacity(0.4),
                            ),
                          ),
                        if (card.email1.isNotEmpty) ...[
                          Icon(Icons.alternate_email_rounded, size: 11, color: sub.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              card.email1,
                              style: TextStyle(
                                color: sub.withOpacity(0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Input Field ──────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading2),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}

// ─── My Card List Tile ────────────────────────────────────────────────────────

class MyCardTile extends StatelessWidget {
  final VisitingCard card;
  final VoidCallback onView;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyCardTile({
    super.key,
    required this.card,
    required this.onView,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 100,
                    height: 58,
                    child: OverflowBox(
                      maxWidth: 340,
                      maxHeight: 196,
                      alignment: Alignment.topLeft,
                      child: Transform.scale(
                        scale: 100 / 340,
                        alignment: Alignment.topLeft,
                        child: VisitingCardWidget(card: card),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.nickname, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Text(card.name, style: AppTextStyles.bodySecondary),
                      Text(card.company, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _ActionBtn(icon: Icons.visibility_outlined, label: 'View', onTap: onView),
                _ActionBtn(icon: Icons.qr_code, label: 'Share', onTap: onShare),
                _ActionBtn(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
                _ActionBtn(icon: Icons.delete_outline, label: 'Delete', onTap: onDelete, isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.accent;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Collected Card Tile ──────────────────────────────────────────────────────

class CollectedCardTile extends StatelessWidget {
  final CollectedCard card;
  final VoidCallback onTap;

  const CollectedCardTile({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.autoName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text(card.name, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
                  Text('${card.company} · ${card.designation}', style: AppTextStyles.bodySecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Home Action Card ─────────────────────────────────────────────────────────

class HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: isLarge
            ? Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.heading3),
                        Text(subtitle, style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
                ],
              ),
      ),
    );
  }
}