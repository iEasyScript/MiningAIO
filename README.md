# Mining AIO

<img width="1000" height="500" alt="image" src="https://github.com/user-attachments/assets/e1affc8d-6598-4e4f-9806-bb8bd9770a50" />


A RuneScape 3 mining script for MemoryError. Pick an ore in the window, press Start, and it mines.

It plays the modern mining game rather than just spam-clicking a rock: it takes rockertunities, keeps the stamina bar topped up, tracks the ore box, and can drop, bank, or run off a Grace of the elves when the pack fills.

## What it does

**Rockertunities.** When a rock starts sparkling it moves to it and mines it. That is worth x4 to x8 damage and removes the random roll, so it is the single biggest source of XP in current mining. One shows up every 24 to 36 seconds and ignoring them costs more than anything else you could tune.

**Stamina.** Every swing drains the bar and at zero your damage drops to 20%. Re-clicking the rock you are already on resets it. The script does that at a configurable threshold (default 200 of 255) with a bit of jitter so it does not fire on the same value every time. It re-clicks the *same* rock, not a neighbour, so it never wastes a walk.

**Walking.** A walking player reports an idle animation, which naive miners read as "not mining" and use to click the nearest rock, cancelling their own trip. This one waits for the walk to finish before reconsidering.

**Ore box.** Read live from the game's counters, per ore, so the stats panel shows what is actually in it. The pack only starts filling once the box is full, which is what makes "inventory full" a real end-of-trip signal.

**When the pack fills** you get three options:

| Option | Behaviour |
| --- | --- |
| Stop the script | Default. Ends the run. |
| Bank it | Deposits the ore box and the pack at a nearby bank chest, booth, banker or deposit box, then reloads a preset. |
| Drop the ore | Powermining. Only items in the ore list are dropped, so a pickaxe, ore box or stack of porters is never at risk. |

**Grace of the elves.** If you wear one, it teleports ore straight to the bank and the pack never fills at all. Turn on the Grace option and the script watches the charge count and tops it up from signs of the porter in your pack. If it runs low and there are no porters left, it stops rather than mining into a dead amulet.

## Supported rocks

39 entries, matched by their real object IDs rather than by name.

| Category | Count | Levels | Contents |
| --- | --- | --- | --- |
| Ores | 18 | 1 to 90 | Copper, tin, iron, coal, silver, mithril, adamantite, gold, luminite, runite, orichalcite, drakolith, necrite, phasmatite, banite, Seren stone, light animica, dark animica |
| Primals | 10 | Daemonheim | Novite, bathus, marmaros, kratonium, fractite, zephyrium, argonite, katagon, gorgonite, promethium |
| Gems | 4 | 1 to 75 | Common, uncommon, precious and Prifddinas gem rocks |
| Minerals | 6 | 1 to 81 | Clay, limestone, granite, sandstone, red sandstone, crystal sandstone |
| Misc | 1 | 1 | Rune and pure essence |

There is also **Best for my level**, which picks the highest tier ore you can mine, and **Anything nearby**, which matches rocks by name for places the list does not cover.

Primals need Daemonheim and a ring of kinship, so they are listed but never picked automatically.

## Installation

Copy the `miningaio` folder into your scripts directory:

```
%USERPROFILE%\MemoryError\Lua_Scripts\miningaio
```

You should end up with:

```
Lua_Scripts/
└── miningaio/
    ├── miningaio.lua
    ├── ores.lua
    └── gui.lua
```

Run `miningaio/miningaio.lua`.

Keep all three files in that folder. `miningaio.lua` loads the other two as `miningaio.ores` and `miningaio.gui`, so renaming the folder breaks it.

## Before you start

Stand at the rocks with a pickaxe equipped or in your pack. Bring an ore box if you have one, it roughly doubles a trip.

For banking, start within reach of a bank. For the Grace option, wear the amulet and bring some porters.

Then pick your ore in the window and press Start. Nothing is clicked until you do.

## Settings

Everything in the window writes into `CONFIG` at the top of `miningaio.lua`, so you can also set it there and ignore the GUI.

| Setting | Default | Notes |
| --- | --- | --- |
| `ORE` | `nil` | An ore name, `"best"`, or `nil` for anything nearby. Unknown names stop the script and print the list. |
| `STAMINA_BELOW` | `200` | Out of 255. Set to 0 to go fully AFK and accept the damage penalty. |
| `FULL_ACTION` | `"stop"` | `"stop"`, `"bank"` or `"drop"`. |
| `USE_GRACE` | `false` | Charge upkeep for the Grace of the elves. |
| `GRACE_CHARGE_BELOW` | `10` | Out of 500. |
| `SCAN_RANGE` | `12` | Tiles. |
| `DEBUG` | `false` | Prints what it is clicking and why. |

## Known limits

It does not walk you to a mine. Start where the rocks are.

The Grace charge click uses a fixed item hash taken from a working script. If charging appears to do nothing in game, that constant (`GRACE_CHARGE_ACTION` in `miningaio.lua`) is the first thing to check.

Settings are not saved between runs.
