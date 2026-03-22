# Accessible Routing (HooHacks)

> Community-centered navigation: routes and places shaped by people who actually move through the world, not only what the default map shows.

We built a Flutter app for **HooHacks (Finance track)** around **accessibility-aware routing** and **crowdsourced points** (ratings, lookups, adds). Tagline in one line: **community-based navigation** (people on the ground, not only the default map). You ask for routes that fit real constraints, not just the shortest line. How you move changes day to day (energy, pain, gear), so you set **per-trip** preferences (stairs, wheelchair-only, benches, indoor, etc.) and send that with the route request. The community side fills in what big maps skip: what’s actually true on the ground.

## Why this matters

A lot of us never think about whether “fastest” is even doable. Stairs, curb cuts, benches, and indoor shortcuts stay invisible until they aren’t. If the world wasn’t built with you in mind, **a line on a screen can still be a bad route**: dead end, fall, or a trip you abandon. Missed class, missed work, missed care. It stings extra when the app that’s supposed to help obviously doesn’t.

Google Maps and similar tools are strong on generic driving, walking, and transit. They’re thinner when you need **your** mobility needs inside the route: one “default” path can still throw stairs, steep hills, or long stretches with nowhere to sit. Detail is patchy. What’s on the map is often official or sparse, not what people actually use day to day.

**Good routes aren’t only geometry.** They need stairs, ramps, cut-throughs, benches, and the obstacles that matter to *you*. Local knowledge fills gaps. Needs shift, so navigation should meet you where you are when you open the app.

## What we’re building

Preference-aware routing plus a community layer: look up, rate, or add accessibility-related points so the app matches how people experience campus and the city. Each trip, you flip the options that match how you feel and what you need right then. Under the hood we kept things modular (Dart layers, clear JSON between app and backend, Mapbox on the map) so we can extend it as we get more real-world data.

## Architecture

We split **data**, **domain**, and **UI** so we’re not tangling map code with HTTP and JSON. That made the hackathon codebase easier to reason about and test.

### Layout under `mobile_app/lib`

Peek at the tree:

```bash
cd mobile_app/lib
# macOS / Linux (brew install tree if needed)
tree -L 3

# Windows
tree /F
```

Rough breakdown:

- `domain/` entities like [`route_request.dart`](lib/domain/entities/route_request.dart) (source/destination and flags, no UI).
- `data/` repositories, [`RouteModel`](lib/data/models/route.dart), services (catalog, location).
- `presentation/` screens and widgets (map, navigation pieces).
- `screens/` feature flows (wild-west route panel, add/rate).
- `theme/` shared styling and assets.

### Layer contract

1. `RouteRequest` holds what the user typed and which toggles are on.
2. `RouteRepository` turns that into coordinates plus JSON (`source`, `destination`, `preferences`) for a POST to your backend (same shape the Python function expects).
3. `RouteModel` parses a successful route response (distance, duration, geometry) from JSON.

Swap the map, swap the base URL, or change geocoding without rewriting the whole UI.

### Three external “API” surfaces (plus our own contract)

There are **three big integration points** everyone on the team had to line up:

1. **Mapbox:** map display, style, markers; token at startup; room for Geocoding later.
2. **Firebase (Python):** [`functions/`](../functions) exposes an **HTTP URL** that accepts **POST** bodies (routing / accessibility payloads). Run locally with **Firebase emulators** or deploy and use the live URL.
3. **Flutter to your backend:** `RouteRepository` builds JSON and POSTs it; same JSON shape the Python handler expects.

**The part we’re proudest of** is the **internal layer contract** (not a third-party API, but it behaved like one): **`RouteRequest`** (what the user chose) → **`RouteRepository`** (coordinates + `preferences` JSON) → **`RouteModel`** (parsed route response). That let UI, networking, and future routing logic stay separate. Swap geocoding, swap base URL, or extend preferences without rewriting screens.

| Piece | What it does |
|--------|----------------|
| Mapbox | Map via `mapbox_maps_flutter`, token at startup, geocoding where wired in repos. |
| Firebase (Python) | [`functions/`](../functions): Cloud Functions, Python 3.13 per [`firebase.json`](../firebase.json). HTTP endpoint for POST bodies. Emulator or deploy; paste URL into app `baseUrl`. |
| App to backend | `RouteRepository` sends JSON over HTTP; backend can push into Firestore or whatever you add. |

