# Running coff locally (Windows, PowerShell)

Repo root below = `C:\Users\kattcraftt\katdev\projects\coff`. Every command is run from there unless it says `cd`.

## 0. What goes where
Unzip `coff-update.zip` over the repo root (same relative paths), then delete
`src\coff.API\SharedKernel\Infrastructure\Storage\BlobContainers.cs`. If you prefer to edit by hand:

| File | Change |
|---|---|
| `src/coff.API/appsettings.json` | `Anthropic` section: `ApiKey` (empty), **`BaseUrl`**, `Model`; `Receipts:MonthlyScanLimit` |
| `src/coff.API/appsettings.Development.json` | `BlobStorage:Containers:Receipts` (private), `Anthropic:Model`, `Receipts:MonthlyScanLimit` |
| `src/coff.API/DependencyInjection.cs` | in `AddServices`: `Configure<ReceiptOptions>`, `Configure<AnthropicOptions>`, `AddHttpClient<IReceiptExtractor, AnthropicReceiptExtractor>` (reads the URL from options); `using ...Abstractions.Receipts`, `...Infrastructure.Receipts`, `Microsoft.Extensions.Options` |
| `src/coff.API/Abstractions/Receipts/` | `IReceiptExtractor`, `ReceiptOptions` |
| `src/coff.API/SharedKernel/Domain/Receipts/` | `Receipt`, status, errors, events |
| `src/coff.API/SharedKernel/Infrastructure/Receipts/` | EF configuration, `AnthropicOptions`, `AnthropicReceiptExtractor` |
| `src/coff.API/Features/Receipts/` | scan, confirm, delete, list, get, image slices |
| `src/coff.API/Features/Analytics/` | dashboard query |
| `src/coff.API/Endpoints/Receipts/`, `Endpoints/Analytics/` | the HTTP endpoints |
| `src/coff.API/Properties/launchSettings.json` | NEW: `dotnet run` uses Development on http://localhost:5000 |
| `src/coff.API/coff.API.http` | NEW: ready-made requests for Rider |

## 0b. Upgrade the project to .NET 10 (do this before anything else)
The repo was on .NET 9. This update moves it to .NET 10 (LTS): `Directory.Build.props` (net10.0), the Dockerfile images
(`aspnet:10.0` / `sdk:10.0`), `Directory.Packages.props` (new versions), `coff.API.csproj`, and the Swagger setup code.
```powershell
dotnet --version                              # must print 10.x; otherwise install the .NET 10 SDK from dotnet.microsoft.com/download
dotnet restore
dotnet build
```
What changed and why:
* **Two package references removed** (`Microsoft.Extensions.Logging.Abstractions`, `Microsoft.Extensions.Diagnostics.HealthChecks`):
  .NET 10 already ships them in the framework and NuGet now warns "will not be pruned" (NU1510). Your build treats warnings as
  errors, so that warning broke every restore. If NU1510 names another package, delete its `<PackageReference>` from `coff.API.csproj`.
* **Swashbuckle 9 -> 10**: .NET 10's built-in OpenAPI uses Microsoft.OpenApi 2.x, and only Swashbuckle 10 matches it. The JWT
  setup in `Extensions/ServiceCollectionExtensions.cs` was rewritten for the new API (`using Microsoft.OpenApi;`,
  `AddSecurityRequirement(document => ...)`).
* **New analyzer rules**: the .NET 10 SDK adds code-analysis rules, and `AnalysisMode=All` plus warnings-as-errors turns every
  new finding into a build error. If `dotnet build` prints `CAxxxx` errors, either fix the line or silence that rule in
  `.editorconfig` with `dotnet_diagnostic.CAxxxx.severity = none`. Send me the list if it is long.
* SonarAnalyzer is intentionally left on its current version, for the same reason.

When the build is green, commit, then refresh the remaining packages in a separate step:
```powershell
dotnet tool install --global dotnet-outdated-tool
dotnet outdated --upgrade --pre-release Never --version-lock Major     # run `dotnet outdated --help` if a flag differs
dotnet build
```
`--pre-release Never` keeps you off release candidates (NuGet currently offers `11.0.0-rc` builds for Microsoft packages),
and `--version-lock Major` stops it from jumping to a new major version of a library by itself.

