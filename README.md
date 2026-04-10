# KisanAI – Complete Combined App

Full Flutter app with AI crop disease detection built in.

## Structure
```
lib/
  main.dart                  <- Entry point, initializes AI at startup
  theme/app_theme.dart       <- Colors & fonts (shared by all screens)
  models/models.dart         <- Data models
  services/
    disease_detector.dart    <- AI TFLite service (offline)
  widgets/widgets.dart       <- Reusable components
  screens/
    home_screen.dart         <- Dashboard
    scan_screen.dart         <- AI camera scan (COMBINED with AI)
    market_screen.dart       <- Market prices
    store_screen.dart        <- Fertilizer store
    community_screen.dart    <- Community & equipment
assets/model/                <- Put AI model files here after training
android/.../AndroidManifest.xml  <- Camera permissions
ios/Runner/Info.plist            <- iOS permissions
pubspec.yaml                     <- All packages
```

## Run Steps
1. flutter create kisanai && cd kisanai
2. Copy all files from this ZIP
3. mkdir -p assets/model && echo "{}" > assets/model/disease_database.json && echo "{}" > assets/model/label_map.json
4. flutter pub get
5. flutter run

## Add AI Model (after Python training)
Copy these 3 files to assets/model/:
- kisanai_disease_model.tflite
- label_map.json
- disease_database.json
