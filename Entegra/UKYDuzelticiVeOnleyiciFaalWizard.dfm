object KYDuzelticiVeOnleyiciFaalWizardDlg: TKYDuzelticiVeOnleyiciFaalWizardDlg
  Left = 0
  Top = 0
  ActiveControl = editDOFNo
  BorderIcons = [biSystemMenu]
  Caption = 'D'#214'F Olu'#351'turma Sihirbaz'#305
  ClientHeight = 547
  ClientWidth = 927
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 85
    Top = 0
    Width = 842
    Height = 547
    ActivePage = PageDOF
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Kaydet'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      842
      547)
    object PageDOF: TJvWizardInteriorPage
      Header.Title.Color = clNone
      Header.Title.Text = 'D'#252'zeltici ve '#214'nleyici Faaliyet Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      OnExitPage = PageDOFExitPage
      object cxGroupBox1: TcxGroupBox
        Left = 0
        Top = 70
        Align = alTop
        Caption = 'D/'#214' Faaliyet '#304'ste'#287'ini Talep Eden'
        PanelStyle.OfficeBackgroundKind = pobkGradient
        Style.LookAndFeel.Kind = lfStandard
        Style.LookAndFeel.NativeStyle = False
        Style.LookAndFeel.SkinName = 'LondonLiquidSky'
        StyleDisabled.LookAndFeel.Kind = lfStandard
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
        StyleFocused.LookAndFeel.Kind = lfStandard
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
        StyleHot.LookAndFeel.Kind = lfStandard
        StyleHot.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
        TabOrder = 0
        Height = 197
        Width = 842
        object ComboFaaliyet: TcxDBImageComboBox
          Left = 615
          Top = 43
          RepositoryItem = Tablo.RepKaliteDofFaaliyet
          DataBinding.DataField = 'FAALIYETTURU'
          DataBinding.DataSource = DtsDOF
          Properties.Items = <>
          TabOrder = 6
          Width = 205
        end
        object cxLabel1: TcxLabel
          Left = 518
          Top = 44
          Caption = 'Tipi'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 518
          Top = 21
          Caption = 'Durum'
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 11
          Top = 20
          Caption = 'D'#214'F No/Tarih'
          Transparent = True
        end
        object editDOFNo: TcxDBTextEdit
          Left = 125
          Top = 21
          DataBinding.DataField = 'DOFNO'
          DataBinding.DataSource = DtsDOF
          TabOrder = 0
          Width = 97
        end
        object cxLabel6: TcxLabel
          Left = 518
          Top = 67
          Caption = 'Tespit Kayna'#287#305
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object lblMusteri: TcxLabel
          Left = 518
          Top = 114
          Caption = 'M'#252#351'teri'
          Transparent = True
          Visible = False
        end
        object cxLabel8: TcxLabel
          Left = 518
          Top = 162
          Caption = 'D'#214'F A'#231'an'
          Transparent = True
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 615
          Top = 20
          RepositoryItem = Tablo.repAktiviteDurum
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsDOF
          Properties.ImmediatePost = True
          Properties.Items = <>
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 5
          Width = 202
        end
        object ComboHataKaynagi: TcxDBImageComboBox
          Left = 616
          Top = 66
          RepositoryItem = Tablo.RepKaliteTespitKaynagi
          DataBinding.DataField = 'TESPITKAYNAGI'
          DataBinding.DataSource = DtsDOF
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnCloseUp = ComboHataKaynagiPropertiesCloseUp
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 7
          Width = 205
        end
        object ComboMusteri: TcxButtonEdit
          Left = 616
          Top = 113
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = ComboMusteriPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          TabOrder = 10
          Visible = False
          Width = 205
        end
        object EditDOFAcan: TcxButtonEdit
          Left = 615
          Top = 160
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDOFAcanPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          TabOrder = 12
          Width = 205
        end
        object DateTarih: TcxDBDateEdit
          Left = 224
          Top = 21
          DataBinding.DataField = 'EKLENMETARIHI'
          DataBinding.DataSource = DtsDOF
          TabOrder = 1
          Width = 113
        end
        object cxDBImageComboBox1: TcxDBImageComboBox
          Left = 125
          Top = 44
          RepositoryItem = Tablo.RepKaliteDofKategori
          DataBinding.DataField = 'KATEGORI'
          DataBinding.DataSource = DtsDOF
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnCloseUp = ComboHataKaynagiPropertiesCloseUp
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 2
          Width = 212
        end
        object LabelKategori: TcxLabel
          Left = 11
          Top = 45
          Cursor = crHandPoint
          Caption = 'Kategori'
          Transparent = True
          OnClick = LabelKategoriClick
        end
        object EditKartTipiAdi: TcxDBTextEdit
          Left = 125
          Top = 67
          DataBinding.DataField = 'KONU'
          DataBinding.DataSource = DtsDOF
          TabOrder = 3
          Width = 353
        end
        object cxLabel12: TcxLabel
          Left = 11
          Top = 93
          Caption = 'Uygunsuzlu'#287'un Tan'#305'm'#305
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object MemDofNeden: TcxDBMemo
          Left = 127
          Top = 91
          Align = alCustom
          DataBinding.DataField = 'DOFNEDEN'
          DataBinding.DataSource = DtsDOF
          Properties.ScrollBars = ssVertical
          TabOrder = 4
          Height = 95
          Width = 351
        end
        object cxLabel13: TcxLabel
          Left = 11
          Top = 69
          Caption = 'Konu'
        end
        object EditUrun: TcxButtonEdit
          Left = 615
          Top = 89
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditUrunPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          TabOrder = 9
          Width = 205
        end
        object ComboOTVYUZDE: TcxDBImageComboBox
          Left = 520
          Top = 90
          DataBinding.DataField = 'URUNTIPI'
          DataBinding.DataSource = DtsDOF
          Enabled = False
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <
            item
              Description = 'Hizmet'
              ImageIndex = 0
              Value = False
            end
            item
              Description = #220'r'#252'n'
              Value = True
            end>
          TabOrder = 8
          Width = 92
        end
        object BeditProje: TcxButtonEdit
          Left = 615
          Top = 136
          ParentShowHint = False
          Properties.Buttons = <
            item
              Caption = '++'
              Default = True
              Kind = bkText
            end
            item
              Caption = '+'
              Kind = bkText
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.MaxLength = 0
          Properties.OnButtonClick = BeditProjePropertiesButtonClick
          ShowHint = True
          TabOrder = 11
          Width = 205
        end
        object cxLabel7: TcxLabel
          Left = 519
          Top = 139
          Caption = 'Proje'
          Transparent = True
        end
        object cxDBCheckBox1: TcxDBCheckBox
          Left = 410
          Top = 23
          Caption = #214'nemli'
          DataBinding.DataField = 'ONEMLI'
          DataBinding.DataSource = DtsDOF
          ParentBackground = False
          ParentColor = False
          ParentFont = False
          Style.Color = clSilver
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = [fsBold]
          Style.LookAndFeel.NativeStyle = True
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.LookAndFeel.NativeStyle = True
          StyleFocused.LookAndFeel.NativeStyle = True
          StyleHot.LookAndFeel.NativeStyle = True
          TabOrder = 23
        end
        object CheckBoxACIL: TcxDBCheckBox
          Left = 356
          Top = 23
          Caption = 'AC'#304'L'
          DataBinding.DataField = 'ACIL'
          DataBinding.DataSource = DtsDOF
          ParentColor = False
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = [fsBold]
          Style.LookAndFeel.Kind = lfOffice11
          Style.LookAndFeel.NativeStyle = True
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.NativeStyle = True
          StyleDisabled.TextColor = clRed
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.NativeStyle = True
          StyleHot.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.NativeStyle = True
          TabOrder = 24
          Transparent = True
        end
      end
      object cxGroupBox2: TcxGroupBox
        Left = 0
        Top = 267
        Align = alTop
        Caption = 'D/'#214' Faaliyetin Sorumlusu'
        TabOrder = 1
        Height = 120
        Width = 842
        object MemDofSavunma: TcxDBMemo
          Left = 446
          Top = 19
          Align = alCustom
          DataBinding.DataField = 'DOFSAVUNMA'
          DataBinding.DataSource = DtsDOF
          Properties.ScrollBars = ssVertical
          TabOrder = 3
          Height = 65
          Width = 353
        end
        object cxLabel11: TcxLabel
          Left = 11
          Top = 23
          Caption = 'Sorumlu Ki'#351'i'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object EditDOFSorumlu: TcxButtonEdit
          Left = 127
          Top = 22
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDOFSorumluPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          TabOrder = 0
          Width = 175
        end
        object cxLabel5: TcxLabel
          Left = 11
          Top = 56
          Caption = 'Sorumlu B'#246'l'#252'm/G'#246'revi'
          Transparent = True
        end
        object DateSAVUNMAISTEMETARIHI: TcxDBDateEdit
          Left = 127
          Top = 87
          DataBinding.DataField = 'SAVUNMAISTEMETARIHI'
          DataBinding.DataSource = DtsDOF
          TabOrder = 2
          Width = 175
        end
        object cxLabel3: TcxLabel
          Left = 11
          Top = 88
          Caption = 'Cevap '#304'stenen Tarih'
          Transparent = True
        end
        object cxLabel14: TcxLabel
          Left = 338
          Top = 21
          Caption = 'Sorumlu Cevab'#305
          Transparent = True
        end
        object cxLabel15: TcxLabel
          Left = 338
          Top = 89
          Caption = 'Cevap Tarihi'
          Transparent = True
        end
        object cxDBDateEdit2: TcxDBDateEdit
          Left = 446
          Top = 88
          DataBinding.DataField = 'SAVUNMATARIHI'
          DataBinding.DataSource = DtsDOF
          TabOrder = 4
          Width = 147
        end
        object EditDepartman: TcxButtonEdit
          Left = 127
          Top = 55
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
          TabOrder = 1
          Width = 175
        end
      end
      object cxGroupBox3: TcxGroupBox
        Left = 0
        Top = 387
        Align = alClient
        Caption = 'D/'#214' Faaliyeti Sonucu'
        TabOrder = 2
        Height = 118
        Width = 842
        object MemoSONUC: TcxDBMemo
          Left = 127
          Top = 17
          Align = alCustom
          DataBinding.DataField = 'SONUC'
          DataBinding.DataSource = DtsDOF
          Properties.ScrollBars = ssVertical
          TabOrder = 0
          Height = 71
          Width = 675
        end
        object cxLabel18: TcxLabel
          Left = 11
          Top = 26
          Caption = 'Sonu'#231
          Transparent = True
        end
        object cxLabel19: TcxLabel
          Left = 11
          Top = 90
          Caption = 'Sonu'#231' Tarihi'
          Transparent = True
        end
        object dateSONUCTARIHI: TcxDBDateEdit
          Left = 127
          Top = 89
          DataBinding.DataField = 'SONUCTARIHI'
          DataBinding.DataSource = DtsDOF
          TabOrder = 1
          Width = 175
        end
      end
    end
    object PageBelge: TJvWizardInteriorPage
      Header.Title.Color = clNone
      Header.Title.Text = 'D'#246'k'#252'man Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'PageBelge'
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 836
        Height = 22
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 20
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
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object BelgeEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Belge Ekle'
          ImageIndex = 4
          Style = tbsTextButton
          OnClick = BelgeEkleTusClick
        end
        object BelgeSilTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Belge Sil'
          ImageIndex = 5
          Style = tbsTextButton
          OnClick = BelgeSilTusClick
        end
        object BelgeGorTus: TToolButton
          Left = 122
          Top = 0
          Caption = 'Belge G'#246'r'
          ImageIndex = 6
          Style = tbsTextButton
          OnClick = BelgeGorTusClick
        end
        object ToolButton2: TToolButton
          Left = 183
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          Style = tbsSeparator
        end
        object KaydetTus: TToolButton
          Left = 191
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = KaydetTusClick
        end
        object IptalTus: TToolButton
          Left = 252
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = IptalTusClick
        end
      end
      object GridBelge: TcxGrid
        Left = 0
        Top = 95
        Width = 842
        Height = 410
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridBelgeDBTableViewImaj: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn
            Caption = 'Belge Ad'#305
            DataBinding.FieldName = 'BELGEADI'
            Width = 95
          end
          object GridBelgeDBTableViewImajTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            Width = 79
          end
          object GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 363
          end
          object GridBelgeDBTableViewImajBELGE: TcxGridDBColumn
            Caption = 'Belge'
            DataBinding.FieldName = 'BELGE'
            Width = 38
          end
        end
        object GridBelgeLevel1: TcxGridLevel
          GridView = GridBelgeDBTableViewImaj
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 85
    Height = 547
    Align = alLeft
    TabOrder = 0
    Visible = False
    object btnDOF: TcxButton
      Left = 9
      Top = 80
      Width = 65
      Height = 29
      Caption = 'D'#214'F'
      TabOrder = 0
      OnClick = btnDOFClick
    end
    object BtnDokuman: TcxButton
      Tag = 3
      Left = 9
      Top = 117
      Width = 65
      Height = 29
      Caption = 'Dok'#252'man'
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnDokumanClick
    end
  end
  object TabDOF: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDOFAfterOpen
    BeforePost = TabDOFBeforePost
    AfterPost = TabDOFAfterPost
    OnNewRecord = TabDOFNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from KALITEDOF'
      'Where ID=:ID')
    Left = 437
    Top = 14
  end
  object DtsDOF: TDataSource
    DataSet = TabDOF
    Left = 503
    Top = 22
  end
  object TabBelge: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabDOFBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT  *  FROM  [IMAJ]'
      'WHERE'
      'YERI = :PYeri and'
      'YER_ID = :PYerID')
    Left = 687
    Top = 10
  end
  object DtsBelge: TDataSource
    DataSet = TabBelge
    OnDataChange = DtsBelgeDataChange
    Left = 736
    Top = 9
  end
  object OpenDialog1: TOpenDialog
    Left = 828
    Top = 20
  end
end
