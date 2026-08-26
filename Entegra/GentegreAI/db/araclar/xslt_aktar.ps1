# ============================================================================
#  Gentegre AI — e-Belge XSLT sablonlarini BILIM'den aktar
#
#      powershell -File db\araclar\xslt_aktar.ps1
#      powershell -File db\araclar\xslt_aktar.ps1 -PgHost 46.36.201.170
#
#  NEDEN AYRI BETIK: sablonlar 106 KB - 1,3 MB (toplam ~3,7 MB). Migration'a
#  gomulseler depo sisirdi ve her yayinda tekrar tasinirlardi.
#
#  HEDEF (160): ayri tablo YOK - merkezi `dokuman` deposu.
#      kaynak='ebelge-xslt' · kaynak_id=belge turu · yon 1 gelen / 2 giden
#  Icerik `dokuman_icerik`e hash ile (dedup) yazilir.
#
#  TEKRAR CALISTIRILABILIR: eslesme (kaynak_id + yon + ad) uzerinden; ayni
#  sablon ikinci kez eklenmez, icerigi guncellenir.
#
#  KAYNAK: BILIM.dbo.DOKUMLER, GRUBU = 'XSLT'. RAPORID belge turu + yonu tek
#  sayida kodluyor; asagidaki tablo bunu ikiye ayirir.
# ============================================================================
param(
    [string]$MsSqlSunucu = 'DESKTOP-HL3J3AS\SQLEXPRESS',
    [string]$MsSqlDb     = 'BILIM',
    [string]$MsSqlKul    = 'sa',
    [string]$MsSqlSifre  = 'FETAGEN',
    [string]$PgKapsayici = 'gentegre-pg18',
    [string]$PgDb        = 'gentegre_ai',
    [string]$PgSifre     = 'FETAGEN'
)
$ErrorActionPreference = 'Stop'

# RAPORID -> (belge_turu, yon).  belge_turu: 1 e-Fatura · 2 e-Arsiv · 7 e-Irsaliye
#                                yon: 1 gelen · 2 giden
$Esleme = @{
     1 = @(1, 1);   2 = @(1, 2)      # e-Fatura  gelen / giden
    11 = @(2, 1);  12 = @(2, 2)      # e-Arsiv   gelen / giden
    51 = @(7, 1);  52 = @(7, 2)      # e-Irsaliye gelen / giden
}

# GENINI'de SECILI olan sablonlar (bunlar varsayilan isaretlenir).
#   -24107 e-Fatura gelen · -24076 e-Fatura giden
#   -24108 e-Arsiv gelen  · -24077 e-Arsiv giden
#   -24110 e-Irsaliye gelen · -24079 e-Irsaliye giden
$SecimKodlari = @(-24107, -24076, -24108, -24077, -24110, -24079)

function Yaz($m) { Write-Host "  $m" }

$cs = "Server=$MsSqlSunucu;Database=$MsSqlDb;User Id=$MsSqlKul;Password=$MsSqlSifre;TrustServerCertificate=True"
$con = New-Object System.Data.SqlClient.SqlConnection $cs
$con.Open()

# --- secili sablon kimlikleri ------------------------------------------------
$secili = New-Object System.Collections.Generic.HashSet[int]
$cmd = $con.CreateCommand()
$cmd.CommandText = "select DEGER from GENINI where BOLUM in ($($SecimKodlari -join ','))"
$rd = $cmd.ExecuteReader()
while ($rd.Read()) { $n = 0; if ([int]::TryParse($rd[0].ToString(), [ref]$n) -and $n -gt 0) { [void]$secili.Add($n) } }
$rd.Close()
Yaz "secili sablon: $($secili.Count)"

# --- sablonlar ---------------------------------------------------------------
$cmd.CommandText = @"
select ID, RAPORID, isnull(RAPORADI,'') as ADI, isnull(DURUM,1) as DURUM,
       cast(isnull(SQL,'') as nvarchar(max)) as ICERIK
  from DOKUMLER where GRUBU = 'XSLT' order by RAPORID, ID
"@
$rd = $cmd.ExecuteReader()
$kayitlar = New-Object System.Collections.Generic.List[object]
while ($rd.Read()) {
    $raporId = [int]$rd['RAPORID']
    if (-not $Esleme.ContainsKey($raporId)) { Yaz "atlandi: RAPORID=$raporId ($($rd['ADI']))"; continue }
    $kayitlar.Add([pscustomobject]@{
        Id      = [int]$rd['ID']
        Tur     = $Esleme[$raporId][0]
        Yon     = $Esleme[$raporId][1]
        Ad      = [string]$rd['ADI']
        Icerik  = [string]$rd['ICERIK']
        Durum   = if ([int]$rd['DURUM'] -eq 0) { 0 } else { 1 }   # 9 da kullanimda: aktif say
    })
}
$rd.Close(); $con.Close()
Yaz "sablon: $($kayitlar.Count)"

