# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Two products in this repository

| Product | What it is | Stack | Lives in |
|---|---|---|---|
| **Gentegre / Entegra** | the shipping desktop ERP | Delphi VCL + MS SQL Server | this folder |
| **Gentegre AI** | the new web product — runs in **ERP** and **HBYS** (hospital information system) mode | .NET 10 API + React web, PostgreSQL only | `GentegreAI/` |

They share the repository and the domain rules, **not code**. An unqualified "the app" / "program" means the Delphi one; the web one is called "web" or "AI". Don't port a fix from one to the other unless asked — the same rule is expressed differently in each.

## Project (Delphi)

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
| `Ekranlar/` | HTML screen mockups — the design source for the Gentegre AI web UI, not Delphi forms |
| `GentegreAI/` | Separate PostgreSQL-only web product (.NET API + React web + its own migrations) — see its section below |

## Critical conventions

These are documented in detail in the companion docs — read them before non-trivial work:

- **`architecture.md`** — module map, dependency layers, tab/frame lifecycle, integration list.
- **`ui-guidelines.md`** — DevExpress component standards, colors, fonts (Trebuchet MS, `TURKISH_CHARSET`), skin (`London Liquid Sky`), `cxEditRepository1` items, image lists.
- **`error-handling.md`** — transaction pattern (`StartTransaction` / `try` / `Commit` / `except` / `Rollback if InTransaction` / `raise`), `Veritabani.VeriVarMi` / `BasitKomutCalistir` helpers, `Application.OnException` handler in `UKimlik.pas`, `ShowErrorDialog` from `UHataDialog`.
- **`ebelge-akis.md`** — GİB e-Belge (e-Fatura / e-Arşiv / e-İrsaliye) flow: encoding schemes (`FATBASLIK.TUR`, `REHBERALIAS.BELGETURU`/`EBELGE.BELGETURU` alias codes), the tables/constants and REST endpoints used, and the decision logic in `UFaturalar.MenuEFatura` / `UOpsiyonFatura` / `UEBelgeOlusturucu`. Read this before touching e-invoice code. (`IHRACAT_DAGITIM.md` covers the İhracat/export e-Fatura specifics on top of it.)
- **`loglama-sistemi.md`** — the full ISLEMLOG audit system: `Ortak/ULog.pas` helpers, the yearly `GENDEPO.LOG<yyyy>` tables + self-healing `ISLEMLOG` view, the `LOGCOZUM`/`LOGREFERANS` decode path behind the UInfo screen, and the delete→"Geri Al" undo. Read before touching audit logging (expands the summary in "Key patterns" below).
- **`Doc/PROJE_OZETI.md`** — Turkish whole-project summary distilled from all of the above; useful as a fast orientation read, but the topic docs are authoritative.
- **`belge-depolama.md`** — document/media storage: the three layers (business record → `IMAJ` metadata → content), the migration from `IMAJ.BELGE`/on-disk `.OBJ` to `GENDEPO.DOSYA` (FILESTREAM, hash-dedup), and `IMAJ.YERI` context codes. Read before touching attachments, images, or document content.

Key patterns to honor without re-deriving:

