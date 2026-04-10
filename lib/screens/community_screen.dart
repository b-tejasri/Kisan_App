// KisanAI – Community Screen (Instagram-style)
// Stories row, Reels, Like/Comment/Share/Save, Video posts, Equipment rental, Help

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

// ── Data Models ───────────────────────────────────────────────────────────────
class _Post {
  final String id, avatar, name, district, cropEmoji, content, time, mediaEmoji;
  final int likes, comments, shares;
  final bool verified, isVideo;
  bool liked, saved;
  _Post({required this.id, required this.avatar, required this.name, required this.district,
    required this.cropEmoji, required this.content, required this.time, required this.mediaEmoji,
    required this.likes, required this.comments, required this.shares,
    this.verified = false, this.isVideo = false, this.liked = false, this.saved = false});
}

class _Story {
  final String avatar, name, emoji;
  final bool isOwn, hasNew;
  const _Story(this.avatar, this.name, this.emoji, {this.isOwn=false, this.hasNew=true});
}

class _Equip {
  final String emoji, name, rate, owner, phone, district;
  final bool available;
  const _Equip(this.emoji, this.name, this.rate, this.owner, this.phone, this.district, this.available);
}

// ─────────────────────────────────────────────────────────────────────────────
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CS();
}

class _CS extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabs;
  String _myName   = 'You';
  String _myAvatar = '👨‍🌾';

  // Instagram-style posts feed
  final _posts = <_Post>[
    _Post(id:'1', avatar:'👨‍🌾', name:'రాజు రెడ్డి', district:'Guntur', cropEmoji:'🌶️', isVideo:false, mediaEmoji:'🌶️',
      content:'మిర్చి పంటలో థ్రిప్స్ పురుగు వచ్చింది. స్పైనోసాడ్ 0.3ml/L చల్లాను, 3 రోజుల్లో తగ్గింది! 👍\n#mirchi #pest #kisanai',
      time:'2h', likes:124, comments:18, shares:7, verified:true),
    _Post(id:'2', avatar:'👩‍🌾', name:'లక్ష్మి', district:'Krishna', cropEmoji:'🌾', isVideo:true, mediaEmoji:'🎬',
      content:'వరి పంటకు బ్లాస్ట్ వ్యాధి వచ్చింది — ఈ video లో పూర్తి treatment చూడండి! ట్రైసైక్లజోల్ use చేయండి.\n#rice #blast #farming',
      time:'4h', likes:287, comments:42, shares:31, verified:true),
    _Post(id:'3', avatar:'👨', name:'వెంకటేశ్వర్లు', district:'Prakasam', cropEmoji:'🌿', isVideo:false, mediaEmoji:'📊',
      content:'ఈ సీజన్ టొమాటో ధర పడిపోయింది 😢. మార్కెట్‌లో ₹8/kg. Cold storage వాడి 2 weeks ఆపితే ₹22/kg వచ్చింది!\n#tomato #market #tips',
      time:'6h', likes:456, comments:89, shares:54),
    _Post(id:'4', avatar:'🧔', name:'సురేష్ కుమార్', district:'Nellore', cropEmoji:'💧', isVideo:true, mediaEmoji:'🎬',
      content:'నీటి తడి తక్కువగా వేసి DAP తో పాటు జిప్సమ్ వేశాను. వేరుశెనగ దిగుబడి 20% పెరిగింది! Full demo video 👇\n#groundnut #yield #organic',
      time:'1d', likes:892, comments:134, shares:98, verified:true),
    _Post(id:'5', avatar:'👩', name:'సావిత్రి', district:'West Godavari', cropEmoji:'☀️', isVideo:false, mediaEmoji:'💰',
      content:'PM-KISAN డబ్బు వచ్చింది! ₹2000 account లో జమ అయింది ✅ మీకు వచ్చిందా? pmkisan.gov.in లో చెక్ చేయండి.\n#pmkisan #scheme #money',
      time:'1d', likes:1243, comments:267, shares:189, verified:true),
    _Post(id:'6', avatar:'👱', name:'కృష్ణ రావు', district:'East Godavari', cropEmoji:'🌱', isVideo:true, mediaEmoji:'🎬',
      content:'విత్తన శుద్ధి ఎలా చేయాలో step-by-step video. ట్రైకోడెర్మా 5g/kg వాడితే వ్యాధులు 60% తగ్గుతాయి! 💪\n#seed #treatment #organic',
      time:'2d', likes:678, comments:91, shares:76),
  ];

  final _stories = const [
    _Story('👨‍🌾', 'My Story', '➕', isOwn: true, hasNew: false),
    _Story('👩‍🌾', 'లక్ష్మి', '🌾', hasNew: true),
    _Story('🧔', 'రాజు', '🍅', hasNew: true),
    _Story('👱', 'కృష్ణ', '🌱', hasNew: true),
    _Story('👵', 'శాంత', '🌶️', hasNew: false),
    _Story('🧕', 'ఫాతిమా', '💰', hasNew: true),
    _Story('👴', 'రంగయ్య', '🌿', hasNew: false),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() {
      _myName   = p.getString('farmer_name')   ?? 'You';
      _myAvatar = p.getString('farmer_avatar') ?? '👨‍🌾';
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: Colors.white,
    body: NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          pinned: true,
          title: Row(children: [
            Text('KisanAI', style: GoogleFonts.lora(
                fontSize: 22, fontWeight: FontWeight.w700, color: KisanColors.leafDeep)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.add_box_outlined, color: KisanColors.textDark, size: 26), onPressed: () => _newPost(ctx)),
            IconButton(icon: const Icon(Icons.notifications_none_rounded, color: KisanColors.textDark, size: 26), onPressed: () {}),
          ]),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: KisanColors.leafDeep,
            indicatorWeight: 2,
            labelColor: KisanColors.leafDeep,
            unselectedLabelColor: KisanColors.textLight,
            labelStyle: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800),
            tabs: const [
              Tab(icon: Icon(Icons.grid_view_rounded, size: 20), text: 'Feed'),
              Tab(icon: Icon(Icons.play_circle_outline_rounded, size: 20), text: 'Reels'),
              Tab(icon: Icon(Icons.agriculture_rounded, size: 20), text: 'Equipment'),
              Tab(icon: Icon(Icons.help_outline_rounded, size: 20), text: 'Help'),
            ],
          ),
        ),
      ],
      body: TabBarView(controller: _tabs, children: [
        _feed(),
        _reels(ctx),
        _equipment(ctx),
        _help(ctx),
      ]),
    ),
  );

  // ── Feed (Instagram style) ──────────────────────────────────────────────────
  Widget _feed() => ListView(children: [
    _storiesRow(),
    ..._posts.map((p) => _postCard(p)),
    const SizedBox(height: 80),
  ]);

  // ── Stories Row ─────────────────────────────────────────────────────────────
  Widget _storiesRow() => Container(
    height: 100,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _stories.length,
      itemBuilder: (_, i) {
        final s = _stories[i];
        return GestureDetector(
          onTap: () {},
          child: Container(
            width: 68, margin: const EdgeInsets.only(right: 10),
            child: Column(children: [
              Container(
                padding: EdgeInsets.all(s.hasNew ? 2.5 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: s.isOwn ? null : s.hasNew
                      ? const LinearGradient(colors: [Color(0xFFFFD700), KisanColors.leaf, KisanColors.leafDeep],
                          begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: s.isOwn ? KisanColors.leafPale : !s.hasNew ? const Color(0xFFDDDDDD) : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]),
                        shape: BoxShape.circle),
                    child: Center(child: Text(s.isOwn ? '➕' : s.emoji,
                        style: TextStyle(fontSize: s.isOwn ? 22.0 : 28.0))),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(s.isOwn ? 'Your Story' : s.name,
                  overflow: TextOverflow.ellipsis, maxLines: 1,
                  style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w700,
                      color: KisanColors.textDark)),
            ]),
          ),
        );
      },
    ),
  );

  // ── Post Card ───────────────────────────────────────────────────────────────
  Widget _postCard(_Post p) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]),
                  shape: BoxShape.circle,
                  border: Border.all(color: KisanColors.leafLight, width: 1.5)),
              child: Center(child: Text(p.avatar, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(p.name, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
              if (p.verified) ...[const SizedBox(width: 4),
                const Icon(Icons.verified_rounded, size: 14, color: KisanColors.leafMid)],
            ]),
            Text('📍 ${p.district} • ${p.time}',
                style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          ])),
          Text(p.cropEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 4),
          const Icon(Icons.more_horiz, color: Colors.black54, size: 20),
        ]),
      ),
      // Media area
      Container(
        width: double.infinity, height: 260,
        color: const Color(0xFF0A1F12),
        child: Stack(alignment: Alignment.center, children: [
          Text(p.mediaEmoji, style: const TextStyle(fontSize: 80)),
          if (p.isVideo) Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36)),
          if (p.isVideo) Positioned(top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
                Text(' Reel', style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ]))),
          Positioned(bottom: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 11),
                Text(' ${p.district}', style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ]))),
        ]),
      ),
      // Action bar (Instagram style)
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(children: [
          // Like
          GestureDetector(
            onTap: () => setState(() => p.liked = !p.liked),
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
              child: Icon(p.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: ValueKey(p.liked), size: 26,
                  color: p.liked ? Colors.red : Colors.black87))),
          const SizedBox(width: 16),
          // Comment
          GestureDetector(onTap: () => _showComments(p),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 24, color: Colors.black87)),
          const SizedBox(width: 16),
          // Share
          GestureDetector(onTap: () {},
              child: const Icon(Icons.send_outlined, size: 24, color: Colors.black87)),
          const Spacer(),
          // Save
          GestureDetector(
            onTap: () => setState(() => p.saved = !p.saved),
            child: Icon(p.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 26, color: Colors.black87)),
        ]),
      ),
      // Likes count
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
        child: Text('${(p.likes + (p.liked ? 1 : 0)).toStringAsFixed(0)} likes',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87)),
      ),
      // Content
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: RichText(text: TextSpan(style: GoogleFonts.nunito(fontSize: 13, color: Colors.black87, height: 1.4), children: [
          TextSpan(text: '${p.name} ', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.black)),
          TextSpan(text: p.content),
        ])),
      ),
      // Comments preview
      GestureDetector(
        onTap: () => _showComments(p),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Text('View all ${p.comments} comments',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );

  // ── Reels Tab ───────────────────────────────────────────────────────────────
  Widget _reels(BuildContext ctx) {
    const reels = [
      {'e':'🎬','title':'Rice Blast Treatment — Full Guide','farmer':'రాజు రెడ్డి','likes':'2.3K','d':'4:32','c':0xFF2D6A4F},
      {'e':'🍅','title':'Tomato Late Blight Control','farmer':'లక్ష్మి','likes':'1.8K','d':'5:10','c':0xFFE63946},
      {'e':'🌿','title':'Organic Neem Spray — Complete Guide','farmer':'వెంకటేశ్వర్లు','likes':'3.1K','d':'6:45','c':0xFF40916C},
      {'e':'💰','title':'PM-KISAN Apply Step by Step','farmer':'సావిత్రి','likes':'4.7K','d':'3:20','c':0xFFF4A226},
      {'e':'🧶','title':'Cotton Bollworm Control','farmer':'కృష్ణ రావు','likes':'1.2K','d':'4:55','c':0xFF0096C7},
      {'e':'🌱','title':'Seed Treatment — ట్రైకోడెర్మా','farmer':'సురేష్','likes':'2.9K','d':'3:15','c':0xFF6B3F1A},
      {'e':'🥜','title':'Groundnut Pegging Stage Care','farmer':'అనిల్','likes':'1.5K','d':'5:30','c':0xFF805500},
      {'e':'🌾','title':'Rice Transplanting Tips 2025','farmer':'రాజేశ్వరి','likes':'3.8K','d':'7:12','c':0xFF1B4D30},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: reels.length,
      itemBuilder: (_, i) {
        final r = reels[i];
        final color = Color(r['c'] as int);
        return GestureDetector(
          onTap: () => _playReel(ctx, r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Stack(fit: StackFit.expand, children: [
              Center(child: Text(r['e'] as String, style: const TextStyle(fontSize: 60))),
              Center(child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28))),
              Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, Colors.black54],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 1.2)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text('❤️ ${r['likes']}', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text('⏱ ${r['d']}', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 9)),
                      ]),
                    ]),
                  )),
              Positioned(top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(6)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
                      Text(' Reel', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                    ]))),
            ]),
          ),
        );
      },
    );
  }

  // ── Equipment Tab ───────────────────────────────────────────────────────────
  Widget _equipment(BuildContext ctx) {
    const equips = [
      _Equip('🚜','Tractor','₹800/hr','రాజు రెడ్డి','9876543210','Guntur',true),
      _Equip('🌾','Harvester','₹2500/acre','వెంకట్','9123456780','Krishna',true),
      _Equip('💧','Power Sprayer','₹200/hr','సురేష్','9988776655','Prakasam',false),
      _Equip('🔧','Rotavator','₹600/hr','రమేష్','9845123456','Nellore',true),
      _Equip('🌱','Seed Drill','₹400/acre','కృష్ణ','9756231489','West Godavari',false),
      _Equip('💦','Water Pump','₹150/hr','లక్ష్మి','9671234567','East Godavari',true),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(14,14,14,90), children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [KisanColors.leafDeep, KisanColors.leaf]),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Text('🚜', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rent Equipment Near You', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('Tap 📞 to call • Available 24/7', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
          ])),
          GestureDetector(
            onTap: () => _newPost(ctx),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: KisanColors.sun, borderRadius: BorderRadius.circular(10)),
              child: Text('+ List Mine', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)))),
        ]),
      ),
      const SizedBox(height: 14),
      ...equips.map((e) => _equipCard(ctx, e)),
    ]);
  }

  Widget _equipCard(BuildContext ctx, _Equip e) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,2))]),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 32)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(e.name, style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.w700, color: KisanColors.textDark)),
            const SizedBox(width: 8),
            if (e.available) Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: KisanColors.leafPale, borderRadius: BorderRadius.circular(8)),
              child: Text('✅ Available', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w800, color: KisanColors.leaf))),
          ]),
          Text(e.rate, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: KisanColors.leaf)),
          Text('👤 ${e.owner}  📍 ${e.district}', style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('📞 Calling ${e.owner}: ${e.phone}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              backgroundColor: KisanColors.leaf, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep]), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('📞', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text('Call ${e.owner}', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ]))),
        ])),
      ]),
    ),
  );

  // ── Help Tab ────────────────────────────────────────────────────────────────
  Widget _help(BuildContext ctx) => ListView(padding: const EdgeInsets.fromLTRB(14,14,14,90), children: [
    Container(
      padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KisanColors.alertRed.withOpacity(0.4), width: 1.5)),
      child: Row(children: [
        const Text('🆘', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Emergency Farm Help', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: KisanColors.alertRed)),
          Text('Kisan Call Center: 1800-180-1551\nFree • 24/7 • Telugu/Hindi/English',
              style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.alertRed, fontWeight: FontWeight.w600, height: 1.4)),
        ])),
      ])),
    for (final h in [
      ['🌾','Kisan Call Center','1800-180-1551','Crop disease, pest, fertilizer help — FREE',KisanColors.leaf],
      ['💧','Irrigation Helpline','1800-425-1172','Water & irrigation problems — FREE',KisanColors.skyBlue],
      ['💰','PM-KISAN Helpline','155261','PM-KISAN money issues — FREE',KisanColors.sun],
      ['🏦','Kisan Credit Card','1800-11-0001','KCC loan problems — FREE',const Color(0xFF6B3F1A)],
      ['🌦️','Weather Helpline','1800-180-1717','Weather forecast — FREE',const Color(0xFF5C6BC0)],
    ])
      _helpCard(ctx, h[0] as String, h[1] as String, h[2] as String, h[3] as String, h[4] as Color),
    const SizedBox(height: 14),
    Text('GOVERNMENT WEBSITES', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: KisanColors.textMid, letterSpacing: 1)),
    const SizedBox(height: 10),
    for (final l in [
      ['💰','PM-KISAN','pmkisan.gov.in','₹6000/year status check'],
      ['📊','Agmarknet','agmarknet.gov.in','Daily mandi prices'],
      ['🛡️','Fasal Bima','pmfby.gov.in','Crop insurance apply'],
      ['🌾','eNAM','enam.gov.in','Online crop selling'],
    ])
      _linkCard(ctx, l[0], l[1], l[2], l[3]),
  ]);

  Widget _helpCard(BuildContext ctx, String emoji, String name, String number, String desc, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,2))]),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 50, height: 50,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
              Text(desc, style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid, fontWeight: FontWeight.w600)),
            ])),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text('📞 Calling $number...', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                backgroundColor: color, behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text('📞', style: TextStyle(fontSize: 16)),
                  Text(number, style: GoogleFonts.nunito(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                ]))),
          ]),
        ),
      );

  Widget _linkCard(BuildContext ctx, String emoji, String name, String url, String desc) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KisanColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.textDark)),
              Text(desc, style: GoogleFonts.nunito(fontSize: 11, color: KisanColors.textMid)),
              Text(url, style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.skyBlue, fontWeight: FontWeight.w700)),
            ])),
            const Icon(Icons.open_in_new_rounded, color: KisanColors.textLight, size: 18),
          ]),
        ),
      );

  // ── New Post Sheet ──────────────────────────────────────────────────────────
  void _newPost(BuildContext ctx) => showModalBottomSheet(
    context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => _NewPostSheet(avatar: _myAvatar, name: _myName));

  // ── Show Comments ────────────────────────────────────────────────────────────
  void _showComments(_Post p) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => _CommentsSheet(post: p));

  // ── Play Reel ────────────────────────────────────────────────────────────────
  void _playReel(BuildContext ctx, Map r) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text('▶️ Playing: ${r['title']}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
    backgroundColor: KisanColors.leaf, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
}

