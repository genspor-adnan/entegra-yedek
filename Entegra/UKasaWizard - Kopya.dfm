object KasaWizardDlg: TKasaWizardDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Aksiyon Ekleme Ekran'#305
  ClientHeight = 492
  ClientWidth = 921
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 18
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 921
    Height = 492
    ActivePage = KasaSecimEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &'#214'nceki'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Sonraki >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Biti'#351
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.ModalResult = 1
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
      921
      492)
    object MenuEkr: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'G'#252'nl'#252'k Aksiyonlar'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #304#351'lem Se'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clRed
      Header.Subtitle.Font.Height = -12
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = [fsBold]
      Panel.BorderWidth = 3
      VisibleButtons = [bkNext, bkCancel]
      OnEnterPage = MenuEkrEnterPage
      OnNextButtonClick = MenuEkrNextButtonClick
      object Label3: TLabel
        Left = 617
        Top = 40
        Width = 62
        Height = 18
        Caption = #304#351'lem Tarihi'
      end
      object MenuTree: TcxTreeView
        Left = 164
        Top = 70
        Width = 757
        Height = 380
        Align = alClient
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TextColor = clActiveCaption
        Style.IsFontAssigned = True
        TabOrder = 0
        OnClick = MenuTreeClick
        OnDblClick = MenuTreeDblClick
        AutoExpand = True
        Items.NodeData = {
          0302000000400000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF000000
          000400000001114D00FC005F017400650072006900200030015F016C0065006D
          006C006500720069002A0000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
          FF0000000002000000010650006C0061006E006C0061003A000000000000003D
          000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010E54006100680073
          0069006C0061007400200050006C0061006E0031013400000000000000470000
          00FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010BD600640065006D0065
          00200050006C0061006E0031012C0000000000000000000000FFFFFFFFFFFFFF
          FFFFFFFFFF00000000040000000107420065006C00670065006C006500380000
          00000000000B000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010D46
          0061007400750072006100200047006900720069005F01690032000000000000
          000C000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010A460069005F
          01200047006900720069005F01690038000000000000000F000000FFFFFFFFFF
          FFFFFFFFFFFFFF0000000000000000010D4600610074007500720061002000C7
          0031016B0031015F013101320000000000000010000000FFFFFFFFFFFFFFFFFF
          FFFFFF0000000000000000010A460069005F012000C70031016B0031015F0131
          01300000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF00000000050000
          000109540061006800730069006C002000450074003C00000000000000150000
          00FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010F4E0061006B00690074
          002000540061006800730069006C006100740031014800000000000000190000
          00FFFFFFFFFFFFFFFF00000000000000000000000001154B0072006500640069
          0020004B0061007200740031012000540061006800730069006C006100740031
          01420000000000000016000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000
          000112470065006C0065006E00200048006100760061006C00650020002F0020
          00450046005400320000000000000017000000FFFFFFFFFFFFFFFFFFFFFFFF00
          00000000000000010A41006C0031016E0061006E002000C70065006B00360000
          000000000018000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010C41
          006C0031016E0061006E002000530065006E0065007400300000000000000000
          000000FFFFFFFFFFFFFFFFFFFFFFFF00000000060000000109D600640065006D
          006500200059006100700034000000000000001F000000FFFFFFFFFFFFFFFFFF
          FFFFFF0000000000000000010B4E0061006B00690074002000D600640065006D
          006500440000000000000023000000FFFFFFFFFFFFFFFF000000000000000000
          00000001134B00720065006400690020004B0061007200740031012000D60064
          0065006D006500730069004C0000000000000020000000FFFFFFFFFFFFFFFFFF
          FFFFFF000000000000000001174700F6006E0064006500720069006C0065006E
          00200048006100760061006C00650020002F0020004500460054003400000000
          00000021000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010B560065
          00720069006C0065006E002000C70065006B00380000000000000022000000FF
          FFFFFFFFFFFFFFFFFFFFFF0000000000000000010D56006500720069006C0065
          006E002000530065006E006500740034000000000000006F000000FFFFFFFFFF
          FFFFFFFFFFFFFF0000000000000000010B4B0072006500640069002000D60064
          0065006D0065003E00000000000000F4010000FFFFFFFFFFFFFFFFFFFFFFFF00
          0000000400000001105600610072006C0031016B00200030015F016C0065006D
          006C00650072006900340000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
          FF0000000003000000010B5400720061006E0073006600650072006C00650072
          00420000000000000029000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000
          000112420061006E006B00610079006100200050006100720061002000590061
          0074003101720040000000000000002A000000FFFFFFFFFFFFFFFFFFFFFFFF00
          000000000000000111420061006E006B006100640061006E0020005000610072
          0061002000C70065006B0060000000000000002B000000FFFFFFFFFFFFFFFFFF
          FFFFFF00000000000000000121420061006E006B006100200048006500730061
          0070006C0061007200310120004100720061007300310120005400720061006E
          0073006600650072006C00650072004A0000000000000000000000FFFFFFFFFF
          FFFFFFFFFFFFFF00000000040000000116C70065006B00200076006500200053
          0065006E0065007400200030015F016C0065006D006C00650072006900380000
          000000000033000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010DC7
          0065006B002000540061006800730069006C006100740031013C000000000000
          0034000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010F530065006E
          00650074002000540061006800730069006C0061007400310134000000000000
          0035000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010BC70065006B
          002000D600640065006D00650073006900380000000000000036000000FFFFFF
          FFFFFFFFFFFFFFFFFF0000000000000000010D530065006E00650074002000D6
          00640065006D006500730069003C0000000000000000000000FFFFFFFFFFFFFF
          FFFFFFFFFF0000000004000000010F4400F600760069007A00200030015F016C
          0065006D006C006500720069003E000000000000002D000000FFFFFFFFFFFFFF
          FFFFFFFFFF000000000000000001104B00610073006100640061006E00200044
          00F600760069007A00200041006C0040000000000000002E000000FFFFFFFFFF
          FFFFFFFFFFFFFF000000000000000001114B00610073006100640061006E0020
          004400F600760069007A00200053006100740040000000000000002F000000FF
          FFFFFFFFFFFFFFFFFFFFFF00000000000000000111420061006E006B00610064
          0061006E0020004400F600760069007A00200041006C00420000000000000030
          000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000112420061006E006B
          006100640061006E0020004400F600760069007A0020005300610074003A0000
          000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000002000000010E44
          0069001F0165007200200030015F016C0065006D006C00650072004400000000
          00000079000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000113420061
          006E006B006F00640061006E00200050006F007300200047006900720069005F
          01690048000000000000007A000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000
          0000000115420061006E006B006F00640061006E0020004E0061006B00690074
          00200047006900720069005F016900}
        ReadOnly = True
      end
      object KasaTarihi: TcxDateEdit
        Left = 677
        Top = 36
        Properties.SaveTime = False
        Properties.ShowTime = False
        TabOrder = 1
        Width = 121
      end
    end
    object AramaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Arama Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        #304#351'lem yapmak istedi'#287'iniz m'#252#351'teriyi se'#231'in ve sonraki d'#252#287'mesine ba' +
        's'#305'n'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'AramaEkr'
      OnEnterPage = AramaEkrEnterPage
      OnPage = AramaEkrPage
      OnNextButtonClick = AramaEkrNextButtonClick
      object Panel1: TPanel
        Left = 0
        Top = 70
        Width = 921
        Height = 50
        Align = alTop
        Color = 16757683
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object LabelPNO: TLabel
          Left = 172
          Top = 5
          Width = 35
          Height = 16
          Caption = #220'nvan'
          FocusControl = AraFirma
          Font.Charset = TURKISH_CHARSET
          Font.Color = clNavy
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label2: TLabel
          Left = 308
          Top = 4
          Width = 23
          Height = 16
          Caption = #304'lgili'
          FocusControl = AraYetkili
          Font.Charset = TURKISH_CHARSET
          Font.Color = clNavy
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 94
          Top = 4
          Width = 21
          Height = 16
          Caption = '&Kod'
          FocusControl = AraKod
          Font.Charset = TURKISH_CHARSET
          Font.Color = clNavy
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label12: TLabel
          Left = 9
          Top = 4
          Width = 27
          Height = 16
          Caption = '&Grup'
          FocusControl = AraKod
          Font.Charset = TURKISH_CHARSET
          Font.Color = clNavy
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object rbIcindeGecen: TRadioButton
          Left = 447
          Top = 31
          Width = 81
          Height = 17
          Caption = #304#231'inde Ge'#231'en'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object rbBaslayan: TRadioButton
          Left = 447
          Top = 17
          Width = 65
          Height = 17
          Caption = 'Ba'#351'layan'
          Checked = True
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
          TabStop = True
        end
        object AraFirma: TcxTextEdit
          Left = 172
          Top = 22
          TabOrder = 3
          OnKeyUp = AraFirmaKeyUp
          Width = 130
        end
        object AraYetkili: TcxTextEdit
          Left = 308
          Top = 22
          TabOrder = 4
          OnKeyUp = AraFirmaKeyUp
          Width = 130
        end
        object AraKod: TcxTextEdit
          Left = 94
          Top = 22
          TabOrder = 2
          OnKeyUp = AraFirmaKeyUp
          Width = 72
        end
        object AletCubugu: TToolBar
          Left = 895
          Top = 1
          Width = 25
          Height = 48
          Align = alRight
          AutoSize = True
          ButtonWidth = 25
          Caption = 'AletCubugu'
          DockSite = True
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
          ShowCaptions = True
          TabOrder = 5
          object AraTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Ara'
            ImageIndex = 9
            Visible = False
            OnClick = AraTusClick
          end
        end
        object ComboGrup: TcxComboBox
          Left = 5
          Top = 22
          Properties.DropDownListStyle = lsFixedList
          Properties.MaxLength = 0
          Properties.OnChange = AraTusClick
          TabOrder = 1
          Width = 87
        end
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 990
          Top = 427
          Width = 60
          Height = 33
          Margins.Bottom = 0
          Align = alCustom
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 59
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
          Images = AnaForm.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 7
          Transparent = True
          ExplicitLeft = 984
          ExplicitTop = 421
          object YeniTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 7
            OnClick = YeniTusClick
          end
        end
      end
      object GridCariArama: TcxGrid
        Left = 0
        Top = 120
        Width = 921
        Height = 330
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridCariAramaDBTableView1: TcxGridDBTableView
          OnDblClick = GridCariAramaDBTableView1DblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = dsAra
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.CancelOnExit = False
          OptionsData.Editing = False
          OptionsSelection.CellSelect = False
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridCariAramaDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object GridCariAramaDBTableView1GRUP: TcxGridDBColumn
            Caption = 'Grup'
            DataBinding.FieldName = 'GRUP'
            Width = 76
          end
          object GridCariAramaDBTableView1KOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            Width = 81
          end
          object GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'FIRMA'
            Width = 135
          end
          object GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn
            Caption = #304'lgili'
            DataBinding.FieldName = 'ADSOYAD'
            Width = 188
          end
        end
        object GridCariAramaLevel1: TcxGridLevel
          GridView = GridCariAramaDBTableView1
        end
      end
    end
    object FaturaPlanSecEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Planlanm'#305#351' '#246'deme veya Faturas'#305'n'#305' se'#231'in'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Tahsilat ya da '#246'deme yaparken '#246'nceden girilmi'#351' plan ya da fatura' +
        'yla e'#351'le'#351'tirme yapar'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'FaturaPlanSecEkr'
      OnEnterPage = FaturaPlanSecEkrEnterPage
      OnPage = FaturaPlanSecEkrPage
      object GridTakvimPlan: TcxGrid
        Left = 0
        Top = 277
        Width = 921
        Height = 173
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object TakvimPlanView: TcxGridDBTableView
          OnDblClick = TakvimPlanViewDblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DtsTakvimPlan
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object TakvimPlanViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object TakvimPlanViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Giren Fatura'
                ImageIndex = 0
                Value = 11
              end
              item
                Description = #199#305'kan Fatura'
                Value = 15
              end
              item
                Description = 'Tahsilat Plan'#305
                ImageIndex = 0
                Value = 61
              end
              item
                Description = #214'deme Plan'#305
                Value = 71
              end>
            Width = 91
          end
          object TakvimPlanViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Tahmin'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = 'Fatural'#305
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 2
              end>
          end
          object TakvimPlanViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
          end
          object TakvimPlanViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 132
          end
          object TakvimPlanViewHESAPADI: TcxGridDBColumn
            Caption = #214'deme Yeri'
            DataBinding.FieldName = 'HESAPADI'
            Width = 150
          end
          object TakvimPlanViewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            Width = 69
          end
          object TakvimPlanViewKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 34
          end
        end
        object cxGridLevel5: TcxGridLevel
          GridView = TakvimPlanView
        end
      end
      object CheckDisinda: TcxCheckBox
        Left = 147
        Top = 43
        Caption = 'A'#351'a'#287#305'dakilerin d'#305#351#305'nda'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        TabOrder = 1
        Transparent = True
        Width = 184
      end
      object Panel4: TPanel
        Left = 0
        Top = 236
        Width = 921
        Height = 41
        Align = alTop
        Alignment = taLeftJustify
        Caption = 'Daha '#246'nce yap'#305'lm'#305#351' '#246'deme planlar'#305
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 2
      end
      object GridTakvimFat: TcxGrid
        Left = 0
        Top = 111
        Width = 921
        Height = 125
        Align = alTop
        TabOrder = 3
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object TakvimFatView: TcxGridDBTableView
          OnDblClick = TakvimPlanViewDblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DtsTakvimFat
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Giren Fatura'
                ImageIndex = 0
                Value = 11
              end
              item
                Description = #199#305'kan Fatura'
                Value = 15
              end
              item
                Description = 'Tahsilat Plan'#305
                ImageIndex = 0
                Value = 61
              end
              item
                Description = #214'deme Plan'#305
                Value = 71
              end>
            Width = 69
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Tahmin'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = 'Fatural'#305
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 2
              end>
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
          end
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 132
          end
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            Width = 69
          end
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 34
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = TakvimFatView
        end
      end
      object Panel5: TPanel
        Left = 0
        Top = 70
        Width = 921
        Height = 41
        Align = alTop
        Alignment = taLeftJustify
        Caption = '  Daha '#246'nce kesilmi'#351' faturalar'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 4
      end
    end
    object FaturaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Fatura'
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
      OnEnterPage = FaturaEkrEnterPage
      OnNextButtonClick = FaturaEkrNextButtonClick
      object lbl21: TLabel
        Left = 26
        Top = 349
        Width = 47
        Height = 18
        Caption = 'A'#231#305'klama'
      end
      object lbl22: TLabel
        Left = 470
        Top = 91
        Width = 70
        Height = 18
        Caption = 'Fatura Tarihi'
      end
      object lbl23: TLabel
        Left = 486
        Top = 125
        Width = 54
        Height = 18
        Caption = 'Fatura No'
      end
      object lbl25: TLabel
        Left = 521
        Top = 405
        Width = 39
        Height = 18
        Caption = 'Toplam'
      end
      object Label28: TLabel
        Left = 529
        Top = 348
        Width = 30
        Height = 18
        Caption = 'Tutar'
      end
      object Label29: TLabel
        Left = 536
        Top = 377
        Width = 21
        Height = 18
        Caption = 'KDV'
      end
      object LabelIslemTarih2: TLabel
        Left = 611
        Top = 39
        Width = 62
        Height = 18
        Caption = #304#351'lem Tarihi'
        Transparent = True
      end
      object Label1: TLabel
        Left = 33
        Top = 91
        Width = 33
        Height = 18
        Caption = 'Ba'#351'l'#305'k'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label7: TLabel
        Left = 35
        Top = 115
        Width = 32
        Height = 18
        Caption = 'Adres'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label36: TLabel
        Left = 52
        Top = 194
        Width = 16
        Height = 18
        Caption = 'VD'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label37: TLabel
        Left = 178
        Top = 195
        Width = 21
        Height = 13
        Caption = 'VNo'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label38: TLabel
        Left = 517
        Top = 157
        Width = 23
        Height = 18
        Caption = 'KDV'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object TextBelgeAdi: TDBText
        Left = 359
        Top = 153
        Width = 97
        Height = 24
        Alignment = taCenter
        DataField = 'BELGE'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -19
        Font.Name = 'Arial Black'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
      end
      object Label39: TLabel
        Left = 47
        Top = 168
        Width = 20
        Height = 18
        Caption = #304'l'#231'e'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label40: TLabel
        Left = 187
        Top = 169
        Width = 8
        Height = 13
        Caption = #304'l'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label41: TLabel
        Left = 672
        Top = 94
        Width = 26
        Height = 18
        Caption = 'Saati'
      end
      object ComboBoxFatAciklama: TcxDBComboBox
        Left = 74
        Top = 348
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsFatBaslik
        Properties.MaxLength = 0
        TabOrder = 2
        Width = 241
      end
      object EditFaturaTarih: TcxDBDateEdit
        Left = 545
        Top = 89
        DataBinding.DataField = 'FATURATARIH'
        DataBinding.DataSource = DtsFatBaslik
        TabOrder = 0
        Width = 121
      end
      object EditFaturaNo: TcxDBTextEdit
        Left = 545
        Top = 123
        DataBinding.DataField = 'FATURANO'
        DataBinding.DataSource = DtsFatBaslik
        TabOrder = 1
        Width = 121
      end
      object ComboKurFat: TcxDBComboBox
        Left = 684
        Top = 348
        DataBinding.DataField = 'KUR'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DropDownListStyle = lsFixedList
        Properties.MaxLength = 0
        TabOrder = 4
        Width = 58
      end
      object ComboBoxKDVOran: TcxComboBox
        Left = 561
        Top = 374
        Properties.Items.Strings = (
          '18'
          '8'
          '0')
        Properties.MaxLength = 0
        Properties.OnChange = EditKDVSIZPropertiesChange
        TabOrder = 5
        Width = 49
      end
      object EditKDVSIZ: TcxDBCurrencyEdit
        Left = 562
        Top = 348
        DataBinding.DataField = 'FATURA_MATRAHI'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        Properties.OnChange = EditKDVSIZPropertiesChange
        TabOrder = 3
        OnExit = EditKDVSIZExit
        Width = 121
      end
      object EditFaturaKDV: TcxDBCurrencyEdit
        Left = 608
        Top = 374
        DataBinding.DataField = 'KDV_TUTARI'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        Properties.OnChange = EditFaturaKDVPropertiesChange
        TabOrder = 6
        Width = 74
      end
      object EditFaturaTutar: TcxDBCurrencyEdit
        Left = 561
        Top = 402
        DataBinding.DataField = 'FATURA_TUTARI'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        Properties.OnChange = EditFaturaTutarPropertiesChange
        TabOrder = 7
        OnExit = EditKDVSIZExit
        Width = 121
      end
      object DateIslemTarih2: TcxDateEdit
        Left = 677
        Top = 36
        Properties.OnEditValueChanged = DateIslemTarih2PropertiesEditValueChanged
        TabOrder = 8
        Width = 121
      end
      object FatBaslik: TcxDBTextEdit
        Left = 72
        Top = 89
        DataBinding.DataField = 'BASLIK'
        DataBinding.DataSource = DtsFatBaslik
        Properties.OnEditValueChanged = FatBaslikPropertiesEditValueChanged
        Style.Color = clBtnFace
        TabOrder = 9
        Width = 241
      end
      object FatAdres: TcxDBMemo
        Left = 72
        Top = 115
        DataBinding.DataField = 'ADRES'
        DataBinding.DataSource = DtsFatBaslik
        Properties.OnEditValueChanged = FatBaslikPropertiesEditValueChanged
        Style.Color = clBtnFace
        TabOrder = 10
        Height = 48
        Width = 241
      end
      object FatVD: TcxDBTextEdit
        Left = 70
        Top = 191
        DataBinding.DataField = 'VD'
        DataBinding.DataSource = DtsFatBaslik
        Style.Color = clBtnFace
        TabOrder = 13
        Width = 100
      end
      object FatVNo: TcxDBTextEdit
        Left = 200
        Top = 191
        DataBinding.DataField = 'VNO'
        DataBinding.DataSource = DtsFatBaslik
        Style.Color = clBtnFace
        TabOrder = 14
        Width = 113
      end
      object ComboKDV: TcxDBComboBox
        Left = 546
        Top = 155
        DataBinding.DataField = 'KDVDURUM'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'Hari'#231
          'Dahil'
          'Muaf')
        Properties.MaxLength = 0
        TabOrder = 16
        Width = 115
      end
      object cxImage1: TcxImage
        Left = 368
        Top = 91
        AutoSize = True
        ParentColor = True
        Picture.Data = {
          0A544A504547496D6167658A080000FFD8FFE000104A46494600010101006000
          600000FFDB004300080606070605080707070909080A0C140D0C0B0B0C191213
          0F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F2739
          3D38323C2E333432FFDB0043010909090C0B0C180D0D1832211C213232323232
          3232323232323232323232323232323232323232323232323232323232323232
          32323232323232323232323232FFC0001108003D003E03012200021101031101
          FFC4001F0000010501010101010100000000000000000102030405060708090A
          0BFFC400B5100002010303020403050504040000017D01020300041105122131
          410613516107227114328191A1082342B1C11552D1F02433627282090A161718
          191A25262728292A3435363738393A434445464748494A535455565758595A63
          6465666768696A737475767778797A838485868788898A92939495969798999A
          A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
          D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
          01010101010101010000000000000102030405060708090A0BFFC400B5110002
          0102040403040705040400010277000102031104052131061241510761711322
          328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
          292A35363738393A434445464748494A535455565758595A636465666768696A
          737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
          A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
          E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00F7FA
          A1AA6B169A4428F70CED24ADB218225DF24CDFDD551D4FE83BE29DAB6A70E91A
          6CB7932B3ECC048D3EF48E4E1517DC9200FAD61C7697BA6595E6B32C116A1E24
          92132083CCC0541CF9319E70A3D71F33727D80272BE20D450CB757716896A7A4
          7105967C1FEF3B7C8A7D803F5A65C787F4AB7307F686A3AA4CF3CA218CC97F30
          DCE4120008401C03DAA8EA3A8DBF8D3C2660B1B7324D24D6FE75ACEA731A9753
          9700F2B804E41E71C1A82EDAEF4DB5D36D752D674992EB4DBB12C6F7775E49B8
          8FCB651B872430DDEF9C67BD006ACBA1C16B7905BD96B1AB5ACF2AB3A0176665
          017192565DDC72071EB4F6D435AD13E6D5204D42C475BBB28C89231EAF17391E
          E84FFBB55772DF4FA96B6F241710A69A2DE24B2944E7272D20181C927601EBB6
          9FA6DD5EF87F4182E3C457712ED822863B4B78CB36F031807EF49237A018FE74
          01D1DADD417B6B1DCDACC93412AEE4911B2AC3D8D4D5C8B4F068DB3C43A5B674
          5BB21AFA05181112706751FC241E1C7D4F5073D68218020820F208A00C0BA51A
          A78CADAD9BE6B7D2E1FB53AF6333E563CFD14487F114BE22F0ADA6BCD0DD0C41
          A9DB022DEE80C903A956C60953F50475041A5D13E7F10F89243F785D451FE021
          423F563F9D6E3385EE338E0773401C7D8D849712CBA269B3CB6BA7DA3117D751
          C8CD2492B1DE618DD892AA37649EA370030726BA1B1D0749D363D969A7DBC59E
          AC23059BDCB1E49F726B0F41D39B51F03D832DFDE5A4B3837724B6AE15D9DC96
          6049078CB7E82A1F04C9749E0C835FBFD4EFEFE69AD3CE92399D4A82327E5014
          63A7BD006D5F78634DBA93ED16F17D82F97EE5DDA011C80FBE3861ECC08AE7C6
          9B36B9ADF93AA08CEA1631F933618A808C4B47756FD763E57047B119E065DA55
          A7882FB49B0F110F1132DCDD08EE5ED2555FB2085F07CB000DC0853F7F39C8F4
          E2B5357916CBC59A3DD8E3CC82E6197DD028907E457FF1EA00DA8EC6DE3B6960
          F291926C998151FBC246189038C9EF595E1477874F9F4A95D9A4D3276B50CC79
          31801A33FF007C328FC0D55B2F1A4775716F0CBA45F5BF9E610AEC62651E6825
          33B5C9E429EDC55AD346CF196BCA3A3436B211EE448BFC94500450428BE2DD66
          C275CC5A85B4570A338DD806271C73C009F9D6409F48D1353FB4691E1E89A0B7
          490DCDF7475546D9204C8CB107AF238E99ADCF12D9CE63B7D56CE269AEAC1998
          C2BD668586248C7B91C8FF00694567FF006768A9A10D4D6FAFEE74A6459DA08E
          42C939E3AA819258E32B9C13D475A00B5E1D9069D7173E1C9CEC6859E6B327FE
          5ADBB36463DD092A47B03DEADE99E1E5D274FD2EC2DAFAE3ECB608C86360A44E
          08206FE3B673C62B17576B8FEC5B7BDD7EC9CB3DC0643672059EC0B90B1843FC
          6DCFCD83CE48C1156D26D76D9E7820D6348BF16ECA929BA5314B19600A872848
          C9047F08CE680224F02C6AB158BEAB76FA1C3389E2D30AA6C0436E542F8DC503
          72149EC07414D9EFE1BED5EEF56F3ED92C74FB796D6D65B96C4734EDCC87DD40
          50BC7FB5E94EBB8EEEF1235D6F5B856D65B816A6D74C4650F21FE079325B1EA0
          6DF7AA17F79716DAAE9F61378715B4C4B7733596C8E64445655124407248DFCA
          9038E9C8E402EF852C7C3D7F143A8DAE96B69A8418F3619198BC2DB703A9E46D
          2769E983C63915A1A09FB56B3AF6A03FD5BDCADB467D444A013FF7D971F8545A
          84761E1AB664D0F4EB58754D458436F1C5105F31F070CD8FE1404B1F6FAD6BE9
          1A6C7A46936D611333885305DBABB75663EE4927F1A00BB5CE4FA7DEE857935F
          68D17DA2D277325CE9DB8292C7AC9113C063DD4F07AF07AF47515B4DF688165D
          BB739E339EF8A00C482EB4BF125FDA4D1DD932583B48D6322EC7493180CE87E6
          05416C76E73E959379E18D44EA6F7D6C23CDDEA48D7885BEF5BAB232B7FBCA53
          A7A31AE9F51D134CD5B69BEB28A664FB9211874FF758723F03543FE117443FE8
          FACEB302F645BC2E07FDF618D0054D5BC20B79E26B0D62D1A188A5C24B76AE0F
          CFB01DAC9E8DD01F518F41562FB5BB08F55DBA740753D65233108ADDB2235241
          3E637DD8C640EBCF1C034E3E12B29862FAF352BE5EE97178FB0FD554807F115B
          169656B616EB6F676D15BC2BD238902A8FC050066E93A3CD05D49A9EA732DCEA
          9326C2E8311C299CF97183D173D49E58F27B01B3451401FFD9}
        TabOrder = 17
      end
      object SatirEkleTus: TcxButton
        Left = 8
        Top = 251
        Width = 60
        Height = 25
        Caption = 'Yeni Sat'#305'r'
        TabOrder = 18
        OnClick = SatirEkleTusClick
      end
      object SatirSilTus: TcxButton
        Left = 9
        Top = 278
        Width = 60
        Height = 25
        Caption = 'Sat'#305'r Sil'
        TabOrder = 19
        OnClick = SatirSilTusClick
      end
      object CheckFatDetay: TcxCheckBox
        Left = 541
        Top = 208
        Caption = 'Detay Bilgi Gir'
        ParentFont = False
        Properties.OnChange = CheckFatDetayPropertiesChange
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        TabOrder = 20
        Transparent = True
        Width = 120
      end
      object CheckFatBilgiGuncelle: TcxCheckBox
        Left = 72
        Top = 215
        Caption = 'Fatura Bilgilerini G'#252'ncelle'
        ParentFont = False
        Properties.OnChange = CheckFatDetayPropertiesChange
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        TabOrder = 15
        Transparent = True
        Width = 182
      end
      object FatIlce: TcxDBTextEdit
        Left = 70
        Top = 165
        DataBinding.DataField = 'ILCE'
        DataBinding.DataSource = DtsFatBaslik
        Properties.OnEditValueChanged = FatBaslikPropertiesEditValueChanged
        Style.Color = clBtnFace
        TabOrder = 11
        Width = 100
      end
      object FatIl: TcxDBTextEdit
        Left = 200
        Top = 165
        DataBinding.DataField = 'IL'
        DataBinding.DataSource = DtsFatBaslik
        Style.Color = clBtnFace
        TabOrder = 12
        Width = 113
      end
      object LabelFirma: TcxLabel
        Left = 71
        Top = 69
        Caption = 'LabelFirma'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
      end
      object GridFat: TcxGrid
        Left = 74
        Top = 233
        Width = 610
        Height = 113
        Align = alCustom
        TabOrder = 22
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.SkinName = 'MoneyTwins'
        object GridFatDBTableView1: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DtsFatura
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          Styles.Indicator = AnaForm.cxStyle1
          object GridFatDBTableView1KOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Width = 53
          end
          object GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 206
          end
          object GridFatDBTableView1ADET1: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            Width = 35
          end
          object GridFatDBTableView1BIRIM1: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            PropertiesClassName = 'TcxComboBoxProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.DropDownRows = 7
            Properties.Items.Strings = (
              'Adet'
              'Kutu'
              'Koli')
            Properties.ReadOnly = False
            Width = 42
          end
          object GridFatDBTableView1BIRIMFIYAT1: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Width = 84
          end
          object GridFatDBTableView1ISKONTO1: TcxGridDBColumn
            Caption = #304'sk%'
            DataBinding.FieldName = 'ISKONTO'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            Width = 41
          end
          object GridFatDBTableView1KDV1: TcxGridDBColumn
            DataBinding.FieldName = 'KDV'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            Width = 34
          end
          object GridFatDBTableView1TUTAR1: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = True
            HeaderAlignmentHorz = taCenter
            Width = 77
          end
        end
        object GridFatLevel1: TcxGridLevel
          GridView = GridFatDBTableView1
        end
      end
      object OnizleTus: TcxButton
        Left = 19
        Top = 320
        Width = 50
        Height = 25
        Caption = #214'nizleme'
        TabOrder = 23
        OnClick = OnizleTusClick
      end
      object SQLFatbasOpen: TcxMemo
        Left = -7
        Top = 385
        Lines.Strings = (
          
            'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'#FA' +
            'TBASLIK_:SPID_%'#39')'
          'DROP TABLE #FATBASLIK_:SPID_'
          ''
          'CREATE TABLE #FATBASLIK_:SPID_('
          #9'[TARIH] [smalldatetime] NULL,'
          #9'[TUR] [smallint] NULL,'
          #9'[REHBERID] [int] NOT NULL,'
          #9'[BELGE] [nvarchar](6) NULL,'
          #9'[KIME] [nvarchar](30) NULL,'
          #9'[FATURATARIH] [datetime] NULL,'
          #9'[FATURASAAT] [datetime] NULL,'
          #9'[KOCANNO] [smallint] NULL,'
          #9'[FATURANO] [nvarchar](10) NULL,'
          #9'[BASLIK] [nvarchar](100) NULL,'
          #9'[ADRES] [nvarchar](70) NULL,'
          #9'[ILCE] [nvarchar](20) NULL,'
          #9'[IL] [nvarchar](20) NULL,'
          #9'[VD] [nvarchar](20) NULL,'
          #9'[VNO] [nvarchar](15) NULL,'
          #9'[KDVDURUM] [nvarchar](5) NULL,'
          #9'[LOTNO] [nvarchar](8) NULL,'
          #9'[KATKIYUZDE] [float] NULL,'
          #9'[FATURA_GON_TARIHI] [datetime] NULL,'
          #9'[FATURA_MATRAHI] [money] NULL,'
          #9'[KDV_TUTARI] [money] NULL,'
          #9'[FATURA_TUTARI] [money] NULL,'
          #9'[KUR] [nvarchar](5) NULL,'
          #9'[DOVIZ_TUTARI] [money] NULL,'
          #9'[DOVIZ_KURU] [nvarchar](5) NULL,'
          #9'[KASA] [smallint] NULL,'
          #9'[KULLANICI] [nvarchar](2) NULL,'
          #9'[ONAY] [nvarchar](1) NULL,'
          #9'[SAYFA] [smallint] NULL,'
          #9'[TURU] [nvarchar](6) NULL,'
          #9'[MASRAFID] [smallint] NULL,'
          #9'[ACIKLAMA] [nvarchar](100) NULL,'
          #9'[AMBARNO] [smallint] NULL,'
          #9'[SATICIKODU] [nvarchar](10) NULL,'
          #9'[DURUM] [smallint] NULL'
          ')'
          ''
          
            'select *,YAZIYLATOPLAM=(SELECt dbo.fn_MoneyToText(FATURA_TUTARI)' +
            ') from #FATBASLIK_:SPID_')
        TabOrder = 24
        Visible = False
        Height = 29
        Width = 605
      end
      object EditFaturaSaat: TcxDBTimeEdit
        Left = 702
        Top = 90
        DataBinding.DataField = 'FATURASAAT'
        DataBinding.DataSource = DtsFatBaslik
        TabOrder = 25
        Width = 63
      end
      object SQLFaturaOpen: TcxMemo
        Left = 70
        Top = 407
        Lines.Strings = (
          
            'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'#FA' +
            'TURA_:SPID_%'#39')'
          'DROP TABLE #FATURA_:SPID_'
          ''
          'CREATE TABLE #FATURA_:SPID_('
          #9'[SEC] [nvarchar](1) NULL,'
          #9'[TUR] [nvarchar](5) NULL,'
          #9'[KOD] [nvarchar](15) NULL,'
          #9'[ACIKLAMA] [nvarchar](100) NULL,'
          #9'[ADET] [float] NULL,'
          #9'[BIRIM] [nvarchar](8) NULL,'
          #9'[MIKTAR] [float] NULL,'
          #9'[BIRIMFIYAT] [money] NULL,'
          #9'[TUTAR] [money] NULL,'
          #9'[ISKONTO] [float] NULL,'
          #9'[KDV] [smallint] NULL,'
          #9'[OZELKOD] [nvarchar](10) NULL,'
          #9'[MUHKODU] [nvarchar](10) NULL,'
          #9'[KASA] [smallint] NULL,'
          #9'[ONAY] [nvarchar](1) NULL,'
          #9'[KULLANICI] [nvarchar](2) NULL'
          ')'
          ''
          'SELECT * FROM #FATURA_:SPID_')
        TabOrder = 26
        Visible = False
        Height = 29
        Width = 605
      end
    end
    object SorEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Tahsilat veya '#214'deme'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Alacak veya Borcun '#246'denmesiyle ilgili bilgi giri'#351'i'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkCancel]
      object Label21: TLabel
        Left = 302
        Top = 211
        Width = 118
        Height = 18
        Caption = #214'deme tarihini planla'
      end
      object Label22: TLabel
        Left = 295
        Top = 115
        Width = 151
        Height = 18
        Caption = 'Ne zaman '#246'deme yap'#305'lacak?'
      end
      object Label27: TLabel
        Left = 303
        Top = 285
        Width = 133
        Height = 18
        Caption = 'Hemen '#351'imdi '#246'deme yap'
      end
      object OdemeBelirsizTus: TBitBtn
        Tag = 21
        Left = 250
        Top = 142
        Width = 250
        Height = 23
        Caption = #214'deme zaman'#305' belirsiz'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 0
        OnClick = OdemeBelirsizTusClick
      end
      object OdemeTaksitliTus: TBitBtn
        Tag = 23
        Left = 250
        Top = 230
        Width = 250
        Height = 23
        Caption = 'Tek veya Taksitli '#246'deme tarihlerini belirle'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 1
        OnClick = OdemeTaksitliTusClick
      end
      object OdemeNakitTus: TBitBtn
        Tag = 21
        Left = 250
        Top = 304
        Width = 250
        Height = 23
        Caption = 'Nakit '#214'deme'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 2
        OnClick = OdemeNakitTusClick
      end
      object OdemeHavaleTus: TBitBtn
        Tag = 22
        Left = 250
        Top = 355
        Width = 250
        Height = 23
        Caption = 'Giden Havale/EFT'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 3
        OnClick = OdemeHavaleTusClick
      end
      object OdemeCekTus: TBitBtn
        Tag = 23
        Left = 250
        Top = 382
        Width = 250
        Height = 23
        Caption = 'Verilen '#199'ek'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 4
        OnClick = OdemeCekTusClick
      end
      object OdemeSenetTus: TBitBtn
        Tag = 24
        Left = 250
        Top = 409
        Width = 250
        Height = 23
        Caption = 'Verilen Senet'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 5
        OnClick = OdemeCekTusClick
      end
      object KKTus: TBitBtn
        Tag = 21
        Left = 250
        Top = 329
        Width = 250
        Height = 23
        Caption = 'Kredi Kart'#305' ile '#214'deme'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 6
        OnClick = KKTusClick
      end
    end
    object KasaSecimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Kasa Se'#231'im Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #304#351'lem yapmak istedi'#287'iniz kasay'#305' se'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      OnEnterPage = KasaSecimEkrEnterPage
      OnExitPage = KasaSecimEkrExitPage
      object KasaGrid: TcxGrid
        Left = 0
        Top = 70
        Width = 921
        Height = 380
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object KasaGridTableView: TcxGridDBTableView
          OnDblClick = KasaGridTableViewDblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = dsKasaQuery
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
        end
        object cxGridLevel3: TcxGridLevel
          GridView = KasaGridTableView
        end
      end
    end
    object PlanlamaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Planlama Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Hangi tarihte '#246'deme yap'#305'laca'#287#305' bilgisi girilir'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      OnEnterPage = PlanlamaEkrEnterPage
      OnNextButtonClick = PlanlamaEkrNextButtonClick
      object PanelTaksit: TPanel
        Left = 0
        Top = 70
        Width = 921
        Height = 380
        Align = alClient
        TabOrder = 0
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 919
          Height = 166
          Align = alTop
          TabOrder = 0
          object Bevel3: TBevel
            Left = 360
            Top = 21
            Width = 376
            Height = 102
          end
          object Yenilebtn: TSpeedButton
            Left = 792
            Top = 36
            Width = 79
            Height = 35
            Caption = #214'deme Takvimini Yenile'
            Flat = True
            Visible = False
            OnClick = YenilebtnClick
          end
          object Label14: TLabel
            Left = 400
            Top = 28
            Width = 65
            Height = 18
            Caption = #214'deme Yeri'
          end
          object LabelBanka: TLabel
            Left = 435
            Top = 55
            Width = 32
            Height = 18
            Caption = 'Banka'
          end
          object Label5: TLabel
            Left = 14
            Top = 135
            Width = 47
            Height = 18
            Caption = 'A'#231#305'klama'
          end
          object LabelUyariGun: TLabel
            Left = 445
            Top = 137
            Width = 73
            Height = 18
            Caption = 'g'#252'n '#246'nceden'
          end
          object Label32: TLabel
            Left = 56
            Top = 13
            Width = 39
            Height = 18
            Caption = 'Toplam'
          end
          object LabelPesin: TLabel
            Left = 66
            Top = 42
            Width = 29
            Height = 18
            Caption = 'Pe'#351'in'
            Visible = False
          end
          object LabelPlanlananTarih: TLabel
            Left = 12
            Top = 43
            Width = 84
            Height = 18
            Caption = 'Planlanan Tarih'
          end
          object EditPlanBankaHesapAdi: TcxButtonEdit
            Left = 470
            Top = 51
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.OnButtonClick = EditPlanBankaHesapAdiPropertiesButtonClick
            TabOrder = 1
            Width = 158
          end
          object ComboBoxOdemeYeri: TcxImageComboBox
            Left = 470
            Top = 25
            Properties.Items = <
              item
                Description = 'Kasa'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Banka'
                Value = 2
              end>
            TabOrder = 0
            Width = 158
          end
          object EditPlanBankaHesapNo: TcxCurrencyEdit
            Left = 470
            Top = 77
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            TabOrder = 2
            Width = 158
          end
          object EditPlanBankaHesapId: TcxCurrencyEdit
            Left = 631
            Top = 76
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            TabOrder = 3
            Visible = False
            Width = 53
          end
          object ComboPlanAciklama: TcxComboBox
            Left = 63
            Top = 129
            Properties.MaxLength = 0
            Properties.OnEditValueChanged = YenilebtnClick
            TabOrder = 4
            Width = 241
          end
          object CheckBitisUyar: TcxCheckBox
            Left = 327
            Top = 133
            Caption = 'Uyar'#305' ver'
            State = cbsChecked
            TabOrder = 5
            Transparent = True
            OnClick = CheckBitisUyarClick
            Width = 70
          end
          object SpinUYARIGUN: TcxSpinEdit
            Left = 397
            Top = 131
            Properties.MinValue = 1.000000000000000000
            TabOrder = 6
            Value = 1
            Width = 42
          end
          object cxLabel2: TcxLabel
            Left = 542
            Top = 135
            Caption = 'Resmi tatilse'
          end
          object RadioOnceSonra1: TRadioButton
            Left = 617
            Top = 136
            Width = 63
            Height = 17
            Caption = 'Etkileme'
            TabOrder = 8
          end
          object RadioOnceSonra2: TRadioButton
            Left = 677
            Top = 136
            Width = 89
            Height = 17
            Caption = 'Bir '#246'nceki g'#252'n'
            TabOrder = 9
          end
          object RadioOnceSonra3: TRadioButton
            Left = 765
            Top = 136
            Width = 113
            Height = 17
            Caption = 'Bir sonraki g'#252'n'
            Checked = True
            TabOrder = 10
            TabStop = True
          end
          object EditTutar: TcxCurrencyEdit
            Left = 101
            Top = 12
            Properties.AssignedValues.DisplayFormat = True
            Properties.AssignedValues.EditFormat = True
            Properties.OnEditValueChanged = YenilebtnClick
            TabOrder = 11
            Width = 121
          end
          object ComboKurPlan: TcxComboBox
            Left = 225
            Top = 13
            Properties.DropDownListStyle = lsFixedList
            Properties.MaxLength = 0
            Properties.OnEditValueChanged = YenilebtnClick
            TabOrder = 12
            Width = 58
          end
          object DatePesinat: TcxDateEdit
            Left = 102
            Top = 40
            Properties.OnEditValueChanged = YenilebtnClick
            TabOrder = 13
            Width = 121
          end
          object EditPesinTutar: TcxCurrencyEdit
            Left = 101
            Top = 39
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            Properties.OnEditValueChanged = YenilebtnClick
            TabOrder = 14
            Visible = False
            Width = 121
          end
          object CheckTaksit: TCheckBox
            Left = 101
            Top = 69
            Width = 85
            Height = 17
            Caption = 'Taksitli Plan'
            TabOrder = 15
            OnClick = CheckTaksitClick
          end
          object TaksitPanel: TPanel
            Left = 29
            Top = 89
            Width = 308
            Height = 35
            BevelOuter = bvNone
            TabOrder = 16
            Visible = False
            object Label13: TLabel
              Left = 2
              Top = 9
              Width = 65
              Height = 18
              Caption = 'Taksit Say'#305's'#305
            end
            object TaksitSay: TcxSpinEdit
              Left = 72
              Top = 5
              Properties.MaxValue = 100.000000000000000000
              Properties.MinValue = 1.000000000000000000
              Properties.OnChange = YenilebtnClick
              TabOrder = 0
              Value = 1
              Width = 38
            end
            object EditTaksitTutar: TcxCurrencyEdit
              Left = 113
              Top = 5
              ParentColor = True
              Properties.DisplayFormat = ',0.00 ;-,0.00 '
              TabOrder = 1
              Width = 78
            end
            object DateTaksit: TcxDateEdit
              Left = 194
              Top = 5
              Properties.OnEditValueChanged = YenilebtnClick
              TabOrder = 2
              Width = 121
            end
          end
        end
        object GridTaksit: TcxGrid
          Left = 1
          Top = 167
          Width = 919
          Height = 212
          Align = alClient
          TabOrder = 1
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object PlanTview: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataSource = DtsOdemeTakvimi
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.GroupByBox = False
            object ColumnSozId: TcxGridDBColumn
              Caption = 'No'
              DataBinding.FieldName = 'SOZID'
              Options.Editing = False
            end
            object ColumnTarih: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
            end
            object ColumnTUTAR: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
            end
            object ColumnKur: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              Options.Editing = False
            end
            object ColumnACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              Width = 258
            end
            object PlanTviewUYAR: TcxGridDBColumn
              Caption = 'Uyar'
              DataBinding.FieldName = 'UYAR'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Width = 36
            end
            object PlanTviewUYARIGUN: TcxGridDBColumn
              Caption = 'G'#252'n Say'#305's'#305
              DataBinding.FieldName = 'UYARIGUN'
              PropertiesClassName = 'TcxSpinEditProperties'
              Properties.MaxValue = 30.000000000000000000
              Width = 67
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = PlanTview
          end
        end
        object SQLPlan: TcxMemo
          Left = 46
          Top = 198
          Lines.Strings = (
            'DECLARE @TAKSIT SMALLINT,     '
            '@I SMALLINT,                    '
            '@BASLANGIC SMALLDATETIME,      '
            '@TUTAR MONEY,                  '
            '@KUR VARCHAR(5),'
            '@ACIKLAMA VARCHAR(50),'
            '@UYAR BIT,'
            '@UYARIGUN SMALLINT,        '
            '@ONCESONRA SMALLINT        '
            '                                    '
            'SET @TAKSIT= :PTAKSIT        '
            'SET @I=1                           '
            'SET @BASLANGIC= :PBASLANGIC '
            'SET @TUTAR= :PTUTAR    '
            'SET @KUR= :PKUR               '
            'SET @ACIKLAMA = :PACIKLAMA'
            'SET @UYAR = :PUYAR'
            'SET @UYARIGUN = :PUYARIGUN'
            'SET @ONCESONRA = :PONCESONRA '
            ''
            'CREATE TABLE #GECICIODEME_:SPID_           '
            ' ( SOZID'#9'INT,                       '
            '   TARIH SMALLDATETIME,             '
            '   TUTAR MONEY,                      '
            '   KUR VARCHAR(5),                   '
            '   ACIKLAMA VARCHAR(50) ,'
            '   UYAR BIT,'
            '   UYARIGUN SMALLINT                 '
            ' )      -- '#214'NCE '#304'LK TAKS'#304'D'#304' AYNEN'
            ''
            
              'INSERT INTO #GECICIODEME_:SPID_ (SOZID, TARIH, TUTAR, KUR, ACIKL' +
              'AMA,UYAR, UYARIGUN)                         '
            
              'VALUES (1,@BASLANGIC, ROUND(@TUTAR/@TAKSIT,2), @KUR, @ACIKLAMA,@' +
              'UYAR,@UYARIGUN)  '
            'SET @I=@I+1  '
            
              'WHILE @I <= @TAKSIT                                             ' +
              '                         '
            
              'BEGIN                                                           ' +
              '                         '
            
              '  INSERT INTO #GECICIODEME (SOZID, TARIH, TUTAR, KUR, ACIKLAMA )' +
              '                         '
            
              '  VALUES (1,[dbo].[fn_GT_UygunTarihBul](@BASLANGIC, @ONCESONRA),' +
              ' ROUND(@TUTAR/@TAKSIT,2), @KUR, @ACIKLAMA,@UYAR,@UYARIGUN)  '
            
              '  SET @I=@I+1                                                   ' +
              '                         '
            
              'END                                                             ' +
              '                         '
            
              '                                                                ' +
              '                         '
            
              'select * from #GECICIODEME_:SPID_                               ' +
              '                                '
            'drop table #GECICIODEME_:SPID_ ')
          TabOrder = 2
          Visible = False
          Height = 30
          Width = 788
        end
        object SQLPesin: TMemo
          Left = 44
          Top = 258
          Width = 816
          Height = 29
          Lines.Strings = (
            'DECLARE @TAKSIT SMALLINT,    '
            '@I SMALLINT,                   '
            '@TARIH_PESIN SMALLDATETIME,     '
            '@TARIH_TAKSIT SMALLDATETIME,     '
            '@TUTAR MONEY,@TUTAR_PESIN MONEY,'
            '@KUR VARCHAR(5),'
            '@UYAR SMALLINT,'
            '@UYARIGUN SMALLINT,'
            '@ONCESONRA SMALLINT               '
            '                '
            'SQLKOMUT                     '
            '--SET @TAKSIT=4'
            '--SET @TARIH_PESIN='#39'2010-01-01'#39
            '--sET @TARIH_TAKSIT='#39'2010-01-15'#39
            '--SET @TUTAR=900 '
            '--SET @TUTAR_PESIN=100'
            '--SET @TAKSIT=4'
            '--SET @KUR= '#39'TL'#39
            '--set @UYAR =1'
            '--set @UYARIGUN =1'
            '--SET @ONCESONRA = 1'
            ''
            'CREATE TABLE #GECICIODEME          '
            ' ( ID'#9'INT,                      '
            '   TARIH SMALLDATETIME,            '
            '  TUTAR MONEY,                     '
            '  KUR VARCHAR(5),                  '
            '   ACIKLAMA VARCHAR(50),  '
            '  UYAR bit,'
            '  UYARIGUN SMALLINT               '
            ' )'
            'SET @I=1      '
            '-- '#214'NCE PE'#350#304'NATI s'#305'f'#305'rdan b'#252'y'#252'kse eklensin'
            'if @TUTAR_PESIN > 0 '
            'begin'
            
              '  INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYA' +
              'R, UYARIGUN )            '
            
              '            VALUES (1, [dbo].[fn_GT_UygunTarihBul](@TARIH_PESIN,' +
              '@ONCESONRA), ROUND'
            '    (@TUTAR_PESIN,2), @KUR, '#39'Pe'#351'inat'#39', @UYAR, @UYARIGUN) '
            'end'
            ''
            
              'SET @TUTAR = @TUTAR - @TUTAR_PESIN                              ' +
              '  '
            ''
            '--'#304'LK TAKS'#304'T'
            
              'INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYAR,' +
              ' UYARIGUN )     '
            '                   '
            
              '     VALUES (1,  [dbo].[fn_GT_UygunTarihBul] (@TARIH_TAKSIT, @ON' +
              'CESONRA ), ROUND'
            '(@TUTAR/@TAKSIT,2), @KUR, '
            '       CONVERT(VARCHAR(10),@I)+'#39'. taksit'#39', @UYAR, @UYARIGUN) '
            '--SONRAK'#304' TAKS'#304'TLER  '
            
              'WHILE @I <= @TAKSIT - 1                                         ' +
              '                           '
            
              'BEGIN                                                           ' +
              '                        '
            
              '  INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYA' +
              'R, UYARIGUN )          '
            '              '
            
              '  VALUES (1,DATEADD(month, @I, @TARIH_TAKSIT), ROUND(@TUTAR/@TAK' +
              'SIT,2), @KUR, '
            '  CONVERT(VARCHAR(10),@I+1)+'#39'. taksit'#39', @UYAR, @UYARIGUN) '
            
              '  SET @I=@I+1                                                   ' +
              '                        '
            
              'END                                                             ' +
              '                        '
            
              '                                                                ' +
              '                        '
            
              'select * from #GECICIODEME                                      ' +
              '                        '
            'drop table #GECICIODEME ;')
          TabOrder = 3
          Visible = False
        end
      end
    end
    object CekSenetKrediAraEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #199'ek/Senet Kredi Arama '
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
      OnEnterPage = CekSenetKrediAraEkrEnterPage
      OnExitPage = CekSenetKrediAraEkrExitPage
      object Panel2: TPanel
        Left = 0
        Top = 70
        Width = 921
        Height = 44
        Align = alTop
        TabOrder = 0
        object Label8: TLabel
          Left = 11
          Top = 12
          Width = 46
          Height = 18
          Caption = 'Cari Kod'
        end
        object Label9: TLabel
          Left = 136
          Top = 11
          Width = 39
          Height = 18
          Caption = 'Cari Ad'
        end
        object Label10: TLabel
          Left = 389
          Top = 12
          Width = 35
          Height = 18
          Caption = 'Durum'
        end
        object edCarikod: TcxTextEdit
          Left = 54
          Top = 8
          TabOrder = 0
          Width = 75
        end
        object edCariAd: TcxTextEdit
          Left = 174
          Top = 8
          TabOrder = 1
          Width = 209
        end
        object CekSenetAraTus: TBitBtn
          Left = 617
          Top = 13
          Width = 75
          Height = 25
          Caption = 'Listele'
          DoubleBuffered = True
          Glyph.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            08000000000000010000320B0000320B000000010000000100005A6B7300AD7B
            73004A637B00EFBD8400B58C8C00A5948C00C6948C00B59C8C00BD9C8C00F7BD
            8C00BD949400C6949400CE949400C69C9400CEAD9400F7CE9400C6A59C00CEA5
            9C00D6A59C00C6AD9C00CEAD9C00D6AD9C00F7CE9C00F7D69C004A7BA500CEAD
            A500D6B5A500DEBDA500F7D6A500DEBDAD00DEC6AD00E7C6AD00FFDEAD00FFE7
            AD00CEB5B500F7DEB500F7E7B500FFE7B500FFEFB500D6BDBD00DED6BD00E7DE
            BD00FFE7BD006B9CC600EFDEC600FFEFC600FFF7C600F7E7CE00FFF7CE00F7EF
            D600F7F7D600FFF7D600FFFFD6002184DE00F7F7DE00FFFFDE001884E700188C
            E700FFFFE700188CEF00218CEF00B5D6EF00F7F7EF00FFF7EF00FFFFEF00FFFF
            F700FF00FF004AB5FF0052B5FF0052BDFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0042020A424242
            424242424242424242422B39180B42424242424242424242424243443C180B42
            4242424242424242424242444438180B42424242424242424242424244433918
            0A424242424242424242424242444335004201101A114242424242424242453D
            05072F343434291942424242424242221A2D34343437403E0442424242424206
            231C303437404146284242424242421B210F30373A414140310D42424242421F
            20032434373A3A37321342424242421D25030F2D37373737311042424242420D
            2D2D1C162430333429424242424242421E463F0F0316252E0842424242424242
            4227312D21252314424242424242424242420E141B1B42424242}
          ParentDoubleBuffered = False
          TabOrder = 3
          Visible = False
          OnClick = CekSenetAraTusClick
        end
        object ComboCekSenetKrediDurum: TcxComboBox
          Left = 426
          Top = 8
          Properties.MaxLength = 0
          TabOrder = 2
          Width = 158
        end
      end
      object cxGrid1: TcxGrid
        Left = 0
        Top = 114
        Width = 921
        Height = 336
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        object cxgrdceksenetkrediarama: TcxGridDBTableView
          OnDblClick = cxgrdceksenetkrediaramaDblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = dsCekSenet
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxgrdceksenetkrediarama
        end
      end
      object KrediSQL1: TMemo
        Left = 3
        Top = 154
        Width = 703
        Height = 41
        Lines.Strings = (
          ''
          
            'SELECT  K.ID as KREDIID,KR.ID AS DETAYID,K.KREDITURU, TARIH,BANK' +
            'AKREDIHESAPID,'
          'BANKAKREDIHESAPKODU,BANKAKREDIHESAPADI, '
          'KREDIREFERANSNO,TUTAR,'
          
            'ODENEN=(select isnull(SUM(ODENEN),0.0) from KREDIROTATIF KRT whe' +
            're KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
          
            'BAKIYE=TUTAR-(select isnull(SUM(ODENEN),0.0) from KREDIROTATIF K' +
            'RT where KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
          
            'KALANFAIZ=(select isnull(SUM(TOPLAM-ODENENFAIZ),0.0) from KREDIR' +
            'OTATIF KRT where '
          'KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
          'KUR,ACIKLAMA,ODENMIS'
          '  FROM KREDILER K INNER JOIN KREDIROTATIF KR ON K.ID=KR.KREDIID'
          'where TUTAR>0 ')
        TabOrder = 2
        Visible = False
      end
      object CekSenetSQL: TMemo
        Left = 3
        Top = 289
        Width = 703
        Height = 41
        Lines.Strings = (
          
            'SELECT C.ID,TARIH, TUR, C.DURUM, REHBERID, R.KOD, CARIAD=R.FIRMA' +
            ',TUTAR, NOTLAR,'
          'TUTAR EKLEYEN , KUR'
          'FROM CEKSENETLER C inner join REHBER R on C.REHBERID = R.ID')
        TabOrder = 3
        Visible = False
      end
      object KrediSQL2: TMemo
        Left = 3
        Top = 201
        Width = 703
        Height = 41
        Lines.Strings = (
          'UNION ALL'
          'SELECT K.ID as KREDIID,KO.ID AS '
          'DETAYID,K.KREDITURU,TARIH,BANKAKREDIHESAPID,BANKAKREDIHESAPKODU,'
          
            'BANKAKREDIHESAPADI,KREDIREFERANSNO=SOZLESMENO,TAKSIT,ODENEN=0,BA' +
            'KIYE  ,KALANFAIZ=0,KUR,ACIKLAMA,ODENMIS'
          '  FROM KREDILER K INNER JOIN PLANKREDI KO ON K.ID=KO.KREDIID '
          'where TAKSIT>0 '
          '')
        TabOrder = 4
        Visible = False
      end
    end
    object TahsilatEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Title'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Subtitle'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Caption = 'TahsilatEkr'
      OnEnterPage = TahsilatEkrEnterPage
      OnNextButtonClick = TahsilatEkrNextButtonClick
      object Label15: TLabel
        Left = 199
        Top = 136
        Width = 47
        Height = 18
        Caption = 'A'#231#305'klama'
      end
      object lbl29: TLabel
        Left = 216
        Top = 162
        Width = 30
        Height = 18
        Caption = 'Tutar'
      end
      object LabelFaizTutar: TLabel
        Left = 226
        Top = 187
        Width = 20
        Height = 18
        Caption = 'Faiz'
        Visible = False
      end
      object ComboKurTah: TcxComboBox
        Left = 372
        Top = 159
        Properties.DropDownListStyle = lsFixedList
        Properties.MaxLength = 0
        TabOrder = 0
        Width = 58
      end
      object EditTahsilatTutar: TcxCurrencyEdit
        Left = 248
        Top = 159
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 1
        Width = 121
      end
      object EditFaizTutar: TcxCurrencyEdit
        Left = 248
        Top = 185
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 2
        Visible = False
        Width = 121
      end
      object PanelFisBilgi: TPanel
        Left = 191
        Top = 216
        Width = 197
        Height = 54
        BevelOuter = bvNone
        TabOrder = 3
        object lbl27: TLabel
          Left = 2
          Top = 6
          Width = 49
          Height = 18
          Caption = 'Fi'#351' Tarihi'
        end
        object lbl28: TLabel
          Left = 18
          Top = 27
          Width = 33
          Height = 18
          Caption = 'Fi'#351' No'
        end
        object EditFisNo: TcxTextEdit
          Left = 56
          Top = 27
          TabOrder = 0
          Width = 121
        end
        object DateFisTarihi: TcxDateEdit
          Left = 56
          Top = 1
          TabOrder = 1
          Width = 121
        end
      end
      object ComboBoxTahAciklama: TcxComboBox
        Left = 248
        Top = 133
        Properties.MaxLength = 0
        TabOrder = 4
        Width = 241
      end
    end
    object CekEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #199'ek Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Kalan '#231'ek bilgilerini tamamlay'#305'n'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      OnEnterPage = CekEkrEnterPage
      OnNextButtonClick = CekEkrNextButtonClick
      object Bevel1: TBevel
        Left = 21
        Top = 266
        Width = 702
        Height = 71
      end
      object Bevel2: TBevel
        Left = 21
        Top = 154
        Width = 702
        Height = 88
      end
      object Label6: TLabel
        Left = 594
        Top = 346
        Width = 41
        Height = 18
        Caption = 'Portf'#246'y'
      end
      object Label11: TLabel
        Left = 499
        Top = 192
        Width = 71
        Height = 18
        Caption = 'Ke'#351'ide Tarihi'
      end
      object Label16: TLabel
        Left = 533
        Top = 116
        Width = 35
        Height = 18
        Caption = 'Durum'
      end
      object Label17: TLabel
        Left = 34
        Top = 199
        Width = 42
        Height = 18
        Caption = 'M'#252#351'teri'
      end
      object Label18: TLabel
        Left = 294
        Top = 167
        Width = 30
        Height = 18
        Caption = 'Tutar'
      end
      object Label19: TLabel
        Left = 36
        Top = 284
        Width = 40
        Height = 18
        Caption = 'Seri No'
      end
      object Label20: TLabel
        Left = 508
        Top = 166
        Width = 62
        Height = 18
        Caption = 'Ke'#351'ide Yeri'
      end
      object Label23: TLabel
        Left = 277
        Top = 280
        Width = 47
        Height = 18
        Caption = 'A'#231#305'klama'
      end
      object Label24: TLabel
        Left = 276
        Top = 305
        Width = 48
        Height = 18
        Caption = 'Referans'
      end
      object Label25: TLabel
        Left = 521
        Top = 284
        Width = 49
        Height = 18
        Caption = #214'zel Kod'
      end
      object Label26: TLabel
        Left = 510
        Top = 307
        Width = 60
        Height = 18
        Caption = 'Yetki Kodu'
      end
      object Label30: TLabel
        Left = 549
        Top = 91
        Width = 19
        Height = 18
        Caption = 'T'#252'r'
      end
      object Label31: TLabel
        Left = 24
        Top = 306
        Width = 52
        Height = 18
        Caption = 'Hesap No'
      end
      object Label34: TLabel
        Left = 47
        Top = 170
        Width = 29
        Height = 18
        Caption = 'Hitap'
      end
      object SeriNoSQLMemo: TcxMemo
        Left = 43
        Top = 386
        Lines.Strings = (
          ''
          'DECLARE '
          '@I BIGINT,'
          '@BIT   BIGINT   '
          ' '
          ' CREATE TABLE #GECICI( SERINO'#9'BIGINT) '
          ' '
          'DECLARE cek CURSOR FOR '
          ' --SELECT BASSERINO, BITSERINO from CEKKOCAN order by TARIH'
          ' select BASSERINO, BITSERINO '
          
            '  from CEKKOCAN CK inner join CEKLER C on CK.KREDIID= C.ID where' +
            ' C.HESAPNO='#39':PHESAPNO'#39' order by TARIH'
          ' '
          'OPEN cek '
          'FETCH NEXT FROM cek INTO  @I,@BIT'
          ''
          'WHILE @@FETCH_STATUS = 0 '
          'begin'
          ' WHILE @I <= @BIT'
          '   BEGIN  '
          '     if not exists(select * from CEKSENETLER where SERINO=@I)'
          '     begin'
          '       INSERT INTO #GECICI (SERINO)VALUES (@I)'
          '     end'
          '     SET @I = @I + 1'
          '   END    '
          'FETCH NEXT FROM cek INTO  @I,@BIT'
          'end'
          ''
          'CLOSE cek '
          'DEALLOCATE cek'
          ''
          
            ' select * from #GECICI                                          ' +
            '                    '
          ' drop table #GECICI ;')
        TabOrder = 5
        Visible = False
        Height = 45
        Width = 706
      end
      object SeriNoTus: TcxButton
        Left = 209
        Top = 275
        Width = 48
        Height = 25
        Caption = 'Seri No'
        TabOrder = 6
        OnClick = SeriNoTusClick
      end
      object EditPORTFOY: TcxTextEdit
        Left = 636
        Top = 342
        TabOrder = 7
        Width = 56
      end
      object LabelCARIKOD: TcxLabel
        Left = 78
        Top = 196
        Caption = '--'
      end
      object ComboCekKur: TcxComboBox
        Left = 428
        Top = 162
        Properties.MaxLength = 0
        TabOrder = 2
        Width = 46
      end
      object EditOZELKOD: TcxTextEdit
        Left = 580
        Top = 278
        TabOrder = 9
        Width = 112
      end
      object EditYETKIKODU: TcxTextEdit
        Left = 580
        Top = 304
        TabOrder = 10
        Width = 112
      end
      object EditSERINO: TcxTextEdit
        Left = 82
        Top = 278
        TabOrder = 11
        Width = 121
      end
      object EditODEMEYERI: TcxTextEdit
        Left = 574
        Top = 164
        TabOrder = 3
        Width = 121
      end
      object EditACIKLAMA: TcxTextEdit
        Left = 332
        Top = 278
        TabOrder = 12
        Width = 121
      end
      object EditKEFIL: TcxTextEdit
        Left = 332
        Top = 305
        TabOrder = 13
        Width = 121
      end
      object ComboDURUM: TcxImageComboBox
        Left = 574
        Top = 114
        Properties.Items = <
          item
            Description = 'Portf'#246'yde'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Tahsil Edildi'
            Value = 2
          end
          item
            Description = #304'ptal Edildi'
            Value = 3
          end
          item
            Description = 'Ciro Edildi'
            Value = 4
          end
          item
            Description = 'Tahsile Verildi'
            Value = 5
          end
          item
            Description = 'Teminata Verildi'
            Value = 6
          end
          item
            Description = 'Protesto Edildi'
            Value = 7
          end
          item
            Description = 'Kar'#351#305'l'#305#287#305' Yok'
            Value = 8
          end
          item
            Description = 'Tahsil Edilemiyor'
            Value = 9
          end>
        TabOrder = 14
        Width = 121
      end
      object ComboTUR: TcxImageComboBox
        Left = 574
        Top = 89
        Enabled = False
        Properties.Items = <
          item
            Description = 'M'#252#351'teri '#199'eki'
            ImageIndex = 0
            Value = 23
          end
          item
            Description = 'M'#252#351'teri Senedi'
            Value = 24
          end
          item
            Description = 'Kendi '#199'ekimiz'
            Value = 33
          end
          item
            Description = 'Kendi Senedimiz'
            Value = 34
          end>
        TabOrder = 15
        Width = 121
      end
      object DateKesideTarihi: TcxDateEdit
        Left = 574
        Top = 190
        Properties.SaveTime = False
        Properties.ShowTime = False
        TabOrder = 4
        Width = 121
      end
      object EditCekTutar: TcxCurrencyEdit
        Left = 330
        Top = 162
        Properties.DisplayFormat = ',0.00;-,0.00'
        TabOrder = 1
        Width = 97
      end
      object EditHESAPNO: TcxTextEdit
        Left = 82
        Top = 305
        Properties.ReadOnly = True
        Style.Color = clWindow
        TabOrder = 16
        Width = 121
      end
      object ComboHITAP: TcxImageComboBox
        Left = 78
        Top = 167
        Properties.Items = <
          item
            Description = 'Nama'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Hamiline'
            Value = 1
          end>
        TabOrder = 0
        Width = 103
      end
      object LabelCariAd: TcxLabel
        Left = 165
        Top = 197
        Caption = '--'
      end
      object Logo: TcxImage
        AlignWithMargins = True
        Left = 29
        Top = 73
        Properties.Caption = 'Banka se'#231'mek i'#231'in t'#305'klay'#305'n'
        Properties.GraphicClassName = 'TdxPNGImage'
        Properties.GraphicTransparency = gtTransparent
        Properties.ReadOnly = True
        Properties.Stretch = True
        Style.Shadow = True
        TabOrder = 18
        OnClick = LogoClick
        Height = 75
        Width = 151
      end
      object LabelSubeKodu: TcxLabel
        Left = 194
        Top = 91
        Caption = '--'
        Style.TransparentBorder = True
      end
      object LabelSubeAdi: TcxLabel
        Left = 186
        Top = 112
        Caption = '--'
      end
      object cxDBLabel1: TcxLabel
        Left = 472
        Top = 347
      end
      object LabelBankaSubeID: TcxLabel
        Left = 186
        Top = 133
        Caption = '--'
        Visible = False
      end
    end
    object MasrafEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Masraf Merkezi Se'#231'imi '
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
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      OnEnterPage = MasrafEkrEnterPage
      object GridMasraf: TcxGrid
        Left = 0
        Top = 70
        Width = 921
        Height = 380
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object cxGridDBTableView1: TcxGridDBTableView
          OnDblClick = KasaGridTableViewDblClick
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DtsMasrafGelir
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGridDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object cxGridDBTableView1KOD: TcxGridDBColumn
            Caption = 'Kodu '
            DataBinding.FieldName = 'KOD'
            Width = 78
          end
          object cxGridDBTableView1AD: TcxGridDBColumn
            Caption = 'Ad'#305
            DataBinding.FieldName = 'AD'
            Width = 433
          end
          object cxGridDBTableView1KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
    object VirmanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Virman Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Kasadan kasaya aktar'#305'm i'#231'in kullan'#305'l'#305'r'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      OnEnterPage = VirmanEkrEnterPage
      OnFinishButtonClick = VirmanEkrFinishButtonClick
      object pnl2: TPanel
        Left = 0
        Top = 70
        Width = 921
        Height = 67
        Align = alTop
        TabOrder = 0
        object lbl30: TLabel
          Left = 12
          Top = 44
          Width = 35
          Height = 18
          Caption = 'Miktar'
        end
        object EditVirmanMiktar: TcxCurrencyEdit
          Left = 46
          Top = 40
          ParentColor = True
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          Properties.ReadOnly = True
          TabOrder = 0
          Width = 121
        end
      end
      object GridNereye: TDBGrid
        Left = 0
        Top = 137
        Width = 921
        Height = 313
        Align = alClient
        DataSource = dsKurNereyeQuery
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Options = [dgTitles, dgIndicator, dgColumnResize, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete]
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = TURKISH_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -11
        TitleFont.Name = 'Arial'
        TitleFont.Style = [fsBold]
        OnDblClick = GridNereyeDblClick
      end
    end
    object Label35: TLabel
      Left = 617
      Top = 40
      Width = 62
      Height = 18
      Caption = #304#351'lem Tarihi'
    end
  end
  object dsAra: TDataSource
    AutoEdit = False
    DataSet = AraQuery1
    Left = 425
    Top = 18
  end
  object AraQuery1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 374
    Top = 18
  end
  object KasaQuery: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 16
    Top = 282
  end
  object dsKasaQuery: TDataSource
    AutoEdit = False
    DataSet = KasaQuery
    Left = 76
    Top = 270
  end
  object VirmanNereyeQuery: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 13
    Top = 336
  end
  object dsKurNereyeQuery: TDataSource
    AutoEdit = False
    DataSet = VirmanNereyeQuery
    Left = 82
    Top = 340
  end
  object dsCekSenet: TDataSource
    DataSet = CekSenetKrediQuery
    Left = 81
    Top = 384
  end
  object CekSenetKrediQuery: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'exec p_Ge_CekSenetArama  '#39#39','#39#39','#39#39','#39#39)
    Left = 16
    Top = 385
  end
  object DtsOdemeTakvimi: TDataSource
    DataSet = TabOdemeTakvimi
    Left = 86
    Top = 429
  end
  object TabOdemeTakvimi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 16
    Top = 424
  end
  object TabMasrafGelir: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * FROM  MASRAFGELIR')
    Left = 200
    Top = 425
  end
  object DtsMasrafGelir: TDataSource
    DataSet = TabMasrafGelir
    Left = 271
    Top = 424
  end
  object TabTakvimFat: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pRId2'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select ID,TUR,TARIH,REHBERID,ACIKLAMA,HESAPID=null,'
      'FATURA_TUTARI as TUTAR,KUR,FATURAID=ID,DURUM'
      'from FATBASLIK  '
      'where REHBERID = :pRId2 '
      'order by 3 desc')
    Left = 252
    Top = 303
  end
  object DtsTakvimFat: TDataSource
    DataSet = TabTakvimFat
    Left = 362
    Top = 296
  end
  object TabDuzenliOdeme: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 410
    Top = 228
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = TabFatBaslik
    BCDToCurrency = False
    Left = 716
    Top = 203
  end
  object TabFatBaslik: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 799
    Top = 203
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatBaslik
    Left = 873
    Top = 202
  end
  object DtsFatura: TDataSource
    DataSet = TabFatura
    Left = 873
    Top = 243
  end
  object TabFatura: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterPost = TabFaturaAfterPost
    AfterDelete = TabFaturaAfterDelete
    OnNewRecord = TabFaturaNewRecord
    ParamData = <>
    Left = 799
    Top = 244
    object TabFaturaSEC: TStringField
      FieldName = 'SEC'
      Origin = 'GENOTIP.FATURA.SEC'
      FixedChar = True
      Size = 1
    end
    object TabFaturaTUR: TStringField
      FieldName = 'TUR'
      Origin = 'GENOTIP.FATURA.TUR'
      FixedChar = True
      Size = 5
    end
    object TabFaturaKOD: TStringField
      FieldName = 'KOD'
      Origin = 'GENOTIP.FATURA.KOD'
      FixedChar = True
      Size = 15
    end
    object TabFaturaACIKLAMA: TStringField
      DisplayWidth = 200
      FieldName = 'ACIKLAMA'
      Origin = 'GENOTIP.FATURA.ACIKLAMA'
      Size = 200
    end
    object TabFaturaADET: TFloatField
      FieldName = 'ADET'
      Origin = 'GENOTIP.FATURA.ADET'
      OnChange = TabFaturaADETChange
    end
    object TabFaturaBIRIM: TStringField
      FieldName = 'BIRIM'
      Origin = 'GENOTIP.FATURA.BIRIM'
      FixedChar = True
      Size = 8
    end
    object TabFaturaMIKTAR: TFloatField
      FieldName = 'MIKTAR'
      Origin = 'GENOTIP.FATURA.MIKTAR'
    end
    object TabFaturaISKONTO: TFloatField
      FieldName = 'ISKONTO'
      Origin = 'GENOTIP.FATURA.ISKONTO'
      OnChange = TabFaturaADETChange
      DisplayFormat = '###.##'
    end
    object TabFaturaKDV: TSmallintField
      FieldName = 'KDV'
      Origin = 'GENOTIP.FATURA.KDV'
      OnChange = TabFaturaADETChange
    end
    object TabFaturaOZELKOD: TStringField
      FieldName = 'OZELKOD'
      Origin = 'GENOTIP.FATURA.OZELKOD'
      FixedChar = True
      Size = 10
    end
    object TabFaturaMUHKODU: TStringField
      FieldName = 'MUHKODU'
      Origin = 'GENOTIP.FATURA.MUHKODU'
      FixedChar = True
      Size = 10
    end
    object TabFaturaKASA: TSmallintField
      FieldName = 'KASA'
      Origin = 'GENOTIP.FATURA.KASA'
    end
    object TabFaturaONAY: TStringField
      FieldName = 'ONAY'
      Origin = 'GENOTIP.FATURA.ONAY'
      FixedChar = True
      Size = 1
    end
    object TabFaturaKULLANICI: TStringField
      FieldName = 'KULLANICI'
      Origin = 'GENOTIP.FATURA.KULLANICI'
      FixedChar = True
      Size = 2
    end
    object TabFaturaBIRIMFIYAT: TBCDField
      FieldName = 'BIRIMFIYAT'
      Origin = 'GENOTIP.FATURA.BIRIMFIYAT'
      OnChange = TabFaturaADETChange
      currency = True
      Precision = 19
    end
    object TabFaturaTUTAR: TBCDField
      FieldName = 'TUTAR'
      Origin = 'GENOTIP.FATURA.TUTAR'
      currency = True
      Precision = 19
    end
  end
  object frxFATURA: TfrxDBDataset
    UserName = 'FATURA'
    CloseDataSource = False
    DataSet = TabFatura
    BCDToCurrency = False
    Left = 716
    Top = 245
  end
  object TabTakvimPlan: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pRId1'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      ''
      'select ID,TUR,PLANTARIHI as TARIH,REHBERID,ACIKLAMA,HESAPID,'
      '   TUTAR = case when TUR =61 then GIREN else CIKAN   end,'
      '   KUR,FATURAID=null,DURUM'
      'from KASA'
      'where REHBERID = :pRId1 '
      'and TUR in (61,71,72)'
      'order by 3')
    Left = 253
    Top = 375
  end
  object DtsTakvimPlan: TDataSource
    DataSet = TabTakvimPlan
    Left = 350
    Top = 371
  end
end

