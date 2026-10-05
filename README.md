# FitTrack – Modern Fitness Tracker Mobile Application

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-Enabled-7B1FA2?logo=materialdesign&logoColor=white)
![Database](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![State Management](https://img.shields.io/badge/State-Provider%206.1-4CAF50)
![Charts](https://img.shields.io/badge/Charts-fl__chart-FF6F00)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

**"Track. Move. Improve."**

A complete, modern, simple, and user-friendly mobile application built with Flutter and SQLite for tracking daily workouts, calories, steps, and fitness goals.

</div>

---

## 📌 Project Overview

**FitTrack** is an offline-first fitness tracking mobile application designed for college project assignments, portfolios, and real-world daily fitness tracking. It allows users to log workouts, track physical activities, visualize weekly trends through interactive graphs and charts, monitor progress against daily fitness targets, and store all data locally using SQLite.

---

## ✨ Features & Highlights

### 1. 🏠 Dynamic Dashboard
* **Smart Header**: Time-based greeting (*"Good Morning / Afternoon / Evening, [User] 👋"*) and formatted current date (*e.g. "Monday, October 5"*).
* **2x2 Daily Summary Cards**: Visual cards for **Steps**, **Calories**, **Workout Duration**, and **Distance** with embedded circular progress rings and goal comparison.
* **Today's Progress Section**: Color-coded linear progress bars showing real-time percentage completion toward daily targets.
* **Weekly Activity Chart**: Interactive Bar Chart powered by `fl_chart` with interactive metric switching between **Steps**, **Calories**, and **Workout Minutes**.
* **Recent Activities**: Clean list of the latest workouts displaying exercise type, duration, calories, relative timestamps (*"Today, 6:30 PM"*, *"Yesterday"*), and quick action menus.
* **Extended FAB**: Quick-access `+ Add Activity` floating action button.

### 2. ➕ Activity Logging & Form Validation
* **10 Exercise Categories**: *Running, Walking, Cycling, Swimming, Gym, Strength Training, Yoga, HIIT, Sports, Other* — each with thematic colors and icons.
* **Comprehensive Inputs**: Duration (minutes), Calories burned (kcal), optional Distance (km), optional Steps, Date picker, Time picker, and multiline workout notes.
* **One-Tap Calorie Auto-Estimation**: Automatically estimates calories burned using standard exercise MET rates and workout duration.
* **Form Validation**: Validates inputs with friendly error messages (prevents zero or negative durations, negative numbers, or empty types).
* **Edit & Update Support**: Reusable form architecture supporting both creating new activities and updating existing entries.

### 3. 📜 Activity History & Search
* Chronological listing of all recorded workouts from SQLite.
* **Live Search**: Instant keyword filtering by exercise name or workout notes.
* **Category Filters**: Filter chips to view workouts by specific exercise types (*All, Running, Walking, Gym, etc.*).
* **Swipe & Menu Actions**: Edit activity or delete with a safety confirmation dialog.

### 4. 📊 Statistics & Interactive Analytics
* **Today's Summary**: Quick summary metrics for steps, calories, workout minutes, and distance.
* **Weekly Overview**: Total weekly steps, calories burned, total workout time, average daily steps, and average daily calories.
* **3 Dedicated `fl_chart` Charts**:
  1. *Weekly Steps Chart* (Daily steps comparison across 7 days)
  2. *Weekly Calories Chart* (Daily calories burned breakdown)
  3. *Weekly Workout Duration Chart* (Daily active minutes breakdown)

### 5. 🎯 Customizable Daily Goals
* Set and adjust daily fitness targets:
  * **Steps Goal** (Default: `10,000 steps`)
  * **Calories Goal** (Default: `700 kcal`)
  * **Workout Duration Goal** (Default: `60 minutes`)
  * **Distance Goal** (Default: `5.0 km`)
* Targets are stored persistently in SQLite and immediately reflect on dashboard progress indicators.
* One-tap **"Defaults"** button to restore recommended standards.

### 6. 👤 Profile & Local Data Management
* Customizable user display name persisted via `SharedPreferences`.
* **Lifetime Achievement Stats**: Total workouts logged, all-time calories burned, and total steps taken.
* **Load Sample Activities**: One-tap button that seeds 7 days of realistic workouts across varied exercises (ideal for demonstrations, grading, and testing).
* **Clear All Activities**: Safely wipe all local workout data with confirmation.
* **About Section**: Application version, purpose, and framework metadata.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, modular architecture separating UI, business logic, state management, and database operations:

```text
lib/
├── main.dart                          # App initialization, SQLite FFI setup, MultiProvider
│
├── models/
│   ├── activity.dart                  # Activity model with SQLite serialization & copyWith
│   └── fitness_goal.dart              # FitnessGoal model with targets & default values
│
├── database/
│   └── database_helper.dart           # SQLite helper with CRUD, queries & demo seeder
│
├── services/
│   └── fitness_service.dart           # Math calculations, calorie estimation & weekly aggregations
│
├── providers/
│   ├── activity_provider.dart         # Activities state, statistics calculation & DB syncing
│   └── goal_provider.dart             # Daily goals & user profile state management
│
├── utils/
│   ├── app_theme.dart                 # Material 3 theme, Google Fonts Inter, rounded cards
│   └── constants.dart                 # Exercise types, colors, icons, and calorie estimates
│
├── widgets/
│   ├── summary_card.dart              # 2x2 metric card with circular progress badge
│   ├── progress_card.dart             # "Today's Progress" linear bars with percent badges
│   ├── activity_card.dart             # Workout card with relative timestamps & edit/delete
│   ├── weekly_chart.dart              # Interactive fl_chart bar chart with metric switching
│   └── empty_state.dart               # Friendly zero-data state with action buttons
│
└── screens/
    ├── splash_screen.dart             # Animated logo, tagline & SQLite preload
    ├── main_navigation_screen.dart    # 4-tab Material 3 bottom navigation with IndexedStack
    ├── dashboard_screen.dart          # Main dashboard with greeting, cards, chart & workouts
    ├── add_activity_screen.dart       # Form with validation, auto-calorie estimate & pickers
    ├── activity_history_screen.dart   # Search bar, category filters, edit/delete actions
    ├── statistics_screen.dart         # Today & weekly stats, 3 dedicated fl_chart charts
    ├── goals_screen.dart              # Target customization for steps, calories, workout & km
    └── profile_screen.dart            # Profile editor, lifetime metrics, demo seeder & reset
```

---

## 🛠️ Technology Stack & Dependencies

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.12.2 / Dart ^3.12) |
| **Design System** | [Material 3](https://m3.material.io/) |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) (`Inter`) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`^6.1.5`) |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) (`^2.4.4`) & [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) (`^1.2.0`) |
| **Date & Time Formatting** | [intl](https://pub.dev/packages/intl) (`^0.20.3`) |
| **Lightweight Preferences** | [shared_preferences](https://pub.dev/packages/shared_preferences) (`^2.5.5`) |

---

## 🗄️ Database Schema

### `activities` Table
```sql
CREATE TABLE activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    exerciseType TEXT NOT NULL,
    duration INTEGER NOT NULL,
    calories REAL NOT NULL,
    distance REAL,
    steps INTEGER,
    date TEXT NOT NULL,       -- Stored as 'YYYY-MM-DD'
    time TEXT,               -- Stored as 'hh:mm a'
    notes TEXT
);
```

### `goals` Table
```sql
CREATE TABLE goals (
    id INTEGER PRIMARY KEY,
    steps INTEGER NOT NULL,
    calories REAL NOT NULL,
    workoutMinutes INTEGER NOT NULL,
    distance REAL NOT NULL
);
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.24.0 or newer recommended)
* Android Studio / VS Code with Flutter extension
* Android Device / Android Emulator OR Windows desktop developer mode enabled

### Installation

1. **Clone or open the project folder**:
   ```bash
   cd "New folder"
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   flutter analyze
   ```
   *Expected result: `No issues found!`*

4. **Run automated unit & widget tests**:
   ```bash
   flutter test
   ```
   *Expected result: `All tests passed!`*

---

## 📱 Running the Application

### On an Android Device or Emulator
```bash
# Check connected devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554
```

### On Windows Desktop
Thanks to `sqflite_common_ffi` integration, the app runs natively on Windows desktop:
```bash
flutter run -d windows
```

---

## 🧪 Test Suite Coverage

The project includes unit and widget tests in [`test/widget_test.dart`](test/widget_test.dart):
* **Model Serialization**: Validates `toMap` and `fromMap` transformations for `Activity` and `FitnessGoal`.
* **Business Logic**: Tests progress calculation clamping (`min(current / goal, 1.0)`), percentage rounding, and MET calorie estimations.
* **Widget Smoke Tests**: Ensures UI components like `SummaryCard` and `ProgressCard` render correct values, labels, and progress bars.

---

## 🎨 Color Palette

| Name | Hex Code | Preview |
|---|---|---|
| **Primary Green** | `#4CAF50` | ![#4CAF50](https://via.placeholder.com/15/4CAF50/000000?text=+) |
| **Secondary Blue** | `#2196F3` | ![#2196F3](https://via.placeholder.com/15/2196F3/000000?text=+) |
| **Accent Orange** | `#FF9800` | ![#FF9800](https://via.placeholder.com/15/FF9800/000000?text=+) |
| **Accent Purple** | `#9C27B0` | ![#9C27B0](https://via.placeholder.com/15/9C27B0/000000?text=+) |
| **Background** | `#F5F7FA` | ![#F5F7FA](https://via.placeholder.com/15/F5F7FA/000000?text=+) |
| **Card Surface** | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) |
| **Text Primary** | `#1F2937` | ![#1F2937](https://via.placeholder.com/15/1F2937/000000?text=+) |

---

## 📄 License

This project is licensed under the MIT License — free for educational and commercial use.
