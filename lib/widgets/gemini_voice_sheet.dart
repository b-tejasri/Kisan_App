// KisanAI Voice+Chat Assistant v10
// CHANGED: Groq API (ultra-fast, free) replaces Gemini
// CHANGED: 👨‍🌾 Farmer logo replaces 🤖 robot everywhere
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Groq AI Service
//  - llama-3.3-70b model: ultra fast, free, 30 req/min
//  - Answers ANY question (greetings, farming, general)
//  - Replies in same language as user (Telugu/Hindi/Tamil/English)
// ─────────────────────────────────────────────────────────────────────────────
class _AI {
  static const _key = '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';
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  // Models in priority order — all free on Groq
  static const _models = [
    'llama-3.3-70b-versatile',
    'llama3-70b-8192',
    'mixtral-8x7b-32768',
    'llama3-8b-8192',
  ];

  static const _sys =
    'You are KisanAI, a friendly AI assistant for Indian farmers. '
    'You can answer ANY question — farming, general knowledge, greetings, jokes, anything. '
    'CRITICAL: Detect language of user message. Reply in EXACTLY that language. '
    'Telugu → Telugu only. Hindi → Hindi only. English → English only. '
    'Greetings (hello, hi, how are you): reply warmly, offer to help with farming. '
    'Farming questions: give exact dose (g/L or kg/acre). 1 organic + 1 chemical remedy. '
    'Max 4 sentences. Friendly like a wise village elder who knows everything.';

