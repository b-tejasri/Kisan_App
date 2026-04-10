// KisanAI – Disease Detector Service
// Works on Web + Android + iOS. No tflite needed to compile.
// Falls back to demo mode when model file is absent.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

// ─────────────────────────────────────────────────────────────────────────────
//  Fertilizer Recommendation Model
// ─────────────────────────────────────────────────────────────────────────────
class FertilizerRec {
  final String name;
  final String type; // 'Organic' or 'Chemical'
  final String dose;
  final String timing;
  final String benefit;
  final double pricePerKg;

  const FertilizerRec({
    required this.name,
    required this.type,
    required this.dose,
    required this.timing,
    required this.benefit,
    required this.pricePerKg,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Disease Result Model
// ─────────────────────────────────────────────────────────────────────────────
class DiseaseResult {
  final String label;
  final double confidence;
  final String crop;
  final String disease;
  final String severity;
  final String symptoms;
  final String organicTreatment;
  final String chemicalTreatment;
  final String prevention;
  final String voiceTelugu;
  final String voiceHindi;
  final String voiceTamil;
  final List<FertilizerRec> fertilizers;

  const DiseaseResult({
    required this.label,
    required this.confidence,
    required this.crop,
    required this.disease,
    required this.severity,
    required this.symptoms,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.prevention,
    required this.voiceTelugu,
    required this.voiceHindi,
    required this.voiceTamil,
    required this.fertilizers,
  });

  bool get isHealthy => disease == 'Healthy';

  String get severityEmoji {
    switch (severity) {
      case 'Very High':
        return '🚨';
      case 'High':
        return '🔴';
      case 'Medium':
        return '🟠';
      case 'Low':
        return '🟡';
      default:
        return '✅';
    }
  }

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Embedded Disease + Fertilizer Database
// ─────────────────────────────────────────────────────────────────────────────
class _DB {
  // Each entry: crop, disease, severity, symptoms, organic, chemical,
  //             prevention, telugu, hindi, tamil,
  //             fertilizers: [ {name, type, dose, timing, benefit, price} ]
  static const _raw = <String, Map<String, dynamic>>{
    'Rice_Blast': {
      'crop': 'Rice',
      'disease': 'Rice Blast',
      'severity': 'High',
      'symptoms': 'Diamond-shaped lesions with grey center and brown border on leaves.',
      'organic': 'Spray Pseudomonas fluorescens 10g/L. Remove infected leaves immediately.',
      'chemical': 'Tricyclazole 75 WP @ 0.6g/L. Spray every 10 days for 3 applications.',
      'prevention': 'Use resistant varieties. Avoid excess nitrogen. Maintain field hygiene.',
      'telugu': 'వరి బ్లాస్ట్ వ్యాధి - ట్రైసైక్లజోల్ మందు పిచికారీ చేయండి',
      'hindi': 'धान का ब्लास्ट - ट्राइसाइक्लाजोल दवा का छिड़काव करें',
      'tamil': 'நெல் வெடிப்பு நோய் - ட்ரைசைக்லசோல் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Neem Cake',
          'type': 'Organic',
          'dose': '200 kg/acre at transplanting',
          'timing': 'Before transplanting',
          'benefit': 'Suppresses soil pathogens and adds slow-release nitrogen',
          'price': 8.0
        },
        {
          'name': 'Trichoderma viride Bio-fungicide',
          'type': 'Organic',
          'dose': '2.5 kg/acre — dissolve in water and spray',
          'timing': 'Weekly foliar spray',
          'benefit': 'Biological fungal disease control, safe for environment',
          'price': 120.0
        },
        {
          'name': 'Potassium Silicate',
          'type': 'Chemical',
          'dose': '2g/L as preventive foliar spray',
          'timing': 'Preventive — spray before disease appears',
          'benefit': 'Strengthens leaf cell walls, highly effective against blast',
          'price': 180.0
        },
        {
          'name': 'Zinc Sulphate 21%',
          'type': 'Chemical',
          'dose': '10 kg/acre as basal dose',
          'timing': 'Before transplanting',
          'benefit': 'Corrects zinc deficiency, improves disease resistance',
          'price': 45.0
        },
      ],
    },

    'Rice_BrownSpot': {
      'crop': 'Rice',
      'disease': 'Brown Leaf Spot',
      'severity': 'Medium',
      'symptoms': 'Oval/circular brown spots with yellow halo. Appears on older leaves first.',
      'organic': 'Neem oil spray 5ml/L. Apply potassium-rich organic compost to soil.',
      'chemical': 'Propiconazole 25 EC @ 1ml/L or Mancozeb 75 WP @ 2g/L. Repeat after 14 days.',
      'prevention': 'Balanced fertilization. Avoid water stress. Treat seeds before sowing.',
      'telugu': 'గోధుమ మచ్చ వ్యాధి - ప్రొపికొనజోల్ పిచికారీ చేయండి',
      'hindi': 'भूरा धब्बा रोग - प्रोपिकोनाजोल का छिड़काव करें',
      'tamil': 'பழுப்பு புள்ளி நோய் - ப்ரோபிகோனசோல் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Vermicompost',
          'type': 'Organic',
          'dose': '500 kg/acre',
          'timing': 'Before transplanting',
          'benefit': 'Improves soil health and natural disease resistance',
          'price': 6.0
        },
        {
          'name': 'Wood Ash',
          'type': 'Organic',
          'dose': '50 kg/acre top dressing',
          'timing': 'At tillering stage',
          'benefit': 'Adds potassium, reduces fungal growth in soil',
          'price': 2.0
        },
        {
          'name': 'Potassium Chloride (MOP)',
          'type': 'Chemical',
          'dose': '20 kg/acre top dressing',
          'timing': 'At tillering stage',
          'benefit': 'Strengthens plant immunity against brown spot',
          'price': 28.0
        },
        {
          'name': 'Mancozeb 75 WP',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'At first sign of disease',
          'benefit': 'Broad-spectrum protective fungicide',
          'price': 85.0
        },
      ],
    },

    'Rice_Healthy': {
      'crop': 'Rice',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'No disease detected. Crop looks healthy and growing normally.',
      'organic': 'Continue organic compost. Apply green manure crop before transplanting.',
      'chemical': 'Apply Urea top-dressing at tillering. Maintain 5cm water level.',
      'prevention': 'Monitor weekly. Check for yellow leaves which indicate nutrient deficiency.',
      'telugu': 'పంట ఆరోగ్యంగా ఉంది. బాగా జాగ్రత్త తీసుకోండి',
      'hindi': 'फसल स्वस्थ है। अच्छी देखभाल जारी रखें',
      'tamil': 'பயிர் ஆரோக்கியமாக உள்ளது. தொடர்ந்து கவனிக்கவும்',
      'fertilizers': [
        {
          'name': 'FYM + Neem Cake Mix',
          'type': 'Organic',
          'dose': '1 tonne FYM + 100 kg neem cake per acre',
          'timing': 'Before transplanting',
          'benefit': 'Complete organic base nutrition and soil improvement',
          'price': 4.0
        },
        {
          'name': 'Urea 46% Nitrogen',
          'type': 'Chemical',
          'dose': '30 kg/acre split in 3 doses',
          'timing': 'At transplanting, tillering, and panicle initiation',
          'benefit': 'Essential nitrogen for vegetative growth and grain filling',
          'price': 266.0
        },
        {
          'name': 'NPK 17-17-17',
          'type': 'Chemical',
          'dose': '25 kg/acre as basal',
          'timing': 'Before transplanting',
          'benefit': 'Balanced all-round crop nutrition',
          'price': 1200.0
        },
      ],
    },

    'Tomato_EarlyBlight': {
      'crop': 'Tomato',
      'disease': 'Early Blight',
      'severity': 'Medium',
      'symptoms': 'Dark brown spots with concentric rings (target pattern) on older leaves.',
      'organic': 'Neem oil 5ml/L + baking soda 5g/L spray. Remove affected leaves immediately.',
      'chemical': 'Mancozeb 75 WP @ 2.5g/L or Chlorothalonil 75 WP @ 2g/L every 7 days.',
      'prevention': 'Crop rotation every season. Mulching. Avoid overhead irrigation.',
      'telugu': 'టొమాటో ప్రారంభ బ్లైట్ - మాంకోజెబ్ పిచికారీ చేయండి',
      'hindi': 'टमाटर अगेती झुलसा - मैंकोजेब का छिड़काव करें',
      'tamil': 'தக்காளி ஆரம்ப கருகல் - மேன்கோசெப் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Panchagavya Bio-spray',
          'type': 'Organic',
          'dose': '30ml/L as foliar spray',
          'timing': 'Weekly spray throughout crop',
          'benefit': 'Boosts plant immunity, improves resistance to blight',
          'price': 40.0
        },
        {
          'name': 'Trichoderma viride',
          'type': 'Organic',
          'dose': '5g/L soil drench around roots',
          'timing': 'Weekly soil application',
          'benefit': 'Biological fungal disease control in soil',
          'price': 110.0
        },
        {
          'name': 'Calcium Nitrate',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'Every 10 days',
          'benefit': 'Strengthens cell walls, significantly reduces blight spread',
          'price': 52.0
        },
        {
          'name': 'Mancozeb 75 WP',
          'type': 'Chemical',
          'dose': '2.5g/L spray',
          'timing': 'At first symptoms, then every 7 days',
          'benefit': 'Best protective fungicide for early blight',
          'price': 85.0
        },
      ],
    },

    'Tomato_LateBlight': {
      'crop': 'Tomato',
      'disease': 'Late Blight',
      'severity': 'Very High',
      'symptoms': 'Greasy water-soaked lesions turning brown-black. White fungal mold under leaves.',
      'organic': 'Copper hydroxide 3g/L spray. Destroy infected plants — do NOT compost them.',
      'chemical': 'Metalaxyl + Mancozeb @ 2.5g/L. Spray every 5-7 days until fully controlled.',
      'prevention': 'Plant resistant varieties. Improve air circulation between plants.',
      'telugu': 'లేట్ బ్లైట్ - మెటలాక్సిల్ మందు వెంటనే పిచికారీ చేయండి',
      'hindi': 'पछेती झुलसा - मेटालेक्सिल का तुरंत छिड़काव करें',
      'tamil': 'பிற்கால கருகல் - மெட்டாலக்சில் உடனே தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Bordeaux Mixture 1%',
          'type': 'Organic',
          'dose': '1kg lime + 1kg CuSO4 per 100L water',
          'timing': 'Preventive spray every 15 days',
          'benefit': 'Traditional copper fungicide — very effective for late blight',
          'price': 25.0
        },
        {
          'name': 'Metalaxyl + Mancozeb 72 WP',
          'type': 'Chemical',
          'dose': '2.5g/L spray',
          'timing': 'Every 5-7 days during active outbreak',
          'benefit': 'Systemic + contact action — penetrates plant tissue',
          'price': 280.0
        },
        {
          'name': 'Potassium Phosphonate',
          'type': 'Chemical',
          'dose': '3ml/L spray or soil drench',
          'timing': 'Preventive and early curative use',
          'benefit': 'Controls late blight systemically with long residual effect',
          'price': 320.0
        },
      ],
    },

    'Tomato_Healthy': {
      'crop': 'Tomato',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Tomato plant is healthy. Good green foliage and flowering visible.',
      'organic': 'Apply compost tea as foliar spray. Mulch around base of plants.',
      'chemical': 'Maintain balanced NPK. Apply 12-61-0 at flowering stage.',
      'prevention': 'Stake plants for support. Water only at base. Monitor weekly for pests.',
      'telugu': 'టొమాటో ఆరోగ్యంగా ఉంది. పోషకాలు అందించండి',
      'hindi': 'टमाटर स्वस्थ है। पोषण जारी रखें',
      'tamil': 'தக்காளி ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'Seaweed Liquid Extract',
          'type': 'Organic',
          'dose': '3ml/L foliar spray',
          'timing': 'Every 15 days throughout crop',
          'benefit': 'Provides growth hormones and 60+ micronutrients',
          'price': 180.0
        },
        {
          'name': 'NPK 19-19-19 (Water Soluble)',
          'type': 'Chemical',
          'dose': '3g/L foliar spray',
          'timing': 'During vegetative stage',
          'benefit': 'Balanced nutrition for strong vegetative growth',
          'price': 95.0
        },
        {
          'name': 'Calcium + Boron Combo',
          'type': 'Chemical',
          'dose': '1g/L foliar spray',
          'timing': 'At flowering and fruit development',
          'benefit': 'Prevents blossom end rot and improves fruit quality',
          'price': 110.0
        },
      ],
    },

    'Maize_NorthernLeafBlight': {
      'crop': 'Maize',
      'disease': 'Northern Leaf Blight',
      'severity': 'High',
      'symptoms': 'Long cigar-shaped grey-green to tan lesions running along the leaf length.',
      'organic': 'Trichoderma harzianum 5g/L spray. Remove and destroy infected crop parts.',
      'chemical': 'Propiconazole 25 EC @ 1ml/L or Tebuconazole 25.9 EC @ 1ml/L every 10 days.',
      'prevention': 'Plant resistant hybrids. Crop rotation with non-host crops like legumes.',
      'telugu': 'మొక్కజొన్న ఆకు బ్లైట్ - ప్రొపికొనజోల్ వాడండి',
      'hindi': 'मक्का पत्ती झुलसा - प्रोपिकोनाजोल का उपयोग करें',
      'tamil': 'சோளம் இலை கருகல் - ப்ரோபிகோனசோல் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Neem Cake',
          'type': 'Organic',
          'dose': '250 kg/acre',
          'timing': 'Before sowing',
          'benefit': 'Reduces soil-borne pathogens that cause leaf blight',
          'price': 8.0
        },
        {
          'name': 'Azospirillum Biofertilizer',
          'type': 'Organic',
          'dose': '2 kg/acre seed treatment',
          'timing': 'At sowing',
          'benefit': 'Natural nitrogen fixation, improves plant health',
          'price': 75.0
        },
        {
          'name': 'Propiconazole 25 EC',
          'type': 'Chemical',
          'dose': '1ml/L foliar spray',
          'timing': 'At first symptom appearance',
          'benefit': 'Systemic fungicide — best for northern leaf blight',
          'price': 185.0
        },
        {
          'name': 'Zinc Sulphate 33%',
          'type': 'Chemical',
          'dose': '5 kg/acre basal application',
          'timing': 'Before sowing',
          'benefit': 'Corrects zinc deficiency, improves disease resistance',
          'price': 65.0
        },
      ],
    },

    'Maize_CommonRust': {
      'crop': 'Maize',
      'disease': 'Common Rust',
      'severity': 'Medium',
      'symptoms': 'Oval brick-red pustules on both upper and lower leaf surfaces.',
      'organic': 'Neem oil 3ml/L spray every 7 days. Improve field ventilation by thinning.',
      'chemical': 'Mancozeb 75 WP @ 2g/L or Zineb 75 WP @ 2g/L. Apply 2-3 sprays.',
      'prevention': 'Plant resistant varieties. Early sowing avoids peak rust season.',
      'telugu': 'సాధారణ తుప్పు వ్యాధి - మాంకోజెబ్ పిచికారీ చేయండి',
      'hindi': 'साधारण रस्ट - मैंकोजेब का छिड़काव करें',
      'tamil': 'சாதாரண துரு நோய் - மேன்கோசெப் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Compost + Neem Cake Mix',
          'type': 'Organic',
          'dose': '400 kg/acre',
          'timing': 'Before sowing',
          'benefit': 'Improves soil microbial health, suppresses rust spores',
          'price': 7.0
        },
        {
          'name': 'Mancozeb 75 WP',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'Every 7-10 days from first rust pustule',
          'benefit': 'Protective fungicide — covers leaf surface against rust',
          'price': 85.0
        },
        {
          'name': 'Potassium Nitrate',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'Every 15 days',
          'benefit': 'Boosts potassium levels which increases rust resistance',
          'price': 120.0
        },
      ],
    },

    'Maize_Healthy': {
      'crop': 'Maize',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Maize crop is healthy and growing normally with good color.',
      'organic': 'Apply FYM and green manure. Use Azospirillum and PSB inoculants at sowing.',
      'chemical': 'NPK 10-26-26 at sowing. Urea top-dressing at knee-high stage.',
      'prevention': 'Maintain proper plant spacing. Monitor for fall armyworm weekly.',
      'telugu': 'మొక్కజొన్న ఆరోగ్యంగా ఉంది',
      'hindi': 'मक्का स्वस्थ है',
      'tamil': 'சோளம் ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'FYM (Farm Yard Manure)',
          'type': 'Organic',
          'dose': '4 tonnes/acre',
          'timing': 'Before sowing as basal',
          'benefit': 'Organic matter, water retention, micronutrients',
          'price': 2.0
        },
        {
          'name': 'NPK 10-26-26',
          'type': 'Chemical',
          'dose': '50 kg/acre basal application',
          'timing': 'At sowing',
          'benefit': 'Complete balanced nutrition for maize growth',
          'price': 1100.0
        },
        {
          'name': 'Urea 46% Nitrogen',
          'type': 'Chemical',
          'dose': '35 kg/acre top dressing',
          'timing': 'At knee-high (30-35 days after sowing)',
          'benefit': 'Nitrogen boost for grain filling stage',
          'price': 266.0
        },
      ],
    },

    'Chilli_AnthracnoseLeafBlight': {
      'crop': 'Chilli',
      'disease': 'Anthracnose / Leaf Blight',
      'severity': 'High',
      'symptoms': 'Dark water-soaked spots on leaves and fruits. Sunken lesions with pink spores on fruit.',
      'organic': 'Bordeaux mixture 1%. Remove and destroy all infected fruits and leaves.',
      'chemical': 'Carbendazim 50 WP @ 1g/L + Mancozeb 75 WP @ 2g/L mixed spray.',
      'prevention': 'Use disease-free seeds. Proper field drainage. Avoid mechanical wounds.',
      'telugu': 'మిర్చి యాంత్రక్నోజ్ - కార్బెండిజిమ్ పిచికారీ చేయండి',
      'hindi': 'मिर्च एन्थ्रेक्नोज - कार्बेन्डाजिम का छिड़काव करें',
      'tamil': 'மிளகாய் ஆந்த்ராக்னோஸ் - கார்பெண்டசிம் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Pseudomonas fluorescens',
          'type': 'Organic',
          'dose': '2.5 kg/acre soil drench',
          'timing': 'At planting and every month',
          'benefit': 'Biological control of Anthracnose fungus in soil',
          'price': 130.0
        },
        {
          'name': 'Neem Oil 5000 PPM',
          'type': 'Organic',
          'dose': '3ml/L foliar spray',
          'timing': 'Weekly preventive spray',
          'benefit': 'Antifungal + insect repellent, safe for consumption',
          'price': 90.0
        },
        {
          'name': 'Carbendazim 50 WP',
          'type': 'Chemical',
          'dose': '1g/L spray',
          'timing': 'At first symptom, then every 7 days',
          'benefit': 'Systemic fungicide — penetrates plant tissue',
          'price': 75.0
        },
        {
          'name': 'Potassium Humate',
          'type': 'Organic',
          'dose': '2g/L soil drench or foliar',
          'timing': 'Every 15 days',
          'benefit': 'Strengthens root system and plant immunity',
          'price': 55.0
        },
      ],
    },

    'Chilli_Healthy': {
      'crop': 'Chilli',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Chilli plant is healthy with good leaf color and active flowering.',
      'organic': 'Apply potassium-rich compost and wood ash for better fruit set and quality.',
      'chemical': 'Apply 00-52-34 MKP at flowering. Calcium Boron at fruit development.',
      'prevention': 'Stake tall plants. Water at base only. Monitor thrips and mites weekly.',
      'telugu': 'మిర్చి ఆరోగ్యంగా ఉంది',
      'hindi': 'मिर्च स्वस्थ है',
      'tamil': 'மிளகாய் ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'Wood Ash + Vermicompost',
          'type': 'Organic',
          'dose': '100 kg ash + 300 kg vermicompost per acre',
          'timing': 'Before planting',
          'benefit': 'Natural potassium source for better fruit size and pungency',
          'price': 5.0
        },
        {
          'name': 'Seaweed Extract Granules',
          'type': 'Organic',
          'dose': '5 kg/acre soil application',
          'timing': 'At flower initiation',
          'benefit': 'Natural growth hormones improve fruit set significantly',
          'price': 200.0
        },
        {
          'name': 'MKP 00-52-34',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'At flowering stage',
          'benefit': 'High phosphorus-potassium ratio for maximum fruit production',
          'price': 145.0
        },
        {
          'name': 'Calcium + Boron',
          'type': 'Chemical',
          'dose': '1ml/L foliar spray',
          'timing': 'Every 20 days from fruit set',
          'benefit': 'Prevents fruit cracking and improves shelf life',
          'price': 110.0
        },
      ],
    },

    'Groundnut_EarlyLeafSpot': {
      'crop': 'Groundnut',
      'disease': 'Early Leaf Spot',
      'severity': 'Medium',
      'symptoms': 'Small brown spots with yellow halo on upper leaf surface from 30 DAS.',
      'organic': 'Neem leaf extract 5% spray. Remove infected lower leaves to reduce spread.',
      'chemical': 'Chlorothalonil 75 WP @ 2g/L or Mancozeb 75 WP @ 2.5g/L every 10 days.',
      'prevention': 'Crop rotation. Deep ploughing in summer. Use tolerant varieties.',
      'telugu': 'వేరుశెనగ ఆకు మచ్చ - క్లోరోథలోనిల్ వాడండి',
      'hindi': 'मूंगफली पत्ती धब्बा - क्लोरोथालोनिल का उपयोग करें',
      'tamil': 'நிலக்கடலை இலை புள்ளி - குளோரோத்தலோனில் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Neem Cake',
          'type': 'Organic',
          'dose': '200 kg/acre before sowing',
          'timing': 'At land preparation',
          'benefit': 'Soil pathogen suppression, slow nitrogen release',
          'price': 8.0
        },
        {
          'name': 'Rhizobium Inoculant',
          'type': 'Organic',
          'dose': '1 packet per 10 kg seed for seed treatment',
          'timing': 'At sowing — coat seeds and dry in shade',
          'benefit': 'Fixes atmospheric nitrogen — saves 30 kg urea per acre',
          'price': 45.0
        },
        {
          'name': 'Gypsum (Calcium Sulphate)',
          'type': 'Chemical',
          'dose': '200 kg/acre at pegging stage',
          'timing': 'At 40-45 days after sowing (pegging)',
          'benefit': 'Calcium for pod filling, reduces leaf spot severity',
          'price': 6.0
        },
        {
          'name': 'Chlorothalonil 75 WP',
          'type': 'Chemical',
          'dose': '2g/L foliar spray',
          'timing': 'Every 10 days starting from 30 DAS',
          'benefit': 'Best fungicide for early and late leaf spot in groundnut',
          'price': 150.0
        },
      ],
    },

    'Groundnut_Healthy': {
      'crop': 'Groundnut',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Groundnut crop is healthy. Good canopy cover and pegging visible.',
      'organic': 'Apply gypsum at pegging. Use Rhizobium + PSB for nitrogen fixation.',
      'chemical': 'Apply SSP for phosphorus and sulphur. No disease treatment needed.',
      'prevention': 'Ensure proper drainage. Avoid waterlogging. Monitor for tikka disease.',
      'telugu': 'వేరుశెనగ ఆరోగ్యంగా ఉంది',
      'hindi': 'मूंगफली स्वस्थ है',
      'tamil': 'நிலக்கடலை ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'Rhizobium + PSB Culture',
          'type': 'Organic',
          'dose': '600g + 600g per 30 kg seed',
          'timing': 'Seed treatment before sowing',
          'benefit': 'Fixes nitrogen + solubilizes phosphorus — saves 50% fertilizer',
          'price': 50.0
        },
        {
          'name': 'Gypsum',
          'type': 'Chemical',
          'dose': '200 kg/acre',
          'timing': 'At pegging stage (40-45 DAS)',
          'benefit': 'Essential calcium for pod development and kernel filling',
          'price': 6.0
        },
        {
          'name': 'SSP (Single Super Phosphate)',
          'type': 'Chemical',
          'dose': '100 kg/acre as basal',
          'timing': 'Before sowing',
          'benefit': 'Phosphorus + sulphur nutrition for groundnut',
          'price': 380.0
        },
      ],
    },

    'Cotton_BacterialBlight': {
      'crop': 'Cotton',
      'disease': 'Bacterial Blight',
      'severity': 'High',
      'symptoms': 'Angular water-soaked spots on leaves turning brown. Black arm lesions on bolls.',
      'organic': 'Copper oxychloride 3g/L spray. Remove infected plant parts immediately.',
      'chemical': 'Streptomycin sulphate 0.5g/L + Copper oxychloride 3g/L — spray together.',
      'prevention': 'Use acid-delinted seeds. Crop rotation every 2 years. Remove crop residues.',
      'telugu': 'పత్తి బ్యాక్టీరియా మచ్చ - కాపర్ ఆక్సీక్లోరైడ్ వాడండి',
      'hindi': 'कपास जीवाणु अंगमारी - कॉपर ऑक्సीक्लोராइड का उपयोग करें',
      'tamil': 'பருத்தி பாக்டீரியா கருகல் - காப்பர் ஆக்சிகுளோரைட் தெளிக்கவும்',
      'fertilizers': [
        {
          'name': 'Neem Cake + Compost',
          'type': 'Organic',
          'dose': '250 kg neem cake + 1 tonne compost per acre',
          'timing': 'At land preparation before sowing',
          'benefit': 'Reduces soil bacterial load, improves soil structure',
          'price': 7.0
        },
        {
          'name': 'Copper Oxychloride 50 WP',
          'type': 'Chemical',
          'dose': '3g/L foliar spray',
          'timing': 'Every 10 days at first sign of disease',
          'benefit': 'Controls bacterial spread on leaves and bolls',
          'price': 70.0
        },
        {
          'name': 'NPK 20-20-0',
          'type': 'Chemical',
          'dose': '25 kg/acre as basal',
          'timing': 'At sowing',
          'benefit': 'Balanced nitrogen-phosphorus for healthy plant recovery',
          'price': 900.0
        },
      ],
    },

    'Cotton_Healthy': {
      'crop': 'Cotton',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Cotton crop is healthy. Good boll formation and lint development visible.',
      'organic': 'Continue potassium and boron supplementation for boll development quality.',
      'chemical': 'Apply potassium nitrate at boll formation for better lint quality and weight.',
      'prevention': 'Monitor weekly for whitefly, bollworm, and pink bollworm.',
      'telugu': 'పత్తి ఆరోగ్యంగా ఉంది',
      'hindi': 'कपास स्वस्थ है',
      'tamil': 'பருத்தி ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'FYM + Neem Cake',
          'type': 'Organic',
          'dose': '2T FYM + 200 kg neem cake per acre',
          'timing': 'Before sowing',
          'benefit': 'Base organic nutrition and soil health improvement',
          'price': 5.0
        },
        {
          'name': 'Seaweed Liquid Concentrate',
          'type': 'Organic',
          'dose': '2ml/L foliar spray',
          'timing': 'At boll formation stage',
          'benefit': 'Improves boll retention and reduces premature drop',
          'price': 180.0
        },
        {
          'name': 'SOP (Sulphate of Potash) 00-00-50',
          'type': 'Chemical',
          'dose': '20 kg/acre top dressing',
          'timing': 'At boll development',
          'benefit': 'Potassium for better lint quality and staple length',
          'price': 800.0
        },
        {
          'name': 'Boron (Solubor 20%)',
          'type': 'Chemical',
          'dose': '1g/L foliar spray',
          'timing': 'At flowering',
          'benefit': 'Improves boll set, reduces square/boll shedding',
          'price': 130.0
        },
      ],
    },

    'RedGram_Wilt': {
      'crop': 'Red Gram',
      'disease': 'Fusarium Wilt',
      'severity': 'Very High',
      'symptoms': 'Sudden wilting of plant. Brown discoloration of vascular tissue when stem is cut.',
      'organic': 'Trichoderma harzianum 5g/kg seed treatment. Bio-compost soil application.',
      'chemical': 'Carbendazim 50 WP 2g/kg seed treatment + soil drench 1g/L around plant roots.',
      'prevention': 'Use wilt-resistant variety ICPL 87119. Deep summer ploughing. Crop rotation.',
      'telugu': 'కందిపప్పు వాడు వ్యాధి - నిరోధక రకాలు వాడండి',
      'hindi': 'अरहर उकठा रोग - प्रतिरोधी किस्म लगाएं',
      'tamil': 'துவரை வாட்டம் - எதிர்ப்பு திறன் ரகங்கள் பயன்படுத்தவும்',
      'fertilizers': [
        {
          'name': 'Trichoderma + Pseudomonas Mix',
          'type': 'Organic',
          'dose': '5g/kg seed treatment before sowing',
          'timing': 'Seed treatment — apply 24 hrs before sowing',
          'benefit': 'Biological wilt control — most effective organic option',
          'price': 120.0
        },
        {
          'name': 'Biochar',
          'type': 'Organic',
          'dose': '200 kg/acre soil incorporation',
          'timing': 'Before sowing at land prep',
          'benefit': 'Improves drainage, reduces Fusarium wilt severity',
          'price': 15.0
        },
        {
          'name': 'Carbendazim 50 WP',
          'type': 'Chemical',
          'dose': '1g/L soil drench around wilting plants',
          'timing': 'Immediately at first wilt sign',
          'benefit': 'Systemic fungicide — prevents spread to healthy plants',
          'price': 75.0
        },
        {
          'name': 'DAP 18-46-00',
          'type': 'Chemical',
          'dose': '25 kg/acre basal application',
          'timing': 'At sowing',
          'benefit': 'Strong phosphorus for deep root development',
          'price': 1350.0
        },
      ],
    },

    'RedGram_Healthy': {
      'crop': 'Red Gram',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Red gram crop is healthy with good pod formation and leaf color.',
      'organic': 'Apply Rhizobium + PSB inoculant at sowing. Use phosphate-rich compost.',
      'chemical': 'Apply SSP at sowing for phosphorus. No disease treatment needed.',
      'prevention': 'Monitor for pod borer weekly. Set pheromone traps for Ha-NPV.',
      'telugu': 'కంది ఆరోగ్యంగా ఉంది',
      'hindi': 'अरहर स्वस्थ है',
      'tamil': 'துவரை ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'Rhizobium + PSB Culture',
          'type': 'Organic',
          'dose': '600g + 600g per 30 kg seed',
          'timing': 'Seed treatment before sowing',
          'benefit': 'Fixes nitrogen + solubilizes phosphorus — 50% fertilizer savings',
          'price': 50.0
        },
        {
          'name': 'SSP (Single Super Phosphate)',
          'type': 'Chemical',
          'dose': '80 kg/acre basal',
          'timing': 'Before sowing',
          'benefit': 'Phosphorus and sulphur for pod development',
          'price': 380.0
        },
        {
          'name': 'Potassium Sulphate',
          'type': 'Chemical',
          'dose': '20 kg/acre top dressing',
          'timing': 'At pod formation stage',
          'benefit': 'Improves grain filling, size, and protein content',
          'price': 480.0
        },
      ],
    },

    'GreenGram_YellowMosaic': {
      'crop': 'Green Gram',
      'disease': 'Yellow Mosaic Virus',
      'severity': 'Very High',
      'symptoms': 'Bright yellow patches alternating with green on leaves. Stunted growth, no pods.',
      'organic': 'Immediately destroy infected plants. Neem oil 5ml/L for whitefly control.',
      'chemical': 'Imidacloprid 17.8 SL @ 0.3ml/L to control whitefly vector. Repeat in 7 days.',
      'prevention': 'Virus-resistant varieties ML 818 or Pusa Vishal. Early sowing before June.',
      'telugu': 'పెసలు పసుపు మొజాయిక్ - తెల్ల దోమ నియంత్రణ చేయండి',
      'hindi': 'मूंग पीला मोजेक वायरस - सफेद मक्खी नियंत्रण करें',
      'tamil': 'பச்சை பயறு மஞ்சள் மொசைக் - வெள்ளை ஈ கட்டுப்படுத்தவும்',
      'fertilizers': [
        {
          'name': 'Neem Oil 5000 PPM',
          'type': 'Organic',
          'dose': '5ml/L foliar spray',
          'timing': 'Weekly spray for whitefly control',
          'benefit': 'Repels whitefly which spreads yellow mosaic virus',
          'price': 90.0
        },
        {
          'name': 'Yellow Sticky Traps',
          'type': 'Organic',
          'dose': '10 traps per acre',
          'timing': 'Install from 7 days after sowing',
          'benefit': 'Physical monitoring and mass trapping of whiteflies',
          'price': 15.0
        },
        {
          'name': 'Imidacloprid 17.8 SL',
          'type': 'Chemical',
          'dose': '0.3ml/L foliar spray',
          'timing': 'Every 7 days until whitefly is controlled',
          'benefit': 'Fast-acting insecticide — controls virus vector whitefly',
          'price': 220.0
        },
        {
          'name': 'Rhizobium Inoculant',
          'type': 'Organic',
          'dose': '600g per 30 kg seed treatment',
          'timing': 'At sowing',
          'benefit': 'Biological nitrogen fixation helps recovery from virus stress',
          'price': 40.0
        },
      ],
    },

    'GreenGram_Healthy': {
      'crop': 'Green Gram',
      'disease': 'Healthy',
      'severity': 'None',
      'symptoms': 'Green gram is healthy with good leaf color and active pod filling.',
      'organic': 'Rhizobium seed treatment is essential. Apply phosphate-solubilizing bacteria.',
      'chemical': 'Apply SSP at sowing. No disease treatment needed currently.',
      'prevention': 'Avoid waterlogging. Monitor for aphids and yellow mosaic symptoms.',
      'telugu': 'పెసలు ఆరోగ్యంగా ఉంది',
      'hindi': 'मूंग स्वस्थ है',
      'tamil': 'பச்சை பயறு ஆரோக்கியமாக உள்ளது',
      'fertilizers': [
        {
          'name': 'Rhizobium + PSB Mix',
          'type': 'Organic',
          'dose': '1 packet each per 10 kg seed',
          'timing': 'Seed treatment at sowing',
          'benefit': 'Natural nitrogen fixation — reduces urea need by 40%',
          'price': 45.0
        },
        {
          'name': 'Vermicompost',
          'type': 'Organic',
          'dose': '300 kg/acre',
          'timing': 'Before sowing at land preparation',
          'benefit': 'Improves soil health and provides micronutrients',
          'price': 6.0
        },
        {
          'name': 'DAP 18-46-00',
          'type': 'Chemical',
          'dose': '25 kg/acre basal',
          'timing': 'At sowing',
          'benefit': 'Phosphorus for strong root and pod development',
          'price': 1350.0
        },
        {
          'name': 'MOP (Muriate of Potash)',
          'type': 'Chemical',
          'dose': '15 kg/acre top dressing',
          'timing': 'At first flowering',
          'benefit': 'Potassium for grain filling and quality',
          'price': 28.0
        },
      ],
    },
  };

  static List<FertilizerRec> getFertilizers(String label) {
    final entry = _raw[label];
    if (entry == null) return [];
    final list = (entry['fertilizers'] as List?)?.cast<Map>() ?? [];
    return list
        .map((f) => FertilizerRec(
              name: f['name'] as String,
              type: f['type'] as String,
              dose: f['dose'] as String,
              timing: f['timing'] as String,
              benefit: f['benefit'] as String,
              pricePerKg: (f['price'] as num).toDouble(),
            ))
        .toList();
  }

  static DiseaseResult build(String label, double confidence) {
    final e = _raw[label] ?? _raw['Rice_Healthy']!;
    return DiseaseResult(
      label: label,
      confidence: confidence,
      crop: e['crop'] as String,
      disease: e['disease'] as String,
      severity: e['severity'] as String,
      symptoms: e['symptoms'] as String,
      organicTreatment: e['organic'] as String,
      chemicalTreatment: e['chemical'] as String,
      prevention: e['prevention'] as String,
      voiceTelugu: e['telugu'] as String,
      voiceHindi: e['hindi'] as String,
      voiceTamil: e['tamil'] as String,
      fertilizers: getFertilizers(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Disease Detector Service
// ─────────────────────────────────────────────────────────────────────────────
class DiseaseDetectorService {
  bool _ready = false;

  static const _labels = [
    'Rice_Blast', 'Rice_BrownSpot', 'Rice_Healthy',
    'Tomato_EarlyBlight', 'Tomato_LateBlight', 'Tomato_Healthy',
    'Maize_NorthernLeafBlight', 'Maize_CommonRust', 'Maize_Healthy',
    'Chilli_AnthracnoseLeafBlight', 'Chilli_Healthy',
    'Groundnut_EarlyLeafSpot', 'Groundnut_Healthy',
    'Cotton_BacterialBlight', 'Cotton_Healthy',
    'RedGram_Wilt', 'RedGram_Healthy',
    'GreenGram_YellowMosaic', 'GreenGram_Healthy',
  ];

  Future<void> initialize() async {
    try {
      await rootBundle.load('assets/model/kisanai_disease_model.tflite');
      _ready = true;
      debugPrint('✅ TFLite model loaded');
    } catch (_) {
      _ready = false;
      debugPrint('⚠️  No model file — running in demo mode');
    }
  }

  Future<List<DiseaseResult>> predict(Uint8List bytes) async {
    if (!_ready) return _demo(bytes);
    try {
      final processed = await compute(_preprocess, bytes);
      const ch = MethodChannel('kisanai/tflite');
      final raw = await ch.invokeMethod<List>('runInference', {
        'bytes': processed,
        'shape': [1, 224, 224, 3],
      });
      if (raw == null) return _demo(bytes);
      final probs = raw.map((e) => (e as num).toDouble()).toList();
      return _top3(probs);
    } catch (e) {
      debugPrint('Inference error: $e');
      return _demo(bytes);
    }
  }
  List<FertilizerRec> _buildFertilizers(String crop, String disease, String fertAdvice) {
  final label = '${crop}_${disease.replaceAll(" ", "_")}';

  final dbFerts = _DB.getFertilizers(label);

  if (dbFerts.isNotEmpty) return dbFerts;

  return [
    FertilizerRec(
      name: fertAdvice.isNotEmpty ? fertAdvice : 'General Fertilizer',
      type: 'General',
      dose: 'As recommended',
      timing: 'Based on crop stage',
      benefit: 'Improves plant health',
      pricePerKg: 0.0,
    )
  ];
}

  // Real AI analysis using Groq Vision (llama-3.2-11b-vision-preview)
  // This replaces random demo mode with actual crop disease detection
  Future<List<DiseaseResult>> _demo(Uint8List bytes) async {
    try {
      final result = await _analyzeWithGroqVision(bytes);
      if (result != null) return result;
    } catch (e) {
      debugPrint('Groq vision error: \$e');
    }
    // API failed - try with a different Groq model
    debugPrint('Trying fallback vision model...');
    try {
      final result2 = await _analyzeWithFallbackModel(bytes);
      if (result2 != null) return result2;
    } catch (e) {
      debugPrint('Fallback model error: ' + e.toString());
    }
    // Last resort: informative error result
    return [DiseaseResult(
      label: 'Scan_Failed',
      confidence: 0.0,
      crop: 'Unknown',
      disease: 'Detection Failed',
      severity: 'None',
      symptoms: '''Could not analyze image. Please ensure:
• Leaf is clearly visible and in focus
• Good lighting (no shadows)
• Leaf fills most of the frame
• Stable internet connection''' ,
      organicTreatment: 'Take another photo with better lighting and try again.',
      chemicalTreatment: 'Ensure leaf shows clear disease symptoms.',
      prevention: 'For best results: photograph single leaf, close-up, in daylight.',
      voiceTelugu: 'చిత్రం స్పష్టంగా లేదు. మళ్ళీ ప్రయత్నించండి.',
      voiceHindi: 'छवि स्पष्ट नहीं है। कृपया फिर से प्रयास करें।',
      voiceTamil: 'படம் தெளிவாக இல்லை. மீண்டும் முயற்சிக்கவும்.',
      fertilizers: const [],
    )];
  }

  // Use Groq's vision model to actually analyze the crop image
  // EXPERT crop disease detection using Groq Vision AI
  // Uses detailed pathologist-level prompt for maximum accuracy
  Future<List<DiseaseResult>?> _analyzeWithGroqVision(Uint8List bytes) async {
    const key = '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';
    const url = 'https://api.groq.com/openai/v1/chat/completions';

    // Resize image to reduce payload while keeping quality
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final resized = img.copyResize(decoded, width: 512, height: 512);
    final compressed = img.encodeJpg(resized, quality: 85);
    final base64Image = base64Encode(compressed);

    // Expert-level pathologist prompt for maximum accuracy
    const systemPrompt =
      'You are a PhD-level plant pathologist and agronomist with 30 years of experience '
      'diagnosing crop diseases across India. You have examined millions of diseased crop samples. '
      'Your diagnoses are always precise, actionable, and include exact chemical names and doses. '
      'You ONLY respond in valid JSON. Never add any text outside the JSON.';

    const userPrompt =
      'Examine this crop leaf image with expert precision. '
      'STEP 1 - Identify the EXACT crop species by looking at: leaf shape, texture, color, venation pattern, stem. '
      'STEP 2 - Diagnose the EXACT disease/pest by looking at: lesion shape, color, pattern, location, margin, size, spread. '
      'STEP 3 - Assess severity: what percentage of leaf is affected? '
      'STEP 4 - Give PRECISE treatment with exact product names and doses used in India. '
      '\n\n'
      'Common Indian crop diseases to consider:\n'
      'Rice: Blast (diamond lesions), Brown Spot (oval brown spots), Bacterial Blight (yellowing from margins), Sheath Blight, Tungro Virus\n'
      'Tomato: Early Blight (dark rings), Late Blight (water-soaked patches), Leaf Curl Virus, Septoria Leaf Spot, Fusarium Wilt\n'
      'Chilli: Anthracnose (dark sunken spots), Powdery Mildew (white powder), Leaf Curl, Cercospora Leaf Spot\n'
      'Cotton: Bacterial Blight (angular water-soaked spots), Alternaria Leaf Spot, Fusarium Wilt\n'
      'Groundnut: Early Leaf Spot (circular brown spots), Late Leaf Spot (darker spots with yellow halo), Rust\n'
      'Maize: Northern Leaf Blight (long cigar-shaped lesions), Common Rust (orange pustules), Gray Leaf Spot\n'
      'Wheat: Yellow Rust (yellow stripes), Brown Rust (orange pustules), Loose Smut\n'
      'Sugarcane: Red Rot, Smut, Leaf Scald, Pokkah Boeng\n'
      'Potato: Late Blight (dark water-soaked), Early Blight (target spots), Common Scab\n'
      'Onion: Purple Blotch (purple lesions), Stemphylium Blight\n'
      'Mango: Anthracnose (black spots), Powdery Mildew (white coating), Bacterial Canker\n'
      'Banana: Sigatoka (yellow streaks), Panama Wilt, Bunchy Top Virus\n'
      'Nutrient deficiency symptoms also: Nitrogen (yellowing from tip), Iron (interveinal chlorosis), Zinc (stunted growth)\n'
      '\n'
      'Respond ONLY in this exact JSON (no markdown, no extra text):\n'
      '{\n'
      '  "crop": "exact crop name",\n'
      '  "disease": "exact disease/pest/deficiency name",\n'
      '  "confidence": 0.92,\n'
      '  "severity": "High",\n'
      '  "affected_area_percent": 35,\n'
      '  "symptoms": "Detailed description of exactly what you see in THIS image - color, shape, pattern, location of lesions",\n'
      '  "cause": "Causal organism - fungus/bacteria/virus/nutrient name",\n'
      '  "organic_treatment": "Specific organic remedy with EXACT dose per litre or acre",\n'
      '  "chemical_treatment": "Specific chemical product name available in India + EXACT dose (ml/L or g/L) + frequency + timing",\n'
      '  "prevention": "3 specific prevention steps for this exact disease",\n'
      '  "fertilizer_advice": "Which fertilizer to apply now and exact dose per acre",\n'
      '  "spray_timing": "Best time to spray - morning/evening, before/after rain",\n'
      '  "is_healthy": false\n'
      '}\n'
      'Severity must be: None/Low/Medium/High/Very High\n'
      'Confidence: 0.60-0.99\n'
      'If healthy: is_healthy=true, disease="Healthy", severity="None"';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + key,
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,' + base64Image}
                },
                {'type': 'text', 'text': userPrompt}
              ]
            }
          ],
          'max_tokens': 800,
          'temperature': 0.05,  // Very low temp = more precise, consistent output
          'top_p': 0.9,
        }),
      ).timeout(const Duration(seconds: 40));

      debugPrint('Groq Vision: ' + response.statusCode.toString());

      if (response.statusCode != 200) {
        debugPrint('Vision error: ' + response.body.substring(0, response.body.length.clamp(0, 300)));
        return null;
      }

      final j = jsonDecode(response.body) as Map;
      final text = j['choices']?[0]?['message']?['content'] as String?;
      if (text == null || text.isEmpty) return null;

      debugPrint('Vision AI response: ' + text.substring(0, text.length.clamp(0, 500)));

      // Parse JSON — handle markdown code blocks if present
      String jsonStr = text.trim();
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json').last.split('```').first.trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```').elementAt(1).trim();
      }

      // Extract JSON object
      final start = jsonStr.indexOf('{');
      final end   = jsonStr.lastIndexOf('}');
      if (start < 0 || end < 0) return null;
      jsonStr = jsonStr.substring(start, end + 1);

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final crop        = (data['crop'] as String? ?? 'Unknown Crop').trim();
      final disease     = (data['disease'] as String? ?? 'Unknown Disease').trim();
      final conf        = (data['confidence'] as num?)?.toDouble() ?? 0.75;
      final severity    = (data['severity'] as String? ?? 'Medium').trim();
      final symptoms    = (data['symptoms'] as String? ?? 'Symptoms visible on leaf').trim();
      final cause       = (data['cause'] as String? ?? '').trim();
      final organic     = (data['organic_treatment'] as String? ?? 'Apply neem oil 5ml/L weekly').trim();
      final chemical    = (data['chemical_treatment'] as String? ?? 'Consult local agronomist').trim();
      final prevent     = (data['prevention'] as String? ?? 'Regular monitoring').trim();
      final fertAdvice  = (data['fertilizer_advice'] as String? ?? '').trim();
      final sprayTime   = (data['spray_timing'] as String? ?? 'Early morning 6-9 AM').trim();
      final affected    = (data['affected_area_percent'] as num?)?.toInt() ?? 0;
      final healthy     = data['is_healthy'] as bool? ?? false;

      // Build enriched symptoms with all details
      final fullSymptoms = healthy
          ? crop + ' plant is healthy. No disease symptoms visible.'
          : symptoms +
            (cause.isNotEmpty ? ' Caused by: ' + cause + '.' : '') +
            (affected > 0 ? ' Approximately ' + affected.toString() + '% of leaf affected.' : '') +
            ' Best spray time: ' + sprayTime;

      final fullPrevention = prevent;
      

      final cropLabel = crop + '_' + disease.replaceAll(' ', '_');

      final result = DiseaseResult(
        label: cropLabel,
        confidence: conf,
        crop: crop,
        disease: disease,
        severity: healthy ? 'None' : severity,
        symptoms: fullSymptoms,
        organicTreatment: healthy ? 'Continue regular crop care. ' + fertAdvice : organic,
        chemicalTreatment: healthy ? 'No treatment needed.' : chemical,
        prevention: fullPrevention,
        voiceTelugu: healthy
            ? crop + ' పంట పూర్తి ఆరోగ్యంగా ఉంది! వ్యాధి లేదు.'
            : crop + ' పంటకు ' + disease + ' వ్యాధి వచ్చింది! తీవ్రత: ' + severity + '. ' + chemical.split('.').first + ' వాడండి.',
        voiceHindi: healthy
            ? crop + ' फसल बिल्कुल स्वस्थ है! कोई बीमारी नहीं।'
            : crop + ' फसल में ' + disease + ' रोग है! गंभीरता: ' + severity + '. तुरंत ' + chemical.split('.').first + ' का उपयोग करें।',
        voiceTamil: healthy
            ? crop + ' பயிர் முழுமையான ஆரோக்கியமாக உள்ளது!'
            : crop + ' பயிரில் ' + disease + ' நோய் உள்ளது! ' + severity + ' தீவிரம். உடனடியாக சிகிச்சை செய்யுங்கள்.',
        fertilizers: _buildFertilizers(crop, disease, fertAdvice),
      );

      return [result];

    } catch (e) {
      debugPrint('Vision analysis error: ' + e.toString());
      return null;
    }
  }

  // Fallback to llama3-70b model if primary fails
  Future<List<DiseaseResult>?> _analyzeWithFallbackModel(Uint8List bytes) async {
    const key = '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';
    const url = 'https://api.groq.com/openai/v1/chat/completions';

    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final resized = img.copyResize(decoded, width: 384, height: 384);
    final compressed = img.encodeJpg(resized, quality: 80);
    final base64Image = base64Encode(compressed);

    const prompt =
      'You are a plant disease expert. Look at this leaf image carefully. '
      'Identify: 1) Crop name 2) Disease name 3) Treatment. '
      'Reply ONLY in JSON: '
      '{"crop":"name","disease":"name","confidence":0.85,"severity":"High",'
      '"symptoms":"what you see","organic_treatment":"remedy+dose",'
      '"chemical_treatment":"medicine+dose","prevention":"steps",'
      '"fertilizer_advice":"fertilizer+dose","spray_timing":"timing","is_healthy":false}';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ' + key},
      body: jsonEncode({
        'model': 'llama-3.2-11b-vision-preview',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,' + base64Image}},
              {'type': 'text', 'text': prompt}
            ]
          }
        ],
        'max_tokens': 500,
        'temperature': 0.1,
      }),
    ).timeout(const Duration(seconds: 35));

    if (response.statusCode != 200) return null;

    final j = jsonDecode(response.body) as Map;
    final text = j['choices']?[0]?['message']?['content'] as String?;
    if (text == null) return null;

    String jsonStr = text.trim();
    final start = jsonStr.indexOf('{');
    final end = jsonStr.lastIndexOf('}');
    if (start < 0 || end < 0) return null;
    jsonStr = jsonStr.substring(start, end + 1);

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final crop = (data['crop'] as String? ?? 'Unknown').trim();
    final disease = (data['disease'] as String? ?? 'Unknown').trim();
    final conf = (data['confidence'] as num?)?.toDouble() ?? 0.70;
    final severity = (data['severity'] as String? ?? 'Medium').trim();
    final symptoms = (data['symptoms'] as String? ?? 'Symptoms detected').trim();
    final organic = (data['organic_treatment'] as String? ?? 'Apply neem oil 5ml/L').trim();
    final chemical = (data['chemical_treatment'] as String? ?? 'Consult agronomist').trim();
    final prevent = (data['prevention'] as String? ?? 'Regular monitoring').trim();
    final fertAdvice = (data['fertilizer_advice'] as String? ?? '').trim();
    final healthy = data['is_healthy'] as bool? ?? false;

    return [
  DiseaseResult(
    label: crop + '_' + disease.replaceAll(' ', '_'),
    confidence: conf,
    crop: crop,
    disease: disease,
    severity: healthy ? 'None' : severity,
    symptoms: healthy ? crop + ' is healthy.' : symptoms,
    organicTreatment: healthy ? 'Continue good care.' : organic,
    chemicalTreatment: healthy ? 'No treatment needed.' : chemical,

    // ✅ FIXED (added comma)
    prevention: prevent +
        (fertAdvice.isNotEmpty ? '\nFertilizer: $fertAdvice' : ''),

    voiceTelugu: healthy
        ? crop + ' పంట ఆరోగ్యంగా ఉంది!'
        : crop + ' పంటకు ' + disease + ' వచ్చింది!',

    voiceHindi: healthy
        ? crop + ' फसल स्वस्थ है!'
        : crop + ' में ' + disease + ' रोग है!',

    voiceTamil: healthy
        ? crop + ' நலமாக உள்ளது!'
        : crop + ' பயிரில் ' + disease + '!',

    fertilizers: _buildFertilizers(crop, disease, fertAdvice),
  )
];
  }

  List<DiseaseResult> _top3(List<double> probs) {
    final n = probs.length < _labels.length ? probs.length : _labels.length;
    final ranked = List.generate(n, (i) => MapEntry(i, probs[i]))
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(3).map((e) => _DB.build(_labels[e.key], e.value)).toList();
  }

  // Runs in isolate — uses image 4.x API: pixel.r / pixel.g / pixel.b
  static Uint8List _preprocess(Uint8List raw) {
    final decoded = img.decodeImage(raw);
    if (decoded == null) throw Exception('Cannot decode image');
    final resized = img.copyResize(decoded, width: 224, height: 224);
    final out = Float32List(224 * 224 * 3);
    int i = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final p = resized.getPixel(x, y);
        out[i++] = p.r / 255.0;
        out[i++] = p.g / 255.0;
        out[i++] = p.b / 255.0;
      }
    }
    return out.buffer.asUint8List();
  }
}

final diseaseDetector = DiseaseDetectorService();
