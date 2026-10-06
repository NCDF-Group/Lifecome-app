<p align="center">
  <img src="assets/images/logo/lifecome-live-logo.svg" alt="LifeCome Live" width="360" />
</p>

# LifeCome Live - Patient App

The Flutter app for LifeCome Live patients: book an online GP or an in-person Smart GP clinic visit,
keep health records and a care plan, message the care team, and manage an account.

It talks to the LifeCome backend (NestJS) over REST. Where the backend doesn't have an endpoint yet,
the screen is built and works locally with sample data - see [What's real and what isn't](#whats-real-and-what-isnt).

## Contents

- [Run it](#run-it)
- [What's in the app](#whats-in-the-app)
- [Project structure](#project-structure)
- [Design system](#design-system)
- [Navigation](#navigation)
- [Stack](#stack)
- [What's real and what isn't](#whats-real-and-what-isnt)

## Run it

Needs Flutter 3.47+ (Dart 3.13+).

```bash
flutter pub get
flutter run
```

The API base URL defaults to the deployed backend. To point at your own, pass it at run or build time:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3001/api/v1
```

On an Android emulator, `localhost` is the emulator itself - use `http://10.0.2.2:3001/api/v1`.

Release APK:

```bash
flutter build apk --release
```

Checks: `flutter analyze` and `dart format lib`.

## What's in the app

| Area | Screens |
|---|---|
| **Onboarding & auth** | Splash, welcome, create account (details, email verification, password), sign in, forgot / reset password, app lock (biometric) |
| **Home** | Greeting header, Online GP and Smart GP Clinic cards, "Your Care" call to action, membership banner, quick links, location confirmation |
| **Book** | Choose your access, connect your access, my benefits, how can we help, find a GP, Smart GP locations, choose your appointment, prepare for online care / clinic visit, review (online, in-person or funded), confirmation |
| **Records** | Health records (All / Online / Clinic), care plan, your next steps |
| **Messages** | Contact the care team by topic |
| **Notifications** | Booking, message, support and record updates |
| **Profile** | Account card, my profile, country, help and support, privacy policy, terms and conditions, sign out, delete account |
| **Consultation** | Waiting room and video call UI |

## Project structure

```
lib/
  app.dart, main.dart, bootstrap.dart
  core/
    router/        go_router config, route paths, the shell with the floating navigation bar
    theme/         colours, spacing, text theme, SVG icon set (app_svg_icons.dart)
    widgets/       shared widgets; design/ holds the Home / Book / Records building blocks
    network/       Dio client and API errors
    country/       Nigeria / UK selection, persisted
    services/      session store
  features/
    auth/ booking/ care_plan/ consultation/ dashboard/ doctors/ health_records/
    legal/ messaging/ notifications/ payer/ profile/ splash/ support/ welcome/
      (each: presentation/, application/, data/, domain/ as needed)
assets/
  images/{logo,home,welcome}/   fonts/Manrope/   icons/
```

## Design system

Screens share one set of building blocks in `lib/core/widgets/design/soft_widgets.dart`:

- `SoftCard` - the pale-blue bordered card
- `PillButton` - full-width pill, filled or outlined, with a chevron
- `InfoNote`, `PageHeading`, `DesignBackButton`, `IconCircle`
- `SlidingSegments` - segmented control (Online / In Person, All / Online / Clinic)
- `DetailRows`, `ActionRow`, `LinkRow` - key-value lists and tappable rows

Icons are single-colour SVGs drawn in `lib/core/theme/app_svg_icons.dart` (`AppSvgIcon(AppSvgGlyph.x)`),
recoloured at draw time. Colours live in `AppColors` (primary action blue `#016DC3`, card fill `#F5F9FD`,
border `#D7DAE0`). The font is Manrope, bundled.

## Dark mode

Light, dark, or follow the phone (Profile > Appearance; the choice is remembered). Colours that change with
the theme live in `AppColors` as getters (`background`, `textPrimary`, `cardFill`, `tintBlue`, ...), backed by a
light and a dark palette; brand and accent colours (`actionBlue`, `accentGreen`, ...) are constants. The
palette is global and is switched in `app.dart` before any screen builds, and the whole UI rebuilds when the
brightness changes - so use the getters, never a hard-coded hex, for anything that should follow the theme.
Because they are getters, expressions using them can't be `const`. The Online GP / Smart GP Clinic cards stay
light in both themes because their artwork has a pale background baked in.

## Navigation

`go_router` with a `StatefulShellRoute`: five tabs (Home, Book, Records, Messages, Profile) in a floating
pill bar. The selected tab expands into a blue pill and slides between tabs; tab content cross-fades and
each tab keeps its own stack. The booking flow screens stay inside the Book tab so the bar stays visible.

## Stack

| | |
|---|---|
| Framework | Flutter / Dart |
| Navigation | `go_router` |
| State | `flutter_riverpod` |
| HTTP | `dio` |
| Storage | `shared_preferences` (name, country), `flutter_secure_storage` (session token) |
| Photos | `image_picker` |
| Biometrics | `local_auth` |
| Graphics | `flutter_svg` |

## What's real and what isn't

**Wired to the backend:** sign up and sign in (the greeting uses your name from your profile, never your
email), your profile and profile photo, the service catalogue, clinicians and their open times, booking,
confirming and cancelling appointments, My visits, messages to the care team, and notifications (a
booking confirmed or cancelled, a care-team reply). The bell checks for new ones every 45 seconds. The session token is
kept in the platform's secure storage, so a biometric unlock goes straight back in; if it has expired the
app asks for your password.

**Built and working locally, backend not connected yet:** payments and funding checks (while the
backend's `ALLOW_SELF_CONFIRM_BOOKINGS` is on, "Pay and confirm" books without taking payment), the care
plan and visit summaries. Records lists your real past visits as "Summary pending" until clinicians can
write summaries; the care plan screen shows an empty state.

Some illustrations (avatar, Online GP, Smart GP Clinic, location photos) are placeholders and should be
replaced with the final artwork.