- **Central data module:** `Utablo.pas` (`TDataModule`) owns the `FDConnection`, all shared `FDQuery` instances, the `cxEditRepository1`, style repositories, and image lists. New queries/styles/icons typically go here, not in individual forms.
- **Ad-hoc SQL goes through `Veritabani` (`Ortak/FetaKurulusSiniflari.pas`) — do not hand-roll `TFDQuery` blocks.** Use `Veritabani.VeriVarMi(cnn, sql, ['&p'], [v])` for existence checks, `Veritabani.BasitKomutÇalıştır(cnn, sql, ['&p'], [v])` for `ExecSQL` (add `True` to return the first column), `Veritabani.SorguBaslat(...)` when you need the dataset, or `Tablo.TablodanSorguAc(n, sql)` for the shared `QueryN`. Parameters are `&ad` tokens substituted by `InitSql`. A create/try/finally/free block for a one-line query is a code-review smell. Reach for a raw `TFDQuery` only for blob streaming (`CreateBlobStream` / `LoadFromStream`) or long-lived datasets.
- **Frame factory:** `UFrameYoneticisi` / `UGentegreFrameYonetimi` instantiate frames dynamically. Tab structure is data-driven via `entegra_sekmeconfig.xml` (with `SekmeConfig.xml` / `*.backup*.xml` variants present).
- **Event bus:** Cross-module notification goes through `Ortak/UMultiCastEvent.pas`, not direct form references.
- **Wizards:** Multi-step business flows use the `JvWizard`-based pattern (`UFaturaWizard`, `UStokWizard`, `UProjeWizard`...).
- **ADO → FireDAC:** Legacy code uses `TADOQuery`/`TADOConnection`; new/modernized code uses `TFDQuery`/`TFDConnection`. The Python helpers in the parent folder (`convert_dfm.py`, `fix_dfm.py`, `fix_binary_dfm.py`) exist to assist this conversion on `.dfm` form files.
- **Server-side list SPs:** grid/list screens increasingly call `sp_Prog_<Modül>_Liste_Json2` (`GenUpdate/`) instead of embedding SQL in the DFM. `KULLANICI_ARAMA.MODUL` must be the real MODULID (not the tab number) — collisions silently cross-wire saved searches between lists. Two paging rules these SPs must honor: `TopN = 0` means **no TOP** (guard with `CASE WHEN @TopN > 0`; an unconditional `TOP (@TopN)` turns "Tümünü Yükle" into `TOP (0)` = empty grid), and **customers all run SQL Server Express** — a list query that needs a large memory grant (unconditional `DISTINCT` over wide rows, detail joins that are only needed for an optional filter) will sit in `RESOURCE_SEMAPHORE` forever and freeze the screen. Make the detail join and its `DISTINCT` conditional on the filter that needs them.
- **ISLEMLOG audit logging:** Card/detail changes are audited into `GENDEPO.ISLEMLOG` via the central helpers in `Ortak/ULog.pas` (`LogKartEkle` / `LogKartDegisti` / `LogKartSil`, lower-level `LogKayitEkle` / `LogDiffKaydet` / `LogDetaylariSil`). Non-obvious rules: the **insert** log is written once when the form/wizard closes (guarded by an `FEkleLogland` flag), *not* in `AfterPost` (that produces duplicates); **delete** logging must run *before* the SQL `DELETE`; on wizard finish, `Cancel` the card dataset if it isn't `Modified` instead of posting (AutoEdit otherwise logs an empty "change"). Follow the existing pattern in an already-logged module when adding logging to a new one.

## PostgreSQL port — dropped (Delphi is MSSQL-only)

**As of 14.09.2026 the PostgreSQL port of the Delphi app is abandoned** (user
decision: *"delphi için PG artık kullanılmayacak"*). The desktop ERP targets
**MS SQL Server only**.

What this means for new work:

- **Write plain T-SQL.** `TOP`, `ISNULL`, `CONVERT`, `DATEADD`, `bit` are all
  fine — no portability contortions, no dual-engine review.
- **One file per DB change:** `Update_SQL_<N>.sql`. **Do not write
  `Update_PG_<N>.sql`** and do not add `#pg`-tagged commands.
- **No new work in `pg/`** or on PG-specific helpers.
- **Existing PG plumbing stays in place.** `PgSqlCevir`, `PgDeclareCevir` and
  the seam helpers (`DbUst`, `DbSinir`, `DbConv`, `DbTarihEkle`…) are still
  called all over the code and produce correct MSSQL output — leaving them is
  safer than ripping them out. Keep using them where they already are; just
  don't reach for them in new code for portability reasons.
- The `pg/` folder, `postgres-gecis-maliyeti.md` and `pg/README.md` are kept as
  historical record. `pg/schema/` functions are not deployed anywhere.

This applies to the **Delphi app only**. `GentegreAI/` (the web product) is
**PostgreSQL-only** and unaffected — see its section below.

## Gentegre AI (separate web product, same repo)

`GentegreAI/` is the **second product** — a PostgreSQL-only web rewrite that covers both the ERP and, on the same schema, **HBYS** (hospital information system: patient registration, appointment, examination, lab, radiology, e-Nabız). ERP comes first; HBYS screens build on the same `taraf` / `belge` core, so a patient is a `taraf` with the `hasta` role flag, not a separate entity. It shares this repository but **not** the Delphi toolchain, and nothing in it links against the VCL app. Don't mix concerns: a change requested "in the app" is Delphi unless the user says web/AI.

