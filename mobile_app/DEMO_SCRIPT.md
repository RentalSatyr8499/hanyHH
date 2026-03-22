# Demo / video script (HooHacks)

Use for a **2 to 3 minute** live or recorded judge demo. Stress **iOS Simulator on macOS** (Xcode, signing, Mapbox): harder path than Android-only, and Flutter still ships to other platforms from the same codebase.

## Before you record

- Pre-fill two `lat, lng` pairs so typing is not slow.
- Run through once: Simulator open, optional Firebase emulators, `flutter run` to the same device.
- Record at 1080p or higher; quiet room for audio.

## How to run (talk track if judges ask)

1. **Flutter + Xcode** installed; `cd mobile_app`, `flutter pub get`.
2. Mapbox token in **`assets/env/default.env`**: `MAPBOX_PUBLIC_TOKEN=pk...`
3. **Simulator:** `open -a Simulator`, wait for boot.
4. **Backend (optional for demo):** from repo root, `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` then `firebase emulators:start`; copy the URL for your Python function and match it in `app.dart` `baseUrl` when wired.
5. **App:** `cd mobile_app`, `flutter run`, pick iOS Simulator.

## Timed script

| Time | Visual | Say (talking points) |
|------|--------|----------------------|
| 0:00 to 0:25 | Title / home | **AccessBilly Compass** — tagline: *community maps, smarter routes.* **HooHacks Finance.** **Three integrations:** Mapbox, Firebase Python POST, and our **layer contract** (`RouteRequest` → `RouteRepository` → `RouteModel`). |
| 0:25 to 0:55 | Map + panel | **Mapbox** map; source/destination; toggles for stairs, wheelchair, benches, indoor. Data flows through the contract we defined, not ad-hoc strings everywhere. |
| 0:55 to 1:20 | Find route | Tap **Find route**; POST JSON to backend or emulator; **`.env`** for Mapbox key. Be honest if polyline or backend is still stubbed. |
| 1:20 to 1:50 | Star FAB | Community layer: look up, rate, or add points. |
| 1:50 to 2:15 | Report FAB (optional) | Reporting flow; skip if short on time. |
| 2:15 to 2:45 | Close | **Finance:** time and money lost to bad routes. **Roadmap:** geocoding, DB, **working backend URL**, more platforms. **Challenges:** APIs, contract design, routing logic scope in a weekend. Thank judges. |

## One-line finance closer (pick one)

- When people cannot trust routes, **time is money**, and we are trying to cut that waste.
- **Inclusion is economic:** if you cannot get there safely, you cannot work, learn, or spend there reliably.

## Q&A prep

- **Layer contract:** walk `RouteRequest` → repository JSON → `RouteModel`.
- **Why iOS demo:** Xcode, Simulator, tokens, signing.
- **Secrets:** `default.env`, not committed as production secrets.
- **Firebase:** emulator URL vs deployed function; POST shape matches Flutter.

Full write-up: **[README.md](README.md)** (impact, Google Maps gaps, architecture, roadmap, challenges, assets).
