# TaskX

"The Smartest Way to Manage Tasks Between Friends, Teams & Startups"

## Getting Started

This project is a Flutter application with Firebase backend.

### Prerequisites

- Flutter SDK
- Firebase CLI (for Firebase setup)
- Android Studio / XCode (for running on emulators or physical devices)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (follow instructions in Firebase setup section)
4. Run the app with `flutter run`

## Project Structure

The project follows a clean architecture approach with the following main directories:

- `lib/app`: App-level components (theme, routes)
- `lib/common`: Common utilities and widgets
- `lib/core`: Core functionality (analytics, error handling, network)
- `lib/data`: Data layer (models, repositories, services)
- `lib/domain`: Domain layer (entities, use cases)
- `lib/features`: Feature modules (auth, tasks, workspaces)

## Firebase Setup

1. Create a new Firebase project
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files
4. Run `flutterfire configure` to set up Firebase

## Features

- Task Assignment with Comments
- Private Personal & Shared Workspaces
- Deadline Reminders
- Chat-style Feed for Each Task
- Progress Tracker
- Voice Notes in Tasks
- Basic Analytics & Task History

## Running Tests

- Unit tests: `flutter test test/unit`
- Widget tests: `flutter test test/widget`
- Integration tests: `flutter test test/integration`
