// KisanAI – Weather Service
// Uses Open-Meteo (100% free, no API key needed) + Geolocator
// Returns real weather for farmer's exact GPS location

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherDay {
  final String day;       // Mon, Tue…
  final String date;      // Mar 15
  final double maxTemp;
  final double minTemp;
  final int    weatherCode;
  final double rainMm;
  final int    humidity;
  final double windKph;

  const WeatherDay({
    required this.day, required this.date, required this.maxTemp,
    required this.minTemp, required this.weatherCode, required this.rainMm,
    required this.humidity, required this.windKph,
  });

  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 57) return '🌦️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 86) return '🌨️';
    return '⛈️';
  }

  String get condition {
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 57) return 'Light Rain';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain Showers';
    return 'Thunderstorm';
  }

  /// Farming spray advice based on weather
  String get sprayAdvice {
    if (rainMm > 5) return '🚫 Do NOT spray — rain expected';
    if (humidity > 85) return '⚠️ High humidity — fungal risk';
    if (weatherCode > 60) return '🚫 Skip spray — wet conditions';
    if (maxTemp > 38) return '⚠️ Too hot — spray early morning only';
    return '✅ Good day to spray — 6-9 AM best';
  }
}

class CurrentWeather {
  final double temp;
  final int    humidity;
  final double windKph;
  final int    weatherCode;
  final String cityName;
  final double lat, lon;

  const CurrentWeather({
    required this.temp, required this.humidity, required this.windKph,
    required this.weatherCode, required this.cityName,
    required this.lat, required this.lon,
  });

  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    return '⛈️';
  }

  String get condition {
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    return 'Thunderstorm';
  }
}

class WeatherService {
  static WeatherService? _instance;
  static WeatherService get i => _instance ??= WeatherService._();
  WeatherService._();

  CurrentWeather? _current;
  List<WeatherDay> _forecast = [];
  DateTime? _lastFetch;

  CurrentWeather? get current => _current;
  List<WeatherDay> get forecast => _forecast;

  Future<bool> fetchWeather() async {
    // Cache for 30 minutes
    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 30 &&
        _current != null) {
      return true;
    }

    try {
      // Get GPS location
      final pos = await _getLocation();
      if (pos == null) return false;

      final lat = pos.latitude;
      final lon = pos.longitude;

      // Get city name via reverse geocoding (free)
      final city = await _getCityName(lat, lon);

      // Fetch weather from Open-Meteo (completely free, no key needed)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,'
        'relative_humidity_2m_max,wind_speed_10m_max'
        '&timezone=Asia/Kolkata'
        '&forecast_days=7',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return false;

      final j = jsonDecode(res.body) as Map;
      final cur = j['current'] as Map;
      final daily = j['daily'] as Map;

      _current = CurrentWeather(
        temp:        (cur['temperature_2m'] as num).toDouble(),
        humidity:    (cur['relative_humidity_2m'] as num).toInt(),
        windKph:     (cur['wind_speed_10m'] as num).toDouble(),
        weatherCode: (cur['weather_code'] as num).toInt(),
        cityName:    city,
        lat: lat, lon: lon,
      );

      final dates = (daily['time'] as List).cast<String>();
      _forecast = List.generate(7, (i) {
        final d = DateTime.parse(dates[i]);
        final days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return WeatherDay(
          day:         i == 0 ? 'Today' : i == 1 ? 'Tomorrow' : days[d.weekday % 7],
          date:        '${d.day} ${months[d.month - 1]}',
          maxTemp:     (daily['temperature_2m_max'][i] as num).toDouble(),
          minTemp:     (daily['temperature_2m_min'][i] as num).toDouble(),
          weatherCode: (daily['weather_code'][i] as num).toInt(),
          rainMm:      (daily['precipitation_sum'][i] as num).toDouble(),
          humidity:    (daily['relative_humidity_2m_max'][i] as num).toInt(),
          windKph:     (daily['wind_speed_10m_max'][i] as num).toDouble(),
        );
      });

      _lastFetch = DateTime.now();
      return true;
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      return false;
    }
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return null;
      }
      if (perm == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json');
      final res = await http.get(url,
          headers: {'User-Agent': 'KisanAI/1.0'}).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map;
        final addr = j['address'] as Map?;
        if (addr != null) {
          return addr['city'] as String? ??
              addr['town'] as String? ??
              addr['village'] as String? ??
              addr['state_district'] as String? ??
              'Your Location';
        }
      }
    } catch (_) {}
    return 'Your Location';
  }
}
