# Seri kurallari tanisi
# Kullanim: powershell -ExecutionPolicy Bypass -File tani_seri.ps1
# Sonuc: tani_seri_sonuc.txt

$server = "DESKTOP-HL3J3AS\SQLEXPRESS"
$database = "BILIM"
$user = "sa"
$password = "FETAGEN"

$sqlFile = Join-Path $PSScriptRoot "tani_seri.sql"
$outFile = Join-Path $PSScriptRoot "tani_seri_sonuc.txt"

if (-not (Test-Path $sqlFile)) {
    "HATA: tani_seri.sql dosyasi bulunamadi!" | Out-File $outFile -Encoding UTF8
    exit
}

$sql = Get-Content $sqlFile -Raw -Encoding UTF8

try {
    $connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $sql
    $command.CommandTimeout = 30

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    [void]$adapter.Fill($dataset)

    $result = ""
    foreach ($table in $dataset.Tables) {
        $headers = ($table.Columns | ForEach-Object { $_.ColumnName }) -join "`t"
        $result += $headers + "`r`n"
        $result += ("-" * 100) + "`r`n"
        foreach ($row in $table.Rows) {
            $values = ($table.Columns | ForEach-Object { $row[$_.ColumnName] }) -join "`t"
            $result += $values + "`r`n"
        }
        $result += "`r`n"
    }

    if ($result -eq "") { $result = "Sorgu basarili (sonuc yok)" }
    $result | Out-File $outFile -Encoding UTF8

    $connection.Close()
}
catch {
    "HATA: $($_.Exception.Message)" | Out-File $outFile -Encoding UTF8
}

Write-Host "Sonuc: $outFile"
