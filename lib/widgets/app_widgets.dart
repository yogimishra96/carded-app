import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../models/collected_card.dart';

// ─── Card Templates Registry ──────────────────────────────────────────────────

class CardTemplates {
  static const List<Map<String, dynamic>> templates = [
    {'name': 'Minimal',    'style': 'minimal'},
    {'name': 'Dark Gold',  'style': 'darkgold'},
    {'name': 'Gradient',   'style': 'gradient'},
    {'name': 'Glass',      'style': 'glass'},
    {'name': 'Editorial',  'style': 'editorial'},
    {'name': 'Corporate',  'style': 'corporate'},
    {'name': 'Midnight',   'style': 'midnight'},
    {'name': 'Ocean',      'style': 'ocean'},
    // {'name': 'Neon Cyber', 'style': 'neoncyber'},
    // {'name': 'Soft Clay',  'style': 'softclay'},
  ];
}

// ─── Photo Helper ─────────────────────────────────────────────────────────────

Widget _cardPhoto(VisitingCard card, double size, {double radius = 999, BoxShape shape = BoxShape.circle, Border? border}) {
  final url  = card.effectivePhotoUrl;
  final path = card.photoPath;
  final initials = card.name.isNotEmpty ? card.name[0].toUpperCase() : 'C';

  ImageProvider? provider;
  if (url != null)        provider = NetworkImage(url);
  else if (path != null && path.isNotEmpty) provider = FileImage(File(path));

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: shape,
      borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      border: border,
      color: Colors.black12,
    ),
    clipBehavior: Clip.antiAlias,
    child: provider != null
        ? Image(image: provider, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initials(initials))
        : _initials(initials),
  );
}

Widget _initials(String letter, {Color bg = const Color(0x22FFFFFF), Color text = Colors.white, double fontSize = 22}) {
  return Container(
    color: bg,
    child: Center(child: Text(letter, style: TextStyle(color: text, fontSize: fontSize, fontWeight: FontWeight.w800))),
  );
}

// ─── Master Card Widget ───────────────────────────────────────────────────────

class VisitingCardWidget extends StatelessWidget {
  final VisitingCard card;
  final double scale;

  const VisitingCardWidget({super.key, required this.card, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final style = CardTemplates.templates[card.templateIndex % CardTemplates.templates.length]['style'] as String;
    Widget cardBody;
    switch (style) {
      case 'minimal':    cardBody = _MinimalCard(card: card); break;
      case 'darkgold':   cardBody = _DarkGoldCard(card: card); break;
      case 'gradient':   cardBody = _GradientCard(card: card); break;
      case 'glass':      cardBody = _GlassCard(card: card); break;
      case 'editorial':  cardBody = _EditorialCard(card: card); break;
      case 'corporate':  cardBody = _CorporateCard(card: card); break;
      case 'midnight':   cardBody = _MidnightCard(card: card); break;
      case 'ocean':      cardBody = _OceanCard(card: card); break;
      // case 'neoncyber':   cardBody = _NeonCyberCard(card: card); break;
      // case 'softclay':    cardBody = _SoftClayCard(card: card); break;
      default:           cardBody = _MinimalCard(card: card);
    }
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: cardBody,
    );
  }
}

const double _kW = 340;
const double _kH = 194;

// ═══════════════════════════════════════════════════════════════════════════════
// 1. MINIMAL WHITE  — slate-50 bg, top-right photo, icons bottom
// ═══════════════════════════════════════════════════════════════════════════════
class _MinimalCard extends StatelessWidget {
  final VisitingCard card;
  const _MinimalCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E2EC), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Text(card.designation.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 1.8)),
          ])),
          const SizedBox(width: 10),
          _cardPhoto(card, 46, radius: 999,
            border: Border.all(color: Colors.white, width: 3)),
        ]),
        const Spacer(),
        Container(height: 1, color: const Color(0xFFE2E2EC)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(card.company, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          Row(children: [
            _MinIcon(Icons.phone_outlined),
            const SizedBox(width: 14),
            _MinIcon(Icons.mail_outlined),
            if (card.website.isNotEmpty) ...[const SizedBox(width: 14), _MinIcon(Icons.language_outlined)],
          ]),
        ]),
      ]),
    );
  }
}