- `api/` — ASP.NET Core (.NET 10) + Npgsql, three projects: `Gentegre.Cekirdek` (contract DTOs, permission model, **resource catalog + SQL generator**, no external deps), `Gentegre.Veri` (`NpgsqlDataSource` + repositories), `Gentegre.Api` (endpoints, JWT, error middleware).
- `web/` — React 19 + TypeScript + Vite. Consumes the server contract directly; **field names are identical on both sides, there is no translation layer**.
- `db/` — numbered, apply-in-order PG scripts (`NNN_*.sql`, currently ~545). Migrations are history and are **never edited**; when an object is defined in several files the **highest-numbered file is in force** — `db/GUNCEL.md` (generated by `araclar/guncel_indeks.ps1`) is the index that tells you which file that is. Read it before changing any `fn_*` / view.
- `dokuman/01_API_SOZLESMELERI.md` is the authoritative API contract (§ numbers are cited throughout the code); `dokuman/00_TARIHCE.md` is the change history.
- Each subfolder has its own `OKUBENI.md` with the full rule list — read the relevant one before working there.

```powershell
cd GentegreAI\api;  dotnet build;  dotnet run --project src\Gentegre.Api --urls http://localhost:5180
cd GentegreAI\web;  npm install;   npm run dev      # http://localhost:5173 (VITE_API in .env)
cd GentegreAI\web;  npm run build                   # tsc -b + vite build
cd GentegreAI\api;  dotnet test tests\Gentegre.Testler            # xUnit; one class: --filter FullyQualifiedName~LabTestleri
powershell -ExecutionPolicy Bypass -File GentegreAI\db\kur.ps1   # create DB + apply all migrations + migrate from MSSQL
powershell -ExecutionPolicy Bypass -File GentegreAI\yayin\yayinla.ps1   # deploy to 46.36.201.170/ai
```

Dev DB is docker **`gentegre-pg18`** (port 5434, db `gentegre_ai`, ICU `tr-TR`). Dev login `admin` / `Gentegre!2026`.

**Tests (web product only — the Delphi app still has none).** `api/tests/Gentegre.Testler` is an xUnit project (~26 classes, mostly HBYS: lab, mikrobiyoloji, e-Nabız, ilaç/karekod, dağıtım, kalite kontrol). Two things about it are easy to get wrong:

- It is **not in `Gentegre.slnx`**, so `dotnet build` at `api/` does not build it. Run it by path: `dotnet test tests\Gentegre.Testler`.
- Most classes take `VeritabaniOlgusu`, which connects to `GENTEGRE_TEST_DB` or falls back to the local `gentegre-pg18`. **With no database reachable the tests silently return green** (each prints `[ATLANDI] <test>: …`). A passing run proves nothing until you check the output for `[ATLANDI]`. Tests create and delete their own rows; they must not touch shared data.

Non-obvious rules that shape most changes here:

