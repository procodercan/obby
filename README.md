# Escape Tsunami: Fish Edition

A Roblox game where you play as one of **2,999 unique fish** escaping a devastating tsunami. Swim for survival!

## Features

- **2,999 Fish Varieties** – 23 species × 13 colors × 10 patterns with size variations
- **Ocean Escape Gameplay** – Swim away from the incoming tsunami wave
- **Obstacles** – Rocks and debris to avoid
- **Fish Selector** – Pick any fish by ID (1–2999) or randomize
- **Polished UI** – Clean menus, score display, game over screen

## Installation (Roblox Studio)

1. Open **Roblox Studio** and create a new **Baseplate** or **Obby**.
2. Create the folder structure below and add the scripts.

### Folder Structure

```
ReplicatedStorage
└── Modules (Folder)
    ├── FishData (ModuleScript)
    └── FishBuilder (ModuleScript)

ServerScriptService
└── GameController (Script)

StarterPlayer
└── StarterPlayerScripts
    └── PlayerController (LocalScript)

StarterGui
└── MainUI (LocalScript)
```

### Steps

1. **ReplicatedStorage** → Create folder `Modules`
   - Create **ModuleScript** named `FishData` → paste contents of `src/ReplicatedStorage/Modules/FishData.lua`
   - Create **ModuleScript** named `FishBuilder` → paste contents of `src/ReplicatedStorage/Modules/FishBuilder.lua`

2. **ServerScriptService** → Create **Script** named `GameController` → paste contents of `src/ServerScriptService/GameController.lua`

3. **StarterPlayer** → **StarterPlayerScripts** → Create **LocalScript** named `PlayerController` → paste contents of `src/StarterPlayer/StarterPlayerScripts/PlayerController.lua`

4. **StarterGui** → Create **LocalScript** named `MainUI` → paste contents of `src/StarterGui/MainUI.lua`

5. Enable **Terrain** in the World tab so water can be styled.
6. Add **SpawnLocation** in Workspace for players to spawn.

## Controls

| Key | Action |
|-----|--------|
| W | Swim forward |
| S | Swim backward |
| A / D | Strafe left / right |
| Space | Swim up |
| Left Shift | Swim down |

## Fish Rarity

- **1–100**: Legendary
- **101–500**: Epic
- **501–1500**: Rare
- **1501–2999**: Common

## Game Logic

- The tsunami chases you from behind.
- Obstacles spawn periodically.
- You must stay ahead of the wave to survive.
- Score = seconds survived.

Have fun escaping the tsunami with your favorite fish!
