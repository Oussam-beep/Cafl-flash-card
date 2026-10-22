# Cafl — Flashcard & Quiz App

A Flutter application for organizing study material into flashcard decks and practicing with multiple-choice quizzes. The project was built as a mobile development project and includes account screens, deck/card management, quiz sessions, score tracking, and profile/settings screens.

> **Project status:** Student project. The repository contains the Flutter source code; setup and behavior should be verified locally before treating it as a production-ready application.

## Features

- **User accounts:** registration and login screens.
- **Flashcard decks:** organize questions into named, color-coded decks.
- **Multiple-choice practice:** answer questions with four answer options.
- **Quiz results:** track correct and incorrect answers and retain quiz history.
- **Progress overview:** profile statistics for cards, quizzes, and answers.
- **Leaderboard screen:** a screen for displaying rankings.
- **Profile and settings:** edit profile information and access settings, privacy policy, and terms pages.
- **Local persistence:** SQLite storage for users, decks, cards, quiz history, and wrong answers.
- **State management:** Flutter BLoC for app and theme state.

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter & Dart | Cross-platform application UI |
| `flutter_bloc` | State management |
| SQLite (`sqflite`) | Local data persistence |
| `shared_preferences` | Store small local preferences |
| `fl_chart` | Charts and progress visualization |
| `google_fonts` | Typography |
| `intl` | Date and formatting utilities |

## Project Structure

```text
lib/
├── Bloc/       # Application and theme state
├── DB/         # Database initialization and data operations
├── screens/    # Login, registration, home, cards, quiz, scores,
│               # profile, settings, and related screens
└── main.dart   # Application entry point
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with the Dart SDK constraint in `pubspec.yaml`
- A configured emulator, connected device, or supported desktop target
- Git

### Run locally

1. Clone the repository:

   ```bash
   git clone https://github.com/Oussam-beep/Cafl-flash-card.git
   cd Cafl-flash-card
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Check the available run targets:

   ```bash
   flutter devices
   ```

4. Launch the application:

   ```bash
   flutter run
   ```

## Data & Implementation Notes

The database helper initializes a local SQLite database named `Cafl.db`. It defines tables for users, decks, and cards, with quiz-history and wrong-answer tables added through a database upgrade.

This repository should not be assumed to include a deployed backend or cloud synchronization. The `MYSQL.dart` file currently performs its data operations through the local SQLite helper.

## Future Improvements

- Add screenshots or a short demo GIF of the main user flows.
- Document and test the complete setup on a clean environment.
- Add automated tests for deck creation, quiz scoring, and persistence.
- Improve authentication security before any real-world deployment; passwords should not be stored as plain text.
- Clarify whether leaderboard data is local-only or backed by a shared service.

## Author

**Oussam-beep** — [GitHub profile](https://github.com/Oussam-beep)

---

Built with Flutter and Dart.