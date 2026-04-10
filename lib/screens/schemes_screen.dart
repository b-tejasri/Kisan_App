// KisanAI – Government Schemes Screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});
  @override
  State<SchemesScreen> createState() => _SchemeState();
}

class _SchemeState extends State<SchemesScreen> {
  String _state = 'Andhra Pradesh';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _state = p.getString('farmer_state') ?? 'Andhra Pradesh');
  }

  static const _central = [
    {'e':'💰','n':'PM-KISAN Samman Nidhi','b':'₹6,000/year','d':'₹2,000 every 4 months to your bank. Apply at pmkisan.gov.in with Aadhaar + land records.','t':'Central'},
    {'e':'🛡️','n':'PM Fasal Bima Yojana','b':'Full crop coverage','d':'Crop insurance against drought, flood & pest. Premium only 1.5–2%. Apply via bank or Common Service Centre.','t':'Central'},
    {'e':'🏦','n':'Kisan Credit Card (KCC)','b':'₹3 lakh at 4%','d':'Low-interest crop loan. Apply at any bank with land documents. Renew every year.','t':'Central'},
    {'e':'📊','n':'eNAM Online Market','b':'Best crop price','d':'Sell your crop online to buyers across India. Register at enam.gov.in. No middlemen needed.','t':'Central'},
    {'e':'💧','n':'PM Krishi Sinchai Yojana','b':'Free irrigation','d':'Drip & sprinkler irrigation subsidy up to 55% for small farmers. Apply via Agriculture Department.','t':'Central'},
    {'e':'🌱','n':'Soil Health Card Scheme','b':'Free soil testing','d':'Get your soil tested free. Receive card with fertilizer recommendations. Visit nearest Krishi Vigyan Kendra.','t':'Central'},
  ];

  static const _stateSchemes = <String, List<Map<String,String>>>{
    'Andhra Pradesh': [
      {'e':'💚','n':'YSR Rythu Bharosa','b':'₹13,500/year','d':'AP farmers get ₹13,500/year — ₹6,000 central + ₹7,500 state. Auto-credited before each season.','t':'State'},
      {'e':'🔋','n':'YSR Free Power','b':'Free electricity','d':'9 hours free electricity for agricultural connections in Andhra Pradesh.','t':'State'},
    ],
    'Telangana': [
      {'e':'🌾','n':'Rythu Bandhu','b':'₹10,000/acre/year','d':'₹5,000 per acre twice a year before Kharif and Rabi. Direct bank transfer to farmer.','t':'State'},
      {'e':'🌿','n':'Rythu Bima','b':'₹5 lakh life cover','d':'Free life insurance of ₹5 lakh for all Telangana farmers aged 18–59 years.','t':'State'},
    ],
    'Tamil Nadu': [
      {'e':'🏛️','n':'TN Farmer Support','b':'₹1,000/month','d':'Monthly ₹1,000 support to small farmers. Apply at tahsildar office with land documents.','t':'State'},
      {'e':'🌊','n':'TN Drought Relief','b':'Compensation available','d':'Drought and flood relief compensation. Register crop damage within 72 hours of event.','t':'State'},
    ],
    'Karnataka': [
      {'e':'🌻','n':'Raitha Siri Scheme','b':'₹2,000/acre','d':'Karnataka farmers get ₹2,000 per acre per year. Apply at gram panchayat office.','t':'State'},
    ],
    'Maharashtra': [
      {'e':'💸','n':'Namo Shetkari Maha Samman','b':'₹6,000 extra','d':'Maharashtra gives additional ₹6,000 on top of PM-KISAN. Total ₹12,000/year for eligible farmers.','t':'State'},
    ],
    'Punjab': [
      {'e':'🌾','n':'Punjab Free Crop Insurance','b':'Free insurance','d':'State provides free crop insurance for paddy and wheat. Auto-enrolled if you have Kisan Registration.','t':'State'},
    ],
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KisanColors.cream,
    appBar: AppBar(
      backgroundColor: KisanColors.leafDeep,
      title: Row(children: [
        const Text('💰', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Text('Government Schemes', style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // State schemes first
        if (_stateSchemes[_state] != null) ...[
          _header('$_state Schemes 🏛️', KisanColors.leaf),
          ..._stateSchemes[_state]!.map((s) => _card(s)),
          const SizedBox(height: 8),
        ],
        _header('Central Government Schemes 🇮🇳', KisanColors.skyBlue),
        ..._central.map((s) => _card(s)),
        const SizedBox(height: 80),
      ],
    ),
  );

  Widget _header(String t, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Row(children: [
      Container(width: 4, height: 20, color: c, margin: const EdgeInsets.only(right: 8)),
      Text(t, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: KisanColors.textDark, letterSpacing: 0.5)),
    ]),
  );

  Widget _card(Map<String,String> s) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 50, height: 50,
          decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(s['e']!, style: const TextStyle(fontSize: 26)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(s['n']!, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: s['t'] == 'State' ? KisanColors.leafPale : const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(8)),
              child: Text(s['t']!, style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800,
                  color: s['t'] == 'State' ? KisanColors.leaf : KisanColors.skyBlue))),
          ]),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8)),
            child: Text(s['b']!, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF9A6600)))),
          const SizedBox(height: 6),
          Text(s['d']!, style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600, height: 1.4)),
        ])),
      ]),
    ),
  );
}
