// KisanAI – AI Document Scanner
// Uses Gemini Vision to read:
//   📄 Government scheme forms (PM-KISAN, Fasal Bima, KCC)
//   🧾 Fertilizer bills (fraud detection)
//   📸 Seed packet labels
//   🖼️ Any farm document / receipt

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Scan Mode
// ─────────────────────────────────────────────────────────────────────────────
enum _Mode {
  govt,       // Government scheme documents
  bill,       // Fertilizer / pesticide bills
  seed,       // Seed packet labels
  general,    // Any document / receipt
}

extension _ModeX on _Mode {
  String get label {
    switch (this) {
      case _Mode.govt:    return 'Govt Scheme Doc';
      case _Mode.bill:    return 'Fertilizer Bill';
      case _Mode.seed:    return 'Seed Packet';
      case _Mode.general: return 'Any Document';
    }
  }

  String get emoji {
    switch (this) {
      case _Mode.govt:    return '📄';
      case _Mode.bill:    return '🧾';
      case _Mode.seed:    return '🌱';
      case _Mode.general: return '📸';
    }
  }

  Color get color {
    switch (this) {
      case _Mode.govt:    return const Color(0xFF0096C7);
      case _Mode.bill:    return const Color(0xFFF4A226);
      case _Mode.seed:    return KisanColors.leafMid;
      case _Mode.general: return const Color(0xFF6B3F1A);
    }
  }

  String get hint {
    switch (this) {
      case _Mode.govt:    return 'Take photo of PM-KISAN / Fasal Bima / KCC form';
      case _Mode.bill:    return 'Photo your fertilizer shop bill for fraud check';
      case _Mode.seed:    return 'Photo the seed packet to read crop info';
      case _Mode.general: return 'Photo any farm document, receipt or notice';
    }
  }

  // Gemini prompt for each mode
  String get prompt {
    switch (this) {
      case _Mode.govt:
        return '''
Analyze this Indian government agricultural scheme document image.
Extract and present clearly:
1. SCHEME NAME (PM-KISAN / Fasal Bima Yojana / KCC / other)
2. FARMER DETAILS: Name, Aadhaar, land details if visible
3. AMOUNTS: Any money amounts, installment details, compensation amounts
4. DATES: Application date, due dates, validity period
5. STATUS: Approved / Pending / Rejected if mentioned
6. KEY REQUIREMENTS: What farmer needs to do next
7. IMPORTANT WARNINGS: Any deadlines or missing documents

Reply in Telugu first, then Hindi, then English.
Use simple village farmer language.
Start with: "ఈ పత్రంలో ఉన్న ముఖ్యమైన విషయాలు:" (Important points in this document:)
''';

      case _Mode.bill:
        return '''
Analyze this fertilizer / pesticide shop bill image carefully.
Extract:
1. SHOP NAME & LOCATION
2. DATE OF PURCHASE
3. LIST OF ITEMS PURCHASED:
   - Product name
   - Quantity (kg/L)
   - MRP (maximum retail price)
   - Charged price
   - Batch number / lot number if visible
4. TOTAL AMOUNT PAID
5. FRAUD CHECK:
   - Is any product charged MORE than MRP? Flag it!
   - Are there any suspicious items?
   - Does the bill have GST number? (Required by law)
   - Are batch numbers present? (Required for authenticity)
6. YOUR VERDICT: GENUINE ✅ or SUSPICIOUS ⚠️

Reply in Telugu first, then English.
Be very clear about any overcharging.
''';

      case _Mode.seed:
        return '''
Analyze this seed packet label image.
Extract and explain:
1. CROP NAME & VARIETY (e.g., "Rice - MTU 1010")
2. COMPANY NAME: Is it a known certified company?
3. SEED TYPE: Hybrid / OPV / BT / Non-BT
4. SOWING SEASON: Kharif / Rabi / Summer
5. SOWING METHOD: Direct / Transplanting / Row
6. SPACING: Plant to plant, row to row distance
7. SEED RATE: How much per acre
8. MATURITY DAYS: How many days to harvest
9. SPECIAL FEATURES: Disease resistance, yield potential
10. VALIDITY: Expiry date of seeds
11. CERTIFICATION: Any ISI / ICAR / State certification marks
12. BEST PRACTICES: Seed treatment before sowing

Reply in Telugu and English.
Warn if seeds are expired or uncertified.
''';

      case _Mode.general:
        return '''
You are an AI assistant helping Indian farmers read documents.
Analyze this image carefully.

If it is a RECEIPT or BILL:
- Extract: Store name, date, all items with prices, total
- Check for overcharging

If it is a NOTICE or LETTER:
- Summarize the main message in simple language
- Highlight any deadlines or action required

If it is a FORM:
- List all fields and what is filled
- Tell farmer what fields are empty/missing

If it is a PHOTO of crop/land/product:
- Describe what you see
- Give relevant farming advice

Always reply in Telugu and simple English.
Be helpful, clear, and brief.
''';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Gemini Vision Service
// ─────────────────────────────────────────────────────────────────────────────
class _GeminiVision {
  static const _key = 'AIzaSyBUVaP5tyV6YnPViVWRWB8MJiJJt40nbGs';
  static const _base = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const _models = [
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash-001',
    'gemini-1.0-pro-vision',
  ];

  static Future<String> analyze(Uint8List imageBytes, String prompt) async {
    final base64Image = base64Encode(imageBytes);

    for (final model in _models) {
      final url = '$_base/$model:generateContent?key=$_key';
      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'inline_data': {
                      'mime_type': 'image/jpeg',
                      'data': base64Image,
                    }
                  },
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'maxOutputTokens': 800,
              'temperature': 0.2,
            }
          }),
        ).timeout(const Duration(seconds: 30));

