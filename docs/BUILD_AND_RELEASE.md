> **Doc:** docs/BUILD_AND_RELEASE.md
> **Updated:** 2026-09-15 10:40 IST
> **Session:** Play Store signed AAB — key.properties + release signing

# Build and release

How to build and ship the CTS Flutter app (Android focus from current project notes).

**See also:** [../PROJECT_TODOS.md](../PROJECT_TODOS.md) · [TESTING.md](./TESTING.md) · [API_AND_ENV.md](./API_AND_ENV.md)

---

## Prerequisites

- Flutter SDK (project uses current stable toolchain; run `flutter doctor`)
- Android Studio / SDK for Android builds
- Xcode on macOS for iOS builds
- Copy [`.env.example`](../.env.example) → `.env` and set `API_BASE_URL` / `WEBSOCKET_URL` for your backend
- **Store builds:** the `.env` file is a Flutter **asset** packaged into the binary. Use prod **HTTPS/WSS** values for release APK/IPA — never ship lab LAN hosts (see [API_AND_ENV.md](./API_AND_ENV.md)).

---

## Platform pins (FE-7.1 / FE-7.2)

| Knob | Value | Source |
|------|-------|--------|
| Android `minSdk` | **24** (Flutter default) | `android/app/build.gradle.kts` → `flutter.minSdkVersion` |
| Android `targetSdk` | Flutter default (**36** on Flutter 3.47) | `flutter.targetSdkVersion` |
| Android `compileSdk` | **37** (pinned) | `build.gradle.kts` |
| NDK | Flutter default (`28.2.13676358` on 3.47) | `ndkVersion = flutter.ndkVersion` |
| CMake | **3.31.6** (pinned) | `externalNativeBuild.cmake` |
| Gradle wrapper | **9.1.0** | `android/gradle/wrapper/gradle-wrapper.properties` |
| iOS deployment | **13.0** | `IPHONEOS_DEPLOYMENT_TARGET` in Xcode project |
| App id (both) | `tech.abhimaarg.cts` | Android `applicationId` / iOS `PRODUCT_BUNDLE_IDENTIFIER` |
| Display name | `cts` | `android:label` / `CFBundleDisplayName` |

**Fleet fit:** India mid-tier (incl. Xiaomi lab phone) — API 24 + iOS 13 covers current ops devices. Raise only when a plugin forces it.

**Icons / splash (FE-7.3):** `flutter_launcher_icons` → `assets/brand/cts_icon_master.png`; launch theme `LaunchTheme` / `LaunchScreen.storyboard`; in-app splash uses `easy_splash_screen` + `flutter_native_splash` dep.

---

## Permissions (FE-7.4 / FE-7.5)

**Justified (ship):**
- `INTERNET` + `ACCESS_NETWORK_STATE` — REST/WS + connectivity
- `POST_NOTIFICATIONS` — splash notification prompt (FCM token path deferred)
- `CAMERA` — odometer photo + boarding QR (`image_picker` / `mobile_scanner`)
- iOS `NSCameraUsageDescription` — same camera uses
- iOS `NSAllowsLocalNetworking` — lab HTTP only; prod `.env` must be HTTPS/WSS
- Debug/profile only: `usesCleartextTraffic` — LAN Docker; **release main manifest has no cleartext**

**Removed (FIND-012):** `READ_PHONE_STATE`, `ACCESS_*_LOCATION`, iOS `NSLocationWhenInUseUsageDescription` — no Dart usage.

---

## FCM (FE-7.6) — deferred

`firebase_messaging` is in `pubspec` for a future push path. **No** `Firebase.initializeApp`, **no** token get/register hooks, and **no** `google-services.json` / `GoogleService-Info.plist` in repo. Do not treat notification permission as “FCM live.” Wire init+token under P10 when Firebase project + BE device-token API exist (FIND-018).

---

## OEM battery / live trip (FE-7.11)

Driver morning D2D and boarding QR keep a live WebSocket and (on QR panel) wakelock. **Xiaomi / Oppo / Vivo / Realme / Samsung** battery savers often kill background sockets or restrict wakelock after the screen blanks.

