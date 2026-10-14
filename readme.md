# Al-Mu’jam al-Kafi: Arabi–Myanmarī dictionary

An offline-first Flutter dictionary built from the vocalized JSON files in this
directory. It searches both Arabic and Myanmar, displays Arabic headwords with
their vowel marks, supports alphabet browsing, and includes dedicated book and
developer pages. 

## The json files that contains the vocabs are concealed from the public.

## What is included

- 17,020 entries across all 28 Arabic letter sections

- Arabic search with or without harakat (vowel marks)

- Myanmar full-text search

- Exact, prefix, word-prefix, and contained-match ranking

- Source page and extraction-review information on each entry

- Fully local data with no account, network request, analytics, or external package

- Material 3 UI based on the supplied navy, royal blue, sky blue, ivory, and gold references


The duplicate `AMDText_Dal_Arabic_Myanmar_with_Harakat(1).json` and the older
unvocalized Alif file are intentionally not bundled.

## Architecture, logos, and data quality

- [Comprehensive architecture and maintenance guide](docs/ARCHITECTURE.md), with

  system, component, navigation, data-model, search-sequence and repair diagrams.
- [Character audit and remaining source-review work](docs/DATA_QUALITY.md).

- [Logo design](assets/logo_options/README.md).


The Arabic encoding repair corrects 412 entries (824 fields). Both Arabic fields
are now free of Latin fallback characters and unresolved glyph-code placeholders.
The audit retains 1,573 records for other source/language review; this is not a
claim that every translation or vowel mark has been proofread.

```sh
python3 tool/audit_dictionary.py
flutter test
flutter analyze
```

Use `python3 tool/audit_dictionary.py --strict` to require an empty editorial
review queue as well. That stricter gate currently fails on documented issues.



## Run the app

Android, iOS, and Linux runner projects are included. With Flutter on your PATH,
run:

```sh
flutter pub get
flutter test
flutter run
```

## Install the Android build

Version **1.0.1+2** includes the character repair and selected Language Bridge
logo. The older v1.0.0 binaries are retained; they predate these changes.

The release-signed universal Android APK is
`Nur-Arabic-Myanmar-Dictionary-v1.0.1.apk`. Copy it to an Android 7.0 or newer
device and open it to install. The Play-ready App Bundle is the adjacent `.aab`
file. Use the `.sha256` file to verify either artifact after transfer.
See [release verification](docs/RELEASE_1.0.1.md) for checks and remaining limits.

The permanent application identifier is `com.nur.arabicmyanmardictionary`.
Release builds use the private key under `.signing/`; back up that ignored folder
securely because every future update must use the same signing identity.

## Project map

```text
lib/
  main.dart                         App entry point
  src/app.dart                      Theme, loading, and startup states
  src/config/app_content.dart       Editable book/developer content
  src/models/dictionary_entry.dart  Dictionary model
  src/services/dictionary_repository.dart
                                    Asset loading and bilingual search
  src/screens/                      Search, details, and about pages
  src/widgets/                      Reusable cards and geometric styling
test/
  dictionary_repository_test.dart  Search-normalization tests
assets/
  branding/                        App logo
  logo_options/                    Logo concepts
  profile/                         Developer portrait
  source_pages/                    Reference page images
```

## Data format

Every bundled section is loaded from the existing JSON and expects an `entries`
array containing `arabic`, `arabic_vocalized`, `myanmar`, and optional source and
review fields. Add a future section file to both `pubspec.yaml` and
`DictionaryRepository.sectionFiles`.
