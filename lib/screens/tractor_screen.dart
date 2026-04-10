// KisanAI – Tractor & Equipment Rental Screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TractorScreen extends StatelessWidget {
  const TractorScreen({super.key});

  static const _equips = [
    {'e':'🚜','n':'Tractor','r':'₹800/hr','o':'రాజు రెడ్డి','p':'9876543210','d':'Guntur','a':true},
    {'e':'🌾','n':'Harvester','r':'₹2500/acre','o':'వెంకట్','p':'9123456780','d':'Krishna','a':true},
    {'e':'💧','n':'Power Sprayer','r':'₹200/hr','o':'సురేష్','p':'9988776655','d':'Prakasam','a':false},
    {'e':'🔧','n':'Rotavator','r':'₹600/hr','o':'రమేష్','p':'9845123456','d':'Nellore','a':true},
    {'e':'🌱','n':'Seed Drill','r':'₹400/acre','o':'కృష్ణ','p':'9756231489','d':'West Godavari','a':false},
    {'e':'💦','n':'Water Pump','r':'₹150/hr','o':'లక్ష్మి','p':'9671234567','d':'East Godavari','a':true},
    {'e':'🚛','n':'Mini Truck','r':'₹1200/trip','o':'అనిల్','p':'9845678901','d':'Guntur','a':true},
    {'e':'✂️','n':'Crop Cutter','r':'₹350/hr','o':'మహేష్','p':'9912345678','d':'Krishna','a':true},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KisanColors.cream,
    appBar: AppBar(
      backgroundColor: KisanColors.leafDeep,
      title: Row(children: [
        const Text('🚜', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Text('Equipment Rental', style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
      actions: [
        TextButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('📋 List your equipment coming soon!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              backgroundColor: KisanColors.leaf, behavior: SnackBarBehavior.floating)),
          icon: const Icon(Icons.add, color: KisanColors.sun, size: 18),
          label: Text('List Mine', style: GoogleFonts.nunito(color: KisanColors.sun, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
    body: ListView(padding: const EdgeInsets.all(14), children: [
      Container(
        padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [KisanColors.leafDeep, KisanColors.leaf]),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Text('🚜', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rent Equipment Near You', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('Call directly • Available 24/7 • Best rates', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
          ])),
        ])),
      ..._equips.map((e) => _card(context, e)),
      const SizedBox(height: 80),
    ]),
  );

  Widget _card(BuildContext ctx, Map e) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,2))]),
    child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 60, height: 60,
          decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(e['e'] as String, style: const TextStyle(fontSize: 32)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(e['n'] as String, style: GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.w700, color: KisanColors.textDark)),
          const SizedBox(width: 6),
          if (e['a'] as bool) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(6)),
            child: Text('✅ Available', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.leaf))),
        ]),
        Text(e['r'] as String, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: KisanColors.leaf)),
        Text('👤 ${e['o']}  📍 ${e['d']}', style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('📞 Calling ${e['o']}: ${e['p']}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            backgroundColor: KisanColors.leaf, behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep]), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('📞', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Call Now', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ]))),
      ])),
    ])),
  );
}