## 1. Start clean (database + blob storage)
The containers keep their data in `.containers\` (bind mounts), so `docker compose down -v` does NOT wipe it.
```powershell
docker compose down
Remove-Item -Recurse -Force .containers      # deletes ALL local DB and blob data
docker compose up -d coff-database coff-blob-storage coff-seq
docker compose ps                            # all three should be "running"
```
Do not start the `coff.api` container for now: it also binds port 5000, and its HTTPS redirect will
most likely break plain-HTTP calls from the phone app. Run the API with `dotnet run` instead.

## 2. Point the API at the containers (one time, stored outside the repo)
`appsettings.Development.json` uses Docker network names (`coff-database`), which do not resolve from your
machine. User secrets override them without touching the repo:
```powershell
cd src\coff.API
dotnet user-secrets set "ConnectionStrings:Database" "Host=localhost;Port=5432;Database=coff;Username=postgres;Password=postgres;Include Error Detail=true"
dotnet user-secrets set "BlobStorage:ConnectionString" "UseDevelopmentStorage=true"
dotnet user-secrets set "Serilog:WriteTo:1:Args:ServerUrl" "http://localhost:8081"
dotnet user-secrets set "Anthropic:ApiKey" "sk-ant-..."    # optional: without it scanning fails, everything else works
cd ..\..
```

## 3. Create the migration for the new receipts table
```powershell
dotnet tool update --global dotnet-ef        # installs it if missing; version must be 10.x for a .NET 10 project (dotnet ef --version)
cd src\coff.API                              # IMPORTANT: run it inside the project folder (see note)
$env:ASPNETCORE_ENVIRONMENT = "Development"  # otherwise EF runs as Production and finds no connection string
dotnet ef migrations add AddReceipts --output-dir SharedKernel/Infrastructure/Database/Migrations
cd ..\..
```
* Do NOT run it from the repo root: there `dotnet ef` finds `docker-compose.dcproj` (a Visual Studio container project, not an SDK
  project) and fails with `MSB4057 ... ResolvePackageAssets`. From the repo root the equivalent is
  `dotnet ef migrations add AddReceipts --project src/coff.API --startup-project src/coff.API --output-dir ...`.
* `--output-dir` matters: without it EF creates a new `Migrations` folder instead of using yours.
* After the move to .NET 10, open the generated file before you run the API: besides the `receipts` table it can contain other
  changes that come from the newer Identity / EF Core / Npgsql versions (for example a new Identity table for passkeys).
  That is expected; the migration has to exist, because EF refuses to start when the model differs from the last migration.
  Development applies pending migrations automatically at startup, so `dotnet ef database update` is optional.

## 4. Run and test the API
```powershell
dotnet build
dotnet test                                  # architecture tests
cd src\coff.API
dotnet run                                   # http://localhost:5000, Development, opens /swagger
```
* Swagger: http://localhost:5000/swagger (Authorize button takes the token from `users/login`)
* Rider: open `src/coff.API/coff.API.http` and run the requests top to bottom (it stores the token and ids for you)
* Seq logs: http://localhost:8081
* Reset the database again any time: stop the API, repeat section 1, start the API.

## 5. Flutter app on the Android emulator (IntelliJ IDEA + PowerShell)
Do these in order. `flutter doctor` is your checklist: you want a green tick on "Flutter" and "Android toolchain".
(Ignore "Visual Studio - develop Windows apps": it is only for Windows desktop apps, and Chrome/web is irrelevant too.)

**a) Android command-line tools (fixes "cmdline-tools component is missing")**
IntelliJ: Settings > Languages & Frameworks > Android SDK > SDK Tools tab. Tick "Android SDK Command-line Tools (latest)",
"Android Emulator" and "Android SDK Platform-Tools", then Apply. (Manual alternative: download "Command line tools only" from
developer.android.com/studio and unzip so that `<SDK>\cmdline-tools\latest\bin\sdkmanager.bat` exists: the `latest` folder
must contain `bin` and `lib` directly.)
```powershell
flutter doctor -v                         # the "Android SDK at ..." line shows which SDK folder Flutter is using
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"    # only if that is a different folder than the one you installed into
flutter doctor --android-licenses         # press y to every question
flutter doctor
```

**b) An emulator**
Install a system image once (any recent `google_apis` x86_64 image works; API 35 is fine):
```powershell
$sdkRoot    = "$env:LOCALAPPDATA\Android\Sdk"
$sdkmanager = "$sdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"
& $sdkmanager "system-images;android-35;google_apis;x86_64" "emulator" "platform-tools"
& $sdkmanager --list_installed             # the system image and "emulator" should be listed
```
`flutter emulators --create` is picky about which image types it accepts (it fails with "No suitable Android AVD system images"
for the plain `google_apis` image), so create the virtual device with Android's own tool instead:
```powershell
$avdmanager = "$sdkRoot\cmdline-tools\latest\bin\avdmanager.bat"
& $avdmanager list device -c               # pick a phone id from this list, e.g. pixel_7
"no" | & $avdmanager create avd --name coff_pixel --package "system-images;android-35;google_apis;x86_64" --device pixel_7
flutter emulators                          # coff_pixel is listed now
flutter emulators --launch coff_pixel
flutter devices                            # the emulator appears here once it has booted
```
(The "sdkmanager is deprecated, use Android CLI" and "restricted method" warnings are harmless.)
If the emulator refuses to start with a hypervisor error: turn on virtualization in the BIOS and enable the Windows feature
"Windows Hypervisor Platform". You can also create and start devices from IntelliJ's Device Manager instead of the commands.

**c) IntelliJ: fix "Dart SDK is not configured"**
Do not click "Download Dart SDK": a Flutter project uses the Dart SDK that comes inside the Flutter SDK.
Settings > Plugins > install "Flutter" (it also installs the Dart plugin) and restart. Then
Settings > Languages & Frameworks > Flutter > Flutter SDK path: the folder from `where.exe flutter` without `\bin\flutter.bat`.
IntelliJ then sets the Dart SDK itself (`<flutter>\bin\cache\dart-sdk`).

**d) Create the Flutter project files** (your folder only has lib/, assets/, test/: no pubspec.yaml or android/ yet)
Pick your own reverse-domain: it becomes the permanent Android application id.
```powershell
cd C:\Users\kattcraftt\katdev\projects\coff\src\coff.mobile
flutter create --project-name coff_mobile --org com.yourname --platforms android .
Select-String -Path lib\main.dart -Pattern "CoffApp"     # must print a match; if not, unzip coff-update.zip over the repo root again
Remove-Item test\widget_test.dart -ErrorAction SilentlyContinue
flutter pub add flutter_riverpod go_router dio flutter_secure_storage image_picker intl fl_chart "google_fonts:^8.2.1" flutter_svg font_awesome_flutter pdf share_plus cross_file file_selector
```
Edit `pubspec.yaml`, in the `flutter:` section:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```
Allow plain HTTP in DEBUG builds only: `android/app/src/debug/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:usesCleartextTraffic="true"/>
</manifest>
```
```powershell
flutter pub get
flutter test                              # the CSV import tests
```

**e) Run** (the API from section 4 must be running; 10.0.2.2 is your PC as seen from the emulator)
```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/ --dart-define=CURRENCY=PHP
```
In the terminal: `r` hot reload, `R` hot restart, `q` quit.
From IntelliJ instead: pick the emulator in the device dropdown, Run > Edit Configurations > Flutter > main.dart > "Additional run args":
`--dart-define=API_BASE_URL=http://10.0.2.2:5000/ --dart-define=CURRENCY=PHP`, then press Run.

Try it: register, sign in, Settings > add an account and a category, add a transaction by hand, look at Overview.
To test scanning/import on the emulator, drag a receipt photo or a CSV onto the emulator window (it lands in the device storage),
then "Choose from gallery" / "Choose CSV file".
