# Tailor Catalog — Flutter app

Android and iOS app for tailors: email OTP login, design uploads to Cloudinary, and a shop QR code.

## Prerequisites

- Flutter 3.47+ (Dart 3.13+)
- Android SDK (emulator or device)

## Run

1. Copy `dart_defines.json.example` to `dart_defines.json` and fill in your Supabase and Cloudinary values. Do not commit `dart_defines.json`.
2. From this directory:

```sh
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

Keys match `AGENT.md`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `CLOUDINARY_CLOUD_NAME` (public cloud name)
- `CLOUDINARY_UPLOAD_PRESET` (default `tailor-designs`)
