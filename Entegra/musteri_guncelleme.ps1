# ============================================================================
# musteri_guncelleme.ps1 — bu surumun MUSTERI DB guncellemeleri (MSSQL)
#
# Ne yapar: asagidaki .sql dosyalarini SIRAYLA, tek tek calistirir ve sonucu
#   raporlar. Hepsi idempotent (tekrar calistirmak zararsiz).
#
# NEREDE CALISTIRILIR: musterinin ANA veritabaninda (GENDEPO/depo DB'sinde DEGIL).
#   GenDepoUpdate61 ana DB'den depo DB'sine synonym kurar; digerleri ana DB nesneleri.
#
# Kullanim:
#   powershell -ExecutionPolicy Bypass -File musteri_guncelleme.ps1 `
#     -Server "SUNUCU\ORNEK" -Database MUSTERIDB -User sa -Password ***
#   Windows kimlik dogrulamasi icin: -Trusted
#
# NOT: uygulama tarafi (Gentegre.exe) da yenilenmelidir. Bu surumde .res'e gomulu
#   SekmeConfig.xml degisti (kaldirilan spin'lerin OlayBagla satirlari) -> ESKI EXE
#   ile YENI DB uyumludur, ama YENI ozellikler (sayfali liste, adet kontrolu) exe ister.
# ============================================================================
param(
    [Parameter(Mandatory=$true)][string]$Server,
    [Parameter(Mandatory=$true)][string]$Database,
    [string]$User = "",
    [string]$Password = "",
    [switch]$Trusted,
    [switch]$SadeceKontrol   # hicbir sey calistirma, yalniz mevcut durumu raporla
)

$ErrorActionPreference = "Stop"
$kok = $PSScriptRoot

