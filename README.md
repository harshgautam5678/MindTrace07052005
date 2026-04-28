# MindTrace

MindTrace is an AI-driven emotional pattern analysis system designed to help users understand their mood trends, express their thoughts, and process past experiences.

---

## 🚀 Current Features

### 🔐 Authentication

* Email & Password login using Firebase Auth
* User-specific data storage

### 📊 Mood Tracking

* Users can log mood (1–10 scale)
* Stored securely per user in Firestore
* Latest mood displayed on Home screen

### 📝 Journal System (Day 3)

* Multi-line journal input
* Stores user thoughts in Firestore
* Data saved under:
  users/{userId}/journals
* Real-time fetching and display of journal entries

---

## 🧱 Tech Stack

* **Frontend:** Flutter
* **Backend:** Firebase (Firestore + Authentication)
* **Language:** Dart

---

## 📂 Project Structure

```
lib/
 ├── screens/
 │    ├── home_screen.dart
 │    ├── mood_screen.dart
 │    ├── journal_screen.dart
 │    ├── chat_screen.dart
 │    ├── sos_screen.dart
 │
 ├── components/
 ├── services/
 ├── models/
 ├── utils/
```

---

## 📅 Development Progress

### ✅ Day 1

* Flutter project setup
* Basic UI screens and navigation

### ✅ Day 2

* Firebase connected
* Authentication implemented
* Mood data stored per user
* Dynamic mood display

### ✅ Day 3

* Journal input system added
* Journal data stored per user
* Firestore integration for journals
* Real-time journal fetching and display

---

## 🔥 Upcoming Features

* 🤖 AI-based emotional analysis
* 🧠 Context-aware AI responses
* 📊 Mood & behavior pattern detection
* ⏳ “Past Release System” (processing past regrets)

---

## 🎯 Project Vision

To build an intelligent system that not only tracks emotions but also helps users understand and process them over time using AI-driven insights.

---

## ⚠️ Disclaimer

This application is not a medical or diagnostic tool. It is intended for emotional support and self-reflection only.

---
