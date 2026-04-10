import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/disease_detector.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reels_screen.dart';
import 'screens/tractor_screen.dart';
import 'screens/community_screen.dart';
import 'widgets/gemini_voice_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: KisanColors.leafDeep,
      statusBarIconBrightness: Brightness.light,
    ));
  } catch (_) {}
  diseaseDetector.initialize().catchError((e) => debugPrint('AI init: $e'));
  bool loggedIn = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool('is_logged_in') ?? false;
  } catch (e) {
    debugPrint('Prefs error: $e');
  }
  runApp(KisanAIApp(loggedIn: loggedIn));
}

class KisanAIApp extends StatelessWidget {
  final bool loggedIn;
  const KisanAIApp({super.key, required this.loggedIn});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'KisanAI',
    debugShowCheckedModeBanner: false,
    theme: KisanTheme.theme,
    initialRoute: loggedIn ? '/home' : '/login',
    routes: {
      '/login': (_) => const LoginScreen(),
      '/home':  (_) => const MainNavigator(),
    },
  );
}

// ─── Main Navigator — 5 tabs: Home | Reels | AI(big) | Tractor | Community ──
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _NavState();
}

class _NavState extends State<MainNavigator> {
  int _idx = 0;

  // 5 screens only
  static const _screens = <Widget>[
    HomeScreen(),      // 0  Home
    ReelsScreen(),     // 1  Reels
    _ChatbotScreen(),  // 2  AI Chatbot (centre, big)
    TractorScreen(),   // 3  Tractor
    CommunityScreen(), // 4  Community
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _screens),
    bottomNavigationBar: _buildNav(),
  );

  Widget _buildNav() => Container(
    height: 72,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, -3))],
    ),
    child: Row(children: [
      _tab(0, Icons.home_rounded,       Icons.home_outlined,         'Home'),
      _tab(1, Icons.play_circle_filled, Icons.play_circle_outline,   'Reels'),
      _aiTab(),   // Centre big AI tab
      _tab(3, Icons.agriculture_rounded, Icons.agriculture_outlined, 'Tractor'),
      _tab(4, Icons.groups_rounded,     Icons.groups_outlined,       'Community'),
    ]),
  );

  // Regular tab
  Widget _tab(int i, IconData active, IconData inactive, String label) {
    final on = _idx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _idx = i),
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: on ? KisanColors.leafPale : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(on ? active : inactive, size: 24,
                color: on ? KisanColors.leaf : KisanColors.textLight),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
              fontSize: 9, fontWeight: on ? FontWeight.w800 : FontWeight.w600,
              color: on ? KisanColors.leaf : KisanColors.textLight)),
        ]),
      ),
    );
  }

  // Centre AI tab — bigger, elevated, farmer image
  Widget _aiTab() => GestureDetector(
    onTap: () => setState(() => _idx = 2),
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 80,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Elevated farmer logo button — bigger than others
        Transform.translate(
          offset: const Offset(0, -10),
          child: Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              gradient: _idx == 2
                  ? const LinearGradient(colors: [KisanColors.sun, Color(0xFFCC7A00)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : const LinearGradient(colors: [KisanColors.leafMid, KisanColors.leafDeep],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: (_idx == 2 ? KisanColors.sun : KisanColors.leafMid).withOpacity(0.5),
                    blurRadius: 14, spreadRadius: 2, offset: const Offset(0, 3)),
              ],
            ),
            // Farmer image as chatbot icon
            child: ClipOval(child: Image.asset(
              'assets/images/kisanai_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                  child: Text('👨‍🌾', style: TextStyle(fontSize: 28))),
            )),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Text('AI Chat',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _idx == 2 ? KisanColors.sun : KisanColors.leaf)),
        ),
      ]),
    ),
  );
}

// ─── Chatbot Screen wrapper — embeds VoiceListeningSheet as a full screen ────
class _ChatbotScreen extends StatelessWidget {
  const _ChatbotScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF061A0E),
    body: Column(children: [
      // Status bar spacer
      SizedBox(height: MediaQuery.of(context).padding.top),
      // Full chatbot embedded — not a bottom sheet
      const Expanded(child: _ChatbotBody()),
    ]),
  );
}

class _ChatbotBody extends StatelessWidget {
  const _ChatbotBody();

  @override
  Widget build(BuildContext context) => const VoiceListeningSheet();
}