class _MinIcon extends StatelessWidget {
  final IconData icon;
  const _MinIcon(this.icon);
  @override
  Widget build(BuildContext context) => Icon(icon, size: 16, color: const Color(0xFF94A3B8));
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. DARK GOLD — black radial gradient, gold text, glowing orb
// ═══════════════════════════════════════════════════════════════════════════════
class _DarkGoldCard extends StatelessWidget {
  final VisitingCard card;
  const _DarkGoldCard({required this.card});

  static const gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const RadialGradient(
          center: Alignment(0.7, -0.7),
          radius: 1.2,
          colors: [Color(0xFF2D2D2D), Color(0xFF0A0A0A)],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // gold glow orb top-right
        Positioned(right: -50, top: -50,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: gold.withOpacity(0.10)),
          )),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: gold, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                Text(card.designation, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.45), letterSpacing: 0.5)),
              ])),
              _cardPhoto(card, 46, border: Border.all(color: gold.withOpacity(0.4), width: 2)),
            ]),
            const Spacer(),
            Text('${card.company}  •  ${card.address.isNotEmpty ? card.address.split(',').last.trim() : 'India'}',
              style: TextStyle(fontSize: 9, color: gold.withOpacity(0.6), letterSpacing: 2.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(children: [
              _GoldIcon(Icons.smartphone_outlined),
              const SizedBox(width: 16),
              _GoldIcon(Icons.alternate_email),
              const SizedBox(width: 16),
              _GoldIcon(Icons.language),
              const SizedBox(width: 16),
              _GoldIcon(Icons.people_outline),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _GoldIcon extends StatelessWidget {
  final IconData icon;
  const _GoldIcon(this.icon);
  @override
  Widget build(BuildContext context) => Icon(icon, size: 18, color: const Color(0xFFD4AF37));
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. GRADIENT MODERN — conic blue-fuchsia-rose, italic name, rotated photo
// ═══════════════════════════════════════════════════════════════════════════════
class _GradientCard extends StatelessWidget {
  final VisitingCard card;
  const _GradientCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final parts = card.name.trim().split(' ');
    final first = parts.first;
    final last  = parts.length > 1 ? parts.last : '';

    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          center: Alignment(-0.8, -0.8),
          colors: [Color(0xFF2563EB), Color(0xFFD946EF), Color(0xFFF43F5E), Color(0xFF2563EB)],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        boxShadow: [BoxShadow(color: const Color(0xFFD946EF).withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Container(color: Colors.white.withOpacity(0.06)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Transform.rotate(angle: 0.05,
                child: _cardPhoto(card, 58, radius: 14,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2))),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(first, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic, height: 1.0, letterSpacing: -1)),
                    if (last.isNotEmpty)
                      Text(last, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic, height: 1.0, letterSpacing: -1)),
                  ]),
                ),
              ),
            ]),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.designation.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 2),
                Text(card.company, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
              ]),
              Row(children: [
                _GlassBtn(Icons.call),
                const SizedBox(width: 6),
                _GlassBtn(Icons.mail_outline),
              ]),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    child: Icon(icon, size: 14, color: Colors.white),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. GLASSMORPHISM — blurred indigo+pink orbs, frosted inner card
// ═══════════════════════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final VisitingCard card;
  const _GlassCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFCDD5F0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // indigo orb
        Positioned(left: -30, top: -30,
          child: Container(width: 130, height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withOpacity(0.55)),
          )),
        // pink orb
        Positioned(right: -30, bottom: -30,
          child: Container(width: 130, height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: const Color(0xFFEC4899).withOpacity(0.55)),
          )),
        // frosted inner
        Center(
          child: Container(
            width: _kW - 20, height: _kH - 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.32),
              border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.2),
              boxShadow: [BoxShadow(color: const Color(0xFF3B3FA0).withOpacity(0.12), blurRadius: 20)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _cardPhoto(card, 48,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 2)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(card.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(card.designation.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4338CA), letterSpacing: 1.2)),
                ])),
              ]),
              const Spacer(),
              Container(height: 1, color: Colors.white.withOpacity(0.25)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _GlassInfo(Icons.alternate_email, card.email1.isNotEmpty ? card.email1.split('@').last : card.company),
                  const SizedBox(height: 4),
                  _GlassInfo(Icons.language, card.website.isNotEmpty ? card.website.replaceAll('https://', '') : 'www.${card.name.toLowerCase().replaceAll(' ', '')}.com'),
                ]),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.45),
                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                  ),
                  child: const Icon(Icons.share_outlined, size: 16, color: Color(0xFF1E293B)),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _GlassInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _GlassInfo(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 12, color: const Color(0xFF475569)),
    const SizedBox(width: 5),
    Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. EDITORIAL / BOLD CREATIVE — cream bg, serif name, split layout, photo right
