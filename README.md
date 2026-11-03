# KRICO - Krida & Coach Sports Ecosystem Platform (v0.1)

[![Deploy to GitHub Pages](https://github.com/AAYUSHNIKAM/KRICO-0.1/actions/workflows/deploy.yml/badge.svg)](https://github.com/AAYUSHNIKAM/KRICO-0.1/actions/workflows/deploy.yml)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-2ea44f?style=flat&logo=github)](https://aayushnikam.github.io/KRICO-0.1/)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Theme](https://img.shields.io/badge/Default%20Theme-Warm%20Athletic%20Light-76A200)](https://aayushnikam.github.io/KRICO-0.1/)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](#platforms-supported)
[![State Management](https://img.shields.io/badge/State-Flutter%20Riverpod%20v3-blueviolet)](https://riverpod.dev)
[![Routing](https://img.shields.io/badge/Navigation-GoRouter-orange)](https://pub.dev/packages/go_router)

**KRICO** is an end-to-end, multi-role sports management and athlete empowerment platform. Built on Flutter and powered by Google Cloud & Firebase, KRICO seamlessly connects **Athletes (Players)**, **Coaches**, **Sports Academies**, **Parents**, and **Ecosystem Administrators** in a unified, high-performance digital environment.

**Live Application URL**: [https://aayushnikam.github.io/KRICO-0.1/](https://aayushnikam.github.io/KRICO-0.1/)

---

## What's New in v0.1

- **Warm Athletic Premium Light Theme (Default)**: A custom-designed light interface combining warm ivory foundations (`#F6F4EE`), crisp porcelain card surfaces (`#FFFFFF`), precision dual-layer ambient shadows, and electric fluorescent volt badges (`#B7E532` on `#20251D` with 11.5:1 contrast).
- **Cyber-Athletic Obsidian Dark Theme**: Futuristic cockpit theme (`#090A0F`) with neon lime (`#CCFF00`), cyan HUD glows, and deep-contrast glassmorphic telemetry cards.
- **Coach-Verified Telemetry Engine**: Authentic XP, streak, and verified drill counters linked directly to coach session attendance.
- **Physical VIP Stadium Pass**: High-gloss stadium credential hero with dynamic athletic header striping, real-time countdowns, and QR gate verification.
- **Responsive 3-Column Navigation System**: Seamless multi-role layouts automatically adapting between 360px mobile viewports, 800px tablets, and 1280px+ wide desktop cockpits.

---

## Multi-Role Architecture

KRICO provisions dedicated experiences for each stakeholder:

```
                      +-------------------+
                      |   KRICO ENGINE    |
                      +---------+---------+
                                |
       +------------+-----------+-----------+------------+
       |            |           |           |            |
+------v-----+ +----v----+ +----v----+ +----v-----+ +----v----+
|   PLAYER   | |  COACH  | | ACADEMY | |  PARENT  | |  ADMIN  |
|   PORTAL   | |   HUB   | | SYSTEM  | |  PORTAL  | | CONSOLE |
+------------+ +---------+ +---------+ +---------+ +---------+
```

1. **Player (Athlete)**:
   - Command Center with verified athletic telemetry, training rhythm streaks, and level progression.
   - Live stadium ticket hero with interactive QR gate pass access.
   - 15-tier athletic certification showcase with vector PDF exports.
   - Coach discovery across 30 Olympic and academy sports.
   - Attendance ledger tracking verified coach sessions.

2. **Coach**:
   - Command center with daily session timetable, athlete rosters, and real-time billing value.
   - Urgent pending booking request banner with 1-tap booking acceptance.
   - Training routines and 100% KRICO XP allocation configurations.
   - Availability and session calendar with conflict avoidance.

3. **Academy**:
   - Batch formation and schedule management with capacity tracking.
   - Staff recruitment (job posting, application review, coach contracts).
   - Student enrollment tracking and academy analytics.

4. **Parent**:
   - Training session logger for duration, effort rating (/5), and energy levels.
   - Direct coach communication and scheduled session oversight.
   - Linked athlete progress and attendance monitoring.

5. **Administrator**:
   - Platform-wide KPI counters (active users, total bookings, verified venues, platform revenue).
   - Role permission audits and verification reviews.

---

## Design System & Theme Engine

| Property | Warm Athletic Light (Default) | Cyber-Athletic Dark |
| :--- | :--- | :--- |
| **Canvas Background** | Warm Ivory (`#F6F4EE`) | Midnight Obsidian (`#090A0F`) |
| **Card Surface** | Pure Porcelain (`#FFFFFF` to `#FAFAF7`) | Deep Slate (`#131722`) |
| **Surface Secondary** | Soft Warm Neutral (`#EDEFE7`) | Pitch Surface (`#161A24`) |
| **Primary Accent** | Athletic Olive (`#76A200`) | Neon Volt (`#CCFF00`) |
| **High-Energy Badge** | Fluorescent Lime (`#B7E532` on `#20251D`) | Electric Volt (`#CCFF00` on `#090A0F`) |
| **Contrast Ratio** | **11.5:1** (Badges) / **4.8:1** (Icons) | **14.2:1** (High-Contrast HUD) |
| **Hero Actions** | Authoritative Charcoal (`#20251D`) | High-Luminance Volt (`#CCFF00`) |
| **Borders** | Warm Mineral (`#E5E6DE`) | Slate Obsidian (`#222736`) |

---

## Branching Strategy

| Branch | Purpose | Deployment Pipeline |
| :--- | :--- | :--- |
| `master` | Production release branch | Deployed live to [GitHub Pages](https://aayushnikam.github.io/KRICO-0.1/) |
| `qa` | Staging & quality assurance verification | Automated QA CI/CD checks |
| `dev` | Active development & feature integration | Branch for active development & test suites |

---

## Technology Stack

- **Framework**: [Flutter 3.22+](https://flutter.dev) (Web, Android, iOS, Desktop)
- **Language**: [Dart 3.4+](https://dart.dev)
- **State Management**: [Flutter Riverpod v3](https://riverpod.dev)
- **Routing**: [GoRouter v17](https://pub.dev/packages/go_router)
- **Database & Cloud**: Firebase Authentication, Cloud Firestore, Cloud Storage
- **Typography & Icons**: Google Fonts (Inter), Material Rounded Icons
- **PDF Generation**: [pdf / printing](https://pub.dev/packages/pdf)
- **CI/CD**: GitHub Actions deploying to GitHub Pages

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.22.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.4.0`)
- Chrome browser (for Flutter Web development)

### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/AAYUSHNIKAM/KRICO-0.1.git
cd KRICO-0.1

# 2. Get dependencies
flutter pub get

# 3. Run static analysis & tests
flutter analyze --no-pub
flutter test --no-pub

# 4. Launch locally in Chrome
flutter run -d chrome
```

---

## License & Credits

Developed for the **KRICO Sports Ecosystem**. All rights reserved.
