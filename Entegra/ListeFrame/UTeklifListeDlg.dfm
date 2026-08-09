object TeklifListeDlg: TTeklifListeDlg
  Left = 0
  Top = 0
  Width = 1174
  Height = 494
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object GridTeklif: TcxGrid
    Left = 0
    Top = 32
    Width = 1174
    Height = 194
    Align = alClient
    PopupMenu = PmSiparisedonustur
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridTeklifView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridTeklifViewCanFocusRecord
      DataController.DataSource = DtsTeklifler
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          FieldName = 'TEKLIF_TUTARI'
          Column = GridTeklifViewTEKLIF_TUTARI
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
        end
        item
          Format = 'Say'#305' :  ######'
          Kind = skCount
          Position = spFooter
          Column = GridTeklifViewTARIH
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'TEKLIF_MATRAHI'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'KDV_TUTARI'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'TEKLIF_TUTARI'
          Column = GridTeklifViewTEKLIF_TUTARI
        end
        item
          Format = 'Say'#305' :  ######'
          Kind = skCount
          Column = GridTeklifViewTARIH
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
      Styles.OnGetContentStyle = GridTeklifViewStylesGetContentStyle
      object GridTeklifViewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Width = 116
      end
      object GridTeklifViewTEKLIFNO: TcxGridDBColumn
        Caption = 'Teklif No'
        DataBinding.FieldName = 'TEKLIFNO'
        DataBinding.IsNullValueType = True
        Width = 53
      end
      object GridTeklifViewKONU: TcxGridDBColumn
        Caption = 'Konusu'
        DataBinding.FieldName = 'KONUSU'
        DataBinding.IsNullValueType = True
        Width = 127
      end
      object GridTeklifViewTURU: TcxGridDBColumn
        Caption = 'T'#252'r'#252
        DataBinding.FieldName = 'TURU'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repTeklifTuru
        Width = 42
      end
      object GridTeklifViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repTeklifDurumu
        Width = 54
      end
      object GridTeklifViewFIRMA: TcxGridDBColumn
        Caption = 'M'#252#351'teri'
        DataBinding.FieldName = 'FIRMA'
        DataBinding.IsNullValueType = True
        Width = 179
      end
      object GridTeklifViewMUS_ILGILIAD: TcxGridDBColumn
        Caption = #304'lgili'
        DataBinding.FieldName = 'MUS_ILGILIAD'
        DataBinding.IsNullValueType = True
        Width = 115
      end
      object GridTeklifViewHAZIRLAYAN: TcxGridDBColumn
        Caption = 'Haz'#305'rlayan'
        DataBinding.FieldName = 'HAZIRLAYANAD'
        DataBinding.IsNullValueType = True
        Width = 113
      end
      object GridTeklifViewTEKLIF_MATRAHI: TcxGridDBColumn
        Caption = 'Teklif Matrah'#305
        DataBinding.FieldName = 'TEKLIF_MATRAHI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 82
      end
      object GridTeklifViewISKONTO_TUTARI: TcxGridDBColumn
        Caption = #304'skonto Tutar'#305
        DataBinding.FieldName = 'ISKONTO_TUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 88
      end
      object GridTeklifViewKDV_TUTARI: TcxGridDBColumn
        Caption = 'KDV Tutar'#305
        DataBinding.FieldName = 'KDV_TUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 78
      end
      object GridTeklifViewTEKLIF_TUTARI: TcxGridDBColumn
        Caption = 'Teklif Tutar'#305
        DataBinding.FieldName = 'TEKLIF_TUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 76
      end
      object GridTeklifViewKUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
      end
      object GridTeklifViewDOVIZ_TUTARI: TcxGridDBColumn
        Caption = 'Doviz Tutar'#305
        DataBinding.FieldName = 'DOVIZ_TUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 88
      end
      object GridTeklifViewDOVIZ_KURU: TcxGridDBColumn
        Caption = 'D'#246'viz Kuru'
        DataBinding.FieldName = 'DOVIZ_KURU'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewPROJEKODU: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJEKODU'
        DataBinding.IsNullValueType = True
        Width = 171
      end
      object GridTeklifViewPROJEADI: TcxGridDBColumn
        Caption = 'Proje Ad'#305
        DataBinding.FieldName = 'PROJEADI'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewSURE: TcxGridDBColumn
        Caption = 'Ge'#231'erlilik(G'#252'n)'
        DataBinding.FieldName = 'GECERLILIK_SURESI'
        DataBinding.IsNullValueType = True
        Width = 84
      end
      object GridTeklifViewGECERLILIK_KALAN: TcxGridDBColumn
        Caption = 'Ge'#231'erlilik (Kalan G'#252'n)'
        DataBinding.FieldName = 'GECERLILIK_KALAN'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewDURUMGUNSAYISI: TcxGridDBColumn
        Caption = 'Durum De'#287'i'#351'ikli'#287'i(G'#252'n)'
        DataBinding.FieldName = 'DURUMGUNSAYISI'
        DataBinding.IsNullValueType = True
        Width = 125
      end
      object GridTeklifViewOLASILIK: TcxGridDBColumn
        Caption = 'Olas'#305'l'#305'k %'
        DataBinding.FieldName = 'OLASILIK'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewTEKLIFGUNSAYISI: TcxGridDBColumn
        Caption = 'Ge'#231'en G'#252'n'
        DataBinding.FieldName = 'TEKLIFGUNSAYISI'
        DataBinding.IsNullValueType = True
        Width = 70
      end
      object GridTeklifViewVERILENSIPARIS: TcxGridDBColumn
        Caption = 'Verilen Sipari'#351
        DataBinding.FieldName = 'VERILENSIPARIS'
        DataBinding.IsNullValueType = True
        Width = 82
      end
      object GridTeklifViewALINANSIPARIS: TcxGridDBColumn
        Caption = 'Al'#305'nan Sipari'#351
        DataBinding.FieldName = 'ALINANSIPARIS'
        DataBinding.IsNullValueType = True
        Width = 72
      end
      object GridTeklifViewTESLIM_SEKLI: TcxGridDBColumn
        Caption = 'Teslim '#350'ekli'
        DataBinding.FieldName = 'TESLIM_SEKLI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repTeklifTeslimSekli
        Width = 75
      end
      object GridTeklifViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
      object GridTeklifViewODEME: TcxGridDBColumn
        Caption = #214'deme '#350'ekli'
        DataBinding.FieldName = 'ODEME'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repTeklifOdeme
        Width = 73
      end
      object GridTeklifViewFIYAT_LISTESI: TcxGridDBColumn
        Caption = 'Fiyat'
        DataBinding.FieldName = 'FIYAT_LISTESI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepFiyatAdlari
        Width = 68
      end
      object GridTeklifViewSTOKISK: TcxGridDBColumn
        Caption = #304'skonto'
        DataBinding.FieldName = 'STOKISK'
        DataBinding.IsNullValueType = True
        Width = 77
      end
      object GridTeklifViewVADE: TcxGridDBColumn
        Caption = 'Vade'
        DataBinding.FieldName = 'VADE'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewNOTLAR: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 36
      end
      object GridTeklifViewTESLIM_SURESI: TcxGridDBColumn
        Caption = 'Teslim S'#252'resi(G'#252'n)'
        DataBinding.FieldName = 'TESLIM_SURESI'
        DataBinding.IsNullValueType = True
        Width = 100
      end
      object GridTeklifViewTESLIMTARIHI: TcxGridDBColumn
        Caption = 'Teslim Tarihi'
        DataBinding.FieldName = 'TESLIMTARIHI'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewREVIZEID: TcxGridDBColumn
        Caption = 'Revize No'
        DataBinding.FieldName = 'REVIZEID'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewONAYCI: TcxGridDBColumn
        Caption = 'Onaylayacak (i'#231')'
        DataBinding.FieldName = 'ONAYLAYACAK2'
        DataBinding.IsNullValueType = True
        Width = 94
      end
      object GridTeklifViewONAYLAYAN_1: TcxGridDBColumn
        Caption = 'Onaylayan (i'#231')'
        DataBinding.FieldName = 'ONAYLAYAN_1'
        DataBinding.IsNullValueType = True
        Width = 83
      end
      object GridTeklifViewDISONAYCI: TcxGridDBColumn
        Caption = 'Onaylayan (d'#305#351')'
        DataBinding.FieldName = 'DISONAYCI'
        DataBinding.IsNullValueType = True
        Width = 85
      end
      object GridTeklifViewTEKLIFSERI: TcxGridDBColumn
        Caption = 'T'#214'K'
        DataBinding.FieldName = 'TEKLIFSERI'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTeklifViewSONUCAD: TcxGridDBColumn
        Caption = 'Sonu'#231
        DataBinding.FieldName = 'SONUCAD'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewSEBEBIAD: TcxGridDBColumn
        Caption = 'Sebebi'
        DataBinding.FieldName = 'SEBEBIAD'
        DataBinding.IsNullValueType = True
      end
      object GridTeklifViewPRJ_DURUM: TcxGridDBColumn
        Caption = 'Prj.Durum'
        DataBinding.FieldName = 'PRJ_DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repProjeDurum
      end
      object GridTeklifViewPRJ_SONUC: TcxGridDBColumn
        Caption = 'Prj.Sonu'#231
        DataBinding.FieldName = 'PRJ_SONUC'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
      end
      object GridTeklifViewPRJ_SEBEBI: TcxGridDBColumn
        Caption = 'Prj.Sebebi'
        DataBinding.FieldName = 'PRJ_SEBEBI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
      end
      object GridTeklifViewBILGI: TcxGridDBColumn
        Caption = 'Bilgi'
        DataBinding.FieldName = 'BILGI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repTeklifBilgi
      end
    end
    object GridTeklifLevel1: TcxGridLevel
      GridView = GridTeklifView
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1168
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 74
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton3: TToolButton
      Left = 148
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 156
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
    object ToolButton1: TToolButton
      Left = 230
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 238
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 226
    Width = 1174
    Height = 7
    AlignSplitter = salBottom
    Control = cxPageControl1
  end
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 233
    Width = 1174
    Height = 261
    Align = alBottom
    TabOrder = 3
    Properties.ActivePage = SheetDetay
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 257
    ClientRectLeft = 4
    ClientRectRight = 1170
    ClientRectTop = 27
    object SheetDetay: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 22
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 1166
        Height = 126
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridDetayViewCanFocusRecord
          DataController.DataSource = DtsTeklifDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Header = AnaForm.cxStyle1
          Styles.Indicator = AnaForm.cxStyle1
          object GridDetayViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepFatDetayTur
            HeaderAlignmentHorz = taCenter
          end
          object GridDetayViewTESLIMTARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIMTARIHI'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
          end
          object GridTeklifViewKOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Width = 62
          end
          object GridDetayViewColumn1: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 202
          end
          object GridTeklifViewACIKLAMA1: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 228
          end
          object GridTeklifViewADET1: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 35
          end
          object GridTeklifViewBIRIM1: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
            Width = 42
          end
          object GridTeklifViewBIRIMFIYAT1: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Width = 84
          end
          object GridTeklifViewISKONTO1: TcxGridDBColumn
            Caption = #304'sk1'
            DataBinding.FieldName = 'ISKONTO'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 41
          end
          object GridTeklifViewISKONTO2: TcxGridDBColumn
            Caption = #304'sk2'
            DataBinding.FieldName = 'ISKONTO2'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 41
          end
          object GridTeklifViewKDV1: TcxGridDBColumn
            DataBinding.FieldName = 'KDV'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 34
          end
          object GridTeklifViewTUTAR1: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            HeaderAlignmentHorz = taCenter
            Width = 97
          end
          object GridDetayViewKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 58
          end
          object GridTeklifViewMASRAFKOD: TcxGridDBColumn
            Caption = 'Gelir Kod'
            DataBinding.FieldName = 'MASRAFKOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Width = 77
          end
          object GridTeklifViewMASRAFAD: TcxGridDBColumn
            Caption = 'Gelir Ad'
            DataBinding.FieldName = 'MASRAFAD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Width = 92
          end
          object GridDetayViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridDetayViewPROJEKODU: TcxGridDBColumn
            Caption = 'Proje Kodu'
            DataBinding.FieldName = 'PROJEKODU'
            DataBinding.IsNullValueType = True
            Width = 139
          end
        end
        object GridDetay: TcxGridLevel
          GridView = GridDetayView
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 126
        Width = 1166
        Height = 104
        Align = alBottom
        Color = 11776947
        ParentBackground = False
        TabOrder = 1
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 480
          Height = 102
          Align = alLeft
          Caption = 'Panel2'
          TabOrder = 0
          object cxDBMemo1: TcxDBMemo
            Left = 57
            Top = 4
            TabStop = False
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsTeklifler
            ParentColor = True
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
            TabOrder = 0
            Height = 69
            Width = 397
          end
          object Label8: TcxLabel
            Left = 15
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
        end
        object gridFatToplam: TcxGrid
          Left = 481
          Top = 1
          Width = 336
          Height = 102
          Align = alLeft
          BorderStyle = cxcbsNone
          Enabled = False
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object tvFatToplamlar: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dtsTOPLAMLAR
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideSelection = True
            OptionsView.ScrollBars = ssVertical
            OptionsView.GridLineColor = 11776947
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            OptionsView.RowSeparatorColor = 11776947
            Styles.Background = Tablo.cxStyle19
            Styles.Content = Tablo.cxStyle19
            object tvFatToplamlarTUR: TcxGridDBColumn
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object tvFatToplamlarACIKLAMA: TcxGridDBColumn
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object tvFatToplamlarDEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
              Width = 60
            end
            object tvFatToplamlarKUR: TcxGridDBColumn
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Width = 25
            end
            object tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZTUTARI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
              Width = 60
            end
            object tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZ_KURU'
              DataBinding.IsNullValueType = True
              Width = 25
            end
          end
          object gridFatToplamLevel1: TcxGridLevel
            GridView = tvFatToplamlar
            Options.DetailFrameColor = 11776947
          end
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Caption = 'Yorum/Medya'
      ImageIndex = 38
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel4: TPanel
        Left = 0
        Top = 169
        Width = 1166
        Height = 41
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 39
          Width = 1018
        end
        object BtnMesajGonder: TcxButton
          Left = 1019
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 0
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 1104
          Top = 1
          Width = 61
          Height = 39
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
        Top = 210
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
        ExplicitTop = 209
        AnchorX = 1166
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1166
        Height = 169
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
            PropertiesClassName = 'TcxRichEditProperties'
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
  object DtsTeklifler: TDataSource
    DataSet = TabTeklif
    Left = 29
    Top = 121
  end
  object TabTeklif: TFDQuery
    AfterOpen = TabTeklifAfterOpen
    AfterScroll = TabTeklifAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select  T.*,'
      'P.PROJEKODU,P.PROJEADI,'
      'CARIKOD=R1.KOD , R1.FIRMA,'
      'HAZIRLAYAN,R2.FIRMA as HAZIRLAYANAD,'
      'RP.ADSOYAD as MUS_ILGILIAD,'
      
        'VERILENSIPARIS = case when 412 in (select YERI from SIPARISDETAY' +
        ' where YERID in (select ID from TEKLIFDETAY where TEKLIFID=T.ID)' +
        ') then '#39'Var'#39' else '#39#39' end ,'
      
        'ALINANSIPARIS = case when 413 in (select YERI from SIPARISDETAY ' +
        'where YERID in (select ID from TEKLIFDETAY where TEKLIFID=T.ID))' +
        ' then '#39'Var'#39' else '#39#39' end ,'
      'TEKLIFGUNSAYISI=DATEDIFF(day,T.TARIH,GETDATE()),'
      'DURUMGUNSAYISI=DATEDIFF(day,DURUMTARIHI,GETDATE()),'
      
        'TESLIMTARIHI =(Select Min(TESLIMTARIHI) from TEKLIFDETAY Where T' +
        'EKLIFID=T.ID ),'
      
        'TESLIMTARIHI =(Select Min(TESLIMTARIHI) from TEKLIFDETAY Where T' +
        'EKLIFID=T.ID ),'
      'ONAYLAYACAK=R3.FIRMA,'
      'ONAYLAYAN =R4.FIRMA,'
      'DISONAYCI =RP2.ADSOYAD,'
      ''
      
        'SONUCAD=(select ANAHTAR from GENINI where BOLUM=-2911 and DEGER=' +
        'T.SONUC),'
      
        'SEBEBIAD= (select ANAHTAR from GENINI where BOLUM=-2912 and DEGE' +
        'R=T.SEBEBI),'
      'PRJ_DURUM=P.DURUM,PRJ_SONUC=P.SONUC,PRJ_SEBEBI=P.SEBEBI'
      'from TEKLIF T'
      'left outer join REHBER R1 on R1.ID=T.REHBERID'
      'left outer join REHBER R2 on R2.ID=T.HAZIRLAYAN'
      'left outer join REHBERPERSONEL RP on RP.ID=T.MUS_ILGILI'
      'left outer join PROJELER P on P.ID=T.PROJEID'
      'left outer join REHBER R3 on T.ONAYLAYACAK=R3.ID'
      'left outer join REHBER R4 on T.ONAYLAYAN=R4.ID'
      'left outer join REHBERPERSONEL RP2 on T.DISONAY=RP2.ID')
    Left = 29
    Top = 159
  end
  object DtsTeklifDetay: TDataSource
    DataSet = TabTeklifDetay
    Left = 97
    Top = 121
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 199
    Top = 56
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
  object frxTEKLIF: TfrxDBDataset
    UserName = 'TEKLIF'
    CloseDataSource = False
    DataSet = TabTeklif
    BCDToCurrency = False
    DataSetOptions = []
    Left = 30
    Top = 201
  end
  object frxTEKLIFDETAY: TfrxDBDataset
    UserName = 'TEKLIFDETAY'
    CloseDataSource = False
    DataSet = TabTeklifDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 91
    Top = 200
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'SIRALAMA'
        FieldAlias = 'SIRALAMA'
      end
      item
        FieldName = 'TEKLIFID'
        FieldAlias = 'TEKLIFID'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'TUR'
        FieldAlias = 'TUR'
      end
      item
        FieldName = 'URUNID'
        FieldAlias = 'URUNID'
      end
      item
        FieldName = 'KOD'
        FieldAlias = 'KOD'
      end
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'ADET'
        FieldAlias = 'ADET'
      end
      item
        FieldName = 'BIRIM'
        FieldAlias = 'BIRIM'
      end
      item
        FieldName = 'MIKTAR'
        FieldAlias = 'MIKTAR'
      end
      item
        FieldName = 'BIRIMFIYAT'
        FieldAlias = 'BIRIMFIYAT'
      end
      item
        FieldName = 'TUTAR'
        FieldAlias = 'TUTAR'
      end
      item
        FieldName = 'ISKONTO'
        FieldAlias = 'ISKONTO'
      end
      item
        FieldName = 'KDV'
        FieldAlias = 'KDV'
      end
      item
        FieldName = 'OZELKOD'
        FieldAlias = 'OZELKOD'
      end
      item
        FieldName = 'MUHKODU'
        FieldAlias = 'MUHKODU'
      end
      item
        FieldName = 'KASA'
        FieldAlias = 'KASA'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'MALIYET'
        FieldAlias = 'MALIYET'
      end
      item
        FieldName = 'KAR_YUZDE'
        FieldAlias = 'KAR_YUZDE'
      end
      item
        FieldName = 'ALTERNATIFNO'
        FieldAlias = 'ALTERNATIFNO'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'DOVIZ_TUTARI'
        FieldAlias = 'DOVIZ_TUTARI'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end
      item
        FieldName = 'ISKONTO2'
        FieldAlias = 'ISKONTO2'
      end
      item
        FieldName = 'TESLIMTARIHI'
        FieldAlias = 'TESLIMTARIHI'
      end
      item
        FieldName = 'YERI'
        FieldAlias = 'YERI'
      end
      item
        FieldName = 'YERID'
        FieldAlias = 'YERID'
      end
      item
        FieldName = 'DOVIZ_BIRIMFIYAT'
        FieldAlias = 'DOVIZ_BIRIMFIYAT'
      end
      item
        FieldName = 'KAMPANYAID'
        FieldAlias = 'KAMPANYAID'
      end
      item
        FieldName = 'VADE'
        FieldAlias = 'VADE'
      end
      item
        FieldName = 'AD'
        FieldAlias = 'AD'
      end
      item
        FieldName = 'PROJEKODU'
        FieldAlias = 'PROJEKODU'
      end
      item
        FieldName = 'MASRAFKOD'
        FieldAlias = 'MASRAFKOD'
      end
      item
        FieldName = 'MASRAFAD'
        FieldAlias = 'MASRAFAD'
      end
      item
        FieldName = 'GRUBU'
        FieldAlias = 'GRUBU'
      end
      item
        FieldName = 'STOKDURUM'
        FieldAlias = 'STOKDURUM'
      end>
  end
  object PmSiparisedonustur: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PmSiparisedonusturPopup
    Left = 64
    Top = 72
    object TeklifInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = TeklifInfoMenuClick
    end
    object eklifiA1: TMenuItem
      Caption = 'Teklifi A'#231
      ImageIndex = 4
      OnClick = eklifiA1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object AlnanSipariiA1: TMenuItem
      Tag = 413
      Caption = 'Al'#305'nan Sipari'#351'i A'#231
      ImageIndex = 4
      Hint = '413'
      OnClick = AlnanSipariiA1Click
    end
    object VerilenSipariiA1: TMenuItem
      Tag = 412
      Caption = 'Verilen Sipari'#351'i A'#231
      ImageIndex = 4
      Hint = '412'
      OnClick = VerilenSipariiA1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object pmAlinanSiparisedonustur: TMenuItem
      Tag = 19
      Caption = 'Al'#305'nan Sipari'#351'e D'#246'n'#252#351't'#252'r'
      ImageIndex = 4
      Hint = '413'
      OnClick = pmAlinanSiparisedonusturClick
    end
    object pmVerilenSiparisedonustur: TMenuItem
      Tag = 9
      Caption = 'Verilen Sipari'#351'e D'#246'n'#252#351't'#252'r'
      ImageIndex = 4
      Hint = '412'
      OnClick = pmAlinanSiparisedonusturClick
    end
    object N7: TMenuItem
      Caption = '-'
      Visible = False
    end
    object PmVerilenSiparisDetay: TMenuItem
      Caption = 'Verilen sipari'#351' detay tablosu'
      ImageIndex = 22
      Visible = False
      OnClick = PmVerilenSiparisDetayClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object EPosta1: TMenuItem
      Caption = 'E-Posta olarak g'#246'nder'
      ImageIndex = 17
      OnClick = btnEPostaClick
    end
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 758
    Top = 316
  end
  object frxTeklifDetayIlkUrun: TfrxDBDataset
    UserName = 'TEKLIFDETAYILKURUN'
    CloseDataSource = False
    DataSet = TabTeklifDetayIlkUrun
    BCDToCurrency = False
    DataSetOptions = []
    Left = 621
    Top = 217
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'TEKLIFID'
        FieldAlias = 'TEKLIFID'
      end
      item
        FieldName = 'ALTERNATIFNO'
        FieldAlias = 'ALTERNATIFNO'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'SIRALAMA'
        FieldAlias = 'SIRALAMA'
      end
      item
        FieldName = 'SEC'
        FieldAlias = 'SEC'
      end
      item
        FieldName = 'URUNID'
        FieldAlias = 'URUNID'
      end
      item
        FieldName = 'TUR'
        FieldAlias = 'TUR'
      end
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'ADET'
        FieldAlias = 'ADET'
      end
      item
        FieldName = 'BIRIM'
        FieldAlias = 'BIRIM'
      end
      item
        FieldName = 'MIKTAR'
        FieldAlias = 'MIKTAR'
      end
      item
        FieldName = 'BIRIMFIYAT'
        FieldAlias = 'BIRIMFIYAT'
      end
      item
        FieldName = 'ISKONTO'
        FieldAlias = 'ISKONTO'
      end
      item
        FieldName = 'KDV'
        FieldAlias = 'KDV'
      end
      item
        FieldName = 'TUTAR'
        FieldAlias = 'TUTAR'
      end
      item
        FieldName = 'MALIYET'
        FieldAlias = 'MALIYET'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'KAR_YUZDE'
        FieldAlias = 'KAR_YUZDE'
      end
      item
        FieldName = 'OZELKOD'
        FieldAlias = 'OZELKOD'
      end
      item
        FieldName = 'MUHKODU'
        FieldAlias = 'MUHKODU'
      end
      item
        FieldName = 'KASA'
        FieldAlias = 'KASA'
      end
      item
        FieldName = 'ONAY'
        FieldAlias = 'ONAY'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'DOVIZ_TUTARI'
        FieldAlias = 'DOVIZ_TUTARI'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end
      item
        FieldName = 'ISKONTO2'
        FieldAlias = 'ISKONTO2'
      end
      item
        FieldName = 'YERI'
        FieldAlias = 'YERI'
      end
      item
        FieldName = 'YERID'
        FieldAlias = 'YERID'
      end
      item
        FieldName = 'KOD_2'
        FieldAlias = 'KOD_2'
      end
      item
        FieldName = 'AD_2'
        FieldAlias = 'AD_2'
      end
      item
        FieldName = 'TESLIMTARIHI'
        FieldAlias = 'TESLIMTARIHI'
      end
      item
        FieldName = 'DOVIZ_BIRIMFIYAT'
        FieldAlias = 'DOVIZ_BIRIMFIYAT'
      end
      item
        FieldName = 'KAMPANYAID'
        FieldAlias = 'KAMPANYAID'
      end
      item
        FieldName = 'VADE'
        FieldAlias = 'VADE'
      end
      item
        FieldName = 'SUBEID'
        FieldAlias = 'SUBEID'
      end
      item
        FieldName = 'SIPBIRIMFIYAT'
        FieldAlias = 'SIPBIRIMFIYAT'
      end
      item
        FieldName = 'SIPTUTAR'
        FieldAlias = 'SIPTUTAR'
      end
      item
        FieldName = 'MASRAFID'
        FieldAlias = 'MASRAFID'
      end
      item
        FieldName = 'PROJEID'
        FieldAlias = 'PROJEID'
      end
      item
        FieldName = 'DOVIZKURDEGERI'
        FieldAlias = 'DOVIZKURDEGERI'
      end
      item
        FieldName = 'KOD'
        FieldAlias = 'KOD'
      end
      item
        FieldName = 'AD'
        FieldAlias = 'AD'
      end
      item
        FieldName = 'BIRIMAD'
        FieldAlias = 'BIRIMAD'
      end
      item
        FieldName = 'MARKA_AD'
        FieldAlias = 'MARKA_AD'
      end
      item
        FieldName = 'MODEL_AD'
        FieldAlias = 'MODEL_AD'
      end
      item
        FieldName = 'STOK_NOTLAR'
        FieldAlias = 'STOK_NOTLAR'
      end
      item
        FieldName = 'RESIM'
        FieldAlias = 'RESIM'
      end>
  end
  object TabTeklifDetayIlkUrun: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM'
      '('
      'Select TD.*,'
      'KOD = CASE WHEN TD.TUR IN (1,11) THEN S.KOD ELSE M.KOD END,'
      'AD = CASE WHEN TD.TUR IN (1,11) THEN S.STOKADI ELSE M.AD END,'
      
        'BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 and ' +
        'DEGER=convert(varchar(10), TD.BIRIM) and DIL=-1),'
      
        'MARKA_AD = (select top 1 ANAHTAR from GENINI where BOLUM=-2701 a' +
        'nd DEGER=convert(varchar(10), S.MARKA) and DIL=-1), '
      
        'MODEL_AD = (select top 1 ANAHTAR from GENINI where BOLUM=convert' +
        '(int,'#39'-2701'#39'+convert(varchar(10),S.MARKA)) and DEGER=convert(var' +
        'char(10), S.MODEL) and DIL=-1 ),'
      'STOK_NOTLAR = S.NOTLAR,'
      
        'RESIM = (select BELGE from IMAJ where REHBERID=S.ID and YERI=71 ' +
        'and YER_ID=S.ID and VARSAYILAN = 1)    '
      
        '    from TEKLIFDETAY TD left outer join STOKLAR S on TD.URUNID=S' +
        '.ID'
      
        '                                        left outer join MASRAFGE' +
        'LIR M ON TD.URUNID = M.ID'
      ''
      'Where '
      'TEKLIFID = :Par'
      ') AS X'
      ' order by ID')
    Left = 621
    Top = 159
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabTeklifYaz: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'T.*,R1.FIRMA as HAZIRLAYAN,RP.ADSOYAD,'
      
        '  ILGILIISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=40' +
        '),'
      
        ' '#9'ILGILIMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=46)' +
        ','
      
        '  ILGILIFAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=43),'
      
        #9'TUR_AD = (select top 1 ANAHTAR  from GENINI where BOLUM=-2901 a' +
        'nd DEGER=T.TURU and DIL=-1),'
      
        #9'TESLIM_SEKLI_AD = (select top 1 ANAHTAR  from GENINI where BOLU' +
        'M=-2903 and DEGER=T.TESLIM_SEKLI and DIL=-1),'
      
        #9'ODEME_AD = (select top 1 ANAHTAR  from GENINI where BOLUM=-2904' +
        ' and DEGER=T.ODEME and DIL=-1),'
      
        '                REVIZE_TEKLIFNO = Case When  T.DURUM = 5 then '#39'R' +
        'evize No'#39' else '#39'Teklif No'#39' end ,'
      #9'PROJEADI=(select PROJEADI from PROJELER where ID=T.PROJEID),'
      #9'PROJEKODU=(select PROJEKODU from PROJELER where ID=T.PROJEID)'
      'FROM'
      #9'TEKLIF T '
      '    left outer join REHBER R1 on R1.ID = T.HAZIRLAYAN '
      '    left outer join REHBERPERSONEL RP on RP.ID = T.MUS_ILGILI '
      'where T.ID=:PTid')
    Left = 479
    Top = 177
    ParamData = <
      item
        Name = 'PTid'
        Size = -1
        Value = Null
      end>
  end
  object TabTeklifDetayYaz: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM'
      '('
      'Select TD.*,'
      'KOD = CASE WHEN TD.TUR IN (1,11) THEN S.KOD ELSE M.KOD END,'
      'AD = CASE WHEN TD.TUR IN (1,11) THEN S.STOKADI ELSE M.AD END,'
      
        'BIRIMAD=(select ANAHTAR from GENINI where BOLUM=-2702 and DEGER=' +
        'convert(varchar(10), TD.BIRIM)),'
      
        'MARKA_AD = (select ANAHTAR from GENINI where BOLUM=-2701 and DEG' +
        'ER=convert(varchar(10), S.MARKA)),'
      
        'MODEL_AD = (select ANAHTAR from GENINI where BOLUM=convert(int,'#39 +
        '-2701'#39'+convert(varchar(10),S.MARKA)) and DEGER=convert(varchar(1' +
        '0), S.MODEL) ),'
      'STOK_NOTLAR = S.NOTLAR,'
      'EKIPMANAD = E.AD,EKIPMANSERINO= ER.SERINO,'
      
        'RESIM = (select BELGE from IMAJ where REHBERID=S.ID and YERI=71 ' +
        'and YER_ID=S.ID and VARSAYILAN = 1)'
      'from TEKLIFDETAY TD'
      'left outer join STOKLAR S on TD.URUNID=S.ID'
      'left outer join MASRAFGELIR M ON TD.URUNID = M.ID'
      'LEFT OUTER JOIN EKIPMANREHBER ER ON ER.ID=TD.EKIPMANID'
      'LEFT OUTER JOIN EKIPMANLAR E on E.ID=ER.EKIPMANID'
      'Where'
      'TEKLIFID = :Par'
      ') AS X'
      ' order by ID'
      '')
    Left = 389
    Top = 157
    ParamData = <
      item
        Name = 'Par'
        Size = -1
        Value = Null
      end>
  end
  object frxTEKLIF2: TfrxDBDataset
    UserName = 'TEKLIF'
    CloseDataSource = False
    DataSet = TabTeklifYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 30
    Top = 256
  end
  object frxTEKLIFDETAY2: TfrxDBDataset
    UserName = 'TEKLIFDETAY'
    CloseDataSource = False
    DataSet = TabTeklifDetayYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 95
    Top = 260
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'TEKLIFID'
        FieldAlias = 'TEKLIFID'
      end
      item
        FieldName = 'ALTERNATIFNO'
        FieldAlias = 'ALTERNATIFNO'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'SIRALAMA'
        FieldAlias = 'SIRALAMA'
      end
      item
        FieldName = 'SEC'
        FieldAlias = 'SEC'
      end
      item
        FieldName = 'URUNID'
        FieldAlias = 'URUNID'
      end
      item
        FieldName = 'TUR'
        FieldAlias = 'TUR'
      end
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'ADET'
        FieldAlias = 'ADET'
      end
      item
        FieldName = 'BIRIM'
        FieldAlias = 'BIRIM'
      end
      item
        FieldName = 'MIKTAR'
        FieldAlias = 'MIKTAR'
      end
      item
        FieldName = 'BIRIMFIYAT'
        FieldAlias = 'BIRIMFIYAT'
      end
      item
        FieldName = 'ISKONTO'
        FieldAlias = 'ISKONTO'
      end
      item
        FieldName = 'KDV'
        FieldAlias = 'KDV'
      end
      item
        FieldName = 'TUTAR'
        FieldAlias = 'TUTAR'
      end
      item
        FieldName = 'MALIYET'
        FieldAlias = 'MALIYET'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'KAR_YUZDE'
        FieldAlias = 'KAR_YUZDE'
      end
      item
        FieldName = 'OZELKOD'
        FieldAlias = 'OZELKOD'
      end
      item
        FieldName = 'MUHKODU'
        FieldAlias = 'MUHKODU'
      end
      item
        FieldName = 'KASA'
        FieldAlias = 'KASA'
      end
      item
        FieldName = 'ONAY'
        FieldAlias = 'ONAY'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'DOVIZ_TUTARI'
        FieldAlias = 'DOVIZ_TUTARI'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end
      item
        FieldName = 'ISKONTO2'
        FieldAlias = 'ISKONTO2'
      end
      item
        FieldName = 'YERI'
        FieldAlias = 'YERI'
      end
      item
        FieldName = 'YERID'
        FieldAlias = 'YERID'
      end
      item
        FieldName = 'TESLIMTARIHI'
        FieldAlias = 'TESLIMTARIHI'
      end
      item
        FieldName = 'DOVIZ_BIRIMFIYAT'
        FieldAlias = 'DOVIZ_BIRIMFIYAT'
      end
      item
        FieldName = 'KAMPANYAID'
        FieldAlias = 'KAMPANYAID'
      end
      item
        FieldName = 'VADE'
        FieldAlias = 'VADE'
      end
      item
        FieldName = 'SUBEID'
        FieldAlias = 'SUBEID'
      end
      item
        FieldName = 'SIPBIRIMFIYAT'
        FieldAlias = 'SIPBIRIMFIYAT'
      end
      item
        FieldName = 'SIPTUTAR'
        FieldAlias = 'SIPTUTAR'
      end
      item
        FieldName = 'MASRAFID'
        FieldAlias = 'MASRAFID'
      end
      item
        FieldName = 'PROJEID'
        FieldAlias = 'PROJEID'
      end
      item
        FieldName = 'DOVIZKURDEGERI'
        FieldAlias = 'DOVIZKURDEGERI'
      end
      item
        FieldName = 'RESIMGOSTER'
        FieldAlias = 'RESIMGOSTER'
      end
      item
        FieldName = 'TEKLIFONAY'
        FieldAlias = 'TEKLIFONAY'
      end
      item
        FieldName = 'IZLEME'
        FieldAlias = 'IZLEME'
      end
      item
        FieldName = 'MERKEZID'
        FieldAlias = 'MERKEZID'
      end
      item
        FieldName = 'STOKDURUM'
        FieldAlias = 'STOKDURUM'
      end
      item
        FieldName = 'EKIPMANID'
        FieldAlias = 'EKIPMANID'
      end
      item
        FieldName = 'KOD'
        FieldAlias = 'KOD'
      end
      item
        FieldName = 'AD'
        FieldAlias = 'AD'
      end
      item
        FieldName = 'BIRIMAD'
        FieldAlias = 'BIRIMAD'
      end
      item
        FieldName = 'MARKA_AD'
        FieldAlias = 'MARKA_AD'
      end
      item
        FieldName = 'MODEL_AD'
        FieldAlias = 'MODEL_AD'
      end
      item
        FieldName = 'STOK_NOTLAR'
        FieldAlias = 'STOK_NOTLAR'
      end
      item
        FieldName = 'EKIPMANAD'
        FieldAlias = 'EKIPMANAD'
      end
      item
        FieldName = 'EKIPMANSERINO'
        FieldAlias = 'EKIPMANSERINO'
      end
      item
        FieldName = 'RESIM'
        FieldAlias = 'RESIM'
      end>
  end
  object frxStokDetay: TfrxDBDataset
    UserName = 'StokDetay1'
    CloseDataSource = False
    DataSet = TabStokDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 540
    Top = 191
  end
  object TabStokDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE '
      #9'@SQL '#9#9#9'VARCHAR(5000),'
      #9'@KOLONBASLIK'#9'VARCHAR(100),'
      #9'@URUNADI'#9#9'VARCHAR(100),'
      #9'@URUNFIYATI'#9#9'VARCHAR(100),'
      #9'@URUNID'#9#9#9'INT,'
      #9'@TEKLIFID'#9#9'INT,'
      #9'@ETIKET'#9#9#9'VARCHAR(50),'
      #9'@BILGI'#9#9#9'VARCHAR(100),'
      #9'@SIRA'#9#9#9'VARCHAR(10),'
      #9'@DETAYBOLMU'#9#9'VARCHAR(20),'
      #9'@KOLONSAYISI'#9'int,'
      #9'@MinKolonSayisi'#9'int'#9
      'SET @TEKLIFID = :PTeklifID'
      'SET @MinKolonSayisi = :PKolonSayisi'
      'SET @SQL = '#39'Create Table ##RehberBilgiView( '
      'ID'#9#9'INT IDENTITY(1,1),'
      'SIRA '#9'INT NULL,'
      'ETIKET'#9'VARCHAR(60) NULL,'
      'KONU'#9'VARCHAR(50) NULL,'
      'GIRIS'#9#9'INT NULL,'#39
      ''
      'select top 1 @KOLONSAYISI=count(*)'
      
        'FROM STOKLAR S inner join TEKLIFDETAY TD on S.ID=TD.URUNID and T' +
        'D.TUR=1 '
      'where '
      #9'TD.TEKLIFID=@TEKLIFID and'
      
        #9'S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR S whe' +
        're isnull(DETAYBOLUMU,'#39#39')<>'#39#39'and S.ID in(select URUNID from TEKL' +
        'IFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID))'
      'group by DETAYBOLUMU'
      'order by 1 desc'
      ''
      'if @KOLONSAYISI<@MinKolonSayisi'
      'SET @KOLONSAYISI=@MinKolonSayisi'
      ''
      'DECLARE @count INT '
      'SET @count = 0 '
      'WHILE (@count < @KOLONSAYISI) '
      'BEGIN '
      
        '   SET @SQL = @SQL +'#39' ['#220'r'#252'n'#39'+CONVERT(varchar(5),@count+1)+'#39'] nva' +
        'rchar(100) NULL ,'#39' '
      '   SET @count = (@count + 1) '
      'END '
      'SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1 )+'#39')'#39
      'EXEC (@SQL)'
      ''
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      'SELECT RA.SIRA,RA.ETIKET,RA.BOLUM,RA.GIRIS'
      'FROM REHBERAYAR RA '
      
        'where YERI=88 and BOLUM in(select distinct DETAYBOLUMU from STOK' +
        'LAR S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select URUNI' +
        'D from TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID))'
      'order by BOLUM '
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct -1,'#39#220'r'#252'n Ad'#305#39',DETAYBOLUMU,-1 from STOKLAR S wher' +
        'e isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select URUNID from TEK' +
        'LIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID)'
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct 2147483640,'#39'Fiyat'#305#39',DETAYBOLUMU,2147483640 from ' +
        'STOKLAR S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select U' +
        'RUNID from TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID)'
      ''
      ''
      'DECLARE cur_Konular Cursor For '
      'select DETAYBOLUMU'
      'FROM STOKLAR S '
      
        'where S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR ' +
        'S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and  S.ID in (select URUNID f' +
        'rom TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID) )'
      'group by DETAYBOLUMU'
      'order by count(*) desc'
      'OPEN cur_Konular'
      'FETCH NEXT FROM cur_Konular INTO @DETAYBOLMU'
      'WHILE @@FETCH_STATUS = 0'
      #9'BEGIN '
      #9#9#9#9#9#9
      #9#9#9#9'DECLARE cur_Urunler cursor for '
      #9#9#9#9'select '
      #9#9#9#9#9'T.URUNID,--select * from TEKLIFDETAY'
      
        #9#9#9#9#9'KOLONADI='#39#220'r'#252'n'#39'+convert(varchar(5),ROW_NUMBER()OVER(order b' +
        'y T.URUNID)),'
      #9#9#9#9#9'S.STOKADI,'
      #9#9#9#9#9'URUNFIYAT=convert(varchar(50),T.TUTAR)+KUR'
      
        #9#9#9#9'from STOKLAR S inner join TEKLIFDETAY T on T.TUR=1 and T.URU' +
        'NID=S.ID'
      #9#9#9#9'where T.TEKLIFID=@TEKLIFID and S.DETAYBOLUMU=@DETAYBOLMU'
      #9#9#9#9'OPEN cur_Urunler'
      
        #9#9#9#9'FETCH NEXT FROM cur_Urunler INTO @URUNID,@KOLONBASLIK,@URUNA' +
        'DI,@URUNFIYATI'#9
      #9#9#9#9'WHILE @@FETCH_STATUS = 0'
      #9#9#9#9#9'BEGIN '
      ''
      
        #9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASLIK+'#39 +
        '] = '#39#39#39'+@URUNADI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA=-1 ' +
        'and ETIKET = '#39#39#220'r'#252'n Ad'#305#39#39' '#39
      #9#9#9#9#9#9'exec(@SQL)'
      
        #9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASLIK+'#39 +
        '] = '#39#39#39'+@URUNFIYATI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA=' +
        '2147483640 and ETIKET = '#39#39'Fiyat'#305#39#39' '#39
      #9#9#9#9#9#9'exec(@SQL)'#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9'DECLARE cur_Etiketler cursor for '
      #9#9#9#9#9#9#9#9'select RB2.ETIKET,RB2.BILGI,RB2.SIRA '
      #9#9#9#9#9#9#9#9'from --select * from REHBERBILGI'
      #9#9#9#9#9#9#9#9#9'REHBERBILGI RB2 inner join '
      
        #9#9#9#9#9#9#9#9#9'REHBERAYAR RA2 on RB2.SIRA=RA2.SIRA and RB2.ETIKET=RA2.' +
        'ETIKET'
      
        #9#9#9#9#9#9#9#9'where RA2.BOLUM=@DETAYBOLMU and RB2.YERI=88 and YER_ID=@' +
        'URUNID'
      #9#9#9#9#9#9#9#9'OPEN cur_Etiketler'
      #9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Etiketler INTO @ETIKET,@BILGI,@SIRA'#9
      #9#9#9#9#9#9#9#9'WHILE @@FETCH_STATUS = 0'
      #9#9#9#9#9#9#9#9#9'BEGIN '
      
        #9#9#9#9#9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASL' +
        'IK+'#39'] = '#39#39#39'+@BILGI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA='#39 +
        '+@SIRA+'#39' and ETIKET = '#39#39#39'+@ETIKET+'#39#39#39' '#39
      #9#9#9#9#9#9#9#9#9#9'exec(@SQL)'#9#9#9#9#9#9#9#9#9#9#9#9#9#9#9#9
      
        #9#9#9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Etiketler INTO @ETIKET,@BILGI,@SIR' +
        'A'#9#9#9#9
      #9#9#9#9#9#9#9#9#9'END'#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9'CLOSE cur_Etiketler'
      #9#9#9#9#9#9#9#9'DEALLOCATE cur_Etiketler'
      #9#9#9#9#9#9#9#9#9#9#9#9#9#9
      
        #9#9#9#9#9#9'FETCH NEXT FROM cur_Urunler INTO @URUNID,@KOLONBASLIK,@URU' +
        'NADI,@URUNFIYATI'#9#9#9#9
      #9#9#9#9#9'END'
      #9#9#9#9'CLOSE cur_Urunler'
      #9#9#9#9'DEALLOCATE cur_Urunler'#9#9
      ''
      #9#9'FETCH NEXT FROM cur_Konular INTO @DETAYBOLMU'#9#9
      #9'END '
      'CLOSE cur_Konular'
      'DEALLOCATE cur_Konular'#9
      ''
      'select * from ##RehberBilgiView order by KONU,SIRA'#9#9#9
      'drop table ##RehberBilgiView'#9
      ''
      ''
      ''
      ''
      '')
    Left = 545
    Top = 145
    ParamData = <
      item
        Name = 'PTeklifID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PKolonSayisi'
        Size = -1
        Value = Null
      end>
  end
  object TabTeklifDetayResimli: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM'
      '('
      'Select TD.*,'
      'KOD = CASE WHEN TD.TUR IN (1,11) THEN S.KOD ELSE M.KOD END,'
      'AD = CASE WHEN TD.TUR IN (1,11) THEN S.STOKADI ELSE M.AD END,'
      
        'BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 and ' +
        'DEGER=convert(varchar(10), TD.BIRIM) and DIL=-1),'
      
        'MARKA_AD = (select top 1  ANAHTAR from GENINI where BOLUM=-2701 ' +
        'and DEGER=convert(varchar(10), S.MARKA) and DIL=-1), '
      
        'MODEL_AD = (select top 1  ANAHTAR from GENINI where BOLUM=conver' +
        't(int,'#39'-2701'#39'+convert(varchar(10),S.MARKA)) and DEGER=convert(va' +
        'rchar(10), S.MODEL) and DIL=-1),'
      'STOK_NOTLAR = S.NOTLAR,'
      
        'RESIM = (select top 1 BELGE from IMAJ where REHBERID=S.ID and YE' +
        'RI=71 and YER_ID=S.ID and VARSAYILAN = 1)    '
      
        '    from TEKLIFDETAY TD left outer join STOKLAR S on TD.URUNID=S' +
        '.ID'
      
        '                                        left outer join MASRAFGE' +
        'LIR M ON TD.URUNID = M.ID'
      ''
      'Where '
      'TEKLIFID = :Par'
      'and RESIMGOSTER=1'
      ') AS X'
      ' order by ID')
    Left = 192
    Top = 158
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object frxTeklifDetayResimli: TfrxDBDataset
    UserName = 'TEKLIFDETAYRESIMLI'
    CloseDataSource = False
    DataSet = TabTeklifDetayResimli
    BCDToCurrency = False
    DataSetOptions = []
    Left = 194
    Top = 205
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 777
    Top = 235
    FieldDefs = <
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'DEGER'
        FieldAlias = 'DEGER'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end>
  end
  object TabHazirlayanDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Declare @IletisimID integer, @RehberID integer'
      'set @RehberID = :PRehID'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=@RehberID  order by VARSAYILAN desc'
      '    select'
      '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,NOTLAR,YETKIKODU,'
      
        '    '#9'KATEGORIADI=(select top 1 ANAHTAR from GENINI where BOLUM=-' +
        '2204 and DEGER=KATEGORI),'
      
        '    '#9'GOREVADI=(select top 1 ANAHTAR from GENINI where BOLUM=-220' +
        '5 and DEGER=KATEGORI),'
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=40),'
      
        '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '2),'
      
        '    '#9'FAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '3),'
      
        '    '#9'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=2),'
      
        '    '#9'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '6),'
      
        '    '#9'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=8)' +
        ','
      
        '    '#9'PK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4)' +
        ','
      
        '    '#9'VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILA' +
        'N=20),'
      
        '    '#9'VERGINO=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN' +
        '=22),'
      
        '    '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '8),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46),'
      
        '    '#9'FATURABASLIK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSA' +
        'YILAN=10),'
      
        '    '#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 A' +
        'ND YERI=11 AND YER_ID=@RehberID ),'
      
        '    '#9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE V' +
        'D.VD =(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20)),'
      
        '      VERGI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=' +
        '20)+'#39' / '#39'+(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22' +
        ')'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = @RehberID')
    Left = 298
    Top = 169
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object frxHazirlayanDetay: TfrxDBDataset
    UserName = 'HazirlayanDetay'
    CloseDataSource = False
    DataSet = TabHazirlayanDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 293
    Top = 223
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 279
    Top = 76
  end
  object TabTeklifDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ' SELECT * FROM'
      '('
      'Select T.* , MASRAFKOD=MG.KOD,MASRAFAD=MG.AD,'
      
        'AD =  CASE WHEN T.TUR IN( 1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = T.URUNID )'
      ' ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = T.URUNID)  END,'
      
        'KOD =  CASE WHEN T.TUR IN (1,11)  THEN (SELECT KOD FROM STOKLAR ' +
        'WHERE ID = T.URUNID )'
      ' ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= T.URUNID )  END,'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=T.PROJE' +
        'ID),'
      
        'GRUBU=(select top 1 ANAHTAR from GENINI where BOLUM=-2704 and DE' +
        'GER=convert(varchar(10), S.GRUBU) AND DIL=-1)'
      'from TEKLIFDETAY T LEFT OUTER JOIN STOKLAR S ON T.URUNID = S.ID'
      ' LEFT OUTER JOIN MASRAFGELIR MG ON T.MASRAFID = MG.ID'
      'Where TEKLIFID =:PTid and ALTERNATIFNO=1'
      ''
      ')'
      'AS X'
      ' order by KUR,ID'
      '')
    Left = 92
    Top = 156
    ParamData = <
      item
        Name = 'PTid'
        DataType = ftInteger
        Size = -1
        Value = 0
      end>
  end
  object TabFinansalYaz: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      'KURUMKODU=R.KOD,KURUMADI=R.FIRMA,'
      
        'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=2),'
      
        'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN' +
        ' REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=6),'
      
        'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN R' +
        'EHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=8),'
      
        'VD=(SELECT BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERA' +
        'YAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.' +
        'YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),'
      
        'VNO=(SELECT RB.BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REH' +
        'BERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI' +
        '=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),'
      
        'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=40)'
      ''
      'from TEKLIFFINANSAL TF '
      'inner join REHBER R on R.ID=TF.REHBERID and TF.SEC=1'
      
        'left outer join REHBERILETISIM RI on RI.REHBERID=R.ID and VARSAY' +
        'ILAN=1'
      'where TF.TEKLIFID=:PTeklifId')
    Left = 698
    Top = 140
    ParamData = <
      item
        Name = 'PTEKLIFID'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = 1
      end>
  end
  object frxFINANSMAN: TfrxDBDataset
    UserName = 'FINANSMAN'
    CloseDataSource = False
    DataSet = TabFinansalYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 701
    Top = 199
  end
  object TabHesapOzeti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PBirim,:FatTut' +
        'ari) ')
    Left = 864
    Top = 137
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBirim'
        Size = -1
        Value = Null
      end
      item
        Name = 'FatTutari'
        Size = -1
        Value = Null
      end>
  end
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 863
    Top = 188
  end
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 857
    Top = 240
  end
  object TabSmsEPosta: TFDQuery
    Connection = Tablo.FDCnn
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
      'WHERE YER=97 and '
      'REHID=@REHID'
      'UNION ALL'
      
        'SELECT TIP='#39'Sms'#39',EXT=2,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,YON='#39 +
        'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'83'#39' T' +
        'HEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GSMNO,SURUM='#39#39',KONUSU=ME' +
        'SAJMETNI,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39',BOYUT='#39#39',' +
        'LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK='#39#39' ,ANAHTAR,YE' +
        'R  FROM SMSLER'
      'WHERE YER=97 and '
      'REHID=@REHID')
    Left = 509
    Top = 320
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 509
    Top = 272
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 419
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 19
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 19
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
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
    Left = 419
    Top = 377
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
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 423
    Top = 276
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
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC SP_PRG_TeklifDipToplami :PRM1, :PRM2')
    Left = 679
    Top = 313
    ParamData = <
      item
        Name = 'PRM1'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end
      item
        Name = 'PRM2'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
end
