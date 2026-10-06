<p align="center">
  <img src="../brand/logo/lifecome-live-logo.svg" alt="LifeCome Live" width="360" />
</p>

# LifeCome Live — Mobile App (Flutter)

**Status: scaffold only.** This folder is a file-and-folder map for the patient app, not a runnable
Flutter project yet. Every `.dart` file listed below is empty — a marker for where each piece of
code will go — and no `flutter create` has been run, so there is no `android/`, `ios/`, `pubspec.lock`
or generated platform code here. See [Turning this into a real project](#turning-this-into-a-real-project)
for the exact commands to make it one.

This README is the plan: every screen mapped to the [blueprint](../docs/prd/lifecome-live-blueprint.md)'s
22 views, every shared widget, the animation approach, the Manrope font setup, and the full dependency
list — described here rather than written into `pubspec.yaml`, since no code was written this pass.

---

## Contents

- [Architecture](#architecture)
- [Screens, mapped to the blueprint's 22 views](#screens-mapped-to-the-blueprints-22-views)
- [Screens beyond the 22 — and why they're here](#screens-beyond-the-22--and-why-theyre-here)
- [Shared widgets (`core/widgets`)](#shared-widgets-corewidgets)
- [Animation](#animation)
- [Font: Manrope](#font-manrope)
- [State management, navigation, networking](#state-management-navigation-networking)
- [Folder-by-folder reference](#folder-by-folder-reference)
- [Recommended `pubspec.yaml` dependencies](#recommended-pubspecyaml-dependencies)
- [Turning this into a real project](#turning-this-into-a-real-project)
- [Before you write the first real screen](#before-you-write-the-first-real-screen)

---

## Architecture

**Feature-first**, matching the backend's module boundaries so a screen's data needs map cleanly onto
one backend module (`features/booking` talks mostly to the backend's `BookingModule` and
`SchedulingModule`, `features/payer` to `PayerModule` and `EligibilityModule`, and so on).

Every feature folder follows the same four-layer shape, borrowed from the backend's own module
pattern so the two codebases read the same way:

```
features/<name>/
  domain/models/      Plain data classes (will be `freezed` unions once code is written)
  application/         Riverpod controllers — one per screen or flow, hold UI state and call data/
  data/                 Repository: talks to core/network's API client, returns domain models
  presentation/         Screens (one file per screen) and presentation/widgets/ (feature-only widgets)
```

Anything used by **more than one** feature lives in `core/widgets/` instead of a feature's own
`presentation/widgets/`. That's the one placement rule worth keeping as the app grows.

## Screens, mapped to the blueprint's 22 views

| # | Blueprint view | File(s) |
|---|---|---|
| 01 | Sign In / Create Account | `features/auth/presentation/sign_in_screen.dart`, `create_account_screen.dart` |
| 02 | Verify Mobile Number | `features/auth/presentation/verify_otp_screen.dart` |
| 03 | Patient Profile | `features/profile/presentation/patient_profile_screen.dart`, `edit_profile_screen.dart` |
| 04 | LifeCome Live Dashboard | `features/dashboard/presentation/dashboard_screen.dart` |
| 05 | Choose How to Pay | `features/payer/presentation/choose_payment_method_screen.dart` |
| 06 | Select Your HMO | `features/payer/presentation/select_hmo_screen.dart` |
| 07 | Verify HMO Membership | `features/payer/presentation/verify_hmo_membership_screen.dart` |
| 08 | HMO Coverage & Benefits | `features/payer/presentation/hmo_coverage_screen.dart` |
| 09 | Check Service Eligibility | `features/payer/presentation/check_eligibility_screen.dart` |
| 10 | Choose a Service | `features/booking/presentation/choose_service_screen.dart` |
| 11 | Find a Doctor | `features/doctors/presentation/find_a_doctor_screen.dart` |
| 12 | Doctor Profile | `features/doctors/presentation/doctor_profile_screen.dart` |
| 13 | Choose Appointment Time | `features/booking/presentation/choose_appointment_time_screen.dart` |
| 14 | Before Your Visit | `features/booking/presentation/before_your_visit_screen.dart` |
| 15 | Review Booking & Payment | `features/booking/presentation/review_booking_screen.dart` |
| 16 | Payment / HMO Authorisation | `features/booking/presentation/payment_authorisation_screen.dart` |
| 17 | Booking Confirmation | `features/booking/presentation/booking_confirmation_screen.dart` |
| 18 | Consultation Waiting Room | `features/consultation/presentation/waiting_room_screen.dart`, `device_check_screen.dart` |
| 19 | Video / Audio Consultation | `features/consultation/presentation/consultation_call_screen.dart` |
| 20 | Care Plan & Visit Summary | `features/care_plan/presentation/care_plan_screen.dart`, `visit_summary_screen.dart` |
| 21 | Health Records | `features/health_records/presentation/health_records_screen.dart` (+ detail screens) |
| 22 | Care Team Messages | `features/messaging/presentation/message_threads_screen.dart`, `thread_detail_screen.dart` |

Every required *state* from blueprint §4.1 (HMO verification, eligibility, authorisation, payment,
booking, consultation, records — loading / not-found / expired / declined / etc.) is a case the
matching screen renders from its controller's state, not a separate screen. `core/widgets/feedback/`
holds the pieces every one of those states is built from (`empty_state.dart`, `error_state.dart`,
`status_chip.dart`, `skeleton_loader.dart`).

## Screens beyond the 22 — and why they're here

The blueprint's 22 views are the core patient journey; a real app also needs the screens around it.
None of these are optional extras — each is load-bearing for a real release:

| Screen(s) | Why it has to exist |
|---|---|
| `splash_screen.dart` | Every app needs one while auth state resolves |
| `onboarding_screen.dart` | First-run explanation before Sign In (skippable, shown once) |
| `dependant_list_screen.dart`, `add_dependant_screen.dart` | The blueprint's data model is "dependant-ready" (§2.3, §8) — the UI to add one has to live somewhere |
| `settings_screen.dart`, `consent_settings_screen.dart` | Account settings and the consent record blueprint §12.1 requires patients to see and control |
| `notifications_screen.dart` | A tappable inbox for the pushes blueprint §15 defines — pushes need somewhere to land |
| `help_centre_screen.dart`, `faq_screen.dart`, `support_contact_screen.dart` | Mirrors the website's Help Centre and Support pages (blueprint §5, pages 33–34) |
| `emergency_guidance_screen.dart` + `emergency_banner.dart` | Blueprint §2.2 and §35: the emergency boundary must be reachable from the app, not just the website |
| `terms_screen.dart`, `privacy_screen.dart` | Can't gate sign-up consent on a document the app can't show |
| `receipt_screen.dart`, `transaction_history_screen.dart` | Blueprint §13 requires a receipt for every payment — it needs a screen to view |
| `no_connection_screen.dart`, `maintenance_screen.dart`, `not_found_screen.dart`, `force_update_screen.dart` | The "operationally observable" principle (blueprint §23) extends to the client: users need to see the actual state of a slow API, not a spinner forever |

## Shared widgets (`core/widgets`)

| Folder | Widgets | Used for |
|---|---|---|
| `buttons/` | `primary_button`, `secondary_button`, `ghost_button`, `icon_action_button` | Every call-to-action in the app, one visual language |
| `inputs/` | `app_text_field`, `otp_input`, `phone_number_field`, `search_field`, `date_field` | Sign-up, OTP entry, doctor search, date-of-birth, intake forms |
| `feedback/` | `status_chip`, `empty_state`, `error_state`, `loading_indicator`, `skeleton_loader`, `app_toast`, `confirmation_dialog`, `permission_denied_state` | Every one of blueprint §4.1's workflow states, rendered consistently |
| `layout/` | `app_scaffold`, `section_header`, `bottom_nav_bar`, `app_bar_back`, `card_container`, `bottom_sheet_wrapper` | Page structure, so screens don't each reinvent spacing and app bars |
| `media/` | `avatar`, `network_image_placeholder` | Doctor photos, profile pictures — always with a graceful loading/failure state |
| `lists/` | `list_tile_card`, `timeline_item` | Doctor lists, HMO lists, message threads, care-plan timelines |

`status_chip.dart` is the mobile equivalent of the website's status chips (blueprint §19): "Covered",
"Requires Authorisation", "Pending", "Approved" etc. always render as a labelled chip, never colour
alone — same rule, same component, different platform.

## Animation

Mirrors the motion the website already has (smooth scroll, card lift, scroll-reveal, animated
buttons) in ways that make sense as native app motion rather than web scroll effects:

| File | What it's for |
|---|---|
| `motion_tokens.dart` | Shared durations and curves (the Flutter equivalent of the website's `--ease-smooth` and animation timings) — every other animation file uses these, so motion feels consistent app-wide |
| `page_transitions.dart` | Custom `PageRouteBuilder` transitions wired into `go_router` — slide/fade between screens instead of the platform default |
| `fade_in.dart` | Fade-and-rise on entry, the mobile equivalent of the website's scroll-reveal |
| `staggered_list_animation.dart` | Staggers list items in on load (doctor search results, health records list) — same idea as the website's staggered card reveal |
| `shimmer_loading.dart` | Skeleton/shimmer placeholders while data loads, instead of a bare spinner |
| `animated_status_chip.dart` | A status chip that animates when its value changes (e.g. "Pending" → "Approved" mid-session) |
| `pulse_loading_dot.dart` | The waiting-room "connecting…" indicator (blueprint §10.1's waiting states) |

## Font: Manrope

Bundled locally rather than fetched from Google Fonts at runtime — a clinic-facing app shouldn't
depend on a font CDN being reachable, and it avoids a visible font swap after first paint.

**What's here:** `assets/fonts/Manrope/` is an empty folder waiting for the actual font files (a
`.gitkeep` placeholder is the only thing in it — font files are binary and weren't generated).

**To add it:**
1. Download the family from [Google Fonts](https://fonts.google.com/specimen/Manrope) or the
   [Manrope GitHub repo](https://github.com/sharanda/manrope) — get the variable font or the static
   weights (400, 500, 600, 700, 800 cover everything the website uses).
2. Place the `.ttf` files in `assets/fonts/Manrope/`.
3. Declare them in `pubspec.yaml` under `flutter: fonts:` (see below) and set Manrope as the
   default in `core/theme/app_typography.dart`'s `TextTheme`.

## State management, navigation, networking

Chosen for consistency with the [tech stack recommendation](../docs/architecture/tech-stack-recommendation.md#3-mobile-flutter--patient-app),
which this scaffold follows exactly:

- **State:** Riverpod. Every `application/*_controller.dart` is a Riverpod `Notifier`/`AsyncNotifier` —
  UI reads state, never talks to a repository directly.
- **Navigation:** `go_router`, configured in `core/router/app_router.dart` with routes named in
  `route_paths.dart` and auth/consent gating in `route_guards.dart`.
- **Networking:** `dio`, wrapped in `core/network/api_client.dart`, with interceptors
  (`dio_interceptors.dart`) for the auth token, the correlation id, and retry — mirroring the
  backend's own correlation-id and idempotency-key conventions. `idempotency_key_generator.dart`
  produces the `Idempotency-Key` header the backend's payment/booking/authorisation endpoints
  require (see [`Lifecome-backend`](../Lifecome-backend/README.md#conventions)).
- **Models:** plain classes for now; once code is written, `freezed` + `json_serializable` are the
  intended pair for immutable models and JSON (de)serialisation matching the backend's DTOs.
- **API contract:** generated from the backend's OpenAPI spec (`http://localhost:3001/api/docs-json`
  once the backend is running) rather than hand-typed, so the two never drift silently. See
  `core/network/api_client.dart`'s intended role once that generation step exists.

## Folder-by-folder reference

```
lib/
  main.dart              Entry point
  app.dart                MaterialApp.router — theme, routing, localisation wiring
  bootstrap.dart           Runs before app.dart: env loading, error zone, crash reporting init

  core/
    theme/                 Colours, type scale (Manrope), spacing, radius, icons, status-chip styles
    router/                go_router setup, route names, auth/consent guards
    network/                API client, interceptors, typed exceptions, idempotency keys
    storage/                Secure token storage, lightweight local cache
    config/                 Environment (dev/staging/prod) and build-time config
    providers/              App-wide Riverpod providers (the client, storage, config — wired together)
    animation/               Shared motion — see Animation above
    utils/                   Formatters (currency, dates), validators, extensions, logging
    error/                   Maps backend error codes (blueprint §7.1) to patient-safe messages
    widgets/                 Shared, cross-feature UI — see Shared widgets above

  features/
    splash/                 Launch screen
    onboarding/              First-run intro
    auth/                    Views 01–02
    profile/                 View 03 + settings, dependants, consent
    dashboard/               View 04
    payer/                   Views 05–09
    booking/                 Views 10, 13–17
    doctors/                 Views 11–12
    payment/                 Receipts and transaction history (supports view 16)
    consultation/            Views 18–19
    care_plan/               View 20
    health_records/          View 21
    messaging/               View 22
    notifications/           Notification inbox
    support/                 Help centre, FAQ, contact support
    emergency/               Emergency guidance + the banner shown elsewhere
    legal/                   Terms, privacy
    common_states/           No connection, maintenance, 404, force-update

  l10n/
    app_en.arb              English strings (structure only — see l10n.yaml once dependencies are added)

assets/
  fonts/Manrope/            Font files go here (see Font: Manrope above)
  images/logo/               App icon source, splash logo
  images/illustrations/       Onboarding / empty-state illustrations
  icons/                      Any custom icons beyond Material's set

test/
  unit/                     Controller and repository logic — no widget tree
  widget/                    Individual widget rendering/interaction tests
  integration/               Full-flow tests (e.g. sign in → book → confirm) with `integration_test`
```

## Recommended `pubspec.yaml` dependencies

No `pubspec.yaml` was written this pass — `flutter create` generates the working one that has to
exist for the project to build (see below), and this table is what to add to it, matching the
[tech stack recommendation](../docs/architecture/tech-stack-recommendation.md#3-mobile-flutter--patient-app):

| Package | Purpose |
|---|---|
| `flutter_riverpod`, `riverpod_annotation` (+ `riverpod_generator`, `build_runner` as dev deps) | State management |
| `go_router` | Navigation, deep links (booking/payment return links, push-notification taps) |
| `freezed`, `freezed_annotation`, `json_serializable` (+ `json_annotation`) | Immutable models, JSON |
| `dio` | HTTP client |
| `flutter_secure_storage` | Tokens, never in plain SharedPreferences |
| `local_auth` | Biometric unlock |
| `flutter_appauth` | OIDC/PKCE login against the identity provider once one is chosen |
| `firebase_core`, `firebase_messaging`, `flutter_local_notifications` | Push notifications |
| `livekit_client` *(or the chosen vendor's package — see the backend's `ConsultationModule` README note)* | Video/audio consultation |
| `drift` (optional) | Local cache for non-sensitive, non-authoritative data only — never for coverage/payment/booking status (blueprint §6.2) |
| `intl` | Date/number formatting, localisation |
| `sentry_flutter` | Crash/error reporting |
| `posthog_flutter` | Product analytics, governed event dictionary (matches the website's PostHog use) |
| **Dev:** `flutter_test`, `integration_test`, `patrol` (optional, for richer E2E), `mocktail` | Testing |
| **Dev:** `flutter_lints` | Linting |

## Turning this into a real project

1. **Generate the real Flutter project** (this creates `android/`, `ios/`, `pubspec.yaml`,
   `analysis_options.yaml` and the rest, in a temp location so it doesn't collide with the empty
   placeholders already here):
   ```bash
   flutter create --org com.lifecomelive --project-name lifecome_mobile /tmp/lifecome_mobile_scaffold
   ```
   (`Lifecome-mobile` isn't a valid Dart package name — it has a capital letter and a hyphen — hence
   `--project-name lifecome_mobile` and generating into a separate folder first.)

2. **Copy the generated platform folders in**: `android/`, `ios/`, `web/`, `macos/`, `linux/`,
   `windows/`, plus `pubspec.yaml`, `analysis_options.yaml` and `.metadata` from that temp project
   into `Lifecome-mobile/`. Don't copy its `lib/`, `test/`, or `pubspec.yaml`'s generated `main.dart`
   reference over what's already here.

3. **Add the dependencies** from the table above to the copied `pubspec.yaml`, and declare the
   Manrope font files under `flutter: fonts:` and the asset folders under `flutter: assets:`.

4. **Add `l10n.yaml`** (currently empty) with Flutter's standard `arb-dir: lib/l10n` /
   `template-arb-file: app_en.arb` / `output-localization-file` settings, and enable
   `generate: true` in `pubspec.yaml`.

5. **Run codegen and install:**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Start filling in files**, `core/` first (theme, router, network client), then `auth/` (the only
   feature every other screen sits behind), then outward from the dashboard.

## Before you write the first real screen

- **Point the API client at the backend.** `Lifecome-backend` is running and documented at
  `http://localhost:3001/api/docs` — see [its README](../Lifecome-backend/README.md) for setup. Generate
  the Dart API client from its OpenAPI spec rather than hand-typing request/response models.
- **The video vendor is still an open decision** (see the root README's sign-ups section) — it
  decides which package goes in `consultation/`, so settling it early avoids rework there.
- **Identity provider is also open** — `auth/` and `core/network`'s token handling depend on it.
- **Decide Android-first or both platforms together** before scaffolding continues into real code —
  see the root [README's mobile section](../README.md#building-the-mobile-app) for the trade-offs.
