# 📅 Fixed Event Tracker (Date Reminder)

A cross-platform Flutter application designed to track recurring fixed annual events, such as birthdays, anniversaries, memorials, work milestones, and more. The app calculates upcoming milestone years, remaining days, and sends automated local push notifications before each event occurs.

---

## 📑 Features

* 🔔 **Local Notifications:** Schedule reminders with customizable lead times (on the day, 1 day, 3 days, or 1 week before).
* 🎨 **Category & Visual Customization:** Assign categories, custom icons, and theme colors to individual events.
* 🌐 **Internationalization (i18n):** Full localization support for English (`en`) and Portuguese (`pt`).
* 🌓 **Appearance Themes:** Supports Light Mode and Dark Mode automatically based on system or user preference.
* 📤 **Data Import & Export:** Backup and restore event records using CSV file export/import functionality.
* 📊 **Milestone Tracking:** Automatically displays annual milestone counters (e.g., age or anniversary length) and countdowns to the next occurrence.

---

## 🛠️ Built With

* **[Flutter](https://flutter.dev/)** - UI Toolkit
* **[Dart](https://dart.dev/)** - Programming Language
* **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** - Native local notifications delivery
* **[timezone](https://pub.dev/packages/timezone)** - Time zone utility for precise notification scheduling
* **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Persistent local key-value data storage
* **[csv](https://pub.dev/packages/csv)** & **[file_picker](https://pub.dev/packages/file_picker)** - Import/export file management

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
* Android Studio / VS Code with Flutter extensions
* An Android device or emulator running Android 5.0+

### Installation & Local Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/date-reminder.git
   cd date-reminder
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Release (Android APK)

To build a signed release APK for in-house distribution without store deployment:

```bash
flutter build apk --release
```

The output APK will be available at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License

This project is maintained for personal and internal team distribution.
