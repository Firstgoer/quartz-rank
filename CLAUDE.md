# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A World of Warcraft Classic addon (Lua) that plugs into the **Quartz** cast bar addon as a Quartz3 module named `Rank`. It appends the spell rank (e.g. `Lvl 3`, or a user-configured prefix) to the player's cast bar text, placed left or right of the spell name.

There is no build system, linter, or test suite. Code runs only inside the WoW client; to test, copy/symlink the repo into `Interface/AddOns/Quartz_Rank/` with Quartz installed and `/reload`.

## Releasing to CurseForge

Pushing a git tag (`1.9`, `1.9-beta1`, `1.9-alpha1`) runs `.github/workflows/release.yml`, which packages the addon with the BigWigs packager and uploads it to CurseForge project 409129 (`## X-Curse-Project-ID` in the flavor TOCs). It needs the repo secret `CF_API_TOKEN`. The packager replaces `@project-version@` in the TOCs with the tag and builds the changelog from commits.

- CurseForge's own automatic packaging (webhook) must stay disabled. It ignores the `-g` fix below and uploads a duplicate file tagged with retail (seen on 1.9-alpha1 and in 2022).
- `.pkgmeta` declares CurseForge relations for every upload: `quartz` (original, Classic Era + TBC) and `quartz-midnight` (Quartz Redux, Forever). Their flavors don't overlap, so each flavor resolves to exactly one.
- `.pkgmeta` lists development files excluded from the zip (`CLAUDE.md`, `tests`). Dotfiles are excluded automatically. Add any new non-addon file to `ignore`.
- Game versions are passed explicitly with `-g`, computed from `Quartz_Rank_*.toc` only. Otherwise the fallback TOC's `## Interface: 00000` is detected as retail and the file gets published for retail (the reason the 2022 `.pkgmeta` attempt was reverted). A new flavor TOC is picked up automatically.

## Multi-client TOC layout

WoW picks a flavor-specific TOC by suffix and falls back to the unsuffixed one. Each supported flavor (only clients that still have spell ranks) has its own TOC that loads `globals/<flavor>.lua`, `locale.lua`, then `core.lua`:

- `Quartz_Rank_Vanilla.toc` — Classic Era (`globals/vanilla.lua`).
- `Quartz_Rank_TBC.toc` — Burning Crusade Classic / Anniversary (`globals/tbc.lua`).
- `Quartz_Rank_Camelot.toc` — WoW: Forever (`globals/forever.lua`). The game accepts both `_Camelot` and `_Forever` suffixes; `_Camelot` is the canonical game type and the one the BigWigs packager recognizes. Forever runs on the modern client API, hence the `C_Spell.GetSpellSubtext` fallback at the top of `core.lua`.
- `Quartz_Rank.toc` — fallback for every other client (`Interface: 00000`); loads only `unsupported.lua`, which prints an error to chat.

`## X-Quartz-Module: Rank` is what lets Quartz recognize the module. The globals files differ only in locale rank strings (e.g. ruRU). `locale.lua` holds this addon's options-panel strings as `ns.L` (English keys, English fallback); in `core.lua` it's `RL`, while `L` is Quartz's own locale (Enable/Left/Right). `unsupported.lua` loads alone, so it carries its own translated message. After a game patch, update `## Interface:` in the flavor TOC (check in-game with `/dump select(4, GetBuildInfo())`). Don't hardcode `## Version:`; it stays `@project-version@`.

## How core.lua works

- Registers itself via `Quartz3:NewModule("Rank")`, stores settings in `Quartz3.db:RegisterNamespace("Rank", defaults)` (`ranktextposition`, `ranktext`), and adds an options panel through `Quartz3:RegisterModuleOptions`. Option keys map to db keys by prefixing `rank` (e.g. option `textposition` → `db.ranktextposition`).
- **Monkey-patches Quartz's shared cast bar template** (`Quartz3.CastBarTemplate.template`) in `OnEnable`, and restores the originals in `OnDisable`:
  - `UNIT_SPELLCAST_START` / `UNIT_SPELLCAST_CHANNEL_START` are wrapped to capture `spellID` into the module-level `castingSpellID`, then call the original.
  - `SetNameText` is wrapped: it decorates `name` with the rank (left/right) and calls Quartz's original, so target-name formatting stays owned by Quartz. Don't reimplement Quartz's formatting here.
- Two Quartz forks are supported, both installing as folder `Quartz` with AceAddon name `Quartz3` (so `## Dependencies: Quartz` covers both): original Quartz (Classic Era, TBC) and **Quartz Redux** (github.com/NoSelph/Quartz; Midnight + Forever). In Redux, `UNIT_SPELLCAST_CHANNEL_START` is an alias of `UNIT_SPELLCAST_START`, and values such as the spell name, spell ID and subtext can be Midnight "secret values". Never compare, concatenate or `string.match` a value without checking `IsSecret()` first (it wraps `issecretvalue`, which doesn't exist on Classic).
- Rank is only shown for `self.unit == "player"`.
- Rank parsing: `GetSpellSubtext(spellID)` returns a localized string like `"Rank 3"`. The per-locale format from `ns.CASTING_TRANSLATIONS[GetLocale()]` (set by the `globals/*.lua` file on the shared addon namespace `local _, ns = ...`, never as a global) has its pattern magic characters escaped and `%d` turned into a `(%d+)` capture; falls back to Blizzard globals `TRADESKILL_RANK_HEADER` and `FLOOR_NUMBER`. If no number is extracted, the raw subtext is shown instead.
- The addon must not create any globals: an earlier global `GetSpellRank` conflicted with other addons (commit f6edddb). Keep helpers `local`, and share data between files through `ns`.
