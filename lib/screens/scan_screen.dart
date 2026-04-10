// KisanAI – AI Crop Disease Scanner
// PhonePe-style animated scanner UI
// Point camera at leaf → AI detects disease instantly

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/disease_detector.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _SS();
}

class _SS extends State<ScanScreen> with TickerProviderStateMixin {
  final _picker  = ImagePicker();
  Uint8List? _img;
  bool  _scanning = false;
  List<DiseaseResult>? _results;

  // PhonePe-style scan line animation
  late AnimationController _lineCtrl;
  late Animation<double>   _lineAnim;

  // Corner pulse animation
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _pulseCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final xf = await _picker.pickImage(
          source: src, imageQuality: 92, maxWidth: 1024);
      if (xf == null) return;
      final bytes = await xf.readAsBytes();
      setState(() { _img = bytes; _results = null; _scanning = true; });
      final res = await diseaseDetector.predict(bytes);
      setState(() { _results = res; _scanning = false; });
      await Future.delayed(const Duration(milliseconds: 300));
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
      }
    } catch (e) {
      setState(() => _scanning = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: KisanColors.alertRed));
    }
  }

  void _reset() => setState(() { _img = null; _results = null; _scanning = false; });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A1A0F),
    body: CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(child: Column(children: [
          _topBar(),
          _scannerArea(),
          _buttons(),
          if (_scanning) _thinkingBar(),
          if (_results != null) _resultSection(),
          const SizedBox(height: 100),
        ])),
      ],
    ),
  );

  // ── Top bar ─────────────────────────────────────────────────────────────────
  Widget _topBar() => Container(
    color: const Color(0xFF0A1A0F),
    padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 12),
    child: Row(children: [
      // App logo small
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: KisanColors.leafMid.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: KisanColors.leafLight.withOpacity(0.4)),
        ),
        child: ClipOval(child: Image.asset(
          'assets/images/kisanai_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
              child: Text('🌿', style: TextStyle(fontSize: 18))),
        )),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('KisanAI Scanner',
            style: GoogleFonts.lora(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        Text('Point camera at crop leaf', style: GoogleFonts.nunito(
            color: KisanColors.leafLight, fontSize: 11, fontWeight: FontWeight.w600)),
      ])),
      if (_img != null)
        GestureDetector(
          onTap: _reset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: KisanColors.leafMid.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KisanColors.leafMid)),
            child: Text('New Scan', style: GoogleFonts.nunito(
                color: KisanColors.leafLight, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
    ]),
  );

  // ── PhonePe-style scanner area ───────────────────────────────────────────────
  Widget _scannerArea() {
    final size = MediaQuery.of(context).size.width - 40;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      width: size, height: size,
      child: Stack(fit: StackFit.expand, children: [
        // Image or dark background
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _img != null
              ? Image.memory(_img!, fit: BoxFit.cover)
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2A0F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🌿', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text('Point camera at\na crop leaf',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
        ),

        // Dark overlay when no image
        if (_img == null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.3)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),

        // PhonePe-style corner brackets
        ..._corners(size),

        // Animated scan line (PhonePe style)
        if (!_scanning && _img == null)
          AnimatedBuilder(
            animation: _lineAnim,
            builder: (_, __) {
              final top = (size - 40) * _lineAnim.value + 20;
              return Positioned(
                top: top, left: 20, right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        KisanColors.leafLight.withOpacity(0.8),
                        KisanColors.leafLight,
                        KisanColors.leafLight.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: KisanColors.leafLight.withOpacity(0.6),
                          blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
              );
            },
          ),

        // Scanning overlay
        if (_scanning)
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(
                  color: KisanColors.leafLight, strokeWidth: 3),
              const SizedBox(height: 16),
              Text('AI Scanning…',
                  style: GoogleFonts.lora(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Checking 30+ diseases',
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
            ]),
          ),

        // Result badge on image
        if (_results != null && _img != null)
          Positioned(
            bottom: 12, left: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _results!.first.isHealthy
                    ? KisanColors.leaf.withOpacity(0.92)
                    : KisanColors.alertRed.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Text(_results!.first.isHealthy ? '✅' : '🦠',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_results!.first.disease,
                      style: GoogleFonts.lora(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('${_results!.first.crop} • ${_results!.first.confidencePercent} confident',
                      style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          ),
      ]),
    );
  }

  // PhonePe-style animated corner brackets
  List<Widget> _corners(double size) {
    const len = 28.0;
    const thickness = 3.5;
    const radius = 14.0;
    final color = KisanColors.leafLight;

    return [
      // Top-left
      Positioned(top: 0, left: 0, child: _cornerBracket(color, len, thickness, radius, true, true)),
      // Top-right
      Positioned(top: 0, right: 0, child: _cornerBracket(color, len, thickness, radius, true, false)),
      // Bottom-left
      Positioned(bottom: 0, left: 0, child: _cornerBracket(color, len, thickness, radius, false, true)),
      // Bottom-right
      Positioned(bottom: 0, right: 0, child: _cornerBracket(color, len, thickness, radius, false, false)),
    ];
  }

  Widget _cornerBracket(Color color, double len, double thick, double r,
      bool top, bool left) => AnimatedBuilder(
    animation: _pulseAnim,
    builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
    child: SizedBox(
      width: len + r, height: len + r,
      child: CustomPaint(painter: _CornerPainter(color, len, thick, r, top, left)),
    ),
  );

  // ── Action buttons ──────────────────────────────────────────────────────────
  Widget _buttons() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Row(children: [
      if (!kIsWeb) ...[
        Expanded(child: _btn('📷', 'Camera', KisanColors.leafMid,
            () => _pick(ImageSource.camera))),
        const SizedBox(width: 12),
      ],
      Expanded(child: _btn('🖼️', 'Gallery', const Color(0xFF2D5016),
          () => _pick(ImageSource.gallery))),
    ]),
  );

  Widget _btn(String emoji, String label, Color color, VoidCallback fn) =>
      GestureDetector(
        onTap: fn,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.nunito(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
          ])),
        ),
      );

  // ── Thinking bar ────────────────────────────────────────────────────────────
  Widget _thinkingBar() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: const Color(0xFF163020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KisanColors.leafMid.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(color: KisanColors.leafLight, strokeWidth: 2.5)),
        const SizedBox(width: 14),
        Expanded(child: Text('Expert AI Scanning Your Crop…',
            style: GoogleFonts.lora(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 12),
      _scanStep('🔍', 'Identifying crop species from leaf shape & texture'),
      const SizedBox(height: 6),
      _scanStep('🦠', 'Detecting disease, lesion pattern & spread area'),
      const SizedBox(height: 6),
      _scanStep('💊', 'Generating exact treatment with doses'),
      const SizedBox(height: 10),
      Text('Using Groq Vision AI • PhD-level pathology model',
          style: GoogleFonts.nunito(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _scanStep(String emoji, String text) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: GoogleFonts.nunito(
        color: KisanColors.leafLight, fontSize: 11, fontWeight: FontWeight.w600))),
  ]);

  // ── Results ─────────────────────────────────────────────────────────────────
  Widget _resultSection() {
    final top = _results!.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('DISEASE DETECTION RESULT'),
        _topResultCard(top),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _reset,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: KisanColors.leafMid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.camera_alt_rounded, color: KisanColors.leafLight, size: 18),
              const SizedBox(width: 8),
              Text('Scan Another Crop', style: GoogleFonts.nunito(
                  color: KisanColors.leafLight, fontSize: 13, fontWeight: FontWeight.w800)),
            ])),
          ),
        ),
        if (!top.isHealthy) ...[
          _label('TREATMENT PLAN'),
          _treatCard(top),
          _label('FERTILIZER RECOMMENDATIONS'),
          _fertSection(top.fertilizers),
        ],
        if (top.isHealthy) ...[
          _label('RECOMMENDED FERTILIZERS'),
          _fertSection(top.fertilizers),
        ],
        if (_results!.length > 1) ...[
          _label('OTHER POSSIBILITIES'),
          ..._results!.skip(1).map(_altCard),
        ],
      ]),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(t, style: GoogleFonts.nunito(
        fontSize: 10, fontWeight: FontWeight.w900,
        color: KisanColors.leafLight, letterSpacing: 1.2)),
  );

  Widget _topResultCard(DiseaseResult r) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF163020),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: r.isHealthy
          ? KisanColors.leafLight.withOpacity(0.4)
          : KisanColors.alertRed.withOpacity(0.5), width: 1.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: r.isHealthy
                ? KisanColors.leafMid.withOpacity(0.25)
                : KisanColors.alertRed.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(r.isHealthy ? '✅' : '🦠',
              style: const TextStyle(fontSize: 30))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.disease, style: GoogleFonts.lora(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: r.isHealthy ? KisanColors.leafLight : KisanColors.alertRed)),
          Text(r.crop, style: GoogleFonts.nunito(
              fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: [
            _chip('${r.severityEmoji} ${r.severity}',
                r.isHealthy ? KisanColors.leafMid.withOpacity(0.3) : KisanColors.alertRed.withOpacity(0.2),
                r.isHealthy ? KisanColors.leafLight : KisanColors.alertRed),
            _chip('🎯 ${r.confidencePercent}',
                KisanColors.leafMid.withOpacity(0.3), KisanColors.leafLight),
          ]),
        ])),
      ]),
      const Divider(color: Colors.white12, height: 20),
      Text('Symptoms', style: GoogleFonts.nunito(
          fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 0.6)),
      const SizedBox(height: 4),
      Text(r.symptoms, style: GoogleFonts.nunito(
          fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600, height: 1.5)),
    ]),
  );

  Widget _chip(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
  );

  Widget _treatCard(DiseaseResult r) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: const Color(0xFF163020),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12)),
    child: Column(children: [
      _treatRow('🌿', 'Organic Treatment', r.organicTreatment, const Color(0xFF163020)),
      const SizedBox(height: 10),
      _treatRow('🧪', 'Chemical Treatment', r.chemicalTreatment, const Color(0xFF0D1F3A)),
      const SizedBox(height: 10),
      _treatRow('🛡️', 'Prevention', r.prevention, const Color(0xFF1A1A0A)),
    ]),
  );

  Widget _treatRow(String emoji, String title, String detail, Color bg) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(detail, style: GoogleFonts.nunito(
                fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600, height: 1.45)),
          ])),
        ]),
      );

  Widget _fertSection(List<FertilizerRec> list) {
    final org = list.where((f) => f.type == 'Organic').toList();
    final chem = list.where((f) => f.type == 'Chemical').toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF163020),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (org.isNotEmpty) ...[
          Row(children: [
            const Text('🌱', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('ORGANIC', style: GoogleFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w900, color: KisanColors.leafLight, letterSpacing: 1)),
          ]),
          const SizedBox(height: 8),
          ...org.map(_fertCard),
        ],
        if (chem.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Text('🧪', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('CHEMICAL', style: GoogleFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF7BAFD4), letterSpacing: 1)),
          ]),
          const SizedBox(height: 8),
          ...chem.map(_fertCard),
        ],
      ]),
    );
  }

  Widget _fertCard(FertilizerRec f) {
    final isOrg = f.type == 'Organic';
    final color = isOrg ? KisanColors.leafLight : const Color(0xFF7BAFD4);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(f.name, style: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w800, color: color))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('₹${f.pricePerKg}/kg', style: GoogleFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w800, color: color)),
          ),
        ]),
        const SizedBox(height: 6),
        _infoRow('💊', f.dose, color),
        _infoRow('⏰', f.timing, color),
        _infoRow('✨', f.benefit, color),
      ]),
    );
  }

  Widget _infoRow(String icon, String text, Color color) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: GoogleFonts.nunito(
          fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600, height: 1.4))),
    ]),
  );

  Widget _altCard(DiseaseResult r) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
        color: const Color(0xFF163020),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12)),
    child: Row(children: [
      Text(r.severityEmoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.disease, style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
        Text(r.crop, style: GoogleFonts.nunito(
            fontSize: 11, color: Colors.white38)),
      ])),
      Text(r.confidencePercent, style: GoogleFonts.nunito(
          fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ── Custom corner bracket painter (PhonePe style) ─────────────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  final double len, thick, radius;
  final bool top, left;

  const _CornerPainter(this.color, this.len, this.thick, this.radius, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x = left ? radius : size.width - radius;
    final double y = top  ? radius : size.height - radius;

    // Horizontal arm
    final hx1 = left ? x : x - len;
    final hx2 = left ? x + len : x;
    canvas.drawLine(Offset(hx1, y), Offset(hx2, y), paint);

    // Vertical arm
    final vy1 = top ? y : y - len;
    final vy2 = top ? y + len : y;
    canvas.drawLine(Offset(x, vy1), Offset(x, vy2), paint);

    // Corner arc
    final rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
    double startAngle;
    if (top && left)   startAngle = 3.14159; // 180°
    else if (top)      startAngle = 4.71239; // 270°
    else if (left)     startAngle = 1.5708;  // 90°
    else               startAngle = 0;       // 0°
    canvas.drawArc(rect, startAngle, 1.5708, false, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
