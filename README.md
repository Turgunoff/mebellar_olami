<div align="center">

# 🛋️ Mebellar Olami

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/BLoC-State%20Management-blueviolet?style=for-the-badge)](https://bloclibrary.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)

**A premium e-commerce furniture application built with Flutter, focusing on high performance, clean architecture, and seamless user experience.**

[Features](#-key-features) • [Tech Stack](#️-tech-stack) • [Architecture](#-project-structure) • [Installation](#️-installation--run) • [Roadmap](#-future-improvements)

</div>

---

## 📖 Project Overview

**Mebellar Olami** is a sophisticated mobile e-commerce platform designed for the premium furniture market. The application delivers a seamless shopping experience with cutting-edge features including hybrid authentication, intelligent favorites management with cloud sync, and an optimistic UI that provides instant feedback to users.

Built with **Clean Architecture** principles and leveraging Flutter's cross-platform capabilities, the app runs natively on both iOS and Android while maintaining a consistent, premium user experience.

---

## ✨ Key Features

### 🔐 Hybrid Authentication System

| Mode                   | Description                                                                                                                                   |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Guest Mode**         | Browse the full catalog, manage favorites locally, and explore products without creating an account. Privacy-first approach for casual users. |
| **Authenticated Mode** | Full access to profile management, order history, cloud-synced favorites, and personalized recommendations.                                   |

### ❤️ Smart Favorites (Hybrid Storage)

```
┌─────────────────────────────────────────────────────────────┐
│                    FAVORITES SYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│  GUEST USER                    AUTHENTICATED USER           │
│  ┌─────────────────┐          ┌─────────────────┐          │
│  │ SharedPreferences│          │    Cloud API    │          │
│  │  (Local Only)   │  ──────► │  + Auto Merge   │          │
│  └─────────────────┘   Login  └─────────────────┘          │
│                        Sync                                 │
└─────────────────────────────────────────────────────────────┘
```

- **Local Storage (SharedPreferences):** Guests enjoy privacy-focused favorites stored locally on-device
- **Cloud Sync (API):** Upon login/registration, local favorites automatically merge with cloud storage
- **Conflict Resolution:** Smart merge strategy ensures no favorites are lost during sync

### ⚡ Optimistic UI Updates

Zero-latency feel on user interactions:

- **Instant Feedback:** Heart icon toggles immediately on tap
- **Background Sync:** API calls happen asynchronously
- **Rollback on Failure:** Graceful error handling with automatic state rollback

### 🎨 Design System

A carefully crafted visual identity:

| Element             | Specification                     |
| ------------------- | --------------------------------- |
| **Primary Palette** | Cappuccino / Beige tones          |
| **Typography**      | Roboto (Google Fonts)             |
| **Components**      | Custom `ThemeData` implementation |
| **Style**           | Premium minimalist aesthetic      |

### 🧭 Advanced Navigation

- **GoRouter:** Declarative routing with redirect logic (guards)
- **NavigationCubit:** Programmatic tab switching (e.g., "Go to Catalog" button)
- **Dynamic Badges:** Real-time badge updates on BottomNavigationBar (cart count, notifications)

---

## 🛠️ Tech Stack

### Core

| Technology        | Purpose                     |
| ----------------- | --------------------------- |
| **Flutter 3.10+** | Cross-platform UI framework |
| **Dart 3.0+**     | Programming language        |

### Architecture & State Management

| Package        | Purpose                                                                                   |
| -------------- | ----------------------------------------------------------------------------------------- |
| `flutter_bloc` | State management following Clean Architecture: `Bloc → UseCase → Repository → DataSource` |
| `get_it`       | Dependency Injection container                                                            |
| `equatable`    | Value equality for BLoC states                                                            |

### Networking

| Package                            | Purpose                                                                             |
| ---------------------------------- | ----------------------------------------------------------------------------------- |
| `dio`                              | HTTP client with interceptors for token management, retry logic, and error handling |
| `internet_connection_checker_plus` | Network connectivity monitoring                                                     |

### Routing

| Package     | Purpose                                                             |
| ----------- | ------------------------------------------------------------------- |
| `go_router` | Declarative routing with deep linking support and navigation guards |

### Local Storage

| Package              | Purpose                                            |
| -------------------- | -------------------------------------------------- |
| `shared_preferences` | Key-value storage for settings and guest favorites |

### UI/UX

| Package                | Purpose                                  |
| ---------------------- | ---------------------------------------- |
| `flutter_animate`      | Smooth, declarative animations           |
| `cached_network_image` | Image caching and placeholder management |
| `iconsax`              | Premium icon set                         |
| `google_fonts`         | Typography (Roboto)                      |
| `shimmer`              | Loading state animations                 |

### Utilities

| Package             | Purpose                                      |
| ------------------- | -------------------------------------------- |
| `easy_localization` | Multi-language support (🇺🇿 UZ, 🇷🇺 RU, 🇬🇧 EN) |
| `flutter_dotenv`    | Environment configuration                    |
| `intl`              | Date/number formatting                       |

---

## 📂 Project Structure

The project follows a **feature-first** directory structure with **Clean Architecture** layers:

```
lib/
├── core/                           # Shared application infrastructure
│   ├── constants/                  # App-wide constants
│   │   ├── app_colors.dart         # Design system colors
│   │   ├── app_theme.dart          # ThemeData configuration
│   │   └── app_strings.dart        # Static strings
│   ├── di/                         # Dependency Injection setup
│   ├── init/                       # App initialization logic
│   ├── network/                    # Dio client & interceptors
│   ├── router/                     # GoRouter configuration
│   ├── services/                   # Global services
│   ├── utils/                      # Extensions & helpers
│   └── widgets/                    # Reusable UI components
│
├── data/
│   └── models/                     # Shared data models
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication
│   │   ├── data/                   # DataSources, Repositories impl
│   │   ├── domain/                 # Entities, UseCases, Repository interfaces
│   │   └── presentation/           # Screens, Widgets, BLoC
│   ├── cart/                       # Shopping cart
│   ├── catalog/                    # Product catalog & browsing
│   ├── favorites/                  # Wishlist management
│   ├── home/                       # Home screen & discovery
│   ├── onboarding/                 # First-launch experience
│   ├── orders/                     # Order management
│   ├── product/                    # Product details
│   ├── profile/                    # User profile
│   └── search/                     # Search functionality
│
└── main.dart                       # Application entry point
```

### Architecture Flow

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                       │
│  ┌─────────┐    ┌─────────┐    ┌─────────────────────────┐  │
│  │ Screens │───►│  BLoC   │───►│       Widgets           │  │
│  └─────────┘    └────┬────┘    └─────────────────────────┘  │
│                      │                                        │
├──────────────────────┼───────────────────────────────────────┤
│                      ▼          DOMAIN LAYER                  │
│               ┌─────────────┐                                 │
│               │  Use Cases  │                                 │
│               └──────┬──────┘                                 │
│                      │                                        │
│               ┌──────▼──────┐                                 │
│               │ Repository  │ (Interface)                     │
│               └─────────────┘                                 │
├──────────────────────────────────────────────────────────────┤
│                        DATA LAYER                             │
│  ┌─────────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ Repository Impl │───►│ DataSource  │───►│  API / DB   │  │
│  └─────────────────┘    └─────────────┘    └─────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## 🏃‍♂️ Installation & Run

### Prerequisites

- Flutter SDK 3.10.4+
- Dart SDK 3.0+
- Android Studio / Xcode
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/mebellar_olami.git
cd mebellar_olami

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Platform Support

| Platform | Status          | Min Version  |
| -------- | --------------- | ------------ |
| Android  | ✅ Supported    | SDK 21 (5.0) |
| iOS      | ✅ Supported    | iOS 12.0     |
| Web      | ⚠️ Experimental | —            |

---

## 🚀 Future Improvements

### Planned Enhancements

| Feature                  | Description                                                                     | Priority  |
| ------------------------ | ------------------------------------------------------------------------------- | --------- |
| **Offline First (Hive)** | Cache the entire product catalog for offline browsing with background sync      | 🔴 High   |
| **Dark Mode**            | Implement a dark theme variant maintaining the Cappuccino/Beige design language | 🟡 Medium |
| **Payment Integration**  | Payme, Click, and Stripe integration for seamless checkout                      | 🔴 High   |
| **Push Notifications**   | Deep OneSignal integration for order updates, promotions, and re-engagement     | 🟡 Medium |
| **Hero Animations**      | Add Hero animations for product card → detail screen transitions                | 🟢 Low    |
| **AR Preview**           | Augmented reality furniture placement in user's space                           | 🟢 Low    |
| **Reviews & Ratings**    | User-generated product reviews with photo uploads                               | 🟡 Medium |

---

## 📄 License

**Proprietary** — All rights reserved.

---

<div align="center">

**Built with ❤️ by the Mebellar Olami Team**

</div>
