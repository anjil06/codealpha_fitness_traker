# FitTrack – Modern Phone Activity & Fitness Tracker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-Enabled-7B1FA2?logo=materialdesign&logoColor=white)
![Sensors](https://img.shields.io/badge/Sensors-Pedometer%20%2B%20GPS-00C853?logo=android&logoColor=white)
![Database](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![State Management](https://img.shields.io/badge/State-Provider%206.1-4CAF50)
![Charts](https://img.shields.io/badge/Charts-fl__chart-FF6F00)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

**"Track. Move. Improve."**

A complete, modern, device-centric mobile application built with Flutter, SQLite, hardware step sensors, and GPS for tracking real-time footsteps, distance traveled while moving from place to place, and fitness activities directly on the phone.

</div>

---

## 📌 Project Overview

**FitTrack** is an offline-first **device-based activity tracker**. Activities, foot steps, and distance traveled belong directly to the **phone carried by the user**, rather than requiring personal accounts or user profiles. Anyone who carries the phone has their real-time footsteps counted via hardware pedometer sensors and their real-time traveling distance measured via GPS.

---

## ✨ Features & Highlights

### 1. ⚡ Real-Time Hardware Step Counter & GPS Distance Tracking
* **Hardware Pedometer Integration**: Listens to the device's physical step sensor (`Sensor.TYPE_STEP_COUNTER`) to count real footsteps as you walk or carry your phone.
* **Live GPS Distance Traveled**: High-precision GPS tracking calculates exact distance traveled (in meters and kilometers) as you travel from one place to another.
* **Live Activity & Trip Tracker**:
  * Digital stopwatch timer (HH:MM:SS)
  * Real-time distance counter (`0.00 km`)
  * Real-time live footsteps counter
  * Real-time speedometer (`km/h`) and calorie burn rate
  * One-tap **"Finish & Save"** that records the trip/workout directly into the local SQLite database.
* **Persistent Daily Sensor Baselines**: Daily steps and distances are stored persistently with automatic day-boundary transitions.

### 2. 🏠 Dynamic Dashboard
* **Device Status Header**: Time-based greeting (*"Good Morning 👋"*), device status indicator, and formatted current date.
* **Live Sensor Banner**: Real-time status badge showing active sensors, current live steps, traveled distance, and quick **"Track Trip"** button.
* **Combined Real-Time Summary Cards**: Visual cards for **Steps**, **Calories**, **Workout Duration**, and **Distance** combining both stored database workouts and live sensor data.
* **Today's Progress Section**: Color-coded progress bars showing percentage completion toward device daily targets.
* **Weekly Activity Chart**: Interactive Bar Chart powered by `fl_chart` with metric switching between **Steps**, **Calories**, and **Workout Minutes**.
* **Dual Action Buttons**: Quick-access floating buttons for **Track Trip** (Live GPS & steps) and **Add Activity** (manual entry).

### 3. ➕ Activity Logging & Form Validation
* **10 Exercise Categories**: *Running, Walking, Cycling, Swimming, Gym, Strength Training, Yoga, HIIT, Sports, Other*.
* **Comprehensive Inputs**: Duration (minutes), Calories burned (kcal), optional Distance (km), optional Steps, Date picker, Time picker, and workout notes.
* **One-Tap Calorie Auto-Estimation**: Automatically estimates calories burned using exercise MET rates and duration.
* **Form Validation**: Friendly error validation ensuring positive numbers and required fields.

### 4. 📜 Activity History & Search
* Chronological listing of all recorded workouts stored locally in SQLite.
* **Live Search**: Instant keyword filtering by exercise name or workout notes.
* **Category Filters**: Filter chips to view workouts by specific exercise types.
* **Edit & Delete Actions**: Edit past workouts or delete them with safety confirmation dialogs.

### 5. 📊 Statistics & Interactive Analytics
* **Today's Statistics**: Total steps, calories, duration, and distance.
* **Weekly Overview**: Total weekly steps, calories burned, active duration, and daily averages.
* **3 Dedicated `fl_chart` Charts**:
  1. *Weekly Steps Chart*
  2. *Weekly Calories Chart*
  3. *Weekly Workout Duration Chart*

### 6. 📱 Device Settings & Target Management
* **Device-Centric Design**: All records belong to this phone without personal profile restrictions.
* **Hardware Diagnostics**: Displays live status of Hardware Step Counter, GPS Location Tracking, and SQLite Database.
* **Customizable Device Daily Targets**:
  * Steps Target (Default: `10,000 steps`)
  * Calories Target (Default: `700 kcal`)
  * Workout Duration Target (Default: `60 minutes`)
  * Distance Target (Default: `5.0 km`)
* **Data Management**:
  * *Load Sample Activities*: One-tap button that seeds 7 days of realistic workouts.
  * *Clear Device Activities*: Wipes local database with confirmation dialog.

---

## 🏗️ Architecture & Project Structure

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
│   ├── fitness_service.dart           # Math calculations, calorie estimation & weekly aggregations
│   └── realtime_tracker_service.dart  # Hardware pedometer streams & GPS distance tracking
│
├── providers/
│   ├── activity_provider.dart         # Activities state, statistics calculation & DB syncing
│   ├── goal_provider.dart             # Device daily targets management
│   └── realtime_tracker_provider.dart # Live sensor tracking & active workout session state
│
├── screens/
│   ├── splash_screen.dart             # App logo & branding splash screen
│   ├── main_navigation_screen.dart    # Bottom navigation bar (Home, History, Stats, Device)
│   ├── dashboard_screen.dart          # Main dashboard with live banner & summary cards
│   ├── live_workout_screen.dart       # Real-time GPS distance & step tracking HUD
│   ├── add_activity_screen.dart       # Activity entry form with validation
│   ├── activity_history_screen.dart   # Filterable activity timeline with search
│   ├── statistics_screen.dart         # Detailed metrics & fl_chart visualizations
│   ├── goals_screen.dart              # Device daily targets configuration
│   └── profile_screen.dart            # Device status, sensor diagnostics & data management
│
├── widgets/
│   ├── realtime_tracker_banner.dart   # Live tracking status banner on dashboard
│   ├── summary_card.dart              # 2x2 metric cards with circular progress rings
│   ├── progress_card.dart             # Linear progress indicators for today's targets
│   ├── activity_card.dart             # Activity list item with options & category badges
│   ├── weekly_chart.dart              # fl_chart bar chart with metric selector
│   └── empty_state.dart               # Empty state placeholder with action buttons
│
└── utils/
    ├── app_theme.dart                 # Material 3 theme, Google Fonts Inter, rounded styling
    └── constants.dart                 # Exercise types, colors, icons, and calorie estimates
```

---

## ⚙️ Hardware Permissions Required

FitTrack requires standard Android hardware permissions to count footsteps and measure traveling distance:
* `android.permission.ACTIVITY_RECOGNITION`: Allows listening to physical device step counter sensors.
* `android.permission.ACCESS_FINE_LOCATION`: Allows calculating high-accuracy GPS distance traveled.
* `android.permission.ACCESS_COARSE_LOCATION`: Approximate location fallback.

---

## 🧪 Testing

The application includes automated unit and widget test coverage:

```bash
flutter test
```

### Verified Test Cases:
* `Activity` model serialization (`toMap` / `fromMap`)
* `FitnessGoal` model serialization & defaults
* `FitnessService` progress math and MET calorie calculations
* `SummaryCard` and `ProgressCard` widget rendering
* `LiveWorkoutScreen` live HUD rendering with GPS distance and footsteps counter

---

## 📦 Building the Release APK

```bash
flutter build apk --release
```

The compiled release APK is located at:
* `build/app/outputs/flutter-apk/app-release.apk`
* `FitTrack-v1.0.0.apk`
