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

In practice the user compiles from the RAD Studio IDE — write the code and let them build unless they explicitly ask you to run the build. If you do run it, note that `build.bat` ends with `pause` (blocks non-interactive shells) and hardcodes the `.dproj` path; prefer calling `rsvars.bat` + `msbuild` directly.

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
- **`ebelge-akis.md`** — GİB e-Belge (e-Fatura / e-Arşiv / e-İrsaliye) flow: encoding schemes (`FATBASLIK.TUR`, `REHBERALIAS.BELGETURU`/`EBELGE.BELGETURU` alias codes), the tables/constants and REST endpoints used, and the decision logic in `UFaturalar.MenuEFatura` / `UOpsiyonFatura` / `UEBelgeOlusturucu`. Read this before touching e-invoice code. (`IHRACAT_DAGITIM.md` covers the İhracat/export e-Fatura specifics on top of it.)
- **`loglama-sistemi.md`** — the full ISLEMLOG audit system: `Ortak/ULog.pas` helpers, the yearly `GENDEPO.LOG<yyyy>` tables + self-healing `ISLEMLOG` view, the `LOGCOZUM`/`LOGREFERANS` decode path behind the UInfo screen, and the delete→"Geri Al" undo. Read before touching audit logging (expands the summary in "Key patterns" below).
- **`belge-depolama.md`** — document/media storage: the three layers (business record → `IMAJ` metadata → content), the migration from `IMAJ.BELGE`/on-disk `.OBJ` to `GENDEPO.DOSYA` (FILESTREAM, hash-dedup), and `IMAJ.YERI` context codes. Read before touching attachments, images, or document content.

Key patterns to honor without re-deriving:

- **Central data module:** `Utablo.pas` (`TDataModule`) owns the `FDConnection`, all shared `FDQuery` instances, the `cxEditRepository1`, style repositories, and image lists. New queries/styles/icons typically go here, not in individual forms.
- **Frame factory:** `UFrameYoneticisi` / `UGentegreFrameYonetimi` instantiate frames dynamically. Tab structure is data-driven via `entegra_sekmeconfig.xml` (with `SekmeConfig.xml` / `*.backup*.xml` variants present).
- **Event bus:** Cross-module notification goes through `Ortak/UMultiCastEvent.pas`, not direct form references.
- **Wizards:** Multi-step business flows use the `JvWizard`-based pattern (`UFaturaWizard`, `UStokWizard`, `UProjeWizard`...).
- **ADO → FireDAC:** Legacy code uses `TADOQuery`/`TADOConnection`; new/modernized code uses `TFDQuery`/`TFDConnection`. The Python helpers in the parent folder (`convert_dfm.py`, `fix_dfm.py`, `fix_binary_dfm.py`) exist to assist this conversion on `.dfm` form files.
- **Server-side list SPs:** grid/list screens increasingly call `sp_Prog_<Modül>_Liste_Json2` (MSSQL, `GenUpdate/`) / `fn_prog_<modül>_liste_json2` (PG, `pg/schema/`) instead of embedding SQL in the DFM. `KULLANICI_ARAMA.MODUL` must be the real MODULID (not the tab number) — collisions silently cross-wire saved searches between lists.
- **ISLEMLOG audit logging:** Card/detail changes are audited into `GENDEPO.ISLEMLOG` via the central helpers in `Ortak/ULog.pas` (`LogKartEkle` / `LogKartDegisti` / `LogKartSil`, lower-level `LogKayitEkle` / `LogDiffKaydet` / `LogDetaylariSil`). Non-obvious rules: the **insert** log is written once when the form/wizard closes (guarded by an `FEkleLogland` flag), *not* in `AfterPost` (that produces duplicates); **delete** logging must run *before* the SQL `DELETE`; on wizard finish, `Cancel` the card dataset if it isn't `Modified` instead of posting (AutoEdit otherwise logs an empty "change"). Follow the existing pattern in an already-logged module when adding logging to a new one.

## PostgreSQL migration (dual-engine discipline)

An in-progress effort ports the app from SQL Server to PostgreSQL. It is **isolated** to the `pg/` folder and the `pg-migration` branch; customer/release builds ship from stable `backup/…` branches and nothing in `pg/` reaches production. See `postgres-gecis-maliyeti.md` (cost/inventory) and `pg/README.md` (workspace + golden rules). This shapes how *all* new code is written today:

- **Every change must work on both engines.** MSSQL always keeps working (dual-capable code); a customer can stay on or revert to MSSQL at any time. There is no big-bang cutover.
- **Prefer Pascal over SQL** for engine-divergent logic (e.g. `IncYear` instead of `DATEADD`), and portable ANSI (`AS`, `CAST`) in the SQL you do write. For genuine dialect gaps use the central `PgSqlCevir` (getdate/isnull) plus the per-call **seam helper** pattern (top/date) rather than duplicating queries.
- **Known dialect traps:** MSSQL `bit` maps to PG `smallint` (not `boolean`) — otherwise `= 1`/`= 0` comparisons break en masse. `TOP 1 <col>` static ports become `MAX(CAST(col AS int))` on bit columns. Static `DECLARE`/`SET @var` in DFM SQL is inlined via `PgDeclareCevir`. Large/gnarly queries are *not* hand-rewritten to be portable — keep an MSSQL-original TVF and a PG-native TVF, call once from the app, and compare.
- **No test suite → differential testing is the safety net:** run the same input on both engines and compare tables with `pg/tools/db_diff.ps1` (seed a PG copy from MSSQL with `pg/tools/seed_from_mssql.ps1`). PG string columns are deterministic (case-sensitive) collation in the pilot; `GLogins`/license-hash gate is disabled in the PG pilot and will be redesigned for real cutover.

### PG dev environment (local)

Docker Postgres 14 (`gentegre-pg`, `localhost:5433`, db `gentegre`, `postgres`/`FETAGEN`) plus Adminer on `localhost:8080`. The app's dev target is this local container, not the cloud host (`HETZNER_PG_KURULUM.md` covers the cloud/"ekspert" instance).

```powershell
Get-Content pg\schema\NN_x.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -U postgres -d gentegre
powershell -File pg\tools\seed_from_mssql.ps1 -Table DEPOLAR      # MSSQL -> PG same data
powershell -File pg\tools\db_diff.ps1 -Table DEPOLAR -Keys DEPOADI # compare engines
```

`pg/schema/` is numbered, apply-in-order SQL (`NN_fn_*.sql`) — ported functions/TVFs live here, one file per object. `pg/tools/` also has `schema_port*.ps1`, `seed_bulk.ps1`, `fix_pk_names.ps1`, and `resync_sequences.sql` (run after any MSSQL→PG seed, otherwise inserts fail with `duplicate key pk_…` because sequences lag the table max).

## Database schema changes

DB objects are **not** migrated by the build. `GenUpdate/` holds:

- `GenDepoKur1..9.sql` + `sql_ayaradi_doldur.sql` — one-time GENDEPO install.
- `GenDepoUpdateN.sql` — incremental updates (N currently up to 60). **New DB changes go into a new numbered file**, never by editing an already-shipped one.
- `sp_Prog_*.sql` / `sp_Grnt_*.sql` / `tbl_*.sql` — deployable stored-procedure and table definitions.

Customers receive updates through `UVersiyonGuncelle.pas`, which pulls command rows from the GenUpdate web service and runs those newer than `GENINI` section `Ops_GenelOpsiyon_VersiyonNo`. Each command is engine-tagged: `#pg` / `#PG` anywhere in its `ACIKLAMA` marks it a **PostgreSQL** command; untagged means MSSQL. Only commands matching the active engine run — the others are skipped (and logged) while the version number still advances, so a PG-only change must be tagged or it will execute against MSSQL. Mind the batch order inside a script: inserts that copy data must precede the `DROP` of their source.

Deploying Turkish-containing SQL with `sqlcmd` requires `-f 65001` (a UTF-8 BOM alone is not enough), and `sqlcmd -u` mangles Turkish when *reading* definitions back — verify with `NCHAR` literals instead.

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
- Commits are frequent whole-tree checkpoints, not curated changesets — messages like `LAZY snapshot: …`, `WIP restore point: …`, or `Backup snapshot`. Dated `backup/YYYYMMDD` branches (e.g. `backup/20260622`) are periodic safety copies, as are `master`, `remote-snapshot`, and `local-full-backup`. Development currently happens on the `pg-migration` branch (see the PostgreSQL section); **customer/release builds ship from stable `backup/…` branches, never from `pg-migration`**. Confirm with the user before switching branches.