**Stack in short:** Mapbox for the map, Firebase for the Python function, and a **small JSON contract** between Flutter and your server.

### Backend (Python)

Code lives in [`functions/`](../functions) (`main.py`). After deploy you get a URL; the Flutter app POSTs there. Flesh out `main.py` to validate input, call routing or DB, return JSON that `RouteModel` can parse.

### Data layer

Repositories (see [`route_repository.dart`](lib/data/repositories/route_repository.dart)), models, and services like [`accessibility_points_catalog.dart`](lib/data/services/accessibility_points_catalog.dart) and [`location_service.dart`](lib/data/services/location_service.dart).

### UI

Screens and widgets split by feature. The app POSTs structured requests; Mapbox renders the map. Flutter targets iOS, Android, and more from one codebase; our demo was iOS-heavy.

### API keys

Mapbox public token lives in [`assets/env/default.env`](assets/env/default.env) via `flutter_dotenv`, not hard-coded in Dart. Don’t commit secrets you care about; rotate if something leaks.

### Why this layout helps

New preferences or API fields mostly flow **entity → repository → backend**. Same Dart UI can ship to more platforms with mostly config and QA.

## What it does

- Map (Mapbox) with source/destination for routing.
- Find route panel: enter `lat, lng` for now (address search is on the roadmap), set options, POST via the repository. Wild-west themed UI (wood textures + fonts).
- Star FAB: add or rate accessibility points (catalog + in-memory ratings until a real API/DB).
- Extended FAB: report a point (location where relevant).

**Where we’re at:** drawing the route polyline on the map is still TODO. The repository already builds the JSON you’d POST; wire [`functions/main.py`](../functions/main.py) and deploy so the loop is live. See Roadmap.

## HooHacks, Finance track

We pitched it under **Finance** because bad navigation has real cost: **missed work, extra rides, wasted time**. Reliable routes and place info are part of **economic inclusion** (jobs, school, services) without burning time and money on trips that don’t work.

## Tech stack

