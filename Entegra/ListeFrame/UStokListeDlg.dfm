object StokListeDlg: TStokListeDlg
  Left = 0
  Top = 0
  Width = 974
  Height = 513
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
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 968
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
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
      AutoSize = True
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      AutoSize = True
      Left = 105
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object DegisTus: TToolButton
      AutoSize = True
      Left = 210
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
    object ToolButton1: TToolButton
      Left = 315
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsSeparator
    end
    object AraTus: TToolButton
      AutoSize = True
      Left = 323
      Top = 0
      Caption = 'AraTus'
      Enabled = False
      ImageIndex = 21
      ImageName = 'PngImage21'
      Visible = False
      OnClick = AraTusClick
    end
    object YaziciYaz: TToolButton
      AutoSize = True
      Left = 428
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object BtnBarkodYazdir: TToolButton
      AutoSize = True
      Left = 533
      Top = 0
      Caption = 'Barkod Yazd'#305'r'
      ImageIndex = 16
      ImageName = 'PngImage15'
      OnClick = BtnBarkodYazdirClick
    end
    object ToolButton2: TToolButton
      Left = 638
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object ButtonUTS: TToolButton
      AutoSize = True
      Left = 646
      Top = 0
      Caption = #220'TS'
      ImageIndex = 29
      ImageName = 'PngImage29'
      OnClick = ButtonUTSClick
    end
  end
  object GridStok: TcxGrid
    Left = 0
    Top = 32
    Width = 974
    Height = 139
    Align = alClient
    PopupMenu = PmStok
    TabOrder = 3
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitTop = 35
    ExplicitHeight = 136
    object GridStokView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridStokViewCanFocusRecord
      OnSelectionChanged = GridStokViewSelectionChanged
      DataController.DataSource = DtsStoklar
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
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
          FieldName = 'FATURA_MATRAHI'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'KDV_TUTARI'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'FATURA_TUTARI'
        end
        item
          Format = 'Say'#305' :  ######'
          Kind = skCount
          FieldName = 'STOKADI'
          Column = GridStokViewSTOKADI
          DisplayText = 'Kay'#305't Say'#305's'#305
        end>
      DataController.Summary.SummaryGroups = <>
      FilterRow.ApplyChanges = fracImmediately
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.Footer = True
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridStokViewStylesGetContentStyle
      object GridStokViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridStokViewKOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 75
      end
      object GridStokViewSTOKADI: TcxGridDBColumn
        Caption = 'Stok Ad'#305
        DataBinding.FieldName = 'STOKADI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 252
      end
      object GridStokViewURUNNO: TcxGridDBColumn
        Caption = #220'r'#252'n No'
        DataBinding.FieldName = 'URUNNO'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewKATEGORIAD: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewTIPI: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'TIPI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokTipi
        HeaderAlignmentHorz = taCenter
        Width = 84
      end
      object GridStokViewMARKA: TcxGridDBColumn
        Caption = 'Marka'
        DataBinding.FieldName = 'MARKA'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokMarka
        HeaderAlignmentHorz = taCenter
        Width = 99
      end
      object GridStokViewMODEL: TcxGridDBColumn
        Caption = 'Model'
        DataBinding.FieldName = 'STOKMODEL'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 100
      end
      object GridStokViewGRUBU: TcxGridDBColumn
        Caption = 'Grubu'
        DataBinding.FieldName = 'GRUBU'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokGrubu
        HeaderAlignmentHorz = taCenter
        Width = 91
      end
      object GridStokViewOZELLIK: TcxGridDBColumn
        Caption = #214'zellik'
        DataBinding.FieldName = 'OZELLIK'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokOzellik
        HeaderAlignmentHorz = taCenter
        Width = 87
      end
      object GridStokViewSTOKIZLEME: TcxGridDBColumn
        Caption = #304'zleme'
        DataBinding.FieldName = 'IZLEME'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepStokIzleme
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewANABIRIM: TcxGridDBColumn
        Caption = 'Ana Birim'
        DataBinding.FieldName = 'ANABIRIM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokAnaBirim
        Visible = False
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewYERI: TcxGridDBColumn
        Caption = 'Raf'
        DataBinding.FieldName = 'HUCRE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Visible = False
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewKDV: TcxGridDBColumn
        DataBinding.FieldName = 'KDV'
        DataBinding.IsNullValueType = True
        Visible = False
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokDurum
        Visible = False
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        HeaderAlignmentHorz = taCenter
      end
      object GridStokViewSDKALAN: TcxGridDBColumn
        Caption = 'Stok'
        DataBinding.FieldName = 'SDKALAN'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.##;-,0.##'
      end
      object GridStokViewICERIK: TcxGridDBColumn
        Caption = #304#231'erik'
        DataBinding.FieldName = 'ICERIK'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepStokIcerik
      end
      object GridStokViewRECETEVAR: TcxGridDBColumn
        Caption = 'Re'#231'ete'
        DataBinding.FieldName = 'RECETEVAR'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repVarYok
        Width = 40
      end
      object GridStokViewOZELKOD: TcxGridDBColumn
        Caption = #214'zelkod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewMUHKODU: TcxGridDBColumn
        Caption = 'Muh Kodu'
        DataBinding.FieldName = 'MUHKODU'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewBIRIM2: TcxGridDBColumn
        Caption = 'Birim2'
        DataBinding.FieldName = 'BIRIM2'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokAnaBirim
      end
      object GridStokViewBIRIM2MIKTAR: TcxGridDBColumn
        Caption = 'Birim 2 Miktar'
        DataBinding.FieldName = 'BIRIM2MIKTAR'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewMINSTOK: TcxGridDBColumn
        Caption = 'Minimum Stok'
        DataBinding.FieldName = 'MINSTOK'
        DataBinding.IsNullValueType = True
      end
      object GridStokViewBILDIRIM: TcxGridDBColumn
        Caption = 'Bildirim'
        DataBinding.FieldName = 'BILDIRIM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Yok'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = #220'TS'
            Value = 2
          end>
      end
      object GridStokViewNOTLAR: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'NOTLAR'
        DataBinding.IsNullValueType = True
      end
    end
    object GridStokLevel1: TcxGridLevel
      GridView = GridStokView
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 171
    Width = 974
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = Panel1
    ExplicitWidth = 8
  end
  object Panel1: TPanel
    Left = 0
    Top = 179
    Width = 974
    Height = 334
    Align = alBottom
    TabOrder = 1
    object PageControl1: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 1
      Top = 1
      Width = 787
      Height = 332
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = tshFiyatlar
      Properties.CustomButtons.Buttons = <>
      Properties.MultiLine = True
      OnPageChanging = PageControl1PageChanging
      ClientRectBottom = 328
      ClientRectLeft = 4
      ClientRectRight = 783
      ClientRectTop = 27
      object tshFiyatlar: TcxTabSheet
        Caption = 'Fiyatland'#305'rma'
        ImageIndex = 34
        object GridFiyat: TcxGrid
          Left = 0
          Top = 30
          Width = 779
          Height = 271
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridFiyatView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridFiyatViewCanFocusRecord
            DataController.DataSource = DtsFiyat
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridFiyatViewFIYATADI: TcxGridDBColumn
              Caption = 'Fiyat Ad'#305
              DataBinding.FieldName = 'FIYATAD'
              DataBinding.IsNullValueType = True
              Width = 151
            end
            object GridFiyatViewBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
            end
            object GridFiyatViewFIYAT: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYAT'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.000000;-,0.000000'
              Width = 73
            end
            object GridFiyatViewKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Width = 68
            end
            object GridFiyatViewKDVDURUM: TcxGridDBColumn
              Caption = 'KDV Durum'
              DataBinding.FieldName = 'KDVDURUM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepKDVDurum
              Width = 97
            end
            object GridFiyatViewDEGISTIRMETARIHI: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'DEGISTIRMETARIHI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxDateEditProperties'
              Properties.ReadOnly = True
            end
          end
          object GridFiyatLevel1: TcxGridLevel
            GridView = GridFiyatView
          end
        end
        object JvNavPanelHeader5: TJvNavPanelHeader
          Left = 0
          Top = 0
          Width = 779
          Height = 30
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
          object cxLabel4: TcxLabel
            Left = 3
            Top = 4
            Caption = 'Fiyat Se'#231'imi :'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object RadioFiyatSatis: TcxRadioButton
            Tag = -1007
            Left = 94
            Top = 7
            Width = 58
            Height = 17
            Caption = 'Sat'#305#351
            Checked = True
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            TabStop = True
            OnClick = RadioFiyatSatisClick
            GroupIndex = 12
            LookAndFeel.Kind = lfFlat
            LookAndFeel.NativeStyle = True
            Transparent = True
          end
          object RadioFiyatAlis: TcxRadioButton
            Tag = -1008
            Left = 154
            Top = 7
            Width = 78
            Height = 17
            Caption = 'Al'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            OnClick = RadioFiyatSatisClick
            GroupIndex = 12
            LookAndFeel.Kind = lfFlat
            LookAndFeel.NativeStyle = True
            Transparent = True
          end
        end
      end
      object TabYorumMedya: TcxTabSheet
        Caption = 'Yorum / Medya'
        ImageIndex = 38
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Panel4: TPanel
          Left = 0
          Top = 260
          Width = 779
          Height = 41
          Align = alBottom
          TabOrder = 0
          object MemoChat: TcxRichEdit
            Left = 1
            Top = 1
            Align = alClient
            Properties.ScrollBars = ssVertical
            TabOrder = 1
            Height = 39
            Width = 631
          end
          object BtnMesajGonder: TcxButton
            Left = 632
            Top = 1
            Width = 85
            Height = 39
            Align = alRight
            OptionsImage.ImageIndex = 39
            OptionsImage.Images = Tablo.cxImageList1
            TabOrder = 0
            OnClick = BtnMesajGonderClick
          end
          object BtnDosyaGonder: TcxButton
            Left = 717
            Top = 1
            Width = 61
            Height = 39
            Align = alRight
            DropDownMenu = YorumAtacMenu
            Kind = cxbkDropDown
            OptionsImage.ImageIndex = 38
            OptionsImage.Images = Tablo.cxImageList1
            TabOrder = 2
          end
        end
        object labelFileName: TcxLabel
          Left = 0
          Top = 240
          ParentCustomHint = False
          Align = alBottom
          ParentColor = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = False
          Style.Edges = [bLeft, bRight]
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.Shadow = False
          Style.IsFontAssigned = True
          Properties.Alignment.Horz = taRightJustify
          Transparent = True
          Visible = False
          ExplicitTop = 239
          AnchorX = 779
        end
        object GridYorum: TcxGrid
          Left = 0
          Top = 0
          Width = 779
          Height = 240
          Align = alClient
          TabOrder = 2
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridYorumDBCardView1: TcxGridDBCardView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridYorumDBCardView1CellDblClick
            DataController.DataSource = DtsYorum
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            LayoutDirection = ldVertical
            OptionsView.CardBorderWidth = 1
            OptionsView.CardIndent = 2
            OptionsView.CardWidth = 900
            OptionsView.CategoryIndent = 1
            OptionsView.CategorySeparatorWidth = 1
            OptionsView.CellAutoHeight = True
            OptionsView.CellTextMaxLineCount = 5
            Styles.Content = Tablo.cxStyle6
            Styles.CardBorder = Tablo.cxStyle19
            object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Position.Width = 120
            end
            object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YAZAN'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
            end
            object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
              DataBinding.FieldName = 'ATAC'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repFileExtensionList
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 25
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
              DataBinding.FieldName = 'DOKUMANAD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 300
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YORUM'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxRichEditProperties'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Styles.Content = Tablo.cxStyle12
              Styles.CategoryRow = Tablo.cxStyle4
            end
          end
          object GridYorumLevel1: TcxGridLevel
            GridView = GridYorumDBCardView1
          end
        end
      end
      object tshStokDurum: TcxTabSheet
        Caption = 'Stok Durum'
        ImageIndex = 12
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Panel8: TPanel
          Left = 0
          Top = 0
          Width = 779
          Height = 27
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object cxProgressBar1: TcxProgressBar
            Left = 4
            Top = 1
            Properties.BarStyle = cxbsGradient
            Properties.BeginColor = 8454143
            Properties.PeakColor = 8454143
            Properties.ShowPeak = True
            TabOrder = 0
            Visible = False
            Width = 216
          end
          object cbSifirKalanGoster: TcxCheckBox
            Left = 226
            Top = 1
            Caption = 'S'#305'f'#305'r(0) Kalan G'#246'ster'
            Properties.NullStyle = nssUnchecked
            TabOrder = 1
            Transparent = True
            OnClick = cbSifirKalanGosterClick
          end
          object cbSKTsizGrupla: TcxCheckBox
            Left = 401
            Top = 2
            Caption = 'SKTsiz Grupla'
            Properties.NullStyle = nssUnchecked
            TabOrder = 2
            Transparent = True
            Visible = False
            OnClick = cbSifirKalanGosterClick
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 27
          Width = 779
          Height = 274
          Align = alClient
          Caption = 'Panel2'
          TabOrder = 1
          object GridStokDurum: TcxGrid
            Left = 1
            Top = 1
            Width = 441
            Height = 272
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridStokDurumView: TcxGridDBTableView
              PopupMenu = pmStokDurum
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridStokDurumViewCanFocusRecord
              DataController.DataSource = dtsStokDurum
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = '0;'
                  Kind = skSum
                  FieldName = 'GIREN'
                  Column = clmDurumGiren
                  DisplayText = '0;'
                end
                item
                  Format = '0;'
                  Kind = skSum
                  FieldName = 'CIKAN'
                  Column = clmDurumCikan
                  DisplayText = '0;'
                end
                item
                  Format = '0;'
                  Kind = skSum
                  FieldName = 'KALAN'
                  Column = clmDurumKalan
                  DisplayText = '0;'
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.Deleting = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.HideSelection = True
              OptionsView.Footer = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object clmDurumDepoAdi: TcxGridDBColumn
                Caption = 'Depo Ad'#305
                DataBinding.FieldName = 'DEPOADI'
                DataBinding.IsNullValueType = True
                Width = 156
              end
              object clmDurumGiren: TcxGridDBColumn
                Caption = 'Giren'
                DataBinding.FieldName = 'GIREN'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyAdetGenel
              end
              object clmDurumCikan: TcxGridDBColumn
                Caption = #199#305'kan'
                DataBinding.FieldName = 'CIKAN'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyAdetGenel
              end
              object clmDurumKalan: TcxGridDBColumn
                Caption = 'Kalan'
                DataBinding.FieldName = 'KALAN'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyAdetGenel
                Width = 59
              end
              object clmKritikSeviye: TcxGridDBColumn
                Caption = 'Kritik Seviye'
                DataBinding.FieldName = 'KSEVIYE'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyAdetGenel
                Visible = False
                Width = 71
              end
              object GridStokDurumViewSUBEID: TcxGridDBColumn
                Caption = #350'ube'
                DataBinding.FieldName = 'SUBEID'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                Options.Editing = False
              end
              object GridStokDurumViewMaksimum: TcxGridDBColumn
                Caption = 'Maksimum'
                DataBinding.FieldName = 'MAKSIMUM'
                DataBinding.IsNullValueType = True
              end
              object GridStokDurumViewMinimum: TcxGridDBColumn
                Caption = 'Minimum'
                DataBinding.FieldName = 'MINIMUM'
                DataBinding.IsNullValueType = True
              end
              object GridStokDurumViewKritik: TcxGridDBColumn
                Caption = 'Kritik'
                DataBinding.FieldName = 'KRITIK'
                DataBinding.IsNullValueType = True
              end
            end
            object GridStokDurumLevel1: TcxGridLevel
              GridView = GridStokDurumView
            end
          end
          object PageControl_SeriLot: TcxPageControl
            Left = 442
            Top = 1
            Width = 336
            Height = 272
            Align = alRight
            TabOrder = 1
            Properties.ActivePage = cxTabSheet1
            Properties.CustomButtons.Buttons = <>
            ClientRectBottom = 268
            ClientRectLeft = 4
            ClientRectRight = 332
            ClientRectTop = 27
            object cxTabSheet1: TcxTabSheet
              Caption = 'Da'#287#305'l'#305'm'
              ImageIndex = 19
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object cxGrid2: TcxGrid
                Left = 0
                Top = 0
                Width = 328
                Height = 241
                Align = alClient
                TabOrder = 0
                LevelTabs.CaptionAlignment = taLeftJustify
                LookAndFeel.ScrollbarMode = sbmClassic
                object cxGrid1DBTableViewDurum: TcxGridDBTableView
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  DataController.DataSource = DtsStokDurumDetay
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <>
                  DataController.Summary.SummaryGroups = <>
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.Deleting = False
                  OptionsData.Editing = False
                  OptionsData.Inserting = False
                  OptionsView.GroupByBox = False
                  object cxGrid1DBTableViewDurumTIP: TcxGridDBColumn
                    Caption = 'Tip'
                    DataBinding.FieldName = 'TIP'
                    DataBinding.IsNullValueType = True
                    Width = 99
                  end
                  object cxGrid1DBTableViewDurumADET: TcxGridDBColumn
                    Caption = 'Miktar'
                    DataBinding.FieldName = 'ADET'
                    DataBinding.IsNullValueType = True
                    RepositoryItem = Tablo.RepCurrencyAdetGenel
                    Width = 82
                  end
                  object cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn
                    Caption = 'Birim'
                    DataBinding.FieldName = 'BIRIM'
                    DataBinding.IsNullValueType = True
                    RepositoryItem = Tablo.repStokAnaBirim
                    Width = 42
                  end
                end
                object cxGrid1Level2: TcxGridLevel
                  Caption = 'Depo Durumu'
                  GridView = cxGrid1DBTableViewDurum
                end
              end
            end
            object TabSheetSeriLot: TcxTabSheet
              Caption = 'Seri / Lot'
              ImageIndex = 19
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object GridSeriLot: TcxGrid
                Left = 0
                Top = 27
                Width = 328
                Height = 214
                Align = alClient
                TabOrder = 0
                LevelTabs.CaptionAlignment = taLeftJustify
                object GridSeriLotView: TcxGridDBTableView
                  OnDblClick = SeriLotDuzenleClick
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  OnCanFocusRecord = GridSeriLotViewCanFocusRecord
                  DataController.DataSource = DtsSeriLotDurum
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Format = ',0.0000;-,0.0000'
                      Kind = skSum
                      FieldName = 'KALAN'
                      Column = GridSeriLotViewKALAN
                      DisplayText = ',0.0000;-,0.0000'
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsSelection.HideFocusRectOnExit = False
                  OptionsSelection.UnselectFocusedRecordOnExit = False
                  OptionsView.Footer = True
                  OptionsView.GroupByBox = False
                  object GridSeriLotViewSTOKID: TcxGridDBColumn
                    DataBinding.FieldName = 'STOKID'
                    DataBinding.IsNullValueType = True
                    Visible = False
                  end
                  object GridSeriLotViewDEPOID: TcxGridDBColumn
                    DataBinding.FieldName = 'DEPOID'
                    DataBinding.IsNullValueType = True
                    Visible = False
                  end
                  object GridSeriLotViewSERINO: TcxGridDBColumn
                    Caption = 'Seri No'
                    DataBinding.FieldName = 'SERINO'
                    DataBinding.IsNullValueType = True
                    Width = 70
                  end
                  object GridSeriLotViewLOTNO: TcxGridDBColumn
                    Caption = 'Lot No'
                    DataBinding.FieldName = 'LOTNO'
                    DataBinding.IsNullValueType = True
                    Width = 70
                  end
                  object GridSeriLotViewURT: TcxGridDBColumn
                    Caption = #220'RT'
                    DataBinding.FieldName = 'URT'
                    DataBinding.IsNullValueType = True
                    Width = 60
                  end
                  object GridSeriLotViewSKT: TcxGridDBColumn
                    DataBinding.FieldName = 'SKT'
                    DataBinding.IsNullValueType = True
                    Width = 60
                  end
                  object GridSeriLotViewKALAN: TcxGridDBColumn
                    Caption = 'Miktar'
                    DataBinding.FieldName = 'KALAN'
                    DataBinding.IsNullValueType = True
                    Width = 70
                  end
                end
                object cxGridLevel2: TcxGridLevel
                  Caption = 'Depo Durumu'
                  GridView = GridSeriLotView
                end
              end
              object ToolBar2: TToolBar
                AlignWithMargins = True
                Left = 3
                Top = 3
                Width = 322
                Height = 24
                Margins.Bottom = 0
                AutoSize = True
                ButtonWidth = 66
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
                object SeriLotDuzenle: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'D'#252'zenle'
                  ImageIndex = 7
                  ImageName = 'PngImage7'
                  OnClick = SeriLotDuzenleClick
                end
              end
            end
          end
        end
      end
      object tshHareketler: TcxTabSheet
        Caption = 'Hareketler'
        ImageIndex = 32
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridHareket: TcxGrid
          Left = 0
          Top = 0
          Width = 509
          Height = 301
          Align = alClient
          PopupMenu = PmStokHareket
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object StokHareketler: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = StokHareketlerCanFocusRecord
            OnCellDblClick = StokHareketlerCellDblClick
            DataController.DataSource = DtsStokHareketler
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',#;-,#'
                Kind = skSum
                Position = spFooter
                FieldName = 'MIKTAR'
                Column = StokHareketlerMIKTAR
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skAverage
                Position = spFooter
                FieldName = 'BIRIMFIYAT'
                Column = StokHareketlerBIRIMFIYAT
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'TUTAR'
                Column = StokHareketlerTUTAR
              end
              item
                Format = ',#;-,#'
                Kind = skSum
                Position = spFooter
                FieldName = 'GIREN'
                Column = StokHareketlerGIREN
              end
              item
                Format = ',#;-,#'
                Kind = skSum
                Position = spFooter
                FieldName = 'CIKAN'
                Column = StokHareketlerCIKAN
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',#;-,#'
                Kind = skSum
                FieldName = 'MIKTAR'
                Column = StokHareketlerMIKTAR
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skAverage
                FieldName = 'BIRIMFIYAT'
                Column = StokHareketlerBIRIMFIYAT
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                FieldName = 'TUTAR'
                Column = StokHareketlerTUTAR
              end
              item
                Format = ',#;-,#'
                Kind = skSum
                FieldName = 'GIREN'
                Column = StokHareketlerGIREN
              end
              item
                Format = ',#;-,#'
                Kind = skSum
                FieldName = 'CIKAN'
                Column = StokHareketlerCIKAN
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideFocusRectOnExit = False
            OptionsSelection.UnselectFocusedRecordOnExit = False
            OptionsView.GroupFooterMultiSummaries = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.GroupSummaryLayout = gslAlignWithColumnsAndDistribute
            OptionsView.Indicator = True
            object StokHareketlerOLAY: TcxGridDBColumn
              Caption = 'Olay'
              DataBinding.FieldName = 'OLAY'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerFIRMA: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              Width = 165
            end
            object StokHareketlerURUNID: TcxGridDBColumn
              Caption = #220'r'#252'n ID'
              DataBinding.FieldName = 'URUNID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokHareketlerFATBASID: TcxGridDBColumn
              Caption = 'Belge ID'
              DataBinding.FieldName = 'FATBASID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokHareketlerTURAD: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TURAD'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerFATURATARIH: TcxGridDBColumn
              Caption = 'Belge Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerFATURASERI: TcxGridDBColumn
              Caption = 'Belge Seri'
              DataBinding.FieldName = 'FATURASERI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokHareketlerFATURANO: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'FATURANO'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerREHBERID: TcxGridDBColumn
              Caption = 'Rehber ID'
              DataBinding.FieldName = 'REHBERID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokHareketlerDEPO: TcxGridDBColumn
              Caption = 'Depo'
              DataBinding.FieldName = 'DEPO'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepStokDepolarTumu
            end
            object StokHareketlerADET: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
            end
            object StokHareketlerGIREN: TcxGridDBColumn
              AlternateCaption = '*'
              Caption = 'Giren'
              DataBinding.FieldName = 'GIREN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              HeaderGlyphAlignmentHorz = taRightJustify
            end
            object StokHareketlerCIKAN: TcxGridDBColumn
              Caption = #199#305'kan'
              DataBinding.FieldName = 'CIKAN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              HeaderGlyphAlignmentHorz = taRightJustify
            end
            object StokHareketlerKALAN: TcxGridDBColumn
              Caption = 'Kalan'
              DataBinding.FieldName = 'KALAN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
            end
            object StokHareketlerMIKTAR: TcxGridDBColumn
              Caption = 'Miktar'
              DataBinding.FieldName = 'MIKTAR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              Visible = False
            end
            object StokHareketlerBIRIMFIYAT: TcxGridDBColumn
              Caption = 'Birim Fiyat'
              DataBinding.FieldName = 'BIRIMFIYAT'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
            end
            object StokHareketlerBIRIMMALIYET: TcxGridDBColumn
              Caption = 'T.Maliyet'
              DataBinding.FieldName = 'MALIYET'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
            end
            object StokHareketlerTUTAR: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyGenel
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
            end
            object StokHareketlerKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
            end
            object StokHareketlerEKMALIYET: TcxGridDBColumn
              Caption = 'Ek T.Maliyet'
              DataBinding.FieldName = 'EKMALIYET'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = StokHareketler
          end
        end
        object PageHareketSeriLot: TcxPageControl
          Left = 509
          Top = 0
          Width = 270
          Height = 301
          Align = alRight
          TabOrder = 1
          Visible = False
          Properties.ActivePage = cxTabSheet4
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 297
          ClientRectLeft = 4
          ClientRectRight = 266
          ClientRectTop = 27
          object cxTabSheet4: TcxTabSheet
            Caption = 'Seri / Lot'
            ImageIndex = 19
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object GridSeriLotHareket: TcxGrid
              Left = 0
              Top = 0
              Width = 262
              Height = 270
              Align = alClient
              TabOrder = 0
              LevelTabs.CaptionAlignment = taLeftJustify
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridSeriLotHareketView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsSeriLotHareket
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Kind = skSum
                    FieldName = 'ADET'
                    Column = cxGridDBColumn9
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsView.Footer = True
                OptionsView.GroupByBox = False
                object cxGridDBColumn4: TcxGridDBColumn
                  DataBinding.FieldName = 'STOKID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object cxGridDBColumn5: TcxGridDBColumn
                  DataBinding.FieldName = 'DEPOID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Seri No'
                  DataBinding.FieldName = 'SERINO'
                  DataBinding.IsNullValueType = True
                  Width = 70
                end
                object cxGridDBColumn7: TcxGridDBColumn
                  Caption = 'Lot No'
                  DataBinding.FieldName = 'LOTNO'
                  DataBinding.IsNullValueType = True
                  Width = 70
                end
                object GridSeriLotHareketViewColumn1: TcxGridDBColumn
                  Caption = 'Depo'
                  DataBinding.FieldName = 'DEPOADI'
                  DataBinding.IsNullValueType = True
                end
                object cxGridDBColumn9: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  DataBinding.IsNullValueType = True
                  Width = 70
                end
              end
              object cxGridLevel4: TcxGridLevel
                Caption = 'Depo Durumu'
                GridView = GridSeriLotHareketView
              end
            end
          end
        end
      end
      object TshEsDegerUrun: TcxTabSheet
        Caption = 'E'#351'de'#287'er '#220'r'#252'n'
        ImageIndex = 12
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 773
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
          object EUYeni: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = EUYeniClick
          end
          object EuSil: TToolButton
            Left = 48
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = EuSilClick
          end
        end
        object StokEsdeger: TcxGrid
          Left = 0
          Top = 27
          Width = 779
          Height = 274
          Align = alClient
          PopupMenu = PopupMenuEsdeger
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object StokEsdegerTV: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsStokEsdeger
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object StokEsdegerTVTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepStokEsdegerTur
            end
            object StokEsdegerTVKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Width = 94
            end
            object StokEsdegerTVSTOKADI: TcxGridDBColumn
              Caption = 'Stok Ad'#305
              DataBinding.FieldName = 'STOKADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 255
            end
            object StokEsdegerTVACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 233
            end
          end
          object cxGridLevel6: TcxGridLevel
            GridView = StokEsdegerTV
          end
        end
      end
    end
    object DateHarBas: TcxDateEdit
      Left = 446
      Top = 2
      Properties.ImmediatePost = True
      Properties.ShowTime = False
      Properties.OnEditValueChanged = DateHarBasPropertiesEditValueChanged
      TabOrder = 2
      Width = 87
    end
    object ComboDepo: TcxImageComboBox
      Left = 705
      Top = 1
      Properties.ImmediatePost = True
      Properties.Items = <>
      Properties.OnCloseUp = DateHarBasPropertiesEditValueChanged
      TabOrder = 4
      Width = 90
    end
    object cxLabel1: TcxLabel
      Left = 398
      Top = 4
      Caption = 'Ba'#351'lama:'
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 537
      Top = 3
      Caption = 'Biti'#351':'
      Transparent = True
    end
    object DateHarBit: TcxDateEdit
      Left = 568
      Top = 2
      Properties.ImmediatePost = True
      Properties.ShowTime = False
      Properties.OnEditValueChanged = DateHarBasPropertiesEditValueChanged
      TabOrder = 3
      Width = 88
    end
    object cxLabel3: TcxLabel
      Left = 672
      Top = 3
      Caption = 'Depo:'
      Transparent = True
    end
    object PanelFiyatAltSag: TPanel
      Left = 788
      Top = 1
      Width = 185
      Height = 332
      Align = alRight
      Caption = 'PanelFiyatAltSag'
      TabOrder = 1
      object ToolBar4: TToolBar
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 177
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
        TabOrder = 0
        Transparent = True
        object ResimYapistirTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yap'#305#351't'#305'r'
          ImageIndex = 10
          ImageName = 'PngImage10'
          OnClick = ResimYapistirTusClick
        end
        object ToolButton5: TToolButton
          Left = 75
          Top = 0
          Width = 8
          Caption = 'ToolButton6'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object ResimDosyadanTus: TToolButton
          Left = 83
          Top = 0
          Caption = 'Dosyadan'
          ImageIndex = 4
          ImageName = 'PngImage4'
          OnClick = ResimDosyadanTusClick
        end
      end
      object LogoResim: TcxDBImage
        Left = 1
        Top = 28
        HelpType = htKeyword
        Align = alClient
        DataBinding.DataField = 'RESIM'
        DataBinding.DataSource = DtsResim
        Properties.Caption = 'Resim s'#252'r'#252'kleyip buraya b'#305'rak'#305'n'
        Properties.GraphicClassName = 'TdxSmartImage'
        Style.BorderColor = clBtnFace
        Style.Color = clBtnFace
        Style.Edges = []
        StyleDisabled.BorderStyle = ebsNone
        StyleFocused.BorderStyle = ebsNone
        TabOrder = 1
        OnClick = LogoResimClick
        Height = 303
        Width = 183
      end
    end
    object cxLabel5: TcxLabel
      Left = 801
      Top = 2
      Caption = 'T'#252'r:'
      Transparent = True
    end
    object ComboHareketTur: TcxImageComboBox
      Left = 824
      Top = 2
      EditValue = 1
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = 'Giri'#351' / '#199#305'k'#305#351
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Maliyet'
          Value = 2
        end>
      Properties.OnCloseUp = DateHarBasPropertiesEditValueChanged
      TabOrder = 9
      Width = 90
    end
  end
  object DtsStoklar: TDataSource
    DataSet = STOKLAR
    Left = 137
    Top = 59
  end
  object STOKLAR: TFDQuery
    BeforeOpen = STOKLARBeforeOpen
    AfterOpen = STOKLARAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  TOP 200    '
      
        ' S.ID, S.KOD, S.STOKADI, K.AD, S.TIPI, S.MARKA, S.GRUBU, S.OZELL' +
        'IK,S.ICERIK, S.OZELKOD,S.SUBEID,'
      
        ' S.MUHKODU, S.ANABIRIM, S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.K' +
        'DV, S.DURUM,'
      ' S.IZLEME, S.NOTLAR,StokModel.ANAHTAR AS STOKMODEL,'#9#9
      ' SDGIREN = ISNULL( SUM( SD.GIREN ),0),'
      ' SDCIKAN = ISNULL( SUM( SD.CIKAN ),0),'
      ' SDKALAN =ISNULL( SUM(SD.KALAN),0),'
      
        'BARKOD=(select top 1 SB.BARKOD from STOKBARKOD SB where SB.STOKI' +
        'D=S.ID and SB.VARSAYILAN=1),'
      
        ' SIPARISTOP=(select case When (SUM( CASE WHEN FB.TUR IN (14,15,1' +
        '6) THEN MIKTAR ELSE 0 END )-ISNULL( (select SUM(ISNULL(KALAN,0))' +
        ' FROM STOKDURUM WHERE STOKID = S.ID),0)) > 0 then '
      '((SUM( CASE WHEN FB.TUR IN (14,15,16) THEN MIKTAR ELSE 0 END )-'
      
        'ISNULL( (select SUM(ISNULL(KALAN,0)) FROM STOKDURUM WHERE STOKID' +
        ' = S.ID),0))/1) else 0 END'
      
        'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID where ' +
        'F.TUR=1 and F.URUNID=S.ID and FB.TUR IN (14,15,16))'
      '--EKALANLAR--'
      'FROM STOKLAR S'
      ' LEFT OUTER JOIN KATEGORI K on K.ID=S.KATEGORI'
      
        ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL A' +
        'ND StokModel.BOLUM=convert(int,'#39'-2701'#39'+convert(varchar(10),S.MAR' +
        'KA))'
      ' LEFT OUTER JOIN STOKDURUM SD on S.ID=SD.STOKID'
      ' LEFT OUTER JOIN DEPOLAR D on D.ID=SD.DEPOID and D.SUBEID=-1'
      
        ' LEFT OUTER JOIN STOKBARKOD StokBarkod on S.ID=StokBarkod.STOKID' +
        ' and StokBarkod.VARSAYILAN=1'
      ''
      
        'group by S.ID, S.KOD, S.STOKADI,K.AD, S.ICERIK, S.TIPI, S.MARKA,' +
        ' S.MODEL, S.GRUBU, S.OZELLIK, S.OZELKOD, S.MUHKODU, S.ANABIRIM, ' +
        'S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM, S.IZLEME, S' +
        '.NOTLAR, StokModel.ANAHTAR ,S.SUBEID'
      ''
      '')
    Left = 36
    Top = 58
  end
  object STOKFIYAT: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ' Select distinct ID, STOKID,FIYATADI,BIRIM,'
      
        'FIYATAD=(select top 1 case when DEGER=-2 then ANAHTAR +'#39' (Son'#39'+c' +
        'ast(PAKETID as varchar(5))+'#39')'#39
      
        'else ANAHTAR end from GENINI where BOLUM=:Par1 and DEGER=FIYATAD' +
        'I),'
      
        'FIYAT,KUR,KDVDURUM,DEGISTIRMETARIHI from STOKFIYAT Where STOKID=' +
        ':Par2 and SATIS=:Par3')
    Left = 34
    Top = 244
    ParamData = <
      item
        Name = 'Par1'
        DataType = ftWideString
        ParamType = ptInput
        Size = 5
        Value = '-1007'
      end
      item
        Name = 'Par2'
        DataType = ftWideString
        ParamType = ptInput
        Size = 2
        Value = '17'
      end
      item
        Name = 'Par3'
        DataType = ftWideString
        ParamType = ptInput
        Size = 1
        Value = '1'
      end>
  end
  object DtsFiyat: TDataSource
    DataSet = STOKFIYAT
    Left = 104
    Top = 214
  end
  object tabStokDurum: TFDQuery
    AfterOpen = tabStokDurumAfterOpen
    BeforeClose = tabStokDurumBeforeClose
    AfterClose = tabStokDurumAfterClose
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  STOKID=S.ID, DEPOID=D.ID, D.DEPOADI, SD.GIREN, SD.CIKAN,' +
        ' SD.KALAN, SS.MAKSIMUM,SS.MINIMUM,SS.KRITIK,D.SUBEID'
      'FROM uv_Stok_StokDurum SD INNER JOIN'
      '     DEPOLAR D ON SD.STOKDEPOID = D.ID INNER JOIN'
      '     STOKLAR S ON SD.URUNID = S.ID INNER JOIN'
      '     STOKSEVIYE SS ON SS.DEPOID=SD.STOKDEPOID'
      'WHERE'
      '    S.ID = :PSTOKID'
      '    AND D.DURUM = 1    ')
    Left = 330
    Top = 205
    ParamData = <
      item
        Name = 'PSTOKID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object dtsStokDurum: TDataSource
    DataSet = tabStokDurum
    Left = 363
    Top = 112
  end
  object pmStokDurum: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = pmStokDurumPopup
    Left = 164
    Top = 427
    object KritikSeviyeMiktarnGiriniz1: TMenuItem
      Caption = 'Seviye Miktarlar'#305'n'#305' Gir'
      ImageIndex = 30
      OnClick = KritikSeviyeMiktarnGiriniz1Click
    end
    object DetayIzlemeMenu: TMenuItem
      Caption = 'Detay '#304'zleme Ekran'#305' A'#231
      ImageIndex = 22
      Visible = False
      OnClick = DetayIzlemeMenuClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object BuUrununstokdurumunugncelle1: TMenuItem
      Caption = 'Bu '#252'r'#252'n'#252'n stok durumunu g'#252'ncelle'
      ImageIndex = 12
      OnClick = BuUrununstokdurumunugncelle1Click
    end
    object Btnrnlerinstokdurumlarngncelle1: TMenuItem
      Caption = 'B'#252't'#252'n '#252'r'#252'nlerin stok durumlar'#305'n'#305' g'#252'ncelle'
      ImageIndex = 12
      OnClick = Btnrnlerinstokdurumlarngncelle1Click
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 204
    Top = 96
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
  object frxStokListe: TfrxDBDataset
    UserName = 'STOKLISTE'
    CloseDataSource = False
    DataSet = STOKLAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 311
    Top = 67
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'KOD'
        FieldAlias = 'KOD'
      end
      item
        FieldName = 'STOKADI'
        FieldAlias = 'STOKADI'
      end
      item
        FieldName = 'AD'
        FieldAlias = 'AD'
      end
      item
        FieldName = 'TIPI'
        FieldAlias = 'TIPI'
      end
      item
        FieldName = 'MARKA'
        FieldAlias = 'MARKA'
      end
      item
        FieldName = 'GRUBU'
        FieldAlias = 'GRUBU'
      end
      item
        FieldName = 'OZELLIK'
        FieldAlias = 'OZELLIK'
      end
      item
        FieldName = 'ICERIK'
        FieldAlias = 'ICERIK'
      end
      item
        FieldName = 'OZELKOD'
        FieldAlias = 'OZELKOD'
      end
      item
        FieldName = 'SUBEID'
        FieldAlias = 'SUBEID'
      end
      item
        FieldName = 'MUHKODU'
        FieldAlias = 'MUHKODU'
      end
      item
        FieldName = 'ANABIRIM'
        FieldAlias = 'ANABIRIM'
      end
      item
        FieldName = 'BIRIM2'
        FieldAlias = 'BIRIM2'
      end
      item
        FieldName = 'BIRIM2MIKTAR'
        FieldAlias = 'BIRIM2MIKTAR'
      end
      item
        FieldName = 'MINSTOK'
        FieldAlias = 'MINSTOK'
      end
      item
        FieldName = 'KDV'
        FieldAlias = 'KDV'
      end
      item
        FieldName = 'DURUM'
        FieldAlias = 'DURUM'
      end
      item
        FieldName = 'IZLEME'
        FieldAlias = 'IZLEME'
      end
      item
        FieldName = 'NOTLAR'
        FieldAlias = 'NOTLAR'
      end
      item
        FieldName = 'STOKMODEL'
        FieldAlias = 'STOKMODEL'
      end
      item
        FieldName = 'SDGIREN'
        FieldAlias = 'SDGIREN'
      end
      item
        FieldName = 'SDCIKAN'
        FieldAlias = 'SDCIKAN'
      end
      item
        FieldName = 'SDKALAN'
        FieldAlias = 'SDKALAN'
      end
      item
        FieldName = 'BARKOD'
        FieldAlias = 'BARKOD'
      end
      item
        FieldName = 'SIPARISTOP'
        FieldAlias = 'SIPARISTOP'
      end>
  end
  object PmStok: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PmStokPopup
    Left = 183
    Top = 127
    object StokInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = StokInfoMenuClick
    end
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object UretimIslemleriMenu: TMenuItem
      Caption = #220'retim '#304#351'lemleri'
      ImageIndex = 15
      object YeniReceteOlusturMenu: TMenuItem
        Caption = 'Yeni Re'#231'ete Olu'#351'tur'
        ImageIndex = 0
        OnClick = YeniReceteOlusturMenuClick
      end
      object BaskaStoktanKopyalaMenu: TMenuItem
        Caption = 'Ba'#351'ka Stoktan Kopyala'
        ImageIndex = 10
        OnClick = BaskaStoktanKopyalaMenuClick
      end
      object ReceteyiDuzenleMenu: TMenuItem
        Caption = 'Re'#231'eteyi D'#252'zenle'
        ImageIndex = 7
        OnClick = ReceteyiDuzenleMenuClick
      end
      object ReceteyiSilMenu: TMenuItem
        Caption = 'Re'#231'eteyi Sil'
        ImageIndex = 1
        OnClick = ReceteyiSilMenuClick
      end
    end
    object CoKullanlanlarMenu: TMenuItem
      Caption = #199'ok Sat'#305'lan '#220'r'#252'nler'
      ImageIndex = 12
      object CoKullanlanlarEkleMenu: TMenuItem
        Tag = -2319
        Caption = 'Listeye Ekle'
        ImageIndex = 32
        OnClick = CoKullanlanlarEkleMenuClick
      end
      object CoKullanlanlarSilMenu: TMenuItem
        Tag = -2319
        Caption = 'Listeden '#199#305'kar'
        ImageIndex = 32
        OnClick = CoKullanlanlarSilMenuClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object CokKullanlanlarListeleMenu: TMenuItem
        Tag = -2319
        Caption = #199'ok Kullan'#305'lanlar'#305' Listele'
        ImageIndex = 32
        OnClick = CokKullanlanlarListeleMenuClick
      end
    end
    object CokSatilanRestMenu: TMenuItem
      Caption = #199'ok Sat'#305'lan Rest/Cafe'
      ImageIndex = 15
      object ListeyeEkle1: TMenuItem
        Tag = -2318
        Caption = 'Listeye Ekle'
        ImageIndex = 32
        OnClick = CoKullanlanlarEkleMenuClick
      end
      object Listedenkar1: TMenuItem
        Tag = -2318
        Caption = 'Listeden '#199#305'kar'
        ImageIndex = 32
        OnClick = CoKullanlanlarSilMenuClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object okKullanlanlarListele1: TMenuItem
        Tag = -2318
        Caption = #199'ok Kullan'#305'lanlar'#305' Listele'
        ImageIndex = 32
        OnClick = CokKullanlanlarListeleMenuClick
      end
    end
    object Barkodlemleri1: TMenuItem
      Caption = 'Barkod '#304#351'lemleri'
      ImageIndex = 15
      object BarkodsuzrnleriListele1: TMenuItem
        Caption = 'Barkodsuz '#220'r'#252'nleri Listele'
        ImageIndex = 32
        OnClick = BarkodsuzrnleriListele1Click
      end
      object SeilirnlereBarkodOlutur1: TMenuItem
        Caption = 'Se'#231'ili '#220'r'#252'nlere Barkod Olu'#351'tur'
        ImageIndex = 12
        OnClick = SeilirnlereBarkodOlutur1Click
      end
    end
    object Servislemleri1: TMenuItem
      Caption = 'Servis '#304#351'lemleri'
      ImageIndex = 15
      object EkipmanListesineEkle1: TMenuItem
        Caption = 'Ekipman Listesine Ekle'
        ImageIndex = 32
        OnClick = EkipmanListesineEkle1Click
      end
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object ExceldenVeriAlMenu: TMenuItem
      Caption = 'Excelden Veri Al'
      ImageIndex = 32
      OnClick = ExceldenVeriAlMenuClick
    end
  end
  object TabStokHareketler: TFDQuery
    AfterScroll = TabStokHareketlerAfterScroll
    Connection = Tablo.FDCnn
    Left = 173
    Top = 185
  end
  object DtsStokHareketler: TDataSource
    DataSet = TabStokHareketler
    Left = 273
    Top = 138
  end
  object TabStokDurumDetay: TFDQuery
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'select * from fn_StokDurumDetay(:PStokID,:PDepoID)')
    Left = 427
    Top = 141
    ParamData = <
      item
        Name = 'PStokID'
        DataType = ftWideString
        Size = 4
        Value = '1407'
      end
      item
        Name = 'PDepoID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object DtsStokDurumDetay: TDataSource
    DataSet = TabStokDurumDetay
    Left = 428
    Top = 214
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  TOP 1 ID, RESIM'
      'FROM         STOKLAR '#9' '
      'WHERE ID=:PRID')
    Left = 763
    Top = 271
    ParamData = <
      item
        Name = 'PRID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 841
    Top = 118
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 583
    Top = 156
  end
  object PmStokHareket: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = pmStokDurumPopup
    Left = 324
    Top = 435
    object BirUrunMaliyetGuncelleMenu: TMenuItem
      Caption = 'Bu '#252'r'#252'n'#252'n maliyetini g'#252'ncelle'
      ImageIndex = 12
      OnClick = BirUrunMaliyetGuncelleMenuClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object HareketlerinzlemBilgileriniGosterMenu: TMenuItem
      Caption = 'Hareketlerin '#304'zlem Bilgilerini G'#246'ster'
      ImageIndex = 22
      OnClick = HareketlerinzlemBilgileriniGosterMenuClick
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 1027
    Top = 289
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 892
    Top = 388
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 19
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 19
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 440
    Top = 364
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object TabStokEsdeger: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Declare @PStokID int'
      'Set @PStokID=:PstokID'
      'Select SE.*,S.KOD,S.STOKADI from STOKESDEGER SE left outer join '
      'STOKLAR S on S.ID=SE.STOKESDEGERID Where SE.STOKID=@PStokID'
      'union all'
      'Select SE.*,S.KOD,S.STOKADI from STOKESDEGER SE left outer join '
      'STOKLAR S on S.ID=SE.STOKID Where SE.STOKESDEGERID=@PStokID')
    Left = 516
    Top = 336
    ParamData = <
      item
        Name = 'PStokID'
        Size = -1
        Value = Null
      end>
  end
  object DtsStokEsdeger: TDataSource
    DataSet = TabStokEsdeger
    Left = 510
    Top = 433
  end
  object PopupMenuEsdeger: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 364
    Top = 465
    object MenuTurDegis: TMenuItem
      Caption = 'T'#252'r'#252'n'#252' De'#287'i'#351'tir'
      ImageIndex = 12
      OnClick = MenuTurDegisClick
    end
    object MenuAciklamaDegis: TMenuItem
      Caption = 'A'#231#305'klamas'#305'n'#305' de'#287'i'#351'tir'
      ImageIndex = 30
      OnClick = MenuAciklamaDegisClick
    end
  end
  object TabSeriLotDurum: TFDQuery
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'select * from STOKDURUMIZLEME SD'
      'INNER JOIN [STOKSERILOT] SSL ON SD.SERILOTID=SSL.ID'
      'where SD.STOKID=:PStokID'
      'and SD.DEPOID=:PDepoID'
      'and KALAN>0')
    Left = 619
    Top = 221
    ParamData = <
      item
        Name = 'PStokID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1407
      end
      item
        Name = 'PDepoID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsSeriLotDurum: TDataSource
    DataSet = TabSeriLotDurum
    Left = 604
    Top = 318
  end
  object TabSeriLotHareket: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select SI.ID,SSL.SERINO,SSL.LOTNO,SSL.SKT,SSL.URT,SD.DEPOID,D.DE' +
        'POADI, SD.ADET from STOKIZLEME SI'
      'LEFT JOIN STOKIZLEMEDEPO SD  ON SD.IZLEMID=SI.ID'
      'LEFT JOIN [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID'
      'LEFT JOIN DEPOLAR D ON D.ID=SD.DEPOID'
      'where SI.STOKID=:PStokID'
      'and SI.SATIRID=:PSatirID')
    Left = 715
    Top = 245
    ParamData = <
      item
        Name = 'PStokID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1407
      end
      item
        Name = 'PSatirID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsSeriLotHareket: TDataSource
    DataSet = TabSeriLotHareket
    Left = 708
    Top = 326
  end
end
