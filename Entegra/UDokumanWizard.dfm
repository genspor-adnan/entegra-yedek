object DokumanWizard: TDokumanWizard
  Left = 0
  Top = 0
  ActiveControl = LogoResim
  BorderIcons = [biSystemMenu]
  Caption = 'Dok'#252'man Sihirbaz'#305
  ClientHeight = 562
  ClientWidth = 956
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 74
    Top = 0
    Width = 882
    Height = 562
    ActivePage = DokKartEkr
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
      882
      562)
    object DokKartEkr: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Dok'#252'man Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Eklenmediyse orjinal belgeyi s'#252'r'#252'kleyip buraya b'#305'rakabilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      WaterMark.Width = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel3: TPanel
        Left = 593
        Top = 70
        Width = 289
        Height = 450
        Align = alClient
        TabOrder = 0
        object Panel1: TPanel
          Left = 1
          Top = 1
          Width = 287
          Height = 32
          Align = alTop
          TabOrder = 0
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 44
            Top = 4
            Width = 239
            Height = 27
            Margins.Bottom = 0
            Align = alClient
            AutoSize = True
            ButtonWidth = 54
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
            TabOrder = 1
            Transparent = True
            object BelgeGorTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'G'#246'r'
              ImageIndex = 6
              ImageName = 'PngImage6'
              OnClick = BelgeGorTusClick
            end
            object DuzenleTus: TToolButton
              Left = 54
              Top = 0
              Caption = 'De'#287'i'#351
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = DuzenleTusClick
            end
          end
          object LogoResim: TcxImage
            Left = 1
            Top = 1
            Align = alLeft
            Properties.Caption = 'Belge i'#231'in t'#305'klay'#305'n'
            Properties.GraphicClassName = 'TIcon'
            Properties.ImmediatePost = True
            Style.BorderColor = clBtnFace
            Style.Color = clBtnFace
            Style.Edges = []
            StyleDisabled.BorderStyle = ebsNone
            StyleFocused.BorderStyle = ebsNone
            TabOrder = 0
            OnClick = BelgeGorTusClick
            Height = 30
            Width = 40
          end
        end
        object PageControlSag: TcxPageControl
          Left = 1
          Top = 33
          Width = 287
          Height = 416
          Align = alClient
          TabOrder = 1
          Properties.ActivePage = cxTabSheet1
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 412
          ClientRectLeft = 4
          ClientRectRight = 283
          ClientRectTop = 24
          object cxTabSheet1: TcxTabSheet
            Caption = 'cxTabSheet1'
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object GridDokuman: TcxGrid
              Left = 0
              Top = 0
              Width = 279
              Height = 388
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
                OnCellClick = GridDetayViewCellClick
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
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Etiketi'
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  MinWidth = 100
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
                  Width = 100
                end
                object cxGridDBColumn7: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxTextEditProperties'
                  OnGetPropertiesForEdit = cxGridDBColumn7GetPropertiesForEdit
                  MinWidth = 135
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
                  Width = 135
                end
                object GridDetayViewColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'ORJINAL'
                  DataBinding.IsNullValueType = True
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
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Visible = False
                end
              end
              object cxGridDetay: TcxGridLevel
                GridView = GridDetayView
              end
            end
            object SQLDetay: TcxMemo
              Left = 83
              Top = 144
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
                #9'[ETIKET] [nvarchar](100) NULL,'
                #9'[BILGI] [nvarchar](1000) NULL,'
                #9'[ORJINAL] [nvarchar](1000) NULL,'
                #9'[GIRIS] [nvarchar](50) NULL,'
                #9'[KAYNAK] [nvarchar](255) NULL,'
                '                [ZORUNLU] [bit] NULL'
                ')'
                'INSERT INTO #DETAY_:SPID_'
                'select '
                'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
                'RA.KAYNAK,RA.ZORUNLU  '
                'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
                'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
                'where RB.YERI= @yeri and YER_ID= @yerid '
                'and isnull(RA.BOLUM,'#39#39')=@bolum '
                ''
                'union all'
                ''
                
                  'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
                  '  '
                ' from REHBERAYAR  '
                'where  YERI=@yeri '
                'and isnull(BOLUM,'#39#39')=@Bolum  '
                'and ETIKET not in (select ETIKET from REHBERBILGI where  '
                'YERI=@yeri  and YER_ID= @yerid )'
                ''
                'order by 1'
                ''
                'select * from #DETAY_:SPID_'
                'order by SIRA')
              TabOrder = 1
              Visible = False
              Height = 49
              Width = 409
            end
            object MemoRehBilgList: TcxMemo
              Left = 133
              Top = 31
              Lines.Strings = (
                'declare @Varsayilan int'
                'declare @RehberID int'
                'set @Varsayilan = :PVars'
                'set @RehberID = :PReh'
                ''
                ''
                'select ACIKLAMA='#39#350'ube '#39'+RI.AD, RA.ETIKET,RB.BILGI'
                'from REHBER R inner join'
                #9'REHBERILETISIM RI on R.ID=RI.REHBERID inner join'
                #9'REHBERBILGI RB on RB.YERI=1 and RB.YER_ID=RI.ID inner join'
                #9'REHBERAYAR RA on RB.YERI=RA.YERI and RB.ETIKET=RA.ETIKET'
                'where RA.VARSAYILAN=@Varsayilan and R.ID=@RehberID'
                'union all'
                'select ACIKLAMA='#39#304'lgili '#39'+RP.FIRMA, RA.ETIKET,RB.BILGI'
                'from REHBER R inner join'
                #9'REHBER RP on R.ID=RP.BAGID and RP.GRUP=334 inner join'
                #9'REHBERBILGI RB on RB.YERI=4 and RB.YER_ID=RP.ID inner join'
                #9'REHBERAYAR RA on RB.YERI=RA.YERI and RB.ETIKET=RA.ETIKET'
                'where RA.VARSAYILAN=@Varsayilan and R.ID=@RehberID')
              TabOrder = 2
              Visible = False
              Height = 107
              Width = 612
            end
          end
          object TabSheetSozlesme: TcxTabSheet
            Caption = 'TabSheetSozlesme'
            ImageIndex = 1
            object Panel6: TPanel
              Left = 0
              Top = 0
              Width = 279
              Height = 388
              Align = alClient
              Color = clSilver
              ParentBackground = False
              TabOrder = 0
              object CheckBoxUYAR: TcxDBCheckBox
                Left = 5
                Top = 214
                Caption = 'Uyar'#305' Yap       '
                DataBinding.DataField = 'UYAR'
                DataBinding.DataSource = DtsSozlesme
                Properties.Alignment = taRightJustify
                Properties.OnChange = cxDBCheckBox1PropertiesChange
                TabOrder = 8
              end
              object LabelGunSay: TcxLabel
                Left = 101
                Top = 216
                Caption = 'G'#252'n Say'#305's'#305
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Properties.WordWrap = True
                Transparent = True
                Visible = False
                Width = 54
              end
              object EditGunSay: TcxDBSpinEdit
                Left = 159
                Top = 216
                DataBinding.DataField = 'UYARIGUN'
                DataBinding.DataSource = DtsSozlesme
                Properties.AssignedValues.MinValue = True
                Properties.MaxValue = 100.000000000000000000
                TabOrder = 9
                Visible = False
                Width = 55
              end
              object cxDBTextEdit1: TcxDBTextEdit
                Left = 80
                Top = 24
                DataBinding.DataField = 'SOZLESMENO'
                DataBinding.DataSource = DtsSozlesme
                TabOrder = 0
                Width = 190
              end
              object cxLabel17: TcxLabel
                Left = 5
                Top = 24
                Caption = 'S'#246'zle'#351'me No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxDBTextEdit2: TcxDBTextEdit
                Left = 80
                Top = 258
                DataBinding.DataField = 'ACIKLAMA'
                DataBinding.DataSource = DtsSozlesme
                TabOrder = 10
                Width = 190
              end
              object cxLabel18: TcxLabel
                Left = 5
                Top = 258
                Caption = 'A'#231#305'klama'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxLabel16: TcxLabel
                Left = 5
                Top = 52
                Caption = 'S'#246'zle'#351'me Tipi'
                FocusControl = ComboSOZLESMETIPI
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Properties.WordWrap = True
                Transparent = True
                OnClick = cxLabel1Click
                Width = 69
              end
              object ComboSOZLESMETIPI: TcxDBImageComboBox
                Tag = -2303
                Left = 80
                Top = 51
                RepositoryItem = Tablo.repMasrafaSozlesmeTipi
                DataBinding.DataField = 'SOZLESMETIPI'
                DataBinding.DataSource = DtsSozlesme
                ParentFont = False
                Properties.Items = <>
                TabOrder = 1
                Width = 190
              end
              object cxDateEdit1: TcxDBDateEdit
                Left = 80
                Top = 94
                DataBinding.DataField = 'BASLAMA_TARIHI'
                DataBinding.DataSource = DtsSozlesme
                TabOrder = 2
                Width = 109
              end
              object cxLabel8: TcxLabel
                Left = 5
                Top = 94
                Caption = 'Ba'#351'lama Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxLabel12: TcxLabel
                Left = 5
                Top = 116
                Caption = 'Biti'#351' Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxDateEdit2: TcxDBDateEdit
                Left = 80
                Top = 116
                DataBinding.DataField = 'BITIS_TARIHI'
                DataBinding.DataSource = DtsSozlesme
                TabOrder = 3
                Width = 109
              end
              object cxLabel19: TcxLabel
                Left = 5
                Top = 149
                Caption = 'S'#252'resi'
                FocusControl = ComboSURE
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Properties.WordWrap = True
                Transparent = True
                OnClick = cxLabel1Click
                Width = 34
              end
              object ComboSURE: TcxDBImageComboBox
                Tag = -2303
                Left = 80
                Top = 148
                RepositoryItem = Tablo.RepSozlesmeSure
                DataBinding.DataField = 'SURE'
                DataBinding.DataSource = DtsSozlesme
                ParentFont = False
                Properties.Items = <>
                TabOrder = 4
                Width = 109
              end
              object cxLabel20: TcxLabel
                Left = 5
                Top = 179
                Caption = 'Tutar'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object CurrencySATISFIYATI: TcxDBCurrencyEdit
                Left = 80
                Top = 177
                DataBinding.DataField = 'TUTAR'
                DataBinding.DataSource = DtsSozlesme
                Properties.DisplayFormat = ',0.00;(,0.00)'
                TabOrder = 5
                Width = 79
              end
              object ComboSATISKUR: TcxDBComboBox
                Left = 161
                Top = 177
                RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                DataBinding.DataField = 'KUR'
                DataBinding.DataSource = DtsSozlesme
                Properties.DropDownListStyle = lsFixedList
                TabOrder = 6
                Width = 44
              end
            end
          end
        end
      end
      object PageControl1: TcxPageControl
        Left = 0
        Top = 70
        Width = 593
        Height = 450
        Align = alLeft
        TabOrder = 1
        Properties.ActivePage = TabSheetGenel
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControl1Change
        ClientRectBottom = 446
        ClientRectLeft = 4
        ClientRectRight = 589
        ClientRectTop = 24
        object TabSheetGenel: TcxTabSheet
          Caption = 'Genel'
          Color = clHotLight
          ImageIndex = 0
          ParentColor = False
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 585
            Height = 422
            Align = alClient
            Color = clMoneyGreen
            ParentBackground = False
            TabOrder = 0
            object Label2: TcxLabel
              Left = 1
              Top = 87
              Caption = 'Ad'#305
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditAD: TcxDBTextEdit
              Left = 120
              Top = 87
              DataBinding.DataField = 'AD'
              DataBinding.DataSource = DtsDokuman
              TabOrder = 3
              Width = 245
            end
            object EditKonusu: TcxDBTextEdit
              Left = 120
              Top = 112
              DataBinding.DataField = 'KONU'
              DataBinding.DataSource = DtsDokuman
              TabOrder = 4
              Width = 245
            end
            object Label7: TcxLabel
              Left = 365
              Top = 42
              Caption = 'Durum'
              FocusControl = ComboDURUM
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object ComboDURUM: TcxDBImageComboBox
              Left = 419
              Top = 42
              RepositoryItem = Tablo.RepAktifPasif
              DataBinding.DataField = 'DURUM'
              DataBinding.DataSource = DtsDokuman
              Properties.Items = <>
              TabOrder = 16
              Width = 111
            end
            object LabelMasrafMerkezi: TcxLabel
              Left = 2
              Top = 183
              Caption = 'Ait Oldu'#287'u Kurum'
              Transparent = True
            end
            object EditKurum: TcxButtonEdit
              Left = 120
              Top = 180
              HelpType = htKeyword
              Properties.Buttons = <
                item
                  Caption = '+'
                  Default = True
                  Kind = bkText
                end
                item
                  Caption = '-'
                  Kind = bkText
                end>
              Properties.MaxLength = 0
              Properties.OnButtonClick = EditMMPropertiesButtonClick
              TabOrder = 6
              Width = 245
            end
            object cxLabel3: TcxLabel
              Left = 4
              Top = 353
              Caption = 'Sorumlusu'
              Transparent = True
            end
            object EditSorumlu: TcxButtonEdit
              Left = 124
              Top = 351
              HelpType = htKeyword
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.MaxLength = 0
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditSorumluPropertiesButtonClick
              TabOrder = 13
              Width = 148
            end
            object cxLabel4: TcxLabel
              Left = 1
              Top = 111
              Caption = 'Konusu'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxLabel5: TcxLabel
              Left = 1
              Top = 39
              Hint = 'StokKart_Durum'
              Caption = 'S'#252'r'#252'm No'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxLabel6: TcxLabel
              Left = 2
              Top = 231
              Cursor = crHandPoint
              Hint = 'StokKart_Durum'
              Caption = 'Ait Oldu'#287'u Departman'
              FocusControl = ComboBolum
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              OnClick = cxLabel1Click
            end
            object cxLabel7: TcxLabel
              Left = 2
              Top = 256
              Caption = 'Orjinal Lokasyonu'
              Transparent = True
            end
            object EditLokasyon: TcxButtonEdit
              Left = 120
              Top = 254
              HelpType = htKeyword
              HelpKeyword = 'MASRAFID'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.MaxLength = 0
              Properties.OnButtonClick = cxButtonEdit4PropertiesButtonClick
              TabOrder = 8
              Width = 245
            end
            object Label1: TcxLabel
              Left = 1
              Top = 13
              Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
              Caption = 'Dok'#252'man No'
              ParentFont = False
              ParentShowHint = False
              ShowHint = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              Width = 65
            end
            object LabelID: TcxDBLabel
              Left = 203
              Top = 13
              DataBinding.DataField = 'ID'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Height = 21
              Width = 37
            end
            object cxLabel10: TcxLabel
              Left = 365
              Top = 66
              Caption = 'Y'#246'n'#252
              FocusControl = ComboYonu
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object ComboYonu: TcxDBImageComboBox
              Left = 419
              Top = 66
              RepositoryItem = Tablo.RepDokumanYonu
              DataBinding.DataField = 'YON'
              DataBinding.DataSource = DtsDokuman
              Properties.Items = <>
              TabOrder = 17
              Width = 108
            end
            object DateTarih: TcxDBDateEdit
              Left = 419
              Top = 15
              DataBinding.DataField = 'TARIH'
              DataBinding.DataSource = DtsDokuman
              Properties.SaveTime = False
              Properties.ShowTime = False
              TabOrder = 15
              Width = 109
            end
            object cxLabel11: TcxLabel
              Left = 365
              Top = 18
              Caption = 'Tarih'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditSurum: TcxTextEdit
              Left = 120
              Top = 39
              TabOrder = 2
              Width = 74
            end
            object cxDBLabel2: TcxDBLabel
              Left = 120
              Top = 66
              DataBinding.DataField = 'REHBERID'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
              Height = 21
              Width = 37
            end
            object cxDBLabel3: TcxDBLabel
              Left = 189
              Top = 66
              DataBinding.DataField = 'ILGILIID'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
              Height = 21
              Width = 37
            end
            object cxDBLabel6: TcxDBLabel
              Left = 59
              Top = 298
              DataBinding.DataField = 'SORUMLU'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
              Height = 21
              Width = 37
            end
            object cxDBLabel7: TcxDBLabel
              Left = 4
              Top = 444
              DataBinding.DataField = 'LOKASYON'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
              Height = 21
              Width = 45
            end
            object LabelBOYUT: TcxDBLabel
              Left = 466
              Top = 238
              Cursor = crHandPoint
              DataBinding.DataField = 'BOYUT'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
              Height = 21
              Width = 58
            end
            object EditBelgeNo: TcxDBTextEdit
              Left = 120
              Top = 13
              DataBinding.DataField = 'BELGENO'
              DataBinding.DataSource = DtsDokuman
              TabOrder = 1
              Width = 74
            end
            object cxLabel13: TcxLabel
              Left = 377
              Top = 211
              Caption = 'Gizlilik Derecesi'
              FocusControl = ComboGizlilikDerecesi
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              OnClick = cxLabel1Click
              Width = 83
            end
            object ComboGizlilikDerecesi: TcxDBImageComboBox
              Left = 470
              Top = 211
              RepositoryItem = Tablo.RepDokumanGizlilik
              DataBinding.DataField = 'GIZLILIKDERECESI'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Properties.Items = <>
              TabOrder = 11
              Width = 100
            end
            object cxLabel14: TcxLabel
              Left = 377
              Top = 183
              Caption = 'Ar'#351'iv S'#252'resi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              Width = 62
            end
            object cxLabel1: TcxLabel
              Left = 2
              Top = 280
              Caption = 'Klas'#246'r'
              FocusControl = ComboGizlilikDerecesi
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              OnClick = cxLabel1Click
              Width = 34
            end
            object LabelKlasor: TcxLabel
              Left = 124
              Top = 280
              AutoSize = False
              Caption = '---'
              FocusControl = ComboGizlilikDerecesi
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              OnClick = cxLabel1Click
              Height = 20
              Width = 445
            end
            object EditOnaylayacak: TcxButtonEdit
              Left = 369
              Top = 353
              HelpType = htKeyword
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.MaxLength = 0
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditOnaylayacakPropertiesButtonClick
              TabOrder = 14
              Width = 176
            end
            object cxLabel2: TcxLabel
              Left = 377
              Top = 238
              Caption = 'Boyut'
              FocusControl = ComboGizlilikDerecesi
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              Visible = False
              OnClick = cxLabel1Click
              Width = 33
            end
            object cxDBSpinEdit1: TcxDBSpinEdit
              Left = 471
              Top = 184
              DataBinding.DataField = 'ARSIVSURESI'
              DataBinding.DataSource = DtsDokuman
              Properties.MaxValue = 50.000000000000000000
              Properties.MinValue = 1.000000000000000000
              TabOrder = 9
              Width = 50
            end
            object Label9: TcxLabel
              Left = 371
              Top = 138
              Cursor = crHandPoint
              Caption = #304#231'erik'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clNavy
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsUnderline]
              Style.IsFontAssigned = True
              Transparent = True
              OnClick = Label9Click
            end
            object ComboKATEGORI: TcxDBImageComboBox
              Tag = -3204
              Left = 120
              Top = 137
              RepositoryItem = Tablo.RepDokumanKategor
              DataBinding.DataField = 'KATEGORI'
              DataBinding.DataSource = DtsDokuman
              Properties.ImmediatePost = True
              Properties.ImmediateUpdateText = True
              Properties.Items = <>
              Properties.OnEditValueChanged = ComboKATEGORIPropertiesEditValueChanged
              TabOrder = 5
              Width = 245
            end
            object cxLabel15: TcxLabel
              Left = 2
              Top = 138
              Caption = 'Kategori'
              FocusControl = ComboKATEGORI
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Properties.WordWrap = True
              Transparent = True
              OnClick = cxLabel1Click
              Width = 47
            end
            object BeditDemirbas: TcxButtonEdit
              Left = 119
              Top = 205
              Hint = 'DEMIRBASID'
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Caption = '+'
                  Hint = 'Sil'
                  Kind = bkText
                end
                item
                  Caption = '-'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = BeditDemirbasPropertiesButtonClick
              ShowHint = True
              Style.BorderStyle = ebsOffice11
              Style.LookAndFeel.Kind = lfStandard
              Style.LookAndFeel.NativeStyle = False
              StyleDisabled.LookAndFeel.Kind = lfStandard
              StyleDisabled.LookAndFeel.NativeStyle = False
              StyleFocused.LookAndFeel.Kind = lfStandard
              StyleFocused.LookAndFeel.NativeStyle = False
              StyleHot.LookAndFeel.Kind = lfStandard
              StyleHot.LookAndFeel.NativeStyle = False
              StyleReadOnly.LookAndFeel.Kind = lfStandard
              StyleReadOnly.LookAndFeel.NativeStyle = False
              TabOrder = 41
              Width = 245
            end
            object ComboBolum: TcxDBImageComboBox
              Left = 121
              Top = 229
              RepositoryItem = Tablo.RepBizimDepartman
              DataBinding.DataField = 'BOLUM'
              DataBinding.DataSource = DtsDokuman
              Properties.Items = <>
              TabOrder = 7
              Width = 245
            end
            object EditANAHTAR: TcxDBTextEdit
              Left = 124
              Top = 324
              DataBinding.DataField = 'ANAHTAR'
              DataBinding.DataSource = DtsDokuman
              TabOrder = 12
              Width = 421
            end
            object lblDemirbas: TcxLabel
              Left = 1
              Top = 206
              Caption = 'Ait Oldu'#287'u Demirba'#351
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxLabel21: TcxLabel
              Left = 1
              Top = 323
              Caption = 'Anahtar Kelimeler'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxDBImageComboBox1: TcxDBImageComboBox
              Left = 522
              Top = 184
              DataBinding.DataField = 'ARSIVSURETIPI'
              DataBinding.DataSource = DtsDokuman
              ParentFont = False
              Properties.Items = <
                item
                  Description = 'G'#252'n'
                  ImageIndex = 0
                  Value = 1
                end
                item
                  Description = 'Ay'
                  Value = 30
                end
                item
                  Description = 'Y'#305'l'
                  Value = '365'
                end>
              TabOrder = 10
              Width = 48
            end
            object LabelSurumTarihi: TcxLabel
              Left = 205
              Top = 40
              Hint = 'StokKart_Durum'
              Caption = 'S'#252'r'#252'm Tarihi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditOnaylayan: TcxButtonEdit
              Left = 371
              Top = 380
              Properties.Buttons = <
                item
                  Default = True
                  Glyph.SourceDPI = 96
                  Glyph.Data = {
                    424D360400000000000036000000280000001000000010000000010020000000
                    000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00EFF7EFFF4AA54AFF189418FFA5D6A5FFFFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00EFF7EFFF39A539FF10AD29FF18B529FF089410FFA5D6A5FFFFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FF
                    F7FF39AD39FF18AD31FF18B531FF10AD29FF10B529FF089410FFADDEADFFFFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF7FF42B5
                    42FF18B531FF18B539FF18B531FF31BD4AFF18AD31FF10AD29FF089410FFADDE
                    ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0052BD5AFF21B5
                    42FF21BD42FF21B542FF10A521FF189418FF63C673FF18B531FF10B529FF0894
                    10FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039BD4AFF42C6
                    63FF21BD4AFF18B529FF63C663FFEFF7EFFF39AD39FF63C673FF18B531FF10B5
                    29FF109410FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF009CE7A5FF42C6
                    5AFF39BD4AFF63CE6BFFFFFFFF00FFFFFF00EFF7EFFF31A531FF63CE73FF18B5
                    31FF10B529FF109410FFB5E7B5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7
                    D6FFB5EFBDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7EFFF31A531FF63CE
                    73FF18B531FF10B529FF109410FFBDDEBDFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7E7FF29A5
                    29FF63CE73FF18B531FF18B531FF189418FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7
                    E7FF29A529FF63CE7BFF29BD4AFF299C31FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00E7F7E7FF31AD31FF31A531FFCEE7CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                  Kind = bkGlyph
                end
                item
                  Glyph.SourceDPI = 96
                  Glyph.Data = {
                    424D360400000000000036000000280000001000000010000000010020000000
                    000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFEFF7FF3939
                    BDFF2129B5FF8484D6FFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B
                    CEFF7373C6FFD6D6EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007373CEFF1842
                    F7FF184AF7FF1031D6FF3131BDFFDEDEF7FFFFFFFF00FFFFFF006B6BD6FF0829
                    D6FF0831D6FF0010B5FF7373CEFFFFFFFF00FFFFFF00FFFFFF003131BDFF2152
                    F7FF2152FFFF2152FFFF1842E7FF1821B5FFC6C6EFFF6B6BCEFF1031DEFF1042
                    F7FF1039F7FF0839EFFF0018BDFFA5A5DEFFFFFFFF00FFFFFF00BDBDE7FF1831
                    DEFF295AFFFF2152FFFF2152FFFF184AEFFF0810B5FF1031DEFF184AFFFF1042
                    F7FF1042F7FF1042F7FF0839EFFF4242B5FFFFFFFF00FFFFFF00ADADE7FF2139
                    DEFF396BFFFF295AFFFF295AFFFF295AFFFF2152FFFF1852FFFF184AFFFF184A
                    F7FF1042F7FF1039EFFF1821B5FFBDBDE7FFFFFFFF00FFFFFF00FFFFFF009C9C
                    E7FF2129CEFF396BFFFF316BFFFF295AFFFF295AFFFF2152FFFF214AFFFF184A
                    FFFF1039EFFF3139BDFFE7E7F7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00E7E7F7FF4242CEFF314AE7FF396BFFFF315AFFFF295AFFFF2152FFFF1839
                    E7FF4242BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00B5B5EFFF2142DEFF396BFFFF3163FFFF315AFFFF295AFFFF184A
                    E7FF3131BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF004242D6FF4A7BFFFF4273FFFF396BFFFF396BFFFF295AFFFF215A
                    FFFF1039D6FF6B6BD6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00D6D6F7FF2939DEFF5284FFFF4273FFFF3963F7FF1018C6FF396BFFFF295A
                    FFFF2152FFFF1021C6FFB5B5EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF007373E7FF527BF7FF5284FFFF4A7BFFFF2129CEFFBDBDEFFF2129CEFF396B
                    FFFF2152FFFF184AEFFF2121BDFFEFEFFFFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF003139DEFF6B9CFFFF5A8CFFFF294AE7FFA5A5EFFFFFFFFF00CECEF7FF1829
                    CEFF3163FFFF2152FFFF1039DEFF6363CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF006B6BEFFF3952E7FF5A84FFFF4242DEFFFFFFFF00FFFFFF00FFFFFF00B5B5
                    EFFF1829D6FF295AFFFF1031E7FF3131C6FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00C6C6F7FF5A5AD6FFCECEF7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF009C9CE7FF4242CEFFB5B5E7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                  Kind = bkGlyph
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditOnaylayanPropertiesButtonClick
              TabOrder = 45
              Width = 173
            end
            object cxLabel22: TcxLabel
              Left = 298
              Top = 381
              Caption = 'Onaylayan'
            end
            object cxLabel23: TcxLabel
              Left = 297
              Top = 358
              Caption = 'Onaylayacak'
            end
          end
        end
        object EkAlanlarEkr: TcxTabSheet
          Caption = 'Ek Alan'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
        end
      end
    end
    object RevizeEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Revizeler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Dok'#252'man'#305'n '#246'nceki revizeleri. Yeni s'#252'r'#252'm olu'#351'turmak i'#231'in ayn'#305' adl' +
        #305' dosyay'#305' buraya ekleyin..'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'RevizeEkr'
      OnEnterPage = RevizeEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridAktDetay: TcxGrid
        Left = 0
        Top = 97
        Width = 882
        Height = 423
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridRevizeView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsRevize
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object GridRevizeViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridRevizeViewSURUM: TcxGridDBColumn
            Caption = 'Revize'
            DataBinding.FieldName = 'SURUM'
            DataBinding.IsNullValueType = True
            Width = 104
          end
          object GridRevizeViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            DataBinding.IsNullValueType = True
            Width = 149
          end
          object GridRevizeViewREHBERID: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'REHBERID'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
            Width = 123
          end
          object GridRevizeViewONAY: TcxGridDBColumn
            Caption = 'Onay'
            DataBinding.FieldName = 'ONAY'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
            Width = 121
          end
          object GridRevizeViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 215
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridRevizeView
        end
      end
      object ToolBarRevize: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 876
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 117
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
        object SilTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Se'#231'ili Revizeyi Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilTusClick
        end
        object ToolButton1: TToolButton
          Left = 117
          Top = 0
          Width = 51
          Caption = 'ToolButton1'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object GorTus: TToolButton
          Left = 168
          Top = 0
          Caption = 'Se'#231'ili Revizeyi G'#246'r'
          ImageIndex = 6
          ImageName = 'PngImage6'
          OnClick = GorTusClick
        end
      end
    end
    object YetkiEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Dok'#252'man Yetki'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'G'#246'rme, de'#287'i'#351'tirme, silme'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'YetkiEkr'
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar4: TToolBar
        Left = 0
        Top = 70
        Width = 882
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
        object YetkiYeniTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni Yetkili'
          DropdownMenu = PopupMenuYetki
          ImageIndex = 0
          ImageName = 'PngImage0'
        end
        object YetkiSilTus: TToolButton
          Left = 78
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = YetkiSilTusClick
        end
        object YetkiKaydetTus: TToolButton
          Left = 156
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
        end
        object YetkiIptalTus: TToolButton
          Left = 234
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
        end
      end
      object GridYetki: TcxGrid
        Left = 0
        Top = 94
        Width = 882
        Height = 426
        Align = alClient
        TabOrder = 1
        object GridYetkiDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridYetkiDBTableView1CellClick
          DataController.DataSource = DtsYetki
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object GridYetkiDBTableView1Tur: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
          end
          object GridYetkiDBTableView1KULLANICI: TcxGridDBColumn
            Caption = 'Kullan'#305'c'#305' Ad'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 168
          end
          object GridYetkiDBTableView1GOR: TcxGridDBColumn
            Caption = 'G'#246'rme'
            DataBinding.FieldName = 'GOR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1EKLE: TcxGridDBColumn
            Caption = 'Revize'
            DataBinding.FieldName = 'EKLE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn
            Caption = 'De'#287'i'#351'tirme'
            DataBinding.FieldName = 'DEGISTIR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1SIL: TcxGridDBColumn
            Caption = 'Silme'
            DataBinding.FieldName = 'SIL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
        end
        object GridYetkiLevel1: TcxGridLevel
          GridView = GridYetkiDBTableView1
        end
      end
    end
    object IlgiliEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #304'lgili Dok'#252'manlar'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Buraya eklenen dok'#252'man ayn'#305' zamanda di'#287'er dok'#252'man ilgilisinde de' +
        ' g'#246'r'#252'n'#252'r'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'IlgiliEkr'
      OnEnterPage = IlgiliEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 876
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 48
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
        object YeniIlgiliTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = YeniIlgiliTusClick
        end
        object SilIlgiliTus: TToolButton
          Left = 48
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilIlgiliTusClick
        end
        object ToolButton4: TToolButton
          Left = 96
          Top = 0
          Width = 51
          Caption = 'ToolButton1'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object GorIlgiliTus: TToolButton
          Left = 147
          Top = 0
          Caption = 'G'#246'r'
          ImageIndex = 6
          ImageName = 'PngImage6'
          OnClick = GorIlgiliTusClick
        end
      end
      object GridIlgili: TcxGrid
        Left = 0
        Top = 97
        Width = 882
        Height = 423
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridIlgiliView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsIlgili
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object GridIlgiliViewDOKUMANILGILIID: TcxGridDBColumn
            DataBinding.FieldName = 'DOKUMANILGILIID'
            Visible = False
            VisibleForCustomization = False
          end
          object GridIlgiliViewAD: TcxGridDBColumn
            DataBinding.FieldName = 'AD'
            Width = 191
          end
          object GridIlgiliViewKLASOR: TcxGridDBColumn
            DataBinding.FieldName = 'KLASOR'
            Width = 256
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = GridIlgiliView
        end
      end
    end
    object TarihceEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Tarih'#231'e'
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
      Caption = 'TarihceEkr'
      OnPage = TarihceEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 70
        Width = 882
        Height = 450
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
        object cxGridDBTarihce: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsTarihce
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object cxGridDBTarihceID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBTarihceDOKUMANID: TcxGridDBColumn
            DataBinding.FieldName = 'DOKUMANID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBTarihceEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBTarihceACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 213
          end
          object cxGridDBTarihceEKLEYEN: TcxGridDBColumn
            Caption = 'Kullan'#305'c'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 261
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = cxGridDBTarihce
        end
      end
    end
    object BildirimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Duyuru Aboneli'#287'i'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Bu d'#246'k'#252'man ile ilgili belirlenen ki'#351'ilere, belirlenen durumlarda' +
        ' duyuru g'#246'nderilecektir.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'BildirimEkr'
      OnEnterPage = BildirimEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid2: TcxGrid
        Left = 0
        Top = 97
        Width = 882
        Height = 423
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
        object cxGridDBBildirim: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsAbone
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object cxGridDBID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBDOKUMANID: TcxGridDBColumn
            DataBinding.FieldName = 'DOKUMANID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBBildirimColumn1: TcxGridDBColumn
            Caption = 'Da'#287#305'l'#305'm'
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
            Width = 124
          end
          object cxGridDBKullaniciAdi: TcxGridDBColumn
            Caption = 'Duyuru Yap'#305'lacaklar'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 323
          end
          object cxGridDBUyari: TcxGridDBColumn
            Caption = 'Duyurulacak Durum'
            DataBinding.FieldName = 'BILDIRIMTIPI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 153
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = cxGridDBBildirim
        end
      end
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 876
        Height = 24
        Margins.Bottom = 0
        Anchors = [akLeft]
        AutoSize = True
        ButtonWidth = 82
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
        TabOrder = 1
        Transparent = True
        object YeniBildirimTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni Abone'
          DropdownMenu = PopupMenuYetki
          ImageIndex = 0
          ImageName = 'PngImage0'
        end
        object SilBildirimTus: TToolButton
          Left = 82
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilBildirimTusClick
        end
      end
    end
    object DateArsivTarih: TDateTimePicker
      Left = 92
      Top = 206
      Width = 111
      Height = 17
      Date = 41144.000000000000000000
      Time = 0.506678240737528500
      DoubleBuffered = False
      ParentDoubleBuffered = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 10
      Visible = False
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 74
    Height = 562
    Align = alLeft
    TabOrder = 0
    object btnKart: TcxButton
      Left = 2
      Top = 79
      Width = 65
      Height = 29
      Caption = 'Kart'
      TabOrder = 0
      OnClick = btnKartClick
    end
    object btnYetki: TcxButton
      Tag = 2
      Left = 3
      Top = 189
      Width = 65
      Height = 29
      Caption = 'Yetki'
      TabOrder = 2
      OnClick = btnKartClick
    end
    object btnRevize: TcxButton
      Tag = 1
      Left = 3
      Top = 154
      Width = 65
      Height = 29
      Caption = 'Revize'
      TabOrder = 1
      OnClick = btnKartClick
    end
    object BtnIlgili: TcxButton
      Tag = 3
      Left = 3
      Top = 233
      Width = 65
      Height = 56
      Caption = #304'lgili Dok'#252'manlar'
      TabOrder = 3
      WordWrap = True
      OnClick = btnKartClick
    end
    object BtnTarihce: TcxButton
      Tag = 4
      Left = 3
      Top = 295
      Width = 65
      Height = 30
      Caption = 'Tarih'#231'e'
      TabOrder = 4
      WordWrap = True
      OnClick = btnKartClick
    end
  end
  object BtnBildirim: TcxButton
    Tag = 5
    Left = 3
    Top = 331
    Width = 65
    Height = 50
    Caption = 'Duyuru Aboneli'#287'i'
    TabOrder = 2
    Visible = False
    WordWrap = True
    OnClick = btnKartClick
  end
  object TabImaj: TFDQuery
    AfterOpen = TabImajAfterOpen
    AfterPost = TabImajAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  top 1 ID, YERI, YER_ID,DURUM, ICDIS,BELGENO, BELGEADI, T' +
        'UR, ACIKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID'
      'order by ID desc')
    Left = 816
    Top = 30
  end
  object DtsDetay: TDataSource
    DataSet = DETAY
    Left = 883
    Top = 222
  end
  object DETAY: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 764
    Top = 27
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 567
    Top = 161
  end
  object TabDokuman: TFDQuery
    AfterOpen = TabDokumanAfterOpen
    BeforePost = TabDokumanBeforePost
    AfterPost = TabDokumanAfterPost
    OnNewRecord = TabDokumanNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'* '
      'from '
      #9'DOKUMAN'
      'where '
      #9'ID = :pID')
    Left = 535
    Top = 10
  end
  object DtsDokuman: TDataSource
    DataSet = TabDokuman
    Left = 414
    Top = 15
  end
  object TabRevize: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ID,BELGEADI, SURUM, REHBERID,ONAY, EKLEMETARIHI, DEGISTIR' +
        'METARIHI, DURUM, ACIKLAMA'
      ' from IMAJ'
      'where'
      '      YERI =1 and '
      '           YER_ID = :pYERID'
      'order by 4')
    Left = 590
    Top = 21
  end
  object DtsRevize: TDataSource
    DataSet = TabRevize
    Left = 292
    Top = 19
  end
  object TabIlgili: TFDQuery
    AfterPost = TabDokumanAfterPost
    OnNewRecord = TabDokumanNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        '  select DOKUMANILGILIID,D.AD,KLASOR = K.AD from DOKUMANILGILI I' +
        ' '
      '  inner join DOKUMAN D on D.ID = I.DOKUMANILGILIID'
      '  inner join DOKUMANKLASOR K on K.ID = D.KLASOR'
      '  '
      'where '
      'DOKUMANID = :pDID1'
      '--and'
      '--DOKUMANILGILIID = :pDID2')
    Left = 457
    Top = 166
    object TabIlgiliDOKUMANILGILIID: TIntegerField
      FieldName = 'DOKUMANILGILIID'
    end
    object TabIlgiliAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object TabIlgiliKLASOR: TWideStringField
      FieldName = 'KLASOR'
    end
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 359
    Top = 18
  end
  object TabAltKlasor: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'WITH Liste (ID,USTID) AS'
      '('#9'SELECT'
      #9#9'ID,'
      #9#9'USTID'
      #9'FROM DOKUMANKLASOR DK'
      #9#9'where DK.ID= :UstID'
      'UNION ALL'
      #9'SELECT'
      #9#9'ID=DK.ID,'
      #9#9'USTID=P.ID'
      #9'From Liste p INNER JOIN DOKUMANKLASOR DK ON DK.USTID=p.ID'
      ')'
      'SELECT DK.ID,DK.USTID,DK.AD'
      'FROM'
      #9'DOKUMANKLASOR DK inner join'
      #9'Liste p on p.ID=DK.USTID')
    Left = 352
    Top = 173
  end
  object TabYetki: TFDQuery
    BeforeEdit = TabYetkiBeforeEdit
    AfterPost = TabYetkiAfterPost
    OnNewRecord = TabYetkiNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @yeri int,@yerid int'
      'set @yeri=:YERI'
      'set @yerid=:YERID '
      ''
      'select         '
      '       TURU=case '
      #9'   when TUR=5 THEN '#39'Kurum'#39'  '
      #9'   when TUR=4 THEN '#39#350'ube'#39'  '
      #9'   when TUR=3 THEN '#39'Departman'#39'  '
      #9'   when TUR=2 THEN '#39'G'#246'rev'#39'  '
      #9'   when TUR=1 THEN '#39'Ki'#351'i'#39'  '
      #9'   end,'
      '       DY.*,'
      #9'   FIRMA=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DY' +
        '.REHBERID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DY.REHBERID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DY.REHBERID AND DIL=-1 )'
      #9'   END'
      ' from '
      '       DOKUMANYETKI DY '
      '       where'
      '      YERI=@yeri and'
      '       yerID=@yerid '
      ' order by DY.TUR, DY.REHBERID desc')
    Left = 480
    Top = 13
  end
  object DtsYetki: TDataSource
    DataSet = TabYetki
    OnStateChange = DtsYetkiStateChange
    Left = 520
    Top = 165
  end
  object TabTarihce: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  DG.*,R.FIRMA  '
      
        '     FROM DOKUMANGECMIS DG INNER JOIN REHBER R ON R.ID=DG.EKLEYE' +
        'N'
      'WHERE'
      'DokumanID = :PID'
      'order by DG.EKLEMETARIHI desc')
    Left = 696
    Top = 24
  end
  object DtsTarihce: TDataSource
    DataSet = TabTarihce
    Left = 816
    Top = 112
  end
  object TabAbone: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select         '
      '       TURU=case '
      #9'   when TUR=5 THEN '#39'Kurum'#39'  '
      #9'   when TUR=4 THEN '#39#350'ube'#39'  '
      #9'   when TUR=3 THEN '#39'Departman'#39'  '
      #9'   when TUR=2 THEN '#39'G'#246'rev'#39'  '
      #9'   when TUR=1 THEN '#39'Ki'#351'i'#39'  '
      #9'   end,'
      '       DB.*,'
      #9'   FIRMA=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DB' +
        '.REHBERID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DB.REHBERID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DB.REHBERID AND DIL=-1 )'
      #9'   END'
      ' from '
      '       DOKUMANBILDIRIM DB'
      ' where'
      '      DOKUMANID= :DID'
      ''
      ' order by DB.TUR,DB.REHBERID desc')
    Left = 560
    Top = 368
  end
  object DtsAbone: TDataSource
    DataSet = TabAbone
    Left = 560
    Top = 224
  end
  object PopupMenuYetki: TPopupMenu
    Left = 277
    Top = 286
    object TumKullanicilarMenu: TMenuItem
      Tag = 5
      Caption = 'T'#252'm Kullan'#305'c'#305'lar'
      OnClick = TumKullanicilarMenuClick
    end
    object SubeMenu: TMenuItem
      Tag = 4
      Caption = #350'ube'
      OnClick = SubeMenuClick
    end
    object DepartmanMenu: TMenuItem
      Tag = 3
      Caption = 'Departman'
      OnClick = SubeMenuClick
    end
    object GorevMenu: TMenuItem
      Tag = 2
      Caption = 'G'#246'rev'
      OnClick = SubeMenuClick
    end
    object KisiMenu: TMenuItem
      Tag = 1
      Caption = 'Ki'#351'i'
      OnClick = SubeMenuClick
    end
  end
  object TabSozlesme: TFDQuery
    BeforePost = TabSozlesmeBeforePost
    OnNewRecord = TabSozlesmeNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from SOZLESMELER '
      'where YERI=321 and YER_ID=:PID')
    Left = 381
    Top = 345
  end
  object DtsSozlesme: TDataSource
    DataSet = TabSozlesme
    Left = 450
    Top = 347
  end
end
