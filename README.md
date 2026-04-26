# Skyrim Texture Overhaul Pack Helper

This repository now includes a small helper workflow to package a completed texture overhaul into a **Mod Organizer 2 (MO2)-ready mod folder** and optional archive.

## What this is for
If your texture generation pipeline already produced files but the final pack was never assembled/wired, use the PowerShell script in `tools/` to:

1. Collect generated texture assets from a source folder.
2. Build a clean MO2 mod layout (`textures/`, optional `meshes/`).
3. Output to your mod location (example: `D:\skyfall 2.0\mods`).
4. Optionally create a `.7z`/`.zip` archive for sharing/backups.

## Quick Start
From PowerShell:

```powershell
pwsh -File .\tools\Build-SkyrimTexturePack.ps1 `
  -SourcePath "D:\your-generated-textures" `
  -ModRootPath "D:\skyfall 2.0\mods" `
  -PackName "Skyfall 2.0 - Full Texture Overhaul" `
  -ProfileName "testing" `
  -CreateArchive
```

After running:
- Enable the created mod in MO2.
- Put it low enough in priority to overwrite older texture packs when desired.
- Launch game through MO2 using your `testing` profile.

## Notes
- The script does not edit MO2 profile files automatically.
- It only assembles/copies content so you can review before enabling.
- If a generated asset folder does not contain `textures`, all files are still copied and placed under `textures/` by default (safe fallback).
