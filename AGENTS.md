# Combat Tracker — Developer Guide (AGENTS.md)

This document outlines the architecture, coding conventions, and roadmap for the Combat Tracker project. Use this guide to understand the codebase and maintain consistency when contributing.

## Architecture & Data Flow

### The Single Source of Truth
`combat_encounter.gd` is the core of this project. It is the absolute single source of truth for all combat state. 
- **Centralized Logic**: Any function that interacts with or modifies the combat state must be defined here. Interfaces (like the text tracker) should only call these centralized functions.
- **Resource Benefits**: It is a Godot `Resource` by design. This allows encounters to be saved to disk, pre-built and loaded later, and enables carrying players over between encounters.
- **Shared State**: Because it is a Resource, a single encounter instance can be shared across multiple scenes. This means a DM interface and a Player-facing interface can both interact with the exact same data simultaneously.

### File Structure: Entities vs. Systems
Keep the file structure strictly organized by purpose. Think carefully about where data should be stored and where functions belong.
- **`entities/`**: Frontend. All visual elements, UI windows, and scenes belong here.
- **`systems/`**: Backend. Core simulation, data models (Resources), and utility scripts belong here.
- **`addons/`**: Third-party editor plugins (e.g., `script-ide`).

## Coding Conventions

- **Do NOT edit `.tscn`, `.tres`, or `.uid` files**: Unless explicitly asked, never manually edit Godot scene (`.tscn`), resource (`.tres`), or generated UID (`.uid`) files. Always instruct the user (or leave a TODO comment) to make scene/resource changes in the Godot Editor. Let the editor create script UID files itself to avoid duplicate or invalid IDs.

Follow these rules for all GDScript files:

- **Indentation**: ALWAYS use tabs. Never use spaces.
- **Class Organization**: Keep classes highly structured and readable.
  - Group related variables together without line breaks.
  - Use a single line break to separate different groups of variables.
  - Use a single line break between related functions within a group.
  - Use double line breaks to separate major groups of functions.
  - Order your function groups so they match the order of their corresponding variable groups. 
- **Negative Space Programming**: Show what should not happen by what you do not write. Do not create unnecessary extra checks that return silently. Where a check is reasonable to add and possible to fail, use `assert(check, "error msg")` to crash immediately with a specific and useful error message.
- **Avoid Useless Intermediate Variables**: Keep code concise. If a variable is only used once, inline it. For example, instead of `var name := args[0]; find(name)`, use `find(args[0])`. If a line gets too long, split it across multiple lines with a backslash `\` or by putting function arguments on new lines rather than creating intermediate variables.
- **Descriptive Naming**: Keep helper function names verbose and descriptive. It must be clear what a function does based solely on its name.
- **Explicit Type Hints**: Prefer explicit type hints over type inference (e.g., use `var target: Entity = ...` instead of `var target := ...`).
- **Function Comments**: Any function that is used in another class, or is long enough that reading a comment is faster than reading the function itself, and does not have a name that fully explains its function, must have a double hashtag (`##`) comment (single-line if possible) above the function name. Describe *what* the function does, not *how* it does it.
- **Maintain Documentation Integrity**: Always update code comments, inline documentation, and this `AGENTS.md` file immediately when any changes or edits would render them outdated or inaccurate.

## Testing & Validation

### Godot Headless Checks
When running Godot from the Codex sandbox, use the right command form first and keep Godot's user data contained. Native Godot crash/error popups are not a useful way to notify the user that a command failed: they interrupt the user's desktop, are not captured in the transcript, and can obscure whether the project failed or the command was wrong.

Always point `APPDATA` and `LOCALAPPDATA` at a unique writable temporary folder in the same PowerShell invocation before launching Godot. Do not point them at the project folder, because that pollutes the repository with generated `Godot/app_userdata/.../logs` files. Use a unique folder per Godot process, especially when running checks in parallel, so separate runs cannot collide over the same log files.

For full project startup validation, use this pattern:
```powershell
$godot_user_data = Join-Path ([System.IO.Path]::GetTempPath()) ("combat-tracker-godot-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $godot_user_data | Out-Null
$env:APPDATA = $godot_user_data
$env:LOCALAPPDATA = $godot_user_data
godot --headless --path "combat-tracker" --quit
```

For targeted script parsing, use the same environment setup and swap only the final line. `--check-only` is for script parsing with `--script`; do not use it as a general project startup check.
```powershell
godot --headless --path "combat-tracker" --check-only --script "res://systems/combat/combat_encounter.gd"
```

If a Godot check fails, inspect the console output first. Logs will be under the temporary folder assigned to `APPDATA`/`LOCALAPPDATA`, not inside the repository. If testing takes multiple attempts, say that in the final response and consider refining this section so the next agent can get it right first try.

## Roadmap & Planned Features

The ultimate goal is to build a highly flexible, multi-window tool.

1. **Core Interfaces**:
   - **Text-based DM UI**: A keyboard-only, command-line style interface for rapid use (currently in progress).
   - **Visual DM UI**: A traditional, basic UI-based DM interface.
   - **Player UI**: A basic UI-based interface for players. It will feature togglable settings for what/how much information is shown to players, support for uploadable enemy sprites, and alternate state sprites (e.g., pristine, damaged, bloodied), with eventual support for animations.
2. **Multi-Monitor Support**: Support for pop-out windows, allowing separate interfaces (like the DM view and Player view) to be displayed on different monitors.

## Existing Subsystems

- **Combat (`systems/combat/`)**: Contains `combat_encounter.gd` (the core state) plus `Entity`, `Player`, and `Enemy` Resources for individual combatants. Player damage can fall to unconscious or lethal negative HP, while enemy damage clamps at 0 HP.
- **Damage (`systems/damage/`)**: Enums for damage types, vulnerability math, and color mappings.
- **Dice (`systems/dice/`)**: Notation parser (e.g., `1d20+5`) and rolling logic.
- **Text (`systems/text/`)**: Utilities for string similarity and closest-match searches.

When implementing new features, ensure they hook into `combat_encounter.gd` appropriately and strictly respect the boundary between backend `systems/` and frontend `entities/`.
