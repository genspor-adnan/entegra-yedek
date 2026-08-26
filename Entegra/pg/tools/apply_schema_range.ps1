param(
  [int]$From = 1,
  [int]$To = 999,
  [string]$SchemaDir = (Join-Path $PSScriptRoot '..\schema'),
  [string]$Container = 'gentegre-pg',
  [string]$Database = 'gentegre',
  [string]$User = 'postgres'
)

$ErrorActionPreference = 'Stop'

# Windows PowerShell native-command pipe encoding is not UTF-8 by default.
# Turkish SQL literals such as "Hariç" can otherwise become "Hari?" in PG.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom

$resolvedSchemaDir = Resolve-Path -LiteralPath $SchemaDir

$files = Get-ChildItem -LiteralPath $resolvedSchemaDir -File |
  Where-Object {
    $_.Name -match '^([0-9]+)_' -and
    [int]$Matches[1] -ge $From -and
    [int]$Matches[1] -le $To
  } |
  Sort-Object { [int]($_.Name -replace '^([0-9]+).*', '$1') }, Name

if (-not $files) {
  Write-Host "No schema files found in range $From..$To under $resolvedSchemaDir"
  exit 0
}

foreach ($file in $files) {
  Write-Host "APPLY $($file.Name)"
  Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName |
    docker exec -i $Container psql -v ON_ERROR_STOP=1 -U $User -d $Database

  if ($LASTEXITCODE -ne 0) {
    throw "Failed applying $($file.FullName)"
  }
}

Write-Host "Applied clean count: $($files.Count)"
