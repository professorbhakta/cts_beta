# AGENTS.md

## Cursor Cloud specific instructions

This repository is the **CTS / c2s "Commuter Transport System"** — a **Flutter** mobile app
(Android + iOS) for admin, driver, and commuter roles. It is **frontend-only**; the REST API
and WebSocket backend are external and **not** in this repo (see `docs/API_AND_ENV.md`).

> Note: the application code lives on the **`beta-ver`** branch. `main` currently contains only
> a placeholder `README.md`.

### Toolchain (already installed in the VM snapshot)
- **Flutter 3.44.7 / Dart 3.12.2** at `/opt/flutter/bin` (matches `pubspec.yaml` `sdk: ^3.12.2`).
- **Android SDK** at `/opt/android-sdk` (`ANDROID_HOME`), with platforms 34/35/36, build-tools 36,
  NDK, and **CMake 3.31.6** (pinned in `android/app/build.gradle.kts` — the debug APK build fails
  without it).
- `PATH`/`ANDROID_HOME` are exported in `~/.bashrc`. Non-interactive shells do **not** auto-source
  it: if `flutter` is not found, run `source ~/.bashrc` first, or call `/opt/flutter/bin/flutter`
  directly.
- The Android Gradle build works with the VM's **Java 21**.

### Standard commands (from `docs/BUILD_AND_RELEASE.md` / `docs/TESTING.md`)
- Lint: `flutter analyze`
- Test: `flutter test`
- Build: `flutter build apk --debug` (output `build/app/outputs/flutter-apk/app-debug.apk`)
- The startup update script already runs `flutter pub get` and creates `.env` from `.env.example`.

### Running the app in this headless VM (non-obvious)
- There is **no `/dev/kvm`**, so an Android emulator cannot boot here. Physical devices aren't
  attached either.
- The app is **mobile-only**: `main.dart` initializes `sqflite` at startup (`AppDatabase` +
  `OfflineTempDatabase`, and `SyncManager` reads the DB), and `sqflite` has **no web/desktop
  backend** in `pubspec.yaml`. So `flutter run -d web-server` / `-d chrome` compiles and serves,
  but the screen stays **blank** because DB init aborts before `runApp`.
- To actually see the UI in a browser during setup, two temporary shims are needed (do **not**
  commit them): (1) add `sqflite_common_ffi_web`, run `dart run sqflite_common_ffi_web:setup`,
  and set `databaseFactory = databaseFactoryFfiWeb` for `kIsWeb` in `main.dart`; (2) enable
  Chrome's `chrome://flags/#enable-unsafe-swiftshader` flag (this VM's Chrome refuses the
  automatic software-WebGL fallback, otherwise Flutter's CanvasKit renderer never paints).
- Without a backend, login won't succeed. A backend-free in-app flow for smoke testing is the
  **Sign In → "Preview UI wireframes (debug)"** link (route `/designWireframes`).
