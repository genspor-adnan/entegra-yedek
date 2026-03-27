import re

def clean_dfm_references():
    components_to_remove = [
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
        "RepSenaryo",
        "cxEditRepository1ImageComboBoxItem1"
    ]

    with open('c:/Entegra/Entegra/Utablo.dfm', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    removed_count = 0
    
    # Regex to find property assignments: "    PropName = ComponentName"
    # We look for " = ComponentName" at the end of the line (ignoring potential comments or trailing chars if any, though DFM is strict)
    
    for line in lines:
        stripped = line.strip()
        keep = True
        
        if "=" in stripped:
            parts = stripped.split("=")
            if len(parts) >= 2:
                value = parts[1].strip()
                # Value might be "ComponentName" or "ComponentName, ComponentName" (unlikely for simple props)
                # DFM values usually don't have quotes for component references
                
                if value in components_to_remove:
                    keep = False
                    removed_count += 1
                    # print(f"Removing reference: {line.strip()}")
        
        if keep:
            new_lines.append(line)

    with open('c:/Entegra/Entegra/Utablo.dfm', 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
        
    print(f"Removed {removed_count} invalid references from Utablo.dfm")

clean_dfm_references()
