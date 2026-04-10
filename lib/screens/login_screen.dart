// KisanAI – Login Screen
// Step 1: Enter name + phone + select avatar/crop/state
// Step 2: OTP verification (simulated — real SMS can be plugged in)
// Step 3: Enter home screen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SampleData {
  static List<int> marketPrices = [1200, 1400, 1350];
}

class MarketRow extends StatelessWidget {
  final int price;
  const MarketRow({required this.price});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Price: ₹$price'),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class KisanCard extends StatelessWidget {
  final Widget child;

  const KisanCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LS();
}

class _LS extends State<LoginScreen> with TickerProviderStateMixin {
  int    _step    = 0;  // 0=welcome, 1=details, 2=otp
  bool   _loading = false;

  // Step 1 fields
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _avatar = '👨‍🌾';
  String _crop   = 'Rice';
  String _state  = 'Andhra Pradesh';

  // Step 2 OTP
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  Timer? _resendTimer;
  String _demoOtp = ''; // shown to user for demo

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _avatars = ['👨‍🌾','👩‍🌾','🧑‍🌾','👴','👵','🧔','👱','🧕'];
  static const _crops = ['Rice','Tomato','Chilli','Groundnut','Cotton',
      'Maize','Red Gram','Green Gram','Onion','Sugarcane','Wheat','Potato'];
  static const _states = ['Andhra Pradesh','Telangana','Tamil Nadu',
      'Karnataka','Maharashtra','Punjab','Uttar Pradesh','Bihar',
      'West Bengal','Rajasthan','Gujarat','Madhya Pradesh'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _resendTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Generate & send OTP ────────────────────────────────────────────────────
  void _sendOtp() {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Please enter your name'); return;
    }
    if (_phoneCtrl.text.trim().length < 10) {
      _snack('Please enter a valid 10-digit mobile number'); return;
    }
    // Generate demo OTP
    _demoOtp = (100000 + DateTime.now().millisecond * 997 % 900000).toString().substring(0, 6);
    setState(() { _step = 2; _resendSeconds = 30; });
    _fadeCtrl.reset(); _fadeCtrl.forward();
    _startResendTimer();
    // In production: call SMS API here with _demoOtp
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) { t.cancel(); return; }
      if (mounted) setState(() => _resendSeconds--);
    });
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final entered = _otpCtrl.map((c) => c.text).join();
    if (entered.length < 6) { _snack('Enter all 6 digits'); return; }
    if (entered != _demoOtp) { _snack('❌ Wrong OTP. Try again.'); return; }
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name',   _nameCtrl.text.trim());
    await prefs.setString('farmer_phone',  _phoneCtrl.text.trim());
    await prefs.setString('farmer_avatar', _avatar);
    await prefs.setString('farmer_crop',   _crop);
    await prefs.setString('farmer_state',  _state);
    await prefs.setBool('is_logged_in',    true);
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
    backgroundColor: KisanColors.alertRed,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2E1A), KisanColors.leafDeep, Color(0xFF2D6A4F)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: _step == 0 ? _welcome(size)
                 : _step == 1 ? _details(size)
                 : _otp(size),
          ),
        ),
      ),
    );
  }

  // ── Step 0: Welcome splash ─────────────────────────────────────────────────
  Widget _welcome(Size size) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Column(children: [
      const SizedBox(height: 20),
      // App logo image
      Container(
        height: size.height * 0.28,
        width: size.height * 0.28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: KisanColors.leafLight.withOpacity(0.3), blurRadius: 30, spreadRadius: 8)],
        ),
        child: ClipOval(
          child: Image.asset('assets/images/kisanai_logo.png', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(color: KisanColors.leafMid, shape: BoxShape.circle),
              child: const Center(child: Text('🌾', style: TextStyle(fontSize: 80))))),
        ),
      ),
      const SizedBox(height: 28),
      Text('KisanAI', style: GoogleFonts.lora(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('మీ స్మార్ట్ వ్యవసాయ సహాయకుడు',
          style: GoogleFonts.nunito(color: KisanColors.leafLight, fontSize: 14, fontWeight: FontWeight.w600)),
      Text('Your Smart Farming Assistant',
          style: GoogleFonts.nunito(color: KisanColors.leafLight.withOpacity(0.7), fontSize: 12)),
      const SizedBox(height: 32),
      // Feature pills
      Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
        children: ['🌾 Crop AI','🎙️ Voice','📊 Market','💰 Schemes','🌦️ Weather','👥 Community']
          .map((f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KisanColors.leafLight.withOpacity(0.25))),
            child: Text(f, style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))).toList()),
      const SizedBox(height: 36),
      _greenBtn('Get Started  →', () {
        setState(() => _step = 1);
        _fadeCtrl.reset(); _fadeCtrl.forward();
      }),
      const SizedBox(height: 14),
      Text('Free • No subscription • Works offline',
          style: GoogleFonts.nunito(color: KisanColors.leafLight.withOpacity(0.6), fontSize: 11)),
    ]),
  );

  // ── Step 1: Details form ───────────────────────────────────────────────────
  Widget _details(Size size) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(children: [
      // Header
      Row(children: [
        GestureDetector(onTap: () { setState(() => _step = 0); _fadeCtrl.reset(); _fadeCtrl.forward(); },
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
        const SizedBox(width: 12),
        Text('Create Profile', style: GoogleFonts.lora(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 20),

      // Avatar strip — farm avatars
      _sectionLabel('Choose Your Avatar'),
      const SizedBox(height: 10),
      SizedBox(height: 72, child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _avatars.length,
        itemBuilder: (_, i) {
          final sel = _avatars[i] == _avatar;
          return GestureDetector(
            onTap: () => setState(() => _avatar = _avatars[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58, height: 58, margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: sel ? KisanColors.leafMid : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: sel ? KisanColors.leafLight : Colors.white24, width: 2.5),
                boxShadow: sel ? [BoxShadow(color: KisanColors.leafLight.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : [],
              ),
              child: Center(child: Text(_avatars[i], style: const TextStyle(fontSize: 28))),
            ),
          );
        },
      )),
      const SizedBox(height: 18),

      // Name
      _sectionLabel('Your Name  మీ పేరు *'),
      const SizedBox(height: 8),
      _glassField(_nameCtrl, 'e.g. రాజు రెడ్డి', Icons.person_outline, false),
      const SizedBox(height: 14),

      // Phone
      _sectionLabel('Mobile Number  మొబైల్ నంబర్ *'),
      const SizedBox(height: 8),
      _glassField(_phoneCtrl, '10-digit mobile number', Icons.phone_outlined, true),
      const SizedBox(height: 4),
      Align(alignment: Alignment.centerLeft,
        child: Text('  OTP will be sent to this number for verification',
          style: GoogleFonts.nunito(color: KisanColors.leafLight.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600))),
      const SizedBox(height: 14),

      // Crop
      _sectionLabel('Main Crop  ముఖ్య పంట'),
      const SizedBox(height: 8),
      _glassDropdown(_crops, _crop, '🌾 ', (v) => setState(() => _crop = v!)),
      const SizedBox(height: 14),

      // State
      _sectionLabel('State  రాష్ట్రం'),
      const SizedBox(height: 8),
      _glassDropdown(_states, _state, '📍 ', (v) => setState(() => _state = v!)),
      const SizedBox(height: 28),

      _greenBtn('Send OTP  →', _sendOtp),
      const SizedBox(height: 16),
    ]),
  );

  // ── Step 2: OTP verification ───────────────────────────────────────────────
  Widget _otp(Size size) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Column(children: [
      Row(children: [
        GestureDetector(onTap: () { setState(() => _step = 1); _fadeCtrl.reset(); _fadeCtrl.forward(); },
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
        const SizedBox(width: 12),
        Text('Verify OTP', style: GoogleFonts.lora(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 36),

      // Lock icon
      Container(width: 80, height: 80,
        decoration: BoxDecoration(color: KisanColors.leafMid.withOpacity(0.25), shape: BoxShape.circle,
            border: Border.all(color: KisanColors.leafLight.withOpacity(0.4), width: 2)),
        child: const Center(child: Text('🔐', style: TextStyle(fontSize: 40)))),
      const SizedBox(height: 20),

      Text('OTP Sent!', style: GoogleFonts.lora(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Enter the 6-digit code sent to',
          style: GoogleFonts.nunito(color: KisanColors.leafLight, fontSize: 13)),
      Text(_phoneCtrl.text.replaceRange(3, 7, '****'),
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      // Demo OTP hint (remove in production with real SMS)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: KisanColors.sun.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: KisanColors.sun.withOpacity(0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔑', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('Demo OTP: $_demoOtp', style: GoogleFonts.nunito(
              color: KisanColors.sun, fontSize: 14, fontWeight: FontWeight.w800)),
        ])),
      const SizedBox(height: 32),

      // 6-box OTP input
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) => Container(
          width: 44, height: 52, margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _otpCtrl[i].text.isNotEmpty
                ? KisanColors.leafLight : Colors.white30, width: 2),
          ),
          child: TextField(
            controller: _otpCtrl[i],
            focusNode: _otpFocus[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.lora(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: InputBorder.none, counterText: '',
                contentPadding: EdgeInsets.zero),
            onChanged: (v) {
              setState(() {});
              if (v.isNotEmpty && i < 5) {
                _otpFocus[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _otpFocus[i - 1].requestFocus();
              }
              // Auto verify when all 6 entered
              if (i == 5 && v.isNotEmpty) _verifyOtp();
            },
          ),
        ))),
      const SizedBox(height: 32),

      _loading
          ? const CircularProgressIndicator(color: KisanColors.leafLight)
          : _greenBtn('Verify & Continue  ✓', _verifyOtp),
      const SizedBox(height: 20),

      // Resend
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Didn't receive? ", style: GoogleFonts.nunito(color: KisanColors.leafLight, fontSize: 13)),
        _resendSeconds > 0
            ? Text('Resend in ${_resendSeconds}s',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w700))
            : GestureDetector(
                onTap: () { for (final c in _otpCtrl) c.clear(); _sendOtp(); },
                child: Text('Resend OTP', style: GoogleFonts.nunito(
                    color: KisanColors.sun, fontSize: 13, fontWeight: FontWeight.w800))),
      ]),
    ]),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t, style: GoogleFonts.nunito(
        color: KisanColors.leafLight, fontSize: 11,
        fontWeight: FontWeight.w800, letterSpacing: 0.4)));

  Widget _glassField(TextEditingController ctrl, String hint, IconData icon, bool isPhone) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.name,
          inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] : null,
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: KisanColors.leafLight, size: 20),
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: Colors.white38, fontSize: 13),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          ),
        ),
      );

  Widget _glassDropdown(List<String> items, String val, String prefix, ValueChanged<String?> fn) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: DropdownButton<String>(
          value: val, isExpanded: true, underline: const SizedBox(),
          dropdownColor: KisanColors.leafDeep,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: KisanColors.leafLight),
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          items: items.map((i) => DropdownMenuItem(value: i,
              child: Text('$prefix$i', style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
          onChanged: fn,
        ),
      );

  Widget _greenBtn(String label, VoidCallback fn) => SizedBox(
    width: double.infinity,
    child: GestureDetector(
      onTap: fn,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: KisanColors.leaf.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Center(child: Text(label, style: GoogleFonts.nunito(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
      ),
    ),
  );
}



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
                   SectionLabel('Nearby Mandis'),
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

