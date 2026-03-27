$components = @(
    "cxEditRepository1ImageComboBoxItem1"
)

$files = Get-ChildItem -Path c:\Entegra\Entegra -Recurse -Include *.pas, *.dfm

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding Default
    $originalContent = $content
    $modified = $false

    foreach ($comp in $components) {
        $pattern = "Tablo\.$comp\b"
        if ($content -match $pattern) {
            $content = $content -replace $pattern, "Still.$comp"
            $modified = $true
        }
    }

    if ($modified) {
        if ($file.Extension -eq ".pas") {
            if ($content -notmatch "uses\s+[^;]*\bUStil\b") {
                if ($content -match "(uses\s+)") {
                     $content = $content -replace "(uses\s+)", "uses UStil, "
                }
            }
        }
        
        Set-Content -Path $file.FullName -Value $content -Encoding Default
        Write-Host "Updated: $($file.Name)"
    }
}
