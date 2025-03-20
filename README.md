# AgriTrack - AI-Powered Farming Solutions


## Overview

![diagram-export-3-20-2025-5_55_38-PM](https://github.com/user-attachments/assets/a40c0b97-0ce3-4577-b509-435f52c04d65)


AgriTrack is an innovative Flutter-based mobile application designed to revolutionize farming through AI-powered solutions. The app helps farmers optimize crop production, detect diseases early, make data-driven decisions, and maximize profits through smart technology.

## Key Features

###  AI Disease Detection
- Upload photos of crops to instantly identify diseases
- Get detailed treatment recommendations
- Access historical disease data for your farm

###  Integrated E-commerce
- Purchase recommended agricultural products directly through the platform
- Compare prices from various suppliers
- Track your orders and delivery status

###  Precision Farming
- Real-time weather insights for your specific location
- Resource usage optimization recommendations (water, fertilizer, etc.)
- Season planning based on climate predictions

### Market Predictions
- Access real-time market prices for your crops
- Trend analysis and future price predictions
- Optimal harvest timing recommendations

### 📱 Farmer Dashboard
- Comprehensive overview of farm performance
- Task management system
- Resource usage analytics
- Yield tracking and forecasting

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider/Bloc
- **Backend**: Supabase
- **Authentication**: Custom auth with third-party options (Google, Facebook)
- **AI Integration**: TensorFlow Lite for on-device image processing
- **Maps & Location**: Google Maps API
- **Storage**: Supabase Storage
- **Analytics**: Firebase Analytics

## Project Structure

```
agritrack/
├── lib/
│   ├── config/                  # App configuration, constants, theme
│   ├── core/                    # Core functionality, utilities, helpers
│   ├── data/                    # Data layer (repositories, models, services)
│   │   ├── models/              # Data models
│   │   ├── repositories/        # Data repositories
│   │   └── services/            # API services
│   ├── domain/                  # Business logic
│   │   ├── entities/            # Business entities
│   │   └── usecases/            # Business use cases
│   ├── presentation/            # UI layer
│   │   ├── common/              # Common widgets, dialogs
│   │   ├── screens/             # App screens
│   │   │   ├── auth/            # Authentication screens
│   │   │   ├── dashboard/       # Dashboard screens
│   │   │   ├── disease/         # Disease detection screens
│   │   │   ├── ecommerce/       # E-commerce screens
│   │   │   ├── market/          # Market prediction screens
│   │   │   └── profile/         # User profile screens
│   │   ├── widgets/             # Reusable widgets
│   │   └── bloc/                # State management
│   ├── routes.dart              # App routes
│   └── main.dart                # Entry point
├── assets/                      # Assets (images, fonts, etc.)
├── test/                        # Tests
└── pubspec.yaml                 # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Android Studio / VS Code
- An active Supabase account
- Google Maps API key (for location features)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-organization/agritrack.git
   cd agritrack
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the root directory with your API keys:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Development Guidelines

### Code Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style). Please ensure your code follows these conventions before submitting PRs.

### Architecture

AgriTrack follows a clean architecture approach with the following layers:
- **Presentation Layer**: UI components, screens, widgets
- **Domain Layer**: Business logic, use cases
- **Data Layer**: Data sources, repositories, models

### State Management

We use the BLoC pattern for state management. Please follow these guidelines:
- Create separate BLoCs for different features
- Keep BLoC logic simple and focused
- Use events for user interactions
- Use states to represent UI states

### Committing Code

- Follow conventional commit messages
- Keep commits small and focused
- Write descriptive PR descriptions

## Testing

- Unit tests: `flutter test`
- Integration tests: `flutter test integration_test`
- Widget tests: included in the main test suite

## UI/UX Guidelines

The app follows a professional, future-oriented design language with:
- Clean, minimalist interfaces
- High contrast for outdoor visibility
- Intuitive navigation
- Responsive layouts for different screen sizes
- Accessibility considerations

## Backend Setup (Supabase)

1. Create a new Supabase project
2. Set up the following tables:
   - users
   - farms
   - crops
   - disease_detections
   - market_prices
   - orders
   - products

3. Configure authentication with both email/password and third-party providers

## Deployment

### Android
1. Generate keystore: `keytool -genkey -v -keystore agritrack.keystore -alias agritrack -keyalg RSA -keysize 2048 -validity 10000`
2. Build APK: `flutter build apk --release`
3. Build App Bundle: `flutter build appbundle --release`

### iOS
1. Set up certificates in Apple Developer account
2. Build IPA: `flutter build ipa --release`

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request


## Acknowledgements

- Flutter Team
- Supabase
- TensorFlow
