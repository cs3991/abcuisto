# ABCuisto

ABCuisto is a Flutter client for the ABCuisto recipe service. Browse recipes, manage your own recipes, and share them through groups. The application interface is in French.

## Features

- Browse and search recipes with paginated results.
- Filter by time, tags, categories, ingredients to include or exclude, creator, and groups.
- View instructions and adjust ingredient quantities for different portions.
- Create and edit recipes with ingredients, instructions, and photos.
- Manage favorites and recipe comments.
- Sign up, log in, reset a password, and manage a profile.
- Create and join groups, manage members and permissions, and share invitations.
- Open shared recipe and group links on Android and iOS.
- Choose a light, dark, or system theme, with the preference saved locally.

Feature availability depends on authentication and API permissions.

## Requirements

- Flutter with a bundled Dart SDK compatible with `^3.8.1` (see `pubspec.yaml`).
- The Flutter platform toolchain for your target device or desktop.
- Access to an ABCuisto API server. This repository contains the client, and does not include the backend.
- Python 3.9 or later for the optional Linux installation script.

## Getting started

Install dependencies from the repository root:

```bash
flutter pub get
```

Run against the production API:

```bash
flutter run --target lib/main_prod.dart
```

For local backend development, update the development API address in `lib/app_config.dart` to an address reachable from your device, then run:

```bash
flutter run --target lib/main_dev.dart
```

Add `-d <device-id>` to select a device when needed.

## Environments

API addresses are configured in `lib/app_config.dart`:

| Environment | Entry point | API URL |
| --- | --- | --- |
| Development | `lib/main_dev.dart` | `http://192.168.1.102:7067` |
| Production | `lib/main_prod.dart` | `https://back.abcuisto.fr` |

The default entry point, `lib/main.dart`, uses production unless `APP_FLAVOR` is supplied:

```bash
flutter run --dart-define=APP_FLAVOR=dev
flutter run --dart-define=APP_FLAVOR=prod
```

Prefer the explicit entry points to make the intended environment clear. A shared link does not switch the app's API environment.

## Release builds

Build a production Android APK:

```bash
flutter build apk --release --target lib/main_prod.dart
```

Build a production Linux bundle:

```bash
flutter build linux --release --target lib/main_prod.dart
```

On Linux x64, install the generated bundle for the current user:

```bash
python3 build/linux/x64/release/bundle/install.py
```

See [Linux installation](linux/packaging/README.md) for installation paths, updates, other architectures, and removal instructions.

The repository also includes iOS, macOS, Windows, and web platform directories. Platform support and feature behavior should be validated on the intended target.

## Architecture

The application uses Cubits from `flutter_bloc` for application and feature state, with `provider` for repository injection.

```text
Widgets → Cubits → AbcuistoRepository → HTTP API
```

- Widgets render state, collect input, and dispatch user intents.
- Cubits coordinate business logic and expose loading, success, and failure states.
- `AbcuistoRepository` handles HTTP requests, response conversion, and persisted authentication data.
- `lib/main.dart` initializes local storage and provides the shared repository and app-wide Cubits.
- UI listeners coordinate changes between features, such as refreshing recipe permissions after authentication changes.

```text
lib/
├── main.dart             # Shared startup, providers, themes, and app shell
├── main_dev.dart         # Development entry point
├── main_prod.dart        # Production entry point
├── app_config.dart       # Environment and API configuration
├── models/               # Domain models, API repository, and session storage
├── login/                # Authentication screens and Cubit
├── recipe/               # Recipe list, details, comments, and quantity adjustment
│   ├── add_recipe/       # Recipe creation and editing
│   └── filters/          # Search filters and filter state
├── profile/              # Profile management and group features
├── links/                # Incoming links and linked recipe loading
└── theme/                # Persisted theme selection
```

## Shared links

The Android and iOS configuration accepts these HTTPS paths on `abcuisto.fr` and `dev.abcuisto.fr`:

- `/recette/ID` opens a recipe.
- `/group/ID` opens a group invitation, with login when needed and confirmation before joining.

Automatic opening requires domain association files matching the installed application's signing identity. See [app link configuration](docs/app-links/README.md) for deployment details and remaining platform setup.

## Contributing

Follow [AGENTS.md](AGENTS.md) for architecture and collaboration conventions. Keep API access in the repository and business state in feature Cubits. Use rounded Material icons for UI changes and English commit messages.

Known issues and improvement opportunities are tracked in [todo.md](todo.md).