// ─────────────────────────────────────────────────────────────────────────────
class _NewPostSheet extends StatefulWidget {
  final String avatar, name;
  const _NewPostSheet({required this.avatar, required this.name});
  @override State<_NewPostSheet> createState() => _NPS();
}

class _NPS extends State<_NewPostSheet> {
  final _ctrl = TextEditingController();
  String _topic = '🌾 Crop Disease';
  static const _topics = ['🌾 Crop Disease','🧪 Fertilizer','💧 Water','📊 Market','🌧️ Weather','🚜 Equipment','💰 Scheme','📹 Video Tip'];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Container(
    height: MediaQuery.of(ctx).size.height * 0.78,
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(ctx).viewInsets.bottom + 20),
    child: Column(children: [
      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
      const SizedBox(height: 14),
      Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]), shape: BoxShape.circle),
          child: Center(child: Text(widget.avatar, style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.name, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800)),
          Text('Posting to KisanAI Community', style: GoogleFonts.nunito(fontSize: 10, color: KisanColors.textMid)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () { Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('✅ Post shared!', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              backgroundColor: KisanColors.leaf, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));},
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep]), borderRadius: BorderRadius.circular(20)),
            child: Text('Share', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)))),
      ]),
      const SizedBox(height: 14),
      SizedBox(height: 36, child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: _topics.length,
        itemBuilder: (_, i) { final sel = _topics[i] == _topic; return GestureDetector(
          onTap: () => setState(() => _topic = _topics[i]),
          child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: sel ? KisanColors.leaf : KisanColors.leafPale, borderRadius: BorderRadius.circular(20)),
            child: Text(_topics[i], style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: sel ? Colors.white : KisanColors.leaf)))); })),
      const SizedBox(height: 12),
      Expanded(child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF8FAF8), borderRadius: BorderRadius.circular(16), border: Border.all(color: KisanColors.border)),
        child: TextField(controller: _ctrl, maxLines: null,
          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: KisanColors.textDark),
          decoration: InputDecoration(hintText: 'Share your farming experience, tips or questions...',
            hintStyle: GoogleFonts.nunito(fontSize: 13, color: KisanColors.textLight, fontWeight: FontWeight.w600),
            border: InputBorder.none, contentPadding: const EdgeInsets.all(14))))),
      const SizedBox(height: 12),
      Row(children: [
        _mediaBtn(Icons.photo_library_outlined, 'Photo'),
        const SizedBox(width: 8),
        _mediaBtn(Icons.videocam_outlined, 'Video'),
        const SizedBox(width: 8),
        _mediaBtn(Icons.location_on_outlined, 'Location'),
        const SizedBox(width: 8),
        _mediaBtn(Icons.tag_rounded, 'Tag'),
      ]),
    ]),
  );

  Widget _mediaBtn(IconData icon, String label) => GestureDetector(
    onTap: () {},
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(border: Border.all(color: KisanColors.border), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: KisanColors.leaf),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: KisanColors.leaf)),
      ])));
}

