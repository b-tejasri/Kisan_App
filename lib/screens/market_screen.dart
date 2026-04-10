import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _selectedTab = 0;
  final tabs = ['Today', 'This Week', 'Best Time to Sell'];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: KisanColors.cream,
        appBar: AppBar(
          title: const Text('Market Prices'),
          backgroundColor: KisanColors.leafDeep,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: KisanColors.leafDeep,
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: Row(
                children: List.generate(
                  tabs.length,
                  (i) => GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedTab == i ? KisanColors.sun : Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tabs[i],
                          style: GoogleFonts.nunito(
                            fontSize: 11, fontWeight: FontWeight.w800,
                            color: _selectedTab == i ? Colors.white : Colors.white70,
                          )),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // Location
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: KisanColors.sunPale, borderRadius: BorderRadius.circular(14), border: Border.all(color: KisanColors.sun.withOpacity(0.4))),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Kakinada Mandi, Andhra Pradesh', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: KisanColors.soilDark)),
                        const Spacer(),
                        Text('Live 🟢', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: KisanColors.leaf)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sell Now Highlight
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [KisanColors.leaf, KisanColors.leafDeep]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Best Time to Sell Rice', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text('Prices are up ₹180 today — sell within 2 days for max profit', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Prices
                  KisanCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Today\'s Prices', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
                            Text('Updated 30 min ago', style: GoogleFonts.nunito(fontSize: 9, color: KisanColors.textLight, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...SampleData.marketPrices.map((p) => MarketRow(price: p)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nearby mandis
                  const SectionLabel('Nearby Mandis'),
                  ...[
                    ('Kakinada', '2 km', '🟢'),
                    ('Rajahmundry', '48 km', '🟡'),
                    ('Vijayawada', '110 km', '🔴'),
                  ].map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: KisanColors.border),
                        ),
                        child: Row(
                          children: [
                            Text('🏪', style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(m.$1, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: KisanColors.textDark))),
                            Text(m.$2, style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Text(m.$3, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
}
