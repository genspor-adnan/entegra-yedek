$files = Get-ChildItem -Path c:\Entegra\Entegra -Recurse -Include *.pas, *.dfm

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding Default
    $originalContent = $content
    $modified = $false

    # Replace Still. with Tablo.
    if ($content -match "Still\.") {
        $content = $content -replace "Still\.", "Tablo."
        $modified = $true
    }

    # Remove UStil from uses
    if ($file.Extension -eq ".pas") {
        if ($content -match "uses\s+UStil,\s+") {
            $content = $content -replace "uses\s+UStil,\s+", "uses "
            $modified = $true
        }
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding Default
        Write-Host "Reverted: $($file.Name)"
    }
}

Write-Host "Rollback complete"