// ─────────────────────────────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final _Post post;
  const _CommentsSheet({required this.post});
  @override State<_CommentsSheet> createState() => _CmtState();
}

class _CmtState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Container(
    height: MediaQuery.of(ctx).size.height * 0.7,
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
        child: Center(child: Text('Comments', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800)))),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        for (final c in [
          ['👨‍🌾','రాజు','చాలా useful info! Thanks 🙏','1h','42'],
          ['👩‍🌾','లక్ష్మి','నా పంటకు కూడా ఇలానే చేశాను','2h','28'],
          ['🧔','వెంకట్','Dose ఎంత వేశారు?','3h','15'],
          ['👱','సురేష్','Great tip! Saved ⭐','4h','67'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]), shape: BoxShape.circle),
                  child: Center(child: Text(c[0], style: const TextStyle(fontSize: 18)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(style: GoogleFonts.nunito(fontSize: 13, color: Colors.black87), children: [
                  TextSpan(text: '${c[1]} ', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  TextSpan(text: c[2]),
                ])),
                const SizedBox(height: 4),
                Row(children: [
                  Text(c[3]!, style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Text('❤️ ${c[4]}', style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Text('Reply', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                ]),
              ])),
            ]),
          ),
      ])),
      Container(
        padding: EdgeInsets.fromLTRB(14, 8, 14, MediaQuery.of(ctx).viewInsets.bottom + 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafLight]), shape: BoxShape.circle),
              child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 17)))),
          const SizedBox(width: 10),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(24)),
            child: TextField(controller: _ctrl,
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(hintText: 'Add a comment...', hintStyle: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[400]), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10))))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { Navigator.pop(ctx); },
            child: Text('Post', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: KisanColors.leafMid))),
        ]),
      ),
    ]),
  );
}
