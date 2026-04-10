// KisanAI – Weather Screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WS();
}

class _WS extends State<WeatherScreen> {
  bool _loading = true;
  int _sel = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    await WeatherService.i.fetchWeather();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A2E4A),
    body: RefreshIndicator(
      onRefresh: _fetch,
      color: Colors.white,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0A2E4A),
          pinned: true,
          expandedHeight: 0,
          title: Text('🌦️ Weather Forecast',
              style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          actions: [
            IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh, color: Colors.white)),
          ],
        ),
        SliverToBoxAdapter(child: _loading ? _loader() : _content()),
      ]),
    ),
  );

  Widget _loader() => const SizedBox(height: 300,
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text('Getting your location…', style: TextStyle(color: Colors.white70, fontSize: 13)),
      ])));

  Widget _content() {
    final w = WeatherService.i.current;
    final days = WeatherService.i.forecast;
    if (w == null || days.isEmpty) return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Text('📍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('Allow location access for real weather',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _fetch,
          style: ElevatedButton.styleFrom(backgroundColor: KisanColors.leafMid),
          child: Text('Retry', style: GoogleFonts.nunito(fontWeight: FontWeight.w800))),
      ]),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Current weather card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0A2E4A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📍 ${w.cityName}', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(children: [
              Text(w.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${w.temp.toStringAsFixed(1)}°C',
                    style: GoogleFonts.lora(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w700)),
                Text(w.condition, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _chip('💧 ${w.humidity}% Humidity'),
              const SizedBox(width: 10),
              _chip('🌬️ ${w.windKph.toStringAsFixed(0)} km/h'),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(days.first.sprayAdvice,
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        Text('7-DAY FORECAST', style: GoogleFonts.nunito(
            color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 12),

        // 7-day list
        ...List.generate(days.length, (i) {
          final d = days[i];
          final sel = _sel == i;
          return GestureDetector(
            onTap: () => setState(() => _sel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: sel ? KisanColors.leafMid.withOpacity(0.3) : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? KisanColors.leafLight.withOpacity(0.5) : Colors.transparent),
              ),
              child: Row(children: [
                SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.day, style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                  Text(d.date, style: GoogleFonts.nunito(color: Colors.white54, fontSize: 10)),
                ])),
                Text(d.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(child: Text(d.condition, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))),
                if (d.rainMm > 0.5) Text('💧${d.rainMm.toStringAsFixed(0)}mm',
                    style: GoogleFonts.nunito(color: const Color(0xFF64B5F6), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('${d.maxTemp.toStringAsFixed(0)}°',
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(' / ${d.minTemp.toStringAsFixed(0)}°',
                    style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
              ]),
            ),
          );
        }),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)));
}
