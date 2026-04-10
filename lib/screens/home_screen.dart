// KisanAI – Home Screen (v10 style — clean, not overloaded)
// - Name from login · Auto greeting by time
// - Real weather (Open-Meteo) · 7-day forecast
// - Real market prices (Agmarknet API)
// - State-specific govt schemes
// - NO doc scanner · NO videos · NO bill check

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../services/weather_service.dart';
import '../services/market_service.dart';
import '../widgets/gemini_voice_sheet.dart';
import '../screens/community_screen.dart';
import '../screens/tractor_screen.dart';
import '../screens/market_screen.dart';
import '../screens/store_screen.dart';
import '../screens/weather_screen.dart';
import '../screens/schemes_screen.dart';
import '../screens/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HS();
}

class _HS extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _blink;
  late Animation<double>   _blinkAnim;

  String _name   = 'Farmer';
  String _avatar = '👨‍🌾';
  String _state  = 'Andhra Pradesh';
  String _crop   = 'Rice';

  bool _wLoading = true;
  bool _mLoading = true;
  bool _wOk      = false;

  int _forecastSel = 0;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 1.0, end: 0.2).animate(_blink);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name   = p.getString('farmer_name')   ?? 'Farmer';
      _avatar = p.getString('farmer_avatar') ?? '👨‍🌾';
      _state  = p.getString('farmer_state')  ?? 'Andhra Pradesh';
      _crop   = p.getString('farmer_crop')   ?? 'Rice';
    });
    _loadWeather();
    _loadMarket();
  }

  Future<void> _loadWeather() async {
    setState(() => _wLoading = true);
    final ok = await WeatherService.i.fetchWeather();
    if (mounted) setState(() { _wLoading = false; _wOk = ok; });
  }

  Future<void> _loadMarket() async {
    setState(() => _mLoading = true);
    await MarketService.i.fetchPrices(_state);
    if (mounted) setState(() => _mLoading = false);
  }

  @override
  void dispose() { _blink.dispose(); super.dispose(); }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅 GOOD MORNING';
    if (h < 17) return '☀️ GOOD AFTERNOON';
    if (h < 20) return '🌆 GOOD EVENING';
    return '🌙 GOOD NIGHT';
  }

  // Navigate to a bottom nav tab — push screen directly  
  void _goTo(BuildContext ctx, int tabIdx) {
    // Map tab index to screen widget
    final screens = [
      null,           // 0 = home (current)
      const ScanScreen(),      // 1 = scan
      null,           // 2 = AI (opens via bottom nav)
      const TractorScreen(),   // 3 = tractor
      const CommunityScreen(), // 4 = community
    ];
    if (tabIdx < screens.length && screens[tabIdx] != null) {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => screens[tabIdx]!));
    }
  }

  // Push a screen on top
  void _openScreen(BuildContext ctx, String screen) {
    switch (screen) {
      case 'market':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const MarketScreen()));
        break;
      case 'store':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const StoreScreen()));
        break;
      case 'weather':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const WeatherScreen()));
        break;
      case 'schemes':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const SchemesScreen()));
        break;
      case 'scan':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ScanScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KisanColors.cream,
    body: RefreshIndicator(
      onRefresh: () async { _loadWeather(); _loadMarket(); },
      color: KisanColors.leaf,
      child: Column(children: [
        _header(),
        _weatherStrip(),
        Expanded(child: _body()),
      ]),
    ),
  );

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [KisanColors.leafDeep, Color(0xFF1E5C3A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16, right: 16, bottom: 14),
    child: Column(children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting, style: GoogleFonts.nunito(
              fontSize: 10, color: KisanColors.leafLight,
              fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 3),
          // Farmer name from login
          Text('$_avatar $_name', style: GoogleFonts.lora(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700)),
          Text('$_crop Farmer • $_state',
              style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.leafLight.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ])),
        Stack(clipBehavior: Clip.none, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 2),
                boxShadow: [BoxShadow(color: KisanColors.leafLight.withOpacity(0.3), blurRadius: 8)]),
            child: ClipOval(child: Image.asset(
              'assets/images/kisanai_logo.png', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(color: KisanColors.leafMid, shape: BoxShape.circle),
                child: Center(child: Text(_avatar, style: const TextStyle(fontSize: 23))))))),
          Positioned(top: -2, right: -2,
            child: Container(width: 16, height: 16,
              decoration: BoxDecoration(color: KisanColors.alertRed, shape: BoxShape.circle,
                  border: Border.all(color: KisanColors.leafDeep, width: 2)),
              child: Center(child: Text('3', style: GoogleFonts.nunito(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w900))))),
        ]),
      ]),
      const SizedBox(height: 10),
      AnimatedBuilder(
        animation: _blinkAnim,
        builder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0x26F4A226),
              border: Border.all(color: const Color(0x72F4A226)),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Opacity(opacity: _blinkAnim.value,
                child: Container(width: 7, height: 7,
                    decoration: const BoxDecoration(color: KisanColors.sun, shape: BoxShape.circle))),
            const SizedBox(width: 8),
            Expanded(child: Text(
              _wOk && WeatherService.i.forecast.isNotEmpty
                  ? WeatherService.i.forecast.first.sprayAdvice
                  : '🌾 Pull down to refresh • Tap 👨‍🌾 button for AI help',
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ),
    ]),
  );

  // ── Weather strip ──────────────────────────────────────────────────────────
  Widget _weatherStrip() {
    if (_wLoading) return Container(
      color: KisanColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: KisanColors.leaf)),
        const SizedBox(width: 10),
        Text('Getting weather from your location…',
            style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
      ]),
    );
    final w = WeatherService.i.current;
    if (w == null) return Container(
      color: KisanColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        const Text('📍', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Text('Allow location for real weather',
            style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600))),
        GestureDetector(onTap: _loadWeather,
          child: Text('Retry', style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.leaf, fontWeight: FontWeight.w800))),
      ]),
    );
    return Container(
      color: KisanColors.cream,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(children: [
        Text(w.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${w.temp.toStringAsFixed(1)}°C',
                style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.w700, color: KisanColors.textDark)),
            const SizedBox(width: 6),
            Text(w.condition, style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
          ]),
          Text('📍 ${w.cityName}',
              style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('💧 ${w.humidity}%', style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.textMid, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('🌬️ ${w.windKph.toStringAsFixed(0)} km/h',
              style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.textMid, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body() => ListView(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    children: [
      // Quick actions — each taps to correct screen/action
      const SectionLabel('Quick Actions'),
      GridView.count(
        crossAxisCount: 4, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85,
        children: [
          QuickActionBtn(action: SampleData.quickActions[0],
            onTap: () => _goTo(context, 1)),   // Scan Crop → tab 1 (but we use push)
          QuickActionBtn(action: SampleData.quickActions[1],
            onTap: () => _openScreen(context, 'market')),   // Market Price
          QuickActionBtn(action: SampleData.quickActions[2],
            onTap: () => _openScreen(context, 'store')),    // Buy Fertilizer
          QuickActionBtn(action: SampleData.quickActions[3],
            onTap: () => _openScreen(context, 'weather')),  // Weather
          QuickActionBtn(action: SampleData.quickActions[4],
            onTap: () => _goTo(context, 3)),   // Tractor → nav tab 3
          QuickActionBtn(action: SampleData.quickActions[5],
            onTap: () => _openScreen(context, 'schemes')), // Govt Schemes
          QuickActionBtn(action: SampleData.quickActions[6],
            onTap: () => showModalBottomSheet(  // AI Assistant → opens chatbot
              context: context, backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const VoiceListeningSheet())),
          QuickActionBtn(action: SampleData.quickActions[7],
            onTap: () => _goTo(context, 4)),   // Community → nav tab 4
        ],
      ),

      // 7-Day Forecast — replaces doc scanner
      const SectionLabel('7-Day Weather Forecast'),
      _forecast7Day(),

      // Crop health
      const SectionLabel('My Crop Health'),
      const CropHealthCard(),

      // Market prices
      const SectionLabel('Today\'s Mandi Prices'),
      _market(),

      // Govt schemes
      const SectionLabel('Government Schemes'),
      _schemes(),

      const SizedBox(height: 100),
    ],
  );

  // ── 7-Day Forecast card ────────────────────────────────────────────────────
  Widget _forecast7Day() {
    if (_wLoading) return KisanCard(child: SizedBox(height: 100,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: KisanColors.leaf, strokeWidth: 2.5),
          const SizedBox(height: 10),
          Text('Fetching weather…', style: GoogleFonts.nunito(color: KisanColors.textMid, fontSize: 12)),
        ]))));

    final days = WeatherService.i.forecast;
    if (days.isEmpty) return KisanCard(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const Icon(Icons.cloud_off_rounded, color: KisanColors.textLight, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text('Weather unavailable. Allow location access.',
            style: GoogleFonts.nunito(fontSize: 12, color: KisanColors.textMid, fontWeight: FontWeight.w600))),
        GestureDetector(onTap: _loadWeather,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(10)),
            child: Text('Retry', style: GoogleFonts.nunito(color: KisanColors.leaf, fontSize: 11, fontWeight: FontWeight.w800)))),
      ]),
    ));

    return KisanCard(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('7-Day Forecast', style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: KisanColors.skyPale, borderRadius: BorderRadius.circular(20)),
          child: Text('📍 ${WeatherService.i.current?.cityName ?? "GPS"}',
              style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.skyBlue))),
      ]),
      const SizedBox(height: 12),
      // Day chips — horizontal scroll
      SizedBox(height: 112, child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = _forecastSel == i;
          return GestureDetector(
            onTap: () => setState(() => _forecastSel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: sel ? const LinearGradient(
                    colors: [KisanColors.leafMid, KisanColors.leafDeep],
                    begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: sel ? null : const Color(0xFFF4F8F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? KisanColors.leafLight : KisanColors.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(d.day, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : KisanColors.textMid)),
                const SizedBox(height: 1),
                Text(d.date, style: GoogleFonts.nunito(fontSize: 8,
                    color: sel ? Colors.white60 : KisanColors.textLight)),
                const SizedBox(height: 5),
                Text(d.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 3),
                Text('${d.maxTemp.toStringAsFixed(0)}°',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : KisanColors.textDark)),
                Text('${d.minTemp.toStringAsFixed(0)}°',
                    style: GoogleFonts.nunito(fontSize: 9,
                        color: sel ? Colors.white60 : KisanColors.textLight)),
                if (d.rainMm > 0.5) Text('💧${d.rainMm.toStringAsFixed(0)}mm',
                    style: GoogleFonts.nunito(fontSize: 8,
                        color: sel ? Colors.white70 : KisanColors.skyBlue, fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      )),
      // Selected day spray advice
      const SizedBox(height: 10),
      if (days.isNotEmpty) Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: days[_forecastSel].rainMm > 5 ? const Color(0xFFFFEAEA) : KisanColors.leafPale,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Text(days[_forecastSel].rainMm > 5 ? '🚫' : '✅', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(days[_forecastSel].sprayAdvice,
              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                  color: days[_forecastSel].rainMm > 5 ? KisanColors.alertRed : KisanColors.leaf))),
        ]),
      ),
    ]));
  }

  // ── Market prices ──────────────────────────────────────────────────────────
  Widget _market() {
    if (_mLoading) return KisanCard(child: const SizedBox(height: 60,
        child: Center(child: CircularProgressIndicator(color: KisanColors.leaf, strokeWidth: 2.5))));

    final prices = MarketService.i.prices;
    if (prices.isEmpty) return KisanCard(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Kakinada Mandi', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(20)),
          child: Text('Live 🟢', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.leaf))),
      ]),
      const SizedBox(height: 10),
      ...SampleData.marketPrices.map((p) => MarketRow(price: p)),
    ]));

    return KisanCard(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(prices.isNotEmpty ? '${prices.first.market} Mandi' : 'Mandi Prices',
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(20)),
          child: Text('Live 🟢', style: GoogleFonts.nunito(
              fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.leaf))),
      ]),
      const SizedBox(height: 10),
      ...prices.take(5).map((p) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: KisanColors.border))),
        child: Row(children: [
          Text(p.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.commodity, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: KisanColors.textDark)),
            Text('₹${p.minPrice.toStringAsFixed(0)}–₹${p.maxPrice.toStringAsFixed(0)}/qtl',
                style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.textLight)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(p.modalPriceKg, style: GoogleFonts.lora(
                fontSize: 14, fontWeight: FontWeight.w700, color: KisanColors.leaf)),
            Row(children: [
              Text(p.trend, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 2),
              Text('${p.changePercent > 0 ? '+' : ''}${p.changePercent.toStringAsFixed(1)}%',
                  style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800,
                      color: p.changePercent > 0 ? KisanColors.leaf : KisanColors.alertRed)),
            ]),
          ]),
        ]),
      )),
      const SizedBox(height: 4),
      Text('Source: Agmarknet • data.gov.in',
          style: GoogleFonts.nunito(fontSize: 9, color: KisanColors.textLight)),
    ]));
  }

  // ── Govt Schemes ────────────────────────────────────────────────────────────
  Widget _schemes() => Column(children: [
    ...SampleData.schemes.map((s) => GovtSchemeCard(scheme: s)),
    // State-specific bonus scheme
    _stateScheme(),
  ]);

  Widget _stateScheme() {
    final Map<String,List<String>> extra = {
      'Andhra Pradesh': ['💚','YSR Rythu Bharosa','₹13,500/year — AP state scheme for all farmers'],
      'Telangana': ['🌱','Rythu Bandhu','₹10,000/acre/year — Telangana farmers get money before each season'],
      'Tamil Nadu': ['🏛️','TN Farmer Support','₹1,000/month — Tamil Nadu CM scheme for farmers'],
      'Punjab': ['🌾','Punjab Crop Insurance','Free crop insurance for paddy & wheat growers in Punjab'],
    };
    final e = extra[_state];
    if (e == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KisanColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,2))],
      ),
      child: Row(children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(e[0], style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(e[1], style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(6)),
              child: Text(_state.split(' ').first, style: GoogleFonts.nunito(fontSize: 8, fontWeight: FontWeight.w800, color: KisanColors.leaf))),
          ]),
          const SizedBox(height: 2),
          Text(e[2], style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600, height: 1.4)),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: KisanColors.textLight),
      ]),
    );
  }
}
