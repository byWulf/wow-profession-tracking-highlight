# Profession Tracking Highlight

A World of Warcraft addon that marks the action button of your active profession tracking. When Find Herbs or Find Minerals is on, its button on your action bars gets a colored border, so you can see at a glance which tracking is running.

- **See your tracking at a glance:** the button of the active tracking gets a border, green for Find Herbs and orange for Find Minerals by default
- **Switches with you:** cast the other tracking and the border moves to its button; turn tracking off and it disappears
- **Your style:** border thickness, a color per tracking and an optional glow, all in the options
- **Class and racial tracking too, if you like:** Find Treasure, Track Beasts, Sense Undead and the like can be marked as well (off by default)
- **Works with your action bars:** Blizzard's bars, Bartender4, Dominos, ElvUI, EllesmereUI, DaylightUI and other bars built on LibActionButton, and also macros that show a tracking spell
- Available in all languages of the WoW Forever client

## Supported game versions

| Version | Interface |
|---|---|
| WoW Forever | 16001 |

Classic Era and other versions are not supported.

## Installation

Install it from [CurseForge](https://www.curseforge.com/wow/addons/profession-tracking-highlight), e.g. with the CurseForge app.

For a manual installation, note that the folder in your AddOns directory **must** be named `ProfessionTrackingHighlight`, otherwise WoW will not load the addon:

```bash
cd "C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns"
git clone https://github.com/byWulf/wow-profession-tracking-highlight.git ProfessionTrackingHighlight
```

Alternatively, download the ZIP from the [releases](https://github.com/byWulf/wow-profession-tracking-highlight/releases) and extract it into `Interface/AddOns`.

Then `/reload` in game.

## Usage

Put Find Herbs and/or Find Minerals on an action bar, if they aren't there yet, and cast one of them. That's all: the button of the tracking that is on gets the border.

## Options

Options > AddOns > Profession Tracking Highlight, or `/pth` (also `/professiontracking`).

| Option | Default |
|---|---|
| Also mark other tracking (class and racial tracking abilities) | Off |
| Border thickness | 3 |
| Glow | Off |
| Color: Find Herbs | Green |
| Color: Find Minerals | Orange |
| Color: other tracking | Gold |

## Languages

All languages of the WoW Forever client: English, German, French, Spanish (EU and Latin America), Brazilian Portuguese, Russian, Korean, Simplified and Traditional Chinese. The language follows your WoW client; spell names are taken from the game.

## License

MIT, see [LICENSE](LICENSE).
