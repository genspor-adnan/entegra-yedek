import re
import os

def remove_components_from_dfm(dfm_path, components_to_remove, output_path):
    with open(dfm_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    remaining_content = []
    extracting = False
    object_depth = 0
    
    # Regex to identify object start: "  object Name: Type"
    obj_start_pattern = re.compile(r'^\s{2}object\s+([a-zA-Z0-9_]+):')
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        match = obj_start_pattern.match(line)
        if match and object_depth == 0:
            name = match.group(1)
            if name in components_to_remove:
                extracting = True
                object_depth = 1
                i += 1
                continue
        
        if extracting:
            if re.match(r'^\s*object\s+', line):
                object_depth += 1
            elif re.match(r'^\s*end\s*$', line) or re.match(r'^\s*end$', line):
                object_depth -= 1
            
            if object_depth == 0:
                extracting = False
        else:
            remaining_content.append(line)
            
        i += 1

    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(remaining_content)

def remove_components_from_pas(pas_path, components_to_remove, output_path):
    with open(pas_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    remaining_content = []
    
    # Regex for component declaration: "    Name: Type;"
    # We assume standard indentation
    decl_pattern = re.compile(r'^\s+([a-zA-Z0-9_]+)\s*:\s*[a-zA-Z0-9_]+;')
    
    for line in lines:
        match = decl_pattern.match(line)
        if match:
            name = match.group(1)
            if name in components_to_remove:
                continue # Skip this line
        
        remaining_content.append(line)
        
    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(remaining_content)

components = [
    "cxStilTanimlari",
    "cxEditRepository1",
    "cxEditRepository2",
    "cxStyleRepository3",
    "PngImageListTicari",
    "KlasorResimleri",
    "cxImageList1",
    "cxImageList2",
    # Add items inside repositories that were declared in PAS
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
]

remove_components_from_dfm('c:/Entegra/Entegra/Utablo.dfm', components, 'c:/Entegra/Entegra/Utablo.dfm')
remove_components_from_pas('c:/Entegra/Entegra/Utablo.pas', components, 'c:/Entegra/Entegra/Utablo.pas')
