# =============================================================================
#  Ajanı tek dosya olarak üretir (geliştirici makinesinde):
#  powershell -ExecutionPolicy Bypass -File yayinla_ajan.ps1 [-Cikti ..\..\yayin\ajan]
#  Çıktı: GentegreAktarimAjani.exe (self-contained, .NET kurulumu gerekmez, ~86 MB)
#         + ajan.ornek.json + mssql_hazirla.sql + servis_kur.ps1 -> müşteriye bu klasör gider.
# =============================================================================
param([string]$Cikti = (Join-Path $PSScriptRoot "..\..\yayin\ajan"))
$ErrorActionPreference = "Stop"
$Proje = Join-Path $PSScriptRoot "..\Gentegre.Aktarim.Ajan\Gentegre.Aktarim.Ajan.csproj"
dotnet publish $Proje -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
  -p:IncludeNativeLibrariesForSelfExtract=true -p:DebugType=none -o $Cikti --nologo -v q
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item (Join-Path $PSScriptRoot "mssql_hazirla.sql"), (Join-Path $PSScriptRoot "servis_kur.ps1") $Cikti -Force
Get-ChildItem $Cikti | Format-Table Name, Length -AutoSize