# --- Calistirilacaklar (SIRA ONEMLI) ---------------------------------------
$adimlar = @(
    @{ Ad = "Depo synonym onarimi (log ekrani bos sorunu)";        Dosya = "GenUpdate\GenDepoUpdate61.sql" },
    @{ Ad = "Cari/IK detay tablolari TABLOLAR kaydi (Geri Al)";    Dosya = "GenUpdate\GenDepoUpdate62.sql" },
    @{ Ad = "Stok adet kontrolu SP'leri (izlemli/izlemsiz)";       Dosya = "GenUpdate\GenDepoUpdate43.sql" },
    @{ Ad = "StokHizmetAra detay panelleri SP";                    Dosya = "GenUpdate\GenDepoUpdate45.sql" },
    @{ Ad = "Log/Info liste SP (UInfo sunucu-tarafi)";             Dosya = "GenUpdate\sp_Prog_Log_Liste_Json2.sql" },
    @{ Ad = "Fatura silme on-kontrolu (ayni gun cikis duzeltmesi)";Dosya = "GenUpdate\sp_Prog_Fatura_Silinebilir_Mi.sql" },
    @{ Ad = "Siparis silme on-kontrolu";                           Dosya = "GenUpdate\sp_Prog_Siparis_Silinebilir_Mi.sql" },
    @{ Ad = "Sayfali liste: Banka Kredileri SP (TopN)";            Dosya = "GenUpdate\sp_Prog_Banka_Liste_Json2.sql" },
    @{ Ad = "Sayfali liste: Cek SP (TopN)";                        Dosya = "GenUpdate\sp_Prog_Cek_Liste_Json2.sql" },
    @{ Ad = "Sayfali liste: Fisler SP (TopN)";                     Dosya = "GenUpdate\sp_Prog_Fisler_Liste_Json2.sql" },
    @{ Ad = "Sayfali liste: Kasalar SP (TopN)";                    Dosya = "GenUpdate\sp_Prog_Kasalar_Liste_Json2.sql" },
    @{ Ad = "Sayfali liste: Kredi Karti SP (TopN)";                Dosya = "GenUpdate\sp_Prog_KrediKarti_Liste_Json2.sql" },
    @{ Ad = "Sayfali liste: POS SP (TopN)";                        Dosya = "GenUpdate\sp_Prog_POS_Liste_Json2.sql" },
    @{ Ad = "Servis liste SP (musteriye ozel SERVIS_USER alanlari)";Dosya = "GenUpdate\sp_Prog_Servis_Liste_Json2.sql" },
    @{ Ad = "Fatura/Irsaliye liste SP (TopN=0 -> TAM liste)";      Dosya = "GenUpdate\sp_Prog_AlisSatis_IrsFatFisKons_Json2.sql" },
    @{ Ad = "Siparis liste SP (TopN=0 -> TAM liste)";              Dosya = "GenUpdate\sp_Prog_AlisSatis_Siparis_Json2.sql" },
    @{ Ad = "Servis listesi performans (index + SP yeniden yazim)"; Dosya = "GenUpdate\GenDepoUpdate64.sql" },
    @{ Ad = "Stok/Hizmet arama: seri no duzeltme + lot no";        Dosya = "GenUpdate\GenDepoUpdate63.sql" },
    @{ Ad = "Paket urun ekleme SP (DECLARE batch hatasi)";         Dosya = "GenUpdate\GenDepoUpdate65.sql" },
    # Karar destek raporlari: Turkce harf kaybi ('?' -> ODBC parametresi sanilip
    #   "COUNT field incorrect"), KDR_Disi kolonu/filtresi ve ASCII kolon adlari duzeltmesi.
    # KDR raporlari REHBER_USER.KDR_Disi kolonunu kullanir; bu KULLANICI EK ALAN tablosu
    #   her kurulumda BULUNMAZ -> "Invalid object name REHBER_USER" ile panel acilmaz.
    #   Bu betik tabloyu/kolonu garantiye alir. KDR betiklerinden ONCE calismali.
    @{ Ad = "REHBER_USER + KDR_Disi guvence";                      Dosya = "GenUpdate\rehber_user_kdr_disi.sql" },
    # Rapor ADLARI ASCII olmali: KDR kutucuklari Delphi BILESENIDIR (KDR_BORCLULAR...)
    #   ve kod raporu bilesen adiyla arar; ad Turkce ise kutucuk 0 gorunur, tiklaninca
    #   sagdaki grid bos gelir. Bu betik KDR rapor adlarini ASCII'ye cevirir.
    @{ Ad = "KDR rapor adlari ASCII";                              Dosya = "GenUpdate\kdr_rapor_adlari_ascii.sql" },
    @{ Ad = "KDR kokpit raporu (KDR_SONUC)";                       Dosya = "GenUpdate\KDR_SONUC.sql" },
    @{ Ad = "KDR Borclular raporu";                                Dosya = "GenUpdate\KDR_BORCLULAR.sql" },
    @{ Ad = "KDR Alacaklilar raporu";                              Dosya = "GenUpdate\KDR_ALACAKLILAR.sql" }
)

# --- sqlcmd ortak argumanlari ----------------------------------------------
#   -f 65001 : Turkce karakterli .sql dosyalari icin ZORUNLU (BOM yetmez)
#   -C       : self-signed sertifikaya guven (ODBC 18 varsayilani sifreli baglanti)
#   -b       : hata olursa sqlcmd hata kodu dondursun
function SqlArg {
    $a = @("-S", $Server, "-d", $Database, "-C", "-b", "-f", "65001")
    if ($Trusted) { $a += "-E" } else { $a += @("-U", $User, "-P", $Password) }
    return $a
}

function SqlCalistir([string]$dosyaYolu) {
    $cikti = & sqlcmd @(SqlArg) -i $dosyaYolu 2>&1
    return @{ Basarili = ($LASTEXITCODE -eq 0); Cikti = ($cikti -join "`n") }
}

