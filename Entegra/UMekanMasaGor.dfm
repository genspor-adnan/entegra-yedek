object MekanMasaGorDlg: TMekanMasaGorDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsNone
  Caption = 'GorselForm'
  ClientHeight = 506
  ClientWidth = 1499
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ZeminResim: TcxImage
    Left = 0
    Top = 79
    Align = alClient
    Properties.Center = False
    Properties.GraphicClassName = 'TJPEGImage'
    Properties.Stretch = True
    TabOrder = 4
    Transparent = True
    Height = 408
    Width = 1499
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1499
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object KapatTus: TJvNavPanelButton
      Left = 1389
      Top = 0
      Width = 110
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 1060
    end
    object RezervasyonTus: TJvNavPanelButton
      Left = 1169
      Top = 0
      Width = 110
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Rezervasyon'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 5
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = RezervasyonTusClick
      ExplicitLeft = 772
      ExplicitTop = -6
    end
    object PaketTus: TJvNavPanelButton
      Tag = 1
      Left = 0
      Top = 0
      Width = 110
      Height = 37
      Align = alLeft
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Paket'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = PaketTusClick
      ExplicitLeft = 1060
    end
    object MasaTus: TJvNavPanelButton
      Left = 1279
      Top = 0
      Width = 110
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Masa'
      DropDownMenu = JvPopupMenu1
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 5
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      ExplicitLeft = 806
      ExplicitTop = 3
    end
    object RezTarih: TJvDateTimePicker
      Left = 1001
      Top = 0
      Width = 168
      Height = 37
      Align = alRight
      Date = 41465.055934965280000000
      Time = 41465.055934965280000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Visible = False
      OnChange = RezTarihChange
      DropDownDate = 41465.000000000000000000
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 487
    Width = 1499
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end>
    Touch.ParentTabletOptions = False
    Touch.TabletOptions = [toPressAndHold]
  end
  object PanelBirlesen: TJvNavPanelHeader
    Left = 0
    Top = 37
    Width = 1499
    Height = 42
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object SonTus: TJvNavPanelButton
      Left = 0
      Top = 0
      Width = 110
      Height = 42
      Align = alLeft
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Se'#231'im Bitince Buraya Bas'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 5
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clWhite
      Colors.ButtonColorTo = clSilver
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = SonTusClick
      ExplicitHeight = 37
    end
  end
  object PanelPaket: TPanel
    Left = 0
    Top = 79
    Width = 1499
    Height = 408
    Align = alClient
    TabOrder = 0
    Visible = False
    object cxLabel9: TLabel
      Left = 992
      Top = 336
      Width = 42
      Height = 13
      Caption = 'cxLabel9'
      Transparent = True
    end
    object PanelPaketBaslik: TJvNavPanelHeader
      Left = 1
      Top = 1
      Width = 1497
      Height = 37
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = clGray
      ColorTo = clGreen
      ImageIndex = 0
      object YeniTus: TJvNavPanelButton
        Left = 168
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = 'Yeni Sipari'#351
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 5
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 7
        Images = Tablo.PNGImageList1
        OnClick = YeniTusClick
        ExplicitLeft = 174
        ExplicitTop = 5
      end
      object DuzenleTus: TJvNavPanelButton
        Left = 278
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = 'D'#252'zenle'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 5
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Visible = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 9
        Images = Tablo.PNGImageList1
        OnClick = DuzenleTusClick
        ExplicitLeft = 806
        ExplicitTop = 3
      end
      object SilTus: TJvNavPanelButton
        Left = 388
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = 'Sil'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Visible = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 8
        Images = Tablo.PNGImageList1
        OnClick = SilTusClick
        ExplicitTop = 5
      end
      object JvNavPanelButton1: TJvNavPanelButton
        Left = 498
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Enabled = False
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = -1
        ExplicitLeft = 492
        ExplicitTop = 5
      end
      object KuryeTus: TJvNavPanelButton
        Left = 608
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = 'Kurye Ata'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Visible = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 1
        Images = Tablo.PNGImageList1
        OnClick = KuryeTusClick
        ExplicitLeft = 614
        ExplicitTop = 5
      end
      object TahsilatTus: TJvNavPanelButton
        Left = 718
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = 'Tahsilat '#304#351'le'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Visible = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 4
        Images = Tablo.PNGImageList1
        OnClick = DuzenleTusClick
        ExplicitLeft = 820
        ExplicitTop = -6
      end
      object IptalTus: TJvNavPanelButton
        Left = 828
        Top = 0
        Width = 110
        Height = 37
        Align = alLeft
        Alignment = taCenter
        AllowAllUp = True
        Caption = #304'ptal Et'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 10395294
        Colors.ButtonColorTo = clGreen
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 17
        Images = Tablo.PNGImageList1
        OnClick = IptalTusClick
        ExplicitLeft = 944
        ExplicitTop = -6
      end
      object PaketTarih: TJvDateTimePicker
        Left = 0
        Top = 0
        Width = 168
        Height = 37
        Align = alLeft
        Date = 41465.055934965280000000
        Time = 41465.055934965280000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -24
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnChange = PaketTarihChange
        DropDownDate = 41465.000000000000000000
      end
    end
    object gridSiparis: TcxGrid
      Left = 1
      Top = 38
      Width = 1497
      Height = 210
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      LookAndFeel.SkinName = ''
      object tvSiparis: TcxGridDBTableView
        PopupMenu = PopupMenuSiparis
        OnDblClick = DuzenleTusClick
        Navigator.Buttons.CustomButtons = <>
        OnSelectionChanged = tvSiparisSelectionChanged
        DataController.DataSource = DtsSiparis
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'Musteri'
            Column = tvSiparisMusteri
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            FieldName = 'Tutar'
            Column = tvSiparisTutar
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.DataRowHeight = 40
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        Styles.ContentEven = cxStyle1
        Styles.ContentOdd = cxStyle2
        Styles.Group = cxStyle1
        Styles.Header = cxStyle3
        object tvSiparisID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object tvSiparisSiparisNo: TcxGridDBColumn
          Caption = 'S.No'
          DataBinding.FieldName = 'SiparisNo'
        end
        object tvSiparisMusteri: TcxGridDBColumn
          Caption = 'M'#252#351'teri'
          DataBinding.FieldName = 'Musteri'
          Width = 252
        end
        object tvSiparisSaat: TcxGridDBColumn
          DataBinding.FieldName = 'Saat'
          PropertiesClassName = 'TcxTimeEditProperties'
          Properties.TimeFormat = tfHourMin
          Width = 58
        end
        object tvSiparisSure: TcxGridDBColumn
          Caption = 'S'#252're'
          DataBinding.FieldName = 'Sure'
          PropertiesClassName = 'TcxTimeEditProperties'
          Properties.TimeFormat = tfHourMin
          Width = 51
        end
        object tvSiparisCikisSaati: TcxGridDBColumn
          Caption = #199#305'k'#305#351
          DataBinding.FieldName = 'CikisSaati'
          PropertiesClassName = 'TcxTimeEditProperties'
          Properties.TimeFormat = tfHourMin
          Width = 56
        end
        object tvSiparisTutar: TcxGridDBColumn
          DataBinding.FieldName = 'Tutar'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Width = 71
        end
        object tvSiparisKurye: TcxGridDBColumn
          DataBinding.FieldName = 'Kurye'
          Width = 106
        end
        object tvSiparisDurum: TcxGridDBColumn
          DataBinding.FieldName = 'Durum'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepAdisyon
          Visible = False
          GroupIndex = 0
          Options.ShowCaption = False
        end
        object tvSiparisTeslimTarihi: TcxGridDBColumn
          Caption = 'Teslim Zaman'#305
          DataBinding.FieldName = 'TeslimTarihi'
          PropertiesClassName = 'TcxDateEditProperties'
          Properties.Kind = ckDateTime
          Width = 161
        end
      end
      object gridSiparisLevel1: TcxGridLevel
        GridView = tvSiparis
      end
    end
    object PanelAlt: TPanel
      Left = 1
      Top = 248
      Width = 1497
      Height = 159
      Align = alBottom
      BevelOuter = bvNone
      Color = clMoneyGreen
      ParentBackground = False
      TabOrder = 2
      OnDblClick = YeniTusClick
      object Label8: TLabel
        Left = 508
        Top = 67
        Width = 57
        Height = 13
        Caption = 'Sipari'#351' Notu'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cxLabel3: TLabel
        Left = 508
        Top = 109
        Width = 57
        Height = 13
        Caption = 'Sipari'#351'i Alan'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel4: TLabel
        Left = 47
        Top = 67
        Width = 28
        Height = 13
        Caption = 'Adres'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel5: TLabel
        Left = 343
        Top = 42
        Width = 33
        Height = 13
        Caption = 'Ev Tel.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel2: TLabel
        Left = 511
        Top = 46
        Width = 53
        Height = 13
        Caption = #214'deme Tipi'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel1: TLabel
        Left = 188
        Top = 45
        Width = 30
        Height = 13
        Caption = #304#351' Tel.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel6: TLabel
        Left = 34
        Top = 45
        Width = 40
        Height = 13
        Caption = 'Cep Tel.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object cxLabel7: TLabel
        Left = 46
        Top = 103
        Width = 29
        Height = 13
        Caption = 'Notlar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label1: TLabel
        Left = 767
        Top = 45
        Width = 66
        Height = 13
        Caption = 'Teslim Zaman'#305
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cxDBMemo1: TcxDBMemo
        Left = 572
        Top = 66
        DataBinding.DataField = 'SipNotu'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        Properties.ReadOnly = True
        Properties.ScrollBars = ssVertical
        TabOrder = 0
        OnClick = cxDBMemo1Click
        Height = 37
        Width = 395
      end
      object MemoAdres: TcxDBMemo
        Tag = 2
        Left = 81
        Top = 66
        Hint = 'Adres'
        DataBinding.DataField = 'Adres'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        Properties.ReadOnly = True
        Properties.ScrollBars = ssVertical
        TabOrder = 1
        OnClick = MemoAdresClick
        Height = 37
        Width = 395
      end
      object cxDBTextEdit2: TcxDBTextEdit
        Left = 382
        Top = 41
        DataBinding.DataField = 'EvTel'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        TabOrder = 2
        Width = 94
      end
      object cxDBImageComboBox1: TcxDBButtonEdit
        Left = 571
        Top = 42
        DataBinding.DataField = 'OdemeSekliAd'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxDBImageComboBox1PropertiesButtonClick
        TabOrder = 5
        Width = 121
      end
      object cxDBTextEdit1: TcxDBButtonEdit
        Left = 571
        Top = 106
        DataBinding.DataField = 'SiparisAlan'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        Properties.Buttons = <
          item
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxDBTextEdit1PropertiesButtonClick
        TabOrder = 7
        Width = 113
      end
      object CheckTumListe: TcxCheckBox
        Left = 971
        Top = 8
        Caption = 'T'#252'm Listeyi G'#246'ster'
        TabOrder = 8
        OnClick = PaketTarihChange
        Width = 147
      end
      object cxDBTextEdit3: TcxDBTextEdit
        Left = 232
        Top = 41
        DataBinding.DataField = 'IsTel'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        TabOrder = 3
        Width = 94
      end
      object cxDBTextEdit4: TcxDBTextEdit
        Left = 83
        Top = 42
        DataBinding.DataField = 'CepTel'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        TabOrder = 4
        Width = 94
      end
      object cxDBMemo3: TcxDBMemo
        Left = 81
        Top = 104
        DataBinding.DataField = 'CariNotu'
        DataBinding.DataSource = DtsSiparis
        ParentColor = True
        Properties.ReadOnly = True
        Properties.ScrollBars = ssVertical
        TabOrder = 6
        OnClick = cxDBMemo3Click
        Height = 37
        Width = 395
      end
      object DateTeslim: TcxDateEdit
        Left = 839
        Top = 41
        ParentColor = True
        ParentFont = False
        Properties.Kind = ckDateTime
        Properties.OnCloseUp = DateTeslimPropertiesCloseUp
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 9
        Width = 128
      end
      object Panel2: TPanel
        Left = 508
        Top = 10
        Width = 459
        Height = 22
        Caption = 'Sipari'#351' Bilgi'
        Color = 4227072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 10
      end
      object Panel1: TPanel
        Left = 23
        Top = 10
        Width = 453
        Height = 22
        Caption = 'M'#252#351'teri Bilgi'
        Color = 4227072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 11
      end
    end
    object MemoPaketSQL: TMemo
      Left = 206
      Top = 136
      Width = 676
      Height = 41
      Lines.Strings = (
        'select top 100 FB.ID,SiparisNo=0,FB.REHBERID,Musteri=R.FIRMA,'
        
          'IsTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
          'N REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA' +
          '.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=40),'
        
          'CepTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JO' +
          'IN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND R' +
          'A.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=42),'
        
          'EvTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
          'N REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA' +
          '.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=44),'
        'FB.ADRES,FB.ILCE,FB.IL,'
        
          'Saat=FATURATARIH,Sure=isnull(FATURA_GON_TARIHI, GETDATE())-FATUR' +
          'ATARIH,CikisSaati=FATURA_GON_TARIHI,'
        
          ' Tutar=FATURA_TUTARI,Durum=FB.DURUM,KuryeId=SATICIKODU,Kurye=(se' +
          'lect FIRMA from REHBER where ID=SATICIKODU),'
        'SiparisAlan=(select FIRMA from REHBER where ID=FB.EKLEYEN),'
        'OdemeSekli=FB.DETAYBOLUMU, '
        
          'OdemeSekliAd=(select ANAHTAR from GENINI WHERE BOLUM=-1021 AND D' +
          'EGER=FB.KASA),'
        'CariNotu=R.NOTLAR,'
        'TeslimTarihi=FB.TARIH,'
        'SipNotu=FB.ACIKLAMA,'
        'Lokasyon'
        'from FATBASLIK FB '
        'inner join REHBER R on FB.REHBERID=R.ID'
        
          'inner join REHBERILETISIM RI on RI.REHBERID=R.ID and RI.VARSAYIL' +
          'AN=1'
        '')
      TabOrder = 3
      Visible = False
      WordWrap = False
    end
  end
  object JvPopupMenu1: TJvPopupMenu
    Images = Tablo.cxImageList1
    Style = msOffice
    ImageMargin.Left = 0
    ImageMargin.Top = 0
    ImageMargin.Right = 0
    ImageMargin.Bottom = 0
    ImageSize.Height = 0
    ImageSize.Width = 0
    Left = 488
    Top = 152
    object MasaDegistirMenu: TMenuItem
      Caption = 'De'#287'i'#351'tir'
      ImageIndex = 7
      OnClick = MasaDegistirMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MasaBirlestirMenu: TMenuItem
      Caption = 'Birle'#351'tir'
      ImageIndex = 4
      OnClick = MasaBirlestirMenuClick
    end
    object MasaAyirMenu: TMenuItem
      Caption = 'Ay'#305'r'
      OnClick = MasaAyirMenuClick
    end
  end
  object JvPopupMenu2: TJvPopupMenu
    Images = Tablo.cxImageList1
    OnPopup = JvPopupMenu2Popup
    Style = msOffice
    ImageMargin.Left = 0
    ImageMargin.Top = 0
    ImageMargin.Right = 0
    ImageMargin.Bottom = 0
    ImageSize.Height = 0
    ImageSize.Width = 0
    Left = 264
    Top = 224
    object SubeSecimMenu: TMenuItem
      Caption = #350'ube Se'#231'imi'
      ImageIndex = 35
    end
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Interval = 5000
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 200
    Top = 160
  end
  object DtsSiparis: TDataSource
    DataSet = TabSiparis
    Left = 89
    Top = 318
  end
  object TabSiparis: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabSiparisAfterOpen
    ParamData = <>
    SQL.Strings = (
      'select top 100 FB.ID,SiparisNo=0,FB.REHBERID,Musteri=R.FIRMA,'
      
        'IsTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=40),'
      
        'CepTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JO' +
        'IN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND R' +
        'A.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=42),'
      
        'EvTel=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=44),'
      'FB.ADRES,FB.ILCE,FB.IL,'
      
        'Saat=FATURATARIH,Sure=isnull(FATURA_GON_TARIHI, GETDATE())-FATUR' +
        'ATARIH,CikisSaati=FATURA_GON_TARIHI,'
      
        ' Tutar=FATURA_TUTARI,Durum=FB.DURUM,KuryeId=SATICIKODU,Kurye=(se' +
        'lect FIRMA from REHBER where ID=SATICIKODU),'
      'SiparisAlan=(select FIRMA from REHBER where ID=FB.SATICIKODU),'
      
        'OdemeSekli=FB.KASA, OdemeSekliAd=(select ANAHTAR from GENINI WHE' +
        'RE BOLUM=-1021 AND DEGER=FB.KASA),'
      'CariNotu=R.NOTLAR,'
      'TeslimTarihi=FB.TARIH,'
      'SipNotu=FB.ACIKLAMA,'
      'Lokasyon'
      'from FATBASLIK FB '
      'inner join REHBER R on FB.REHBERID=R.ID'
      
        'inner join REHBERILETISIM RI on RI.REHBERID=R.ID and RI.VARSAYIL' +
        'AN=1'
      '')
    Left = 161
    Top = 326
  end
  object frxAktiviteRapor: TfrxDBDataset
    UserName = 'AktiviteRapor'
    CloseDataSource = False
    DataSource = DtsSiparis
    BCDToCurrency = False
    Left = 159
    Top = 430
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clGradientInactiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
  end
  object PopupMenuSiparis: TJvPopupMenu
    Images = Tablo.cxImageList1
    OnPopup = JvPopupMenu2Popup
    Style = msOffice
    ImageMargin.Left = 0
    ImageMargin.Top = 0
    ImageMargin.Right = 0
    ImageMargin.Bottom = 0
    ImageSize.Height = 0
    ImageSize.Width = 0
    Left = 680
    Top = 192
    object TumListeyi: TMenuItem
      Caption = 'T'#252'm Listeyi G'#246'ster'
      ImageIndex = 35
      OnClick = TumListeyiClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MterikartnSil1: TMenuItem
      Caption = 'M'#252#351'teri kart'#305'n'#305' Sil'
      OnClick = MterikartnSil1Click
    end
  end
end
