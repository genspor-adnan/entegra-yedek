# Entegra - UI Tasarim Rehberi

## Tema ve Gorunum

- **Varsayilan Tema:** London Liquid Sky (`dxSkinLondonLiquidSky`)
- **Konfigurasyon:** `ENTEGRA.skincfg` / `Gentegre.skincfg`
- **Bilesen Kutuphanesi:** DevExpress (cxControls)

---

## Tipografi

| Kullanim | Font | Height | Stil |
|----------|------|--------|------|
| Genel (varsayilan) | Trebuchet MS | -11 | [] |
| Basliklar | Trebuchet MS | -16 | [fsBold] |
| Tiklanan etiketler | Trebuchet MS | -11 | [fsUnderline], clNavy |
| Devre disi metin | Trebuchet MS | -11 | [], clSilver |
| Dialog pencereleri | Verdana | -11 ~ -13 | degisken |
| Bilesen stilleri | Trebuchet MS | -13 | [] |

- **Karakter seti:** `TURKISH_CHARSET` (tum formlarda)

---

## Renk Paleti

| Renk | Kullanim |
|------|----------|
| `clBtnFace` | Form arka plani (varsayilan) |
| `clWhite` | Panel, frame ve icerik alani arka planlari |
| `clWindowText` | Standart metin rengi |
| `clNavy` | Tiklanan/link etiketleri (fsUnderline ile) |
| `clRed` | Uyarilar, onemli bilgiler, vurgulanan metin |
| `clSilver` | Devre disi / soluk metin |
| `clBlack` | Koyu gradyan, buton arka planlari |
| `clMenu` | Dialog arka planlari |
| `16744576` | Bildirim formu arka plani (turuncu) |

**Gradyan Butonlar:**
```
ColorFrom = 10395294
ColorTo = clBlack
ButtonHotColorFrom = 14256961
ButtonHotColorTo = 11694645
```

---

## Yerlestirme Kurallari

### Genel Kurallar
- **Arka plan:** Icerik alanlari `clWhite`, formlar `clBtnFace`
- **Kenar:** `BevelOuter = bvNone` (panellerde)
- **Bosluk:** `AlignWithMargins = True` ile `Left=3, Top=3, Right=0, Bottom=0`
- **Ayirici:** `cxSplitter`, `Width = 8`, `HotZoneClassName = 'TcxMediaPlayer8Style'`

### Ana Frame Yapisi (UGenelAnaSekmeFrame)
```
Ana Frame (alClient, clWhite)
├── Sol Panel (alLeft, Width=209, clWhite)
│   ├── pnlGorev (alTop, Height=145) — Gorev paneli
│   ├── cxSplitter (Width=8, salTop)
│   └── cxGroupBox "Arama" (alClient) — Arama frameleri
└── Sag Panel (alClient)
    ├── pcIcerik (cxPageControl, alClient) — Icerik frameleri
    └── cxSplitter (Width=8, salLeft)
```

### Dialog/Wizard Yapisi
```
Form (clBtnFace, Trebuchet MS -11)
└── TJvWizard (alClient)
    ├── TJvWizardWelcomePage (Color=11776947)
    │   ├── cxLabel (etiketler)
    │   ├── cxDBTextEdit (giris alanlari)
    │   └── cxDBImageComboBox (acilir listeler)
    └── Buton Cubugu [Geri, Ileri, Bitir, Iptal]
```

### Grid Yerlestirme Yapisi
```
Frame (alClient)
├── Ust Panel — Butonlar (Kaydet, Yeni, Sil, Yazdir...)
├── Ana Panel (alClient, AlignWithMargins)
│   ├── cxGrid (alLeft, Width=250)
│   ├── cxSplitter (Width=8)
│   └── GridPanel (alClient) — Form detaylari
└── DataSource + Query bilesenleri
```

### Arama Frame Yapisi
```
Frame (alClient, clWhite, Trebuchet MS -12)
├── cxLabel (etiketler, Style.Font ile)
├── cxTextEdit (Width=115)
├── cxImageComboBox (RepositoryItem tabanli)
├── cxCheckBox
└── cxSpinEdit (satir limiti icin)
```

