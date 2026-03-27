object EkipmanWizardDlg: TEkipmanWizardDlg
  Left = 0
  Top = 0
  ActiveControl = EditKOD
  Caption = 'Ekipman Olu'#351'turma Sihirbaz'#305
  ClientHeight = 465
  ClientWidth = 893
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 85
    Top = 0
    Width = 808
    Height = 465
    ActivePage = PageEkipmanKart
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
    ButtonFinish.Caption = '&Son'
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
    ExplicitWidth = 804
    ExplicitHeight = 464
    DesignSize = (
      808
      465)
    object PageEkipmanKart: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Ekipman Kart Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Se'#231'ece'#287'iniz bilgi listede yoksa sol taraftaki ba'#351'l'#305#287'a t'#305'klay'#305'p e' +
        'kleyin.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnExitPage = PageEkipmanKartExitPage
      ExplicitWidth = 804
      ExplicitHeight = 422
      object LogoResim: TcxImage
        Left = 661
        Top = 122
        Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
        Properties.GraphicClassName = 'TdxSmartImage'
        Style.BorderColor = clBtnFace
        Style.Color = clBtnFace
        Style.Edges = []
        StyleDisabled.BorderStyle = ebsNone
        StyleFocused.BorderStyle = ebsNone
        TabOrder = 11
        OnClick = LogoResimClick
        Height = 111
        Width = 123
      end
      object KodAgaciTus: TcxButton
        Left = 244
        Top = 96
        Width = 25
        Height = 24
        OptionsImage.Glyph.SourceDPI = 96
        OptionsImage.Glyph.Data = {
          424DC60700000000000036000000280000001600000016000000010020000000
          000000000000C40E0000C40E00000000000000000000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
          00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
          00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
          00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000000000FF000000FF000000FF000000FFC0C0C000000000FFC0C0C0000000
          00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
          C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
          C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
          00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
          00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000000000FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
          00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
          C000C0C0C000}
        TabOrder = 1
      end
      object EditKOD: TcxDBTextEdit
        Left = 90
        Top = 97
        Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
        DataBinding.DataField = 'KOD'
        DataBinding.DataSource = DtsEkipman
        ParentShowHint = False
        ShowHint = True
        StyleDisabled.BorderColor = clWindowFrame
        StyleDisabled.Color = clWindow
        StyleDisabled.TextColor = clWindowText
        TabOrder = 0
        Width = 151
      end
      object cxDBTextEdit1: TcxDBTextEdit
        Left = 91
        Top = 122
        Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
        DataBinding.DataField = 'AD'
        DataBinding.DataSource = DtsEkipman
        ParentShowHint = False
        ShowHint = True
        StyleDisabled.BorderColor = clWindowFrame
        StyleDisabled.Color = clWindow
        StyleDisabled.TextColor = clWindowText
        TabOrder = 2
        Width = 177
      end
      object cxDBImageComboBox1: TcxDBImageComboBox
        Left = 90
        Top = 149
        RepositoryItem = Tablo.RepServisEkipmanTur
        DataBinding.DataField = 'EKIPMANTUR'
        DataBinding.DataSource = DtsEkipman
        Properties.Items = <
          item
            Description = 'Ekipman'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Alt Par'#231'a'
            Value = 1
          end>
        TabOrder = 3
        Width = 177
      end
      object cxDBMemo1: TcxDBMemo
        Left = 90
        Top = 301
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsEkipman
        TabOrder = 8
        Height = 37
        Width = 459
      end
      object cxDBImageComboBox2: TcxDBImageComboBox
        Left = 661
        Top = 97
        RepositoryItem = Tablo.RepAktifPasif
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsEkipman
        Properties.Items = <>
        TabOrder = 12
        Width = 121
      end
      object cxLabel1: TcxLabel
        Left = 6
        Top = 98
        Caption = 'Ekipman Kodu'
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 596
        Top = 99
        Caption = 'Durum'
        Transparent = True
      end
      object cxLabel3: TcxLabel
        Left = 6
        Top = 124
        Caption = 'Ad'#305
        Transparent = True
      end
      object cxLabel4: TcxLabel
        Left = 6
        Top = 151
        Caption = 'T'#252'r'#252
        Transparent = True
      end
      object cxLabel5: TcxLabel
        Left = 6
        Top = 302
        Caption = 'A'#231#305'klama'
        Transparent = True
      end
      object cxLabel8: TcxLabel
        Left = 296
        Top = 123
        Cursor = crHandPoint
        Caption = 'Stoklardan Getir...'
        Style.BorderColor = clHotLight
        Style.TextColor = clNavy
        Transparent = True
        OnClick = cxLabel8Click
      end
      object cxDBTextEdit2: TcxDBTextEdit
        Left = 373
        Top = 147
        DataBinding.DataField = 'STOKKODU'
        DataBinding.DataSource = DtsEkipman
        Enabled = False
        TabOrder = 9
        Width = 176
      end
      object cxLabel6: TcxLabel
        Left = 296
        Top = 149
        Caption = 'Stok Kodu'
        Transparent = True
      end
      object cxDBTextEdit3: TcxDBTextEdit
        Left = 373
        Top = 173
        DataBinding.DataField = 'STOKADI'
        DataBinding.DataSource = DtsEkipman
        Enabled = False
        TabOrder = 10
        Width = 176
      end
      object cxLabel7: TcxLabel
        Left = 296
        Top = 175
        Caption = 'Stok Ad'#305
        Transparent = True
      end
      object Label10: TcxLabel
        Left = 6
        Top = 221
        Caption = 'Kategori'
        Transparent = True
      end
      object EditKategori: TcxButtonEdit
        Left = 90
        Top = 218
        HelpType = htKeyword
        HelpKeyword = 'MASRAFID'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end
          item
            Caption = '-'
            Hint = 'Temizle'
            Kind = bkText
          end>
        Properties.OnButtonClick = EditKategoriPropertiesButtonClick
        TabOrder = 5
        Width = 124
      end
      object LabelKategori: TcxLabel
        Left = 220
        Top = 218
        Caption = '----'
        Transparent = True
      end
      object LabelMarka: TcxLabel
        Left = 6
        Top = 248
        Cursor = crHandPoint
        Hint = 'StokKart_Marka'
        HelpType = htKeyword
        HelpKeyword = 'STOKLAR.MARKA'
        Caption = 'Marka'
        FocusControl = ComboMARKA
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelMarkaClick
      end
      object ComboMARKA: TcxDBImageComboBox
        Left = 90
        Top = 245
        Cursor = crHandPoint
        DataBinding.DataField = 'MARKA'
        DataBinding.DataSource = DtsEkipman
        Properties.Items = <>
        Properties.OnEditValueChanged = ComboMARKAPropertiesEditValueChanged
        TabOrder = 6
        Width = 178
      end
      object LabelModel: TcxLabel
        Left = 6
        Top = 274
        Cursor = crHandPoint
        Caption = 'Model'
        FocusControl = ComboMODEL
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelModelClick
      end
      object ComboMODEL: TcxDBImageComboBox
        Left = 90
        Top = 272
        DataBinding.DataField = 'MODEL'
        DataBinding.DataSource = DtsEkipman
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 7
        Width = 178
      end
      object cxLabel9: TcxLabel
        Left = 6
        Top = 182
        Caption = 'Sahibi'
        Transparent = True
      end
      object RadioSAHIP: TcxDBRadioGroup
        Left = 90
        Top = 173
        DataBinding.DataField = 'SAHIP'
        DataBinding.DataSource = DtsEkipman
        Properties.Columns = 2
        Properties.DefaultValue = True
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Caption = 'Biz'
            Value = True
          end
          item
            Caption = 'Rakip'
            Value = False
          end>
        Properties.OnEditValueChanged = cxDBRadioGroup1PropertiesEditValueChanged
        TabOrder = 4
        Height = 36
        Width = 177
      end
    end
    object PageEkipmanDetay: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #304#231'erik Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Ekipman'#305'n'#305'z'#305' olu'#351'turan i'#231'eri'#287'i bu b'#246'l'#252'mde ekleyebilirsiniz.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'PageEkipmanDetay'
      object gridEkipmanDetay: TcxGrid
        Left = 0
        Top = 97
        Width = 808
        Height = 326
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object tvEkipmanDetay: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsEkipmanDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object tvEkipmanDetayEKIPMANID: TcxGridDBColumn
            Caption = 'Ekipman'
            DataBinding.FieldName = 'EKIPMANID'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = True
            Properties.OnButtonClick = tvEkipmanDetayEKIPMANIDPropertiesButtonClick
            OnGetDisplayText = tvEkipmanDetayEKIPMANIDGetDisplayText
            Width = 428
          end
          object tvEkipmanDetayADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            PropertiesClassName = 'TcxSpinEditProperties'
            Width = 78
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = tvEkipmanDetay
        end
      end
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 802
        Height = 24
        Margins.Bottom = 0
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
        TabOrder = 1
        Transparent = True
        object IcerikEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = IcerikEkleTusClick
        end
        object IcerikSilTus: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = IcerikSilTusClick
        end
        object IcerikKaydetTus: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsTextButton
          Visible = False
          OnClick = IcerikKaydetTusClick
        end
        object IcerikIptalTus: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Style = tbsTextButton
          Visible = False
          OnClick = IcerikIptalTusClick
        end
      end
    end
    object PageEkipmanBilgi: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay Bilgilerini Giriniz.'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'PageEkipmanBilgi'
      OnPage = PageEkipmanBilgiPage
      object GridKurIlet: TcxGrid
        Left = 0
        Top = 70
        Width = 808
        Height = 353
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          Styles.Content = AnaForm.cxStyle1
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Etiketi'
            DataBinding.FieldName = 'ETIKET'
            MinWidth = 150
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 150
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            PropertiesClassName = 'TcxTextEditProperties'
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
            MinWidth = 400
            Options.Filtering = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Styles.Content = Tablo.cxStyle1
            Width = 400
          end
          object GridDetayViewColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            Visible = False
            MinWidth = 64
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
          end
          object GridDetayViewColumnsec: TcxGridDBColumn
            Caption = 'Zorunlu'
            DataBinding.FieldName = 'ZORUNLU'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Visible = False
          end
        end
        object cxGridDetay: TcxGridLevel
          GridView = GridDetayView
        end
      end
      object ComboBolum: TcxDBComboBox
        Left = 87
        Top = 39
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsEkipman
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 1
        Width = 153
      end
      object lbDetaySablon: TcxLabel
        Left = 10
        Top = 40
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = lbDetaySablonClick
      end
      object SQLDetay: TcxMemo
        Left = 34
        Top = 117
        Lines.Strings = (
          'declare @yeri int'
          'declare @yerid int'
          'declare @bolum nvarchar(20)'
          'set @yeri = :Yeri'
          'set @yerid = :Yerid'
          'set @bolum = :Bolum'
          ''
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
          'name LIKE '
          #39'#DETAY_:SPID_%'#39')'
          'DROP TABLE #DETAY_:SPID_'
          ''
          'CREATE TABLE #DETAY_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](50) NULL,'
          #9'[BILGI] [nvarchar](100) NULL,'
          #9'[ORJINAL] [nvarchar](100) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #DETAY_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB '
          'INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA AND RA.YERI=88'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
            '  '
          ' from REHBERAYAR  '
          'where  YERI=88'
          'and isnull(BOLUM,'#39#39')=@Bolum  '
          'and ETIKET not in (select ETIKET from REHBERBILGI where  '
          'YERI=@yeri   and YER_ID= @yerid )'
          ''
          'order by 1'
          ''
          'select * from #DETAY_:SPID_'
          'order by SIRA')
        TabOrder = 3
        Visible = False
        Height = 264
        Width = 387
      end
    end
    object PageEkipmanBelge: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'D'#246'k'#252'man Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'PageEkipmanBelge'
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 802
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 76
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
        object BelgeEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Belge Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
          OnClick = BelgeEkleTusClick
        end
        object BelgeSilTus: TToolButton
          Left = 76
          Top = 0
          Caption = 'Belge Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
          OnClick = BelgeSilTusClick
        end
        object BelgeGorTus: TToolButton
          Left = 152
          Top = 0
          Caption = 'Belge G'#246'r'
          ImageIndex = 6
          ImageName = 'PngImage6'
          Style = tbsTextButton
          OnClick = BelgeGorTusClick
        end
        object ToolButton2: TToolButton
          Left = 228
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsSeparator
        end
        object KaydetTus: TToolButton
          Left = 236
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = KaydetTusClick
        end
        object IptalTus: TToolButton
          Left = 312
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = IptalTusClick
        end
      end
      object GridBelge: TcxGrid
        Left = 0
        Top = 97
        Width = 808
        Height = 326
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridBelgeDBTableViewImaj: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
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
    object LabelAciklama: TcxDBLabel
      Left = 487
      Top = 29
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsEkipman
      Properties.WordWrap = True
      Height = 37
      Width = 363
    end
    object LabelID: TcxDBLabel
      Left = 425
      Top = 29
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = DtsEkipman
      Height = 19
      Width = 60
    end
    object LabelAd: TcxDBLabel
      Left = 488
      Top = 4
      DataBinding.DataField = 'AD'
      DataBinding.DataSource = DtsEkipman
      Height = 19
      Width = 361
    end
    object LabelKod: TcxDBLabel
      Left = 224
      Top = 4
      DataBinding.DataField = 'KOD'
      DataBinding.DataSource = DtsEkipman
      Height = 19
      Width = 264
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 85
    Height = 465
    Align = alLeft
    TabOrder = 0
    ExplicitHeight = 464
    object btnServis: TcxButton
      Left = 9
      Top = 80
      Width = 65
      Height = 29
      Caption = 'Ekipman'
      TabOrder = 0
      OnClick = btnServisClick
    end
    object btnIcerik: TcxButton
      Tag = 1
      Left = 9
      Top = 113
      Width = 65
      Height = 29
      Caption = #304#231'erik'
      TabOrder = 1
      OnClick = btnIcerikClick
    end
    object BtnDokuman: TcxButton
      Tag = 3
      Left = 9
      Top = 146
      Width = 65
      Height = 29
      Caption = 'Dok'#252'man'
      TabOrder = 2
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnDokumanClick
    end
    object BtnBilgi: TcxButton
      Tag = 3
      Left = 9
      Top = 181
      Width = 65
      Height = 29
      Caption = 'Detay'
      TabOrder = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnBilgiClick
    end
  end
  object TabEkipman: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabEkipmanAfterOpen
    BeforeEdit = TabEkipmanBeforeEdit
    BeforePost = TabEkipmanBeforePost
    AfterPost = TabEkipmanAfterPost
    OnNewRecord = TabEkipmanNewRecord
    ParamData = <>
    SQL.Strings = (
      'select E.* ,'
      'STOKKODU=(select S.KOD from STOKLAR S where S.ID=E.URUNID),'
      'STOKADI=(select S.STOKADI from STOKLAR S where S.ID=E.URUNID)'
      'from EKIPMANLAR E'
      'where E.ID=:PID')
    Left = 565
    Top = 38
  end
  object DtsEkipman: TDataSource
    DataSet = TabEkipman
    Left = 847
    Top = 30
  end
  object TabBelge: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabEkipmanBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT  *  FROM  [IMAJ]'
      'WHERE'
      'YERI = :PYeri and'
      'YER_ID = :PYerID')
    Left = 807
    Top = 26
  end
  object DtsBelge: TDataSource
    DataSet = TabBelge
    OnDataChange = DtsBelgeDataChange
    Left = 840
    Top = 169
  end
  object OpenDialog1: TOpenDialog
    Left = 668
    Top = 20
  end
  object TabEkipmanDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    BeforePost = TabEkipmanBeforePost
    AfterPost = TabEkipmanAfterPost
    ParamData = <>
    SQL.Strings = (
      'select * from EKIPMANDETAY where USTEKIPMANID=:PID')
    Left = 737
    Top = 35
  end
  object DtsEkipmanDetay: TDataSource
    DataSet = TabEkipmanDetay
    OnStateChange = DtsEkipmanDetayStateChange
    Left = 796
    Top = 160
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 510
    Top = 34
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 472
    Top = 27
  end
end
