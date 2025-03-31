# AgriTrack - AI-Powered Farming Solutions


## Overview

[Website](https://agri-track.vercel.app/)

![diagram-export-3-20-2025-5_55_38-PM](https://github.com/user-attachments/assets/a40c0b97-0ce3-4577-b509-435f52c04d65)

<p align="center">
  <img src="https://github.com/user-attachments/assets/c8305396-63db-4693-9ad2-ecb41f50ff9a" width="22%" />
  <img src="https://github.com/user-attachments/assets/eb782844-2d60-45a3-bbd9-ef1a48a10c2c" width="22%" />
  <img src="https://github.com/user-attachments/assets/4f8b13ff-0257-47e8-af16-623f9d1b153c" width="22%" />
  <img src="https://github.com/user-attachments/assets/bdfe1dd1-7c0a-4d09-9c8f-36df9dc3bbef" width="22%" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/389820c3-99e4-47e5-b5b7-72bf8ad97fea" width="22%" />
  <img src="https://github.com/user-attachments/assets/ec47b52e-0cdd-4c2e-b8ed-e0eb42cbb671" width="22%" />
  <img src="https://github.com/user-attachments/assets/ccc8f7e8-556a-475a-8e9b-95ebf4c31f15" width="22%" />
  <img src="https://github.com/user-attachments/assets/01173927-a950-4c7c-81dc-512d1f3dd823" width="22%" />
</p>











AgriTrack is a Flutter-based mobile application designed to revolutionize farming through AI-powered solutions. The app helps farmers optimize crop production, detect diseases early, make data-driven decisions, and maximize profits through smart technology.

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

### Farmer Dashboard
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
   git clone https://github.com/victorpreston/agritrack-app.git
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
