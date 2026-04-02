object UretimReceteDlg: TUretimReceteDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Re'#231'ete Ekran'#305
  ClientHeight = 614
  ClientWidth = 1046
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PanelSagTaraf: TPanel
    Left = 442
    Top = 0
    Width = 604
    Height = 614
    Align = alClient
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 1
    object cxDBMemo1: TcxDBMemo
      Left = 1
      Top = 552
      Align = alBottom
      DataBinding.DataField = 'NOTLAR'
      DataBinding.DataSource = DtsRecete
      TabOrder = 0
      Height = 61
      Width = 602
    end
    object PanelSagUst: TPanel
      Left = 1
      Top = 104
      Width = 602
      Height = 32
      Align = alTop
      Color = clSkyBlue
      ParentBackground = False
      TabOrder = 2
      Visible = False
      object cxLabel1: TcxLabel
        Left = 4
        Top = 6
        Caption = #220'retim Fi'#351' No'
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 301
        Top = 6
        Caption = #220'retim Fi'#351' Tarihi'
        Transparent = True
      end
      object cxDBLabel1: TcxDBLabel
        Left = 104
        Top = 6
        DataBinding.DataField = 'URETIM_FIS_NO'
        DataBinding.DataSource = DtsReceteDetay
        Transparent = True
        Height = 21
        Width = 121
      end
      object cxDBLabel2: TcxDBLabel
        Left = 387
        Top = 6
        DataBinding.DataField = 'URETIM_FIS_TARIHI'
        DataBinding.DataSource = DtsReceteDetay
        Transparent = True
        Height = 21
        Width = 121
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 602
      Height = 103
      Align = alTop
      Color = clSilver
      ParentBackground = False
      TabOrder = 3
      object cxLabel3: TcxLabel
        Left = 9
        Top = 35
        Caption = 'Kod'
        Transparent = True
      end
      object cxLabel4: TcxLabel
        Left = 14
        Top = 58
        Caption = 'Ad'
        Transparent = True
      end
      object cxDBLabel3: TcxDBLabel
        Left = 53
        Top = 35
        DataBinding.DataField = 'KOD'
        DataBinding.DataSource = DtsRecete
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 177
      end
      object cxDBLabel4: TcxDBLabel
        Left = 53
        Top = 58
        DataBinding.DataField = 'STOKADI'
        DataBinding.DataSource = DtsRecete
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        Transparent = True
        Height = 39
        Width = 180
      end
      object cxLabel5: TcxLabel
        Left = 257
        Top = 58
        Caption = 'Liste Fiyat'#305
        Transparent = True
      end
      object cxDBLabel5: TcxDBCurrencyEdit
        Left = 318
        Top = 59
        DataBinding.DataField = 'LISTE_SATIS'
        DataBinding.DataSource = DtsRecete
        ParentColor = True
        ParentFont = False
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Properties.ReadOnly = True
        Style.Edges = []
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = False
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        StyleReadOnly.LookAndFeel.NativeStyle = False
        TabOrder = 5
        Width = 43
      end
      object cxDBLabel6: TcxDBCurrencyEdit
        Left = 736
        Top = 33
        DataBinding.DataField = 'TAVSIYE_ORT'
        DataBinding.DataSource = DtsRecete
        ParentColor = True
        ParentFont = False
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Properties.ReadOnly = True
        Style.Edges = []
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = False
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        StyleReadOnly.LookAndFeel.NativeStyle = False
        TabOrder = 6
        Visible = False
        Width = 57
      end
      object cxLabel6: TcxLabel
        Left = 635
        Top = 32
        Caption = 'Tavsiye Liste Fiyat'#305
        Transparent = True
        Visible = False
      end
      object cxLabel7: TcxLabel
        Left = 496
        Top = 33
        Caption = 'T'#252'r'
        Transparent = True
      end
      object cxLabel8: TcxLabel
        Left = 460
        Top = 58
        Caption = 'Tavsiye %'
        Transparent = True
      end
      object EditEkVergi: TcxDBCurrencyEdit
        Left = 523
        Top = 55
        DataBinding.DataField = 'TAVSIYE_SATIS_ORANI'
        DataBinding.DataSource = DtsRecete
        ParentColor = True
        ParentFont = False
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Properties.ReadOnly = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
        TabOrder = 10
        Width = 54
      end
      object cxDBImageComboBox1: TcxDBImageComboBox
        Left = 522
        Top = 30
        DataBinding.DataField = 'TUR'
        DataBinding.DataSource = DtsRecete
        ParentColor = True
        ParentFont = False
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Pasif'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'S'#305'cak '#220'retim'
            Value = 1
          end
          item
            Description = 'Haz'#305'r '#220'retim'
            Value = 2
          end>
        Style.BorderStyle = ebsOffice11
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TransparentBorder = True
        Style.ButtonTransparency = ebtNone
        Style.IsFontAssigned = True
        TabOrder = 11
        Width = 93
      end
      object cxDBLabel7: TcxDBCurrencyEdit
        Left = 318
        Top = 83
        DataBinding.DataField = 'KAR'
        DataBinding.DataSource = DtsRecete
        ParentColor = True
        ParentFont = False
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Properties.ReadOnly = True
        Style.Edges = []
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = False
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        StyleReadOnly.LookAndFeel.NativeStyle = False
        TabOrder = 12
        Width = 43
      end
      object cxLabel9: TcxLabel
        Left = 275
        Top = 81
        Caption = ' Kar %'
        Transparent = True
      end
      object ToolBarSag: TToolBar
        Left = 1
        Top = 1
        Width = 600
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 75
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
        TabOrder = 14
        Transparent = True
        object BilesenEkleBtn: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni Sarf'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = BilesenEkleBtnClick
        end
        object UrunEkleBtn: TToolButton
          Left = 75
          Top = 0
          Caption = 'Yeni '#220'r'#252'n'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = UrunEkleBtnClick
        end
        object DetaySilBtn: TToolButton
          Left = 150
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = DetaySilBtnClick
        end
        object DetayKaydetBtn: TToolButton
          Left = 225
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = DetayKaydetBtnClick
        end
        object DetayIptalBtn: TToolButton
          Left = 300
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          OnClick = DetayIptalBtnClick
        end
        object YaziciYaz: TToolButton
          Left = 375
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 8
          ImageName = 'PngImage15'
        end
      end
      object CheckKDV: TcxCheckBox
        Left = 520
        Top = 80
        Caption = 'KDV Hari'#231
        Properties.OnEditValueChanged = CheckKDVPropertiesEditValueChanged
        TabOrder = 15
        OnClick = CheckKDVClick
      end
      object cxDBLabel8: TcxDBLabel
        Left = 318
        Top = 35
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsRecete
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Segoe UI'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 121
      end
      object cxLabel10: TcxLabel
        Left = 274
        Top = 35
        Caption = 'ID'
        Transparent = True
      end
    end
    object PageControlOpr: TcxPageControl
      Left = 1
      Top = 136
      Width = 602
      Height = 416
      Align = alClient
      TabOrder = 5
      Properties.ActivePage = cxTabSheet1
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControlOprChange
      ClientRectBottom = 412
      ClientRectLeft = 4
      ClientRectRight = 598
      ClientRectTop = 24
      object cxTabSheet1: TcxTabSheet
        Caption = 'Malzeme'
        ImageIndex = 0
        object GridUretim: TcxGrid
          Left = 0
          Top = 0
          Width = 594
          Height = 388
          Align = alClient
          PopupMenu = PopupMenuDetay
          TabOrder = 0
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridUretimDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridUretimDBTableView1CanFocusRecord
            DataController.DataSource = DtsReceteDetay
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            Styles.ContentOdd = Tablo.cxstSecili
            Styles.Header = Tablo.cxStyle10
            object GridUretimDBTableView1GRP: TcxGridDBColumn
              DataBinding.FieldName = 'GRP'
              RepositoryItem = Tablo.repUretimFisiGRP
              Visible = False
              GroupIndex = 0
              Options.Editing = False
              Options.Focusing = False
            end
            object GridUretimDBTableView1SIRA: TcxGridDBColumn
              Caption = 'S'#305'ra'
              DataBinding.FieldName = 'SIRA'
              DataBinding.IsNullValueType = True
              Width = 20
            end
            object GridUretimDBTableView1KOD: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNKODU'
              Options.Editing = False
              Options.Focusing = False
              Width = 67
            end
            object GridUretimDBTableView1URUNID: TcxGridDBColumn
              Caption = #220'r'#252'n ID'
              DataBinding.FieldName = 'URUNID'
              DataBinding.IsNullValueType = True
              Width = 51
            end
            object GridUretimDBTableView1URUNNO: TcxGridDBColumn
              Caption = #220'r'#252'n No'
              DataBinding.FieldName = 'URUNNO'
              Width = 200
            end
            object GridUretimDBTableView1AD: TcxGridDBColumn
              Caption = #220'r'#252'n Ad'#305
              DataBinding.FieldName = 'URUNADI'
              Options.Editing = False
              Options.Focusing = False
              Width = 147
            end
            object GridUretimDBTableView1ADETHESAP: TcxGridDBColumn
              Caption = 'Grup Adet'
              DataBinding.FieldName = 'ADETHESAP'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.0000;-,0.0000'
            end
            object GridUretimDBTableView1ADET: TcxGridDBColumn
              Caption = 'Birim Adet'
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.0000;-,0.0000'
              Options.Editing = False
              Width = 78
            end
            object GridUretimDBTableView1BIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
            end
            object GridUretimDBTableView1MASRAFAD: TcxGridDBColumn
              DataBinding.FieldName = 'MASRAFAD'
              Visible = False
              Options.Editing = False
              Width = 129
            end
            object GridUretimDBTableView1ALISMALIYETORT: TcxGridDBColumn
              Caption = 'Al'#305#351' Ort.'
              DataBinding.FieldName = 'ALISMALIYETORT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
            end
            object GridUretimDBTableView1ALISMALIYETSON: TcxGridDBColumn
              Caption = 'Al'#305#351' Son'
              DataBinding.FieldName = 'ALISMALIYETSON'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
            end
            object GridUretimDBTableView1MALIYETORT: TcxGridDBColumn
              Caption = 'Ort.Br.Maliyet'
              DataBinding.FieldName = 'BRMMALIYETORT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1TPLMALIYETORT: TcxGridDBColumn
              Caption = 'Ort.Top.Maliyet'
              DataBinding.FieldName = 'TPLMALIYETORT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1YUZDEORT: TcxGridDBColumn
              Caption = 'Ort %'
              DataBinding.FieldName = 'YUZDEORT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1MALIYETSON: TcxGridDBColumn
              AlternateCaption = 'CurrencyEdit'
              Caption = 'Son Br.Maliyet'
              DataBinding.FieldName = 'BRMMALIYETSON'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1TPLMALIYETSON: TcxGridDBColumn
              Caption = 'Son Tpl.Maliyet'
              DataBinding.FieldName = 'TPLMALIYETSON'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1YUZDESON: TcxGridDBColumn
              Caption = 'Son %'
              DataBinding.FieldName = 'YUZDESON'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
            end
            object GridUretimDBTableView1KDV: TcxGridDBColumn
              DataBinding.FieldName = 'KDV'
              Visible = False
            end
            object GridUretimDBTableView1ACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 288
            end
          end
          object GridUretimLevel1: TcxGridLevel
            GridView = GridUretimDBTableView1
          end
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = 'Operasyon Konu'
        ImageIndex = 1
        object PanelOprUst: TPanel
          Left = 0
          Top = 0
          Width = 594
          Height = 241
          Align = alTop
          TabOrder = 0
          object Panel9: TPanel
            Left = 1
            Top = 1
            Width = 592
            Height = 23
            Align = alTop
            Caption = 'Panel9'
            TabOrder = 0
            object ToolBar4: TToolBar
              Left = 1
              Top = 1
              Width = 250
              Height = 21
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonWidth = 62
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
              object KonuYeni: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = KonuYeniClick
              end
              object KonuSil: TToolButton
                Left = 62
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = KonuSilClick
              end
              object konukaydet: TToolButton
                Left = 124
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = konukaydetClick
              end
              object KonuIptal: TToolButton
                Left = 186
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = KonuIptalClick
              end
            end
            object JvNavPanelHeader5: TJvNavPanelHeader
              Left = 251
              Top = 1
              Width = 340
              Height = 21
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
            end
          end
          object GridIsZaman: TcxGrid
            Left = 1
            Top = 24
            Width = 592
            Height = 216
            Align = alClient
            TabOrder = 1
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridIsZamanView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsUretimReceteOpr
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object cxGridDBKONUSU: TcxGridDBColumn
                Caption = 'Konusu'
                DataBinding.FieldName = 'KONUSU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = cxGridDBKONUSUPropertiesButtonClick
                Width = 269
              end
              object GridIsZamanViewSURE: TcxGridDBColumn
                Caption = 'S'#252're'
                DataBinding.FieldName = 'SURE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTimeEditProperties'
              end
              object GridIsZamanViewKAYNAK: TcxGridDBColumn
                Caption = 'Kaynak'
                DataBinding.FieldName = 'KAYNAK'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridIsZamanViewKAYNAKPropertiesButtonClick
              end
              object GridIsZamanViewKAYNAKADI: TcxGridDBColumn
                Caption = 'Kaynak Ad'#305
                DataBinding.FieldName = 'KAYNAKADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Width = 188
              end
              object GridIsZamanViewSIRA: TcxGridDBColumn
                Caption = 'S'#305'ra'
                DataBinding.FieldName = 'SIRA'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxSpinEditProperties'
              end
              object GridIsZamanViewKALITE: TcxGridDBColumn
                Caption = 'Kalite'
                DataBinding.FieldName = 'KALITE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = GridIsZamanView
            end
          end
        end
        object cxSplitter2: TcxSplitter
          Left = 0
          Top = 241
          Width = 594
          Height = 8
          HotZoneClassName = 'TcxMediaPlayer8Style'
          AlignSplitter = salTop
        end
        object PanelOprAlt: TPanel
          Left = 0
          Top = 249
          Width = 594
          Height = 139
          Align = alClient
          TabOrder = 2
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 586
            Height = 24
            Margins.Bottom = 0
            Anchors = [akLeft]
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
            object YeniSablonDetayTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = YeniSablonDetayTusClick
            end
            object SilSablonDetayTus: TToolButton
              Left = 61
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = SilSablonDetayTusClick
            end
            object KaydetSablonDetayTus: TToolButton
              Left = 122
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = KaydetSablonDetayTusClick
            end
            object IptalSablonDetayTus: TToolButton
              Left = 183
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = IptalSablonDetayTusClick
            end
          end
          object GridKaliteSablon: TcxGrid
            Left = 1
            Top = 28
            Width = 592
            Height = 110
            Align = alClient
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridKaliteSablonView: TcxGridDBTableView
              PopupMenu = PopupMenuTest
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsSablonDetay
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsView.GroupByBox = False
              object GridKaliteSablonViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridKaliteSablonViewKALITESABLONID: TcxGridDBColumn
                DataBinding.FieldName = 'KALITESABLONID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 99
              end
              object GridKaliteSablonViewADI: TcxGridDBColumn
                Caption = 'Test'
                DataBinding.FieldName = 'ADI'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridKaliteSablonViewADIPropertiesButtonClick
                Width = 143
              end
              object GridKaliteSablonViewTESTID: TcxGridDBColumn
                DataBinding.FieldName = 'TESTID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridKaliteSablonViewNOMINAL: TcxGridDBColumn
                Caption = 'Nominal'
                DataBinding.FieldName = 'NOMINAL'
                DataBinding.IsNullValueType = True
                OnGetPropertiesForEdit = GridKaliteSablonViewNOMINALGetPropertiesForEdit
              end
              object GridKaliteSablonViewLIMITALT: TcxGridDBColumn
                Caption = 'Alt Tolerans'
                DataBinding.FieldName = 'LIMITALT'
                DataBinding.IsNullValueType = True
                OnGetPropertiesForEdit = GridKaliteSablonViewNOMINALGetPropertiesForEdit
                Width = 63
              end
              object GridKaliteSablonViewLIMITUST: TcxGridDBColumn
                Caption = #220'st Tolerans'
                DataBinding.FieldName = 'LIMITUST'
                DataBinding.IsNullValueType = True
                OnGetPropertiesForEdit = GridKaliteSablonViewNOMINALGetPropertiesForEdit
                Width = 69
              end
              object GridKaliteSablonViewLIMITYAZI: TcxGridDBColumn
                Caption = 'Limit Bilgi'
                DataBinding.FieldName = 'LIMITYAZI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 138
              end
              object GridKaliteSablonViewBIRIM: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.repStokAnaBirim
              end
              object GridKaliteSablonViewTOLERANSTIPI: TcxGridDBColumn
                Caption = 'Tip'
                DataBinding.FieldName = 'TOLERANSTIPI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = '+-'
                    ImageIndex = 0
                    Value = 1
                  end
                  item
                    Description = '+'
                    Value = 2
                  end
                  item
                    Description = '-'
                    Value = 3
                  end
                  item
                    Description = '%'
                    Value = 4
                  end
                  item
                    Description = 'Binde'
                    Value = 5
                  end>
              end
              object GridKaliteSablonViewTOLERANSDEGERI: TcxGridDBColumn
                Caption = 'Tolerans'
                DataBinding.FieldName = 'TOLERANSDEGERI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DecimalPlaces = 3
                Properties.DisplayFormat = ',0.000;-,0.000'
              end
              object GridKaliteSablonViewOLCUALETI: TcxGridDBColumn
                Caption = #214'l'#231#252' Aleti'
                DataBinding.FieldName = 'OLCUALETI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepKaliteOlcuAleti
              end
              object GridKaliteSablonViewSURE: TcxGridDBColumn
                Caption = 'S'#252're'
                DataBinding.FieldName = 'SURE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTimeEditProperties'
              end
              object GridKaliteSablonViewSIRA: TcxGridDBColumn
                Caption = 'S'#305'ra'
                DataBinding.FieldName = 'SIRA'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxSpinEditProperties'
              end
              object GridKaliteSablonViewGIRIS: TcxGridDBColumn
                Caption = 'Giri'#351
                DataBinding.FieldName = 'GIRIS'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Yaz'#305
                    ImageIndex = 0
                    Value = 1
                  end
                  item
                    Description = 'Rakam'
                    Value = 2
                  end
                  item
                    Description = 'Tarih'
                    Value = 3
                  end
                  item
                    Description = 'Liste (Combo)'
                    Value = 4
                  end
                  item
                    Description = 'Sec (Check)'
                    Value = 5
                  end
                  item
                    Description = 'Liste (Img Combo)'
                    Value = 6
                  end
                  item
                    Description = 'Btn Edit'
                    Value = 7
                  end
                  item
                    Description = 'Check Combo'
                    Value = 8
                  end
                  item
                    Description = 'Check Group'
                    Value = 9
                  end
                  item
                    Description = 'Mask Edit'
                    Value = 10
                  end
                  item
                    Description = 'Ba'#351'l'#305'k (Label)'
                    Value = 11
                  end
                  item
                    Description = 'Bilgi (Label)'
                    Value = 12
                  end
                  item
                    Description = 'Virg'#252'll'#252' Rakam'
                    Value = 13
                  end>
              end
              object GridKaliteSablonViewKAYNAK: TcxGridDBColumn
                Caption = 'Kaynak'
                DataBinding.FieldName = 'KAYNAK'
                DataBinding.IsNullValueType = True
                Width = 150
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = GridKaliteSablonView
            end
          end
        end
      end
    end
    object SQLDetayStandart: TcxMemo
      Left = 54
      Top = 202
      Lines.Strings = (
        'select ID,URETIMRECETEID,TUR,URUNID,ACIKLAMA,ADET=cast(ADET as '
        
          'float),BIRIM,MIKTAR=cast(MIKTAR as float),MASRAFID,ADETHESAP=cas' +
          't'
        '(ADETHESAP as float),MALIYETORT=cast(MALIYETORT as '
        'float),ANAURUN,MALIYETSON,KDVDURUM,SIRA'
        'from URETIMRECETEDETAY'
        'where URETIMRECETEID = :PURID'
        'order by SIRA'
        '')
      TabOrder = 4
      Visible = False
      Height = 41
      Width = 393
    end
    object SQLDetayGecmis: TcxMemo
      Left = 77
      Top = 297
      Lines.Strings = (
        
          ' select ID=cast(F.ID as int),URETIMRECETEID=cast(FB.YERID as int' +
          '),SIRA=cast(ROW_NUMBER() OVER(order by F.ID) as int),MASRAFID=ca' +
          'st(0 as int),KDVDURUM=cast(0 as bit),TUR=cast(F.TUR as smallint)' +
          ',URUNID=cast(URUNID as int),cast(F.ACIKLAMA as nvarchar(100)) as' +
          ' ACIKLAMA,ADET=cast(IADEADET/nullif((select ISNULL(IADEADET,0.0)' +
          ' from FATURA F2 WHERE F2.FATBASID=FB.ID AND VADE>0)  ,0) as floa' +
          't),BIRIM=cast(BIRIM as smallint),MIKTAR=cast(MIKTAR as float),MA' +
          'LIYETSON=cast(BIRIMFIYAT as money),MALIYETORT=cast(TUTAR as floa' +
          't),F.KUR,DOVIZ_BIRIMFIYAT,DOVIZ_KURU,F.DOVIZ_TUTARI,DOVIZKURDEGE' +
          'RI,'
        'BRMMALIYETORT=cast(ABS(TUTAR/FB.STOKISK) as float),'
        'BRMMALIYETSON=cast(ABS(BIRIMFIYAT/FB.STOKISK) as float),'
        'TPLMALIYETORT=cast(ABS((TUTAR/MIKTAR)*IADEADET) as float),'
        'TPLMALIYETSON=cast(ABS((BIRIMFIYAT/MIKTAR)*IADEADET) as float),'
        'ADETHESAP=cast(ISNULL(IADEADET,0.0) as float),'
        'YUZDEORT='
        
          'cast(ABS(ROUND(((TUTAR/FB.STOKISK)/(FB.FATURA_TUTARI))*100.0,2))' +
          ' as float),'
        'YUZDESON='
        
          'cast(ABS(ROUND(((BIRIMFIYAT/FB.STOKISK)/(FB.FATURA_MATRAHI))*100' +
          '.0,2)) as float),'
        
          'ANAURUN=cast(case when URUNID=FB.AKTIVITEID then 1 else 0 end as' +
          ' bit),'
        'GRP = case when MIKTAR>0 then 1 else 0 end,'
        
          'URUNKODU=CASE WHEN F.TUR=1 THEN (SELECT KOD FROM STOKLAR WHERE I' +
          'D= URUNID ) WHEN F.TUR=2 THEN (SELECT KOD FROM MASRAFGELIR WHERE' +
          ' ID= URUNID )  END,'
        
          'URUNADI=CASE WHEN F.TUR=1 THEN (SELECT STOKADI FROM STOKLAR WHER' +
          'E ID= URUNID ) WHEN F.TUR=2 THEN (SELECT AD FROM MASRAFGELIR WHE' +
          'RE ID= URUNID)  END,'
        'URETIM_FIS_NO=FB.FATURANO, URETIM_FIS_TARIHI=FB.FATURATARIH'
        'from FATURA F inner join FATBASLIK FB on FB.ID=F.FATBASID'
        'where FB.TUR=6 and FB.YERI=138 and FB.YERID=:PRM1'
        
          'and FB.ID=(select top 1 ID from FATBASLIK where TUR=6 and YERI=1' +
          '38 and YERID=:PRM2 and FATURATARIH>=:PRM3 order by ID)'
        '')
      Properties.WordWrap = False
      TabOrder = 1
      Visible = False
      Height = 41
      Width = 393
    end
  end
  object PanelSolTaraf: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 614
    Align = alLeft
    TabOrder = 0
    object UretimListeGrid: TcxGrid
      Left = 1
      Top = 104
      Width = 432
      Height = 509
      Align = alClient
      PopupMenu = PopupMenuListe
      TabOrder = 0
      LookAndFeel.ScrollbarMode = sbmClassic
      object UretimListeGridDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = UretimListeGridDBTableView1CanFocusRecord
        DataController.DataSource = DtsRecete
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'STOKADI'
            Column = UretimListeGridDBTableView1STOKADI
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        Styles.ContentOdd = Tablo.cxZrnAln
        Styles.OnGetContentStyle = UretimListeGridDBTableView1StylesGetContentStyle
        object UretimListeGridDBTableView1ID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          Options.Editing = False
        end
        object UretimListeGridDBTableView1KOD: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Options.Editing = False
          Width = 58
        end
        object UretimListeGridDBTableView1Column1: TcxGridDBColumn
          Caption = #220'r'#252'n No'
          DataBinding.FieldName = 'URUNNO'
          Width = 81
        end
        object UretimListeGridDBTableView1STOKADI: TcxGridDBColumn
          Caption = 'Stok Ad'#305
          DataBinding.FieldName = 'STOKADI'
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Options.Editing = False
          Width = 153
        end
        object UretimListeGridDBTableView1MALIYETORT: TcxGridDBColumn
          Caption = 'Ort.Maliyet'
          DataBinding.FieldName = 'MALIYETORT'
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Options.Editing = False
          Width = 59
        end
        object UretimListeGridDBTableView1MALIYETSON: TcxGridDBColumn
          Caption = 'Son Maliyet'
          DataBinding.FieldName = 'MALIYETSON'
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Options.Editing = False
        end
        object UretimListeGridDBTableView1TAVSIYE_ORT: TcxGridDBColumn
          Caption = 'Ort.Tavsiye Fiyat'
          DataBinding.FieldName = 'TAVSIYE_ORT'
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Options.Editing = False
          Width = 63
        end
        object UretimListeGridDBTableView1TAVSIYE_SON: TcxGridDBColumn
          Caption = 'Son Tavsiye Fiyat'
          DataBinding.FieldName = 'TAVSIYE_SON'
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Width = 65
        end
        object UretimListeGridDBTableView1SATIS: TcxGridDBColumn
          Caption = 'Liste Fiyat'#305
          DataBinding.FieldName = 'LISTE_SATIS'
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Options.Editing = False
          Width = 59
        end
        object UretimListeGridDBTableView1KAR: TcxGridDBColumn
          Caption = 'Kar %'
          DataBinding.FieldName = 'KAR'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepCurrencyGenel
          Visible = False
          Options.Editing = False
          Width = 38
        end
        object UretimListeGridDBTableView1TUR: TcxGridDBColumn
          Caption = 'T'#252'r'
          DataBinding.FieldName = 'TUR'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Pasif'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'S'#305'cak '#220'retim'
              Value = 1
            end
            item
              Description = 'Haz'#305'r '#220'retim'
              Value = 2
            end>
          Options.Editing = False
          Width = 73
        end
        object UretimListeGridDBTableView1TAVSIYE_SATIS_ORANI: TcxGridDBColumn
          Caption = 'Tavsiye %'
          DataBinding.FieldName = 'TAVSIYE_SATIS_ORANI'
          Visible = False
          Options.Editing = False
          Width = 40
        end
      end
      object UretimListeGridLevel1: TcxGridLevel
        GridView = UretimListeGridDBTableView1
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 432
      Height = 103
      Align = alTop
      Color = clSilver
      ParentBackground = False
      TabOrder = 1
      object Label1: TcxLabel
        Left = 2
        Top = 40
        Caption = 'Ara'
        Transparent = True
      end
      object ToolBar2: TToolBar
        Left = 394
        Top = 12
        Width = 90
        Height = 26
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 83
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esNone
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        ShowCaptions = True
        TabOrder = 2
      end
      object AraKod: TcxTextEdit
        Left = 47
        Top = 38
        TabOrder = 0
        OnKeyUp = AraKodKeyUp
        Width = 143
      end
      object CheckPasif: TcxCheckBox
        Left = 47
        Top = 65
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 3
        OnClick = CheckPasifClick
      end
      object LabelGecmis: TcxLabel
        Left = 220
        Top = 39
        Cursor = crHandPoint
        Caption = 'Ge'#231'mi'#351' re'#231'ete g'#246'ster'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold, fsUnderline]
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
        OnClick = LabelGecmisClick
      end
      object LabelTarih: TcxLabel
        Left = 196
        Top = 66
        Caption = 'Ge'#231'mi'#351' Tarih Se'#231'in'
        Style.TextColor = clRed
        Transparent = True
        Visible = False
      end
      object ToolBarSol: TToolBar
        Left = 1
        Top = 1
        Width = 430
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 65
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
        TabOrder = 6
        Transparent = True
        object ReceteEkleBtn: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = ReceteEkleBtnClick
        end
        object ReceteSilBtn: TToolButton
          Left = 65
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = ReceteSilBtnClick
        end
        object SecTus: TToolButton
          Left = 130
          Top = 0
          Caption = 'Se'#231
          ImageIndex = 15
          ImageName = 'PngImage15'
          Visible = False
          OnClick = SecTusClick
        end
        object ReceteKaydetBtn: TToolButton
          Left = 195
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = ReceteKaydetBtnClick
        end
        object ReceteIptalBtn: TToolButton
          Left = 260
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          OnClick = ReceteIptalBtnClick
        end
        object ToolButton1: TToolButton
          Left = 325
          Top = 0
          Caption = 'Hesapla'
          DropdownMenu = PopupHesapla
          ImageIndex = 20
          ImageName = 'PngImage20'
        end
      end
      object DateGecmis: TcxDateEdit
        Left = 294
        Top = 65
        Properties.OnCloseUp = DateGecmisPropertiesCloseUp
        TabOrder = 7
        Visible = False
        Width = 121
      end
    end
    object SQLMemo: TcxMemo
      Left = 23
      Top = 184
      Lines.Strings = (
        'select *'
        'from URETIMRECETE'
        'where 1=1'
        ''
        '')
      Properties.WordWrap = False
      TabOrder = 2
      Visible = False
      Height = 105
      Width = 393
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 434
    Top = 0
    Width = 8
    Height = 614
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = PanelSolTaraf
    Color = clSkyBlue
    ParentColor = False
  end
  object TabRecete: TFDQuery
    BeforePost = TabReceteBeforePost
    AfterScroll = TabReceteAfterScroll
    OnCalcFields = TabReceteCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *'
      'from URETIMRECETE'
      'where 1=1'
      ''
      '')
    Left = 164
    Top = 194
    object TabReceteMALIYETSON: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'MALIYETSON'
      ReadOnly = True
      Calculated = True
    end
    object TabReceteMALIYETORT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'MALIYETORT'
      ReadOnly = True
      Calculated = True
    end
    object TabReceteLISTE_SATIS: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'LISTE_SATIS'
      ReadOnly = True
      Calculated = True
    end
    object TabReceteTAVSIYE_ORT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'TAVSIYE_ORT'
      ReadOnly = True
      Calculated = True
    end
    object TabReceteTAVSIYE_SON: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'TAVSIYE_SON'
      ReadOnly = True
      Calculated = True
    end
    object TabReceteSTOKADI: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'STOKADI'
      Size = 100
      Calculated = True
    end
    object TabReceteKOD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'KOD'
      Size = 30
      Calculated = True
    end
    object TabReceteURUNNO: TStringField
      FieldKind = fkCalculated
      FieldName = 'URUNNO'
      Size = 50
      Calculated = True
    end
    object TabReceteID: TFDAutoIncField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object TabReceteTURU: TByteField
      FieldName = 'TURU'
      Origin = 'TURU'
    end
    object TabReceteDURUM: TBooleanField
      FieldName = 'DURUM'
      Origin = 'DURUM'
    end
    object TabReceteOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Origin = 'OZELKOD'
    end
    object TabReceteYETKIKODU: TWideStringField
      FieldName = 'YETKIKODU'
      Origin = 'YETKIKODU'
      Size = 10
    end
    object TabReceteNOTLAR: TWideStringField
      FieldName = 'NOTLAR'
      Origin = 'NOTLAR'
      Size = 200
    end
    object TabReceteSUBEID: TSmallintField
      FieldName = 'SUBEID'
      Origin = 'SUBEID'
    end
    object TabReceteEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
      Origin = 'EKLEYEN'
    end
    object TabReceteEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
      Origin = 'EKLEMETARIHI'
    end
    object TabReceteDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
      Origin = 'DEGISTIREN'
    end
    object TabReceteDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
      Origin = 'DEGISTIRMETARIHI'
    end
    object TabReceteSTOKID: TIntegerField
      FieldName = 'STOKID'
      Origin = 'STOKID'
    end
    object TabReceteTUR: TByteField
      FieldName = 'TUR'
      Origin = 'TUR'
    end
    object TabReceteTAVSIYE_SATIS_ORANI: TCurrencyField
      FieldName = 'TAVSIYE_SATIS_ORANI'
      Origin = 'TAVSIYE_SATIS_ORANI'
    end
  end
  object DtsRecete: TDataSource
    DataSet = TabRecete
    OnStateChange = DtsReceteStateChange
    Left = 252
    Top = 72
  end
  object RECETE: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      
        'MALIYETSON=(select top 1 ABS(URD.MALIYETSON) from URETIMRECETEDE' +
        'TAY URD where URD.URETIMRECETEID=U.ID and URD.URUNID = U.STOKID ' +
        'and URD.ANAURUN=1),'
      
        'MALIYETORT=(select top 1 ABS(URD.MALIYETORT) from URETIMRECETEDE' +
        'TAY URD where URD.URETIMRECETEID=U.ID and URD.URUNID = U.STOKID ' +
        'and URD.ANAURUN=1),'
      
        'TAVSIYE_ORT=((100.0+isnull(TAVSIYE_SATIS_ORANI,0))/100.0*(select' +
        ' top 1 ABS(URD.MALIYETORT) from URETIMRECETEDETAY URD where URD.' +
        'URETIMRECETEID=U.ID and URD.URUNID = U.STOKID and URD.ANAURUN=1)' +
        '),'
      
        'TAVSIYE_SON=((100.0+isnull(TAVSIYE_SATIS_ORANI,0))/100.0*(select' +
        ' top 1 ABS(URD.MALIYETSON) from URETIMRECETEDETAY URD where URD.' +
        'URETIMRECETEID=U.ID and URD.URUNID = U.STOKID and URD.ANAURUN=1)' +
        '),'
      
        'LISTE_SATIS=(select top 1 SF.FIYAT from STOKFIYAT SF where U.STO' +
        'KID=SF.STOKID and SF.BIRIM=(select ST.ANABIRIM from STOKLAR ST w' +
        'here U.STOKID=ST.ID) and SF.FIYATADI=:PRM1),'
      'U.*,'
      
        'STOKADI=(select ST.STOKADI from STOKLAR ST where U.STOKID=ST.ID)' +
        ','
      'STOKKODU=(select ST.KOD from STOKLAR ST where U.STOKID=ST.ID),'
      'URUNNO=(select ST.URUNNO from STOKLAR ST where U.STOKID=ST.ID)'
      'from URETIMRECETE U'
      'where 1=1'
      ''
      ''
      '')
    Left = 316
    Top = 130
  end
  object TabReceteDetay: TFDQuery
    BeforeEdit = TabReceteDetayBeforeEdit
    BeforePost = TabReceteDetayBeforePost
    AfterPost = TabReceteDetayAfterPost
    AfterScroll = TabReceteDetayAfterScroll
    OnCalcFields = TabReceteDetayCalcFields
    OnNewRecord = TabReceteDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *'
      'from URETIMRECETEDETAY'
      'where URETIMRECETEID = :PURID'
      'order by SIRA'
      ''
      '')
    Left = 148
    Top = 282
    ParamData = <
      item
        Name = 'PURID'
        ParamType = ptInput
      end>
    object TabReceteDetayALISMALIYETORT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ALISMALIYETORT'
      Calculated = True
    end
    object TabReceteDetayALISMALIYETSON: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ALISMALIYETSON'
      Calculated = True
    end
    object TabReceteDetayBRMMALIYETORT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'BRMMALIYETORT'
      Calculated = True
    end
    object TabReceteDetayTPLMALIYETORT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'TPLMALIYETORT'
      Calculated = True
    end
    object TabReceteDetayYUZDEORT: TFloatField
      FieldKind = fkCalculated
      FieldName = 'YUZDEORT'
      Calculated = True
    end
    object TabReceteDetayBRMMALIYETSON: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'BRMMALIYETSON'
      Calculated = True
    end
    object TabReceteDetayTPLMALIYETSON: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'TPLMALIYETSON'
      Calculated = True
    end
    object TabReceteDetayYUZDESON: TFloatField
      FieldKind = fkCalculated
      FieldName = 'YUZDESON'
      Calculated = True
    end
    object TabReceteDetayGRP: TIntegerField
      FieldKind = fkCalculated
      FieldName = 'GRP'
      Calculated = True
    end
    object TabReceteDetayURUNKODU: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'URUNKODU'
      Size = 50
      Calculated = True
    end
    object TabReceteDetayURUNNO: TStringField
      FieldKind = fkCalculated
      FieldName = 'URUNNO'
      Size = 50
      Calculated = True
    end
    object TabReceteDetayURUNADI: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'URUNADI'
      Size = 200
      Calculated = True
    end
    object TabReceteDetayMASRAFAD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'MASRAFAD'
      Size = 200
      Calculated = True
    end
    object TabReceteDetayKDV: TFloatField
      FieldKind = fkCalculated
      FieldName = 'KDV'
      Calculated = True
    end
  end
  object DtsReceteDetay: TDataSource
    DataSet = TabReceteDetay
    OnStateChange = DtsReceteDetayStateChange
    Left = 356
    Top = 278
  end
  object RECETEDETAY: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select UD.*,'
      'ALISMALIYETORT=ABS(UD.MALIYETORT),'
      'ALISMALIYETSON=ABS(UD.MALIYETSON),'
      'BRMMALIYETORT=ABS(UD.MIKTAR*UD.MALIYETORT),'
      'TPLMALIYETORT=ABS(UD.ADETHESAP*UD.MALIYETORT),'
      
        'YUZDEORT=CASE WHEN UD.ANAURUN=1 THEN 100.0 ELSE ABS(ROUND((UD.MA' +
        'LIYETORT*UD.ADETHESAP)/NULLIF(ANA.ANA_MALIYETORT,0.0),4))*100.0 ' +
        'END,'
      'BRMMALIYETSON=ABS(UD.MIKTAR*UD.MALIYETSON),'
      'TPLMALIYETSON=ABS(UD.ADETHESAP*UD.MALIYETSON),'
      
        'YUZDESON=CASE WHEN UD.ANAURUN=1 THEN 100.0 ELSE ABS(ROUND((UD.MA' +
        'LIYETSON*UD.ADETHESAP)/NULLIF(ANA.ANA_MALIYETSON,0.0),4))*100.0 ' +
        'END,'
      'GRP = case when UD.MIKTAR>0 then 1 else 0 end,'
      
        'URUNKODU=CASE WHEN UD.TUR=1 THEN ST.KOD WHEN UD.TUR=2 THEN MG.KO' +
        'D END,'
      'URUNNO=CASE WHEN UD.TUR=1 THEN ST.URUNNO ELSE '#39'0'#39' END,'
      
        'URUNADI=CASE WHEN UD.TUR=1 THEN ST.STOKADI WHEN UD.TUR=2 THEN MG' +
        '.AD END,'
      'MASRAFAD=MG.AD,'
      'KDV=ISNULL(ST.KDV,0)'
      'from URETIMRECETEDETAY UD'
      
        'outer apply (select top 1 (X.MALIYETORT*X.ADETHESAP) as ANA_MALI' +
        'YETORT, (X.MALIYETSON*X.ADETHESAP) as ANA_MALIYETSON from URETIM' +
        'RECETEDETAY X where X.URETIMRECETEID=UD.URETIMRECETEID and X.ANA' +
        'URUN=1 order by X.ID) ANA'
      'left join STOKLAR ST on ST.ID=UD.URUNID and UD.TUR=1'
      'left join MASRAFGELIR MG on MG.ID=UD.URUNID and UD.TUR=2'
      'where URETIMRECETEID = :PURID'
      'order by UD.SIRA'
      ''
      '')
    Left = 260
    Top = 282
    ParamData = <
      item
        Name = 'PURID'
        ParamType = ptInput
      end>
  end
  object PopupMenuDetay: TPopupMenu
    Left = 940
    Top = 277
    object ReeternOlarakaretle1: TMenuItem
      Caption = 'Re'#231'ete '#220'r'#252'n'#252' Olarak '#304#351'aretle'
      OnClick = ReeternOlarakaretle1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MaliyetleriHesaplaMenu: TMenuItem
      Caption = 'Maliyetleri Hesapla'
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 1011
    Top = 248
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
    object MenuItem1: TMenuItem
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
  object frxRecete: TfrxDBDataset
    UserName = 'Recete'
    CloseDataSource = False
    DataSource = DtsReceteDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 460
    Top = 252
  end
  object frxReceteDetay: TfrxDBDataset
    UserName = 'ReceteDetay'
    CloseDataSource = False
    DataSource = DtsReceteDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 595
    Top = 235
  end
  object PopupHesapla: TPopupMenu
    Left = 35
    Top = 152
    object BuUrunMenu: TMenuItem
      Tag = 1
      Caption = 'Bu '#220'r'#252'n'#252
      ImageIndex = 1
      OnClick = BuUrunMenuClick
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object TumUrunlerMenu: TMenuItem
      Caption = 'T'#252'm '#220'r'#252'nleri'
      OnClick = TumUrunlerMenuClick
    end
  end
  object PopupMenuListe: TPopupMenu
    Left = 168
    Top = 128
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object ExceldenVeriAl1: TMenuItem
      Caption = 'Excelden Re'#231'ete Verisi Al'
      OnClick = ExceldenVeriAl1Click
    end
    object ExceldenOperasyonKonuVeriAl1: TMenuItem
      Caption = 'Excelden Operasyon Konu Veri Al '
      OnClick = ExceldenOperasyonKonuVeriAl1Click
    end
  end
  object TabUretimReceteOpr: TFDQuery
    AfterScroll = TabUretimReceteOprAfterScroll
    OnNewRecord = TabUretimReceteOprNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      'UO.*,'
      
        'KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L' +
        '1.ID)'
      'from [dbo].[URETIMRECETEOPR] UO '
      'where UO.URETIMRECETEID = :PRM1'
      'order by UO.SIRA, UO.ID')
    Left = 1133
    Top = 240
  end
  object DtsUretimReceteOpr: TDataSource
    DataSet = TabUretimReceteOpr
    OnStateChange = DtsUretimReceteOprStateChange
    Left = 1133
    Top = 308
  end
  object TabSablonDetay: TFDQuery
    OnCalcFields = TabSablonDetayCalcFields
    OnNewRecord = TabSablonDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from KALITESABLONDETAY KSD '
      'where '
      'YER=20'
      'and KSD.YERID=:PRM1 '
      ' order by KSD.ID')
    Left = 549
    Top = 345
    object TabSablonDetayADI: TStringField
      FieldKind = fkCalculated
      FieldName = 'ADI'
      Calculated = True
    end
    object TabSablonDetayBILGI: TStringField
      FieldKind = fkCalculated
      FieldName = 'BILGI'
      Calculated = True
    end
  end
  object DtsSablonDetay: TDataSource
    DataSet = TabSablonDetay
    OnStateChange = DtsSablonDetayStateChange
    Left = 694
    Top = 349
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 71
    Top = 268
  end
  object PopupMenuTest: TPopupMenu
    OnPopup = PopupMenuTestPopup
    Left = 580
    Top = 456
    object KopyalaMenuItem: TMenuItem
      Caption = 'Buraya Test Kopyala'
      OnClick = KopyalaMenuItemClick
    end
  end
end