---

## DevExpress Bilesen Standartlari

### cxGrid
```delphi
LookAndFeel.Kind = lfUltraFlat
LookAndFeel.NativeStyle = False

// Gorunum ayarlari
OptionsView.GroupByBox = False
OptionsBehavior.ImmediateEditor = False
OptionsData.DeletingConfirmation = True

// Ozet satirlari
DataController.Summary.FooterSummaryItems = <>
DataController.Summary.DefaultGroupSummaryItems = <>
```

### cxPageControl
```delphi
Properties.CustomButtons.Buttons = <>
Properties.Options = [pcoAlwaysShowGoDialogButton, pcoGradient,
                      pcoGradientClientArea, pcoRedrawOnResize,
                      pcoUsePageColorForTab]
Properties.TabWidth = 95
LookAndFeel.NativeStyle = False
LookAndFeel.SkinName = 'Black'
```

### cxLabel
```delphi
Style.Font.Charset = TURKISH_CHARSET
Style.Font.Color = [renk]
Style.Font.Height = -11
Style.Font.Name = 'Trebuchet MS'
Style.IsFontAssigned = True
Transparent = True
```

### cxTextEdit / cxDBTextEdit
```delphi
Width = 115
Height = 21
DataBinding.DataField = 'ALAN_ADI'
DataBinding.DataSource = DataSourceAdi
```

### cxSplitter
```delphi
Width = 8
HotZoneClassName = 'TcxMediaPlayer8Style'  // veya 'TcxSimpleStyle'
AlignSplitter = salTop  // salBottom, salLeft, salRight
Control = [boyutlandirilan bilesen]
```

### cxImage
```delphi
Properties.FitMode = ifmProportionalStretch
Properties.GraphicClassName = 'TdxPNGImage'
Properties.GraphicTransparency = gtTransparent
```

---

## Edit Repository (Merkezi Bilesen Tanimlari)

Tum ortak bilesen tanimlari `Utablo.dfm` icindeki `cxEditRepository1` icerisinde tanimlidir:

| Repository Ogesi | Kullanim |
|-------------------|----------|
| TextItem | Duz metin alanlari |
| CurrencyItem | Para birimi alanlari |
| DateItem | Tarih alanlari |
| TimeItem | Saat alanlari |
| CheckBoxItem | Onay kutulari |
| ComboBoxItem | Acilir listeler |
| LookupComboBoxItem | Arama destekli listeler |
| MaskItem | Maskeli giris |
| MemoItem | Cok satirli metin |
| ProgressBar | Ilerleme cubugu |
| SpinEdit | Sayisal giris |
| TextPasswordItem | Sifre alanlari |

**Alan bazli ozel repository ogeleri (ornekler):**
- `repStokAnaBirim` — Stok birimleri
- `repServisTuru`, `repServisDurum` — Servis kodlari
- `repAktiviteTuru`, `repAktiviteOncelik` — Aktivite kodlari
- `repTeklifDurumu`, `repTeklifTuru` — Teklif kodlari
- `RepCurrencyGenel`, `RepCurrencyBF` — Para formatlari

---

## Ikon ve Gorsel Kullanimi

### ImageList Bilesenleri (Utablo icinde tanimli)
| ImageList | Aciklama |
|-----------|----------|
| `PNGImageList1` | Genel PNG ikonlari |
| `PNGImageList2` | Ek PNG ikonlari |
| `PngImageListTicari` | Ticari modul ikonlari |
| `ImgListGridResimleri` | Grid hucre ikonlari |
| `KlasorResimleri` | Klasor/dokuman ikonlari |
| `imgScheduler` | Takvim ikonlari |
| `ImagesEvrak` | Evrak modulu ikonlari |

### Kullanim Sablonu
```delphi
// Buton ikonu
Glyph.Images = Tablo.PNGImageList1
Glyph.ImageIndex = 5

// Grid/Tab ikonu
Properties.Images = Tablo.PNGImageList1
OptionsImage.ImageIndex = 3

// Menu ikonu
Images = Tablo.ImgListGridResimleri
```

- **Format:** PNG (seffaf arka plan)