// ═══════════════════════════════════════════════════════════════════════════════
class _EditorialCard extends StatelessWidget {
  final VisitingCard card;
  const _EditorialCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final parts = card.name.trim().split(' ');
    final first = parts.first;
    final last  = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1EA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        // LEFT — typography
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 20, height: 1, color: Colors.black),
                const SizedBox(width: 8),
                Text('Creative Portfolio'.toUpperCase(), style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, letterSpacing: 2.5, color: Colors.black)),
              ]),
              const SizedBox(height: 10),
              // Serif-style using heavy weight + tight tracking
              Text(first, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black, height: 0.95, letterSpacing: -1.5)),
              if (last.isNotEmpty)
                Text(last, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black, height: 0.95, letterSpacing: -1.5)),
              const Spacer(),
              Text('Position'.toUpperCase(), style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black.withOpacity(0.35))),
              const SizedBox(height: 2),
              Text(card.designation, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.black)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.call, size: 14, color: Colors.black),
                const SizedBox(width: 10),
                const Icon(Icons.mail_outline, size: 14, color: Colors.black),
                const SizedBox(width: 10),
                const Icon(Icons.language, size: 14, color: Colors.black),
              ]),
            ]),
          ),
        ),

        // RIGHT — photo panel
        SizedBox(
          width: _kW * 0.38,
          child: Stack(children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFEAE6DC)),
            ),
            // vertical divider
            Positioned(left: 0, top: 0, bottom: 0,
              child: Container(width: 1, color: Colors.black.withOpacity(0.1))),
            // photo
            Center(
              child: _cardPhoto(card, 80, radius: 999,
                border: Border.all(color: Colors.white, width: 3)),
            ),
            // location watermark
            Positioned(bottom: 12, right: 10,
              child: Transform.rotate(angle: math.pi / 2,
                child: Text(
                  card.address.isNotEmpty ? card.address.split(',').first.toUpperCase() : 'INDIA',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.black.withOpacity(0.18)),
                ),
              )),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. CORPORATE BLUE — primary blue, dot pattern bg, grid contact info
// ═══════════════════════════════════════════════════════════════════════════════
class _CorporateCard extends StatelessWidget {
  final VisitingCard card;
  const _CorporateCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0A0AC2),
        boxShadow: [BoxShadow(color: const Color(0xFF0A0AC2).withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // dot pattern
        Positioned.fill(
          child: CustomPaint(painter: _DotPatternPainter()),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // top: photo + name
            Row(children: [
              _cardPhoto(card, 46, radius: 12, shape: BoxShape.rectangle,
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 2)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(card.company.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.55), letterSpacing: 1.2)),
              ])),
            ]),
            const Spacer(),
            // contact grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _CorpInfo(Icons.call, card.phone1.isNotEmpty ? card.phone1 : '+91 98765 43210')),
                  Expanded(child: _CorpInfo(Icons.mail_outline, card.email1.isNotEmpty ? card.email1 : 'hello@corp.com')),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: _CorpInfo(Icons.language, card.website.isNotEmpty ? card.website.replaceAll('https://', '') : 'www.corp.com')),
                  Expanded(child: _CorpInfo(Icons.location_on_outlined, card.address.isNotEmpty ? card.address.split(',').first : 'Jaipur, RJ')),
                ]),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _CorpInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CorpInfo(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: Colors.white.withOpacity(0.45)),
    const SizedBox(width: 4),
    Expanded(child: Text(text, style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
  ]);
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.09)..style = PaintingStyle.fill;
    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. MIDNIGHT — deep purple gradient (existing, refined)
// ═══════════════════════════════════════════════════════════════════════════════
class _MidnightCard extends StatelessWidget {
  final VisitingCard card;
  const _MidnightCard({required this.card});

