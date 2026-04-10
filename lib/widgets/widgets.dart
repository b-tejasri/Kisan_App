import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── Section Label ───────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: KisanColors.textMid,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── Quick Action Button ──────────────────────────────────────────────────────
class QuickActionBtn extends StatelessWidget {
  final QuickAction action;
  final VoidCallback? onTap;
  const QuickActionBtn({super.key, required this.action, this.onTap});

  Color get bgColor {
    switch (action.colorTag) {
      case 'gold': return KisanColors.sunPale;
      case 'blue': return KisanColors.skyPale;
      case 'red':  return const Color(0xFFFFE8E8);
      default:     return KisanColors.leafPale;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KisanColors.border, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(action.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.textDark),
              ),
            ],
          ),
        ),
      );
}

// ─── Crop Health Card ─────────────────────────────────────────────────────────
class CropHealthCard extends StatelessWidget {
  const CropHealthCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KisanColors.leaf, KisanColors.leafDeep],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT CROP', style: GoogleFonts.nunito(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text('🌾 Paddy Rice – Stage 3', style: GoogleFonts.lora(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('78', style: GoogleFonts.lora(fontSize: 36, color: KisanColors.leafLight, fontWeight: FontWeight.w700, height: 1)),
                    Text('/ 100 Health', style: GoogleFonts.nunito(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              percent: 0.78,
              lineHeight: 6,
              backgroundColor: Colors.white24,
              progressColor: KisanColors.leafLight,
              barRadius: const Radius.circular(8),
              padding: EdgeInsets.zero,
              trailing: Container(
                width: 12, height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: KisanColors.leafLight, blurRadius: 6)],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Day 42', 'Growth'),
                _stat('✅ Good', 'Disease'),
                _stat('~18d', 'Harvest'),
                _stat('2.8T', 'Yield'),
              ],
            ),
          ],
        ),
      );

  Widget _stat(String val, String key) => Column(
        children: [
          Text(val, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(key, style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white54)),
        ],
      );
}

// ─── Alert Card ───────────────────────────────────────────────────────────────
class AlertCard extends StatelessWidget {
  final FarmAlert alert;
  const AlertCard({super.key, required this.alert});

  List<Color> get gradientColors {
    switch (alert.level) {
      case AlertLevel.red:    return [const Color(0xFFE63946), const Color(0xFFC1121F)];
      case AlertLevel.yellow: return [const Color(0xFFF4A226), const Color(0xFFD4830A)];
      case AlertLevel.green:  return [KisanColors.leafMid, KisanColors.leaf];
      case AlertLevel.blue:   return [const Color(0xFF48CAE4), const Color(0xFF0096C7)];
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 22),
                Text(alert.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 6),
                Text(alert.title, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text(alert.description, style: GoogleFonts.nunito(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600, height: 1.4)),
              ],
            ),
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text(alert.badge, style: GoogleFonts.nunito(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
}

// ─── Market Row ───────────────────────────────────────────────────────────────
class MarketRow extends StatelessWidget {
  final MarketPrice price;
  const MarketRow({super.key, required this.price});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: KisanColors.cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(price.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(price.cropName, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
                  Text(price.unit, style: GoogleFonts.nunito(fontSize: 9, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${price.price.toStringAsFixed(0)}',
                    style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.w700, color: KisanColors.leaf)),
                Text(
                  price.isUp ? '▲ +₹${price.change.abs().toStringAsFixed(0)}' : '▼ -₹${price.change.abs().toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: price.isUp ? const Color(0xFF22C55E) : KisanColors.alertRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

// ─── Forecast Day Chip ────────────────────────────────────────────────────────
class ForecastChip extends StatelessWidget {
  final ForecastDay day;
  final bool isSelected;
  const ForecastChip({super.key, required this.day, this.isSelected = false});

  Color get riskColor {
    switch (day.risk) {
      case DiseaseRisk.low:    return KisanColors.leafPale;
      case DiseaseRisk.medium: return KisanColors.sunPale;
      case DiseaseRisk.high:   return const Color(0xFFFFE0E0);
    }
  }

  Color get riskTextColor {
    switch (day.risk) {
      case DiseaseRisk.low:    return KisanColors.leaf;
      case DiseaseRisk.medium: return const Color(0xFFA06800);
      case DiseaseRisk.high:   return KisanColors.alertRed;
    }
  }

  String get riskLabel {
    switch (day.risk) {
      case DiseaseRisk.low:    return 'Low';
      case DiseaseRisk.medium: return 'Mid';
      case DiseaseRisk.high:   return 'High';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? KisanColors.leafPale : KisanColors.cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? KisanColors.leafMid : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(day.dayName, style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w700, color: isSelected ? KisanColors.leaf : KisanColors.textLight)),
            const SizedBox(height: 4),
            Text(day.weatherEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text('${day.tempC}°', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: riskColor, borderRadius: BorderRadius.circular(5)),
              child: Text(riskLabel, style: GoogleFonts.nunito(fontSize: 7, fontWeight: FontWeight.w800, color: riskTextColor)),
            ),
          ],
        ),
      );
}

// ─── Govt Scheme Card ─────────────────────────────────────────────────────────
class GovtSchemeCard extends StatelessWidget {
  final GovtScheme scheme;
  const GovtSchemeCard({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3B1F0A), Color(0xFF6B3F1A)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(scheme.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scheme.tag, style: GoogleFonts.nunito(fontSize: 9, color: KisanColors.soilLight, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        Text(scheme.title, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)),
                        Text(scheme.description, style: GoogleFonts.nunito(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                ],
              ),
            ),
          ),
        ),
      );
}

// ─── White Card Container ─────────────────────────────────────────────────────
class KisanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const KisanCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: KisanColors.border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: child,
      );
}