  static Future<String> ask(String question) async {
    for (final model in _models) {
      try {
        final res = await http.post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_key',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': _sys},
              {'role': 'user',   'content': question},
            ],
            'max_tokens': 300,
            'temperature': 0.7,
          }),
        ).timeout(const Duration(seconds: 20));

        debugPrint('Groq [$model] → ${res.statusCode}');

        if (res.statusCode == 200) {
          final j  = jsonDecode(res.body) as Map;
          final t  = j['choices']?[0]?['message']?['content'] as String?;
          if (t != null && t.trim().isNotEmpty) return t.trim();
          continue;
        }

        if (res.statusCode == 429) {
          debugPrint('[$model] rate limited, wait 8s retry...');
          await Future.delayed(const Duration(seconds: 8));
          final r2 = await http.post(Uri.parse(_url),
            headers: {'Content-Type':'application/json','Authorization':'Bearer $_key'},
            body: jsonEncode({'model':model,'messages':[
              {'role':'system','content':_sys},{'role':'user','content':question}],
              'max_tokens':300,'temperature':0.7}),
          ).timeout(const Duration(seconds: 20));
          if (r2.statusCode == 200) {
            final j2 = jsonDecode(r2.body) as Map;
            final t2 = j2['choices']?[0]?['message']?['content'] as String?;
            if (t2 != null && t2.trim().isNotEmpty) return t2.trim();
          }
          continue;
        }
        if (res.statusCode == 401) return 'API key error. Please check Groq API key.';
        debugPrint('[$model] HTTP ${res.statusCode}');
        continue;

      } on SocketException {
        return 'No internet.\nPlease turn on WiFi or mobile data.\nఇంటర్నెట్ లేదు. WiFi ఆన్ చేయండి.';
      } on TimeoutException {
        debugPrint('[$model] timeout'); continue;
      } catch (e) {
        debugPrint('[$model] $e'); continue;
      }
    }
    return _local(question);
  }

  // Friendly local answers when ALL API attempts fail
  static String _local(String q) {
    final w = q.toLowerCase().trim();
    if (w == 'hello' || w == 'hi' || w == 'hey' ||
        w.contains('how are you') || w.contains('నమస్కారం') ||
        w.contains('నమస్తే') || w.contains('namaste') ||
        w.contains('नमस्ते') || w.contains('vanakkam')) {
      return 'Hello! 🙏 I am KisanAI — your farming friend!\nTell me your crop problem and I will help you right away.\n\nనమస్కారం రైతు అన్నా! మీ పంట సమస్య చెప్పండి.';
    }
    if (w.contains('వరి') || w.contains('rice') || w.contains('paddy')) {
      return 'Rice blast → Tricyclazole 0.6g/L every 10 days. Fertilizer: DAP 25kg/acre + Urea 30kg/acre. Organic: Neem cake 200kg/acre.\nవరి బ్లాస్ట్: ట్రైసైక్లజోల్ 0.6g/లీటర్. DAP 25kg + యూరియా 30kg/ఎకరా.';
    }
    if (w.contains('tomato') || w.contains('టొమాటో')) {
      return 'Tomato: Mancozeb 2g/L weekly. Calcium Nitrate 2g/L foliar. Boron 1g/L at flowering.\nటొమాటో: మాంకోజెబ్ 2g/లీటర్. కాల్షియమ్ నైట్రేట్ 2g/లీటర్.';
    }
    if (w.contains('chilli') || w.contains('మిర్చి')) {
      return 'Chilli: Carbendazim 1g/L for disease. MKP 2g/L at flowering. Neem oil 3ml/L weekly.\nమిర్చి: కార్బెండజిమ్ 1g/లీటర్. MKP 2g/లీటర్ పూత దశలో.';
    }
    if (w.contains('fertilizer') || w.contains('ఎరువు') || w.contains('खाद')) {
      return 'General fertilizer: DAP 25kg/acre at sowing, Urea 30kg/acre top dressing, Potash 20kg/acre.\nఎరువు: DAP 25kg + యూరియా 30kg + పొటాష్ 20kg/ఎకరా.';
    }
    if (w.contains('pest') || w.contains('పురుగు') || w.contains('कीड़े')) {
      return 'Pest control: Neem oil 5ml/L organic. Imidacloprid 0.5ml/L chemical.\nపురుగు: వేప నూనె 5ml/లీటర్. ఇమిడాక్లోప్రిడ్ 0.5ml/లీటర్.';
    }
    if (w.contains('pm-kisan') || w.contains('kisan') || w.contains('కిసాన్')) {
      return 'PM-KISAN: ₹6000/year in 3 installments. Apply at pmkisan.gov.in with Aadhaar and land records.\nPM-KISAN: సంవత్సరానికి ₹6000. pmkisan.gov.in లో దరఖాస్తు.';
    }
    return 'Hello! 🌾 I am KisanAI.\nPlease ask me about rice, tomato, chilli, fertilizer, pests, or government schemes.\n\nనమస్కారం! పంట పేరు చెప్పి అడగండి — నేను సహాయం చేస్తాను!';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Message model
// ─────────────────────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser, byVoice;
  final DateTime time;
  _Msg(this.text, this.isUser, {this.byVoice = false}) : time = DateTime.now();
}

// ─────────────────────────────────────────────────────────────────────────────
//  VoiceListeningSheet
//  👨‍🌾 Farmer logo everywhere (no robots)
//  Illiterate-first: big mic, picture tiles, speaks answers aloud
// ─────────────────────────────────────────────────────────────────────────────
class VoiceListeningSheet extends StatefulWidget {
  const VoiceListeningSheet({super.key});
  @override
  State<VoiceListeningSheet> createState() => _S();
}

