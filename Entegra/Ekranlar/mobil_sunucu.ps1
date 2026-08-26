param([int]$Port = 8080)

# Gentegre mockup - basit statik dosya sunucusu (Python yoksa yedek)
# Not: yerel IP uzerinden dinlemek icin bu dosyayi "Yonetici olarak calistir" gerekebilir.

$kok = Split-Path -Parent $MyInvocation.MyCommand.Path
$mime = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
  '.js'='application/javascript; charset=utf-8'; '.css'='text/css; charset=utf-8'
  '.json'='application/json; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg'
  '.jpeg'='image/jpeg'; '.gif'='image/gif'; '.svg'='image/svg+xml'; '.ico'='image/x-icon'
  '.pdf'='application/pdf'; '.zip'='application/zip'
}

$dinleyici = New-Object System.Net.HttpListener
foreach ($p in @("http://+:$Port/", "http://localhost:$Port/")) {
  try { $dinleyici.Prefixes.Clear(); $dinleyici.Prefixes.Add($p); $dinleyici.Start(); break }
  catch { }
}
if (-not $dinleyici.IsListening) {
  Write-Host "Sunucu baslatilamadi. Bu dosyayi Yonetici olarak calistirmayi dene." -ForegroundColor Red
  return
}

Write-Host "Sunucu calisiyor - klasor: $kok  port: $Port" -ForegroundColor Green
Write-Host "Durdurmak icin Ctrl+C" -ForegroundColor DarkGray

while ($dinleyici.IsListening) {
  try {
    $ctx = $dinleyici.GetContext()
    $yol = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($yol)) { $yol = 'gentegre_v5_fluent.html' }
    $tam = Join-Path $kok $yol

    if (Test-Path $tam -PathType Leaf) {
      $uzanti = [System.IO.Path]::GetExtension($tam).ToLower()
      $tur = $mime[$uzanti]; if (-not $tur) { $tur = 'application/octet-stream' }
      $veri = [System.IO.File]::ReadAllBytes($tam)
      $ctx.Response.ContentType = $tur
      $ctx.Response.ContentLength64 = $veri.Length
      $ctx.Response.OutputStream.Write($veri, 0, $veri.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - bulunamadi: $yol")
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.OutputStream.Close()
  } catch { }
}
