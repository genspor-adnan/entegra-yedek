object BankaKredileriListeFrame: TBankaKredileriListeFrame
  Left = 0
  Top = 0
  Width = 874
  Height = 592
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
  object GridTakvim: TcxGrid
    Left = 0
    Top = 34
    Width = 874
    Height = 226
    Align = alClient
    PopupMenu = KrediMenu
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridTakvimDBTableView1: TcxGridDBTableView
      OnDblClick = GridTakvimDBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridTakvimDBTableView1CanFocusRecord
      DataController.DataSource = DtsKrediler
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = GridTakvimDBTableView1TAKSITTUTARI
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0;-,0'
          Kind = skCount
          Column = GridTakvimDBTableView1KREDIACIKLAMA1
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1KALAN_GIDER
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1KALAN_ANAPARA
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1KALAN_TUTAR
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1ODENEN_GIDER
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1ODENEN_ANAPARA
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1ODENEN_TUTAR
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1TOPLAM_GIDER
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1TOPLAM_ANAPARA
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = GridTakvimDBTableView1TOPLAM_TUTAR
        end>
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
      OptionsView.CellAutoHeight = True
      OptionsView.Footer = True
      OptionsView.Indicator = True
      object GridTakvimDBTableView1ID: TcxGridDBColumn
        Caption = 'Id'
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 58
      end
      object GridTakvimDBTableView1BANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
        DataBinding.IsNullValueType = True
        Width = 99
      end
      object GridTakvimDBTableView1KREDITURU1: TcxGridDBColumn
        Caption = 'Kredi T'#252'r'#252
        DataBinding.FieldName = 'GENELKREDITIPI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKrediTipi
        Width = 70
      end
      object GridTakvimDBTableView1KREDIKODU1: TcxGridDBColumn
        Caption = 'Kredi Kodu'
        DataBinding.FieldName = 'KREDIKODU'
        DataBinding.IsNullValueType = True
        Width = 74
      end
      object GridTakvimDBTableView1KREDIACIKLAMA1: TcxGridDBColumn
        Caption = 'Kredi Ad'#305
        DataBinding.FieldName = 'ADI'
        DataBinding.IsNullValueType = True
        Width = 193
      end
      object GridTakvimDBTableView1SOZLESMENO: TcxGridDBColumn
        Caption = 'S'#246'zle'#351'me No'
        DataBinding.FieldName = 'SOZLESMENO'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTakvimDBTableView1ALINISTARIHI1: TcxGridDBColumn
        Caption = 'Al'#305'n'#305#351' Tarihi'
        DataBinding.FieldName = 'ALINISTARIHI'
        DataBinding.IsNullValueType = True
        Width = 76
      end
      object GridTakvimDBTableView1KAPANISTARIHI: TcxGridDBColumn
        Caption = 'Kapan'#305#351' Tarihi'
        DataBinding.FieldName = 'KAPANISTARIHI'
        DataBinding.IsNullValueType = True
        Width = 95
      end
      object GridTakvimDBTableView1KREDITAKSIT: TcxGridDBColumn
        Caption = 'Toplam Taksit'
        DataBinding.FieldName = 'KREDITAKSIT'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1ODENENTAKSIT: TcxGridDBColumn
        Caption = #214'denen Taksit'
        DataBinding.FieldName = 'ODENENTAKSIT'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1KALANTAKSIT: TcxGridDBColumn
        Caption = 'Kalan Taksit'
        DataBinding.FieldName = 'KALANTAKSIT'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1TAKSITTUTARI: TcxGridDBColumn
        Caption = 'Taksit Tutar'#305
        DataBinding.FieldName = 'TAKSITTUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 81
      end
      object GridTakvimDBTableView1KUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1DURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Kapal'#305
            ImageIndex = 0
            Value = False
          end
          item
            Description = 'A'#231#305'k'
            Value = True
          end>
      end
      object GridTakvimDBTableView1SUBEADI: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEADI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTakvimDBTableView1TOPLAM_TUTAR: TcxGridDBColumn
        Caption = 'Toplam Tutar'
        DataBinding.FieldName = 'TOPLAM_TUTAR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 74
      end
      object GridTakvimDBTableView1TOPLAM_ANAPARA: TcxGridDBColumn
        Caption = 'Toplam Anapara'
        DataBinding.FieldName = 'TOPLAM_ANAPARA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 88
      end
      object GridTakvimDBTableView1TOPLAM_GIDER: TcxGridDBColumn
        Caption = 'Toplam Gider'
        DataBinding.FieldName = 'TOPLAM_GIDER'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 76
      end
      object GridTakvimDBTableView1ODENEN_TUTAR: TcxGridDBColumn
        Caption = #214'denen Tutar'
        DataBinding.FieldName = 'ODENEN_TUTAR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 78
      end
      object GridTakvimDBTableView1ODENEN_ANAPARA: TcxGridDBColumn
        Caption = #214'denen Anapara'
        DataBinding.FieldName = 'ODENEN_ANAPARA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 91
      end
      object GridTakvimDBTableView1ODENEN_GIDER: TcxGridDBColumn
        Caption = #214'denen Gider'
        DataBinding.FieldName = 'ODENEN_GIDER'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 77
      end
      object GridTakvimDBTableView1KALAN_TUTAR: TcxGridDBColumn
        Caption = 'Kalan Tutar'
        DataBinding.FieldName = 'KALAN_TUTAR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 65
      end
      object GridTakvimDBTableView1KALAN_ANAPARA: TcxGridDBColumn
        Caption = 'Kalan Anapara'
        DataBinding.FieldName = 'KALAN_ANAPARA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 77
      end
      object GridTakvimDBTableView1KALAN_GIDER: TcxGridDBColumn
        Caption = 'Kalan Gider'
        DataBinding.FieldName = 'KALAN_GIDER'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 65
      end
      object GridTakvimDBTableView1KREDILIMITSURE: TcxGridDBColumn
        Caption = 'Limit S'#252're'
        DataBinding.FieldName = 'KREDILIMITSURE'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1KREDILIMIT: TcxGridDBColumn
        Caption = 'Limit'
        DataBinding.FieldName = 'KREDILIMIT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
      end
      object GridTakvimDBTableView1KREDIKULLANIMSURE: TcxGridDBColumn
        Caption = 'Kullan'#305'm S'#252'resi'
        DataBinding.FieldName = 'KREDIKULLANIMSURE'
        DataBinding.IsNullValueType = True
      end
      object GridTakvimDBTableView1KREDIEKLIMITVAR: TcxGridDBColumn
        Caption = 'Ek Limit'
        DataBinding.FieldName = 'KREDIEKLIMITVAR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
      end
      object GridTakvimDBTableView1REVIZYONTARIHI: TcxGridDBColumn
        Caption = 'Revizyon Tarihi'
        DataBinding.FieldName = 'REVIZYONTARIHI'
        DataBinding.IsNullValueType = True
      end
    end
    object GridTakvimLevel1: TcxGridLevel
      GridView = GridTakvimDBTableView1
    end
  end
  object PageControlSekme: TcxPageControl
    Left = 0
    Top = 267
    Width = 874
    Height = 325
    Align = alBottom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Properties.ActivePage = TabSheetEkstre
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlSekmeChange
    ClientRectBottom = 321
    ClientRectLeft = 4
    ClientRectRight = 870
    ClientRectTop = 27
    object TabSheetIlet: TcxTabSheet
      Caption = 'Toplamlar'
      ImageIndex = 7
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object TabSheetEkstre: TcxTabSheet
      Caption = 'Ekstre'
      ImageIndex = 6
      OnShow = TabSheetEkstreShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 44
        Width = 866
        Height = 250
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridHareketler: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridHareketlerCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsCariListe
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = cxGridHareketlerBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = cxGridHareketlerALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = cxGridHareketlerBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = cxGridHareketlerALACAK
            end
            item
              Format = ',0.00;(,0.00)'
              Column = cxGridHareketlerBORCBAKIYE
            end
            item
              Format = ',0.00;(,0.00)'
              Column = cxGridHareketlerALACAKBAKIYE
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object cxGridHareketlerTARIH: TcxGridDBColumn
            Caption = #304#351'lem Tarihi'
            DataBinding.FieldName = 'ISLEMTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 68
          end
          object cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Val'#246'r'
            DataBinding.FieldName = 'VALOR'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object cxGridHareketlerNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
            Width = 75
          end
          object cxGridHareketlerTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleri
          end
          object cxGridHareketlerKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 77
          end
          object cxGridHareketlerAD: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object cxGridHareketlerACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 128
          end
          object cxGridHareketlerHESAPKODU: TcxGridDBColumn
            Caption = 'Hesap Kodu'
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            Width = 91
          end
          object cxGridHareketlerHESAPADI: TcxGridDBColumn
            Caption = 'Hesap Ad'#305
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 82
          end
          object cxGridHareketlerKUR: TcxGridDBColumn
            Caption = 'Para Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Width = 76
          end
          object cxGridHareketlerBORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 56
          end
          object cxGridHareketlerALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 67
          end
          object cxGridHareketlerBORCBAKIYE: TcxGridDBColumn
            Caption = 'B.Bakiye'
            DataBinding.FieldName = 'BORCBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 54
          end
          object cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn
            Caption = 'A.Bakiye'
            DataBinding.FieldName = 'ALACAKBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 56
          end
        end
        object cxGrid1DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGrid1DBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object cxGrid1DBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object cxGrid1DBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGridHareketler
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 866
        Height = 44
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 1
        object ToolBar11: TToolBar
          Left = 1
          Top = 1
          Width = 528
          Height = 42
          Margins.Bottom = 0
          Align = alLeft
          ButtonHeight = 47
          ButtonWidth = 72
          Caption = 'AletCubugu'
          Ctl3D = False
          DockSite = True
          DrawingStyle = dsGradient
          EdgeInner = esNone
          EdgeOuter = esNone
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          Images = Tablo.PNGImageList1
          ShowCaptions = True
          TabOrder = 0
          Wrapable = False
          object AnaparaEkleTus: TToolButton
            Left = 0
            Top = 0
            Hint = 'Anapara Giri'#351'i'
            Caption = 'Anapara'
            ImageIndex = 7
            ImageName = 'PngImage6'
            ParentShowHint = False
            ShowHint = True
            OnClick = AnaparaEkleTusClick
          end
          object AnaparaOdemeTus: TToolButton
            Left = 72
            Top = 0
            Hint = 'Anapara '#214'demesi'
            Caption = 'Anapara'
            ImageIndex = 49
            ImageName = 'PngImage49'
            ParentShowHint = False
            ShowHint = True
            OnClick = AnaparaOdemeTusClick
          end
          object ToolButton6: TToolButton
            Left = 144
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 10
            ImageName = 'PngImage9'
            Style = tbsSeparator
            Visible = False
          end
          object MasrafEkleTus: TToolButton
            Left = 152
            Top = 0
            Hint = 'Masraf Giri'#351'i'
            Caption = 'Masraf'
            DropdownMenu = PopupRotatifMasrafEkleMenu
            ImageIndex = 7
            ImageName = 'PngImage6'
            ParentShowHint = False
            ShowHint = True
            Visible = False
          end
          object MasrafOdemeTus: TToolButton
            Left = 224
            Top = 0
            Hint = 'Masraf '#214'demesi'
            Caption = 'Masraf'
            DropdownMenu = PopupRotatifMasrafOdeMenu
            ImageIndex = 49
            ImageName = 'PngImage49'
            ParentShowHint = False
            ShowHint = True
            Visible = False
          end
          object ToolButton8: TToolButton
            Left = 296
            Top = 0
            Width = 8
            Caption = 'ToolButton8'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object SilTus: TToolButton
            Left = 304
            Top = 0
            Hint = 'sat'#305'r Sil'
            Caption = 'Sil'
            ImageIndex = 8
            ImageName = 'PngImage7'
            ParentShowHint = False
            ShowHint = True
            OnClick = SilTusClick
          end
          object DonemOranTus: TToolButton
            Left = 376
            Top = 0
            Hint = 'Bu Kredi '#304#231'in Faiz Oranlar'#305' Giri'#351'i'
            Caption = 'Faiz Oranlar'#305
            ImageIndex = 43
            ImageName = 'PngImage43'
            ParentShowHint = False
            ShowHint = True
            Visible = False
            OnClick = DonemOranTusClick
          end
          object ToolButton9: TToolButton
            Left = 448
            Top = 0
            Width = 8
            Caption = 'ToolButton9'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
        end
        object JvNavPanelHeader2: TJvNavPanelHeader
          Left = 529
          Top = 1
          Width = 336
          Height = 42
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 0
          object Label2: TLabel
            Left = 202
            Top = 11
            Width = 26
            Height = 18
            Caption = 'Biti'#351
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
          end
          object Label1: TLabel
            Left = 7
            Top = 11
            Width = 48
            Height = 18
            Caption = 'Ba'#351'lama'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
          end
          object CalendarEkstreBit: TcxDateEdit
            Left = 231
            Top = 7
            EditValue = 40941d
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 0
            Width = 121
          end
          object CalendarEkstreBas: TcxDateEdit
            Left = 62
            Top = 7
            EditValue = 40909d
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 121
          end
          object CheckMasrafGoster: TcxCheckBox
            Left = 364
            Top = 9
            Caption = 'Masraflar'#305' da G'#246'ster'
            ParentFont = False
            Properties.Alignment = taLeftJustify
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWhite
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 2
            Transparent = True
            OnClick = CheckMasrafGosterClick
          end
        end
      end
    end
    object TabSheetCekKocan: TcxTabSheet
      Caption = #199'ek Ko'#231'an'#305' Listesi'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 860
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 61
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
        Font.Name = 'Arial'
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
        object YeniKocanTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = YeniKocanTusClick
        end
        object KaydetKocanTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = KaydetKocanTusClick
        end
        object IptalKocanTus: TToolButton
          Left = 122
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          OnClick = IptalKocanTusClick
        end
        object SilKocanTus: TToolButton
          Left = 183
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilKocanTusClick
        end
      end
      object GridCekKocan: TcxGrid
        Left = 0
        Top = 27
        Width = 866
        Height = 267
        Align = alClient
        PopupMenu = PopupRotatif
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridCekKocanView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsCekKocan
          DataController.Summary.DefaultGroupSummaryItems = <
            item
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Appending = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          object GridCekKocanViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridCekKocanViewKREDIID: TcxGridDBColumn
            DataBinding.FieldName = 'KREDIID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridCekKocanViewKOCANNO: TcxGridDBColumn
            Caption = 'Ko'#231'an No'
            DataBinding.FieldName = 'KOCANNO'
            DataBinding.IsNullValueType = True
            MinWidth = 60
            Width = 80
          end
          object GridCekKocanViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            MinWidth = 60
            Width = 97
          end
          object GridCekKocanViewBASSERINO: TcxGridDBColumn
            Caption = 'Ba'#351'lama Seri No'
            DataBinding.FieldName = 'BASSERINO'
            DataBinding.IsNullValueType = True
            MinWidth = 60
            Width = 103
          end
          object GridCekKocanViewBITSERINO: TcxGridDBColumn
            Caption = 'Biti'#351' Seri No'
            DataBinding.FieldName = 'BITSERINO'
            DataBinding.IsNullValueType = True
            MinWidth = 60
            Width = 89
          end
          object GridCekKocanViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            MinWidth = 60
            Width = 295
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridCekKocanView
        end
      end
    end
    object TabRotatif: TcxTabSheet
      Caption = 'Rotatif'
      ImageIndex = 2
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PanelDurum: TPanel
        Left = 0
        Top = 132
        Width = 866
        Height = 162
        Align = alBottom
        Caption = 'PanelDurum'
        TabOrder = 0
        Visible = False
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 858
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 55
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
          Font.Name = 'Arial'
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
          object KapatTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kapat'
            ImageIndex = 14
            ImageName = 'PngImage14'
            OnClick = KapatTusClick
          end
          object ToolButton4: TToolButton
            Left = 55
            Top = 0
            Width = 19
            Caption = 'ToolButton3'
            ImageIndex = 15
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
          object cxLabel16: TcxLabel
            Left = 74
            Top = 2
            Caption = 'Hesaplama Biti'#351' Tarihi : '
            Transparent = True
          end
          object HesaplamaTarihi: TcxDateEdit
            Left = 191
            Top = 0
            Properties.OnCloseUp = HesaplamaTarihiPropertiesCloseUp
            TabOrder = 0
            Width = 121
          end
          object CheckValor: TcxCheckBox
            Left = 312
            Top = 0
            Caption = 'Val'#246'r'
            Properties.Alignment = taLeftJustify
            Properties.OnChange = HesaplamaTarihiPropertiesCloseUp
            TabOrder = 1
            Transparent = True
          end
        end
        object cxGrid5: TcxGrid
          Left = 1
          Top = 28
          Width = 864
          Height = 133
          Align = alClient
          PopupMenu = PopupRotatif
          TabOrder = 1
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object cxGridDBTableView4: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsROTATIFDURUM
            DataController.Summary.DefaultGroupSummaryItems = <
              item
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = cxGridDBColumn7
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = cxGridDBColumn8
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = cxGridDBColumn10
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 72
            end
            object cxGridDBColumn4: TcxGridDBColumn
              Caption = 'Referans No'
              DataBinding.FieldName = 'KREDIREFERANSNO'
              DataBinding.IsNullValueType = True
              Width = 79
            end
            object cxGridDBColumn7: TcxGridDBColumn
              Caption = 'Bakiye'
              DataBinding.FieldName = 'BAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 66
            end
            object cxGridDBColumn8: TcxGridDBColumn
              Caption = 'Faiz+BSMV'
              DataBinding.FieldName = 'FAIZ'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 41
            end
            object cxGridDBColumn10: TcxGridDBColumn
              Caption = 'Toplam'
              DataBinding.FieldName = 'TOPLAM'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 55
            end
          end
          object cxGridLevel5: TcxGridLevel
            GridView = cxGridDBTableView4
          end
        end
        object MemoRotatSQL: TMemo
          Left = 110
          Top = 33
          Width = 583
          Height = 56
          Lines.Strings = (
            
              'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##R' +
              'OTA_SPID_%'#39')'
            'DROP TABLE ##ROTA_SPID_'
            ''
            'CREATE TABLE ##ROTA_SPID_('
            #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
            #9'[KREDIREFERANSNO] [nvarchar(50)] NULL,'
            #9'[TARIH] [datetime]  NULL,'
            #9'[BAKIYE] [money] NULL,'
            #9'[FAIZ] [money] NULL,'
            #9'[BSMV] [money] NULL,'
            #9'[TOPLAM] [money] NULL,'
            #9'[VALOR] bit null'
            ')'
            ''
            'INSERT INTO ##ROTA_SPID_'
            
              'select KREDIREFERANSNO, TARIH,BAKIYE, KALANFAIZ as FAIZ, 0 as BS' +
              'MV, 0 as TOPLAM, VALOR'
            'from KREDIROTATIF KR'
            'where BAKIYE>1 '
            
              'and ID = (SELECT MAX(ID) from KREDIROTATIF where KREDIREFERANSNO' +
              '=KR.KREDIREFERANSNO)'
            'and kosul3'
            ''
            'select * from ##ROTA_SPID_'
            '')
          TabOrder = 2
          Visible = False
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 866
        Height = 132
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 1
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 858
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
          Font.Name = 'Arial'
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
          object KrediEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kredi Ekle'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = KrediEkleTusClick
          end
          object OdemeSilTus: TToolButton
            Left = 96
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = OdemeSilTusClick
          end
          object OdemeEkleTus: TToolButton
            Left = 192
            Top = 0
            Caption = #214'deme Ekle'
            ImageIndex = 0
            ImageName = 'PngImage0'
            Style = tbsTextButton
            OnClick = OdemeEkleTusClick
          end
          object CheckKapanmis: TcxCheckBox
            Left = 288
            Top = 0
            Caption = 'Kapanm'#305#351' kredileri g'#246'ster'
            TabOrder = 0
            Transparent = True
          end
          object DurumRaporuTus: TToolButton
            Left = 431
            Top = 0
            Caption = 'Durum Raporu'
            ImageIndex = 8
            ImageName = 'PngImage15'
          end
          object ToolButton5: TToolButton
            Left = 527
            Top = 0
            Caption = 'D'#246'nem / Oran'
            ImageIndex = 22
            ImageName = 'PngImage22'
            OnClick = ToolButton5Click
          end
        end
        object GridRotatif: TcxGrid
          Left = 1
          Top = 28
          Width = 864
          Height = 103
          Align = alClient
          PopupMenu = PopupRotatif
          TabOrder = 1
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object GridRotatifView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsRotatif
            DataController.Summary.DefaultGroupSummaryItems = <
              item
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1TUTAR
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1ODENEN
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1FAIZTUTARI
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1BSMV
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1TOPLAM
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridRotatifView1ODENENFAIZ
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            object GridRotatifView1ID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridRotatifView1KREDIID: TcxGridDBColumn
              DataBinding.FieldName = 'KREDIID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridRotatifView1TARIH: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 72
            end
            object GridRotatifView1KREDIREFERANSNO: TcxGridDBColumn
              Caption = 'Referans No'
              DataBinding.FieldName = 'KREDIREFERANSNO'
              DataBinding.IsNullValueType = True
              Width = 79
            end
            object GridRotatifView1TUTAR: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 61
            end
            object GridRotatifView1ODENEN: TcxGridDBColumn
              Caption = #214'denen'
              DataBinding.FieldName = 'ODENEN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 65
            end
            object GridRotatifView1BAKIYE: TcxGridDBColumn
              Caption = 'Bakiye'
              DataBinding.FieldName = 'BAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 66
            end
            object GridRotatifView1FAIZTUTARI: TcxGridDBColumn
              Caption = 'Faiz'
              DataBinding.FieldName = 'FAIZTUTARI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 41
            end
            object GridRotatifView1BSMV: TcxGridDBColumn
              DataBinding.FieldName = 'BSMV'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 45
            end
            object GridRotatifView1TOPLAM: TcxGridDBColumn
              Caption = 'Toplam'
              DataBinding.FieldName = 'TOPLAM'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 55
            end
            object GridRotatifView1ODENENFAIZ: TcxGridDBColumn
              Caption = #214'd.Faiz'
              DataBinding.FieldName = 'ODENENFAIZ'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 48
            end
            object GridRotatifView1KALANFAIZ: TcxGridDBColumn
              Caption = 'Kalan'
              DataBinding.FieldName = 'KALANFAIZ'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 50
            end
            object GridRotatifView1KUR: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridRotatifView1ACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 83
            end
            object GridRotatifView1VALOR: TcxGridDBColumn
              Caption = 'Val'#246'r'
              DataBinding.FieldName = 'VALOR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Options.Editing = False
              Width = 32
            end
            object GridRotatifView1ODENMIS: TcxGridDBColumn
              Caption = #214'dendi'
              DataBinding.FieldName = 'ODENMIS'
              DataBinding.IsNullValueType = True
              Width = 44
            end
            object GridRotatifView1EKLEYEN: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridRotatifView1EKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridRotatifView1DEGISTIREN: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIREN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridRotatifView1DEGISTIRMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIRMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = GridRotatifView1
          end
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Caption = 'Yorum / Medya'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel7: TPanel
        Left = 0
        Top = 233
        Width = 866
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
          Width = 718
        end
        object BtnMesajGonder: TcxButton
          Left = 719
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
          Left = 804
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
        Top = 274
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
        ExplicitTop = 273
        AnchorX = 866
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 866
        Height = 233
        Align = alClient
        TabOrder = 2
        LookAndFeel.ScrollbarMode = sbmClassic
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
    Top = 260
    Width = 874
    Height = 7
    AlignSplitter = salBottom
    Control = PageControlSekme
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 874
    Height = 34
    Align = alTop
    Caption = 'Panel2'
    TabOrder = 3
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 571
      Height = 29
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 111
      Caption = 'AletCubugu'
      Color = clBtnFace
      Ctl3D = False
      DoubleBuffered = False
      DockSite = True
      DrawingStyle = dsGradient
      EdgeInner = esNone
      EdgeOuter = esNone
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentDoubleBuffered = False
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
      object KrediSilTus: TToolButton
        Left = 111
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        ImageName = 'PngImage7'
        OnClick = KrediSilTusClick
      end
      object DegisTus: TToolButton
        Left = 222
        Top = 0
        Caption = 'D'#252'zenle'
        ImageIndex = 9
        ImageName = 'PngImage8'
        Style = tbsTextButton
        OnClick = DegisTusClick
      end
      object ToolButton1: TToolButton
        Left = 333
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 10
        ImageName = 'PngImage9'
        Style = tbsSeparator
      end
      object YaziciYaz: TToolButton
        Left = 341
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        ImageName = 'PngImage15'
        Style = tbsTextButton
      end
      object ToolButton3: TToolButton
        Left = 452
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 17
        ImageName = 'PngImage16'
        Style = tbsSeparator
      end
      object ToolButton2: TToolButton
        Left = 460
        Top = 0
        Caption = 'Hesap Makinas'#305
        ImageIndex = 3
        ImageName = 'PngImage18'
        OnClick = ToolButton2Click
      end
    end
    object JvNavPanelHeader1: TJvNavPanelHeader
      Left = 572
      Top = 1
      Width = 301
      Height = 32
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object CheckAktifPasif: TcxCheckBox
        Left = 0
        Top = 0
        Align = alLeft
        Caption = 'Pasifleri de g'#246'ster'
        ParentFont = False
        Properties.ImmediatePost = True
        Properties.OnChange = cxCheckBox1PropertiesChange
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
        TabOrder = 0
        Transparent = True
      end
      object EdKrediTrh: TcxDateEdit
        Left = 142
        Top = 0
        Align = alLeft
        TabOrder = 1
        Visible = False
        Width = 121
      end
    end
  end
  object DtsKrediler: TDataSource
    DataSet = KREDILER
    Left = 169
    Top = 136
  end
  object KREDILER: TFDQuery
    AfterScroll = KREDILERAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'DECLARE @PDURUM INT, @PTARIH datetime'
      ''
      'SET @PDURUM= :PDrm'
      'SET @PTARIH= :PTrh'
      ''
      'select '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KR.DURUM,'
      #9'KREDITAKSIT=count(P.ID),'
      
        #9'ODENENTAKSIT=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH the' +
        'n 1 else 0 end),'
      
        #9'KALANTAKSIT=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then' +
        ' 0 else 1 end),'
      #9'TOPLAM_TUTAR=isnull(sum(P.TAKSIT),0),'
      #9'TOPLAM_ANAPARA=isnull(sum(P.ANAPARA),0),'
      #9'TOPLAM_GIDER=isnull(sum(P.FAIZ+P.KKDF+P.BSMV),0),'
      
        #9'ODENEN_TUTAR=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH the' +
        'n P.TAKSIT else 0.0 end),'
      
        #9'ODENEN_ANAPARA=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH t' +
        'hen P.ANAPARA else 0.0 end),'
      
        #9'ODENEN_GIDER=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH the' +
        'n P.FAIZ+P.KKDF+P.BSMV else 0.0 end),'
      
        #9'KALAN_TUTAR=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then' +
        ' 0.0 else P.TAKSIT end),'
      
        #9'KALAN_ANAPARA=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH th' +
        'en 0.0 else P.ANAPARA end),'
      
        #9'KALAN_GIDER=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then' +
        ' 0.0 else P.FAIZ+P.KKDF+P.BSMV end),'
      #9'B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI'
      'from KREDILER KR'
      #9'left join PLANKREDI P on P.KREDIID=KR.ID'
      #9'inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID'
      #9'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      #9'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where '
      #9'KR.DURUM>=@PDURUM and GENELKREDITIPI in (1,11) '
      
        #9'---and exists(select 1 from PLANKREDI P2 where P2.KREDIID=KR.ID' +
        ' and P2.TARIH<=@PTARIH)'
      #9'and ALINISTARIHI<=@PTARIH+1'
      'GROUP BY '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KREDITAKSIT,'
      
        #9'TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICA' +
        'RIHESAPID,BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI'
      '-----'
      'union all'
      '-----'
      'select '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KR.DURUM,'
      #9'KREDITAKSIT= 0,'
      #9'ODENENTAKSIT = 0,'
      #9'KALANTAKSIT = 0,'
      
        #9'TOPLAM_TUTAR=isnull(sum(BORC),0)+([dbo].[fn_RotatifFaizHesapla]' +
        '  (KR.ID, '#39'2000.01.01 00:00'#39', @PTARIH-1, 0)),'
      #9'TOPLAM_ANAPARA=isnull(sum(BORC),0),'
      
        '--'#9'TOPLAM_GIDER=(SELECT isnull(sum(DOVIZ_TUTARI),0.0) FROM FATBA' +
        'SLIK FB '
      '--     where FB.TUR= 13 and FB.YERI=47 AND FB.YERID=KR.ID),'
      ''
      
        #9'TOPLAM_GIDER=[dbo].[fn_RotatifFaizHesapla]  (KR.ID, '#39'2000.01.01' +
        ' 00:00'#39', @PTARIH-1, 0),'
      ''
      ''
      
        #9'ODENEN_TUTAR=isnull(sum(ALACAK),0)+(SELECT isnull(sum(BORC),0.0' +
        ') FROM KASA K where K.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),'
      #9'ODENEN_ANAPARA=isnull(sum(ALACAK),0),'
      
        #9'ODENEN_GIDER=(SELECT isnull(sum(BORC),0.0) FROM KASA K where K.' +
        'TUR=32 and K.YERI=47 AND K.YERID=KR.ID),'
      
        #9'KALAN_TUTAR=isnull(sum(BORC-ALACAK),0)+[dbo].[fn_RotatifFaizHes' +
        'apla]  (KR.ID, '#39'2000.01.01 00:00'#39', @PTARIH-1, 0)'
      
        #9'            - (SELECT isnull(sum(BORC),0.0) FROM KASA K where K' +
        '.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),'
      #9'KALAN_ANAPARA=isnull(sum(BORC-ALACAK),0),'
      
        #9'KALAN_GIDER=[dbo].[fn_RotatifFaizHesapla]  (KR.ID, '#39'2000.01.01 ' +
        '00:00'#39', @PTARIH-1, 0)'
      
        #9'            - (SELECT isnull(sum(BORC),0.0) FROM KASA K where K' +
        '.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),'
      #9'B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI'
      'from KREDILER KR'
      
        #9'left outer join KASA KS on HESAPTURU='#39'R'#39' and KS.HESAPID=KR.ID a' +
        'nd KS.HESAPID=KR.ID and KS.TUR<>2 and KS.ISLEMTARIHI<=@PTARIH+1'
      #9'inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID'
      #9'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      #9'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where '
      #9'KR.DURUM>=@PDURUM '
      #9'and GENELKREDITIPI = 2 '
      'GROUP BY '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KREDITAKSIT,'
      
        #9'TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICA' +
        'RIHESAPID,BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI'
      ''
      #9'-----'
      'union all'
      '-----'#199'ek ko'#231'an'#305
      'select '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KR.DURUM,'
      #9'KREDITAKSIT= 0,'
      #9'ODENENTAKSIT = 0,'
      #9'KALANTAKSIT = 0,'
      #9'TOPLAM_TUTAR=0,'
      #9'TOPLAM_ANAPARA=0,'
      #9'TOPLAM_GIDER=0,'
      #9'ODENEN_TUTAR=0,'
      #9'ODENEN_ANAPARA=0,'
      #9'ODENEN_GIDER=0,'
      #9'KALAN_TUTAR=0,'
      #9'KALAN_ANAPARA=0,'
      #9'KALAN_GIDER=0,'
      #9'B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI'
      'from KREDILER KR'
      
        #9'left outer join KASA KS on HESAPTURU='#39'R'#39' and KS.HESAPID=KR.ID a' +
        'nd KS.HESAPID=KR.ID and KS.TUR<>2 and KS.ISLEMTARIHI<=@PTARIH+1'
      #9'inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID'
      #9'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      #9'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where '
      #9'KR.DURUM>=@PDURUM '
      #9'and GENELKREDITIPI = 31 '
      'GROUP BY '
      
        #9'KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARI' +
        'HI,KAPANISTARIHI,KREDITAKSIT,'
      
        #9'TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICA' +
        'RIHESAPID,BH.KUR,'
      
        #9'KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KRED' +
        'ILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI')
    Left = 97
    Top = 136
    ParamData = <
      item
        Name = 'PDrm'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTrh'
        Size = -1
        Value = Null
      end>
  end
  object EKSTRE: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select CEKID=ID,TARIH,TUR, REHBERID,  CARIKOD AS KOD, CARIUNVAN ' +
        'AS AD, ACIKLAMA=NOTLAR, HESAPID, HESAPKODU, HESAPADI,DURUM, '
      
        '   BORC = case when TUR in(33,34) then cast(TUTAR as money) else' +
        ' 0 end, '
      
        '    ALACAK= case when TUR in(23,24) then cast(TUTAR as money) el' +
        'se 0 end,KUR From CEKLER (NOLOCK) ')
    Left = 468
    Top = 244
  end
  object TabCariListe1: TFDQuery
    Connection = Tablo.FDCnn
    Left = 387
    Top = 245
    object DateTimeField1: TDateTimeField
      FieldName = 'TARIH'
    end
    object StringField1: TStringField
      FieldName = 'KOD'
      FixedChar = True
      Size = 30
    end
    object StringField2: TStringField
      FieldName = 'AD'
      FixedChar = True
      Size = 50
    end
    object StringField3: TStringField
      FieldName = 'ACIKLAMA'
      FixedChar = True
      Size = 30
    end
    object StringField4: TStringField
      FieldName = 'HESAPKODU'
      FixedChar = True
    end
    object StringField5: TStringField
      FieldName = 'HESAPADI'
      FixedChar = True
      Size = 50
    end
    object StringField6: TStringField
      FieldName = 'KUR'
      FixedChar = True
      Size = 6
    end
    object BCDField1: TBCDField
      FieldName = 'BORC'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object BCDField2: TBCDField
      FieldName = 'ALACAK'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object TabCariListe1DURUM: TSmallintField
      FieldName = 'DURUM'
    end
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = EKSTRE
    BCDToCurrency = False
    DataSetOptions = []
    Left = 369
    Top = 134
  end
  object DtsCariListe: TDataSource
    DataSet = EKSTRE
    Left = 669
    Top = 240
  end
  object PopupMenuYaz: TPopupMenu
    Left = 92
    Top = 387
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
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
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxKredi: TfrxDBDataset
    UserName = 'KREDILER'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 474
    Top = 137
  end
  object KrediMenu: TPopupMenu
    Left = 238
    Top = 145
    object arihSe1: TMenuItem
      Caption = 'Durum Tarihi Se'#231
      OnClick = arihSe1Click
    end
    object YeniBanka1: TMenuItem
      Caption = 'Yeni Kredi Olu'#351'tur'
      OnClick = YeniTusClick
    end
    object HesabDzenle1: TMenuItem
      Caption = 'Krediyi D'#252'zenle'
      OnClick = DegisTusClick
    end
    object HesabSil1: TMenuItem
      Caption = 'Krediyi Sil'
      OnClick = KrediSilTusClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
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
    Left = 327
    Top = 265
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
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 207
    Top = 364
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 512
    Top = 294
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
    Left = 672
    Top = 296
  end
  object ROTATIFDURUM: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM KREDIROTATIFFAIZ where KREDIID=:ID')
    Left = 576
    Top = 396
    ParamData = <
      item
        Name = 'ID'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = 1
      end>
  end
  object DtsROTATIFDURUM: TDataSource
    DataSet = ROTATIFDURUM
    Left = 676
    Top = 415
  end
  object DtsRotatif: TDataSource
    AutoEdit = False
    DataSet = KREDIROTATIF
    Left = 665
    Top = 459
  end
  object KREDIROTATIF: TFDQuery
    BeforeEdit = KREDIROTATIFBeforeEdit
    BeforePost = KREDIROTATIFBeforePost
    AfterPost = KREDIROTATIFAfterPost
    OnNewRecord = KREDIROTATIFNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT * FROM KREDIROTATIF where KREDIID=:ID and ODENMIS = :ODE ' +
        'order by KREDIREFERANSNO, ID')
    Left = 600
    Top = 466
    ParamData = <
      item
        Name = 'ID'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = 1
      end
      item
        Name = 'ODE'
        DataType = ftBoolean
        Precision = 255
        NumericScale = 255
        Size = 2
        Value = Null
      end>
  end
  object PopupRotatif: TPopupMenu
    Left = 813
    Top = 319
    object KrediyiEkleMenu: TMenuItem
      Caption = 'Al'#305'nan bu kredi miktar'#305'n'#305' hesaba ekle'
    end
  end
  object PopupRotatifMasrafEkleMenu: TPopupMenu
    Left = 85
    Top = 439
    object RotatifFaizrMasrafEkleMenu: TMenuItem
      Caption = 'D'#246'nem Faizi Hesapla ve Tahakkuk  Ettir'
      OnClick = RotatifFaizrMasrafEkleMenuClick
    end
    object RotatifDigerTurMasrafEkleMenu: TMenuItem
      Caption = 'Di'#287'er T'#252'r Masraf Tahakkuk Ettir'
      OnClick = RotatifDigerTurMasrafEkleMenuClick
    end
  end
  object PopupRotatifMasrafOdeMenu: TPopupMenu
    Left = 261
    Top = 407
    object DonemFaiziOdeMenu: TMenuItem
      Caption = 'D'#246'nem Faizi '#214'de'
      OnClick = DonemFaiziOdeMenuClick
    end
    object DigerMasrafOdeMenu: TMenuItem
      Caption = 'Di'#287'er Masraf '#214'de'
      OnClick = DigerMasrafOdeMenuClick
    end
  end
  object TabCekKocan: TFDQuery
    BeforePost = TabCekKocanBeforePost
    OnNewRecord = TabCekKocanNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT'
      '*'
      'FROM'
      'CEKKOCAN'
      ''
      'WHERE KREDIID=:PKREDIID '
      ''
      'ORDER BY TARIH DESC')
    Left = 867
    Top = 404
    ParamData = <
      item
        Name = 'PKREDIID'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end>
  end
  object DtsCekKocan: TDataSource
    DataSet = TabCekKocan
    OnStateChange = DtsCekKocanStateChange
    Left = 963
    Top = 427
  end
end
