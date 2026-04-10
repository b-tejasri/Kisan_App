// KisanAI – Reels Screen (Instagram-style vertical reels)
// Full screen vertical scroll, like/comment/share, farmer content

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});
  @override
  State<ReelsScreen> createState() => _RS();
}

class _RS extends State<ReelsScreen> {
  final _page = PageController();
  int _cur = 0;
  final _liked  = <int>{};
  final _saved  = <int>{};

  static const _reels = [
    _Reel('రాజు రెడ్డి', 'Guntur', '🌾', '🌾 వరి పంటకు బ్లాస్ట్ వ్యాధి — ట్రైసైక్లజోల్ 0.6g/L చల్లండి. 10 రోజులకొకసారి 3 సార్లు. సేంద్రీయంగా సూడోమోనాస్ వాడవచ్చు! #వరి #farming #kisanai', '2.3K', '186', 'Rice Blast Treatment', 0xFF1B4D30),
    _Reel('లక్ష్మి అమ్మ', 'Krishna', '🍅', '🍅 టొమాటో తోటలో ఆకు మచ్చలు వస్తున్నాయా? మాంకోజెబ్ 2g/లీటర్ వారానికొకసారి చల్లండి. దిగుబడి 30% పెరుగుతుంది! #tomato #organic', '1.8K', '94', 'Tomato Blight Control', 0xFFB71C1C),
    _Reel('వెంకటేశ్వర్లు', 'Prakasam', '🌿', '🌿 సేంద్రీయ వేప నూనె spray — 5ml/లీటర్ వాడండి. పురుగులు, వ్యాధులు రెండూ తగ్గుతాయి. రసాయన మందులకు ఉత్తమ ప్రత్యామ్నాయం! #organic #neem', '3.1K', '241', 'Organic Neem Spray', 0xFF2E7D32),
    _Reel('సావిత్రి', 'West Godavari', '💰', '💰 PM-KISAN ₹2000 వచ్చింది! pmkisan.gov.in లో మీరు eligible అవుతారా చెక్ చేయండి. ఆధార్ + భూమి రికార్డులు ready గా ఉంచుకోండి! #pmkisan #scheme', '4.7K', '389', 'PM-KISAN Update', 0xFFF57F17),
    _Reel('కృష్ణ రావు', 'East Godavari', '🧶', '🧶 పత్తి పంటలో bollworm వచ్చింది. క్లోరిపైరిఫాస్ 2.5ml/L లేదా వేప నూనె 5ml/L వాడండి. ముందే trap లు పెట్టండి! #cotton #pest', '1.2K', '67', 'Cotton Bollworm', 0xFF0D47A1),
    _Reel('సురేష్ కుమార్', 'Nellore', '🌱', '🌱 విత్తన శుద్ధి తప్పనిసరి! ట్రైకోడెర్మా 5g/kg విత్తనానికి చేయండి. వ్యాధులు 60% తగ్గుతాయి. దిగుబడి పెరుగుతుంది! #seed #treatment', '2.9K', '178', 'Seed Treatment', 0xFF4E342E),
    _Reel('అనిల్ కుమార్', 'Guntur', '🥜', '🥜 వేరుశెనగ pegging దశలో జిప్సమ్ 200kg/ఎకరా వేయండి. దిగుబడి 25% పెరిగింది నా అనుభవం! #groundnut #gypsum', '1.5K', '112', 'Groundnut Yield Boost', 0xFF6D4C41),
    _Reel('రాజేశ్వరి', 'Krishna', '☀️', '☀️ వేసవిలో పంటకు నీళ్ళు తక్కువగా వేయడం ఎలా? Drip irrigation పెట్టుకుంటే 40% నీళ్ళు ఆదా అవుతాయి! PM scheme లో subsidy వస్తుంది! #drip #water', '3.8K', '294', 'Water Saving Tips', 0xFF01579B),
  ];