**Ops note for driver devices:**
1. Disable battery optimization / “auto-start” restrictions for **cts**.
2. Keep the trip screen foreground during live runs when possible.
3. If the channel shows disconnected after resume, use in-app reconnect (lifecycle already refreshes session + D2D on resume — FE-7.7).
4. Lab reference: Xiaomi `2107113SI` — see [LOCAL_DEV.md](./LOCAL_DEV.md) launcher tip.

Prove on device in **P8C** (FE-8C.2 / FE-8E.3).

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

### Play Store — signed App Bundle (.aab)

Play Console accepts an **Android App Bundle** signed with your **upload key**. Google may re-sign with the app signing key (Play App Signing).

#### 1. Create the upload keystore (once — keep forever)

From repo root (Windows PowerShell). Pick strong passwords; store them offline (password manager). Losing this key blocks updates under the same Play listing.

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cts-upload
```

Answer the prompts (CN / org / country). Prefer `tech.abhimaarg.cts` / Abhimaarg as org when asked.

#### 2. Wire `android/key.properties` (gitignored)

```powershell
Copy-Item android\key.properties.example android\key.properties
```

Edit `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=cts-upload
storeFile=../upload-keystore.jks
```

`storeFile` is resolved relative to `android/app/` (hence `../upload-keystore.jks`).

**Never commit** `key.properties`, `*.jks`, or `*.keystore` — already in `android/.gitignore`.

#### 3. Prod `.env` before packaging

`.env` is baked into the binary. For store builds use production **HTTPS** / **WSS** only — never lab LAN hosts ([API_AND_ENV.md](./API_AND_ENV.md)).

#### 4. Build the signed AAB

```bash
flutter pub get
flutter build appbundle --release
```

Output:

`build/app/outputs/bundle/release/app-release.aab`

Upload that file in Play Console → **Create app** / **Production** (or testing track) → **App bundles**.

#### 5. Verify signing (optional)

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

If `android/key.properties` is missing, release still falls back to the **debug** key (local only — **do not** upload that to Play).

---

## Android notes (from project history)

Documented fixes in PROJECT_TODOS:

- Main/release manifest: INTERNET + network state + notifications + camera (no cleartext; no phone/location). Debug/profile manifests allow HTTP for LAN Docker.
- CMake **3.31.6** pinned for NDK builds
- Kotlin incremental cache issues on Windows (C: pub cache + D: project) — Gradle flags documented in PROJECT_TODOS

Before store release:

- Replace LAN `http://…` with production **HTTPS** / **WSS** in `.env` (AppConfig does not downgrade schemes; release refuses empty/lab hosts — FIND-010)
- Configure signing (`android/key.properties` + `android/upload-keystore.jks`) — see **Play Store** section above
- Review `android/app/build.gradle.kts` min/target/compile SDK pins above
- Bump `pubspec.yaml` `version:` (`x.y.z+build`) — `build` becomes Android `versionCode`

---

## iOS checklist

- Open `ios/Runner.xcworkspace` in Xcode (Flutter 3.44+ uses Swift Package Manager; no `Podfile` required)
- Set team / signing; **store id (both platforms):** `tech.abhimaarg.cts` (from domain `abhimaarg.tech`)
- `Info.plist` must include `NSCameraUsageDescription` (odometer + boarding QR). **No** `NSLocation*` keys (FE-7.5).
- Lab HTTP: `NSAllowsLocalNetworking` is set; production `.env` should still use HTTPS/WSS
- `LSApplicationQueriesSchemes`: `tel`, `https`, `http` for `url_launcher`
- `flutter build ios` or archive via Xcode (macOS only)

---

## Environment at build time

`.env` is loaded as a Flutter asset (see `pubspec.yaml` `flutter: assets:` → `.env`). Values are **baked into the APK/IPA** — use CI secrets for production URLs, not committed `.env` with secrets. Lab LAN in a local gitignored `.env` is OK for `flutter run`; store builds must swap to HTTPS/WSS before packaging (see [API_AND_ENV.md](./API_AND_ENV.md) § Bundled `.env`).

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
| Live D2D drops on Xiaomi/Oppo/Vivo | OEM battery section above; unrestrict cts; prove in P8C |
