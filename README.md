# Flutter Challenge: Advanced Post Management

Flutter Challenge is a high-performance, scalable mobile application built with Flutter. It demonstrates advanced concepts in state management, local persistence, native platform integration (Pigeon), and responsive UI design.

The project follows **Clean Architecture** principles and the **BLoC (Business Logic Component)** pattern to ensure a highly maintainable and testable codebase.

---

## 📸 Demo
| Android | iOS |
| :---: | :---: |
| [Placeholder: Android Video] | [Placeholder: iOS Video] |
| ![Android Demo](https://via.placeholder.com/300x600?text=Android+Demo) | ![iOS Demo](https://via.placeholder.com/300x600?text=iOS+Demo) |

---

## 🏗️ Architecture Overview

The system is designed using a **Feature-First Clean Architecture** approach, ensuring separation of concerns and ease of scalability.

### 🧠 Architectural Layers
- **Domain Layer**: Contains the core business logic (Entities, Use Cases, Repository interfaces). Completely independent of any external framework.
- **Data Layer**: Implements the repository interfaces. Handles data retrieval from remote APIs (Dio) and local storage (Hive).
- **Presentation Layer (BLoC)**: Manages UI state and handles user interactions. Uses the `flutter_bloc` package for predictable state transitions.
- **Core Layer**: Provides shared utilities, themes, and platform-specific bridges.

### Key Decisions
- **MVVM + BLoC**: Decoupling the UI from business logic with streams.
- **Hive Persistence**: Blazing fast local storage for offline capabilities and user preferences (Likes).
- **Pigeon for Native Communication**: Type-safe platform channels for local notifications on Android and iOS.

---

## 🛠️ Pigeon Integration

The project uses **Pigeon** to generate type-safe communication between Dart and native code (Kotlin/Swift) for notification handling.

### Generate Code
To regenerate the platform-specific code from `pigeons/api.dart`, run:

```bash
dart run pigeon --input pigeons/api.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / Xcode
- CocoaPods (for iOS)

### Installation
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. (iOS Only) Install pods:
   ```bash
   cd ios && pod install && cd ..
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## 📂 Documentation
- [**Requirements Guide**](./docs/requirements.md)
- [**Design Document**](./docs/design.md)

---

Developed as part of the **Flutter Challenge**.
