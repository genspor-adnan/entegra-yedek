object HavaleEFTEkrani: THavaleEFTEkrani
  Left = 0
  Top = 0
  Caption = 'Havale/EFT G'#246'nderim Ekran'#305
  ClientHeight = 500
  ClientWidth = 914
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TcxLabel
    Left = 86
    Top = 94
    AutoSize = False
    Caption = 'Ba'#287'lant'#305' Kuruluyor...'
    Visible = False
    Height = 13
    Width = 305
  end
  object Label2: TcxLabel
    Left = 86
    Top = 113
    AutoSize = False
    Caption = 'Ba'#287'lant'#305' Kuruldu.'
    Visible = False
    Height = 13
    Width = 305
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 908
    Height = 22
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 20
    ButtonWidth = 40
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
    object btnKapat: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 25
    Width = 233
    Height = 475
    Align = alLeft
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 231
      Height = 41
      Align = alTop
      TabOrder = 0
      object cxLabel1: TcxLabel
        Left = 6
        Top = 8
        Caption = 'G'#246'nderen Banka Bilgileri  '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold, fsItalic]
        Style.IsFontAssigned = True
      end
    end
    object cxGrid3: TcxGrid
      Left = 1
      Top = 42
      Width = 231
      Height = 432
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridViewBanka: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCellClick = GridViewBankaCellClick
        DataController.DataSource = DtsGonderen
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        object GridViewBankaLOGO: TcxGridDBColumn
          Caption = 'Banka'
          DataBinding.FieldName = 'LOGO'
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TdxPNGImage'
          Properties.Proportional = False
          Width = 111
        end
        object GridViewBankaKUR: TcxGridDBColumn
          Caption = 'D'#246'viz'
          DataBinding.FieldName = 'KUR'
          Width = 32
        end
        object GridViewBankaBANKAKODU: TcxGridDBColumn
          DataBinding.FieldName = 'BANKAKODU'
          Visible = False
        end
        object GridViewBankaBANKAADI: TcxGridDBColumn
          Caption = 'Banka Ad'#305
          DataBinding.FieldName = 'BANKAADI'
          Options.Editing = False
          Width = 169
        end
        object GridViewBankaSUBEKODU: TcxGridDBColumn
          DataBinding.FieldName = 'SUBEKODU'
        end
        object GridViewBankaSUBEADI: TcxGridDBColumn
          DataBinding.FieldName = 'SUBEADI'
        end
        object GridViewBankaHESAPNO: TcxGridDBColumn
          DataBinding.FieldName = 'HESAPNO'
        end
        object GridViewBankaMUSTERINO: TcxGridDBColumn
          Caption = 'M'#252#351'teri No'
          DataBinding.FieldName = 'MUSTERINO'
        end
        object GridViewBankaEMAIL: TcxGridDBColumn
          Caption = 'E-Mail'
          DataBinding.FieldName = 'EMAIL'
        end
      end
      object cxGridLevel3: TcxGridLevel
        GridView = GridViewBanka
      end
    end
  end
  object HavaleWizard: TJvWizard
    Left = 233
    Top = 25
    Width = 681
    Height = 475
    ActivePage = SayfaGiris1
    ButtonBarHeight = 42
    ButtonStart.Caption = '&Ba'#351'lang'#305#231
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = '&Son'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Bitir'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Yard'#305'm'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = HavaleWizardFinishButtonClick
    OnCancelButtonClick = HavaleWizardCancelButtonClick
    DesignSize = (
      681
      475)
    object SayfaGiris1: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Havale / EFT G'#246'nderme Sihirbaz'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Alttaki al'#305'c'#305' listesi bilgileri tamamsa sonraki butona bas'#305'n'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Panel.Color = clHotLight
      EnabledButtons = [bkNext, bkCancel]
      VisibleButtons = [bkNext, bkCancel]
      OnNextButtonClick = SayfaGiris1NextButtonClick
      WaterMark.Width = 10
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 10
        Top = 70
        Width = 671
        Height = 363
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCellClick = cxGridDBTableView1CellClick
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsAlici
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.ScrollBars = ssVertical
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = cxGridDBTableView1StylesGetContentStyle
          object cxGridDBTableView1SEC: TcxGridDBColumn
            Caption = 'Se'#231
            DataBinding.ValueType = 'Boolean'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ImmediatePost = True
            Properties.NullStyle = nssUnchecked
            Width = 34
          end
          object cxGridDBTableView1UNVAN: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'UNVAN'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 100
          end
          object cxGridDBTableView1BANKAKODU: TcxGridDBColumn
            DataBinding.FieldName = 'BANKAKODU'
            PropertiesClassName = 'TcxLabelProperties'
            Visible = False
          end
          object cxGridDBTableView1BANKAADI: TcxGridDBColumn
            Caption = 'Banka'
            DataBinding.FieldName = 'BANKAADI'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 62
          end
          object cxGridDBTableView1SUBEKODU: TcxGridDBColumn
            Caption = #350'ube Kodu'
            DataBinding.FieldName = 'SUBEKODU'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 77
          end
          object cxGridDBTableView1SUBEADI: TcxGridDBColumn
            Caption = #350'ube Ad'#305
            DataBinding.FieldName = 'SUBEADI'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 95
          end
          object cxGridDBTableView1HESAPNO1: TcxGridDBColumn
            Caption = 'Hesap No'
            DataBinding.FieldName = 'HESAPNO'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 79
          end
          object cxGridDBTableView1IBAN: TcxGridDBColumn
            DataBinding.FieldName = 'IBAN'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 102
          end
          object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            PropertiesClassName = 'TcxLabelProperties'
          end
          object cxGridDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'CIKAN'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 69
          end
          object cxGridDBTableView1DOVIZ: TcxGridDBColumn
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'KUR'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 38
          end
          object cxGridDBTableView1DURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxLabelProperties'
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
    object SayfaIslemSecimi2: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Title'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Subtitle'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      EnabledButtons = []
      VisibleButtons = [bkNext, bkCancel]
      OnPage = SayfaIslemSecimi2Page
      object LabelDosyalarHazirlaniyor: TcxLabel
        Left = 57
        Top = 129
        AutoSize = False
        Caption = 'Dosyalar Haz'#305'rlan'#305'yor...'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 305
      end
      object LabelDosyalarHazirlandi: TcxLabel
        Left = 57
        Top = 223
        AutoSize = False
        Caption = 'Dosyalar Haz'#305'rland'#305'.'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 305
      end
      object LabelPDFHazir: TcxLabel
        Left = 57
        Top = 185
        AutoSize = False
        Caption = 'Talimat Dosyas'#305' (PDF) Haz'#305'rlan'#305'yor...'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 217
      end
      object LabelTextHazir: TcxLabel
        Left = 57
        Top = 148
        AutoSize = False
        Caption = 'Desen Dosyas'#305' (TXT) Haz'#305'rlan'#305'yor...'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 217
      end
      object LabelPDFTamam: TcxLabel
        Left = 57
        Top = 204
        AutoSize = False
        Caption = 'Tamam.'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 49
      end
      object LabelTXTTamam: TcxLabel
        Left = 57
        Top = 167
        AutoSize = False
        Caption = 'Tamam.'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 49
      end
      object LabelPDFIptal: TcxLabel
        Left = 57
        Top = 204
        AutoSize = False
        Caption = #304'ptal'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 49
      end
      object LabelTXTIptal: TcxLabel
        Left = 57
        Top = 167
        AutoSize = False
        Caption = #304'ptal'
        ParentFont = False
        Visible = False
        Height = 13
        Width = 49
      end
    end
    object SayfaTalimat3: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Talimat '#214'nizleme'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Alttaki talimat'#305' okuyup onayl'#305'yorsan'#305'z sonraki sayfaya ge'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkNext, bkCancel]
      OnPage = SayfaTalimat3Page
      object frxPreview1: TfrxPreview
        Left = 0
        Top = 70
        Width = 681
        Height = 331
        Align = alClient
        OutlineVisible = False
        OutlineWidth = 120
        ThumbnailVisible = False
        UseReportHints = True
      end
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 404
        Width = 675
        Height = 29
        Margins.Bottom = 0
        Align = alBottom
        ButtonHeight = 20
        ButtonWidth = 44
        Caption = 'AletCubugu'
        DockSite = True
        DrawingStyle = dsGradient
        EdgeInner = esNone
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        List = True
        ParentFont = False
        ShowCaptions = True
        AllowTextButtons = True
        TabOrder = 1
        object YaziciYaz: TToolButton
          Left = 0
          Top = 0
          Caption = 'Talimat'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          PopupMenu = FastRaporDlg.pmDokumAyarlar
          Style = tbsTextButton
          OnMouseDown = YaziciYazMouseDown
        end
      end
    end
    object SayfaImzalamaIslemleri4: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #304'mzalama '#304#351'lemleri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Mobil imza i'#351'lemleri i'#231'in ad'#305'mlar'#305' takip ediniz. '
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkStart, bkLast, bkBack, bkFinish, bkCancel, bkHelp]
      VisibleButtons = [bkNext, bkCancel]
      OnEnterPage = SayfaImzalamaIslemleri4EnterPage
      OnPage = SayfaImzalamaIslemleri4Page
      ExplicitWidth = 0
      ExplicitHeight = 0
      object JvInstallLabel1: TJvInstallLabel
        Left = 32
        Top = 76
        Width = 612
        Height = 176
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        Images = imgListYukleme
        Lines.Strings = (
          ''
          'Ba'#287'lant'#305' kuruluyor...'
          'Dosya g'#246'nderiliyor...'
          '[ParmakIzi]'
          '[Imzalayan]'
          'Dosya kaydediliyor...'
          #304'mzalama i'#351'lemi tamamland'#305'.')
        ParentFont = False
      end
      object cxButton1: TcxButton
        Left = 421
        Top = 381
        Width = 75
        Height = 23
        Caption = #304'mzala'
        TabOrder = 0
        OnClick = cxButton1Click
      end
      object ImageSertifika: TcxImage
        Left = 485
        Top = 212
        Picture.Data = {
          0954474946496D6167654749463839614A008100F70000000000000033000066
          0000990000CC0000FF002B00002B33002B66002B99002BCC002BFF0055000055
          330055660055990055CC0055FF0080000080330080660080990080CC0080FF00
          AA0000AA3300AA6600AA9900AACC00AAFF00D50000D53300D56600D59900D5CC
          00D5FF00FF0000FF3300FF6600FF9900FFCC00FFFF3300003300333300663300
          993300CC3300FF332B00332B33332B66332B99332BCC332BFF33550033553333
          55663355993355CC3355FF3380003380333380663380993380CC3380FF33AA00
          33AA3333AA6633AA9933AACC33AAFF33D50033D53333D56633D59933D5CC33D5
          FF33FF0033FF3333FF6633FF9933FFCC33FFFF66000066003366006666009966
          00CC6600FF662B00662B33662B66662B99662BCC662BFF665500665533665566
          6655996655CC6655FF6680006680336680666680996680CC6680FF66AA0066AA
          3366AA6666AA9966AACC66AAFF66D50066D53366D56666D59966D5CC66D5FF66
          FF0066FF3366FF6666FF9966FFCC66FFFF9900009900339900669900999900CC
          9900FF992B00992B33992B66992B99992BCC992BFF9955009955339955669955
          999955CC9955FF9980009980339980669980999980CC9980FF99AA0099AA3399
          AA6699AA9999AACC99AAFF99D50099D53399D56699D59999D5CC99D5FF99FF00
          99FF3399FF6699FF9999FFCC99FFFFCC0000CC0033CC0066CC0099CC00CCCC00
          FFCC2B00CC2B33CC2B66CC2B99CC2BCCCC2BFFCC5500CC5533CC5566CC5599CC
          55CCCC55FFCC8000CC8033CC8066CC8099CC80CCCC80FFCCAA00CCAA33CCAA66
          CCAA99CCAACCCCAAFFCCD500CCD533CCD566CCD599CCD5CCCCD5FFCCFF00CCFF
          33CCFF66CCFF99CCFFCCCCFFFFFF0000FF0033FF0066FF0099FF00CCFF00FFFF
          2B00FF2B33FF2B66FF2B99FF2BCCFF2BFFFF5500FF5533FF5566FF5599FF55CC
          FF55FFFF8000FF8033FF8066FF8099FF80CCFF80FFFFAA00FFAA33FFAA66FFAA
          99FFAACCFFAAFFFFD500FFD533FFD566FFD599FFD5CCFFD5FFFFFF00FFFF33FF
          FF66FFFF99FFFFCCFFFFFF00000000000000000000000021F904010000FC002C
          000000004A008100870000000000330000660000990000CC0000FF002B00002B
          33002B66002B99002BCC002BFF0055000055330055660055990055CC0055FF00
          80000080330080660080990080CC0080FF00AA0000AA3300AA6600AA9900AACC
          00AAFF00D50000D53300D56600D59900D5CC00D5FF00FF0000FF3300FF6600FF
          9900FFCC00FFFF3300003300333300663300993300CC3300FF332B00332B3333
          2B66332B99332BCC332BFF3355003355333355663355993355CC3355FF338000
          3380333380663380993380CC3380FF33AA0033AA3333AA6633AA9933AACC33AA
          FF33D50033D53333D56633D59933D5CC33D5FF33FF0033FF3333FF6633FF9933
          FFCC33FFFF6600006600336600666600996600CC6600FF662B00662B33662B66
          662B99662BCC662BFF6655006655336655666655996655CC6655FF6680006680
          336680666680996680CC6680FF66AA0066AA3366AA6666AA9966AACC66AAFF66
          D50066D53366D56666D59966D5CC66D5FF66FF0066FF3366FF6666FF9966FFCC
          66FFFF9900009900339900669900999900CC9900FF992B00992B33992B66992B
          99992BCC992BFF9955009955339955669955999955CC9955FF99800099803399
          80669980999980CC9980FF99AA0099AA3399AA6699AA9999AACC99AAFF99D500
          99D53399D56699D59999D5CC99D5FF99FF0099FF3399FF6699FF9999FFCC99FF
          FFCC0000CC0033CC0066CC0099CC00CCCC00FFCC2B00CC2B33CC2B66CC2B99CC
          2BCCCC2BFFCC5500CC5533CC5566CC5599CC55CCCC55FFCC8000CC8033CC8066
          CC8099CC80CCCC80FFCCAA00CCAA33CCAA66CCAA99CCAACCCCAAFFCCD500CCD5
          33CCD566CCD599CCD5CCCCD5FFCCFF00CCFF33CCFF66CCFF99CCFFCCCCFFFFFF
          0000FF0033FF0066FF0099FF00CCFF00FFFF2B00FF2B33FF2B66FF2B99FF2BCC
          FF2BFFFF5500FF5533FF5566FF5599FF55CCFF55FFFF8000FF8033FF8066FF80
          99FF80CCFF80FFFFAA00FFAA33FFAA66FFAA99FFAACCFFAAFFFFD500FFD533FF
          D566FFD599FFD5CCFFD5FFFFFF00FFFF33FFFF66FFFF99FFFFCCFFFFFF000000
          00000000000000000008FF00F9091C48B0A0C18308132A5CC8B0A14381B6142D
          A2458BD7C38B18332A53A6A896376FDF3E5ACC48B224C189B5CA0963C78EDC37
          5ADECA9563576ED83E933819A2FCC6AE1DBB751E7779F3983218BB5DBCF6DDCC
          C9941F2D943385B55BA7EB9BAEA1316991F3C8F3E8A2614D4DEEEBF8AD5CBB61
          2CB75A7D598ED64BB63065D2AC552BECC57DB5DCB2F4B96ED756726E03B75D4B
          AB6DADAD2AD795AB6B7721ADBC3D57026B8B95EED6C7985F12C55AD5DB2EC5E5
          1A1FC4FBB827E8C09A01E75D8D79D7E3AA55DD763E1C5AF4C07D146BF50C76D9
          6A5ED77431B31EFED83356A16C6DF31B86B2A73AA297872B7A4A7D22CAE2AB87
          6EF5D679A4DD7DBC1E9BFF0DA69D782D458568155244681121F41D3B52AFA50B
          7A50904BC366CAFB6D98E2C0AC59F79E7B8BB832517A85BCB7DE70F569F79237
          6085455A2D2B5D061C66EBB5E78A7918D2829E7082C956567E3965F2986EC1BC
          251C7CE911F7CA631B62F68A44F2B1469837F384151C4B43AD58CB7BABC5D8E2
          7C20FE58204ADB79D4163B2496841B5D73D587997B79BDB85A2DBBD882A596C1
          CD68A581356236182D4D66B4CF229009D3635EEE8549572DBCD065DD748BA019
          DC6A8A18286688E6E0A4D4893481B8DE8B56C2791E7BEC11A2E87B40D215E379
          C325E98D322611B31A3BC20048239E74F1922821B4802A6AA88CD6B821213616
          A62A3B4E4AD2916ED175FF046AA171B2E74A9EB8DEAA2BAE8AB2F9588DB1BDE5
          4D990D3D490BA601A22A5C788AB217EAB333EACAE8ADCAD6A2276B6D651B2146
          8BCC68CE516B827A252FEFE91AAAB57951E4CA63A052FB9E95446EE611AB184D
          082E9BAFD2F20A96CE2A1B2345F0DE4ACBAE8ACA58E35F8715562FA4DF46F7D4
          A374A10AAA222FAA9BEEBAD6EA4B31AFF10A87D537F552BC0B3B529E576D47BB
          8C3AB0C700E6A62EAF2D5EFB984BB0817C114AE6ACB3A69B11813A707630F117
          343600BFAC2BA79915E60D2D1749A29E4A42FF882E5D79A24BD14BD904B6B48A
          17179868478FEEB9D645B54C4453ACC3D532234530BDB875D00FE6E5CDBF7992
          1A2080DB31FD50A8E5F0FFE27081909E57B4DC423F484BD695FD7CEB8CE2862D
          94927A37645DCE954D77E57915BBA262DC9525DEE3B3E55E57786C0F49CDCECC
          AB552B38885869BD99EBEB6E28EDDDF4ADB595438CA0BA8B4C3B0F07B82B6FA3
          76B8EB6F7F3E307BA263779C438B74D492A03006E7F25BC00BDD792DD810A578
          9EE28228D4F70FA1E497F6454EA47960C2734EFCD56C33AE2F882A7AF3107A32
          BD7419E0275A0ED3F95A03D8E34B81C9DAFB701538D4FDC53B0CB9953974518E
          35FD2A75882B9CFF5EB739971D8F1031BA908AB6A59394BC2D2F147B5FBA28C8
          BEEC6DED7C3DC28AEC7EE42655B56517C442484778F7B8228550333DCA9A8A84
          D7BAACA5EB7861D3DE4BFF6288904594E32A1E0151A1D826C0B8052D85515B9A
          4762F4AE13D1C2352FDC054608D1C006D61055F2B921FBA098BE2712AE68D5EA
          4D60E8C1AD723C0880AC81970437F38AA579C36DD64A1C8C4205B6ECB866171C
          740896C89115C340AF898F211A007128AF3B2E4D80E7C9E015B1439245B8242E
          C2091BAAC8B8C345B22F68ED03D2898E430B4A656411DF20640393E8AB172D22
          852F8263EB18F93FF485302F2F1C8A162B79C9A5197238186B9D47EA08232726
          6E85DDCB0E7D4CF24A97F4322FA88A5181E0E83AE111F31B316A5DF7B0281B04
          6244110D344E5B8AF4ABE10D259B67AC65E20AE1A89414C73544D4094808F9C6
          15110A3B66AC9EFF92A6FF1E97B98630DEE496372E49B31186AD459CA4880EF5
          75C28C59CD3043D1453D70028690383324202167906A293CF60170469052D561
          461A0D9C80CA254BFB0BF45E34A43BB6ACA37989D96F94261B62E4642CA91C28
          46B5471C114AF191F8CCDA907EB3CAD8EC62A23949CF3C95061B1F6DE8963F83
          2545D213BD99152795B408A4939A69D19D9ED36AAC2944D89E7A2DD6EC2E3694
          A9854D9BA2948F50462808CB644831B7B1387AE845E5008CFD42B28B5D86E529
          F4A4A771A4045219691462B4A00A74E0B256BBB8472B21B98A767E19B62F594B
          740C749064C9D157E584E19531996764F3CA299925CF2FA4DD0E4846CA46E568
          4111168549670AC3D922FF0591819CDDDA400F33D05D08433902D9477A028BD1
          B690831C7925ED248F580E751C31244C2D6E7DE2C994F7E454A75709C96118A8
          8B7538971CEBB8A44579DB55CE7E031AC02548210819DAC00E14241F01C95502
          43C8CE60B5810C24537A09A205B708969E9DA98A6A1B88D270FEF7881EA2AE84
          20ABCAD0BEF7BA28DD8E5E097A4410D24217FB25082130CADE06E734A79D89F0
          3C6B4B91E9E8821639CA303F16719502C357A78444A9839D49628A40E2C490A0
          4530542C108FBCF7BD326EEF7B53CBB61BDFF88ABA48B22E141C965486A48139
          45AE4E432B940B5FF8C627D68522927CE15D2C99C702792FDBAC9CE50B7327C9
          C048F29195ECE524FB45FF17EA007370C39066251B59C94AA6459DD98CE75D00
          831C698EB39CF981E7421B1ACEBAF0729A170D6872C01918EA50073006BD883D
          1F1ACF92D605A37933194803631D90163498354D6A522F5AD37E46B4A4CBE169
          49BB3AD4A196B3A601DDDD24AB43178DFEB3A75BAD6B570723D2AD963330208D
          6848FBF9D69E06F42E80AD0E50373BD2AE8E343C203DEA5BBBFAD1D16E35B65D
          6D8C57C3431DDD8E358F79CD6C5F333B18903E863ABE0DEE7543DA18EB98F6B4
          45BDDF50BF9AD9B08E742480F16D79F3BBDDFD0EF5BC557CEF82675B1D9190B4
          BCE3AD0E75C32318F296F7BAD791617EE7FBD3F7867524FAFD6D63F4DBE3EB9E
          78B7BB9DE173433BDFF1FFB0383F14018F63441CE41D8747B7FB0D6E8AA71718
          DDC677A4672E707E8481E31E8FB7C75D0E0FA1B71C1ED396477A999DF3707BF7
          DF331783C7E1110FA44F1DE932477AC839CE6492FC1BD2F30E78CCC1BD0F4904
          C3E357A7FACC651E0FB4677DD2CA69B73A7EDDEE7F3F9CE3FC90C42E905EF5A3
          F31DEB588FC7BA918E0CE574DCDDDF8638C0AD0E0F8108A3EF579FBAC7DBCEF8
          947FBBEB170975D3436E8CAAF35BF08DE707C43D7E0FA4DBA3EAF6003CE501CF
          6FDB2CDCEEFC8E78D6652E1078A49EEFC6B8BD314A9F768FC77EC78D61F7CC21
          CE71BF533DF447B747EED55E7AA437DFE1F196778AC3727889539EE858F7F840
          6C6F7BD49B5EF2D9CFBAFFE783CF73C60F9EED572F3C3FF89EFAD437BFEF87AF
          FAE28F6117A4FF5BFEE00F7CF705927A6620BD198C877EC7377B59A70E4AD714
          DD5675BE777C7D4774FE8774DB170FB7F7775A677E6AA70E0A187A4C617FC517
          7EDCE77C1A180C1348746ED77BD93778C6D014D94779AB3780C7907A1E971FFB
          40809DF77796877FE187814C610F760778C9B77C54777B033181F0E78101D877
          19788026817B59E7714418802E37849437752E7775449781692773D34712B387
          844CC8763E487FB5A77F80877D04A880AB670C5B8811A9076E8C97856FC87752
          087E4558836AE78348B70EC7A00C9857106E28730CE7779D777519A87EEBF781
          B3678691677FC0971358FF878280478859688800987C03287E36780991D0870A
          81762D687945778654B87DAA4787DF070C4AC1890B617B83F7893448864B717A
          40C87D12E8719710064AA11C9F5780F9E78250281040C88253670FB8B85FEAA0
          7C64887D706875F130107D3781A9170FAA9811C0F07E040886C7578376980CB5
          878C2FD8723CC863C7288A91788D1F7880D58887C7308D19A10BD11880970879
          BC5775FEB714A6078EF0C08E24018303E876F1F08045F877EA8774D887068376
          7AF028813E787BCC408F72C87FA6170CFAC885B79781603888148875A9478AF7
          209183B67E901784F0777BBC0783B2A881FB600FB9F891CB07844E68875D7889
          10C80FC2800C136912E38FD877CDA791A487740FE87FFF8892375912C0809092
          F77C3EF88CF7780F1F7910EEF8803BE984FF677BB9577AC7200C98D09408918E
          8C678DA7670FF6700CC1800992A0950BB177D13881F0E07FF7600C6569960F01
          0F6DC98CEE9782709911B79797CD789724318FF6D00C8DC8976C687BF6109882
          891172790C6F799824110CC190098C69129019999459995A1910003B}
        Properties.PopupMenuLayout.MenuItems = []
        Style.BorderStyle = ebsNone
        Style.Shadow = False
        TabOrder = 1
        Transparent = True
        Visible = False
        Height = 134
        Width = 131
      end
      object ComboOperator: TcxDBImageComboBox
        Left = 349
        Top = 383
        DataBinding.DataField = 'IMZA_GSM_OP'
        DataBinding.DataSource = DtsBankaAyar
        Properties.Items = <
          item
            Description = 'T'#252'rkCell'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Avea'
            Value = 2
          end
          item
            Description = 'VodaFone'
            Value = 3
          end>
        TabOrder = 2
        Width = 68
      end
      object EditTelefon: TcxDBTextEdit
        Left = 222
        Top = 383
        DataBinding.DataField = 'IMZA_GSM'
        DataBinding.DataSource = DtsBankaAyar
        TabOrder = 3
        Width = 121
      end
    end
    object SayfaDurumGoruntule5: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'G'#246'nderim Durumu G'#246'r'#252'nt'#252'leniyor'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'L'#252'tfen Bekleyiniz...'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkStart, bkLast, bkBack, bkNext, bkCancel, bkHelp]
      VisibleButtons = [bkNext, bkCancel]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      OnEnterPage = SayfaImzalamaIslemleri4EnterPage
      OnPage = SayfaDurumGoruntule5Page
      ExplicitWidth = 0
      ExplicitHeight = 0
      object JvInstallLabel2: TJvInstallLabel
        Left = 33
        Top = 97
        Width = 550
        Height = 288
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        Images = imgListYukleme
        Lines.Strings = (
          'Ba'#287'lant'#305' Kuruluyor...'
          'Kullan'#305'c'#305' Ad'#305' ve '#350'ifre Do'#287'rulan'#305'yor...'
          'Anahtar Do'#287'rulan'#305'yor...'
          'Ba'#287'lant'#305' Ba'#351'ar'#305'yla Kuruldu.'
          'Senkronize Olunuyor...'
          'Dosya G'#246'nderim i'#231'in haz'#305'rlan'#305'yor...'
          '[DOSYAADI]'
          'Dosya G'#246'nderiliyor...'
          'Dosya Ba'#351'ar'#305'yla G'#246'nderildi.'
          'Ba'#287'lant'#305' Kesiliyor...'
          'G'#246'nderim '#304#351'lemi Tamamland'#305'.')
        ParentFont = False
      end
    end
    object SayfaSon6: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Son'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Havale/EFT talimat'#305'n'#305'z bankan'#305'za iletildi'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkFinish]
      VisibleButtons = [bkFinish]
      OnEnterPage = SayfaImzalamaIslemleri4EnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object TabGonderen: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT'
      ' HESAPID,'
      ' ASD.MUSTERINO,'
      ' ASD.EPOSTA,'
      ' B.LOGO,'
      ' B.BANKAKODU,'
      ' B.BANKAADI,'
      ' ASD.SUBEKODU,'
      ' ASD.SUBEADI, '
      ' ASD.HESAPNO,'
      ' ASD.KUR,'
      ' ASD.FIRMANO'
      'FROM'
      'BANKALAR B INNER JOIN'
      '('
      'select DISTINCT'
      'P.HESAPID,B.BANKAKODU,BS.SUBEKODU,BS.SUBEADI,BH.HESAPNO,P.KUR,'
      'BH.MUSTERINO,BH.FIRMANO,BH.EPOSTA'
      ''
      'FROM'
      'KASA P'
      'inner join BANKAHESAPLAR BH on BH.ID = P.HESAPID'
      'inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU = BS.BANKAKODU'
      'WHERE'
      'P.TUR = 71 AND'
      'P.HESAPTURU = '#39'B'#39' AND'
      'P.PLANTARIHI = :pTarih'
      ') ASD ON'
      'B.BANKAKODU=ASD.BANKAKODU')
    Left = 18
    Top = 98
  end
  object DtsGonderen: TDataSource
    DataSet = TabGonderen
    Left = 20
    Top = 147
  end
  object DtsAlici: TDataSource
    DataSet = TabAlici
    Left = 252
    Top = 185
  end
  object TabAlici: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      '--select * from dbo.REHBERBILGI'
      'REHID=R.ID,'
      'P.ID,'
      'P.PLANTARIHI,'
      'TARIH=P.PLANTARIHI,'
      'G_FIRMA=(SELECT FIRMA FROM REHBER WHERE ID=-1) ,'
      
        'G_ADRES=((SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI' +
        ' RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AN' +
        'D RA.VARSAYILAN=2)+'#39' '#39'+(SELECT BILGI FROM REHBERAYAR RA INNER JO' +
        'IN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE R' +
        'B.YER_ID=-1 AND RA.VARSAYILAN=4)+'#39' '#39'+(SELECT BILGI FROM REHBERAY' +
        'AR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=R' +
        'B.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=6)+'#39' '#39'+(SELECT BILGI' +
        ' FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=8)),'
      
        'G_EPOSTA=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI' +
        ' RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AN' +
        'D RA.VARSAYILAN=46),'
      'G_BANKA=BA.BANKAADI,'
      'G_BANKA_KODU=BA.BANKAKODU,'
      'G_SUBE_KODU=BSA.SUBEKODU,'
      'G_SUBE_ADI=BSA.SUBEADI,'
      'G_HESAPNO=BHA.HESAPKODU,'
      
        'G_VD=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ' +
        'ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA' +
        '.VARSAYILAN=20),'
      
        'G_VNO=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB' +
        ' ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND R' +
        'A.VARSAYILAN=22),'
      
        'G_VDKODU=(SELECT VL.VDKODU FROM REHBER R LEFT OUTER JOIN VDLISTE' +
        ' VL ON (SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI R' +
        'B ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND ' +
        'RA.VARSAYILAN=20)=VL.VD WHERE ID=-1),'
      
        'YAZIYLATOPLAM=(SELECT DBO.fn_MoneyToText((SUM(CIKAN)),'#39'TL'#39','#39'Kr'#39')' +
        ' FROM KASA P1 WHERE P1.TUR = P.TUR AND P1.HESAPTURU = P.HESAPTUR' +
        'U AND P1.PLANTARIHI=P.PLANTARIHI AND P1.HESAPID=P.HESAPID ),'
      'TUR=CASE WHEN P.REHBERID=-1 THEN '#39'VRM'#39
      #9#9' WHEN BM.BANKAADI=BA.BANKAADI THEN '#39'EFT'#39' ELSE '#39'HAVALE'#39' END,'
      'REHID=R.ID,'
      'UNVAN=R.FIRMA,'
      
        'ADRES=((SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI R' +
        'B ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AN' +
        'D RA.VARSAYILAN=2)+'#39' '#39'+(SELECT BILGI FROM REHBERAYAR RA INNER JO' +
        'IN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE R' +
        'B.YER_ID=R.ID AND RA.VARSAYILAN=4)+'#39' '#39'+(SELECT BILGI FROM REHBER' +
        'AYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI' +
        '=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6)+'#39' '#39'+(SELECT B' +
        'ILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.' +
        'SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=' +
        '8)),'
      
        'ISTEL=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB' +
        ' ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND' +
        ' RA.VARSAYILAN=40),'
      
        'VD=LTRIM(RTRIM(ISNULL((SELECT BILGI FROM REHBERAYAR RA INNER JOI' +
        'N REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB' +
        '.YER_ID=R.ID AND RA.VARSAYILAN=20),'#39#39'))),'
      
        'VNO=LTRIM(RTRIM(ISNULL((SELECT BILGI FROM REHBERAYAR RA INNER JO' +
        'IN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE R' +
        'B.YER_ID=R.ID AND RA.VARSAYILAN=22),'#39#39'))),'
      'VDKODU=VL.VDKODU,'
      
        'BABAADI=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI ' +
        'RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID A' +
        'ND RA.VARSAYILAN=52),'
      
        'TCKIMLIKNO=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBIL' +
        'GI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.I' +
        'D AND RA.VARSAYILAN=50),'
      'BANKAKODU=LTRIM(RTRIM(BM.BANKAKODU)),'
      'BANKAADI=LTRIM(RTRIM(BM.BANKAADI)),'
      'SUBEKODU=LTRIM(RTRIM(BSM.SUBEKODU)),'
      'SUBEADI=LTRIM(RTRIM(BSM.SUBEADI)),'
      'BHM.HESAPNO,'
      'IBAN=ISNULL(BHM.IBAN,'#39' '#39'),P.ACIKLAMA,P.CIKAN,'
      'KUR=LTRIM(RTRIM(P.KUR)),'
      'ISOKUR=INI1.DEGER,'
      'P.DURUM,'
      
        'EMAIL=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB' +
        ' ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND' +
        ' RA.VARSAYILAN=46),'
      
        'FAX=(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB O' +
        'N RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND R' +
        'A.VARSAYILAN=41)'
      ''
      'FROM KASA P '
      'INNER JOIN REHBER R on R.ID = P.REHBERID '
      'INNER JOIN BANKAHESAPLAR BHM on BHM.ID = P.MUSTERIHESAPID'
      'INNER JOIN BANKAHESAPLAR BHA on BHA.ID = P.HESAPID'
      'INNER JOIN BANKASUBELER BSM on BHM.BANKASUBELERID = BSM.ID'
      'INNER JOIN BANKASUBELER BSA on BHA.BANKASUBELERID = BSA.ID '
      'INNER JOIN BANKALAR BM on BM.BANKAKODU = BSM.BANKAKODU'
      'INNER JOIN BANKALAR BA on BA.BANKAKODU = BSA.BANKAKODU'
      
        'LEFT OUTER JOIN VDLISTE VL ON (SELECT BILGI FROM REHBERAYAR RA I' +
        'NNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI ' +
        'WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20)=VL.VD'
      
        'LEFT OUTER JOIN (SELECT ANAHTAR,DEGER FROM REHBERINI WHERE BOLUM' +
        ' = '#39'ISOParaBirimleri'#39') INI1 on P.KUR=INI1.ANAHTAR'
      'WHERE'
      'P.TUR = 71 AND'
      'P.HESAPTURU = '#39'B'#39' AND'
      'P.PLANTARIHI = :PTarih AND'
      'P.HESAPID=:PHESAPID')
    Left = 253
    Top = 134
  end
  object frxReport1: TfrxReport
    Version = '4.13.1'
    DataSet = frxTalimat
    DataSetName = 'TALIMAT'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    OldStyleProgress = True
    Preview = frxPreview1
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 39069.938386493100000000
    ReportOptions.LastChange = 39069.938386493100000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 452
    Top = 134
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 485
    Top = 338
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
  object frxTalimat: TfrxDBDataset
    UserName = 'TALIMAT'
    OnFirst = frxTalimatNext
    OnNext = frxTalimatNext
    CloseDataSource = False
    DataSet = TabAlici
    BCDToCurrency = False
    Left = 440
    Top = 243
  end
  object frxPDFExport1: TfrxPDFExport
    ShowDialog = False
    FileName = 'Talimat.pdf'
    UseFileCache = True
    DefaultPath = 'D:\Finans\ENTEGRA\PDFDosya'
    ShowProgress = True
    OverwritePrompt = True
    DataOnly = False
    PrintOptimized = False
    Outline = False
    Background = False
    HTMLTags = True
    Quality = 95
    Author = 'FastReport'
    Subject = 'FastReport PDF export'
    ProtectionFlags = [ePrint, eModify, eCopy, eAnnot]
    HideToolbar = False
    HideMenubar = False
    HideWindowUI = False
    FitWindow = False
    CenterWindow = False
    PrintScaling = False
    Left = 446
    Top = 191
  end
  object IdFTP1: TIdFTP
    OnDisconnected = IdFTP1Disconnected
    OnWork = IdFTP1Work
    OnWorkBegin = IdFTP1WorkBegin
    OnWorkEnd = IdFTP1WorkEnd
    OnConnected = IdFTP1Connected
    IPVersion = Id_IPv4
    Host = 'ftp01.garanti.com.tr'
    Password = 'moisT62comp'
    Username = 'garfetabilg'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    OnBannerBeforeLogin = IdFTP1BannerBeforeLogin
    OnBannerAfterLogin = IdFTP1BannerAfterLogin
    OnAfterClientLogin = IdFTP1AfterClientLogin
    OnAfterPut = IdFTP1AfterPut
    OnDataChannelCreate = IdFTP1DataChannelCreate
    Left = 846
    Top = 311
  end
  object TabBankaAyar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Select * from BANKAFTP where BANKAKODU=:PBANKAKODU')
    Left = 268
    Top = 275
  end
  object imgListYukleme: TPngImageList
    Height = 15
    Width = 15
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D494844520000000F0000000F08060000003BD695
          4A000000097048597300000B1300000B1301009A9C180000008F4944415478DA
          63FCFFFF3F03B9807118696664640451A640EC0BC45B81F82456753834AF0652
          21502E4841071057A1ABC5A5F9179062451202295205AABD8B573350E3042095
          8F661E48D146906B80EAFFE2D3AC01A4AE819848C2200D0940BC0CA8FE1F3ECD
          20AA02885BA0424C40FC0288A5C04E40528F4B33084C07627920DE00C4FB80F8
          0E41CDA48021AA1900DC9856E332EF2CD20000000049454E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D494844520000000F0000000F08060000003BD695
          4A000000097048597300000B1300000B1301009A9C18000003234944415478DA
          25536B685447183D33F7B1DEB81BD36263C4C6685094154BA00D611B83826211
          22C422BE405B69E94B2A164102ED1F0545A83FAA46410896B6B6B4CD03C58A41
          6D511BA88FA4364DDD1A93D426F820CF0DD935F7DE993B33FD763B30BFE6FBBE
          73E69CF331A5140AC718706E95854A7C3A947DF8CEE84CBF17AA1C5C1E47A9B7
          088B8A57DC8839EE6EA5F423C6FE6F614A4560E0609CA5D2E35D57EE8E9D8B3F
          D7FDF49281E6125ADB40F4028AF812D4946E152B4B6BD71B6D6E18987CB32044
          6755E7930BEDDD934D2F31770091CE401801AD0C22952F7361E91228B910B565
          7B26D7556CAF27C6BF314374FF9EB83B74F1F19E85B6F30042131366416A4D43
          14A28843468088249476E1E8C5D8B9FCD458D5BCD5352C90D1E6AFFB76B564D0
          06CD883ED18CB481142E44508488E720101606845221541A958937D058DD7A98
          3D18FFFDDED9C1755509CF07370E2248CC081FC9E237D150DE8CEF06DFC3EDD1
          5652C5A101367C5F21E7731C5EDDF107BBFC6FF3FDF34FDF4D266C8F10493A31
          1BA18850337F1B76264FE3CBDE0F7173F807FA06C3B49F4518324C05027B539F
          2BD6D67F74EAEA48E39C18F7900B03BCB5E42BA4E6EDC87B076EB382688CBCB9
          3CD08CA39D1F90752EB2D4FCF66B0786D94F8FCE4CB50FBD3FC7E3450808B122
          9142C25A806525AF6343E547B8F0B0093D23B730921D42EFB3DB14078E6921B0
          BFEEC8304B8FDDB97FAC674DD2620A5231CC0401269E03EB2B36E340AA0587AE
          6F415BBA0571B2DB468C6A1414D768AAEFE860A10C761CB953FF6DFFD435183D
          ABA06A2E9448BEB80A0D4B3FC68F7F9D40F7934E589C231F464956BEF272354E
          6EF8E538A3B4E0DEE8CDEF8F756FDA1A06D36405A744013E4DC9051A36D90763
          91C7A401518E792E0EAEFD265D57DE50C7A490B01D7BF1A5C1B3BF9EEBFD6CC1
          F4CC24A11B0A05A58BAEA2105986385B0C8959C5D8FD6AE3C096E4276B29D6C3
          4C4A49D966B06C2BD5F5ECE7F6B6F417657DE33D849A85C9479390638E87CAB9
          CBB16DC5BED6DAF28DBB68397C63340ACD850D216B2CDBF142E99F4C4F7455FD
          93F99354CDC4E34E625965C9CABEE4DCEA4B9E9BD81FD1225169E1FC07EFC99C
          CE2F36F79A0000000049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D494844520000000F0000000F08060000003BD695
          4A000000097048597300000B1300000B1301009A9C18000003154944415478DA
          1D936F4C956518C6AFE77DDFF30FCF3AE4A1812629049AE8075A33524A97B362
          66033E596B292BC5566BF667056C6DC58436D85A3AE6CED2B6A6AB05E3D01C1F
          6491B8DA9A10E052DB8E111472943A1317E7E0399C739EBFDDEF79DF0FCF87F7
          FADDF7FD5CF7F532A514DCC76216C0B0773EF947FB4CEA4AC5BDEC6C95D06938
          5610617F25AA433B07AA8BB7BF43D2256D5C8681292508749053B996B1DBE7BF
          9ACF0CDBCC4E50B534B491509A41A920985C878AE0F3A9864DADC7024ED18036
          DA853509D4C1E85C77FFBF6A10CCFA075C65A00C20B505A10D0AC3191F894BB1
          A9A809876A4EBCECB57D03CC18F3F4CFB7BF1B1B4F76786DEAA88C9784545059
          E0044A02B9E2C80B46277593C578716377EA40D5D14A96CA26A7CFFCF9D213DA
          FE95CAFB685440505B4190A4332B09CCF891470EC6BD9ECC216C6D4367FDA50E
          3699F8D17C33BF1F21BF0716BD4A0B02A9033CC8F03C582E8C37B60CE0E67F63
          882E7C861C77B092E1F8744F34CD86FF3A654612C7E177D61024C0B221047409
          6EA99B2896A538FEF8106AD6D76328F639BE9CFE085A13CC39DE7CF213B0E86C
          8FF921D186000B60352FF07A653F1E2B790627C70FA379EB87A8DDB017D1580F
          2253EDE485876086548EE3C88E36B0CBF16F93E7665F0DADB103487381FA752D
          68DD7E968485556230D68BD35324241064A224EBD342E2E36723332C9E9A1DED
          9ADEF59CD4CB10D28395D52C1A2ADEC691DA2F7021D687BEC90F08B4011A5769
          D74809BFCF8FB38DBF4499D6A63972FDADEF7F5A8C80691F840099924755711D
          66EEFE46EE92EDDA2A386F68640E81FD5B5F41E7EEF38798266797561717BA26
          9A1EB993BC5180DD55AD72491D1D18C5282C8A6E610A492C5F5B85DE172EC4CB
          1FD85CCD84E0701C4FEDDCF28DD1C8D5F71E9A599A04A7254B4101D1DACD0B18
          41B66DE1D1D26D78FFA9BEB99A921D8D52CA5801A688D347E7E164FE5ED7C5BF
          BF7E6D6261C4BE7B7F91F2CEE1651E3C182C435DF93E346E6E3D130E94BDAB84
          C81A46940BBBB6BA63792CC7FDBD2A32FC7E7B22136FC9F0945DE4095E2B0B6E
          FC3DE80D45A03159C802735761E17FA23D99ACD30759E20000000049454E44AE
          426082}
        Name = 'PngImage2'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D494844520000000F0000000F08060000003BD695
          4A000000097048597300000B1300000B1301009A9C18000003294944415478DA
          3D936F4C95551CC73FE7792E0FF75E01E90A3497B88C9A0DC22C24F405B50AB6
          B6146BCE1796F305B3B66A4E72D5AD288CA1A69B522EDA4A73510B6B73B199D9
          0B56F4468732B4FF97B540D96E304541EE957BEFF3DCE739E77470D5D9CEBBDF
          F7FBFB7ECFF77B849492FF8EB0AC3A011DBEEB3EE65E9F2E52992C5634825356
          416124F2B38667B55289FFE7FF053B9665EDF2D2A93D57BE3F6DE712E7903726
          D13230840558A5E584EF6D6069D306198E2DE9564AED3698DC02B8D600BF9A9B
          18AF9EEA3D0813E7B13337D0B90C3AF0512244E04451D1182C5F45556B9C9295
          D57B95926F09A5757FEEFAF4D3E37B7710BA7C16757316A1145258482DCCD5E8
          BC245012158961ADA8A7A6EBA37CD11D95150BE0F3633D9D0F79A7DEBBB52964
          F4CCCDE7083B0E840AF0B32EE96C603C3BF8FE02A943C553CF53FB76F746914A
          4E78632F3CEA14CE4F216C9BB45D8AB5E935E67F388EF3EB306E751D45CDDB48
          7DBE8F506616CF97F8D1253CD2F7E3A4489E3AA193ED9B718A8D2FCF85D58F53
          7F7480E9CB97B8B027CE9AF6FD94DF55C5E0D626E68606C95B36F3A98087BB8F
          20C68F1CD4573F7805B128829202CF75296FD94A4DE731941D32FE2523F1ED8C
          9DE845861CCC73E0A6F2D4ED8A23C68EBDAFA70EB56199CD81D2645339FCE5B5
          347F7D86484909B99B69FA9F5C87F767026B5121D2CCB8E93C6B5F7F13313978
          5A8FEE68C10EDBF89EC4BBB39E869E2F295B56796B5BD5E66DCC242719786E0B
          99C430DAA891993C4F1CFD02919D9D9919DED21873FF1EC575352B5EEC60D5CB
          EF30146FE58F8F7B59B9BD95C6439F30746037170F744121C4962E63FD7767CF
          08AD75CB5F9F7D7872F4DD9D98FAA10AA244EFA9E1EAC839E3D9C4E3E6297BB0
          8199D1DF8C32174B09D6C63BAFDCDFD6DE200253411DC8BE8BED2F3D93FCF638
          6E90C733B95A219BC09444494DDED8298816609B28AB9AD6E71A0F7FBA4684A3
          09E1FB3E9699945EAE23D1B36FE7A5FEBEC5F3B3D7F01780468BD61696511429
          2EE6EE0D9B78E0D5AE36BBA8E4B0F24DEFF3066CA463874C2C42AC9EF9E5C2C8
          E4C037F6B5DF7FC24BCD525854CA6DD5F751D9BC91DBEBD7BD61E8F6CB2058F8
          53FC03B61A8718311779BE0000000049454E44AE426082}
        Name = 'PngImage3'
        Background = clWindow
      end>
    Left = 671
    Top = 204
    Bitmap = {}
  end
  object DtsBankaAyar: TDataSource
    DataSet = TabBankaAyar
    Left = 269
    Top = 319
  end
end
