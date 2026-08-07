object KrediKartiListeFrame: TKrediKartiListeFrame
  Left = 0
  Top = 0
  Width = 1007
  Height = 492
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
  object BeniDegistir: TPanel
    Left = 0
    Top = 0
    Width = 1007
    Height = 492
    Align = alClient
    Caption = 
      'TabKrediKarti nesnesindeki SQL ifadelerini degistirmeyi unutmayi' +
      'n.'
    TabOrder = 0
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 999
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 24
      ButtonWidth = 62
      Caption = 'AletCubugu'
      Color = clTeal
      DockSite = False
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
      object SilTus: TToolButton
        Left = 89
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        ImageName = 'PngImage7'
        OnClick = SilTusClick
      end
      object ToolButton1: TToolButton
        Left = 178
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 10
        ImageName = 'PngImage9'
        Style = tbsSeparator
      end
      object DegisTus: TToolButton
        Left = 186
        Top = 0
        Caption = 'D'#252'zenle'
        ImageIndex = 9
        ImageName = 'PngImage8'
        Style = tbsTextButton
        OnClick = DegisTusClick
      end
      object YaziciYaz: TToolButton
        Left = 275
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        ImageName = 'PngImage15'
      end
      object ToolButtonArama: TToolButton
        Left = 364
        Top = 0
        Width = 8
        Caption = 'ToolButtonArama'
        Style = tbsSeparator
      end
      object LabelTumKayitlar: TToolButton
        Left = 0
        Top = 0
        Caption = 'T'#252'm'
        Style = tbsTextButton
        OnClick = LabelTumKayitlarClick
        ImageIndex = 52
        ImageName = 'PngImageListe1'
      end
      object LabelSonArananlar: TToolButton
        Left = 62
        Top = 0
        Caption = 'Son'
        Style = tbsTextButton
        OnClick = LabelSonArananlarClick
        ImageIndex = 43
        ImageName = 'PngImage43'
      end
      object LabelSikArananlar: TToolButton
        Left = 124
        Top = 0
        Caption = 'S'#305'k'
        Style = tbsTextButton
        OnClick = LabelSikArananlarClick
        ImageIndex = 51
        ImageName = 'PngImageYildiz1'
      end
    end
    object GridKKListe: TcxGrid
      Left = 1
      Top = 36
      Width = 1005
      Height = 183
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      PopupMenu = PmKrediKarti
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      object GridKKListeView: TcxGridDBTableView
        OnDblClick = DegisTusClick
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridKKListeViewCanFocusRecord
        DataController.DataSource = DtsKrediKarti
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
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
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object GridKKListeViewKODU: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'KODU'
          DataBinding.IsNullValueType = True
        end
        object GridKKListeViewADI: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'ADI'
          DataBinding.IsNullValueType = True
          Width = 138
        end
        object GridKKListeViewLOGO: TcxGridDBColumn
          DataBinding.FieldName = 'LOGO'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TdxPNGImage'
          IsCaptionAssigned = True
        end
        object GridKKListeViewBANKAADI: TcxGridDBColumn
          Caption = 'Banka'
          DataBinding.FieldName = 'BANKAADI'
          DataBinding.IsNullValueType = True
          Width = 97
        end
        object GridKKListeViewID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          DataBinding.IsNullValueType = True
          Visible = False
        end
        object GridKKListeViewHAMILI: TcxGridDBColumn
          Caption = 'Hamili'
          DataBinding.FieldName = 'HAMILI'
          DataBinding.IsNullValueType = True
          Width = 149
        end
        object GridKKListeViewTURU: TcxGridDBColumn
          Caption = 'T'#252'r'#252
          DataBinding.FieldName = 'TURU'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepKrediKartiTuru
        end
        object GridKKListeViewNOSU: TcxGridDBColumn
          Caption = 'No'
          DataBinding.FieldName = 'NOSU'
          DataBinding.IsNullValueType = True
          Width = 114
        end
        object GridKKListeViewHESAP_KESIM_TARIHI: TcxGridDBColumn
          Caption = 'Hesap Kesim Tarihi'
          DataBinding.FieldName = 'HESAP_KESIM_TARIHI'
          DataBinding.IsNullValueType = True
          Width = 84
        end
        object GridKKListeViewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepAktifPasif
        end
        object GridKKListeViewSUBEID: TcxGridDBColumn
          Caption = #350'ube'
          DataBinding.FieldName = 'SUBEID'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        end
      end
      object GridKKListeLevel1: TcxGridLevel
        GridView = GridKKListeView
      end
    end
    object PageControlSekme: TcxPageControl
      Left = 1
      Top = 227
      Width = 1005
      Height = 264
      Align = alBottom
      TabOrder = 4
      Properties.ActivePage = TabSheetToplamlar
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 260
      ClientRectLeft = 4
      ClientRectRight = 1001
      ClientRectTop = 27
      object TabSheetToplamlar: TcxTabSheet
        Caption = 'Hesap Kesim'
        ImageIndex = 7
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridHesapKesim: TcxGrid
          Left = 0
          Top = 29
          Width = 997
          Height = 204
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridHesapKesimView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridHesapKesimViewCanFocusRecord
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsHesapKesim
            DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skSum
                Column = GridHesapKesimViewTUTAR
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
            Styles.ContentEven = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object GridHesapKesimViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridHesapKesimViewKASAID: TcxGridDBColumn
              DataBinding.FieldName = 'KASAID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridHesapKesimViewKKID: TcxGridDBColumn
              DataBinding.FieldName = 'KKID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridHesapKesimViewTARIH: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 80
            end
            object GridHesapKesimViewTAKSIT: TcxGridDBColumn
              Caption = 'Taksit'
              DataBinding.FieldName = 'TAKSIT'
              DataBinding.IsNullValueType = True
            end
            object GridHesapKesimViewTUTAR: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 87
            end
            object GridHesapKesimViewKUR: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Width = 43
            end
            object GridHesapKesimViewACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 340
            end
          end
          object cxGridDBTableView2: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DetailKeyFieldNames = 'CEKID'
            DataController.MasterKeyFieldNames = 'CEKID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.GroupByBox = False
            Styles.ContentOdd = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object cxGridDBColumn15: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 74
            end
            object cxGridDBColumn16: TcxGridDBColumn
              DataBinding.FieldName = 'VADE'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object cxGridDBColumn17: TcxGridDBColumn
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 109
            end
            object cxGridDBColumn18: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 354
            end
            object cxGridDBColumn19: TcxGridDBColumn
              DataBinding.FieldName = 'CEKID'
              DataBinding.IsNullValueType = True
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = GridHesapKesimView
          end
        end
        object JvNavPanelHeader1: TJvNavPanelHeader
          Left = 0
          Top = 0
          Width = 997
          Height = 29
          Align = alTop
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 0
          object Label3: TLabel
            Left = 13
            Top = 6
            Width = 13
            Height = 18
            Caption = 'Ay'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object Label4: TLabel
            Left = 188
            Top = 6
            Width = 14
            Height = 18
            Caption = 'Y'#305'l'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LabelSonOdeme: TLabel
            Left = 324
            Top = 6
            Width = 66
            Height = 18
            Caption = 'Son '#214'deme'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object cbHesapKesimAy: TcxImageComboBox
            Left = 51
            Top = 4
            EditValue = 1
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                Description = 'Ocak'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = #350'ubat'
                Value = 2
              end
              item
                Description = 'Mart'
                Value = 3
              end
              item
                Description = 'Nisan'
                Value = 4
              end
              item
                Description = 'May'#305's'
                Value = 5
              end
              item
                Description = 'Haziran'
                Value = 6
              end
              item
                Description = 'Temmuz'
                Value = 7
              end
              item
                Description = 'A'#287'ustos'
                Value = 8
              end
              item
                Description = 'Eyl'#252'l'
                Value = 9
              end
              item
                Description = 'Ekim'
                Value = 10
              end
              item
                Description = 'Kas'#305'm'
                Value = 11
              end
              item
                Description = 'Aral'#305'k'
                Value = 12
              end>
            Properties.OnEditValueChanged = CalendarHKBasPropertiesEditValueChanged
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWhite
            Style.Font.Height = -12
            Style.Font.Name = 'Arial'
            Style.Font.Style = [fsBold]
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 0
            Width = 121
          end
          object SpinHesapKesimYil: TcxSpinEdit
            Left = 221
            Top = 4
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarHKBasPropertiesEditValueChanged
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWhite
            Style.Font.Height = -12
            Style.Font.Name = 'Arial'
            Style.Font.Style = [fsBold]
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 1
            Value = 2013
            Width = 75
          end
        end
      end
      object TabSheetEkstre: TcxTabSheet
        Caption = 'Ekstre'
        ImageIndex = 6
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridKrediKarti: TcxGrid
          Left = 0
          Top = 31
          Width = 997
          Height = 202
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridKrediKartiView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridKrediKartiViewCanFocusRecord
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsKKEkstre
            DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skSum
                Column = GridKrediKartiViewBORC
              end
              item
                Kind = skSum
                Column = GridKrediKartiViewALACAK
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
            Styles.ContentEven = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object GridKrediKartiViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridKrediKartiViewTUR: TcxGridDBColumn
              Caption = #304#351'lem T'#252'r'#252
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepKasaTurleri
            end
            object GridKrediKartiViewISLEMTARIHI: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'ISLEMTARIHI'
              DataBinding.IsNullValueType = True
              Width = 97
            end
            object GridKrediKartiViewFIRMA: TcxGridDBColumn
              Caption = 'Cari'
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              Width = 134
            end
            object GridKrediKartiViewMASRAFAD: TcxGridDBColumn
              Caption = 'Masraf'
              DataBinding.FieldName = 'MASRAFAD'
              DataBinding.IsNullValueType = True
              Width = 124
            end
            object GridKrediKartiViewBELGENO: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              DataBinding.IsNullValueType = True
              Width = 68
            end
            object GridKrediKartiViewREHBERID: TcxGridDBColumn
              DataBinding.FieldName = 'REHBERID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridKrediKartiViewBORC: TcxGridDBColumn
              Caption = 'Bor'#231
              DataBinding.FieldName = 'BORC'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 65
            end
            object GridKrediKartiViewALACAK: TcxGridDBColumn
              Caption = 'Alacak'
              DataBinding.FieldName = 'ALACAK'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 62
            end
            object GridKrediKartiViewBORCBAKIYE: TcxGridDBColumn
              Caption = 'Bor'#231' Bakiye'
              DataBinding.FieldName = 'BORCBAKIYE'
              DataBinding.IsNullValueType = True
            end
            object GridKrediKartiViewALACAKBAKIYE: TcxGridDBColumn
              Caption = 'Alacak Bakiye'
              DataBinding.FieldName = 'ALACAKBAKIYE'
              DataBinding.IsNullValueType = True
            end
            object GridKrediKartiViewKUR: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
            end
            object GridKrediKartiViewYERELKUR: TcxGridDBColumn
              Caption = 'Y.Kur'
              DataBinding.FieldName = 'YERELKUR'
              DataBinding.IsNullValueType = True
            end
            object GridKrediKartiViewYERELTUTAR: TcxGridDBColumn
              Caption = 'Y.Tutar'
              DataBinding.FieldName = 'YERELTUTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
            end
            object GridKrediKartiViewYERELBAKIYE: TcxGridDBColumn
              Caption = 'Y.Bakiye'
              DataBinding.FieldName = 'YERELBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
            end
            object GridKrediKartiViewMASRAFID: TcxGridDBColumn
              DataBinding.FieldName = 'MASRAFID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridKrediKartiViewACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 304
            end
          end
          object GridKrediKartiDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DetailKeyFieldNames = 'CEKID'
            DataController.MasterKeyFieldNames = 'CEKID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.GroupByBox = False
            Styles.ContentOdd = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object GridKrediKartiDBTableView1DURUM: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 74
            end
            object GridKrediKartiDBTableView1VADE: TcxGridDBColumn
              DataBinding.FieldName = 'VADE'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object GridKrediKartiDBTableView1SERINO: TcxGridDBColumn
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 109
            end
            object GridKrediKartiDBTableView1HESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 354
            end
            object GridKrediKartiDBTableView1Column1: TcxGridDBColumn
              DataBinding.FieldName = 'CEKID'
              DataBinding.IsNullValueType = True
            end
          end
          object GridKrediKartiLevel1: TcxGridLevel
            GridView = GridKrediKartiView
          end
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 997
          Height = 31
          Align = alTop
          Caption = 'Panel1'
          TabOrder = 1
          object JvNavPanelHeader2: TJvNavPanelHeader
            Left = 1
            Top = 1
            Width = 995
            Height = 29
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
              Left = 201
              Top = 6
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
              Left = 10
              Top = 6
              Width = 48
              Height = 18
              Caption = 'Ba'#351'lama'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object CalendarEkstreBas: TcxDateEdit
              Left = 61
              Top = 3
              EditValue = 40909d
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 0
              Width = 121
            end
            object CalendarEkstreBit: TcxDateEdit
              Left = 233
              Top = 3
              EditValue = 40940d
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 1
              Width = 121
            end
          end
        end
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 1
      Top = 219
      Width = 1005
      Height = 8
      HotZoneClassName = 'TcxMediaPlayer8Style'
      AlignSplitter = salBottom
      Control = PageControlSekme
      ExplicitWidth = 8
    end
    object SqlMemo: TMemo
      Left = 14
      Top = 72
      Width = 630
      Height = 65
      Lines.Strings = (
        
          'select KK.*,CAST(SKTAY as varchar(2))+'#39'/'#39'+CAST(SKTYIL as varchar' +
          '(2)) as SKT1,B.LOGO,B.BANKAADI,BS.SUBEADI  from '
        'KREDIKARTI KK'
        'left  join BANKAHESAPLAR BH ON  BH.ID = KK.BANKAHESAPID'
        'left join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
        'left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
        ''
        'Where 1=1')
      TabOrder = 2
      Visible = False
    end
  end
  object DtsKrediKarti: TDataSource
    DataSet = KREDIKARTI
    Left = 652
    Top = 223
  end
  object KREDIKARTI: TFDQuery
    AfterInsert = KREDIKARTIAfterScroll
    AfterDelete = KREDIKARTIAfterScroll
    AfterScroll = KREDIKARTIAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select KK.*,CAST(SKTAY as varchar(2))+'#39'/'#39'+CAST(SKTYIL as varchar' +
        '(2)) as SKT1,B.LOGO,B.BANKAADI,BS.SUBEADI  from KREDIKARTI KK'
      'left  join BANKAHESAPLAR BH ON  BH.ID = KK.BANKAHESAPID'
      'left join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      'left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU')
    Left = 650
    Top = 172
  end
  object TabKKEkstre: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *,'
      #9'BORCBAKIYE=case when BB>0.0 then BB else 0.0 end,'
      #9'ALACAKBAKIYE=case when AB>0.0 then AB else 0.0 end'
      'from('
      #9'select K.* , R.FIRMA,MASRAFAD=M.AD,'
      
        #9'BB=isnull((select isnull(sum(K2.BORC-K2.ALACAK),0.0) from KASA ' +
        'K2 where K2.HESAPTURU='#39'V'#39' and K2.HESAPID=K.HESAPID and K2.ISLEMT' +
        'ARIHI<=K.ISLEMTARIHI),0.0),'
      
        #9'AB=isnull((select isnull(sum(K2.ALACAK-K2.BORC),0.0) from KASA ' +
        'K2 where K2.HESAPTURU='#39'V'#39' and K2.HESAPID=K.HESAPID and K2.ISLEMT' +
        'ARIHI<=K.ISLEMTARIHI),0.0)'
      #9'from '
      #9'KASA K left outer join '
      #9'REHBER R on K.REHBERID=R.ID left outer join '
      #9'MASRAFGELIR M on M.ID=K.MASRAFID'
      ''
      #9'where '
      #9'HESAPTURU='#39'V'#39' and '
      #9'HESAPID=:PKKID and'
      #9'ISLEMTARIHI>=:PBasTar and'
      #9'ISLEMTARIHI<=:PBitTar'
      ') as ASD'
      'order by ISLEMTARIHI'
      ''
      '')
    Left = 811
    Top = 170
  end
  object DtsKKEkstre: TDataSource
    DataSet = TabKKEkstre
    Left = 811
    Top = 219
  end
  object PopupMenuYaz: TPopupMenu
    Left = 367
    Top = 184
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
  object frxKKEkstre: TfrxDBDataset
    UserName = 'KKEkstre'
    CloseDataSource = False
    DataSet = TabKKEkstre
    BCDToCurrency = False
    DataSetOptions = []
    Left = 813
    Top = 270
  end
  object frxKK: TfrxDBDataset
    UserName = 'KREDIKARTI'
    CloseDataSource = False
    DataSet = KREDIKARTI
    BCDToCurrency = False
    DataSetOptions = []
    Left = 650
    Top = 272
  end
  object PmKrediKarti: TPopupMenu
    Left = 510
    Top = 113
    object KKInfoMenu: TMenuItem
      Caption = 'info'
      OnClick = KKInfoMenuClick
    end
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
  end
  object tabHesapKesim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ID,KASAID,KKID,TARIH,TAKSIT=convert(varchar(10),TAKSITNO)' +
        '+'#39'/'#39'+convert(varchar(10),TAKSITSAY),TUTAR,KUR,ACIKLAMA '
      'from '
      'PLANKREDIKARTI PK'
      'where '
      'KKID=:PKKID and'
      'TARIH>:PBasTar and'
      'TARIH<:PBitTar'
      '')
    Left = 731
    Top = 162
  end
  object DtsHesapKesim: TDataSource
    DataSet = tabHesapKesim
    Left = 731
    Top = 211
  end
  object frxHesapKesim: TfrxDBDataset
    UserName = 'HesapKesim'
    CloseDataSource = False
    DataSet = tabHesapKesim
    BCDToCurrency = False
    DataSetOptions = []
    Left = 733
    Top = 262
  end
end
