# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Gentegre / Entegra** — a large Delphi VCL desktop ERP application (finance, stock, CRM, projects, document tracking, HR) developed by Feta Bilgisayar / Genyazılım. Code, comments, identifiers, UI strings and documentation are predominantly **Turkish**. Preserve Turkish identifier names and copy when editing.

- Toolchain: **Embarcadero RAD Studio 37.0 (Delphi 13.1)**, VCL framework, Win32 target.
- Components: **DevExpress (cx*, dx*)**, FastReport, JVCL (Jv*), FireDAC for new data access, ADO in legacy code paths.
- Database: **Microsoft SQL Server** (60+ tables). Active project DB is `DESKTOP-HL3J3AS\SQLEXPRESS` / **`BILIM`** (sa / FETAGEN — local dev only). `sql_calistir.ps1` is configured for this DB (`$database = "BILIM"`).
- Three program entry points: `Gentegre.dpr` (modern, actively developed), `entegra.dpr` (legacy), `Rehber.dpr` (standalone address-book module).

## Repository layout quirk

The git repository root is **one level up** at `C:\Users\HP\Entegra\` (working dir contains `.git/`). The actual Delphi sources live in the `Entegra\` subdirectory (this file's location). When running `git` commands, paths in `git status` are prefixed with `Entegra/...`. Sibling directories at the repo root (e.g. `Banka/`, `BelgeTransfer/`, `DelphiVoicePatient/`, `Dis/`, `Mobil/`, `POSAktar/`, `YZAjanlar/`, `GenService/`, `ITS/`, `Aktarim/`) are **separate companion projects**, not part of this Delphi app — don't pull them in unless asked. `BelgeTransfer/` has its own `AGENTS.md`.

The repo also contains a stale `.svn/` directory and many `.rar` source-code snapshot archives at the parent level — both ignored by git; ignore them when searching.

## Build & run

```cmd
build.bat
```

This first runs `ensure_utf8_bom.ps1` (normalizes source encoding to UTF-8 BOM), then calls `rsvars.bat` and runs:

```cmd
msbuild Gentegre.dproj /t:Build /p:Config=Debug /p:Platform=Win32
```

- Release build: swap `/p:Config=Debug` for `/p:Config=Release`. Win64 target is configured but Win32 is the standard build.
- Compile outputs go to `\bin\$(Ver)\$(Platform)\$(Config)` and `\BIN\$(Ver)\dcu\$(Platform)\$(Config)` (see `DCC_ExeOutput` in `Gentegre.dproj`).
- IDE alternative: open `Gentegre.dproj` in RAD Studio, then **Project > Build** or `F9` to run. The accompanying VS Code workspace is `Entegra.code-workspace` (includes a separate `../Ortak` shared-utilities folder).

There is **no automated test suite**. Validate changes by building and exercising the affected screen in the running app.

## Key directories (inside this folder)

| Path | Role |
|------|------|
| `Ortak/` | Shared utilities, base classes, data module, dialog primitives (`Fetautil`, `FetaKurulusSiniflari`, `UFrameYoneticisi`, `UHataDialog`, `Umesaj`, `UCombo`, `UKimlik`, etc.) |
| `AnaFrame/` | Top-level tab container (`UGenelAnaSekmeFrame`) — orchestrates left/middle/right panels |
| `AramaFrame/` | 35+ search/filter panels (left pane) |
| `IcerikFrame/` | 30+ content/detail frames (center pane) |
| `ListeFrame/` | 30+ grid frames |
| `GorevFrame/` | Task/action panels (right pane) |
| `AracCubuguFrame/` | Toolbar frames |
| `GirisSayfaFrame/` | Dashboards |
| `EvrakTakip/` | Document-tracking module |
| `Social/` | CRM/social features |
| `ItsServisler/`, `UTS/` | Warehouse / product-tracking integrations |
| `eFaturaApi/` | GIB e-invoice integration |
| `Rest/` | TCP/REST integration with POS/receipt printers |
| `Archive/` | Old code kept around — usually do not edit |
| `3dparty/` | Vendored libs (GenYazilim, SuperObjects, DelphiJSON_Tree) — do not modify |

## Critical conventions

These are documented in detail in the companion docs — read them before non-trivial work:

- **`architecture.md`** — module map, dependency layers, tab/frame lifecycle, integration list.
- **`ui-guidelines.md`** — DevExpress component standards, colors, fonts (Trebuchet MS, `TURKISH_CHARSET`), skin (`London Liquid Sky`), `cxEditRepository1` items, image lists.
- **`error-handling.md`** — transaction pattern (`StartTransaction` / `try` / `Commit` / `except` / `Rollback if InTransaction` / `raise`), `Veritabani.VeriVarMi` / `BasitKomutCalistir` helpers, `Application.OnException` handler in `UKimlik.pas`, `ShowErrorDialog` from `UHataDialog`.
- **`ebelge-akis.md`** — GİB e-Belge (e-Fatura / e-Arşiv / e-İrsaliye) flow: encoding schemes (`FATBASLIK.TUR`, `REHBERALIAS.BELGETURU`/`EBELGE.BELGETURU` alias codes), the tables/constants and REST endpoints used, and the decision logic in `UFaturalar.MenuEFatura` / `UOpsiyonFatura` / `UEBelgeOlusturucu`. Read this before touching e-invoice code.

Key patterns to honor without re-deriving:

- **Central data module:** `Utablo.pas` (`TDataModule`) owns the `FDConnection`, all shared `FDQuery` instances, the `cxEditRepository1`, style repositories, and image lists. New queries/styles/icons typically go here, not in individual forms.
- **Frame factory:** `UFrameYoneticisi` / `UGentegreFrameYonetimi` instantiate frames dynamically. Tab structure is data-driven via `entegra_sekmeconfig.xml` (with `SekmeConfig.xml` / `*.backup*.xml` variants present).
- **Event bus:** Cross-module notification goes through `Ortak/UMultiCastEvent.pas`, not direct form references.
- **Wizards:** Multi-step business flows use the `JvWizard`-based pattern (`UFaturaWizard`, `UStokWizard`, `UProjeWizard`...).
- **ADO → FireDAC:** Legacy code uses `TADOQuery`/`TADOConnection`; new/modernized code uses `TFDQuery`/`TFDConnection`. The Python helpers in the parent folder (`convert_dfm.py`, `fix_dfm.py`, `fix_binary_dfm.py`) exist to assist this conversion on `.dfm` form files.

## Tooling in this folder

- `build.bat` — primary build entry point.
- `sql_calistir.ps1` + `sql_calistir.sql` — ad-hoc SQL runner against the local SQL Server, writes results to `sql_sonuc.txt`. Edit the `.sql` and re-run when you need to inspect DB state.
- `refactor_references.ps1`, `refactor_missing_item.ps1`, `rollback.ps1` — refactoring helpers for the central component registry / `Utablo` items.
- `tmp_query_*.ps1` — disposable experiments; safe to ignore. The `.claudeignore` excludes `tmp_*.ps1` from indexing.

`.claudeignore` also excludes build artifacts (`*.dcu`, `*.exe`, `*.dll`, `*.bpl`, `*.res`, `*.map`, `*.identcache`, …), media (`*.bmp`, `*.png`, `*.jpg`, `*.wav`, `*.pdf`, `*.doc`, `*.xls`), the `3dparty/` vendored libraries, and archive backups (`*.rar`, `*.zip`). Don't try to read these blobs; if a `.dfm` reads as binary, it starts with `TPF0` — convert it with `../convert_dfm.py` before editing.

## Editing notes

- `.pas` and `.dfm` files come as a pair — keep component names/types in sync between them. DFMs may be text or binary; the binary form is rare but possible.
- `Utablo.dfm` is multi-megabyte (the central data module). Read specific offsets, do not dump the whole file.
- Default code-page assumptions in legacy units are Windows-1254 (Turkish). Modern files are UTF-8; PowerShell helpers write UTF-8 explicitly.
- The working tree uses dated snapshot branches named `backup/YYYYMMDD` (e.g. `backup/20260622`); commits are periodic "Backup snapshot" saves of the whole tree. Branches `master`, `remote-snapshot`, and `local-full-backup` exist as safety copies — confirm with the user before switching.