        debugPrint('GeminiVision [$model] → ${res.statusCode}');

        if (res.statusCode == 200) {
          final j = jsonDecode(res.body);
          final t = j['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (t != null && t.trim().isNotEmpty) return t.trim();
        } else if (res.statusCode == 404) {
          debugPrint('Vision model $model not found, trying next...');
          continue;
        } else if (res.statusCode == 400) {
          return 'Image quality too low. Please take a clearer photo with good lighting.';
        } else if (res.statusCode == 429) {
          // Auto-retry after 15 seconds instead of showing error
          debugPrint('429 on $model — waiting 15s...');
          await Future.delayed(const Duration(seconds: 15));
          try {
            final retry = await http.post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [{'parts': [{'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}}, {'text': prompt}]}],
                'generationConfig': {'maxOutputTokens': 800, 'temperature': 0.2}
              })).timeout(const Duration(seconds: 30));
            if (retry.statusCode == 200) {
              final j2 = jsonDecode(retry.body);
              final t2 = j2['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
              if (t2 != null && t2.trim().isNotEmpty) return t2.trim();
            }
          } catch (_) {}
          continue; // try next model
        } else if (res.statusCode == 403) {
          return 'API key error. Please check Gemini API key settings.';
        } else {
          debugPrint('HTTP ${res.statusCode}: ${res.body}');
          continue;
        }
      } on SocketException {
        return 'No internet connection. Please check WiFi or mobile data.';
      } on TimeoutException {
        debugPrint('Timeout for vision model $model, trying next...');
        continue;
      } catch (e) {
        debugPrint('GeminiVision [$model] error: $e');
        continue;
      }
    }
    return 'Document AI is currently unavailable. Please try again in a moment.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Document Scanner Screen
// ─────────────────────────────────────────────────────────────────────────────
class DocScannerScreen extends StatefulWidget {
  const DocScannerScreen({super.key});
  @override
  State<DocScannerScreen> createState() => _DocScannerState();
}

class _DocScannerState extends State<DocScannerScreen>
    with SingleTickerProviderStateMixin {
  _Mode _mode = _Mode.govt;
  Uint8List? _imgBytes;
  bool _analyzing = false;
  String? _result;
  bool _speaking = false;
  final _tts = FlutterTts();
  final _picker = ImagePicker();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('te-IN');
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Pick image ──────────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource src) async {
    try {
      final xf = await _picker.pickImage(
          source: src, imageQuality: 92, maxWidth: 1600);
      if (xf == null) return;
      final bytes = await xf.readAsBytes();
      setState(() {
        _imgBytes = bytes;
        _result = null;
        _analyzing = false;
      });
      // Auto-analyze
      await _analyze();
    } catch (e) {
      _showSnack('Could not open camera. Please allow camera permission.');
    }
  }

  // ── Analyze with Gemini Vision ──────────────────────────────────────────────
  Future<void> _analyze() async {
    if (_imgBytes == null || _analyzing) return;
    setState(() {
      _analyzing = true;
      _result = null;
    });

    final answer =
        await _GeminiVision.analyze(_imgBytes!, _mode.prompt);

    if (mounted) {
      setState(() {
        _result = answer;
        _analyzing = false;
      });
      // Auto-read result aloud
      await _speakResult(answer);
    }
  }

  Future<void> _speakResult(String text) async {
    if (kIsWeb) return;
    // Speak first 400 chars (TTS limit)
    final speak = text.length > 400 ? text.substring(0, 400) : text;
    setState(() => _speaking = true);
    await _tts.speak(speak);
  }

  Future<void> _stopSpeak() async {
    await _tts.stop();
    if (mounted) setState(() => _speaking = false);
  }

  void _reset() => setState(() {
        _imgBytes = null;
        _result = null;
        _analyzing = false;
        _speaking = false;
      });

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: KisanColors.alertRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: KisanColors.cream,
        body: CustomScrollView(
          slivers: [
            _appBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _modeSelector(),
                  const SizedBox(height: 14),
                  _imageArea(),
                  const SizedBox(height: 14),
                  _actionButtons(),
                  if (_analyzing) ...[
                    const SizedBox(height: 20),
                    _analyzingCard(),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    _resultCard(),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      );

  // ── App Bar ─────────────────────────────────────────────────────────────────
  SliverAppBar _appBar() => SliverAppBar(
        backgroundColor: KisanColors.leafDeep,
        pinned: true,
        expandedHeight: 0,
        title: Row(children: [
          Text(_mode.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text('Document Scanner',
              style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
        actions: [
          if (_result != null && _speaking)
            IconButton(
                onPressed: _stopSpeak,
                icon: const Icon(Icons.stop_circle,
                    color: KisanColors.sun)),
          if (_result != null && !_speaking)
            IconButton(
                onPressed: () => _speakResult(_result!),
                icon: const Icon(Icons.volume_up_rounded,
                    color: Colors.white),
                tooltip: 'Read aloud'),
          if (_imgBytes != null)
            IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'New scan'),
        ],
      );

  // ── Mode Selector ───────────────────────────────────────────────────────────
  Widget _modeSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT ARE YOU SCANNING?',
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: KisanColors.textMid,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: _Mode.values.map((m) {
              final sel = m == _mode;
              return GestureDetector(
                onTap: () => setState(() {
                  _mode = m;
                  _result = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? m.color : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel
                            ? m.color
                            : KisanColors.border,
                        width: sel ? 2 : 1),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: m.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(m.label,
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: sel
                                  ? Colors.white
                                  : KisanColors.textDark)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );

  // ── Image Preview Area ──────────────────────────────────────────────────────
  Widget _imageArea() => ScaleTransition(
        scale: _imgBytes == null ? _pulse : const AlwaysStoppedAnimation(1.0),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: _mode.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: _imgBytes == null
                    ? _mode.color.withOpacity(0.4)
                    : _mode.color,
                width: 2,
                style: _imgBytes == null
                    ? BorderStyle.solid
                    : BorderStyle.solid),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imgBytes != null
              ? Stack(fit: StackFit.expand, children: [
                  Image.memory(_imgBytes!, fit: BoxFit.cover),
                  if (_analyzing)
                    Container(
                      color: Colors.black45,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                        const SizedBox(height: 14),
                        Text('AI is reading…',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  // Mode badge
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: _mode.color,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${_mode.emoji} ${_mode.label}',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ])
              : _placeholder(),
        ),
      );

  Widget _placeholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_mode.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(_mode.hint,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  color: KisanColors.textMid,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Tap camera or gallery below',
              style: GoogleFonts.nunito(
                  color: KisanColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      );

  // ── Action Buttons ──────────────────────────────────────────────────────────
  Widget _actionButtons() => Row(children: [
        if (!kIsWeb) ...[
          Expanded(
              child: _btn(
                  '📷',
                  'Camera',
                  _mode.color,
                  () => _pickImage(ImageSource.camera))),
          const SizedBox(width: 10),
        ],
        Expanded(
            child: _btn(
                '🖼️',
                'Gallery',
                const Color(0xFF6B3F1A),
                () => _pickImage(ImageSource.gallery))),
        if (_imgBytes != null && _result == null && !_analyzing) ...[
          const SizedBox(width: 10),
          Expanded(
              child: _btn(
                  '🔍', 'Re-Analyze', KisanColors.leaf, _analyze)),
        ],
      ]);

  Widget _btn(String emoji, String label, Color color, VoidCallback fn) =>
      GestureDetector(
        onTap: fn,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color, color.withOpacity(0.75)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Center(
            child: Text('$emoji  $label',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
      );

  // ── Analyzing Card ──────────────────────────────────────────────────────────
  Widget _analyzingCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(children: [
          LinearProgressIndicator(
            backgroundColor: KisanColors.leafPale,
            color: _mode.color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text('${_mode.emoji}  Gemini AI is reading your ${_mode.label}…',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: KisanColors.textDark)),
          const SizedBox(height: 6),
          Text('This may take 5-15 seconds',
              style: GoogleFonts.nunito(
                  fontSize: 11, color: KisanColors.textLight)),
        ]),
      );

  // ── Result Card ─────────────────────────────────────────────────────────────
  Widget _resultCard() {
    // Check for fraud warning in bill mode
    final hasFraud = _mode == _Mode.bill &&
        (_result!.contains('SUSPICIOUS') ||
            _result!.contains('⚠️') ||
            _result!.contains('overcharg') ||
            _result!.contains('fraud'));

    final hasGenuine = _mode == _Mode.bill &&
        (_result!.contains('GENUINE') || _result!.contains('✅'));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(children: [
        Text('AI READING RESULT',
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: KisanColors.textMid,
                letterSpacing: 1.2)),
        const Spacer(),
        if (_speaking)
          GestureDetector(
            onTap: _stopSpeak,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: KisanColors.sun.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stop,
                    color: KisanColors.sun, size: 14),
                const SizedBox(width: 4),
                Text('Stop',
                    style: GoogleFonts.nunito(
                        color: KisanColors.sun,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          )
        else
          GestureDetector(
            onTap: () => _speakResult(_result!),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: KisanColors.leafPale,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.volume_up_rounded,
                    color: KisanColors.leaf, size: 14),
                const SizedBox(width: 4),
                Text('Read Aloud',
                    style: GoogleFonts.nunito(
                        color: KisanColors.leaf,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
      ]),

      const SizedBox(height: 10),

      // Fraud / Genuine badge for bill mode
      if (hasFraud)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAEA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: KisanColors.alertRed.withOpacity(0.5), width: 2),
          ),
          child: Row(children: [
            const Text('⚠️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text('FRAUD DETECTED!',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: KisanColors.alertRed)),
              Text('This bill may have overcharging or fraud. Read details below.',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: KisanColors.alertRed,
                      fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),

      if (hasGenuine)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KisanColors.leafPale,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: KisanColors.leaf.withOpacity(0.5), width: 2),
          ),
          child: Row(children: [
            const Text('✅', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text('BILL LOOKS GENUINE',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: KisanColors.leaf)),
              Text('No obvious fraud detected. Keep this bill safe.',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: KisanColors.leaf,
                      fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),

      // Main result text
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: KisanColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Mode label
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: _mode.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
                '${_mode.emoji} ${_mode.label} — Gemini AI Analysis',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _mode.color)),
          ),

          // Result text — formatted
          SelectableText(
            _result!,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: KisanColors.textDark,
                fontWeight: FontWeight.w600,
                height: 1.7),
          ),
        ]),
      ),

      const SizedBox(height: 14),

      // Action row
      Row(children: [
        Expanded(
            child: _btn('📤', 'Share Result', KisanColors.leafMid,
                () => _shareResult())),
        const SizedBox(width: 10),
        Expanded(
            child: _btn('📷', 'Scan Another', KisanColors.soil, _reset)),
      ]),
    ]);
  }

  void _shareResult() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('📤 Share feature coming soon!'),
      backgroundColor: KisanColors.leafMid,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
