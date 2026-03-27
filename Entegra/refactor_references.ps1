$components = @(
    "cxStilTanimlari",
    "cxEditRepository1",
    "cxEditRepository2",
    "cxStyleRepository3",
    "PngImageListTicari",
    "KlasorResimleri",
    "cxImageList1",
    "cxImageList2",
    "cxEditRepository1BlobItem1",
    "cxEditRepository1ButtonItem1",
    "cxEditRepository1CalcItem1",
    "cxEditRepository1CheckBoxItem1",
    "cxEditRepository1CheckComboBox1",
    "cxEditRepository1CheckGroupItem1",
    "cxEditRepository1ColorComboBox1",
    "cxEditRepository1ComboBoxItem1",
    "cxEditRepository1CurrencyItem1",
    "cxEditRepository1DateItem1",
    "cxEditRepository1ExtLookupComboBoxItem1",
    "cxEditRepository1FontNameComboBox1",
    "cxEditRepository1HyperLinkItem1",
    "cxEditRepository1Label1",
    "cxEditRepository1LookupComboBoxItem1",
    "cxEditRepository1MaskItem1",
    "cxEditRepository1MemoItem1",
    "cxEditRepository1MRUItem1",
    "cxEditRepository1PopupItem1",
    "cxEditRepository1ProgressBar1",
    "cxEditRepository1RadioGroupItem1",
    "cxEditRepository1RichItem1",
    "cxEditRepository1ShellComboBoxItem1",
    "cxEditRepository1SpinItem1",
    "cxEditRepository1TextItem1",
    "cxEditRepository1TimeItem1",
    "cxEditRepository1TrackBar1",
    "cxEditRepository1TextPasswordItem",
    "cxEditRepository1ComboBoxItemKurlar",
    "repStokAnaBirim",
    "repServisTeslimSekli",
    "repServisTuru",
    "repServisDurum",
    "repServisUcreti",
    "repAktiviteTuru",
    "repAktiviteKonum",
    "repAktiviteOncelik",
    "repAktivitePuan",
    "repAktiviteDurum",
    "repAktiviteTipi",
    "repAktiviteKonu",
    "repTeklifBilgi",
    "repTeklifDurumu",
    "repTeklifTuru",
    "repTeklifTeslimSekli",
    "repTeklifOdeme",
    "repTeklifKonusu",
    "repTeklifKonusuimage",
    "repDemirbasAlimSekli",
    "repProjeTuru",
    "repProjeAsama",
    "repProjeDurum",
    "repProjeKonu",
    "repStokMarka",
    "repStokTipi",
    "repStokOzellik",
    "repStokGrubu",
    "repStokZamanBirimi",
    "repStokDurum",
    "repFirsatSonuc",
    "RepAktifPasif",
    "cxStyle2",
    "gridStil_1",
    "cxStyle17",
    "cxStyle19",
    "RepFatTipi",
    "RepIKCinsiyet",
    "RepCariSektor",
    "RepGorevAnimsatOnce",
    "RepGorevAnimsatSonra",
    "RepGorevDurum",
    "RepGorevTuru",
    "RepGorevSonKac",
    "RepBizimDepartman",
    "RepBizimGorev",
    "RepAdisyon",
    "repStokMarkaRakip",
    "Demirbas",
    "Demirbas_Marka",
    "RepIsKlasorListesi",
    "repGenelPersonelListesiHerkes",
    "RepCariDurum",
    "RepKrediTipi",
    "repUyariTurleri",
    "cxEditRepository1CheckBoxItem2",
    "RepKaliteDofKategori",
    "repSiparisDurumVerilen",
    "RepIKOgrenim",
    "RepKYDenetimDurum",
    "RepKYDenetimKategori",
    "RepKYDenetimTipi",
    "RepUretimTuru",
    "RepIKDiller",
    "RepGorevTuruDemirbas",
    "RepIKStatu",
    "RepBankaHareketTipi",
    "RepAtilacakListe",
    "RepStokUretimDepolar",
    "RepCariTemas",
    "RepFirsatAsama",
    "repFirsatDurum",
    "RepFirsatAplikasyon",
    "repFirsatTuru",
    "repFirsatOlasilik",
    "repFirsatKonu",
    "RepImhaGerekce",
    "RepKYSapmaOlayKategori",
    "RepKYSapmaOlayDurum",
    "cxEditRepository1ImageComboBoxItem2",
    "RepDokumanKategor",
    "RepSozlesmeSure",
    "repUretimEmirTuru",
    "repAnaKaynakTipi",
    "RepKaliteOlcuAleti",
    "RepLojistikTipi",
    "RepMedikalSinif",
    "RepFasonTipi",
    "cxEditRepo_GenParasal",
    "RepSenaryo"
)

$files = Get-ChildItem -Path c:\Entegra\Entegra -Recurse -Include *.pas, *.dfm

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding Default
    $originalContent = $content
    $modified = $false

    foreach ($comp in $components) {
        # Replace Tablo.Component with Still.Component
        # Use regex to ensure word boundary
        $pattern = "Tablo\.$comp\b"
        if ($content -match $pattern) {
            $content = $content -replace $pattern, "Still.$comp"
            $modified = $true
        }
    }

    if ($modified) {
        if ($file.Extension -eq ".pas") {
            # Add UStil to uses if not present
            if ($content -notmatch "uses\s+[^;]*\bUStil\b") {
                # Try to add to interface uses
                if ($content -match "(uses\s+)") {
                     $content = $content -replace "(uses\s+)", "uses UStil, "
                }
            }
        }
        
        Set-Content -Path $file.FullName -Value $content -Encoding Default
        Write-Host "Updated: $($file.Name)"
    }
}