  static const accent = Color(0xFF818CF8);
  static const sub    = Color(0xFFE0E7FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0F0C29), Color(0xFF302B63)]),
        boxShadow: [BoxShadow(color: const Color(0xFF302B63).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(right: -36, top: -36,
          child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.18)))),
        Positioned(right: 40, bottom: -48,
          child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.10)))),
        Padding(padding: const EdgeInsets.fromLTRB(22, 20, 22, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _cardPhoto(card, 46, radius: 12, shape: BoxShape.rectangle,
              border: Border.all(color: accent.withOpacity(0.4), width: 1.5)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text(card.designation, style: TextStyle(fontSize: 11, color: sub.withOpacity(0.75))),
            ])),
          ]),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3))),
            child: Text(card.company, style: const TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w700))),
          const SizedBox(height: 10),
          Container(height: 1, color: accent.withOpacity(0.2)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.phone_rounded, size: 11, color: sub.withOpacity(0.65)), const SizedBox(width: 4),
            Text(card.phone1, style: TextStyle(color: sub.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500)),
            Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: sub.withOpacity(0.35))),
            Icon(Icons.alternate_email_rounded, size: 11, color: sub.withOpacity(0.65)), const SizedBox(width: 4),
            Expanded(child: Text(card.email1, style: TextStyle(color: sub.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 8. OCEAN — rich blue gradient (existing, refined)
// ═══════════════════════════════════════════════════════════════════════════════
class _OceanCard extends StatelessWidget {
  final VisitingCard card;
  const _OceanCard({required this.card});

  static const accent = Color(0xFF90E0EF);
  static const sub    = Color(0xFFCAF0F8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW, height: _kH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0077B6), Color(0xFF023E8A)]),
        boxShadow: [BoxShadow(color: const Color(0xFF023E8A).withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(right: -40, top: -40,
          child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.15)))),
        // wave-like arcs
        Positioned(left: -20, bottom: -20,
          child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.08)))),
        Padding(padding: const EdgeInsets.fromLTRB(22, 20, 22, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _cardPhoto(card, 46, radius: 12, shape: BoxShape.rectangle,
              border: Border.all(color: accent.withOpacity(0.4), width: 1.5)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text(card.designation, style: TextStyle(fontSize: 11, color: sub.withOpacity(0.75))),
            ])),
          ]),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3))),
            child: Text(card.company, style: const TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w700))),
          const SizedBox(height: 10),
          Container(height: 1, color: accent.withOpacity(0.2)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.phone_rounded, size: 11, color: sub.withOpacity(0.65)), const SizedBox(width: 4),
            Text(card.phone1, style: TextStyle(color: sub.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500)),
            Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: sub.withOpacity(0.35))),
            Icon(Icons.alternate_email_rounded, size: 11, color: sub.withOpacity(0.65)), const SizedBox(width: 4),
            Expanded(child: Text(card.email1, style: TextStyle(color: sub.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
      ]),
    );
  }
}

// 9. NEON CYBER MINIMAL ───────────────────────────────────────────────────────
class _NeonCyberCard extends StatelessWidget {
  final VisitingCard card;
  const _NeonCyberCard({required this.card});

  static const neonPink = Color(0xFFFF2E63);
  static const neonCyan = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW,
      height: _kH,
      decoration: BoxDecoration(
        color: const Color(0xFF0D001A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: neonPink.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(-10, -10),
          ),
          BoxShadow(
            color: neonCyan.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(10, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // subtle grid background
          CustomPaint(
            painter: _GridPainter(),
            size: Size(_kW, _kH),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: neonCyan, width: 2),
                        boxShadow: [BoxShadow(color: neonCyan.withOpacity(0.6), blurRadius: 12)],
                      ),
                      child: _cardPhoto(card, 56, radius: 999),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: neonPink,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(color: neonPink.withOpacity(0.7), blurRadius: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.designation,
                            style: TextStyle(
                              fontSize: 13,
                              color: neonCyan,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: neonCyan.withOpacity(0.5)),
                  ),
                  child: Text(
                    card.company.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NeonIcon(Icons.phone_android_rounded, neonPink),
                    _NeonIcon(Icons.mail_outline_rounded, neonCyan),
                    _NeonIcon(Icons.language_rounded, neonPink),
                    _NeonIcon(Icons.location_on_rounded, neonCyan),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _NeonIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12)],
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A0033).withOpacity(0.3)
      ..strokeWidth = 0.8;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 10. SOFT CLAY MORPHISM ───────────────────────────────────────────────────────
class _SoftClayCard extends StatelessWidget {
  final VisitingCard card;
  const _SoftClayCard({required this.card});

