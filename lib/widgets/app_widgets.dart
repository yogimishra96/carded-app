import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../models/collected_card.dart';

// ─── Card Templates ───────────────────────────────────────────────────────────

class CardTemplates {
  static const List<Map<String, dynamic>> templates = [
    {'name': 'Midnight', 'bg': Color(0xFF1A1A2E), 'text': Colors.white, 'accent': Color(0xFF4F8EF7)},
    {'name': 'Arctic', 'bg': Color(0xFFEFF6FF), 'text': Color(0xFF1E3A5F), 'accent': Color(0xFF3B82F6)},
    {'name': 'Forest', 'bg': Color(0xFF064E3B), 'text': Colors.white, 'accent': Color(0xFF34D399)},
    {'name': 'Rose', 'bg': Color(0xFFFFF1F2), 'text': Color(0xFF881337), 'accent': Color(0xFFF43F5E)},
    {'name': 'Slate', 'bg': Color(0xFF1E293B), 'text': Colors.white, 'accent': Color(0xFF94A3B8)},
    {'name': 'Amber', 'bg': Color(0xFFFFFBEB), 'text': Color(0xFF78350F), 'accent': Color(0xFFF59E0B)},
  ];
}

// ─── Visiting Card Widget ─────────────────────────────────────────────────────

class VisitingCardWidget extends StatelessWidget {
  final VisitingCard card;
  final double scale;

  const VisitingCardWidget({super.key, required this.card, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final template = CardTemplates.templates[card.templateIndex % CardTemplates.templates.length];
    final bgColor = template['bg'] as Color;
    final textColor = template['text'] as Color;
    final accentColor = template['accent'] as Color;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 340,
        height: 190,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.1),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          card.name.isNotEmpty ? card.name[0].toUpperCase() : 'C',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            card.designation,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
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
                Container(
                  height: 1,
                  color: accentColor.withOpacity(0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  card.company,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 11, color: textColor.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      card.phone1,
                      style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.email_outlined, size: 11, color: textColor.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        card.email1,
                        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
                    width: 80,
                    height: 50,
                    child: VisitingCardWidget(card: card, scale: 0.235),
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
