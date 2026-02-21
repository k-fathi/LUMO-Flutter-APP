# LUMO - AI-Powered Autism Care & Analysis Platform 🧩

![LUMO Logo](assets/images/lumo-logo.png)

## Overview
**LUMO** is a cutting-edge, cross-platform mobile application built with Flutter, designed to bridge the gap between parents, doctors, and autistic children. By leveraging AI-driven analysis and a suite of medical tracking tools, LUMO provides a comprehensive ecosystem for monitoring developmental progress, managing therapy sessions, and fostering a supportive community.

---

## 🌟 Key Features

### 1. AI-Powered Dashboard (Parent View)
- **Deep Sentiment Analysis**: Visualizes child's emotional trends using advanced charting (Pie, Bar, and Line graphs).
- **Daily Progress Tracking**: Logs robot-puzzle sessions and therapy interactions with expressive emoji-based sentiment mapping.
- **AI Recommendation Engine**: Generates personalized medical prescriptions and behavioral advice based on cumulative data.
- **Dynamic Filtering**: View session-specific history or holistic weekly/monthly trends.

### 2. Clinical Management (Doctor View)
- **Patient Requests System**: Securely manage incoming patient join requests with one-click Accept/Reject functionality.
- **Patient Directory**: A centralized list of all supervised children with dynamic trend indicators (Improvement/Stability).
- **Session Scheduling**: Integrated tool for doctors to schedule and sync future therapy sessions with parents.
- **Detailed Patient Access**: Complete viewing rights to child analysis, session history, and reports.

### 3. Community & Social Feed
- **Global Network**: A social space where parents and doctors share insights, success stories, and specialized articles.
- **Bidi-Aware Interface**: Intelligent right-to-left (Arabic) and left-to-right (English) text detection for seamless multi-lingual conversations.
- **Interactive Engagement**: Like, comment, and share posts. Navigate directly from avatars to professional profiles.

### 4. Interactive AI Assistant (Pulsar)
- **Medical Chatbot**: A 24/7 AI companion designed with a glowing orb micro-interaction for a friendly user experience.
- **Persistence**: Remembers chat history locally for continuous care conversations.
- **Intelligent Suggestions**: Dynamic chips to guide parents toward helpful medical topics.

### 5. Secure Auth & Profile
- **Role-Based Access Control (RBAC)**: Specific workflows for Parents and Doctors.
- **Secure Account Deletion**: Full GDPR/Privacy compliant data purge including Firebase records and local cache.
- **Media Uploads**: High-speed image uploading for child photos and community posts via Firebase Storage.

---

## 🛠 Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **Backend/Database**: Firebase (Authentication, Firestore, Storage)
- **Architecture**: Layered Clean Architecture (UI -> Providers -> Repositories -> Data Sources)
- **State Management**: Provider & MultiProvider
- **Dependency Injection**: GetIt
- **UI & Graphics**: 
  - `fl_chart` for medical-grade data visualization.
  - `shimmer` for skeleton loading states.
  - `cached_network_image` for smooth performance.
  - Transparent glassmorphic design system.
- **Branding**: Official LUMO Branding with custom high-fidelity assets.

---

## 🏗 Repository Structure

- `lib/core`: Foundation logic, theme, DI, routing, and network clients.
- `lib/features`: Domain-specific modules (Auth, Analysis, Community, Chat, Profile).
- `lib/shared`: Cross-cutting widgets, providers, and models.
- `lib/data`: Repository implementations and local/remote data sources.
- `assets/`: 
  - `images/`: High-resolution branding and onboarding graphics.
  - `icons/`: Unified icon system.
  - `l10n/`: Localization files for Arabic and English support.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x recommended)
- Android SDK (api level 21+)
- Firebase Project setup

### Installation
1. Clone the repository:
   ```bash
   git clone git@github.com:k-fathi/LUMO-Flutter-APP.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

### Building for Release
To generate a production APK:
```bash
flutter build apk --release
```

---

## 🛡 Security & Privacy
LUMO prioritizes data privacy. 
- All medical data is stored in secure Firebase Firestore cells.
- Media is handled via authenticated Storage buckets.
- User-triggered account deletion ensures a **zero-residue** policy on both cloud and local devices.

---

## 👨‍💻 Developed By
**Karim Fathy** & LUMO Development Team.

*Final Code Audit: Zero Issues Found (`flutter analyze`).*