  @override
  void dispose() { _page.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(children: [
      // Full screen vertical page view
      PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (i) => setState(() => _cur = i),
        itemBuilder: (_, i) => _reelCard(i),
      ),
      // Top bar
      Positioned(top: 0, left: 0, right: 0, child: _topBar()),
    ]),
  );

  Widget _topBar() => Container(
    padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16, right: 16, bottom: 12),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.black87, Colors.transparent],
        begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Row(children: [
      Text('Reels', style: GoogleFonts.lora(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      const Text('🎬', style: TextStyle(fontSize: 18)),
      const Spacer(),
      // Camera icon for posting
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22)),
    ]),
  );

  Widget _reelCard(int i) {
    final r = _reels[i];
    final liked = _liked.contains(i);
    final saved = _saved.contains(i);
    return Stack(fit: StackFit.expand, children: [
      // Background — gradient "video"
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(r.color), Color(r.color).withOpacity(0.5), Colors.black],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      ),
      // Big emoji as video thumbnail
      Positioned(top: 120, left: 0, right: 0,
        child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 100)))),

      // Play indicator
      Positioned(top: 200, left: 0, right: 0,
        child: Center(child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40)))),

      // Bottom gradient overlay
      Positioned(bottom: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 70, 90),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Farmer info
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep])),
                child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 18)))),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.name, style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                Text('📍 ${r.district}', style: GoogleFonts.nunito(color: Colors.white60, fontSize: 10)),
              ]),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('Follow', style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 10),
            // Caption
            Text(r.caption,
              maxLines: 3, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
            const SizedBox(height: 8),
            // Audio strip
            Row(children: [
              const Icon(Icons.music_note_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${r.name} • Original Audio', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        )),

      // Right side action buttons
      Positioned(right: 12, bottom: 100,
        child: Column(children: [
          // Like
          _actionBtn(
            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            liked ? Colors.red : Colors.white,
            r.likes,
            () => setState(() { if (liked) _liked.remove(i); else _liked.add(i); }),
          ),
          const SizedBox(height: 20),
          // Comment
          _actionBtn(Icons.chat_bubble_outline_rounded, Colors.white, r.comments,
            () => _showComments(r)),
          const SizedBox(height: 20),
          // Share
          _actionBtn(Icons.send_outlined, Colors.white, 'Share', () {}),
          const SizedBox(height: 20),
          // Save
          _actionBtn(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            saved ? KisanColors.sun : Colors.white,
            '',
            () => setState(() { if (saved) _saved.remove(i); else _saved.add(i); }),
          ),
          const SizedBox(height: 20),
          // More
          _actionBtn(Icons.more_horiz_rounded, Colors.white, '', () {}),
          const SizedBox(height: 16),
          // Spinning emoji record
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 2),
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep])),
            child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 18)))),
        ])),

      // Progress dots on right edge
      Positioned(right: 4, top: 0, bottom: 0,
        child: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_reels.length, (j) => Container(
            width: 3, height: j == i ? 20 : 4,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: j == i ? Colors.white : Colors.white30,
              borderRadius: BorderRadius.circular(2))))))),
    ]);
  }

  Widget _actionBtn(IconData icon, Color color, dynamic label, VoidCallback fn) =>
    GestureDetector(
      onTap: fn,
      child: Column(children: [
        Icon(icon, color: color, size: 30),
        if (label.toString().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(label.toString(),
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ]),
    );

  void _showComments(_Reel r) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        const SizedBox(height: 8),
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 12),
        Text('Comments', style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
        const Divider(color: Colors.white12),
        Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
          for (final c in [
            ['👨‍🌾','రాజు','చాలా useful! నా పంటకు కూడా పని చేసింది 🙏'],
            ['👩‍🌾','లక్ష్మి','Dose ఎంత వేశారు? ఒక్కసారి చెప్పండి'],
            ['🧔','వెంకట్','Great tip! Share చేశాను friends కి'],
            ['👱','కృష్ణ','₹ cost ఎంత అవుతుంది ఒక ఎకరానికి?'],
          ])
            Padding(padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]), shape: BoxShape.circle),
                  child: Center(child: Text(c[0], style: const TextStyle(fontSize: 16)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c[1], style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text(c[2], style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12, height: 1.3)),
                ])),
              ])),
        ])),
      ]),
    ));
}

class _Reel {
  final String name, district, emoji, caption, likes, comments, title;
  final int color;
  const _Reel(this.name, this.district, this.emoji, this.caption,
      this.likes, this.comments, this.title, this.color);
}
