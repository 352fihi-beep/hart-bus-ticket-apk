# HART Bus Ticket APK

Flutter replica of the HART (Hillsborough Area Regional Transit) Adult Local 1-Day digital ticket UI.

## Features
- Full-screen immersive mode (status + nav bars hidden) for clean operator presentation
- Expand/contract blue donut ring animation matching original capture
- Live sequential clock starting at 9:37:59 AM
- Gear icon → "Set Ticket Clock" dialog (HH:MM:SS + AM/PM)
- Pure black background + refined card spacing / radii for visual parity with recordings

## Build
Push to `main` or run the **Build HART Ticket APK** workflow manually.
APK artifact appears under Actions → latest run → `hart-ticket-apk`.

```bash
flutter build apk --release
```

## Notes
- Immersive sticky mode keeps the ticket edge-to-edge when shown to the operator.
- Tap the gear to adjust the displayed time without affecting the device clock.