function SqlSorgu([string]$sorgu) {
    # -Q ile COK SATIRLI sorgu gecmek kirilgan: icindeki '--' ile baslayan satirlar
    #   sqlcmd tarafindan arguman sanilabiliyor. Gecici dosya + -i her zaman guvenli.
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        $sorgu | Out-File -Encoding utf8 $tmp
        $cikti = & sqlcmd @(SqlArg) -h -1 -W -i $tmp 2>&1
        return ($cikti -join "`n")
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

Write-Host "=== Gentegre musteri guncelleme ===" -ForegroundColor Cyan
Write-Host "Sunucu : $Server"
Write-Host "Veritabani: $Database"
Write-Host ""

# --- Baglanti testi ---------------------------------------------------------
$test = SqlSorgu "SET NOCOUNT ON; SELECT DB_NAME()"
if ($LASTEXITCODE -ne 0) {
    Write-Host "BAGLANTI HATASI:" -ForegroundColor Red
    Write-Host $test
    exit 1
}
Write-Host "Baglanti TAMAM ($($test.Trim()))" -ForegroundColor Green
Write-Host ""

# --- Calistir ---------------------------------------------------------------
$hataSay = 0
$atlanan = 0
if (-not $SadeceKontrol) {
    foreach ($adim in $adimlar) {
        $yol = Join-Path $kok $adim.Dosya
        if (-not (Test-Path $yol)) {
            Write-Host ("ATLANDI  {0}  (dosya yok: {1})" -f $adim.Ad, $adim.Dosya) -ForegroundColor Yellow
            $atlanan++
            continue
        }
        $s = SqlCalistir $yol
        if ($s.Basarili) {
            Write-Host ("TAMAM    {0}" -f $adim.Ad) -ForegroundColor Green
        } else {
            Write-Host ("HATA     {0}" -f $adim.Ad) -ForegroundColor Red
            Write-Host ($s.Cikti) -ForegroundColor DarkRed
            $hataSay++
        }
    }
    Write-Host ""
}

# --- DEPO ADLANDIRMA KURALI (05.08.2026) -------------------------------------
# Depo veritabani adi <ANA_DB>_GENDEPO olmak ZORUNDA (ayni sunucuda birden fazla
#   Gentegre veritabani olabildigi icin ortak 'GENDEPO' adi yanlis depoya yazma riski
#   tasiyordu). Uygulama acilista denetler ve uymayan kurulumda HATA verir; bu yuzden
#   guncelleme sonrasi durumu burada da raporluyoruz.
Write-Host "--- Depo adlandirma kurali ---" -ForegroundColor Cyan
$depoKontrol = @"
SET NOCOUNT ON;
DECLARE @ana SYSNAME = DB_NAME();
DECLARE @beklenen SYSNAME = @ana + N'_GENDEPO';
DECLARE @mevcut NVARCHAR(200) = ISNULL((SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -24120), N'');
SELECT ANA_DB      = @ana,
       TANIMLI_DEPO = CASE WHEN @mevcut = N'' THEN N'(bos -> GENDEPO)' ELSE @mevcut END,
       OLMASI_GEREKEN = @beklenen,
       DEPO_VAR     = CASE WHEN DB_ID(@beklenen) IS NULL THEN N'YOK' ELSE N'VAR' END,
       SONUC        = CASE WHEN @mevcut = @beklenen AND DB_ID(@beklenen) IS NOT NULL
                           THEN N'UYGUN'
                           ELSE N'DUZELTILMELI -> depo_adlandirma_duzelt.ps1 -Onayla' END;
"@
Write-Host (SqlSorgu $depoKontrol)
Write-Host ""

# --- Son durum kontrolu -----------------------------------------------------
$kontrol = @"
SET NOCOUNT ON;
SELECT NESNE = v.ad,
       DURUM = CASE WHEN OBJECT_ID('dbo.' + v.ad, 'P') IS NOT NULL THEN 'VAR'
                    WHEN OBJECT_ID('dbo.' + v.ad)       IS NOT NULL THEN 'VAR'
                    ELSE 'YOK' END
FROM (VALUES
   ('sp_Prog_Log_Liste_Json2'), ('sp_Prog_Fatura_Silinebilir_Mi'),
   ('sp_Prog_Siparis_Silinebilir_Mi'), ('sp_Prog_Kontrol_Adet_Izlemsiz'),
   ('sp_Prog_Kontrol_Adet_Izlemli'), ('sp_Prog_StokHizmetAra_DetayPaneller'),
   ('sp_Prog_Banka_Liste_Json2'), ('sp_Prog_Cek_Liste_Json2'),
   ('sp_Prog_Fisler_Liste_Json2'), ('sp_Prog_Kasalar_Liste_Json2'),
   ('sp_Prog_KrediKarti_Liste_Json2'), ('sp_Prog_POS_Liste_Json2'),
   ('sp_Prog_Servis_Liste_Json2'), ('sp_Prog_AlisSatis_IrsFatFisKons_Json2'),
   ('sp_Prog_AlisSatis_Siparis_Json2')
) v(ad);

SELECT SYNONYM = v.ad,
       DURUM   = CASE WHEN OBJECT_ID('dbo.' + v.ad, 'SN') IS NULL THEN 'YOK'
                      WHEN OBJECT_ID('dbo.' + v.ad)       IS NULL THEN 'COZULMUYOR'
                      ELSE 'TAMAM' END
FROM (VALUES ('ISLEMLOG'), ('LOGREFERANS'), ('LOGCOZUM'), ('SNAPSHOT'),
             ('DOSYA'), ('EBELGE'), ('EBELGEMESAJ'), ('EBELGEKUYRUK')) v(ad);

-- Sayfali liste SP'leri TOP uretiyor mu (TopN gercekten uygulaniyor mu)?
-- Ayrica: TOP KOSULLU mu (TopN=0 "Tumunu Yukle" icin TOP hic uretilmemeli; kosulsuz
-- TOP (0) grid'i BOSALTIR) -> her SP'de '@TopN > 0' kontrolu bulunmali.
SELECT SP = o.name,
       TOPN_UYGULANIYOR = CASE WHEN m.definition LIKE '%TOP (%CAST(@TopN%' THEN 'EVET' ELSE 'HAYIR' END,
       TOPN0_TAM_LISTE  = CASE WHEN m.definition LIKE '%@TopN > 0%' THEN 'EVET' ELSE 'HAYIR' END
FROM sys.sql_modules m JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.name IN ('sp_Prog_Banka_Liste_Json2','sp_Prog_Cek_Liste_Json2','sp_Prog_Fisler_Liste_Json2',
                 'sp_Prog_Kasalar_Liste_Json2','sp_Prog_KrediKarti_Liste_Json2','sp_Prog_POS_Liste_Json2',
                 'sp_Prog_Servis_Liste_Json2','sp_Prog_AlisSatis_IrsFatFisKons_Json2',
                 'sp_Prog_AlisSatis_Siparis_Json2')
ORDER BY o.name;

-- Liste sayfa uzunlugu opsiyonu (bos ise uygulama 100 varsayar; kayit SART DEGIL)
SELECT LISTE_SAYFA_UZUNLUGU = ISNULL((SELECT TOP 1 CAST(DEGER AS varchar(20))
                                      FROM GENINI WHERE BOLUM = -10155), '(ayarlanmamis -> 100)');
"@
Write-Host "--- Son durum ---" -ForegroundColor Cyan
Write-Host (SqlSorgu $kontrol)

Write-Host ""
if ($hataSay -gt 0) {
    Write-Host "$hataSay adimda HATA olustu. Yukaridaki mesajlari inceleyin." -ForegroundColor Red
    exit 1
} elseif (-not $SadeceKontrol) {
    Write-Host "Tum adimlar TAMAM (atlanan: $atlanan)." -ForegroundColor Green
    Write-Host "Unutmayin: yeni Gentegre.exe de kurulmalidir." -ForegroundColor Yellow
}
