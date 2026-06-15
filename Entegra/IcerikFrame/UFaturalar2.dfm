object FaturalarDlg: TFaturalarDlg
  Left = 0
  Top = 0
  Width = 1231
  Height = 462
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1225
    Height = 46
    Margins.Bottom = 0
    ButtonHeight = 47
    ButtonWidth = 77
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
    Images = Tablo.PNGImageList1
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    Wrapable = False
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      DropdownMenu = PopupFatGiris
      ImageIndex = 7
      ImageName = 'PngImage6'
      Style = tbsTextButton
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 77
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Style = tbsTextButton
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 154
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 162
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = GridFatListeTviewDblClick
    end
    object ToolButton3: TToolButton
      Left = 239
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object BtnBelgeZarfi: TToolButton
      Left = 247
      Top = 0
      Caption = 'Belge Zarflar'#305
      ImageIndex = 42
      ImageName = 'PngImage42'
      Style = tbsTextButton
      OnClick = BtnBelgeZarfiClick
    end
    object BtnDonusum: TToolButton
      Left = 324
      Top = 0
      Caption = 'D'#246'n'#252#351#252'm'
      ImageIndex = 39
      ImageName = 'PngImage39'
      Style = tbsTextButton
      OnClick = BtnDonusumClick
    end
    object HizliGirisTus: TToolButton
      Left = 401
      Top = 0
      Caption = 'H'#305'zl'#305' Giri'#351
      ImageIndex = 42
      ImageName = 'PngImage42'
      Style = tbsTextButton
      OnClick = HizliGirisTusClick
    end
    object EFaturaAktarBtn: TToolButton
      Left = 478
      Top = 0
      Caption = 'EFatura Aktar'
      ImageIndex = 33
      ImageName = 'PngImage33'
      Style = tbsTextButton
    end
    object ToolButton2: TToolButton
      Left = 555
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 563
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object ToolButton4: TToolButton
      Left = 640
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
  end
  object GridFatListe: TcxGrid
    Left = 0
    Top = 49
    Width = 1231
    Height = 160
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    PopupMenu = pmBelgeDonustur
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridFatListeTview: TcxGridDBTableView
      OnDblClick = GridFatListeTviewDblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridFatListeTviewCanFocusRecord
      DataController.DataSource = DtsFatBaslik
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = GridFatListeTviewFATURA_MATRAHI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = GridFatListeTviewKDV_TUTARI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = GridFatListeTviewFATURA_TUTARI
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'FATURA_MATRAHI'
          Column = GridFatListeTviewFATURA_MATRAHI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'KDV_TUTARI'
          Column = GridFatListeTviewKDV_TUTARI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'FATURA_TUTARI'
          Column = GridFatListeTviewFATURA_TUTARI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridFatListeTviewDOVIZ_FATURA_MATRAHI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridFatListeTviewDOVIZ_KDV_TUTARI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridFatListeTviewDOVIZ_TUTARI
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'FATURA_MALIYETI_ORT'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          Column = GridFatListeTviewORTKAR
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.CellHints = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.Footer = True
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridFatListeTviewStylesGetContentStyle
      object GridFatListeTviewTUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Al'#305#351' '#304'rsaliyesi'
            ImageIndex = 0
            Value = 10
          end
          item
            Description = 'Al'#305#351' Faturas'#305
            ImageIndex = 0
            Value = 11
          end
          item
            Description = 'Al'#305#351' Fi'#351'i'
            Value = 12
          end
          item
            Description = 'Sat'#305#351' '#304'rsaliyesi'
            Value = 14
          end
          item
            Description = 'Sat'#305#351' Faturas'#305
            Value = 15
          end
          item
            Description = 'Sat'#305#351' Fi'#351'i'
            Value = 16
          end
          item
            Description = 'Alacak Tahakkuku'
            Value = 13
          end
          item
            Description = 'Bor'#231' Tahakkuku'
            Value = 17
          end
          item
            Description = 'Al'#305#351' Sipari'#351'i'
            Value = 9
          end
          item
            Description = 'Sat'#305#351' Sipari'#351'i'
            Value = 19
          end
          item
            Description = 'Gider Pusulas'#305
            Value = 8
          end
          item
            Description = 'Di'#287'er Giri'#351' Fi'#351'i'
            Value = 3
          end
          item
            Description = 'Di'#287'er '#199#305'k'#305#351' Fi'#351'i'
            Value = 4
          end
          item
            Description = 'Sat'#305'nalma'
            Value = 101
          end
          item
            Description = 'Sat'#305#351' Konsinyesi'
            Value = 119
          end
          item
            Description = 'Al'#305#351' Konsinyesi'
            Value = 109
          end>
      end
      object GridFatListeTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewPLAN: TcxGridDBColumn
        Caption = 'Plan'
        DataBinding.FieldName = 'ODEMEPLANI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Yok'
            ImageIndex = 0
            Value = False
          end
          item
            Description = 'Var'
            Value = True
          end>
        Width = 47
      end
      object GridFatListeTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Yap'#305'lmad'#305
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'K'#305'smi'
            Tag = 1
            Value = 1
          end
          item
            Description = #304'ptal'
            Tag = 6
            Value = 6
          end
          item
            Description = 'Tamam'
            Tag = 9
            Value = 9
          end>
      end
      object GridFatListeTviewFATURATARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'FATURATARIH'
        DataBinding.IsNullValueType = True
        Width = 91
      end
      object GridFatListeTviewFATURANO: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'FATURANO'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewDOSYANO: TcxGridDBColumn
        Caption = 'Cari Kod'
        DataBinding.FieldName = 'CARIKOD'
        DataBinding.IsNullValueType = True
        Width = 79
      end
      object GridFatListeTviewREHBERID: TcxGridDBColumn
        Caption = 'RehberId'
        DataBinding.FieldName = 'REHBERID'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewCARIAD: TcxGridDBColumn
        Caption = 'Cari '#220'nvan'
        DataBinding.FieldName = 'CARIAD'
        DataBinding.IsNullValueType = True
        Width = 180
      end
      object GridFatListeTviewBASLIK: TcxGridDBColumn
        Caption = 'Ba'#351'l'#305'k'
        DataBinding.FieldName = 'BASLIK'
        DataBinding.IsNullValueType = True
        Width = 200
      end
      object GridFatListeTviewFATURA_MATRAHI: TcxGridDBColumn
        Caption = 'Tutar(KDV Hari'#231')'
        DataBinding.FieldName = 'FATURA_MATRAHI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 91
      end
      object GridFatListeTviewKDV_TUTARI: TcxGridDBColumn
        Caption = 'KDV'
        DataBinding.FieldName = 'KDV_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        GroupSummaryAlignment = taRightJustify
        HeaderGlyphAlignmentHorz = taRightJustify
        Width = 58
      end
      object GridFatListeTviewFATURA_TUTARI: TcxGridDBColumn
        Caption = 'Tutar(KDV Dahil)'
        DataBinding.FieldName = 'FATURA_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        GroupSummaryAlignment = taRightJustify
        HeaderGlyphAlignmentHorz = taRightJustify
        Width = 88
      end
      object GridFatListeTviewKUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Width = 45
      end
      object GridFatListeTviewORTKAR: TcxGridDBColumn
        Caption = 'Kar Ort.'
        DataBinding.FieldName = 'ORTKAR'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 50
      end
      object GridFatListeTviewDOVIZ_FATURA_MATRAHI: TcxGridDBColumn
        Caption = 'D'#246'viz Tutar(KDV Hari'#231')'
        DataBinding.FieldName = 'DOVIZ_FATURA_MATRAHI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        GroupSummaryAlignment = taRightJustify
        HeaderGlyphAlignmentHorz = taRightJustify
        Width = 139
      end
      object GridFatListeTviewDOVIZ_KDV_TUTARI: TcxGridDBColumn
        Caption = 'D'#246'viz KDV'
        DataBinding.FieldName = 'DOVIZ_KDV_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        GroupSummaryAlignment = taRightJustify
        HeaderGlyphAlignmentHorz = taRightJustify
        Width = 73
      end
      object GridFatListeTviewDOVIZ_TUTARI: TcxGridDBColumn
        Caption = 'D'#246'viz Tutar(KDV Dahil)'
        DataBinding.FieldName = 'DOVIZ_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        GroupSummaryAlignment = taRightJustify
        HeaderGlyphAlignmentHorz = taRightJustify
        Width = 119
      end
      object GridFatListeTviewDOVIZ_CINSI: TcxGridDBColumn
        Caption = 'D'#246'viz Birimi'
        DataBinding.FieldName = 'DOVIZ_CINSI'
        DataBinding.IsNullValueType = True
        Width = 67
      end
      object GridFatListeTviewDOVIZKUR: TcxGridDBColumn
        Caption = 'D'#246'viz Kuru'
        DataBinding.FieldName = 'DOVIZKUR'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridFatListeTviewACIKLAMA: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 148
      end
      object GridFatListeTviewSATICIADI: TcxGridDBColumn
        Caption = 'Sat'#305'c'#305
        DataBinding.FieldName = 'SATICIADI'
        DataBinding.IsNullValueType = True
        Options.Editing = False
      end
      object GridFatListeTviewFATDURUM: TcxGridDBColumn
        Caption = #304'ade Durum'
        DataBinding.FieldName = 'FATDURUM'
        DataBinding.IsNullValueType = True
        Options.Editing = False
      end
      object GridFatListeTviewFATURASERI: TcxGridDBColumn
        Caption = 'Belge Seri'
        DataBinding.FieldName = 'FATURASERI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridFatListeTviewVADE: TcxGridDBColumn
        Caption = 'Vade'
        DataBinding.FieldName = 'VADE'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewVADETARIH: TcxGridDBColumn
        Caption = 'Vade Tarihi'
        DataBinding.FieldName = 'VADETARIH'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewDURUMNEREDEN: TcxGridDBColumn
        Caption = 'Kaynak'
        DataBinding.FieldName = 'DURUMNEREDEN'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxLabelProperties'
      end
      object GridFatListeTviewDURUMNEREYE: TcxGridDBColumn
        Caption = 'Hedef'
        DataBinding.FieldName = 'DURUMNEREYE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxLabelProperties'
      end
      object GridFatListeTviewTESLIMTARIHI: TcxGridDBColumn
        Caption = 'Teslim Tarihi'
        DataBinding.FieldName = 'TESLIMTARIHI'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewDETAYBOLUMU: TcxGridDBColumn
        Caption = 'Detay'
        DataBinding.FieldName = 'DETAYBOLUMU'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
      object GridFatListeTviewTIPI: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'TIPI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepFatTipi
      end
      object GridFatListeTviewSAYFASAY: TcxGridDBColumn
        Caption = 'Sayfa Say'#305's'#305
        DataBinding.FieldName = 'SAYFASAY'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridFatListeTviewFATURA_GON_TARIHI: TcxGridDBColumn
        Caption = 'G'#246'n. Tarihi'
        DataBinding.FieldName = 'FATURA_GON_TARIHI'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewOZELKOD2: TcxGridDBColumn
        Caption = #214'zel Kod2'
        DataBinding.FieldName = 'OZELKOD2'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewZARF: TcxGridDBColumn
        Caption = 'Zarf'
        DataBinding.FieldName = 'ZARF'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridFatListeTviewISEMRIDURUM: TcxGridDBColumn
        Caption = #304#351' Emri Durumu'
        DataBinding.FieldName = 'ISEMRIDURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepIsEmriDurum
      end
      object GridFatListeTviewYAZDIRILDI: TcxGridDBColumn
        Caption = 'Yazd'#305'rma'
        DataBinding.FieldName = 'YAZDIRILDI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Yazd'#305'r'#305'lmad'#305
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Yazd'#305'r'#305'ld'#305
            Value = 1
          end>
      end
      object GridFatListeTviewONAYLAYACAK: TcxGridDBColumn
        Caption = 'Onaylayacak'
        DataBinding.FieldName = 'ONAYLAYACAK'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repGenelPersonelListesi
      end
      object GridFatListeTviewONAYLAYAN: TcxGridDBColumn
        Caption = 'Onaylayan'
        DataBinding.FieldName = 'ONAYLAYAN'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repGenelPersonelListesi
      end
    end
    object GridFatListeLevel1: TcxGridLevel
      GridView = GridFatListeTview
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 217
    Width = 1231
    Height = 245
    Align = alBottom
    TabOrder = 4
    Properties.ActivePage = TabYorumMedya
    Properties.CustomButtons.Buttons = <>
    OnPageChanging = cxPageControl1PageChanging
    ClientRectBottom = 241
    ClientRectLeft = 4
    ClientRectRight = 1227
    ClientRectTop = 27
    object SheetDetay: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 0
      object Panel4: TPanel
        Left = 0
        Top = 103
        Width = 1223
        Height = 111
        Align = alBottom
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        DesignSize = (
          1223
          111)
        object GridFaturaToplam: TStringGrid
          Left = 25496
          Top = -3
          Width = 260
          Height = 118
          Anchors = []
          Color = clBtnFace
          ColCount = 3
          DefaultColWidth = 128
          DefaultRowHeight = 19
          FixedCols = 2
          RowCount = 6
          FixedRows = 0
          Font.Charset = TURKISH_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GridLineWidth = 0
          ParentFont = False
          ScrollBars = ssNone
          TabOrder = 0
        end
        object gridFatToplam: TcxGrid
          Left = 461
          Top = 1
          Width = 340
          Height = 109
          Align = alLeft
          BorderStyle = cxcbsNone
          TabOrder = 2
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object tvFatToplamlar: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dtsTOPLAMLAR
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideSelection = True
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            object tvFatToplamlarTUR: TcxGridDBColumn
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object tvFatToplamlarACIKLAMA: TcxGridDBColumn
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 150
            end
            object tvFatToplamlarDEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
            end
            object tvFatToplamlarKUR: TcxGridDBColumn
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
            end
            object tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZTUTARI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
            end
            object tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZ_KURU'
              DataBinding.IsNullValueType = True
            end
          end
          object gridFatToplamLevel1: TcxGridLevel
            GridView = tvFatToplamlar
          end
        end
        object Panel1: TPanel
          Left = 1
          Top = 1
          Width = 460
          Height = 109
          Align = alLeft
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object Label8: TcxLabel
            Left = 5
            Top = 5
            Caption = 'Notlar'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label10: TcxLabel
            Left = 5
            Top = 82
            Caption = 'D'#246'viz Tutar'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            Transparent = True
            Visible = False
          end
          object DOVIZ_TUTARI: TcxDBLabel
            Left = 97
            Top = 82
            DataBinding.DataField = 'DOVIZ_TUTARI'
            DataBinding.DataSource = DtsFatBaslik
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            Visible = False
            Height = 21
            Width = 52
          end
          object ComboDovizKur: TcxDBLabel
            Left = 164
            Top = 82
            DataBinding.DataField = 'DOVIZ_CINSI'
            DataBinding.DataSource = DtsFatBaslik
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            Visible = False
            Height = 21
            Width = 39
          end
          object cxDBMemo1: TcxDBMemo
            Left = 59
            Top = 4
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsFatBaslik
            ParentColor = True
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
            TabOrder = 0
            Height = 75
            Width = 383
          end
        end
      end
      object GridFat: TcxGrid
        Left = 0
        Top = 0
        Width = 1223
        Height = 103
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridFatDBTableView1: TcxGridDBTableView
          PopupMenu = pmBelgeDonustur
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridFatDBTableView1CanFocusRecord
          DataController.DataSource = DtsDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridFatDBTableView1TUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepFatDetayTur
            Width = 56
          end
          object GridFatDBTableView1TESLIMTARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIMTARIHI'
            DataBinding.IsNullValueType = True
            Width = 105
          end
          object GridFatDBTableView1URUNNO: TcxGridDBColumn
            Caption = #220'r'#252'n No'
            DataBinding.FieldName = 'URUNNO'
            DataBinding.IsNullValueType = True
          end
          object GridFatDBTableView1KOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 61
          end
          object GridFatDBTableView1AD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 141
          end
          object GridFatDBTableView1SATICIKODU: TcxGridDBColumn
            Caption = 'Personel'
            DataBinding.FieldName = 'SATICIKODU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
          end
          object GridFatDBTableView1ADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            Width = 37
          end
          object GridFatDBTableView1BIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 44
          end
          object GridFatDBTableView1BIRIMFIYAT: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Width = 92
          end
          object GridFatDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 79
          end
          object GridFatDBTableView1ISKONTO: TcxGridDBColumn
            Caption = #304'sk1'
            DataBinding.FieldName = 'ISKONTO'
            DataBinding.IsNullValueType = True
            Width = 28
          end
          object GridFatDBTableView1ISKONTO2: TcxGridDBColumn
            Caption = #304'sk2'
            DataBinding.FieldName = 'ISKONTO2'
            DataBinding.IsNullValueType = True
            Width = 28
          end
          object GridFatDBTableView1KDV: TcxGridDBColumn
            DataBinding.FieldName = 'KDV'
            DataBinding.IsNullValueType = True
            Width = 29
          end
          object GridFatDBTableView1MASRAFKOD: TcxGridDBColumn
            Caption = 'Masraf Kod'
            DataBinding.FieldName = 'MASRAFKOD'
            DataBinding.IsNullValueType = True
            Width = 91
          end
          object GridFatDBTableView1MASRAFAD: TcxGridDBColumn
            Caption = 'Gelir Ad'
            DataBinding.FieldName = 'MASRAFAD'
            DataBinding.IsNullValueType = True
            Width = 128
          end
          object GridFatDBTableView1PROJEKODU: TcxGridDBColumn
            Caption = 'Proje Kodu'
            DataBinding.FieldName = 'PROJEKODU'
            DataBinding.IsNullValueType = True
          end
          object GridFatDBTableView1KUR: TcxGridDBColumn
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object GridFatDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 102
          end
        end
        object GridFatLevel1: TcxGridLevel
          GridView = GridFatDBTableView1
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Caption = 'Yorum / Medya'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 151
        Width = 1223
        Height = 43
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 41
          Width = 1075
        end
        object BtnMesajGonder: TcxButton
          Left = 1076
          Top = 1
          Width = 84
          Height = 41
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 0
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 1160
          Top = 1
          Width = 62
          Height = 41
          Align = alRight
          DropDownMenu = YorumAtacMenu
          Kind = cxbkDropDown
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
        end
      end
      object labelFileName: TcxLabel
        Left = 0
        Top = 194
        ParentCustomHint = False
        Align = alBottom
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.Edges = [bLeft, bRight]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.Shadow = False
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taRightJustify
        Transparent = True
        Visible = False
        AnchorX = 1223
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1223
        Height = 151
        Align = alClient
        TabOrder = 2
        object GridYorumDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellDblClick = GridYorumDBCardView1CellDblClick
          DataController.DataSource = DtsYorum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 900
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          Styles.Content = Tablo.cxStyle6
          Styles.CardBorder = Tablo.cxStyle19
          object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 120
          end
          object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YAZAN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
          end
          object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ATAC'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFileExtensionList
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 25
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
            DataBinding.FieldName = 'DOKUMANAD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 300
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxMemoProperties'
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Styles.Content = Tablo.cxStyle12
            Styles.CategoryRow = Tablo.cxStyle4
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 209
    Width = 1231
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = cxPageControl1
  end
  object SQLExcel: TMemo
    Left = 755
    Top = 112
    Width = 465
    Height = 41
    Lines.Strings = (
      'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '
      #39'##EXCEL_SPID_%'#39')'
      'DROP TABLE ##EXCEL_SPID_'
      ''
      'CREATE TABLE ##EXCEL_SPID_('
      #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
      #9'[REHBERID] [int]  NULL,'
      #9'[BASLIK] [nvarchar](100) NULL,'
      #9'[ADRES] [nvarchar](150) NULL,'
      #9'[ILCE] [nvarchar](50) NULL,'
      #9'[IL] [nvarchar](50)  NULL,'
      #9'[VD] [nvarchar](50) NULL,'
      #9'[VNO] [nvarchar](50)  NULL,'
      #9'[BARKOD] [int]  NULL)')
    TabOrder = 2
    Visible = False
  end
  object FATBASLIK: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = FATBASLIKAfterOpen
    AfterScroll = FATBASLIKAfterScroll
    ParamData = <
      item
        Name = 'Par'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = 11
      end>
    SQL.Strings = (
      'select '
      #9'F.*, CARIKOD=R.KOD,CARIAD=R.FIRMA, '
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(FATURA_TUTARI,'#39'TL'#39',0)) '
      ''
      'from '
      #9'FATBASLIK F (NOLOCK) '
      #9'inner join REHBER R on R.ID = F.REHBERID'
      'where '
      #9'TUR <> 20 and TUR= :Par')
    Left = 195
    Top = 116
  end
  object DtsFatBaslik: TDataSource
    DataSet = FATBASLIK
    Left = 264
    Top = 119
  end
  object FATURA: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 84
      end>
    SQL.Strings = (
      'select * from ('
      ''
      'Select '
      #9'F.*, MASRAFKOD=MG.KOD,MASRAFAD=MG.AD,'
      
        '  AD = CASE WHEN F.TUR =0 THEN  (SELECT AD FROM MASRAFGELIR WHER' +
        'E ID = F.URUNID)  ELSE (SELECT STOKADI FROM STOKLAR WHERE ID = F' +
        '.URUNID ) END,'
      
        '  KOD = CASE WHEN F.TUR =0 THEN (SELECT KOD FROM MASRAFGELIR WHE' +
        'RE ID= F.URUNID ) ELSE (SELECT KOD FROM STOKLAR WHERE ID = F.URU' +
        'NID )   END,'
      
        ' URUNNO =  CASE WHEN F.TUR =1 THEN (SELECT URUNNO FROM STOKLAR W' +
        'HERE ID = F.URUNID ) ELSE  '#39#39'  END,  '
      
        ' PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJ' +
        'EID),'#39' '#39' as TESLIMTARIHI'
      'from '
      #9'FATURA F left outer join '
      #9'MASRAFGELIR MG on'
      #9#9'F.MASRAFID=MG.ID                                '
      'Where '
      #9'F.FATBASID = :Par'
      ')as asd'
      ' order by ID')
    Left = 191
    Top = 257
  end
  object DtsDetay: TDataSource
    DataSet = FATURA
    Left = 248
    Top = 262
  end
  object PopupMenuYaz: TPopupMenu
    Left = 326
    Top = 96
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
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = FATBASLIK
    BCDToCurrency = False
    DataSetOptions = []
    Left = 83
    Top = 182
  end
  object pmFatIslemler: TPopupMenu
    Left = 416
    Top = 104
    object mnIrsaliyeyeDonustur: TMenuItem
      Tag = 1
      Caption = 'Se'#231'ilenleri '#304'rsaliyeye D'#246'n'#252#351't'#252'r'
      OnClick = mnIrsaliyeyeDonusturClick
    end
    object mnFaturayaDonustur: TMenuItem
      Tag = 2
      Caption = 'Se'#231'ilenleri Faturaya D'#246'n'#252#351't'#252'r'
    end
  end
  object SIPARISDETAY: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'Par'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select * from ('
      ''
      'Select '
      'F.*, MASRAFKOD=MG.KOD,MASRAFAD=MG.AD,'
      
        'AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FROM STOKLAR WHERE' +
        ' ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = F.' +
        'URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM STOKLAR WHERE ID' +
        ' = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= F.URU' +
        'NID )  END,'
      
        'URUNNO =  CASE WHEN F.TUR =1 THEN (SELECT URUNNO FROM STOKLAR WH' +
        'ERE ID = F.URUNID ) ELSE  '#39#39'  END,'
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = F.BIRIM),'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJE' +
        'ID),'
      'EKIPMAN = E.AD,SERINO= ER.SERINO'
      'from'
      'SIPARISDETAY F '
      'left outer join MASRAFGELIR MG on F.MASRAFID=MG.ID'
      'LEFT OUTER JOIN EKIPMANREHBER ER ON ER.ID=F.EKIPMANID'
      'LEFT OUTER JOIN EKIPMANLAR E on E.ID=ER.EKIPMANID'
      'Where '
      ' F.SIPARISID = :Par'
      ')as asd'
      ' order by ID'
      '')
    Left = 315
    Top = 345
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TOPLAMLARAfterOpen
    ParamData = <
      item
        Name = 'PFATBASID'
        DataType = ftWideString
        Size = 1
        Value = '0'
      end>
    SQL.Strings = (
      'DECLARE @FATBASID INT'
      'SET @FATBASID = :PFATBASID'
      ''
      'EXEC SP_PRG_Siparis_DipToplami  @FATBASID')
    Left = 325
    Top = 143
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 403
    Top = 237
  end
  object pmBelgeDonustur: TPopupMenu
    OnPopup = pmBelgeDonusturPopup
    Left = 77
    Top = 102
    object SipariiniOlutur1: TMenuItem
      Tag = 9
      Caption = 'Sipari'#351'ini Olu'#351'tur'
      Visible = False
      OnClick = mnIrsaliyesiniOlusturClick
    end
    object mnIrsaliyesiniOlustur: TMenuItem
      Tag = 1
      Caption = #304'rsaliyesini Olu'#351'tur'
      OnClick = mnIrsaliyesiniOlusturClick
    end
    object mnFaturasiniOlustur: TMenuItem
      Tag = 2
      Caption = 'Faturas'#305'n'#305' Olu'#351'tur'
      OnClick = mnIrsaliyesiniOlusturClick
    end
    object mnSatisFisiniOlustur: TMenuItem
      Tag = 16
      Caption = 'Sat'#305#351' Fi'#351'ini Olu'#351'tur'
      OnClick = mnIrsaliyesiniOlusturClick
    end
    object KonsinyesiniOlusturMenu: TMenuItem
      Caption = 'Konsinyesini Olu'#351'tur'
      OnClick = mnIrsaliyesiniOlusturClick
    end
    object UretimFisiniOlutur: TMenuItem
      Tag = 4
      Caption = #220'retim Fi'#351'ini Olu'#351'tur'
      object rnOlarak1: TMenuItem
        Tag = 4
        Caption = #220'r'#252'n Olarak'
        OnClick = mnIrsaliyesiniOlusturClick
      end
      object Sae1: TMenuItem
        Tag = -4
        Caption = 'Sarf Olarak'
        OnClick = mnIrsaliyesiniOlusturClick
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Kopyala2: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala2Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object BelgeyiAc: TMenuItem
      Caption = 'Belgeyi A'#231
      OnClick = BelgeyiAcClick
    end
    object KaynakBelgeyiA1: TMenuItem
      Caption = 'Kaynak Belgeyi A'#231
      OnClick = KaynakBelgeyiA1Click
    end
    object HedefBelgeyiA1: TMenuItem
      Caption = 'Hedef Belgeyi A'#231
      OnClick = HedefBelgeyiA1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object IptalIsaretleMenu: TMenuItem
      Caption = #304'ptal '#304#351'aretle'
      OnClick = IptalIsaretleMenuClick
    end
    object N7: TMenuItem
      Caption = '-'
      Visible = False
    end
    object ExceldenBelgeEkle: TMenuItem
      Caption = 'Excelden Belge Al-1'
      Visible = False
      OnClick = ExceldenBelgeEkleClick
    end
    object ExceldenBelgeEkle2: TMenuItem
      Caption = 'Excelden Veri Al'
      OnClick = ExceldenBelgeEkle2Click
    end
    object N8: TMenuItem
      Caption = '-'
      Visible = False
    end
    object IadeAl: TMenuItem
      Caption = #304'ade Al'
      object Fatura1: TMenuItem
        Tag = 2
        Caption = 'Fatura ile'
        OnClick = Fatura1Click
      end
      object Pusula1: TMenuItem
        Tag = 5
        Caption = 'Gider Pusulas'#305' ile'
        OnClick = Fatura1Click
      end
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object TahsilOdemeMenu: TMenuItem
      Caption = 'Tahsil Et'
      object Nakit1: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        OnClick = Nakit1Click
      end
      object HavaleEFT1: TMenuItem
        Tag = 22
        Caption = 'Havale/EFT'
        OnClick = Nakit1Click
      end
      object POSMenu: TMenuItem
        Tag = 25
        Caption = 'POS'
        OnClick = Nakit1Click
      end
      object KrediKartiMenu: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        OnClick = Nakit1Click
      end
      object ek1: TMenuItem
        Tag = 23
        Caption = #199'ek'
        OnClick = Nakit1Click
      end
      object Senet1: TMenuItem
        Tag = 24
        Caption = 'Senet'
        OnClick = Nakit1Click
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object ahsilatPlanla1: TMenuItem
        Tag = 61
        Caption = 'Tahsilat Planla'
        OnClick = Nakit1Click
      end
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object SeyirDefteriMenu: TMenuItem
      Caption = 'Seyir Defteri'
      OnClick = SeyirDefteriMenuClick
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 560
    Top = 104
  end
  object OpenDialog1: TOpenDialog
    Left = 616
    Top = 184
  end
  object TabExcel: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 464
    Top = 152
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 681
    Top = 192
  end
  object frxSIPARISDETAY: TfrxDBDataset
    UserName = 'SIPARISDETAY'
    CloseDataSource = False
    FieldAliases.Strings = (
      'ID=ID'
      'SIPARISID=SIPARISID'
      'REHBERID=REHBERID'
      'SEC=SEC'
      'TUR=TUR'
      'URUNID=URUNID'
      'ACIKLAMA=ACIKLAMA'
      'ADET=ADET'
      'BIRIM=BIRIM'
      'MIKTAR=MIKTAR'
      'BIRIMFIYAT=BIRIMFIYAT'
      'TUTAR=TUTAR'
      'ISKONTO=ISKONTO'
      'KDV=KDV'
      'MASRAFID=MASRAFID'
      'OZELKOD=OZELKOD'
      'MUHKODU=MUHKODU'
      'KASA=KASA'
      'ONAY=ONAY'
      'KUR=KUR'
      'IZLEMEKODU=IZLEMEKODU'
      'DOVIZ_TUTARI=DOVIZ_TUTARI'
      'DOVIZ_KURU=DOVIZ_KURU'
      'ISKONTO2=ISKONTO2'
      'IZLEME=IZLEME'
      'MF=MF'
      'IADEADET=IADEADET'
      'IADESIPARISDETAYID=IADESIPARISDETAYID'
      'YERI=YERI'
      'YERID=YERID'
      'DOVIZ_BIRIMFIYAT=DOVIZ_BIRIMFIYAT'
      'DOVIZKURDEGERI=DOVIZKURDEGERI'
      'EKLEYEN=EKLEYEN'
      'EKLEMETARIHI=EKLEMETARIHI'
      'DEGISTIREN=DEGISTIREN'
      'DEGISTIRMETARIHI=DEGISTIRMETARIHI'
      'KAMPANYAID=KAMPANYAID'
      'VADE=VADE'
      'PROJEID=PROJEID'
      'TESLIMTARIHI=TESLIMTARIHI'
      'SUBEID=SUBEID'
      'URETIMPLANID=URETIMPLANID'
      'URETIMPLANDETAYID=URETIMPLANDETAYID'
      'MERKEZID=MERKEZID'
      'STOKDURUM=STOKDURUM'
      'EKIPMANID=EKIPMANID'
      'MASRAFKOD=MASRAFKOD'
      'MASRAFAD=MASRAFAD'
      'AD=AD'
      'KOD=KOD'
      'BIRIMAD=BIRIMAD'
      'PROJEKODU=PROJEKODU'
      'EKIPMAN=EKIPMAN'
      'SERINO=SERINO')
    DataSet = SIPARISDETAY
    BCDToCurrency = False
    DataSetOptions = []
    Left = 323
    Top = 294
  end
  object SIPARIS: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
    SQL.Strings = (
      'SELECT *,'
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(SIPARIS_TUTARI,'#39'TL'#39',0)),'
      
        'ILGILIADI=(select RP.ADSOYAD from REHBERPERSONEL RP where RP.ID=' +
        'S.MUS_ILGILI),'
      
        'PERSONELADI=(select R.FIRMA from REHBER R where R.ID=S.SATICIKOD' +
        'U) ,'
      
        'SEVKADRES=(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 2 Order by 1 )' +
        ','
      
        'SEVKILCE =(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 6 Order by 1),'
      
        'SEVKIL = (SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 8 Order by 1 )'
      'FROM SIPARIS S WHERE ID = :Par')
    Left = 635
    Top = 242
  end
  object frxSIPARIS: TfrxDBDataset
    UserName = 'SIPARIS'
    CloseDataSource = False
    DataSet = SIPARIS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 534
    Top = 249
  end
  object PopupFatGiris: TPopupMenu
    Left = 632
    Top = 104
    object AlSat1: TMenuItem
      Tag = 1
      Caption = 'Al'#305#351' / Sat'#305#351
      OnClick = AlSat1Click
    end
    object adeFaturas1: TMenuItem
      Tag = 2
      Caption = #304'ade Faturas'#305
      OnClick = AlSat1Click
    end
    object FiatFark1: TMenuItem
      Tag = 3
      Caption = 'Fiyat Fark'#305
      OnClick = AlSat1Click
    end
    object StopajMenu: TMenuItem
      Tag = 4
      Caption = 'Stopaj'
      object SerbestMeslekMakbuzuMenu: TMenuItem
        Tag = 4
        Caption = 'Serbest Meslek Makbuzu'
        OnClick = AlSat1Click
      end
      object KiraMenu: TMenuItem
        Tag = 7
        Caption = 'Kira'
        OnClick = AlSat1Click
      end
      object GiderPusulasiMenu: TMenuItem
        Tag = 8
        Caption = 'Gider Pusulas'#305
        OnClick = AlSat1Click
      end
    end
    object KurFark1: TMenuItem
      Tag = 5
      Caption = 'Kur Fark'#305
      OnClick = AlSat1Click
    end
    object IthalatMenu: TMenuItem
      Tag = 6
      Caption = #304'thalat'
      OnClick = AlSat1Click
    end
    object IhracatMenu: TMenuItem
      Tag = 26
      Caption = #304'hracat'
      OnClick = AlSat1Click
    end
    object IhracKayitliMenu: TMenuItem
      Tag = 9
      Caption = #304'hra'#231' Kay'#305'tl'#305
      OnClick = AlSat1Click
    end
    object CizgiMenu1: TMenuItem
      Caption = '-'
    end
    object EFaturaMenu1: TMenuItem
      Tag = -1
      Caption = 'E-Fatura'
      OnClick = AlSat1Click
    end
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PRehberID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM,ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'REHBERID=:PRehberID')
    Left = 60
    Top = 450
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 64
    Top = 401
  end
  object TabSmsEPosta: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE @REHID int'
      'SET @REHID= :PRehID'
      ''
      
        'SELECT TIP='#39'E-Posta'#39',EXT=1,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,Y' +
        'ON='#39'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'8' +
        '3'#39' THEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GIDENADRES,SURUM='#39#39',' +
        'KONUSU=MESAJKONUSU,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39 +
        ',BOYUT='#39#39',LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK=EPOS' +
        'TA,ANAHTAR,YER  FROM EPOSTALAR'
      'WHERE'
      'REHID=@REHID'
      'UNION ALL'
      
        'SELECT TIP='#39'Sms'#39',EXT=2,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,YON='#39 +
        'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'83'#39' T' +
        'HEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GSMNO,SURUM='#39#39',KONUSU=ME' +
        'SAJMETNI,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39',BOYUT='#39#39',' +
        'LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK='#39#39' ,ANAHTAR,YE' +
        'R  FROM SMSLER'
      'WHERE'
      'REHID=@REHID')
    Left = 200
    Top = 456
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 200
    Top = 408
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 315
    Top = 409
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 332
    Top = 468
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
    end
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    appearance.Gradient1Start = 15722724
    appearance.Gradient1End = 14599608
    appearance.Gradient2Start = 14203563
    appearance.Gradient2End = 15722724
    appearance.MarginX = 4
    appearance.MarginY = 2
    appearance.SeparatorLeading = 6
    appearance.GutterWidth = 26
    appearance.SeparatorBackgroundColor = 15656925
    appearance.SeparatorLineColor = 12961221
    appearance.GutterColor = 15658729
    appearance.ItemBackgroundColor = 16448250
    appearance.ItemSelectedColor = 15128011
    appearance.FontColor = 7214336
    appearance.FontDisabledColor = 14599640
    style = msDefault
    Left = 880
    Top = 404
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object PopupKonsGiris: TPopupMenu
    Left = 712
    Top = 104
    object MenuItem2: TMenuItem
      Tag = 1
      Caption = 'Al'#305#351
      OnClick = AlSat1Click
    end
    object MenuItem3: TMenuItem
      Tag = 2
      Caption = #304'ade '
      OnClick = AlSat1Click
    end
  end
end