# --- PG'ye yaz ---------------------------------------------------------------
# Icerik SQL metnine gomulmez (MB'larca kacis karakteri): her sablon gecici bir
#   dosyaya yazilir, psql \copy ile ara tabloya alinir, oradan upsert edilir.
$gecici = Join-Path $env:TEMP "xslt_aktar_$(Get-Random)"
New-Item -ItemType Directory -Path $gecici -Force | Out-Null
try {
    $veri = Join-Path $gecici 'xslt.tsv'
    $yazici = New-Object IO.StreamWriter($veri, $false, [Text.UTF8Encoding]::new($false))
    foreach ($k in $kayitlar) {
        # TSV: sekme/satir sonu kacislari - \copy bunlari geri cozer.
        $ic = $k.Icerik -replace '\\', '\\\\' -replace "`t", '\t' -replace "`r", '\r' -replace "`n", '\n'
        $ad = $k.Ad -replace "`t", ' '
        $vars = if ($secili.Contains($k.Id)) { 1 } else { 0 }
        $yazici.WriteLine("$($k.Id)`t$($k.Tur)`t$($k.Yon)`t$ad`t$vars`t$($k.Durum)`t$ic")
    }
    $yazici.Close()

    $kapsayiciYol = "/tmp/xslt.tsv"
    docker cp $veri "${PgKapsayici}:$kapsayiciYol" | Out-Null

    $sql = @"
create temporary table gecici_xslt (
    kaynak_id2 integer, belge_turu2 smallint, yon2 smallint,
    ad2 varchar(200), varsayilan2 smallint, durum2 smallint, icerik2 text);
\copy gecici_xslt from '$kapsayiciYol' with (format text, delimiter E'	');

-- Icerik once merkezi depoya (hash ile dedup), sonra dokuman satiri.
insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
select encode(sha256(convert_to(g.icerik2, 'UTF8')), 'hex'),
       convert_to(g.icerik2, 'UTF8'), 'application/xslt+xml',
       octet_length(convert_to(g.icerik2, 'UTF8')), 1
  from gecici_xslt g
on conflict (hash) do nothing;

-- Ayni sablon (tur + yon + ad) varsa GUNCELLE, yoksa ekle.
update public.dokuman d
   set hash = encode(sha256(convert_to(g.icerik2, 'UTF8')), 'hex'),
       boyut = octet_length(convert_to(g.icerik2, 'UTF8')),
       varsayilan = g.varsayilan2, durum = g.durum2,
       degistirme_tarihi = now()::timestamp
  from gecici_xslt g
 where d.kaynak = 'ebelge-xslt' and d.kaynak_id = g.belge_turu2
   and d.yon = g.yon2 and d.ad = g.ad2;

insert into public.dokuman (kaynak, kaynak_id, ad, content_type, boyut, hash,
                            sira, varsayilan, yon, belge_turu, durum, sube_id, ekleyen)
select 'ebelge-xslt', g.belge_turu2, g.ad2, 'application/xslt+xml',
       octet_length(convert_to(g.icerik2, 'UTF8')),
       encode(sha256(convert_to(g.icerik2, 'UTF8')), 'hex'),
       0, g.varsayilan2, g.yon2,
       case g.belge_turu2 when 1 then 'e-Fatura' when 2 then 'e-Arşiv'
                          when 7 then 'e-İrsaliye' when 8 then 'e-SMM' else '' end,
       g.durum2, (select min(id) from public.sube), 0
  from gecici_xslt g
 where not exists (select 1 from public.dokuman d
                    where d.kaynak = 'ebelge-xslt' and d.kaynak_id = g.belge_turu2
                      and d.yon = g.yon2 and d.ad = g.ad2);

select belge_turu, yon, count(*) as sablon, sum(varsayilan) as varsayilan,
       sum(boyut) as toplam_boy
  from public.dokuman where kaynak = 'ebelge-xslt'
 group by belge_turu, yon order by belge_turu, yon;
"@
    $sqlDosya = Join-Path $gecici 'aktar.sql'
    [IO.File]::WriteAllText($sqlDosya, $sql, [Text.UTF8Encoding]::new($false))
    docker cp $sqlDosya "${PgKapsayici}:/tmp/aktar.sql" | Out-Null
    docker exec -e PGPASSWORD=$PgSifre $PgKapsayici psql -U postgres -d $PgDb -v ON_ERROR_STOP=1 -f /tmp/aktar.sql
    if ($LASTEXITCODE -ne 0) { throw 'PG aktarimi basarisiz' }
}
finally {
    Remove-Item $gecici -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "`nXSLT AKTARIMI TAMAM" -ForegroundColor Green
