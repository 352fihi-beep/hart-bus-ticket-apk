# HART Bus Ticket - Flutter APK

Exact visual + behavioral replica of the HART (Hillsborough Area Regional Transit) digital bus ticket.

## Features
- **Expand / Contract ring animation** matching the original recording
- Live sequential ticking clock (`h:mm:ss AM/PM`)
- Gear icon → set custom hour / minute / second (clock continues from new time)
- Single screen, pure Flutter, no external packages

## Build APK via GitHub Actions

1. Go to the **Actions** tab of this repository
2. Select **Build HART Ticket APK**
3. Click **Run workflow** → **Run workflow**
4. Wait ~3-5 minutes
5. Download the `hart-ticket-apk` artifact (contains `app-release.apk`)

You can also trigger a build automatically on every push to `main`.

## Local Build

```bash
flutter pub get
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