- **List/card metadata comes from the server** — columns, labels, groups, required-ness, max length, row colour, and the action catalogue. The client renders what it is given and writes no business rules; an unauthorized column/field is never returned at all, so there is no client-side hiding.
- **List SQL is generated from a whitelist** (`KaynakKatalogu`): no request text ever reaches SQL, values are always parameters. Unknown field → `400 DOGRULAMA`, unknown resource → `404`.
- **Permissions are resolved per request** from `fn_kullanici_yetkileri`, never baked into the token; branch (`sube`) filtering is applied server-side and the active branch is stamped on every write and log row.
- **Money math lives in one place.** Line totals follow the Delphi formula exactly (`BelgeHesap.cs`: round `adet*fiyat` **first**, discounts after, two discounts multiplicative, banker's rounding) and document totals always come from `fn_belge_diptoplam`. Never recompute a total in the client or in a second server path.
- **Optimistic concurrency uses PG `xmin`** as the `surum` stamp (no version column); a mismatched update returns 409 plus the current row.
- **Audit rules are ported from Delphi `ULog.pas`** — delete log written *before* the DELETE with the full row, change log field-by-field with no row when nothing changed, values written culture-invariantly.
- **`mantik` (boolean) columns are `smallint`** (carried over from the Delphi schema).
- Design language: `web/src/tema.css` is derived from the HTML mockups in `Ekranlar/` — match a mockup rather than inventing layout.

## Database schema changes

DB objects are **not** migrated by the build. `GenUpdate/` holds:

- `GenDepoKur1..9.sql` + `sql_ayaradi_doldur.sql` — one-time GENDEPO install.
- `Update_SQL_<N>.sql` — incremental updates, **current naming** (N currently up to 188; files numbered up to 169 use the older `GenDepoUpdateN.sql` name — do not add new ones with that name). One logical change = one numbered file. (`Update_PG_<N>.sql` files exist from the abandoned PG port; do not add new ones.)
- **Every DB change — schema, stored procedure, trigger, or a one-off data repair — goes into a NEW numbered file**, never by editing an already-shipped one and never as an ad-hoc script run only on one machine. Assume the script will be run on a customer database: make it idempotent, back up rows before touching them, report what it will change, and restrict a data repair to rows that are *provably* wrong — never blanket-overwrite a column that a customer may have configured deliberately.
- `sp_Prog_*.sql` / `sp_Grnt_*.sql` / `tbl_*.sql` — deployable stored-procedure and table definitions.

Customers receive updates through `UVersiyonGuncelle.pas`, which pulls command rows from the GenUpdate web service and runs those newer than `GENINI` section `Ops_GenelOpsiyon_VersiyonNo`. (The engine tag left from the PG port still works: `#pg` / `#PG` in a command's `ACIKLAMA` marks it PostgreSQL-only and it is skipped on MSSQL. New commands are untagged.) Mind the batch order inside a script: inserts that copy data must precede the `DROP` of their source.

Deploying Turkish-containing SQL with `sqlcmd` requires `-f 65001` (a UTF-8 BOM alone is not enough), and `sqlcmd -u` mangles Turkish when *reading* definitions back — verify with `NCHAR` literals instead.

## Tooling in this folder

- `build.bat` — primary build entry point.
- `sql_calistir.ps1` + `sql_calistir.sql` — ad-hoc SQL runner against the local SQL Server, writes results to `sql_sonuc.txt`. Edit the `.sql` and re-run when you need to inspect DB state.
- `refactor_references.ps1`, `refactor_missing_item.ps1`, `rollback.ps1` — refactoring helpers for the central component registry / `Utablo` items.
- `tmp_query_*.ps1` — disposable experiments; safe to ignore. The `.claudeignore` excludes `tmp_*.ps1` from indexing.
- `.mcp.json` registers the **`mssql-bilim`** MCP server (`@executeautomation/database-server` against `localhost\SQLEXPRESS` / `BILIM`) — use it, or plain `sqlcmd`, for read-only DB inspection on the dev machine. ODBC Driver 18 rejects the self-signed cert, so `sqlcmd` needs `-C` (trust cert). GENDEPO is reached from `BILIM` through the `ISLEMLOG` / `LOGCOZUM` / `SNAPSHOT` synonyms (physical DB is `BILIM_GENDEPO`; `sa` cannot open it directly).

`.claudeignore` also excludes build artifacts (`*.dcu`, `*.exe`, `*.dll`, `*.bpl`, `*.res`, `*.map`, `*.identcache`, …), media (`*.bmp`, `*.png`, `*.jpg`, `*.wav`, `*.pdf`, `*.doc`, `*.xls`), the `3dparty/` vendored libraries, and archive backups (`*.rar`, `*.zip`). Don't try to read these blobs; if a `.dfm` reads as binary, it starts with `TPF0` — convert it with `../convert_dfm.py` before editing.

## Editing notes

- **Don't create documentation files** (`*.md`, summaries, reports) unless the user asks for them.
- `AGENTS.md` is a near-verbatim copy of this file for Codex; `.cursor/rules/entegra-ana-dizin-erisim.mdc` grants standing read/edit permission over this folder (destructive/bulk git operations still need explicit consent). When a convention here changes, mirror it into `AGENTS.md`.
- `.pas` and `.dfm` files come as a pair — keep component names/types in sync between them. DFMs may be text or binary; the binary form is rare but possible.
- `Utablo.dfm` is multi-megabyte (the central data module). Read specific offsets, do not dump the whole file.
- Default code-page assumptions in legacy units are Windows-1254 (Turkish). Modern files are UTF-8; PowerShell helpers write UTF-8 explicitly.
- Commits are frequent whole-tree checkpoints, not curated changesets — messages like `LAZY snapshot: …`, `WIP restore point: …`, or `Backup snapshot`. Dated `backup/YYYYMMDD` branches (e.g. `backup/20260622`) are periodic safety copies, as are `master`, `remote-snapshot`, and `local-full-backup`. Development currently happens on the `pg-migration` branch (the name is a leftover — the PG port is dropped, see above); **customer/release builds ship from stable `backup/…` branches, never from `pg-migration`**. Confirm with the user before switching branches.

