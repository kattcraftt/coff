# coff.mobile (Flutter, Android first)

## Create the project (once)
Pick your org now: it becomes the permanent Android applicationId on Play Store.

    cd src
    flutter create --project-name coff_mobile --org <your.reverse.domain> --platforms android coff.mobile
    cd coff.mobile
    flutter pub add flutter_riverpod go_router dio flutter_secure_storage image_picker intl fl_chart "google_fonts:^8.2.1" flutter_svg font_awesome_flutter pdf share_plus cross_file file_selector

Then copy this folder's `lib/` and `assets/` over the generated ones (replace main.dart), and
register the assets in `pubspec.yaml`:

    flutter:
      uses-material-design: true
      assets:
        - assets/images/

Logo: replace `assets/images/coff-logo.svg` (a placeholder) with
`src/coff.client/public/coff-logo.svg`. If your SVG already includes the "coff" text,
use `CoffLogo(showWordmark: false)`.

Fonts: google_fonts downloads Inter/JetBrains Mono on first run and caches them. Before
release, bundle the font files as assets so the first launch works offline.

## Android setup
- `android/app/build.gradle(.kts)`: make sure minSdk is at least 23 (flutter_secure_storage).
- Local HTTP backend in debug only: in `android/app/src/debug/AndroidManifest.xml`
  add `android:usesCleartextTraffic="true"` to the `<application>` tag.

## Run against your local API
Emulator (10.0.2.2 = your laptop):

    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:<api-port>/

Physical phone on the same Wi-Fi: use your laptop's LAN IP instead.

## Structure
    lib/
      app/        router (go_router + auth redirect), theme
      core/       dio client, session/token, errors, formatters
      features/   auth/, receipts/{scan_receipt,review_receipt,receipt_list}
Features never import each other; shared code goes in core/.

## Design
Light theme only, colors in `core/theme/app_colors.dart` (sampled from the web design).
Social sign-in buttons are visible but not wired: `core/config/features.dart`.
Currency: `--dart-define=CURRENCY=PHP` (transactions have no currency yet).

## Screens
Overview (dashboard) / Transactions (search, filters, add, edit, delete) / Receipts (AI scan queue) /
Reports (CSV or PDF export, shared through the system share sheet) / Settings (accounts, categories).
The "Add" button offers scan or manual entry.

Shared server data (accounts, categories, transactions) lives in `core/data`. After any write,
call `ref.read(dataRevisionProvider.notifier).bump()` and every screen refreshes itself.
Note: PDFs use the currency code ("PHP 1,250.00"), not the peso sign, because the default PDF
font has no such glyph; payees in non-Latin scripts need an embedded font to render.

## Receipt photos
The review screen shows the stored photo (tap to zoom) and can discard a scan. Confirmed receipts
open their photo from the Receipts tab. Photos come from `GET receipts/{id}/image` (needs the token,
so they are fetched through dio rather than Image.network).

## Statement import (CSV)
Add button -> "Import a statement" (or the upload icon in Transactions). The CSV is parsed on the
phone: columns are detected from the header names, or from the cell contents when there is no
header. Choose the account and a category, check the preview, import. The server skips rows that
already exist, so importing the same statement twice is safe.
Run the parsing tests with `flutter test` (test/csv_import_test.dart).

## google_fonts is pinned to ^8.2.1
Version 9 uses the new `material_ui` package, which has its own `TextTheme` type and does not mix with `package:flutter/material.dart`.
Move to google_fonts 9 only together with migrating the app's imports to `material_ui`.

## Profile, charts and selection (new)
Avatar menu -> Manage account (`/account`). Chart styles live in `features/overview/widgets`.
Transactions: long-press a row to select; Create-new entries in pickers use `core/widgets/lookup_dropdown.dart`.
The radar chart uses fl_chart's RadarChart: if a future fl_chart release renames its title callback, fix it in `categories_card.dart`.
