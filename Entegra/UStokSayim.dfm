object StokSayimDlg: TStokSayimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Stok Say'#305'm'
  ClientHeight = 515
  ClientWidth = 1126
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object pnlSol: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 515
    Align = alLeft
    TabOrder = 0
    object grpFiltre: TGroupBox
      Left = 1
      Top = 1
      Width = 183
      Height = 67
      Align = alTop
      TabOrder = 0
      object Label1: TcxLabel
        Left = 0
        Top = 12
        Caption = 'Ba'#351'lama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label2: TcxLabel
        Left = 0
        Top = 42
        Caption = 'Biti'#351
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object dateBaslangic: TcxDateEdit
        Left = 55
        Top = 11
        Properties.OnCloseUp = dateBitisPropertiesCloseUp
        TabOrder = 1
        Width = 124
      end
      object dateBitis: TcxDateEdit
        Left = 55
        Top = 38
        Properties.OnCloseUp = dateBitisPropertiesCloseUp
        TabOrder = 2
        Width = 124
      end
    end
    object gridSayimListe: TcxGrid
      Left = 1
      Top = 68
      Width = 183
      Height = 446
      Align = alClient
      TabOrder = 1
      ExplicitHeight = 445
      object tvSayimListe: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dtsSayimTutanak
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.GroupByBox = False
        object clmSayimListeDepo: TcxGridDBColumn
          Caption = 'Depo'
          DataBinding.FieldName = 'SAYIMDEPO'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepStokTumDepolar
          Width = 101
        end
        object tvSayimListeColumn3: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'SAYIMTARIHI'
          DataBinding.IsNullValueType = True
          Width = 76
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = tvSayimListe
      end
    end
  end
  object pnlSag: TPanel
    Left = 185
    Top = 0
    Width = 941
    Height = 515
    Align = alClient
    TabOrder = 1
    object pnlSagUst: TPanel
      Left = 1
      Top = 25
      Width = 939
      Height = 104
      Align = alTop
      PopupMenu = pmSayimTutanak
      TabOrder = 0
      object lbSayimId: TDBText
        Left = 137
        Top = 7
        Width = 65
        Height = 17
        DataField = 'ID'
        DataSource = dtsSayimTutanak
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Label3: TcxLabel
        Left = 5
        Top = 5
        Caption = 'Say'#305'm No'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label4: TcxLabel
        Left = 5
        Top = 31
        Caption = 'Say'#305'm Deposu*'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label5: TcxLabel
        Left = 5
        Top = 56
        Caption = 'Say'#305'm Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label6: TcxLabel
        Left = 373
        Top = 28
        Caption = 'Say'#305'm Yapan'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 373
        Top = 79
        Caption = 'Say'#305'm Onaylayan'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cbSayimDepo: TcxDBImageComboBox
        Left = 137
        Top = 28
        RepositoryItem = Tablo.RepStokTumDepolar
        DataBinding.DataField = 'SAYIMDEPO'
        DataBinding.DataSource = dtsSayimTutanak
        Properties.Items = <
          item
            Description = 'aaaaaaaa'
            ImageIndex = 0
            Value = 1
          end>
        TabOrder = 1
        Width = 189
      end
      object dateSayimTarih: TcxDBDateEdit
        Left = 137
        Top = 53
        DataBinding.DataField = 'SAYIMTARIHI'
        DataBinding.DataSource = dtsSayimTutanak
        TabOrder = 3
        Width = 79
      end
      object checkSayimTamamlandi: TcxDBCheckBox
        Left = 617
        Top = 74
        Caption = 'Say'#305'm Onay'
        DataBinding.DataField = 'SAYIMONAY'
        DataBinding.DataSource = dtsSayimTutanak
        ParentFont = False
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Properties.ValueChecked = 1
        Properties.ValueGrayed = 0
        Properties.ValueUnchecked = 0
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clPurple
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.TextColor = clRed
        Style.IsFontAssigned = True
        TabOrder = 13
        Transparent = True
      end
      object cbSayimYapan: TcxDBImageComboBox
        Left = 472
        Top = 26
        RepositoryItem = Tablo.repGenelPersonelListesi
        DataBinding.DataField = 'SAYIMYAPAN'
        DataBinding.DataSource = dtsSayimTutanak
        Properties.Items = <>
        TabOrder = 6
        Width = 139
      end
      object cbSayimOnaylayan: TcxDBImageComboBox
        Left = 472
        Top = 77
        RepositoryItem = Tablo.repGenelPersonelListesi
        DataBinding.DataField = 'SAYIMONAYLAYAN'
        DataBinding.DataSource = dtsSayimTutanak
        Properties.Items = <>
        TabOrder = 11
        Width = 139
      end
      object BtnTumStoklariEkle: TcxButton
        Tag = 4
        Left = 767
        Top = 3
        Width = 161
        Height = 25
        Caption = 'T'#252'm Stok Kartlar'#305'n'#305' Ekle'
        Colors.Default = clGreen
        Colors.DefaultText = clBlack
        Colors.Normal = clGreen
        Colors.NormalText = clGreen
        Colors.Hot = clGreen
        Colors.Pressed = clGreen
        Colors.Disabled = clGreen
        TabOrder = 8
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        OnClick = BtnTumStoklariEkleClick
      end
      object BtnTumKartlariSil: TcxButton
        Tag = 4
        Left = 767
        Top = 29
        Width = 161
        Height = 25
        Caption = 'T'#252'm Stok Kartlar'#305'n'#305' Sil'
        Colors.NormalText = clRed
        TabOrder = 10
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        OnClick = BtnTumKartlariSilClick
      end
      object cxLabel1: TcxLabel
        Left = 373
        Top = 54
        Caption = 'Fiyat Ad'#305'*'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cbFiyatAdi: TcxDBImageComboBox
        Left = 472
        Top = 52
        RepositoryItem = Tablo.RepFiyatAdlariAlis
        DataBinding.DataField = 'FIYATADI'
        DataBinding.DataSource = dtsSayimTutanak
        Properties.ImmediatePost = True
        Properties.Items = <>
        TabOrder = 9
        Width = 139
      end
      object cxImage1: TcxImage
        Left = 767
        Top = 78
        Picture.Data = {
          07544269746D61700E060000424D0E0600000000000036000000280000001600
          0000160000000100180000000000D8050000EF0A0000EF0A0000000000000000
          0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDFDADADAF1F1F1FCFC
          FCFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5C4C27D7D7B7777778E
          8E8EC3C3C3FBFBFB0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEAEAEC6A79ADADA9A6
          8B8B896D6D6D8A8A8AEDEDED0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9E9EB5B74CC206F
          FF8BB6DBEFE7DE8C8B8B7F7F7FDEDEDE0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE6E6E85872CC2B
          76FF54B3FF62CEFFA4CBE4B6B0A77A7A7AD9D9D90000FFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3E3E65570CE
          2D78FF56B4FF6AD2FF5CC0FF3488FE7786B7B2B1AEFBFBFB0000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC8C9CB4A64
          BC2E7BFF57B7FF69D1FF5CBDFF3B8EFF4069DFCBCDD5FFFFFFFFFFFF0000FFFF
          FFFFFFFFFFFFFFFFFFFFF6F6F6D9D9D9C1C1C1B9B9B9BFBFBFDBDBDBD5D5D48C
          8C963367C550B2FE6BD4FF5BBBFF398BFF4369DDD5D6DCFFFFFFFFFFFFFFFFFF
          0000FFFFFFFFFFFFFFFFFFD6D6D693949675777A6666676465666B6E72757677
          8283839D9A95B2B8B95EB0D753B8FF388AFF476CDAD6D7DCFFFFFFFFFFFFFFFF
          FFFFFFFF0000FFFFFFFFFFFFBBBCBC797B7E958D80BEAC8FD1BB95D1B997B8A7
          8B86827D54575CA0A0A1F5F1ECB1BBBE2F6DD44563CCD8D9DEFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFF0000FFFFFFC8C8C8858687C1AB89E2C088E1BD83DFBD86E1
          C08BE8C58FE7C591B0A08B797D81AFAFAFB1AEA782879CC5C5CAFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF0000ECECEC929496C4AF89E2C189DBBE89D9BD8A
          D9BC88DABB85DBBC8BE2C79AECC88FAFA08B53565B838384C9C8C6FEFEFEFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000B9BABBA89E8BE1C491DAC293DAC3
          94DBC395DBC191DABF8DDABA86DABB87E4C99CE7C694837F7A7A7A7AE7E7E7FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A8A8AAC6B28EE1C99BDB
          C89DDBC79EDCC89DDBC69ADBC497DAC091DABC87DDC192E9C897B2A1886E7174
          CACACAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A3A29ED0BE97
          E1CFA7DECFABDFD1B0DED0AADECCA4DDC99EDCC498DAC091DBBD8AE4C699CCB7
          966F6F72C4C4C4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A8A6
          A1D1C09BE5D9B9E6DBC1E1D8BBDFD5B6DFD2AEDECDA5DDC99EDAC396DABF8EE2
          C594CEB998727374CDCDCDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          0000B0AFB0CABE9DEDE5C9EAE4D1EAE7D5E5DFC8E0D7B8DFD3AFDDCBA3DCC699
          DBC193E6C794B7A88D7D7F81E3E3E3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFF0000D2D3D5B4AD98EDE7CBEFEDE2F5F6F3EDEADCE3DCC0E1D7B7DDCD
          A6DCC79CDBC293E4C898918A7F999A9CF9F9F9FFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFF0000F7F7F7AEACACD0CCB2F0EFDDF0F0E8EBEAD9E6E1C9E1
          D6B7DDCDA7DDC79DE4C995BFAC8F7A7C80DEDEDEFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFE9EAEBA7A6A1D1CFB8EEEBD4EEEAD4
          E7E0C5E3D5B2E3D1A8E2CB9CC4B290838486C1C1C1FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFEAEAEBAAAAA7B5B1
          9DCAC3A8D2C8A8D2C4A2C7B798A59D8C909194C8C9C9FFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFF3
          F3F4C6C7C8A9A9A9A3A19DA09E9AA1A1A3B2B2B4E8E8E8FFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
        Style.BorderColor = clWhite
        Style.BorderStyle = ebsNone
        Style.Edges = []
        TabOrder = 14
        Transparent = True
        Height = 23
        Width = 28
      end
      object EditAra: TcxTextEdit
        Left = 797
        Top = 78
        Style.Color = clAqua
        TabOrder = 15
        OnKeyUp = EditAraKeyUp
        Width = 131
      end
      object cxLabel2: TcxLabel
        Left = 5
        Top = 80
        Caption = 'Sat'#305#351' Durumu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboSatisDurumu: TcxDBImageComboBox
        Left = 137
        Top = 78
        DataBinding.DataField = 'SATISDURUMU'
        DataBinding.DataSource = dtsSayimTutanak
        Properties.Items = <
          item
            Description = 'Durdu / Sadece say'#305'm'
            ImageIndex = 0
            Value = False
          end
          item
            Description = 'Devam ediyor'
            Tag = 1
            Value = True
          end>
        TabOrder = 17
        Width = 188
      end
      object cxLabel3: TcxLabel
        Left = 219
        Top = 56
        Caption = 'Saati'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object pnlSayimAksiyon: TPanel
      Left = 1
      Top = 129
      Width = 939
      Height = 26
      Align = alTop
      TabOrder = 1
      ExplicitWidth = 935
      object ToolBar5: TToolBar
        Left = 1
        Top = 1
        Width = 937
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 107
        Caption = 'AletCubugu'
        Color = clTeal
        DockSite = True
        DrawingStyle = dsGradient
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        HotTrackColor = 65408
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        ExplicitWidth = 933
        object btnSayimKalemEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni Stok Kalemi'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = btnSayimKalemEkleClick
        end
        object btnSayimKalemSil: TToolButton
          Left = 107
          Top = 0
          Caption = 'Sat'#305'r Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = btnSayimKalemSilClick
        end
        object btnKalemKaydet: TToolButton
          Left = 214
          Top = 0
          Caption = 'Sat'#305'r'#305' Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = btnKalemKaydetClick
        end
        object btnKalemVazgec: TToolButton
          Left = 321
          Top = 0
          Caption = 'Sat'#305'r '#304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          OnClick = btnKalemVazgecClick
        end
        object YaziciYaz: TToolButton
          Left = 428
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 8
          ImageName = 'PngImage15'
        end
        object btnDosyadan: TToolButton
          Left = 535
          Top = 0
          Caption = 'Dosyadan'
          DropdownMenu = PopupDosyadan
          EnableDropdown = True
          ImageIndex = 12
          ImageName = 'PngImage12'
          Indeterminate = True
        end
      end
    end
    object gridSayimTutanak: TcxGrid
      Left = 1
      Top = 155
      Width = 939
      Height = 359
      Align = alClient
      TabOrder = 2
      ExplicitWidth = 935
      ExplicitHeight = 358
      object tvSayimTutanak: TcxGridDBTableView
        PopupMenu = PopupMenu1
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = tvSayimTutanakCanFocusRecord
        DataController.DataSource = dtsSayimKalemleri
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = '###,###,##0.00'
            Kind = skSum
            Column = clmSayimTutar
          end
          item
            Format = 'Say'#305' :  ######'
            Kind = skCount
            Column = clmSayimStokKod
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object tvSayimDEGISTIRMETARIHI: TcxGridDBColumn
          Caption = 'Zaman'
          DataBinding.FieldName = 'DEGISTIRMETARIHI'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxDateEditProperties'
          Properties.Kind = ckDateTime
        end
        object clmSayimStokKod: TcxGridDBColumn
          Caption = 'Stok Kodu'
          DataBinding.FieldName = 'KOD'
          DataBinding.IsNullValueType = True
          Options.Editing = False
        end
        object clmSayimStokAdi: TcxGridDBColumn
          Caption = 'Stok Ad'#305
          DataBinding.FieldName = 'AD'
          DataBinding.IsNullValueType = True
          Options.Editing = False
          Width = 231
        end
        object tvSayimTutanakBARKOD: TcxGridDBColumn
          Caption = 'Barkod'
          DataBinding.FieldName = 'BARKOD'
          DataBinding.IsNullValueType = True
          Options.Editing = False
          Width = 122
        end
        object clmSayimSistemMiktar: TcxGridDBColumn
          Caption = 'Sistemdeki Miktar'
          DataBinding.FieldName = 'SISTEMDEKIMIKTAR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00;-,0.00'
          Options.Editing = False
          Width = 95
        end
        object clmSayimSayimMiktar: TcxGridDBColumn
          Caption = 'Say'#305'm Miktar'#305
          DataBinding.FieldName = 'SAYIMMIKTAR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00;-,0.00'
          Width = 73
        end
        object tvSayimTutanakFARK: TcxGridDBColumn
          Caption = 'Fark'
          DataBinding.FieldName = 'FARK'
          DataBinding.IsNullValueType = True
          Styles.Content = Tablo.cxStSelected
        end
        object clmSayimBirimFiyat: TcxGridDBColumn
          Caption = 'Birim Fiyat'
          DataBinding.FieldName = 'BIRIMFIYAT'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.EditFormat = ',0.00;-,0.00'
        end
        object clmSayimTutar: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.EditFormat = ',0.00;-,0.00'
          Options.Editing = False
        end
        object clmSayimStokBirim: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.repStokAnaBirim
          Options.Editing = False
        end
        object tvSayimTutanakMARKA: TcxGridDBColumn
          Caption = 'Marka'
          DataBinding.FieldName = 'MARKA'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.repStokMarka
          Options.Editing = False
          Width = 74
        end
        object tvSayimTutanakGRUBU: TcxGridDBColumn
          Caption = 'Grubu'
          DataBinding.FieldName = 'GRUBU'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.repStokGrubu
          Options.Editing = False
          Width = 76
        end
      end
      object gridSayimTutanakLevel1: TcxGridLevel
        GridView = tvSayimTutanak
      end
    end
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 939
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 96
      Caption = 'AletCubugu'
      Color = clTeal
      DockSite = True
      DrawingStyle = dsGradient
      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
      EdgeInner = esLowered
      EdgeOuter = esNone
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 3
      Transparent = True
      ExplicitWidth = 935
      object YeniSayim: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni Say'#305'm'
        ImageIndex = 0
        ImageName = 'PngImage0'
        OnClick = YeniSayimClick
      end
      object SayimSil: TToolButton
        Left = 96
        Top = 0
        Caption = 'Say'#305'm'#305' Sil'
        ImageIndex = 1
        ImageName = 'PngImage1'
        OnClick = SayimSilClick
      end
      object SayimKaydet: TToolButton
        Left = 192
        Top = 0
        Caption = 'Say'#305'm'#305' Kaydet'
        ImageIndex = 2
        ImageName = 'PngImage2'
        OnClick = SayimKaydetClick
      end
      object SayimIptal: TToolButton
        Left = 288
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        ImageName = 'PngImage3'
        OnClick = SayimIptalClick
      end
    end
  end
  object cxDBTimeEdit1: TcxDBTimeEdit
    Left = 441
    Top = 80
    DataBinding.DataField = 'SAYIMTARIHI'
    DataBinding.DataSource = dtsSayimTutanak
    TabOrder = 2
    Width = 71
  end
  object TabSayTutanak: TFDQuery
    AfterOpen = TabSayTutanakAfterOpen
    BeforePost = TabSayTutanakBeforePost
    AfterPost = TabSayTutanakAfterPost
    BeforeDelete = TabSayTutanakBeforeDelete
    AfterScroll = TabSayTutanakAfterScroll
    OnNewRecord = TabSayTutanakNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM STOKSAYIM'
      'WHERE'
      '   SAYIMTARIHI BETWEEN :PBASTAR AND :PBITTAR'
      'ORDER BY SAYIMTARIHI DESC')
    Left = 463
    Top = 174
  end
  object dtsSayimTutanak: TDataSource
    DataSet = TabSayTutanak
    OnStateChange = dtsSayimTutanakStateChange
    Left = 466
    Top = 220
  end
  object tabSayimKalemleri: TFDQuery
    AutoCalcFields = False
    BeforePost = tabSayimKalemleriBeforePost
    AfterPost = tabSayimKalemleriAfterPost
    BeforeDelete = tabSayimKalemleriBeforeDelete
    OnNewRecord = tabSayimKalemleriNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from'
      '(SELECT SS.*,'
      'FARK = SS.SISTEMDEKIMIKTAR - SAYIMMIKTAR,'
      'AD =  (SELECT STOKADI FROM STOKLAR WHERE ID = SS.STOKID),'
      'KOD = (SELECT KOD FROM STOKLAR WHERE ID = SS.STOKID),'
      'MARKA = (SELECT MARKA FROM STOKLAR WHERE ID = SS.STOKID),'
      'GRUBU = (SELECT GRUBU FROM STOKLAR WHERE ID = SS.STOKID),'
      'BIRIM = (SELECT ANABIRIM FROM STOKLAR WHERE ID = SS.STOKID),'
      
        'BARKOD = (select top 1 SB.BARKOD from STOKBARKOD SB where SB.STO' +
        'KID=SS.STOKID order by SB.VARSAYILAN desc)'
      ''
      ''
      'FROM STOKSAYIMKALEMLERI SS  '
      'where SS.SAYIMID=:Sayimid'
      ') as zz'
      'where AD  like  :PAd'
      'or KOD like :PKod')
    Left = 568
    Top = 174
  end
  object dtsSayimKalemleri: TDataSource
    DataSet = tabSayimKalemleri
    OnStateChange = dtsSayimKalemleriStateChange
    Left = 569
    Top = 222
  end
  object pmSayimTutanak: TPopupMenu
    OnPopup = pmSayimTutanakPopup
    Left = 328
    Top = 245
    object mnStokDurumGuncelle: TMenuItem
      Caption = 'Deponun Say'#305'm Durumunu G'#252'ncelle'
      OnClick = mnStokDurumGuncelleClick
    end
  end
  object frxSayimKalemleri: TfrxDBDataset
    UserName = 'frxSayimKalemleri'
    CloseDataSource = False
    FieldAliases.Strings = (
      'SAYIMID=SAYIMID'
      'STOKID=STOKID'
      'SKT=SKT'
      'SISTEMDEKIMIKTAR=SISTEMDEKIMIKTAR'
      'SAYIMMIKTAR=SAYIMMIKTAR'
      'BIRIMFIYAT=BIRIMFIYAT'
      'TUTAR=TUTAR'
      'EKLEYEN=EKLEYEN'
      'EKLEMETARIHI=EKLEMETARIHI'
      'DEGISTIREN=DEGISTIREN'
      'DEGISTIRMETARIHI=DEGISTIRMETARIHI'
      'KOD=KOD'
      'ANABIRIM=ANABIRIM'
      'IZLEME=IZLEME'
      'AD=AD'
      'ID=ID'
      'KUR=KUR'
      'BARKOD=BARKOD'
      'MARKA=MARKA'
      'MODEL=MODEL'
      'GRUBU=GRUBU'
      'TIPI=TIPI')
    DataSource = dtsSayimKalemleri
    BCDToCurrency = False
    DataSetOptions = []
    Left = 568
    Top = 267
  end
  object PopupMenuYaz: TPopupMenu
    Left = 329
    Top = 193
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxSayimTutanak: TfrxDBDataset
    UserName = 'frxSayimTutanak'
    CloseDataSource = False
    DataSource = dtsSayimTutanak
    BCDToCurrency = False
    DataSetOptions = []
    Left = 462
    Top = 272
  end
  object PopupDosyadan: TPopupMenu
    Left = 328
    Top = 296
    object ExcelDosya1: TMenuItem
      Caption = 'Excel Dosya'
      OnClick = ExcelDosya1Click
    end
    object SaymCihaz1: TMenuItem
      Caption = 'Say'#305'm Cihaz'#305
      OnClick = SaymCihaz1Click
    end
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = '*.dat,*.txt,*.text'
    Filter = 'Dat|*.dat|Txt|*.txt|Text|*.text'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 252
    Top = 195
  end
  object PopupMenu1: TPopupMenu
    Left = 712
    Top = 200
    object TumKaytlarnSaymMiktarlarnSfrAtaMenu: TMenuItem
      Caption = 'T'#252'm Kay'#305'tlar'#305'n Say'#305'm Miktarlar'#305'n'#305' S'#305'f'#305'r Ata'
      OnClick = TumKaytlarnSaymMiktarlarnSfrAtaMenuClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object IzlemBilgisiDuzenleMenu: TMenuItem
      Caption = #304'zlem Bilgisi D'#252'zenle'
      OnClick = IzlemBilgisiDuzenleMenuClick
      Visible = False
    end
  end
end