  static const clayBg = Color(0xFFE8EEF5);
  static const shadowLight = Color(0xFFFFFFFF);
  static const shadowDark = Color(0xFFB8C2CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kW,
      height: _kH,
      decoration: BoxDecoration(
        color: clayBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // inset shadow for clay effect
          BoxShadow(
            color: shadowDark.withOpacity(0.25),
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: shadowLight.withOpacity(0.8),
            offset: const Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // subtle noise texture (optional – agar image add karna ho to)
          // ClipRRect(borderRadius: BorderRadius.circular(32), child: ... noise image)

          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // floating photo with clay shadow
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadowDark.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(6, 6),
                        ),
                        BoxShadow(
                          color: shadowLight.withOpacity(0.7),
                          blurRadius: 20,
                          offset: const Offset(-6, -6),
                        ),
                      ],
                    ),
                    child: _cardPhoto(card, 90, radius: 999),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    card.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3748),
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    card.designation.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF718096),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: clayBg,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: shadowDark.withOpacity(0.2), offset: const Offset(4, 4), blurRadius: 10),
                      BoxShadow(color: shadowLight.withOpacity(0.6), offset: const Offset(-4, -4), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_rounded, size: 18, color: const Color(0xFF4A5568)),
                      const SizedBox(width: 12),
                      Text(
                        card.phone1,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF2D3748), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ClayIcon(Icons.mail_outline_rounded),
                    _ClayIcon(Icons.language_rounded),
                    _ClayIcon(Icons.location_on_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClayIcon extends StatelessWidget {
  final IconData icon;
  const _ClayIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: const Color(0xFFB8C2CC).withOpacity(0.3), offset: const Offset(4, 4), blurRadius: 8),
          BoxShadow(color: Colors.white.withOpacity(0.7), offset: const Offset(-4, -4), blurRadius: 8),
        ],
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF4A5568)),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
      ),
    ]);
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: AppTextStyles.heading2),
    if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: AppTextStyles.bodySecondary)],
  ]);
}

// ─── My Card List Tile ────────────────────────────────────────────────────────

class MyCardTile extends StatelessWidget {
  final VisitingCard card;
  final VoidCallback onView, onShare, onEdit, onDelete;

  const MyCardTile({super.key, required this.card, required this.onView, required this.onShare, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 100, height: 58,
              child: OverflowBox(maxWidth: _kW, maxHeight: _kH, alignment: Alignment.topLeft,
                child: Transform.scale(scale: 100 / _kW, alignment: Alignment.topLeft,
                  child: VisitingCardWidget(card: card)))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card.nickname, style: AppTextStyles.heading3),
            const SizedBox(height: 2),
            Text(card.name, style: AppTextStyles.bodySecondary),
            Text(card.company, style: AppTextStyles.caption),
          ])),
        ])),
        const Divider(height: 1, color: AppColors.border),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(children: [
            _ActionBtn(icon: Icons.visibility_outlined, label: 'View', onTap: onView),
            _ActionBtn(icon: Icons.qr_code, label: 'Share', onTap: onShare),
            _ActionBtn(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
            _ActionBtn(icon: Icons.delete_outline, label: 'Delete', onTap: onDelete, isDestructive: true),
          ])),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isDestructive;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.accent;
    return Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ]))));
  }
}

// ─── Collected Card Tile ──────────────────────────────────────────────────────

class CollectedCardTile extends StatelessWidget {
  final CollectedCard card;
  final VoidCallback onTap;
  const CollectedCardTile({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card.autoName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(card.name, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
            Text('${card.company} · ${card.designation}', style: AppTextStyles.bodySecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ]),
      ));
  }
}

// ─── Home Action Card ─────────────────────────────────────────────────────────

class HomeActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap; final bool isLarge;
  const HomeActionCard({super.key, required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))]),
        child: isLarge
          ? Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.heading3),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ])),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22)),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
            ]),
      ));
  }
}