# Third-party icons

The bottom-navigation icons in `nav/` are not original artwork. They are
unmodified path data from two open icon sets, repackaged as standalone 24x24
SVGs (explicit paint attributes on each `<path>`, so `flutter_svg` can tint
them with a `ColorFilter`).

| Asset (outline / filled)               | Icon          | Set                     |
| -------------------------------------- | ------------- | ----------------------- |
| `home.svg` / `home-filled.svg`         | `home`        | Heroicons 2.2.0 (24)    |
| `profile.svg` / `profile-filled.svg`   | `user`        | Heroicons 2.2.0 (24)    |
| `services.svg` / `services-filled.svg` | `element-3`   | Iconsax (Linear / Bold) |
| `visit.svg` / `visit-filled.svg`       | `calendar`    | Iconsax (Linear / Bold) |
| `messages.svg` / `messages-filled.svg` | `messages-1`  | Iconsax (Linear / Bold) |

- **Heroicons** — MIT License, Copyright (c) Tailwind Labs, Inc.
  <https://github.com/tailwindlabs/heroicons> (outline = 24/outline, filled =
  24/solid).
- **Iconsax** — by Vuesax, <https://iconsax.io>. The path data was taken from
  the MIT-licensed `iconsax-react` 0.0.8 package; the icon artwork itself is
  covered by Iconsax's own terms, so confirm they suit the app's commercial use
  before a public release.
