object TalimatWizardDlg: TTalimatWizardDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Talimat Sihirbaz'#305
  ClientHeight = 529
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 957
    Height = 529
    ActivePage = DosyaSecimEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Back'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Next >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Finish'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = 'Cancel'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    DesignSize = (
      957
      529)
    object DosyaSecimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Talimat Olu'#351'turma Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Talimat'#305'n'#305'za eklemek istedi'#287'iniz hareketleri se'#231'iniz..'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkStart, bkLast, bkNext, bkCancel, bkHelp]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      OnNextButtonClick = DosyaSecimEkrNextButtonClick
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        957
        487)
      object PanelBanka: TPanel
        Left = 0
        Top = 70
        Width = 214
        Height = 417
        Align = alLeft
        TabOrder = 0
        object cxGrid3: TcxGrid
          Left = 1
          Top = 26
          Width = 212
          Height = 390
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object GridViewBanka: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
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
            OptionsView.CellAutoHeight = True
            OptionsView.CellTextMaxLineCount = 2
            OptionsView.GridLines = glHorizontal
            OptionsView.GroupByBox = False
            object GridViewBankaLOGO: TcxGridDBColumn
              Caption = 'Banka'
              DataBinding.FieldName = 'LOGO'
              PropertiesClassName = 'TcxImageProperties'
              Properties.GraphicClassName = 'TdxPNGImage'
              Width = 91
            end
            object GridViewBankaAdi: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              Width = 118
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = GridViewBanka
          end
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 212
          Height = 25
          Align = alTop
          TabOrder = 1
          object cxLabel1: TcxLabel
            Left = 6
            Top = 2
            Caption = 'Banka Hesab'#305' Se'#231'iniz...'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -13
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsBold, fsItalic]
            Style.IsFontAssigned = True
          end
        end
      end
      object PageCtrlDosya: TcxPageControl
        Left = 305
        Top = 70
        Width = 652
        Height = 417
        Align = alClient
        TabOrder = 1
        Properties.ActivePage = PageDosyaAl
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 415
        ClientRectLeft = 2
        ClientRectRight = 650
        ClientRectTop = 28
        object PageDosyaOlustur: TcxTabSheet
          Caption = 'Dosya Olu'#351'tur'
          ImageIndex = 0
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object cxGrid1: TcxGrid
            Left = 0
            Top = 0
            Width = 644
            Height = 386
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfStandard
            LookAndFeel.NativeStyle = True
            object cxGridDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsAlicilar
              DataController.KeyFieldNames = 'ID'
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsSelection.MultiSelect = True
              OptionsView.ScrollBars = ssVertical
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object cxGridDBTableView1SEC: TcxGridDBColumn
                Caption = 'Se'#231
                DataBinding.ValueType = 'Boolean'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Properties.OnEditValueChanged = cxGridDBColumnSECPropertiesEditValueChanged
                Width = 25
              end
              object cxGridDBTableView1TUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                Options.Editing = False
                Width = 67
              end
              object cxGridDBTableView1FIRMA: TcxGridDBColumn
                Caption = 'Firma'
                DataBinding.FieldName = 'FIRMA'
                Options.Editing = False
                Width = 67
              end
              object cxGridDBTableView1MUSTERIHESAPID: TcxGridDBColumn
                Caption = 'Hesap'
                DataBinding.FieldName = 'MUSTERIHESAPID'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = cxGridDBTableView1MUSTERIHESAPIDPropertiesButtonClick
                Options.Editing = False
                Width = 66
              end
              object cxGridDBTableView1ALACAK: TcxGridDBColumn
                Caption = 'Alacak'
                DataBinding.FieldName = 'ALACAK'
                Options.Editing = False
                Width = 56
              end
              object cxGridDBTableView1BORC: TcxGridDBColumn
                Caption = 'Bor'#231
                DataBinding.FieldName = 'BORC'
                Options.Editing = False
                Width = 42
              end
              object cxGridDBTableView1KUR: TcxGridDBColumn
                Caption = 'Kur'
                DataBinding.FieldName = 'KUR'
                Options.Editing = False
                Width = 68
              end
              object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                Options.Editing = False
                Width = 265
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridDBTableView1
            end
          end
        end
        object PageDosyaAl: TcxTabSheet
          Caption = 'Dosya Al'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          DesignSize = (
            648
            387)
          object cxTextEdit1: TcxTextEdit
            Left = 60
            Top = 58
            Anchors = [akLeft, akTop, akRight]
            Enabled = False
            TabOrder = 0
            Width = 545
          end
          object BtnDosyaAl: TcxButton
            Left = 531
            Top = 83
            Width = 75
            Height = 25
            Anchors = [akTop]
            Caption = 'Dosya Al'
            TabOrder = 1
            OnClick = BtnDosyaAlClick
            ExplicitLeft = 527
          end
        end
      end
      object TPanel
        Left = 214
        Top = 70
        Width = 91
        Height = 417
        Align = alLeft
        TabOrder = 2
        DesignSize = (
          91
          417)
        object YenileBtn: TcxButton
          Left = 2
          Top = 192
          Width = 86
          Height = 23
          Caption = 'Listele  >>'
          TabOrder = 0
          Visible = False
          OnClick = YenileBtnClick
        end
        object cxLabel5: TcxLabel
          Left = 2
          Top = 34
          Anchors = [akTop, akRight]
          Caption = 'Hesap Kesim;'
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 2
          Top = 47
          Anchors = [akTop, akRight]
          Caption = 'Ba'#351'lang'#305#231' Tarihi:'
          Transparent = True
        end
        object cxLabel7: TcxLabel
          Left = 2
          Top = 84
          Anchors = [akTop, akRight]
          Caption = 'Biti'#351'Tarihi:'
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 2
          Top = 308
          Anchors = [akTop, akRight]
          Caption = #304#351'lem Tarihi:'
          Transparent = True
        end
        object BtnPlanEkle: TcxButton
          Left = 2
          Top = 164
          Width = 86
          Height = 23
          Caption = 'Plan Ekle >>'
          TabOrder = 5
          OnClick = BtnPlanEkleClick
        end
        object cxLabel4: TcxLabel
          Left = 2
          Top = 351
          Anchors = [akTop, akRight]
          Caption = #304#351'lem Saati:'
          Transparent = True
        end
        object DateHKBas: TcxDBDateEdit
          Left = 2
          Top = 62
          DataBinding.DataField = 'BASTAR'
          DataBinding.DataSource = DtsTalimat
          Properties.ImmediatePost = True
          Properties.SaveTime = False
          Properties.ShowTime = False
          TabOrder = 7
          Width = 86
        end
        object DateIslem: TcxDBDateEdit
          Left = 2
          Top = 324
          DataBinding.DataField = 'ODEMETARIHI'
          DataBinding.DataSource = DtsTalimat
          Properties.ImmediatePost = True
          Properties.SaveTime = False
          Properties.ShowTime = False
          TabOrder = 8
          Width = 86
        end
        object cxDBTimeEdit1: TcxDBTimeEdit
          Left = 2
          Top = 367
          DataBinding.DataField = 'ODEMETARIHI'
          DataBinding.DataSource = DtsTalimat
          Properties.ImmediatePost = True
          TabOrder = 9
          Width = 86
        end
        object RadioIBAN: TcxRadioButton
          Left = 2
          Top = 126
          Width = 78
          Height = 17
          Caption = 'IBAN'
          Checked = True
          TabOrder = 10
          TabStop = True
        end
        object RadioHesapno: TcxRadioButton
          Left = 2
          Top = 144
          Width = 81
          Height = 17
          Caption = 'Hesap No'
          TabOrder = 11
        end
        object DateHKBit: TcxDBDateEdit
          Left = 2
          Top = 99
          DataBinding.DataField = 'BITTAR'
          DataBinding.DataSource = DtsTalimat
          Properties.ImmediatePost = True
          Properties.SaveTime = False
          Properties.ShowTime = False
          TabOrder = 12
          Width = 86
        end
      end
      object EditTalimatAdi: TcxTextEdit
        Left = 758
        Top = 72
        Anchors = [akTop, akRight]
        TabOrder = 3
        Width = 195
      end
      object cxLabel8: TcxLabel
        Left = 695
        Top = 74
        Anchors = [akTop, akRight]
        Caption = 'Talimat Ad'#305':'
      end
    end
    object TalimatOlusturmaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #214'deme Listesi'
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
      OnNextButtonClick = TalimatOlusturmaEkrNextButtonClick
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid4: TcxGrid
        Left = 0
        Top = 105
        Width = 957
        Height = 382
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        ExplicitTop = 102
        ExplicitHeight = 385
        object cxGridDBTableView2: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsToplamTutarlar
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.InvertSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.GroupByBox = False
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'UNVAN'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 88
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 150
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 53
          end
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 32
          end
          object cxGridDBColumn6: TcxGridDBColumn
            Caption = 'Banka'
            DataBinding.FieldName = 'BANKAADI'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 62
          end
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = #350'ube Ad'#305
            DataBinding.FieldName = 'SUBEADI'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 95
          end
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Hesap No'
            DataBinding.FieldName = 'HESAPNO'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 79
          end
          object cxGridDBColumn9: TcxGridDBColumn
            DataBinding.FieldName = 'IBAN'
            PropertiesClassName = 'TcxLabelProperties'
            Width = 102
          end
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxLabelProperties'
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridDBTableView2
        end
      end
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 951
        Height = 29
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 67
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
        TabOrder = 1
        Transparent = True
        object YaziciYaz: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          Style = tbsTextButton
        end
      end
    end
    object OnayImzaSureciEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = ' Onay / '#304'mza S'#252'reci'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = ' Bir i'#351'lem s'#252'reci se'#231'erek i'#351'leminize devam ediniz.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkStart, bkLast, bkBack, bkFinish, bkCancel, bkHelp]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      OnEnterPage = OnayImzaSureciEkrEnterPage
      OnPage = OnayImzaSureciEkrPage
      OnBackButtonClick = OnayImzaSureciEkrBackButtonClick
      object cxGrid2: TcxGrid
        Left = 0
        Top = 70
        Width = 957
        Height = 417
        Align = alClient
        TabOrder = 0
        object cxGrid2DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsAktivite
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object cxGrid2DBTableView1SORUMLU: TcxGridDBColumn
            Caption = 'Personel'
            DataBinding.FieldName = 'SORUMLU'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Options.Editing = False
            Width = 174
          end
          object cxGrid2DBTableView1SORUMLU_EPOSTA: TcxGridDBColumn
            Caption = 'E-Posta'
            DataBinding.FieldName = 'SORUMLU_EPOSTA'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ClearKey = 46
            Width = 36
          end
          object cxGrid2DBTableView1SORUMLU_SMS: TcxGridDBColumn
            Caption = 'SMS'
            DataBinding.FieldName = 'SORUMLU_SMS'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ClearKey = 46
            Width = 34
          end
          object cxGrid2DBTableView1KONUSU: TcxGridDBColumn
            Caption = 'Talimat'
            DataBinding.FieldName = 'KONUSU'
            Options.Editing = False
            Width = 281
          end
          object cxGrid2DBTableView1TURU: TcxGridDBColumn
            Caption = 'S'#252're'#231' T'#252'r'#252
            DataBinding.FieldName = 'TURU'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Onay'
                ImageIndex = 0
                Value = -1
              end
              item
                Description = #304'mza'
                Value = -2
              end
              item
                Description = 'Gnderim'
                Value = -3
              end>
            Options.Editing = False
            Width = 117
          end
          object cxGrid2DBTableView1DURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Options.Editing = False
            Width = 90
          end
          object cxGrid2DBTableView1BITISTARIHI: TcxGridDBColumn
            Caption = 'Biti'#351' Tarihi'
            DataBinding.FieldName = 'BITISTARIHI'
            PropertiesClassName = 'TcxLabelProperties'
            Options.Editing = False
            Width = 117
          end
        end
        object cxGrid2Level1: TcxGridLevel
          GridView = cxGrid2DBTableView1
        end
      end
      object ComboSurecAdi: TcxComboBox
        Left = 79
        Top = 45
        Properties.OnCloseUp = ComboSurecAdiPropertiesCloseUp
        TabOrder = 1
        Width = 155
      end
      object cxLabel3: TcxLabel
        Left = 23
        Top = 46
        Caption = 'S'#252're'#231':'
        Transparent = True
      end
    end
  end
  object DtsGonderen: TDataSource
    DataSet = TabGonderen
    Left = 146
    Top = 13
  end
  object TabGonderen: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabGonderenAfterScroll
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'SELECT'
      ' HESAPID,'
      ' HESAPADI,'
      ' ASD.MUSTERINO,'
      ' ASD.EPOSTA,'
      ' B.LOGO,'
      ' B.BANKAKODU,'
      ' B.BANKAADI,'
      ' ASD.SUBEKODU,'
      ' ASD.SUBEADI, '
      ' ASD.HESAPNO,'
      ' ASD.FIRMANO'
      'FROM'
      'BANKALAR B INNER JOIN'
      '('
      'select '
      'HESAPID=BH.ID,B.BANKAKODU,BS.SUBEKODU,BS.SUBEADI,BH.HESAPNO,'
      'BH.MUSTERINO,BH.FIRMANO,BH.EPOSTA,BH.HESAPADI'
      'FROM'
      'BANKAHESAPLAR BH '
      'inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU = BS.BANKAKODU'
      'where '
      'BH.REHBERID=-1 and ONLINETALIMAT=1'
      ') ASD ON'
      'B.BANKAKODU=ASD.BANKAKODU'
      ''
      '')
    Left = 101
    Top = 2
  end
  object DtsAlicilar: TDataSource
    DataSet = TabAlicilar
    Left = 223
    Top = 11
  end
  object TabAlicilar: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabAlicilarAfterOpen
    ParamData = <
      item
        Name = 'PBasTarih'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = 40179d
      end
      item
        Name = 'PBitTarih'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = 40909d
      end
      item
        Name = 'PHESAPID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 10756
      end>
    SQL.Strings = (
      'select '
      #9'K.ID,'
      #9'K.REHBERID,'
      #9'R.FIRMA,'
      #9'ALACAK=case when K.TUR=75 then K.BORC else K.ALACAK end,'
      #9'BORC=case when K.TUR=75 then K.ALACAK else K.BORC end,'
      #9'K.KUR,'
      #9'K.TUR,'
      #9'K.ACIKLAMA,'
      #9'K.MUSTERIHESAPID'#9
      'from '
      #9'KASA K '
      #9#9'left outer join'
      #9'REHBER R on '
      #9#9'R.ID=K.REHBERID'
      ''
      'where '
      #9'K.HESAPTURU='#39'B'#39' and'
      #9'K.TUR in (61,71,75) and '
      
        #9'(select count(*) from TALIMATDETAY TD where TD.KASAID=K.ID and ' +
        'TD.DURUM in (1,9) )=0 and'
      #9'K.PLANTARIHI between :PBasTarih AND :PBitTarih and'
      #9'K.HESAPID=:PHESAPID ')
    Left = 188
    Top = 1
  end
  object DtsTalimat: TDataSource
    DataSet = TabTalimat
    Left = 316
    Top = 7
  end
  object TabTalimat: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabTalimatBeforePost
    ParamData = <
      item
        Name = 'PTALIMATID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select * from TALIMATLAR where ID= :PTALIMATID')
    Left = 270
    Top = 1
  end
  object DtsTalimatBelge: TDataSource
    DataSet = TabTalimatBelge
    Left = 429
    Top = 11
  end
  object TabTalimatBelge: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabTalimatBelgeBeforePost
    ParamData = <
      item
        Name = 'PTALIMATID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select * from TALIMATBELGELER where TALIMATID= :PTALIMATID')
    Left = 374
    Top = 2
  end
  object DtsAktivite: TDataSource
    DataSet = TabAktivite
    Left = 528
    Top = 12
  end
  object TabAktivite: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabAktiviteBeforePost
    ParamData = <
      item
        Name = 'PTALIMATID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 64
      end>
    SQL.Strings = (
      'select * from AKTIVITELER where TALIMATID= :PTALIMATID')
    Left = 486
    Top = 2
  end
  object frxTalimat: TfrxDBDataset
    UserName = 'TALIMAT'
    CloseDataSource = False
    DataSource = DtsToplamTutarlar
    BCDToCurrency = False
    Left = 430
    Top = 163
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
    Left = 642
    Top = 217
    Bitmap = {}
  end
  object TabBankaAyar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PBANKAKODU'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'Select * from BANKAFTP where BANKAKODU=:PBANKAKODU')
    Left = 577
    Top = 2
  end
  object DtsBankaAyar: TDataSource
    DataSet = TabBankaAyar
    Left = 623
    Top = 14
  end
  object dlgOpen: TOpenDialog
    DefaultExt = '*.fr3'
    Filter = 'Fast Report Dosyas'#305'|*.fr3'
    Left = 642
    Top = 174
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 721
    Top = 287
  end
  object TabKomut: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ' set nocount on'
      'DECLARE @RAPORADI VARCHAR(50)'
      'SET @RAPORADI = '#39#304#351'lem Say'#305#39
      'SELECT CONVERT( TEXT,ALAN ) FROM ('
      ''
      
        'SELECT  ALAN = '#39'DELETE FROM AYARLAR  WHERE RAPORADI LIKE '#39#39#39'+ @R' +
        'APORADI +'#39#39#39#39'  '
      'UNION'
      'SELECT  ALAN = '
      
        #39'INSERT INTO AYARLAR (RAPORADI, SIRANO, ALANTURU, TABLO, ALANADI' +
        ', BANDNO, SOL, UST, EN, BOY, FONT, PUNTO, RENK, OZELLIK, YANASIK' +
        ', TRANSPARENT,[FORMAT] ) VALUES('#39'+'
      
        'CASE WHEN RAPORADI    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (RAPORADI , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHAR(3' +
        '9) END + CHAR(44)+ '
      
        'CASE WHEN SIRANO      IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  SIRANO     ) END + CHAR(44) + '
      
        'CASE WHEN ALANTURU    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (ALANTURU     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN TABLO       IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (TABLO        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN ALANADI     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (ALANADI      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN BANDNO      IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  BANDNO     ) END + CHAR(44) + '
      
        'CASE WHEN SOL         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  SOL        ) END + CHAR(44) + '
      
        'CASE WHEN UST         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  UST        ) END + CHAR(44) + '
      
        'CASE WHEN EN          IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  EN         ) END + CHAR(44) + '
      
        'CASE WHEN BOY         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  BOY        ) END + CHAR(44) + '
      
        'CASE WHEN FONT        IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (FONT        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHA' +
        'R(39) END + CHAR(44)+ '
      
        'CASE WHEN PUNTO       IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  PUNTO        ) END + CHAR(44) + '
      
        'CASE WHEN RENK        IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (RENK        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHA' +
        'R(39) END + CHAR(44)+ '
      
        'CASE WHEN OZELLIK     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (OZELLIK      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN YANASIK     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (YANASIK      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN TRANSPARENT IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (TRANSPARENT  , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN [FORMAT]    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E ([FORMAT]     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + '#39')'#39'+CHAR(13)+CHAR(10)'
      'FROM AYARLAR'
      'WHERE RAPORADI LIKE @RAPORADI'
      ''
      'UNION'
      'SELECT ALAN = '
      
        #39'DELETE FROM DOKUMLER WHERE RAPORADI LIKE '#39#39#39'+ RAPORADI +'#39#39#39' '#39'+ ' +
        'CHAR(13) + CHAR(10)'
      'FROM DOKUMLER'
      'WHERE SQL NOT LIKE '#39'%\RTF1\%'#39
      'AND RAPORADI LIKE @RAPORADI'
      'UNION'
      'SELECT ALAN = '
      
        #39'INSERT INTO DOKUMLER (RAPORADI,GRUBU,MODUL,ACIKLAMA,FIELDLIST,S' +
        'QL,SIRALAMA1,YON1,SIRALAMA2,YON2,DOKUMTIPI,AYNIKAYITLAR,ETIKETLI' +
        'ST,GRUPBY,EKBAGLIST) VALUES('#39' + '
      
        'CASE WHEN RAPORADI     IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (RAPORADI      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN GRUBU        IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (GRUBU         , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN MODUL        IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (MODUL         , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN ACIKLAMA     IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (ACIKLAMA      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN FIELDLIST    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),FIELDLIST   ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN SQL          IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),SQL        ), CHAR(39) ,CHAR' +
        '(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR(' +
        '10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN SIRALAMA1    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (SIRALAMA1     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN YON1         IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (YON1          , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN SIRALAMA2    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (SIRALAMA2     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN YON2         IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (YON2          , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN DOKUMTIPI    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (DOKUMTIPI     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN AYNIKAYITLAR IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (AYNIKAYITLAR  , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN ETIKETLIST   IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),ETIKETLIST  ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN GRUPBY       IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),GRUPBY      ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN EKBAGLIST    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),EKBAGLIST    ), CHAR(39) ,CH' +
        'AR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHA' +
        'R(10)+'#39#39#39') + CHAR(39) END +'#39')'#39'+ CHAR(13) + CHAR(10)'
      'FROM DOKUMLER'
      'WHERE SQL NOT LIKE '#39'%\rtf1\%'#39
      'and raporad'#305' LIKE @RAPORADI'
      ''
      'UNION'
      ''
      'select alan = '
      
        #39'DELETE FROM KOSULLAR WHERE RAPORADI LIKE '#39#39#39'+ raporad'#305' +'#39#39#39' '#39'+ ' +
        'char(13) + char(10)'
      'FROM KOSULLAR'
      'where raporad'#305' LIKE @RAPORADI'
      'UNION'
      ''
      'SELECT '
      
        #39'INSERT INTO KOSULLAR (RAPORADI, SIRANO, BAGLAC, TABLO, ALAN, ES' +
        'ITLIK, DEGER, COMBOICERIK) VALUES('#39'+'
      
        'case when RAPORADI    is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (RAPORADI      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + c' +
        'har(39) end + char(44)+ '
      
        'case when SIRANO      is NULL then '#39'NULL'#39' else convert(varchar, ' +
        '  SIRANO      ) end + char(44) + '
      
        'case when BAGLAC      is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (BAGLAC      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when TABLO      is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (TABLO        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when ALAN       is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (ALAN        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + char' +
        '(39) end + char(44)+ '
      
        'case when ESITLIK    is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (ESITLIK      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when DEGER      is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (DEGER        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when COMBOICERIK is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (COMBOICERIK  , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + ch' +
        'ar(39) end + '#39')'#39'+char(13)+ char(10)'
      'FROM KOSULLAR'
      'where raporad'#305' LIKE @RAPORADI'
      ') AS SORGU')
    Left = 570
    Top = 219
  end
  object TabToplamTutarlar: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabToplamTutarlarAfterOpen
    ParamData = <
      item
        Name = 'PTalimatID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PAciklama'
        Size = -1
        Value = Null
      end
      item
        Name = 'POdemeTarihi'
        Size = -1
        Value = Null
      end
      item
        Name = 'PAnahtar'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'declare @TalimatID int'
      'declare @Aciklama nvarchar(100)'
      'declare @OdemeTarihi datetime'
      'declare @Anahtar nvarchar(10)'
      'set @TalimatID = :PTalimatID'
      'set @Aciklama = :PAciklama'
      'set @OdemeTarihi = :POdemeTarihi'
      'set @Anahtar = :PAnahtar'
      ''
      'SELECT AAA.*, '
      #9'G_FIRMA=(SELECT FIRMA FROM REHBER WHERE ID=-1) ,'
      
        #9'G_ADRES=((SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=-1 AND RA.VARSAYILAN=2)+'#39' '#39'+(SELECT  TOP 1 BILGI FROM REHBERAY' +
        'AR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=R' +
        'B.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=4)+'#39' '#39'+(SELECT BILGI' +
        ' FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=6)+'#39' '#39 +
        '+(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON R' +
        'A.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VAR' +
        'SAYILAN=8)),'
      
        #9'G_EPOSTA=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REH' +
        'BERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_' +
        'ID=-1 AND RA.VARSAYILAN=46),'
      
        #9'G_VD=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERB' +
        'ILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-' +
        '1 AND RA.VARSAYILAN=20),'
      
        #9'G_VNO=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBER' +
        'BILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=' +
        '-1 AND RA.VARSAYILAN=22),'
      
        #9'G_VDKODU=(SELECT VL.VDKODU FROM REHBER R LEFT OUTER JOIN VDLIST' +
        'E VL ON (SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI ' +
        'RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND' +
        ' RA.VARSAYILAN=20)=VL.VD WHERE ID=-1),'
      #9'G_BANKA=BA.BANKAADI,'
      #9'G_BANKA_KODU=BA.BANKAKODU,'
      #9'G_SUBE_KODU=BSA.SUBEKODU,'
      #9'G_SUBE_ADI=BSA.SUBEADI,'
      #9'G_HESAPNO=BHA.HESAPNO,'
      #9'G_MUSTERINO=BHA.MUSTERINO,'
      #9'TUR=CASE WHEN AAA.REHID=-1 THEN '#39'VRM'#39
      #9#9#9' WHEN AAA.BANKAADI=BA.BANKAADI THEN '#39'EFT'#39' ELSE '#39'HAVALE'#39' END,'
      #9'YAZIYLATOPLAM=DBO.fn_MoneyToText((AAA.TUTAR),'#39'TL'#39','#39'Kr'#39',0),'
      #9'ACIKLAMA=@Aciklama,'
      
        #9'BELGEADI=(select top 1 TB.BELGEADI from TALIMATBELGELER  TB whe' +
        're TB.TALIMATID=@TalimatID order by TB.ID),'
      #9'ODEMETARIHI=@OdemeTarihi,'
      #9'Anahtar=@Anahtar'
      'FROM'
      #9'(select '
      #9#9'REHID=R.ID,'
      #9#9'REHKOD=R.KOD,'
      #9#9
      #9#9'UNVAN=R.FIRMA,'
      
        #9#9'ADRES=((SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=R.ID AND RA.VARSAYILAN=2)+'#39' '#39'+(SELECT  TOP 1 BILGI FROM REHBER' +
        'AYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI' +
        '=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4)+'#39' '#39'+(SELECT B' +
        'ILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.' +
        'SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=' +
        '6)+'#39' '#39'+(SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI R' +
        'B ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AN' +
        'D RA.VARSAYILAN=8)),'
      
        #9#9'ISTEL=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=R.ID AND RA.VARSAYILAN=40),'
      
        #9#9'VD=LTRIM(RTRIM(ISNULL((SELECT  TOP 1 BILGI FROM REHBERAYAR RA ' +
        'INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI' +
        ' WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),'#39#39'))),'
      
        #9#9'VNO=LTRIM(RTRIM(ISNULL((SELECT  TOP 1 BILGI FROM REHBERAYAR RA' +
        ' INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YER' +
        'I WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),'#39#39'))),'
      #9#9'VDKODU=VL.VDKODU,'
      
        #9#9'BABAADI=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REH' +
        'BERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_' +
        'ID=R.ID AND RA.VARSAYILAN=52),'
      
        #9#9'TCKIMLIKNO=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN ' +
        'REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.Y' +
        'ER_ID=R.ID AND RA.VARSAYILAN=50),'
      #9#9'BANKAKODU=LTRIM(RTRIM(BM.BANKAKODU)),'
      #9#9'BANKAADI=LTRIM(RTRIM(BM.BANKAADI)),'
      #9#9'SUBEKODU=LTRIM(RTRIM(BSM.SUBEKODU)),'
      #9#9'SUBEADI=LTRIM(RTRIM(BSM.SUBEADI)),'
      #9#9'P.HESAPID,'
      #9#9'BHM.HESAPNO,'
      #9#9'IBAN=ISNULL(BHM.IBAN,'#39' '#39'),'
      #9#9'TUTAR=SUM(P.ALACAK-P.BORC),'
      #9#9'KUR=LTRIM(RTRIM(P.KUR)),'
      #9#9'ISOKUR=INI1.DEGER,'
      #9#9'P.DURUM,'
      
        #9#9'EMAIL=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=R.ID AND RA.VARSAYILAN=46),'
      
        #9#9'FAX=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERB' +
        'ILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R' +
        '.ID AND RA.VARSAYILAN=64)'
      #9'FROM '
      #9#9'(select '
      #9#9#9'TD.TALIMATID,ACIKLAMA1=TD.ACIKLAMA,K.* '
      #9#9'from '
      #9#9#9'TALIMATDETAY TD inner join '
      #9#9#9'KASA K on TD.KASAID=K.ID'
      #9#9'where TD.TALIMATID=@TalimatID and TD.DURUM in (1,9)) P '
      #9#9'INNER JOIN REHBER R on R.ID = P.REHBERID '
      #9#9'INNER JOIN BANKAHESAPLAR BHM on BHM.ID = P.MUSTERIHESAPID'
      #9#9'INNER JOIN BANKASUBELER BSM on BHM.BANKASUBELERID = BSM.ID'
      #9#9'INNER JOIN BANKALAR BM on BM.BANKAKODU = BSM.BANKAKODU'
      
        #9#9'LEFT OUTER JOIN VDLISTE VL ON (SELECT BILGI FROM REHBERAYAR RA' +
        ' INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YER' +
        'I WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20)=VL.VD'
      
        #9#9'LEFT OUTER JOIN (SELECT ANAHTAR,DEGER FROM REHBERINI WHERE BOL' +
        'UM = '#39'ISOParaBirimleri'#39') INI1 on P.KUR=INI1.ANAHTAR'
      'group by '
      
        #9'R.ID,R.KOD,R.FIRMA,BM.BANKAKODU,BM.BANKAADI,BSM.SUBEKODU,BSM.SU' +
        'BEADI,BHM.HESAPNO,BHM.IBAN,VL.VDKODU,P.HESAPID,P.KUR,P.DURUM,INI' +
        '1.DEGER'
      ')as AAA'
      #9'INNER JOIN BANKAHESAPLAR BHA on BHA.ID = AAA.HESAPID'
      #9'INNER JOIN BANKASUBELER BSA on BHA.BANKASUBELERID = BSA.ID '
      #9'INNER JOIN BANKALAR BA on BA.BANKAKODU = BSA.BANKAKODU')
    Left = 687
    Top = 1
  end
  object DtsToplamTutarlar: TDataSource
    DataSet = TabToplamTutarlar
    Left = 741
    Top = 18
  end
  object DtsTalimatDetay: TDataSource
    DataSet = TabTalimatDetay
    Left = 842
    Top = 18
  end
  object TabTalimatDetay: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabTalimatDetayAfterOpen
    ParamData = <
      item
        Name = 'PTalimatID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select '
      '*'
      'from'
      'TALIMATDETAY'
      'where '
      'TALIMATID=:PTalimatID'
      '')
    Left = 791
    Top = 3
  end
  object PopupMenuYaz: TPopupMenu
    Left = 511
    Top = 254
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
end


