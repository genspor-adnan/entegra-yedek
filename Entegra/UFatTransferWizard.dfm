object FatTransferWizardDlg: TFatTransferWizardDlg
  Left = 0
  Top = 0
  ActiveControl = ComboCikisDepo
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Transfer Sihirbaz'#305
  ClientHeight = 499
  ClientWidth = 1012
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 1012
    Height = 499
    ActivePage = FaturaEkr
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
    DesignSize = (
      1012
      499)
    object FaturaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Transfer bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      OnNextButtonClick = FaturaEkrNextButtonClick
      object PanelUst: TPanel
        Left = 0
        Top = 70
        Width = 1012
        Height = 104
        Align = alTop
        BevelOuter = bvNone
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object btnKapat: TSpeedButton
          Left = 1050
          Top = 7
          Width = 64
          Height = 23
          Caption = 'Kapat'
          Flat = True
          Glyph.Data = {
            66010000424D6601000000000000760000002800000013000000140000000100
            040000000000F000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777777600007777777777777777777000007777777777777777777000007777
            777777777777777000007777777777777770F77C0000777770F7777777777776
            00007777000F7777770F777000007777000F777770F77770000077777000F777
            00F7777E0000777777000F700F7777700000777777700000F777777F00007777
            7777000F777777760000777777700000F77777700000777777000F70F7777770
            000077770000F77700F7777000007770000F7777700F7770000077700F777777
            7700F77400007777777777777777777600007777777777777777777000007777
            77777777777777700000}
        end
        object Label19: TcxLabel
          Left = 578
          Top = 29
          Caption = 'Transfer Tarihi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object LabelFatNo: TcxLabel
          Left = 578
          Top = 54
          Caption = 'Transfer No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object LblCikis: TcxLabel
          Left = 1
          Top = 40
          Caption = #350'ube/'#199#305'k'#305#351' Deposu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object LblGiris: TcxLabel
          Left = 1
          Top = 65
          Caption = #350'ube/Giri'#351' Deposu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1006
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
          TabOrder = 0
          Transparent = True
          object KaydetTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage9'
            Style = tbsTextButton
            Visible = False
            OnClick = ToolButton4Click
          end
          object IptalTus: TToolButton
            Left = 62
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage16'
            Style = tbsTextButton
            Visible = False
          end
          object ToolButton8: TToolButton
            Left = 124
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 132
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
        end
        object EditFatTarih: TcxDBDateEdit
          Left = 682
          Top = 28
          DataBinding.DataField = 'FATURATARIH'
          DataBinding.DataSource = DtsFatBaslik
          TabOrder = 3
          Width = 113
        end
        object EditFatNo: TcxDBTextEdit
          Left = 682
          Top = 53
          DataBinding.DataField = 'FATURANO'
          DataBinding.DataSource = DtsFatBaslik
          TabOrder = 10
          Width = 113
        end
        object ComboCikisDepo: TcxDBImageComboBox
          Left = 232
          Top = 39
          DataBinding.DataField = 'CIKISDEPO'
          DataBinding.DataSource = DtsFatBaslik
          Properties.Items = <
            item
              Description = 'Yap'#305'lmad'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'K'#305'smi'
              Value = 1
            end
            item
              Description = #304'ptal'
              Value = 6
            end
            item
              Description = 'Tamamland'#305
              Value = 9
            end>
          TabOrder = 1
          Width = 97
        end
        object ComboGirisDepo: TcxDBImageComboBox
          Left = 232
          Top = 64
          DataBinding.DataField = 'GIRISDEPO'
          DataBinding.DataSource = DtsFatBaslik
          Properties.Items = <>
          TabOrder = 8
          Width = 97
        end
        object cxLabel2: TcxLabel
          Left = 340
          Top = 40
          Caption = 'Teslim Eden'
        end
        object ComboTeslimlEden: TcxButtonEdit
          Tag = 1
          Left = 431
          Top = 39
          Properties.Alignment.Horz = taLeftJustify
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
          Properties.ReadOnly = True
          Properties.OnButtonClick = ComboTeslimlEdenPropertiesButtonClick
          TabOrder = 2
          Width = 140
        end
        object cxLabel3: TcxLabel
          Left = 340
          Top = 65
          Caption = 'Teslim Alan'
        end
        object ComboTeslimlAlan: TcxButtonEdit
          Tag = 2
          Left = 431
          Top = 64
          Properties.Alignment.Horz = taLeftJustify
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
          Properties.ReadOnly = True
          Properties.OnButtonClick = ComboTeslimlEdenPropertiesButtonClick
          TabOrder = 9
          Width = 140
        end
        object ComboSubeCikis: TcxDBImageComboBox
          Left = 129
          Top = 39
          DataBinding.DataField = 'SUBEID'
          DataBinding.DataSource = DtsFatBaslik
          Properties.Items = <
            item
              Description = 'Yap'#305'lmad'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'K'#305'smi'
              Value = 1
            end
            item
              Description = #304'ptal'
              Value = 6
            end
            item
              Description = 'Tamamland'#305
              Value = 9
            end>
          Properties.OnChange = ComboSubeCikisPropertiesChange
          TabOrder = 13
          Width = 97
        end
        object ComboSubeGiris: TcxDBImageComboBox
          Left = 129
          Top = 64
          DataBinding.DataField = 'GIRISSUBE'
          DataBinding.DataSource = DtsFatBaslik
          Properties.Items = <
            item
              Description = 'Yap'#305'lmad'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'K'#305'smi'
              Value = 1
            end
            item
              Description = #304'ptal'
              Value = 6
            end
            item
              Description = 'Tamamland'#305
              Value = 9
            end>
          Properties.OnChange = ComboGirisPropertiesChange
          TabOrder = 14
          Width = 97
        end
        object cxDBCheckBox1: TcxDBCheckBox
          Left = 795
          Top = 28
          Caption = 'Onay'
          DataBinding.DataField = 'ONAY'
          DataBinding.DataSource = DtsFatBaslik
          Properties.Alignment = taRightJustify
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          TabOrder = 15
          Transparent = True
        end
        object EditDETAYBOLUMU: TcxDBTextEdit
          Left = 682
          Top = 78
          DataBinding.DataField = 'DETAYBOLUMU'
          DataBinding.DataSource = DtsFatBaslik
          Enabled = False
          Style.ReadOnly = True
          TabOrder = 16
          Width = 113
        end
        object cxLabel11: TcxLabel
          Left = 578
          Top = 79
          Caption = #220'rtetim Emir No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 174
        Width = 1012
        Height = 283
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 1
        object PanelAlt: TPanel
          Left = 1
          Top = 225
          Width = 1010
          Height = 57
          Align = alBottom
          Color = 11776947
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          TabOrder = 2
          DesignSize = (
            1010
            57)
          object Label9: TcxLabel
            Left = 5
            Top = 4
            Caption = #214'zel Kod'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
          end
          object Label10: TcxLabel
            Left = 5
            Top = 28
            Caption = 'Yetki Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
          end
          object GridFaturaToplam: TStringGrid
            Left = 32481
            Top = -31
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
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            GridLineWidth = 0
            ParentFont = False
            ScrollBars = ssNone
            TabOrder = 0
          end
          object DBEdit10: TcxDBTextEdit
            Left = 85
            Top = 3
            DataBinding.DataField = 'OZELKOD'
            DataBinding.DataSource = DtsFatBaslik
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 58
          end
          object DBEdit11: TcxDBTextEdit
            Left = 85
            Top = 28
            DataBinding.DataField = 'YETKIKODU'
            DataBinding.DataSource = DtsFatBaslik
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 6
            Width = 58
          end
          object MemoNOTLAR: TcxDBMemo
            Left = 189
            Top = 5
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsFatBaslik
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 4
            Height = 49
            Width = 655
          end
          object cxLabel17: TcxLabel
            Left = 151
            Top = 3
            Caption = 'Notlar'
          end
        end
        object GridFatura: TcxGrid
          Left = 1
          Top = 28
          Width = 1010
          Height = 197
          Align = alClient
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'LondonLiquidSky'
          object GridFaturaView: TcxGridDBTableView
            PopupMenu = PopupMenuFatura
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridFaturaViewCellDblClick
            DataController.DataSource = DtsFatura
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.AlwaysShowEditor = True
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridFaturaViewKOD1: TcxGridDBColumn
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
              Options.Editing = False
              Styles.Header = cxStyle6
              Width = 126
            end
            object GridFaturaViewACIKLAMA1: TcxGridDBColumn
              Caption = #220'r'#252'n Ad'#305
              DataBinding.FieldName = 'AD'
              Options.Editing = False
              Styles.Header = cxStyle8
              Width = 194
            end
            object GridFaturaViewADET1: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.Alignment.Horz = taRightJustify
              Properties.ReadOnly = False
              Options.Editing = False
              Styles.Header = cxStyle9
              Width = 62
            end
            object GridFaturaViewBIRIM1: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Options.Editing = False
              Styles.Header = cxStyle10
              Width = 52
            end
            object GridFaturaViewColumn3: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              Options.Editing = False
              Styles.Header = cxStyle8
            end
            object GridFaturaViewColumn1: TcxGridDBColumn
              Caption = 'Teslim Tarihi'
              DataBinding.FieldName = 'BASTAR'
              PropertiesClassName = 'TcxDateEditProperties'
              Options.Editing = False
              Styles.Header = cxStyle8
              Width = 81
            end
            object GridFaturaViewColumn2: TcxGridDBColumn
              Caption = 'Proje Kodu'
              DataBinding.FieldName = 'PROJEKODU'
              Options.Editing = False
              Styles.Header = cxStyle8
              Width = 160
            end
          end
          object GridFaturaLevel1: TcxGridLevel
            GridView = GridFaturaView
          end
        end
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 1004
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 78
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
          object SatirEkle: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = SatirEkleClick
          end
          object SatirSil: TToolButton
            Left = 78
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = SatirSilClick
          end
          object ToolButton3: TToolButton
            Left = 156
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 4
            ImageName = 'PngImage4'
            Style = tbsSeparator
          end
          object ToolButton1: TToolButton
            Left = 164
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            OnClick = ToolButton1Click
          end
          object ToolButton2: TToolButton
            Left = 242
            Top = 0
            Caption = 'Iptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            OnClick = ToolButton2Click
          end
          object ToolButton10: TToolButton
            Left = 320
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 4
            ImageName = 'PngImage4'
            Style = tbsSeparator
          end
          object TamEkranTus: TToolButton
            Left = 328
            Top = 0
            Caption = 'Tam Ekran'
            ImageIndex = 6
            ImageName = 'PngImage6'
            OnClick = TamEkranTusClick
          end
          object BtnDonustur: TToolButton
            Left = 406
            Top = 0
            Caption = 'D'#246'n'#252#351't'#252'r'
            ImageIndex = 9
            ImageName = 'PngImage9'
            OnClick = BtnDonusturClick
          end
        end
      end
      object cxDBLabel1: TcxDBLabel
        Left = 12
        Top = 43
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsFatBaslik
        Transparent = True
        Height = 19
        Width = 92
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 5
      Width = 121
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 498
    Top = 21
  end
  object PopupMenuFatura: TPopupMenu
    Left = 265
    Top = 230
    object BoSatrEkle1: TMenuItem
      Caption = 'Alta Bo'#351' Sat'#305'r Ekle'
      Visible = False
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object FaturaKoanAyarlar1: TMenuItem
      Caption = 'Fatura Ko'#231'an'#305' Ayarlar'#305
    end
    object BuKullancdaFaturaKoannDeitir1: TMenuItem
      Caption = 'Bu Kullan'#305'c'#305'da Fatura Ko'#231'an'#305'n'#305' De'#287'i'#351'tir'
    end
    object N21: TMenuItem
      Caption = '-'
    end
    object UTSdenAdetleriKontrolEtMenu: TMenuItem
      Caption = #220'TS'#39'den Adetleri Kontrol Et'
      OnClick = UTSdenAdetleriKontrolEtMenuClick
    end
    object IzlemBilgileriniDuzenle: TMenuItem
      Caption = #304'zlem Bilgilerini D'#252'zenle'
      OnClick = IzlemBilgileriniDuzenleClick
    end
    object MenuItem48: TMenuItem
      Caption = '-'
    end
    object FatHepsiniSil: TMenuItem
      Caption = 'Sat'#305'rlar'#305' Sil'
      ImageIndex = 2
    end
    object FaturayiptalEt1: TMenuItem
      Caption = 'Faturay'#305' Sil'
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 281
    Top = 294
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11796479
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
  end
  object DtsFatura: TDataSource
    DataSet = TabFatura
    OnStateChange = DtsFaturaStateChange
    Left = 85
    Top = 263
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatBaslik
    OnStateChange = DtsFatBaslikStateChange
    Left = 20
    Top = 259
  end
  object PopupMenuYaz: TPopupMenu
    Left = 697
    Top = 41
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
  object TabRehber: TFDQuery
    SQL.Strings = (
      'select KOD,FIRMA'
      '   from REHBER'
      'where ID = :PID')
    Left = 154
    Top = 210
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 152
    Top = 258
  end
  object TabFatura: TFDQuery
    AutoCalcFields = False
    BeforeEdit = TabFaturaBeforeEdit
    BeforePost = TabFaturaBeforePost
    AfterPost = TabFaturaAfterPost
    BeforeDelete = TabFaturaBeforeDelete
    AfterDelete = TabFaturaAfterDelete
    AfterScroll = TabFaturaAfterScroll
    OnCalcFields = TabFaturaCalcFields
    OnNewRecord = TabFaturaNewRecord
    OnPostError = TabFaturaPostError
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'FATURA'
    UpdateOptions.KeyFields = 'ID'
    UpdateOptions.AutoIncFields = 'ID'
    SQL.Strings = (
      'SELECT F.*'
      'FROM FATURA F'
      'WHERE F.FATBASID = :Par'
      'ORDER BY F.ID')
    Left = 94
    Top = 222
    object TabFaturaID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabFaturaFATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object TabFaturaREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabFaturaSEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object TabFaturaTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabFaturaURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabFaturaADET: TFMTBCDField
      FieldName = 'ADET'
      OnChange = TabFaturaADETChange
      Precision = 18
      Size = 6
    end
    object TabFaturaBIRIM: TSmallintField
      FieldName = 'BIRIM'
      OnChange = TabFaturaADETChange
    end
    object TabFaturaMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
      Precision = 18
      Size = 6
    end
    object TabFaturaBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 18
      Size = 6
    end
    object TabFaturaTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 19
    end
    object TabFaturaISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabFaturaKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabFaturaMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabFaturaOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
    end
    object TabFaturaOZELKOD2: TWideStringField
      FieldName = 'OZELKOD2'
    end
    object TabFaturaMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabFaturaKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabFaturaONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object TabFaturaEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabFaturaEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabFaturaDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabFaturaKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabFaturaIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object TabFaturaDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 19
    end
    object TabFaturaDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabFaturaISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabFaturaIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TabFaturaIADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object TabFaturaIADEFATURAID: TIntegerField
      FieldName = 'IADEFATURAID'
    end
    object TabFaturaMF: TFMTBCDField
      FieldName = 'MF'
    end
    object TabFaturaYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabFaturaYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabFaturaDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 19
    end
    object TabFaturaDOVIZKURDEGERI: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
    end
    object TabFaturaAD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'AD'
      Size = 100
      Calculated = True
    end
    object TabFaturaKOD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'KOD'
      Calculated = True
    end
    object TabFaturaPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabFaturaKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabFaturaVADE: TByteField
      FieldName = 'VADE'
    end
    object TabFaturaSTOKDURUMDEGIS: TBooleanField
      FieldName = 'STOKDURUMDEGIS'
    end
    object TabFaturaSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabFaturaACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object TabFaturaGIRDEPO: TSmallintField
      FieldName = 'GIRDEPO'
    end
    object TabFaturaCIKDEPO: TSmallintField
      FieldName = 'CIKDEPO'
    end
    object TabFaturaBASTAR: TSQLTimeStampField
      FieldName = 'BASTAR'
    end
    object TabFaturaPROJEKODU: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'PROJEKODU'
      Size = 100
      Calculated = True
    end
    object TabFaturaKDVDAHILBRMFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object TabFaturaGIRISKAYNAK: TByteField
      FieldName = 'GIRISKAYNAK'
    end
    object TabFaturaKDVMUHAFIYETI: TSmallintField
      FieldName = 'KDVMUHAFIYETI'
    end
    object TabFaturaEKMALIYET: TCurrencyField
      FieldName = 'EKMALIYET'
    end
    object TabFaturaBITTAR: TSQLTimeStampField
      FieldName = 'BITTAR'
    end
    object TabFaturaURETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object TabFaturaURETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object TabFaturaMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
    object TabFaturaEKIPMANID: TIntegerField
      FieldName = 'EKIPMANID'
    end
    object TabFaturaOTVYUZDE: TBooleanField
      FieldName = 'OTVYUZDE'
    end
    object TabFaturaOTVMIKTAR: TBCDField
      FieldName = 'OTVMIKTAR'
      Precision = 6
      Size = 2
    end
    object TabFaturaSIRA: TIntegerField
      FieldName = 'SIRA'
    end
    object TabFaturaSATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object TabFaturaISKONTOLUBRMFIYAT: TFloatField
      FieldName = 'ISKONTOLUBRMFIYAT'
      ReadOnly = True
    end
    object TabFaturaKDVDAHILFIYAT: TFloatField
      FieldName = 'KDVDAHILFIYAT'
      ReadOnly = True
    end
    object TabFaturaDEMIRBASID: TIntegerField
      FieldName = 'DEMIRBASID'
    end
    object TabFaturaPOZNO: TIntegerField
      FieldName = 'POZNO'
    end
  end
  object FATURA: TFDQuery
    AutoCalcFields = False
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'Select *,               '
      
        '   AD =  CASE WHEN F.TUR =0 THEN (SELECT AD FROM MASRAFGELIR WHE' +
        'RE ID = F.URUNID) ELSE (SELECT STOKADI FROM STOKLAR WHERE ID = F' +
        '.URUNID )   END,'
      
        '   KOD =  CASE WHEN F.TUR =0 THEN (SELECT KOD FROM MASRAFGELIR W' +
        'HERE ID= F.URUNID ) ELSE (SELECT KOD FROM STOKLAR WHERE ID = F.U' +
        'RUNID )  END,'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJE' +
        'ID)'
      ' from Fatura F'
      'Where '
      'FATBASID = :Par'
      ' order by ID'
      ' ')
    Left = 494
    Top = 263
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabFatBaslik: TFDQuery
    AutoCalcFields = False
    BeforeEdit = TabFatBaslikBeforeEdit
    BeforePost = TabFatBaslikBeforePost
    AfterPost = TabFatBaslikAfterPost
    BeforeDelete = TabFatBaslikBeforeDelete
    OnNewRecord = TabFatBaslikNewRecord
    SQL.Strings = (
      'SELECT '
      #9'FB.*,'
      
        #9'GIRISDEPOAD=(select DEPOADI from DEPOLAR D where FB.GIRISDEPO=D' +
        '.ID),'
      
        #9'CIKISDEPOAD=(select DEPOADI from DEPOLAR D where FB.CIKISDEPO=D' +
        '.ID),'
      
        #9'TESLIMEDENAD=(select R.FIRMA from REHBER R where R.ID=FB.SATICI' +
        'KODU),'
      
        #9'TESLIMALANAD=(select R.FIRMA from REHBER R where R.ID=FB.REHBER' +
        'ID),'
      
        #9'GIRISSUBEAD=(select R.FIRMA from REHBER R where R.ID=FB.GIRISSU' +
        'BE),'
      
        #9'CIKISSUBEAD=(select R.FIRMA from REHBER R where R.ID=FB.SUBEID)' +
        ','
      #9'YAZIYLATOPLAM=( dbo.fn_MoneyToText(FATURA_TUTARI,KUR,0))'
      'FROM FATBASLIK FB WHERE FB.ID = :Par'
      ''
      ''
      ''
      '')
    Left = 41
    Top = 224
  end
  object frxFATURA: TfrxDBDataset
    UserName = 'FATURA'
    CloseDataSource = False
    DataSet = TabFatura
    BCDToCurrency = False
    DataSetOptions = []
    Left = 88
    Top = 312
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = TabFatBaslik
    BCDToCurrency = False
    DataSetOptions = []
    Left = 25
    Top = 303
  end
end
