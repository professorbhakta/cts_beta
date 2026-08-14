> **Doc:** docs/BUILD_AND_RELEASE.md
> **Updated:** 2026-08-14 19:55 IST
> **Session:** Auth security wave — release has no cleartext

# Build and release

How to build and ship the CTS Flutter app (Android focus from current project notes).

**See also:** [../PROJECT_TODOS.md](../PROJECT_TODOS.md) · [TESTING.md](./TESTING.md)

---

## Prerequisites

- Flutter SDK (project uses current stable toolchain; run `flutter doctor`)
- Android Studio / SDK for Android builds
- Xcode on macOS for iOS builds
- Copy [`.env.example`](../.env.example) → `.env` and set `API_BASE_URL` / `WEBSOCKET_URL` for your backend

---

## Everyday commands

```bash
flutter pub get
flutter analyze
flutter test
```

### Phase 8 quality gate (required after feature work)

Run in this order before calling a session done:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- `flutter analyze` must report **0 issues**
- Debug APK output (typical): `build/app/outputs/flutter-apk/app-debug.apk`
- Historical copy path from earlier validation: `build_android/app/outputs/apk/debug/app-debug.apk`

### Debug run

```bash
flutter run
```

### Debug APK (Android)

```bash
flutter build apk --debug
```

Output (typical): `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (when signing configured)

```bash
flutter build apk --release
```

---

## Android notes (from project history)

Documented fixes in PROJECT_TODOS:

- Main/release manifest: INTERNET only (no `usesCleartextTraffic`). Debug/profile manifests allow HTTP for LAN Docker.
- CMake version pinned for NDK builds
- Kotlin incremental cache issues on Windows (C: pub cache + D: project) — Gradle flags documented in PROJECT_TODOS

Before store release:

- Replace LAN `http://…` with production **HTTPS** / **WSS** in `.env` (AppConfig does not downgrade schemes)
- Configure signing (`key.properties`, release keystore)
- Review `android/app/build.gradle.kts` min/target SDK

---

## iOS checklist

- Open `ios/Runner.xcworkspace` in Xcode
- Set team / bundle id
- Configure ATS if using non-HTTPS API (dev only; production should use HTTPS/WSS)
- `flutter build ios` or archive via Xcode

---

## Environment at build time

`.env` is loaded as a Flutter asset (see `pubspec.yaml`). Values are baked into the app bundle — use CI secrets for production URLs, not committed `.env` with secrets.

---

## Versioning

Update in:

- `pubspec.yaml` — `version: x.y.z+build`
- Android `versionCode` / `versionName` (Flutter manages via pubspec when using standard template)
- iOS `CFBundleShortVersionString` / `CFBundleVersion`

---

## CI suggestion (future)

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --debug` or `--release`

---

## Troubleshooting

| Issue | Try |
|-------|-----|
| Gradle / Kotlin cache errors | See PROJECT_TODOS “Build fixes”; clean `flutter clean` |
| Missing assets in pubspec | Ensure images referenced in pubspec exist under `assets/` |
| API unreachable on device | Use machine LAN IP in `.env`; same Wi‑Fi as phone |
| Wireframes missing in release | Expected — gallery is debug-only |