class _S extends State<VoiceListeningSheet>
    with SingleTickerProviderStateMixin {
  final _stt = SpeechToText();
  final _tts = FlutterTts();
  bool  _sr  = false, _mic = false, _talking = false;
  String _heard = '';
  final _msgs = <_Msg>[];
  final _c    = TextEditingController();
  final _sc   = ScrollController();
  bool   _loading = false;
  String _status  = '';
  String _lang    = 'en';
  late AnimationController _pulse;

  // Picture tiles — big emoji, simple label
  static const _tiles = [
    {'e':'🌾','l':'Rice\nDisease',    'q':'What disease is in my rice crop and how to treat it?'},
    {'e':'🍅','l':'Tomato\nProblem',  'q':'My tomato crop has disease. Which spray to use?'},
    {'e':'🌶','l':'Chilli\nDisease',  'q':'How to treat chilli crop disease?'},
    {'e':'🌿','l':'Fertilizer\nDose', 'q':'Which fertilizer and how much per acre for my crop?'},
    {'e':'💰','l':'PM-KISAN\nMoney',  'q':'How much money in PM-KISAN and how to apply?'},
    {'e':'🐛','l':'Pest\nControl',    'q':'How to control pests and insects on my crop?'},
    {'e':'🌧','l':'Rain &\nSpray',    'q':'Can I spray pesticide when rain is coming?'},
    {'e':'📊','l':'Market\nPrice',    'q':'How to get best mandi price for my crop today?'},
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _iStt(); _iTts();
    _msgs.add(_Msg(
      '🙏 Hello! I am KisanAI — your farming friend!\n\n'
      '🎙️ Tap the BIG MIC button to speak\n'
      '🖼️ Tap picture tiles below for quick questions\n'
      '⌨️ Or just type anything here\n\n'
      'నమస్కారం! ఏదైనా అడగండి — తెలుగు, హిందీ, ఇంగ్లీష్.',
      false,
    ));
  }

  Future<void> _iStt() async {
    if (kIsWeb) return;
    if (!(await Permission.microphone.request()).isGranted) return;
    _sr = await _stt.initialize(onStatus: (s) {
      if ((s == 'done' || s == 'notListening') && mounted) {
        setState(() => _mic = false);
        if (_heard.trim().isNotEmpty) _send(_heard.trim(), byVoice: true);
      }
    });
    if (mounted) setState(() {});
  }

  Future<void> _iTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.44);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() { if (mounted) setState(() => _talking = false); });
  }

  @override
  void dispose() {
    _stt.stop(); _tts.stop(); _pulse.dispose();
    _c.dispose(); _sc.dispose(); super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_loading || _talking) return;
    if (_mic) {
      await _stt.stop(); setState(() => _mic = false);
      if (_heard.trim().isNotEmpty) _send(_heard.trim(), byVoice: true);
      return;
    }
    if (!_sr) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Allow microphone permission in Settings'),
          backgroundColor: KisanColors.alertRed));
      return;
    }
    setState(() { _mic = true; _heard = ''; });
    await _stt.listen(
      onResult: (r) {
        if (mounted) setState(() => _heard = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          _stt.stop();
          if (mounted) setState(() => _mic = false);
          _send(r.recognizedWords.trim(), byVoice: true);
        }
      },
      localeId: _lang=='te'?'te-IN':_lang=='hi'?'hi-IN':_lang=='ta'?'ta-IN':'en-IN',
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _send(String text, {bool byVoice = false}) async {
    final t = text.trim();
    if (t.isEmpty || _loading) return;
    _c.clear(); _heard = '';
    final ln = _lang=='te'?'Telugu':_lang=='hi'?'Hindi':_lang=='ta'?'Tamil':'English';
    final prompt = '[Reply in $ln] $t';
    setState(() {
      _msgs.add(_Msg(t, true, byVoice: byVoice));
      _loading = true; _status = '⏳ Getting answer...';
    });
    _sd();
    final t1 = Timer(const Duration(seconds:4),  (){if(mounted&&_loading) setState(()=>_status='🤔 Thinking...');});
    final t2 = Timer(const Duration(seconds:12), (){if(mounted&&_loading) setState(()=>_status='⌛ Almost ready...');});
    final ans = await _AI.ask(prompt);
    t1.cancel(); t2.cancel();
    if (mounted) {
      setState(() { _msgs.add(_Msg(ans,false)); _loading=false; _status=''; });
      _sd(); _spk(ans);
    }
  }

  Future<void> _spk(String t) async {
    if (kIsWeb) return;
    // Stop any current speech first
    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 150));
    // Set language BEFORE speaking
    final lang = _lang=='te'?'te-IN':_lang=='hi'?'hi-IN':_lang=='ta'?'ta-IN':'en-IN';
    await _tts.setLanguage(lang);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.44);
    await _tts.setVolume(1.0);
    final text = t.length > 400 ? t.substring(0, 400) : t;
    setState(() => _talking = true);
    final result = await _tts.speak(text);
    debugPrint('TTS speak result: \$result');
    // If TTS fails (returns non-1), reset state
    if (result != 1 && mounted) {
      setState(() => _talking = false);
    }
  }

  void _sd() => Future.delayed(const Duration(milliseconds:250),(){
    if (_sc.hasClients) _sc.animateTo(_sc.position.maxScrollExtent,
        duration: const Duration(milliseconds:350), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext ctx) => Container(
    height: MediaQuery.of(ctx).size.height * 0.93,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors:[Color(0xFF061A0E),Color(0xFF0D2E18)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter),
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(children:[
      _handle(), _header(), _langPicker(), _tileRow(),
      Expanded(child: _chatList()),
      if (_mic) _liveBar(),
      if (_loading) _thinkBar(),
      _inputBar(ctx),
    ]),
  );

  Widget _handle() => Padding(
    padding: const EdgeInsets.only(top:10,bottom:4),
    child: Center(child:Container(width:44,height:4,
        decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(2)))));

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16,4,16,8),
    child: Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
      // 👨‍🌾 Farmer logo (tappable mic)
      GestureDetector(
        onTap: _toggleMic,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_,ch)=>Transform.scale(scale:1.0+_pulse.value*(_mic?0.10:0.04),child:ch),
          child: Container(
            width:62, height:62,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors:_mic
                  ?[KisanColors.alertRed,const Color(0xFF8B0000)]
                  :_talking?[KisanColors.sun,const Color(0xFFB05E00)]
                  :[KisanColors.leafMid,KisanColors.leafDeep],
                begin:Alignment.topLeft,end:Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow:[BoxShadow(
                color:(_mic?KisanColors.alertRed:_talking?KisanColors.sun:KisanColors.leafMid).withOpacity(0.55),
                blurRadius:18,spreadRadius:3)],
            ),
            child: Column(mainAxisAlignment:MainAxisAlignment.center,mainAxisSize:MainAxisSize.min,children:[
              _mic || _talking
                ? Text(_mic?'🎙️':'🔊', style:const TextStyle(fontSize:28))
                : ClipOval(child:Image.asset('assets/images/kisanai_logo.png',
                    width:42,height:42,fit:BoxFit.cover,
                    errorBuilder:(_,__,___)=>const Text('👨‍🌾',style:TextStyle(fontSize:28)))),
              const SizedBox(height:2),
              Text(_mic?'Stop':_talking?'Stop':'Speak',
                  style:GoogleFonts.nunito(color:Colors.white,fontSize:9,fontWeight:FontWeight.w900)),
            ]),
          ),
        ),
      ),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Text('KisanAI',style:GoogleFonts.lora(color:Colors.white,fontSize:18,fontWeight:FontWeight.w700)),
          const SizedBox(width:8),
          Container(
            padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),
            decoration:BoxDecoration(color:KisanColors.leafMid.withOpacity(0.35),
                borderRadius:BorderRadius.circular(8),
                border:Border.all(color:KisanColors.leafLight.withOpacity(0.3))),
            child:Row(mainAxisSize:MainAxisSize.min,children:[
              Container(width:6,height:6,decoration:const BoxDecoration(color:Color(0xFF00FF88),shape:BoxShape.circle)),
              const SizedBox(width:4),
              Text('Groq AI',style:GoogleFonts.nunito(color:KisanColors.leafLight,fontSize:9,fontWeight:FontWeight.w800)),
            ]),
          ),
        ]),
        const SizedBox(height:2),
        Text(
          _mic?'🎙️ Listening... speak now'
          :_talking?'🔊 Reading answer aloud...'
          :_loading?_status:'Tap 👨‍🌾 to speak  •  Type  •  Tap tiles',
          style:GoogleFonts.nunito(
              color:_mic?const Color(0xFFFF6B6B):_talking?KisanColors.sun:KisanColors.leafLight,
              fontSize:11,fontWeight:FontWeight.w700),
          maxLines:1,overflow:TextOverflow.ellipsis),
      ])),
      if (_talking) GestureDetector(
        onTap:(){_tts.stop();setState(()=>_talking=false);},
        child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
          decoration:BoxDecoration(color:KisanColors.sun.withOpacity(0.15),borderRadius:BorderRadius.circular(10),border:Border.all(color:KisanColors.sun.withOpacity(0.5))),
          child:Text('⏹ Stop',style:GoogleFonts.nunito(color:KisanColors.sun,fontSize:11,fontWeight:FontWeight.w800)))),
      if(!_talking&&!_loading&&_msgs.where((m)=>!m.isUser).isNotEmpty)...[
        const SizedBox(width:6),
        GestureDetector(
          onTap:(){_spk(_msgs.lastWhere((m)=>!m.isUser).text);},
          child:Container(padding:const EdgeInsets.all(8),
            decoration:BoxDecoration(color:KisanColors.leafMid.withOpacity(0.2),borderRadius:BorderRadius.circular(10),border:Border.all(color:KisanColors.leafMid.withOpacity(0.4))),
            child:const Icon(Icons.replay_rounded,color:KisanColors.leafLight,size:18))),
      ],
    ]),
  );

  Widget _langPicker() => SizedBox(height:32,child:ListView(
    scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:14),
    children:[for(final l in [['en','🇬🇧 English'],['te','🇮🇳 Telugu'],['hi','🇮🇳 Hindi'],['ta','🇮🇳 Tamil']])
      GestureDetector(
        onTap:()async{setState(()=>_lang=l[0]);await _tts.setLanguage(l[0]=='te'?'te-IN':l[0]=='hi'?'hi-IN':l[0]=='ta'?'ta-IN':'en-IN');},
        child:Container(margin:const EdgeInsets.only(right:8),padding:const EdgeInsets.symmetric(horizontal:12,vertical:4),
          decoration:BoxDecoration(color:_lang==l[0]?KisanColors.leafMid:KisanColors.leafMid.withOpacity(0.15),borderRadius:BorderRadius.circular(16),
            border:Border.all(color:_lang==l[0]?KisanColors.leafLight:KisanColors.leafMid.withOpacity(0.3),width:1.5)),
          child:Text(l[1],style:GoogleFonts.nunito(color:_lang==l[0]?Colors.white:KisanColors.leafLight,fontSize:11,fontWeight:FontWeight.w800))),
      )],
  ));

  Widget _tileRow() => SizedBox(height:90,child:ListView.builder(
    scrollDirection:Axis.horizontal,padding:const EdgeInsets.fromLTRB(14,8,14,0),
    itemCount:_tiles.length,
    itemBuilder:(_,i){final t=_tiles[i];return GestureDetector(
      onTap:()=>_send(t['q']!),
      child:Container(width:70,margin:const EdgeInsets.only(right:10),
        decoration:BoxDecoration(color:const Color(0xFF163020),borderRadius:BorderRadius.circular(14),border:Border.all(color:KisanColors.leafMid.withOpacity(0.35))),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Text(t['e']!,style:const TextStyle(fontSize:26)),
          const SizedBox(height:4),
          Padding(padding:const EdgeInsets.symmetric(horizontal:4),
            child:Text(t['l']!,textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,
              style:GoogleFonts.nunito(color:Colors.white,fontSize:9,fontWeight:FontWeight.w800,height:1.2))),
        ]),
      ),
    );},
  ));

  Widget _chatList() => ListView.builder(
    controller:_sc,padding:const EdgeInsets.fromLTRB(12,10,12,6),
    itemCount:_msgs.length,itemBuilder:(_,i)=>_bubble(_msgs[i]));

  Widget _bubble(_Msg m) => Padding(
    padding:const EdgeInsets.only(bottom:12),
    child:Row(mainAxisAlignment:m.isUser?MainAxisAlignment.end:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.end,children:[
      // 👨‍🌾 AI farmer avatar
      if(!m.isUser)...[
        Container(width:32,height:32,
          decoration:const BoxDecoration(shape:BoxShape.circle),
          child:ClipOval(child:Image.asset('assets/images/kisanai_logo.png',
            width:32,height:32,fit:BoxFit.cover,
            errorBuilder:(_,__,___)=>Container(
              decoration:const BoxDecoration(gradient:LinearGradient(colors:[KisanColors.leafMid,KisanColors.leafLight]),shape:BoxShape.circle),
              child:const Center(child:Text('👨‍🌾',style:TextStyle(fontSize:17))))))),
        const SizedBox(width:8),
      ],
      Flexible(child:Column(crossAxisAlignment:m.isUser?CrossAxisAlignment.end:CrossAxisAlignment.start,children:[
        Container(
          padding:const EdgeInsets.fromLTRB(14,10,14,10),
          decoration:BoxDecoration(
            color:m.isUser?KisanColors.leafMid:const Color(0xFF163020),
            borderRadius:BorderRadius.only(topLeft:const Radius.circular(18),topRight:const Radius.circular(18),
              bottomLeft:Radius.circular(m.isUser?18:4),bottomRight:Radius.circular(m.isUser?4:18)),
            border:m.isUser?null:Border.all(color:KisanColors.leafMid.withOpacity(0.25))),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            if(m.byVoice&&m.isUser) Padding(padding:const EdgeInsets.only(bottom:4),
              child:Row(children:[const Icon(Icons.mic,color:KisanColors.leafLight,size:11),const SizedBox(width:3),
                Text('Voice',style:GoogleFonts.nunito(color:KisanColors.leafLight,fontSize:9,fontWeight:FontWeight.w800))])),
            SelectableText(m.text,style:GoogleFonts.nunito(color:Colors.white,fontSize:13,fontWeight:FontWeight.w600,height:1.5)),
          ])),
        const SizedBox(height:2),
        Row(mainAxisSize:MainAxisSize.min,children:[
          Text('${m.time.hour.toString().padLeft(2,'0')}:${m.time.minute.toString().padLeft(2,'0')}',
              style:GoogleFonts.nunito(color:Colors.white30,fontSize:9,fontWeight:FontWeight.w600)),
          if(!m.isUser)...[const SizedBox(width:8),GestureDetector(onTap:()=>_spk(m.text),
            child:Row(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.volume_up_rounded,color:KisanColors.leafLight,size:13),const SizedBox(width:2),
              Text('Hear',style:GoogleFonts.nunito(color:KisanColors.leafLight,fontSize:9,fontWeight:FontWeight.w800))]))],
        ]),
      ])),
      // 🧑‍🌾 User avatar
      if(m.isUser)...[const SizedBox(width:8),
        Container(width:32,height:32,decoration:BoxDecoration(color:KisanColors.leafMid.withOpacity(0.5),shape:BoxShape.circle),
          child:const Center(child:Text('🧑‍🌾',style:TextStyle(fontSize:17))))],
    ]),
  );

  Widget _liveBar() => Container(
    margin:const EdgeInsets.fromLTRB(14,0,14,6),
    padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),
    decoration:BoxDecoration(color:KisanColors.alertRed.withOpacity(0.15),borderRadius:BorderRadius.circular(14),border:Border.all(color:KisanColors.alertRed.withOpacity(0.4))),
    child:Row(children:[const Icon(Icons.mic,color:KisanColors.alertRed,size:18),const SizedBox(width:8),
      Expanded(child:Text(_heard.isEmpty?'Listening... speak now':'"$_heard"',
        style:GoogleFonts.nunito(color:_heard.isEmpty?Colors.white54:Colors.white,fontSize:13,fontWeight:FontWeight.w700,fontStyle:_heard.isEmpty?FontStyle.italic:FontStyle.normal)))]));

  Widget _thinkBar() => Padding(
    padding:const EdgeInsets.fromLTRB(16,0,16,6),
    child:Row(children:[
      Container(width:28,height:28,
        decoration:const BoxDecoration(shape:BoxShape.circle),
        child:ClipOval(child:Image.asset('assets/images/kisanai_logo.png',
          width:28,height:28,fit:BoxFit.cover,
          errorBuilder:(_,__,___)=>Container(
            decoration:const BoxDecoration(gradient:LinearGradient(colors:[KisanColors.leafMid,KisanColors.leafLight]),shape:BoxShape.circle),
            child:const Center(child:Text('👨‍🌾',style:TextStyle(fontSize:15))))))),
      const SizedBox(width:8),
      Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
        decoration:BoxDecoration(color:const Color(0xFF163020),borderRadius:BorderRadius.circular(16),border:Border.all(color:KisanColors.leafMid.withOpacity(0.25))),
        child:Row(mainAxisSize:MainAxisSize.min,children:[
          _dt(0),const SizedBox(width:4),_dt(200),const SizedBox(width:4),_dt(400),const SizedBox(width:8),
          Text(_status.isEmpty?'Thinking...':_status,style:GoogleFonts.nunito(color:KisanColors.leafLight,fontSize:12,fontWeight:FontWeight.w600)),
        ])),
    ]));

  Widget _dt(int d) => TweenAnimationBuilder<double>(
    tween:Tween(begin:0.3,end:1.0),duration:Duration(milliseconds:600+d),curve:Curves.easeInOut,
    builder:(_,v,__)=>Opacity(opacity:v,child:Container(width:7,height:7,
        decoration:const BoxDecoration(color:KisanColors.leafLight,shape:BoxShape.circle))));

  Widget _inputBar(BuildContext ctx) => Container(
    padding:EdgeInsets.fromLTRB(12,8,12,MediaQuery.of(ctx).viewInsets.bottom+12),
    decoration:BoxDecoration(color:const Color(0xFF061A0E),border:Border(top:BorderSide(color:KisanColors.leafMid.withOpacity(0.2)))),
    child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
      // Big mic
      GestureDetector(onTap:_toggleMic,child:AnimatedContainer(
        duration:const Duration(milliseconds:250),width:56,height:56,
        decoration:BoxDecoration(
          gradient:LinearGradient(colors:_mic?[KisanColors.alertRed,const Color(0xFF8B0000)]:[KisanColors.leafMid,KisanColors.leafDeep]),
          shape:BoxShape.circle,
          boxShadow:[BoxShadow(color:(_mic?KisanColors.alertRed:KisanColors.leafMid).withOpacity(_mic?0.7:0.4),blurRadius:_mic?20:10,spreadRadius:_mic?4:1)]),
        child:Center(child:Text(_mic?'⏹️':'🎙️',style:const TextStyle(fontSize:24))))),
      const SizedBox(width:8),
      // Text field
      Expanded(child:Container(
        constraints:const BoxConstraints(minHeight:44,maxHeight:100),
        decoration:BoxDecoration(color:const Color(0xFF163020),borderRadius:BorderRadius.circular(22),border:Border.all(color:KisanColors.leafMid.withOpacity(0.4),width:1.5)),
        child:TextField(controller:_c,maxLines:null,minLines:1,textInputAction:TextInputAction.send,onSubmitted:_send,
          style:GoogleFonts.nunito(color:Colors.white,fontSize:13,fontWeight:FontWeight.w600),
          decoration:InputDecoration(hintText:'Type anything — hello, crops, any language...',
            hintStyle:GoogleFonts.nunito(color:Colors.white30,fontSize:11,fontWeight:FontWeight.w600),
            border:InputBorder.none,contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:11))))),
      const SizedBox(width:8),
      // Send
      GestureDetector(onTap:()=>_send(_c.text),child:AnimatedContainer(
        duration:const Duration(milliseconds:200),width:46,height:46,
        decoration:BoxDecoration(
          gradient:LinearGradient(colors:_loading?[Colors.grey.shade700,Colors.grey.shade600]:[KisanColors.sun,const Color(0xFFCC7A00)],begin:Alignment.topLeft,end:Alignment.bottomRight),
          shape:BoxShape.circle,
          boxShadow:_loading?[]:[ BoxShadow(color:KisanColors.sun.withOpacity(0.4),blurRadius:8,offset:const Offset(0,2))]),
        child:const Center(child:Icon(Icons.send_rounded,color:Colors.white,size:20)))),
    ]),
  );
}
