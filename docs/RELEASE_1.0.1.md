# Nur Dictionary 1.0.1 release verification

Prepared locally on 10 September 2026. Version: **1.0.1+2**.

This build includes the 412-entry Arabic encoding repair and the user's selected
**Language Bridge** logo in the Flutter splash, search header and launcher icons.
Original source text, Myanmar definitions, record IDs and review flags are
preserved. The older v1.0.0 binaries remain available separately.

## Android artifacts

- `Nur-Arabic-Myanmar-Dictionary-v1.0.1.apk` — 49,542,717 bytes; installable universal APK.
- `Nur-Arabic-Myanmar-Dictionary-v1.0.1.aab` — 42,503,601 bytes; signed app bundle.
- `Nur-Arabic-Myanmar-Dictionary-v1.0.1.sha256` — transfer checksums for both files.
- [Machine-readable artifact sizes and hashes](data/release-1.0.1-artifacts.json).

Application ID: `com.nur.arabicmyanmardictionary`. Manifest version code: `2`;
version name: `1.0.1`. Minimum Android SDK: `24` (Android 7.0); target SDK: `36`.
The APK includes `armeabi-v7a`, `arm64-v8a` and `x86_64` native libraries.

## Completed checks

- `python3 tool/audit_dictionary.py`: 28 sections, 17,020 records, zero integrity
  errors and zero Latin characters or unresolved glyph codes in either Arabic field.
- `flutter test --no-pub`: all 11 tests passed, including the repaired spelling in
  search results and word details. The details test checks the route and displayed
  spelling without assuming a large app-bar title has only one internal widget.
- `flutter analyze --no-pub`: no issues found.
- `git diff --check`: passed.
- Release APK and app bundle built successfully with Flutter's installed SDK and
  `ANDROID_HOME=/tmp/android-sdk-build`.
- All 28 packaged dictionary JSON files and the selected logo match the working
  source byte for byte in both the APK and AAB. All five launcher images in the
  APK match the corresponding generated source icons pixel for pixel.
- `apksigner verify --verbose --print-certs`: APK signature valid (v2 scheme).
  Its certificate matches the previous Nur v1.0.0 APK.
- `jarsigner -verify`: app bundle verified. `keytool -printcert -jarfile` confirms
  the same release certificate. Jarsigner reports the expected self-signed Android
  certificate and lack of a timestamp; these are not a failed signature check.
- Five Android launcher densities and all 15 unique iOS icon files were generated
  from the selected opaque master. iOS dimensions follow the AppIcon catalog and
  all iOS PNGs are RGB, with no alpha channel.

Release certificate SHA-256:

```text
9b7b97a514fe0de666bfc2152a4ce985afebf9816d3ae6da000e40e0db747ae0
```

Check the artifacts after copying:

```sh
sha256sum -c Nur-Arabic-Myanmar-Dictionary-v1.0.1.sha256
```

## Verification limits

The 1,573-entry editorial review queue remains; ordinary integrity tests do not
certify translations, all vowel marks, legacy Myanmar encoding, or incomplete
source rows. See [DATA_QUALITY.md](DATA_QUALITY.md). The strict editorial gate
remains unmet.

Screen previews in the visual review are renders of the actual Flutter widgets
at 390 × 844 logical pixels. The headless renderer is supplied with locally
installed Roboto and Noto Arabic/Myanmar fonts because it has no device font
fallback. These fonts are capture-only; they are not added to the app bundle.
The screenshots are not physical-device screenshots or a substitute for testing
the installed APK. No physical-device installation, launcher-mask test, iOS build
or app-store publication was performed in this continuation.

Gradle emitted an SDK XML version compatibility warning; both release builds
completed successfully.