| Layer | Choice |
|--------|--------|
| Mobile | Flutter / Dart (SDK ^3.9) |
| Map | Mapbox (`mapbox_maps_flutter`) |
| HTTP | `dio`, `http` |
| Config | `flutter_dotenv`, token in `assets/env/default.env` |
| Location | `geolocator` |
| Models | Dart + JSON (`json_serializable` / `freezed_annotation` available) |
| State | StatefulWidget + injected repository; `flutter_riverpod` in pubspec for later |
| Backend | Python on Firebase Cloud Functions ([`functions/`](../functions)), POST API |
| Assets | Accessibility JSON, marker, wild-west images/fonts. Credits: [below](#assets--attributions) and [`ATTRIBUTIONS.md`](ATTRIBUTIONS.md) |

## Roadmap (what we’d add next)

- **Addresses, not only coordinates:** Mapbox Geocoding (or similar) so users type a street string instead of raw `lat, lng`.
- **Backend URL wired end-to-end:** finish [`functions/main.py`](../functions/main.py), deploy or use emulator URL, point `RouteRepository` `baseUrl` in [`app.dart`](lib/app.dart) so POSTs return real geometry for the map.
- **Draw the route on the map:** polyline from API response (today the contract is there; rendering is still TODO).
- **More data in the DB:** Firestore (or your store) for accessibility points and ratings instead of only local JSON / memory.
- **More platforms:** Flutter is **cross-platform**; we focused the demo on **iOS** (harder path: Xcode, signing, Simulator). Shipping Android (and others) is mostly QA and store setup, not a rewrite.

## Challenges we ran into

- **APIs and keys:** Mapbox token handling, `flutter_dotenv`, and iOS/Android config so the map actually boots without leaking secrets into source.
- **End-to-end routing:** agreeing on a **JSON contract** between Flutter and Python early; debugging POSTs to the emulator or deployed function; CORS or networking gotchas depending on how you call the backend.
- **“Routing algorithm”:** in a short hack, the hard part is **encoding preferences** (stairs, wheelchair, benches, indoor) and passing them cleanly; a full graph search over custom accessibility edges is future work. The repo is structured so that logic can move server-side without breaking the app.
- **Time:** themed UI, map, and community flows competed with wiring the full backend loop and drawing routes on the map.

## Setup (iOS Simulator on macOS + optional Firebase emulator)

Requirements: **Flutter**, **Xcode**, **Firebase CLI** (if you run the Python backend locally). The app is **not fully deployed** in the hackathon snapshot; we **simulate on the iOS Simulator**.

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and [Xcode](https://developer.apple.com/xcode/).
2. `cd mobile_app` and `flutter pub get`.
3. Add your Mapbox public token. Copy [`assets/env/default.env.example`](assets/env/default.env.example) to **`assets/env/default.env`** (that file is gitignored so keys are not committed):

   ```env
   MAPBOX_PUBLIC_TOKEN=pk.your_public_token_here
   ```

4. **Terminal A (Simulator):**

   ```bash
   open -a Simulator
   ```

   Wait until an iOS device boots.

5. **Terminal B (Firebase emulators, backend):** from the **repo root** (where `firebase.json` lives), not only `mobile_app`:

   ```bash
   export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
   firebase emulators:start
   ```

   Copy the **Functions** or **host** URL the CLI prints; put that base URL into [`lib/app.dart`](lib/app.dart) as `baseUrl` when your Flutter app should talk to the emulator (exact host/port depends on your Firebase version; use what the terminal shows).

6. **Terminal C (Flutter):**

   ```bash
   cd mobile_app
   flutter run
   ```

   Select the **iOS Simulator** device if prompted.

7. Finish implementing [`functions/main.py`](../functions/main.py) so POSTs return data your [`RouteModel`](lib/data/models/route.dart) can parse.

8. Optional: `flutter analyze` and `flutter test`.

**Windows:** use `tree /F` instead of `tree -L 3` under `mobile_app/lib`; Firebase emulator env var above is macOS-oriented for fork safety; adjust per Firebase docs on your OS.

## Demo / video script

Timed outline and Q&A beats are in [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) so this file doesn’t turn into a novel.

## Team

- Event: HooHacks  
- Track: Finance  
- Team: *(names)*  

## Assets and attributions

Wood textures, fonts, map pin, hooves SFX, and optional **Noiz AI** voice need proper credits for class or judging. Short list (details in [`ATTRIBUTIONS.md`](ATTRIBUTIONS.md)):

| Asset | Role in app | Source |
|------|-------------|--------|
| **Wood background** | Full-width panel / screen backdrop | [Unsplash wood grain](https://unsplash.com/photos/close-up-of-dark-wood-grain-texture-KKKHaEA4coc) (The Cleveland Museum of Art); may share source with plank depending on export |
| **Wood plank** | Button / plank styling | [Freepik three kinds wood](https://www.freepik.com/free-photo/three-kinds-wood_19138518.htm) (see Freepik attribution rules) |
| **Font 1 (headings / labels)** | Confetti Western | [DaFont](https://www.dafont.com/confetti-western.font) → `Confetti_Western.otf` |
| **Font 2 (buttons / display)** | Carnevalee Freakshow | [DaFont](https://www.dafont.com/carnivalee-freakshow.font) → `Carnevalee_Freakshow.ttf` |
| **Map pin** | Map markers | [Flaticon](https://www.flaticon.com/free-icon/maps-and-flags_447031) → `assets/marker.png` |
| **Horse hooves / gallop** | Optional SFX | [Freesound Horse Galloping.wav](https://freesound.org/people/Jordishaw/sounds/490751/) by Jordishaw ([CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) |
| **Generated voice / audio** | Optional voiceover or UI audio | **[Noiz AI](https://noiz.ai/)** (see terms); list filenames in `ATTRIBUTIONS.md` when finalized |

Full detail and license notes: [`ATTRIBUTIONS.md`](ATTRIBUTIONS.md). DaFont fonts are often personal or non-commercial only; check before a paid app release.

## License

Your choice for the code you wrote (MIT, Apache-2.0, etc.). Third-party assets stay under their own licenses (see `ATTRIBUTIONS.md`).
