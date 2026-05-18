# Meditation Timer

[![Flutter Version](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A beautiful, distraction-free meditation timer for Android. Build a consistent mindfulness practice with customizable durations, relaxing alarm sounds, daily reminders, and session history tracking.

<p align="center">
  <img src="docs/screenshots/home.png" width="200" alt="Home Screen">
  <img src="docs/screenshots/meditation.png" width="200" alt="Active Session">
  <img src="docs/screenshots/alarm.png" width="200" alt="Full-Screen Alarm">
</p>

## ✨ Features

- 🧘 **Customizable Timer** — From 5 to 120 minutes, for beginners and advanced meditators.
- 🎵 **Relaxing Alarm Sounds** — Angelic, Bell, Rain, and Forest sounds to end your session gently.
- 🔔 **Daily Reminders** — Set a personalized notification to keep your practice consistent.
- 📊 **Session History** — Track your progress and build healthy habits.
- 🔥 **Streak Counter** — Stay motivated with consecutive-day streaks.
- 🖥️ **Full-Screen Alarm** — Never miss the end of your session, even with the screen off.
- 🌙 **Dark, Minimalist UI** — Clean design that keeps you focused.
- 🔒 **100% Offline & Private** — No account, no ads, no data collection. All data stays on your device.

## 🛠️ Tech Stack

- **Flutter 3.19+**
- **BLoC** pattern for state management
- **Clean Architecture** (Domain / Data / Presentation)
- **Dependency Injection** via `get_it`
- **Native Android Alarms** (AlarmManager + BroadcastReceivers)
- **Local Notifications** for daily reminders

## 📦 Installation

```bash
flutter pub get
flutter build apk --release
```

## 🌍 Localization

The app supports English and Spanish out of the box.

## 🛡️ Privacy

Meditation Timer does not collect, transmit, or store any personal data on external servers. All session history and preferences are stored locally on your device. Read the full [Privacy Policy](privacy_policy.html).

## 📝 License

MIT License — feel free to use and modify.

---

<p align="center">Made with 💙 for a calmer world.</p>
