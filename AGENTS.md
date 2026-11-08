# AGENTS.md

## Language

All documentation in this repository (README, AGENTS.md, code comments, commit messages) is written in **English**.

## Project

WoW addon `ProfessionTrackingHighlight` (shown as "Profession Tracking Highlight"): marks the action button of the active profession tracking (Find Herbs, Find Minerals) with a colored border and an optional glow. Class and racial trackings can be marked too (option, off by default).

- `ProfessionTrackingHighlight.toc`: addon manifest, interface `16001` (WoW Forever only, Classic Era is not supported), SavedVariables `ProfessionTrackingHighlightDB` (account-wide options)
- `Locales.lua`: all user-facing strings. English is the base table, other locales only override keys. Exposed as `ns.L`. Covers every text locale of the WoW Forever client: enUS, deDE, frFR, esES, esMX (same table as esES), ptBR, ruRU, koKR, zhCN, zhTW. There is no itIT client. The TOC has a localized `Notes-xxXX` for each. Spell names are never translated here, they come from the client (`ns.SpellName`).
- `Core.lua`: options defaults, the profession tracking spell IDs, reading the active trackings, the `/pth` command and all events
- `Buttons.lua`: finding action buttons of all bar addons (named lists, Blizzard's `ActionBarButtonEventsFrame.frames`, LibActionButton registries, plus one walk over all frames), reading the spell a button shows, and the border/glow overlay. Taken from Smart Gear Switcher (`byWulf/wow-smart-gear-switcher`), which matches buttons the same way.
- `Options.lua`: options page with Blizzard's Settings API (vertical layout)

Key behavior:

- Tracking is no aura in Forever. The active trackings come from `C_Minimap.GetNumTrackingTypes` / `C_Minimap.GetTrackingInfo(index)` (a table with `name`, `active`, `spellID`), re-read on `MINIMAP_UPDATE_TRACKING`, `SPELLS_CHANGED`, `PLAYER_ENTERING_WORLD` and `PLAYER_REGEN_ENABLED`. Entries without a spell ID (flight masters etc.) are skipped.
- Profession trackings: Find Herbs `2383`/`8387`, Find Minerals `2580`/`8388` (Forever uses the second ID as well). Anything else that is active counts as "other" and is only marked with the option on. Forever has no Find Fish.
- A button matches when the spell it shows (spell action, or the spell of a macro via `GetMacroSpell`, or a LibActionButton `spell`/`macro` button) equals an active tracking by spell ID or by spell name (name catches the other ID of the same tracking).
- In combat, values can be secret (`issecretvalue`). A button whose contents can't be read keeps its current look; the tracking list keeps its last readable state.

The Forever UI source is mirrored at https://github.com/Gethe/wow-ui-source (branch `forever`, game type "Camelot"). Check it before relying on Blizzard frame or function names.

When adding a user-facing string, add the key to the English base table and to every locale in `Locales.lua`.

## Installed copies

The addon is installed as a plain copy (not a clone) in:

- `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\ProfessionTrackingHighlight`

After changing the `.toc` or any `.lua`, copy them to the Forever installation. The folder name must stay `ProfessionTrackingHighlight`.

## Testing

There is no automated test setup. Changes are verified in game with `/reload`; Lua errors show up with `/console scriptErrors 1`. A syntax check is possible with `luajit -bl <file>.lua`.

## Releasing

Releases are built by `.github/workflows/release.yml` with the BigWigs packager (`.pkgmeta` sets the folder name and leaves out `AGENTS.md`/`CLAUDE.md`).

1. Commit and push the changes to `main`.
2. Tag and push: `git tag -a vX.Y.Z -m "X.Y.Z"` and `git push origin vX.Y.Z` (semantic versioning).
3. The workflow packages the addon, replaces `@project-version@` in the TOC with the tag, uploads the zip to CurseForge (project ID from `X-Curse-Project-ID` in the TOC, game version from the TOC interface) and creates the GitHub release.

Not on CurseForge yet: the project has to be created by hand first and its ID added to the TOC as `## X-Curse-Project-ID`. The upload needs the repository secret `CF_API_TOKEN`. Never edit `## Version` in the TOC by hand; installed dev copies show `@project-version@`.