---

## Bildirim ve Hata Mesajlari

### Hata Dialogu (UHataDialog)
```delphi
BorderStyle = bsDialog
BorderIcons = []
Color = clMenu
Font = Verdana -11
Position = poMainFormCenter
// Icerik: Hata ikonu (65x65) + mesaj + "Ayrinti Goster" + "Kapat"
```

### Bildirim Formu (UInfoForm)
```delphi
AlphaBlend = True          // Seffaflik efekti
FormStyle = fsStayOnTop    // Her zaman ustte
Color = 16744576           // Turuncu arka plan
BevelOuter = bvLowered
BevelWidth = 2
// Otomatik gizleme: 3000ms sonra kapanir
// Animasyon: 10ms aralikla seffaflik degisimi
```

### Onay Dialogu (UOnayDialog)
- Standart Evet/Hayir secimi
- Ikon destekli gorsel gosterim

### Mesaj Girdi Dialogu (Umesaj)
Dinamik kontrol turleri:
| Kod | Tur |
|-----|-----|
| E | TextEdit (metin girisi) |
| P | PasswordEdit (sifre) |
| C | ComboBox (acilir liste) |
| D | DateTimePicker (tarih) |
| R | RadioGroup (tek secim) |
| I | ImageComboBox (ikonlu liste) |

---

## Arac Cubugu ve Menu Standartlari

### Standart Butonlar
Yaygin kullanilan islem butonlari:
- **Kaydet** — Kaydi kaydetme
- **Listele** — Verileri listeleme
- **Yeni Kayit** — Yeni kayit olusturma
- **Sil** — Kayit silme
- **Detay** — Detay goruntuleme
- **Yazdir** — Baski/cikti alma

### Buton Boyutlari
```delphi
Width = 51
Height = 22 ~ 25
```

### Menu Yapisi
```delphi
// Ana menu
TMainMenu
  OwnerDraw = True
  Images = Tablo.ImgListGridResimleri

// Sag tik menusu
TPopupMenu
  Images = Tablo.PNGImageList1
  // Dinamik OnPopup olaylari ile doldurulur
```

---

## LookAndFeel Standartlari

### Genel Bilesen Gorunumu
```delphi
LookAndFeel.Kind = lfUltraFlat      // veya lfOffice11
LookAndFeel.NativeStyle = False      // veya True
LookAndFeel.SkinName = 'Black'       // veya 'LondonLiquidSky', ''
```

### Durum Bazli Stiller
```delphi
Style.LookAndFeel.Kind = lfOffice11
StyleDisabled.LookAndFeel.Kind = lfOffice11
StyleFocused.LookAndFeel.Kind = lfOffice11
StyleHot.LookAndFeel.Kind = lfOffice11
```

### Grid Kosullu Bicimlendirme
`TStilKosul` sinifi ile kosullu stiller tanimlanir:
- `AlanAdi` — Kosulun uygulanacagi alan
- `Tur` — Kosul turu
- `AltDeger`, `UstDeger` — Deger araligi
- `stil` — Uygulanan TcxStyle

`TGridStilYonetim` sinifi birden fazla kosulu yonetir.

---

## Stil Deposu (cxStyleRepository)

Merkezi stil tanimlari `Utablo` icinde:
- `cxStyleRepository1` — Ana stil deposu
- `cxstilTanimlari` — Ek stil tanimlari

Ornek stiller:
- `cxstSecili` — Secili satir stili
- `cxstFaturaKontrol` — Fatura kontrol vurgusu
- `cxTaksit` — Taksit satirlari icin stil
- `cxStyle1` ~ `cxStyle28` — Genel amacli stiller

---

## Konfigürasyon ile UI Yonetimi

Sekme yapisi ve frame atamalari `entegra_sekmeconfig.xml` ile yonetilir:
- Sekme tanimlari (Aksiyonlar, Cari, Kasa, Banka, Fatura, Stok...)
- Frame sinif atamalari (IcerikFrame, AramaFrame, GorevFrame)
- Olay baglantilari (`hedefBilesen`, `hedefOlay`, `kaynakMethod`)
- Ozellik eslestirmeleri
