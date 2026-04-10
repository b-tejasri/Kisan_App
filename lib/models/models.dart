// Market Price Model
class MarketPrice {
  final String emoji;
  final String cropName;
  final double price;
  final double change;
  final String unit;

  const MarketPrice({
    required this.emoji,
    required this.cropName,
    required this.price,
    required this.change,
    required this.unit,
  });

  bool get isUp => change >= 0;
}

// Alert Model
class FarmAlert {
  final String emoji;
  final String title;
  final String description;
  final AlertLevel level;
  final String badge;

  const FarmAlert({
    required this.emoji,
    required this.title,
    required this.description,
    required this.level,
    required this.badge,
  });
}

enum AlertLevel { red, yellow, green, blue }

// Forecast Day Model
class ForecastDay {
  final String dayName;
  final String weatherEmoji;
  final int tempC;
  final DiseaseRisk risk;

  const ForecastDay({
    required this.dayName,
    required this.weatherEmoji,
    required this.tempC,
    required this.risk,
  });
}

enum DiseaseRisk { low, medium, high }

// Govt Scheme Model
class GovtScheme {
  final String emoji;
  final String tag;
  final String title;
  final String description;

  const GovtScheme({
    required this.emoji,
    required this.tag,
    required this.title,
    required this.description,
  });
}

// Quick Action Model
class QuickAction {
  final String emoji;
  final String label;
  final String colorTag; // 'green','gold','blue','red'

  const QuickAction({
    required this.emoji,
    required this.label,
    required this.colorTag,
  });
}

// Sample Data
class SampleData {
  static const List<MarketPrice> marketPrices = [
    MarketPrice(emoji: '🌾', cropName: 'Paddy Rice', price: 2180, change: 180, unit: 'Per Quintal'),
    MarketPrice(emoji: '🌽', cropName: 'Maize', price: 1640, change: -40, unit: 'Per Quintal'),
    MarketPrice(emoji: '🧅', cropName: 'Onion', price: 890, change: 55, unit: 'Per Quintal'),
    MarketPrice(emoji: '🌶️', cropName: 'Chilli', price: 4200, change: 120, unit: 'Per Quintal'),
    MarketPrice(emoji: '🥜', cropName: 'Groundnut', price: 5800, change: -80, unit: 'Per Quintal'),
  ];

  static const List<FarmAlert> alerts = [
    FarmAlert(
      emoji: '🐛', title: 'Pest Nearby', badge: '🔴 URGENT',
      description: 'Locusts reported 8km away. Prepare now.',
      level: AlertLevel.red,
    ),
    FarmAlert(
      emoji: '🌧️', title: 'Rain Alert', badge: '⚠️ NOW',
      description: 'Heavy rain in 2 days. Skip spraying.',
      level: AlertLevel.yellow,
    ),
    FarmAlert(
      emoji: '🌱', title: 'Crop Healthy', badge: '✅ OK',
      description: 'No disease detected today. Keep it up!',
      level: AlertLevel.green,
    ),
    FarmAlert(
      emoji: '📈', title: 'Sell Now!', badge: '💰 ACT',
      description: 'Rice prices up ₹180. Best time this week.',
      level: AlertLevel.blue,
    ),
  ];

  static const List<ForecastDay> forecast = [
    ForecastDay(dayName: 'THU', weatherEmoji: '☀️', tempC: 31, risk: DiseaseRisk.low),
    ForecastDay(dayName: 'FRI', weatherEmoji: '⛅', tempC: 28, risk: DiseaseRisk.low),
    ForecastDay(dayName: 'SAT', weatherEmoji: '🌧️', tempC: 24, risk: DiseaseRisk.medium),
    ForecastDay(dayName: 'SUN', weatherEmoji: '⛈️', tempC: 22, risk: DiseaseRisk.high),
    ForecastDay(dayName: 'MON', weatherEmoji: '🌦️', tempC: 25, risk: DiseaseRisk.medium),
    ForecastDay(dayName: 'TUE', weatherEmoji: '⛅', tempC: 27, risk: DiseaseRisk.low),
    ForecastDay(dayName: 'WED', weatherEmoji: '☀️', tempC: 30, risk: DiseaseRisk.low),
  ];

  static const List<GovtScheme> schemes = [
    GovtScheme(
      emoji: '💵', tag: 'New · PM-KISAN',
      title: '₹2,000 arriving in 4 days!',
      description: 'Tap to check eligibility & status',
    ),
    GovtScheme(
      emoji: '🛡️', tag: 'Deadline · 5 Days',
      title: 'Fasal Bima – Enrol Now',
      description: 'Crop insurance deadline approaching',
    ),
    GovtScheme(
      emoji: '🏦', tag: 'Open · KCC Loan',
      title: 'Kisan Credit Card Available',
      description: 'Low-interest loan up to ₹3 lakh',
    ),
  ];

  static const List<QuickAction> quickActions = [
    QuickAction(emoji: '📷', label: 'Scan\nCrop', colorTag: 'green'),
    QuickAction(emoji: '📊', label: 'Market\nPrice', colorTag: 'gold'),
    QuickAction(emoji: '🛒', label: 'Buy\nFertilizer', colorTag: 'blue'),
    QuickAction(emoji: '🌦️', label: 'Weather\nForecast', colorTag: 'blue'),
    QuickAction(emoji: '🚜', label: 'Rent\nTractor', colorTag: 'red'),
    QuickAction(emoji: '💰', label: 'Govt\nSchemes', colorTag: 'gold'),
    QuickAction(emoji: '🎙️', label: 'AI\nAssistant', colorTag: 'green'),
    QuickAction(emoji: '👥', label: 'Community', colorTag: 'red'),
  ];
}
