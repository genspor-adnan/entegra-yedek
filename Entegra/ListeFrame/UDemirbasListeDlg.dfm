object DemirbasListeDlg: TDemirbasListeDlg
  Left = 0
  Top = 0
  Width = 1092
  Height = 662
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
    Width = 1086
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 96
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
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 96
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object DegisTus: TToolButton
      Left = 192
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      Visible = False
      OnClick = DegisTusClick
    end
    object ToolButton3: TToolButton
      Left = 288
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 296
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 304
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object AksiyonEkle: TToolButton
      Left = 400
      Top = 0
      Caption = 'Aksiyon Ekle'
      DropdownMenu = PopupDemirbasListe
      ImageIndex = 1
      ImageName = 'PngImage0'
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 404
    Width = 1092
    Height = 7
    AlignSplitter = salBottom
    Control = PgAltDetay
  end
  object PgAltDetay: TcxPageControl
    Left = 0
    Top = 411
    Width = 1092
    Height = 251
    Align = alBottom
    TabOrder = 3
    Properties.ActivePage = TabSheetHareketler
    Properties.CustomButtons.Buttons = <>
    OnChange = PgAltDetayChange
    ClientRectBottom = 247
    ClientRectLeft = 4
    ClientRectRight = 1088
    ClientRectTop = 27
    object TabSheetHareketler: TcxTabSheet
      Tag = 1
      Caption = 'Hareketler'
      ImageIndex = 0
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridTarihce: TcxGrid
        Left = 0
        Top = 27
        Width = 899
        Height = 193
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridTarihceView: TcxGridDBTableView
          OnDblClick = GridTarihceViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridTarihceViewCanFocusRecord
          DataController.DataSource = dtsTabDemirbasTutanak
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Editing = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridTarihceViewStylesGetContentStyle
          object GridTarihceViewTUTANAK: TcxGridDBColumn
            Caption = #304#351'lem'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repDemirbasAksiyon
            HeaderAlignmentHorz = taCenter
            Width = 120
          end
          object GridTarihceViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 130
          end
          object GridTarihceViewZIMMETALAN: TcxGridDBColumn
            Caption = 'Alan'
            DataBinding.FieldName = 'ALANADI'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 129
          end
          object GridTarihceViewZIMMETVEREN: TcxGridDBColumn
            Caption = 'Veren'
            DataBinding.FieldName = 'VERENADI'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 127
          end
          object GridTarihceViewLOKASYON: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYON'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 105
          end
          object GridTarihceViewBELGENO: TcxGridDBColumn
            Caption = 'Belgeno'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
            Width = 69
          end
          object GridTarihceViewBELGETARIH: TcxGridDBColumn
            Caption = 'B.Tarihi'
            DataBinding.FieldName = 'BELGETARIH'
            DataBinding.IsNullValueType = True
          end
          object GridTarihceViewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
          end
          object GridTarihceViewKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 42
          end
          object GridTarihceViewFIRMA: TcxGridDBColumn
            Caption = 'Cari'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 147
          end
          object GridTarihceViewNOTLAR: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'NOTLAR'
            DataBinding.IsNullValueType = True
            Width = 485
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridTarihceView
        end
      end
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1078
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 90
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
        object TutanakGorTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'G'#246'r/D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = TutanakGorTusClick
        end
        object TutanakSilTus: TToolButton
          Left = 90
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = TutanakSilTusClick
        end
      end
      object SQLMemoTutanak: TcxMemo
        Left = 133
        Top = 72
        Lines.Strings = (
          'declare @DID int'
          'set @DID= :prm1'
          ''
          'SELECT DT.*, --DI.ANAHTAR AS TUTANAK, '
          ' L.ACIKLAMA AS LOKASYON, R.FIRMA,'
          'ALANADI=RA.FIRMA,ALANROL=ROA.ROL,'
          'VERENADI=RV.FIRMA,VERENROL=ROV.ROL,'
          ''
          '--@Zimmet'
          'DTD.DEMIRBASID'
          'FROM DEMIRBAS_TUTANAK_DETAY AS DTD '
          
            '    LEFT OUTER JOIN DEMIRBAS_TUTANAK AS DT ON DT.ID = DTD.TUTANA' +
            'KID '
          '    LEFT OUTER JOIN REHBER AS R ON R.ID = DT.REHBERID '
          '    LEFT OUTER JOIN REHBER AS RA ON RA.ID = DT.ALANID '
          '    LEFT OUTER JOIN REHBER AS RV ON RV.ID = DT.VERENID '
          
            #9'LEFT OUTER JOIN ROLLER ROA on ROA.ID=(select K1.ROLID from KULL' +
            'ANICI K1 where K1.REHBERID=DT.ALANID)'
          
            #9'LEFT OUTER JOIN ROLLER ROV on ROV.ID=(select K1.ROLID from KULL' +
            'ANICI K1 where K1.REHBERID=DT.VERENID)'
          '   -- LEFT OUTER JOIN (SELECT BOLUM, ANAHTAR, DEGER'
          
            '   -- FROM GENINI WHERE (BOLUM =-2801 and DIL=-1)) AS DI ON DI.D' +
            'EGER = DT.TIP '
          #9'LEFT OUTER JOIN LOKASYON as L on L.ID=DT.LOKASYONID'
          'Where DTD.DEMIRBASID=@DID'
          'order by DT.ID')
        Properties.WordWrap = False
        TabOrder = 2
        Visible = False
        Height = 161
        Width = 588
      end
      object PanelFiyatAltSag: TPanel
        Left = 899
        Top = 27
        Width = 185
        Height = 193
        Align = alRight
        Caption = 'PanelFiyatAltSag'
        TabOrder = 3
        object ToolBar5: TToolBar
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
          Height = 164
          Width = 183
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Tag = 5
      Caption = 'Yorum/Medya'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel4: TPanel
        Left = 0
        Top = 159
        Width = 1084
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
          Width = 936
        end
        object BtnMesajGonder: TcxButton
          Left = 937
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
          Left = 1022
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
        Top = 200
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
        ExplicitTop = 199
        AnchorX = 1084
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1084
        Height = 159
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
    object TabSheetKalibrasyon: TcxTabSheet
      Tag = 3
      Caption = 'Kalibrasyon'
      ImageIndex = 2
      object ToolBar3: TToolBar
        Left = 0
        Top = 0
        Width = 1084
        Height = 24
        Margins.Bottom = 0
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
        TabOrder = 0
        Transparent = True
        object KalEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = KalEkleTusClick
        end
        object KalDuzenTus: TToolButton
          Left = 66
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = KalDuzenTusClick
        end
        object KalSilTus: TToolButton
          Left = 132
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = KalSilTusClick
        end
        object ToolButton6: TToolButton
          Left = 198
          Top = 0
          Width = 8
          Caption = 'ToolButton4'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
      end
      object gridKalibrasyon: TcxGrid
        Left = 0
        Top = 24
        Width = 1084
        Height = 196
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object ViewKalibrasyon: TcxGridDBTableView
          OnDblClick = KalDuzenTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = ViewKalibrasyonCanFocusRecord
          DataController.DataSource = dtsKalibrasyon
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object ViewKalibrasyonTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object ViewKalibrasyonGECERLILIKTARIHI: TcxGridDBColumn
            Caption = 'Ge'#231'erlilik'
            DataBinding.FieldName = 'GECERLILIKTARIHI'
            DataBinding.IsNullValueType = True
          end
          object ViewKalibrasyonSERTIFIKA: TcxGridDBColumn
            Caption = 'Sertifika'
            DataBinding.FieldName = 'SERTIFIKA'
            DataBinding.IsNullValueType = True
          end
          object ViewKalibrasyonGONDERILENFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
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
            Width = 200
          end
          object ViewKalibrasyonFIRMAPERSONELI: TcxGridDBColumn
            Caption = 'Firma Yetkili'
            DataBinding.FieldName = 'FIRMAPERSONEL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
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
            Width = 115
          end
          object ViewKalibrasyonMALIYET: TcxGridDBColumn
            Caption = 'Maliyet'
            DataBinding.FieldName = 'MALIYET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
          end
          object ViewKalibrasyonKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object ViewKalibrasyonNOTLAR: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'NOTLAR'
            DataBinding.IsNullValueType = True
            Width = 382
          end
        end
        object gridKalibrasyonLevel1: TcxGridLevel
          GridView = ViewKalibrasyon
        end
      end
    end
    object TabSheetTakip: TcxTabSheet
      Tag = 4
      Caption = 'Takip / Uyar'#305
      ImageIndex = 2
      object TreeListGorev: TcxDBTreeList
        Left = 0
        Top = 41
        Width = 1084
        Height = 179
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsGorevler
        DataController.ParentField = 'BAGIDUST'
        DataController.KeyField = 'ID'
        DragMode = dmAutomatic
        Images = Tablo.KlasorResimleri
        LookAndFeel.ScrollbarMode = sbmClassic
        Navigator.Buttons.CustomButtons = <>
        OptionsCustomizing.ColumnsQuickCustomization = True
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.MultiSelect = True
        OptionsView.GridLines = tlglBoth
        OptionsView.Indicator = True
        OptionsView.TreeLineStyle = tllsNone
        PopupMenu = GorevlerMenu
        PopupMenus.ColumnHeaderMenu.PopupMenu = AnaForm.PopupMenuTree
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 0
        OnDblClick = TreeListGorevDblClick
        object TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ID'
          Width = 100
          Position.ColIndex = 8
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn
          Tag = 1
          PropertiesClassName = 'TcxCheckBoxProperties'
          Caption.Glyph.SourceDPI = 96
          Caption.Glyph.Data = {
            424D360400000000000036000000280000001000000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            000000000002000000070000000C0000001000000012000000110000000E0000
            0008000000020000000000000000000000000000000000000000000000010000
            0004000101120D2A1D79184E36C6216B4BFF216B4BFF216C4BFF1A533AD20F2F
            218400010115000000050000000100000000000000000000000000000005050F
            0A351C5B40DC24805CFF29AC7EFF2CC592FF2DC894FF2DC693FF2AAE80FF2585
            60FF1A563DD405110C3D00000007000000010000000000000003040E0A312065
            48ED299D74FF2FC896FF2EC996FF56D4ACFF68DAB5FF3BCD9DFF30C996FF32CA
            99FF2BA479FF227050F805110C3D00000005000000000000000A1A573DD02EA5
            7CFF33CA99FF2EC896FF4CD2A8FF20835CFF00673BFF45BE96FF31CB99FF31CB
            98FF34CC9CFF31AD83FF1B5C41D300010113000000020B23185E2E8A66FF3BCD
            9EFF30CA97FF4BD3A9FF349571FF87AF9DFFB1CFC1FF238A60FF45D3A8FF36CF
            9FFF33CD9BFF3ED0A3FF319470FF0F32237F00000007184D37B63DB38CFF39CD
            9FFF4BD5A9FF43A382FF699782FFF8F1EEFFF9F3EEFF357F5DFF56C4A1FF43D5
            A8FF3ED3A4FF3CD1A4FF41BC95FF1B5C43CD0000000B1C6446DF4BCAA4FF44D2
            A8FF4FB392FF4E826AFFF0E9E6FFC0C3B5FFEFE3DDFFCEDDD4FF1B754FFF60DC
            B8FF48D8ACFF47D6AAFF51D4ACFF247A58F80000000E217050F266D9B8FF46D3
            A8FF0B6741FFD2D2CBFF6A8F77FF116B43FF73967EFFF1E8E3FF72A28BFF46A6
            85FF5EDFBAFF4CD9AFFF6BE2C2FF278460FF020604191E684ADC78D9BEFF52DA
            B1FF3DBA92FF096941FF2F9C76FF57DEB8FF2D9973FF73967EFFF0EAE7FF4F88
            6CFF5ABB9AFF5BDEB9FF7FE2C7FF27835FF80000000C19523BAB77C8B0FF62E0
            BCFF56DDB7FF59DFBAFF5CE1BDFF5EE2BEFF5FE4C1FF288C67FF698E76FFE6E1
            DCFF176B47FF5FD8B4FF83D5BDFF1E674CC60000000909201747439C7BFF95EC
            D6FF5ADFBAFF5EE2BDFF61E4BFFF64E6C1FF67E6C5FF67E8C7FF39A17EFF1F6D
            4AFF288B64FF98EFD9FF4DAC8CFF1036286D00000004000000041C5F46B578C6
            ADFF9AEED9FF65E5C0FF64E7C3FF69E7C6FF6BE8C8FF6CE9C9FF6BEAC9FF5ED6
            B6FF97EDD7FF86D3BBFF237759D20102010C0000000100000001030A0718247B
            5BDA70C1A8FFB5F2E3FF98F0DAFF85EDD4FF75EBCEFF88EFD6FF9CF2DDFFBAF4
            E7FF78CDB3FF2A906DEA0615102E00000002000000000000000000000001030A
            07171E694FB844AB87FF85D2BBFFA8E6D6FFC5F4EBFFABE9D8FF89D8C1FF4BB6
            92FF237F60CB05130E2700000003000000000000000000000000000000000000
            0001000000030A241B411B60489D258464CF2C9D77EE258867CF1F7156B00E32
            26560000000600000002000000000000000000000000}
          Caption.ShowEndEllipsis = False
          Caption.Text = '*'
          DataBinding.FieldName = 'ACKAPA'
          Options.Editing = False
          Width = 61
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn
          Caption.Text = 'L'#304'STE'
          DataBinding.FieldName = 'LISTEADI'
          Options.Editing = False
          Width = 62
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn
          DataBinding.FieldName = 'KONUSU'
          Options.Editing = False
          Width = 139
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn
          Caption.Text = 'T'#220'R'#220
          DataBinding.FieldName = 'TURU'
          Options.Editing = False
          Width = 65
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListCARIAD: TcxDBTreeListColumn
          Caption.Text = 'CAR'#304' AD'
          DataBinding.FieldName = 'CARIAD'
          Options.Editing = False
          Width = 100
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListATANAN1: TcxDBTreeListColumn
          Caption.Text = 'ATANAN'
          DataBinding.FieldName = 'ATANAN1'
          Options.Editing = False
          Width = 100
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListTARIH: TcxDBTreeListColumn
          PropertiesClassName = 'TcxDateEditProperties'
          Caption.Text = 'TAR'#304'H'
          DataBinding.FieldName = 'BITISTARIHI'
          Options.Editing = False
          Width = 100
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListNOTLAR_BIT: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Images = Tablo.KlasorResimleri
          Properties.Items = <
            item
              Value = False
            end
            item
              ImageIndex = 27
              Value = True
            end>
          Caption.Glyph.SourceDPI = 96
          Caption.Glyph.Data = {
            424D360400000000000036000000280000001000000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000200000
            002100000023000000240000002600000027000000290000002A0000002C0000
            002D0000002F0000003100000032000000340000000000000000000000140000
            00150000001600000017000000190000001A0000001B0000001D0000001E0000
            0020000000210000002300000024000000260000000000000000000000090000
            000A0000000B0000000C0000000E0000000F0000001000000011000000120000
            0014000000150000001600000017000000190000000000000000000000000000
            000000000000000000040000000F000000110000000B00000004000000010000
            0000000000000000000000000000000000000000000000000000402A1FFF402A
            1FFF3E291FFF0000000E421C11FF31140CE1190A0698030407420000000C0000
            0002000000000000000000000000000000000000000000000000422B20FF0000
            0000000000000000000D663C2BDCB9C7D2FF7889A2FF244182FF051033960000
            000F000000020000000000000000000000000000000000000000442D22FF0000
            0000000000000000000841261B91879AB2FFC8E3F5FF1F66B6FF2B6BA8FF0512
            36950000000E0000000200000000000000000000000000000000452E23FF0000
            000000000000000000031113163E488BC3FFDEFEFDFF51B4E3FF1F68B7FF3173
            AEFF061538940000000D00000002000000000000000000000000483022FF0000
            00000000000000000001000000081D44618D479FD2FFDEFEFDFF59BFE9FF216B
            B9FF367BB3FF07173A920000000C000000020000000000000000493224FF0000
            0000000000000000000000000001000000091D44618C4BA5D5FFDEFEFDFF61CA
            EFFF246FBCFF3B83B9FF08193D900000000A00000002000000004A3225FF0000
            000000000000000000000000000000000001000000081D44618A4EAAD7FFDEFE
            FDFF68D4F4FF2875BEFF3F8BBEFF091B3F8E00000006000000004C3426FF4B33
            26FF4B3225FF4A3225FF493225FF483124FF483124FF000000071C44618951AE
            DAFFDEFEFDFF6EDDF8FF2C7BC2FF18448BFF0000000800000000000000000000
            0000000000000000000000000000000000000000000000000001000000061D44
            618754B1DCFFDEFEFDFF4FA6D4FF112B4E880000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            00051D456185357FBCFF173A5986000000050000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00010000000200000004000000030000000100000000}
          Caption.Text = 'N'
          DataBinding.FieldName = 'NOTLAR_BIT'
          Width = 22
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListYORUM_BIT: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Images = Tablo.KlasorResimleri
          Properties.Items = <
            item
              Value = False
            end
            item
              ImageIndex = 26
              Value = True
            end>
          Caption.Text = 'Y'
          DataBinding.FieldName = 'YORUM_BIT'
          Width = 22
          Position.ColIndex = 9
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListTEKRAR_BIT: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Images = Tablo.KlasorResimleri
          Properties.Items = <
            item
              Value = False
            end
            item
              ImageIndex = 20
              Value = True
            end>
          Caption.Text = 'T'
          DataBinding.FieldName = 'TEKRAR_BIT'
          Width = 22
          Position.ColIndex = 10
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListANIMSAT_BIT: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Images = Tablo.KlasorResimleri
          Properties.Items = <
            item
              Value = False
            end
            item
              ImageIndex = 23
              Value = True
            end>
          Caption.Text = 'A'
          DataBinding.FieldName = 'ANIMSAT_BIT'
          Width = 22
          Position.ColIndex = 11
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListBAYRAK: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Images = Tablo.KlasorResimleri
          Properties.Items = <
            item
              Value = False
            end
            item
              ImageIndex = 21
              Value = True
            end>
          Caption.Text = 'B'
          DataBinding.FieldName = 'BAYRAK'
          Width = 22
          Position.ColIndex = 12
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListDURUM: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepGorevDurum
          DataBinding.FieldName = 'DURUM'
          Width = 100
          Position.ColIndex = 13
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn
          DataBinding.FieldName = 'PROJEKODU'
          Width = 100
          Position.ColIndex = 14
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn
          DataBinding.FieldName = 'EKLEYENAD'
          Width = 100
          Position.ColIndex = 15
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn
          PropertiesClassName = 'TcxDateEditProperties'
          DataBinding.FieldName = 'EKLEMETARIHI'
          Width = 100
          Position.ColIndex = 16
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'EKLEYEN'
          Position.ColIndex = 17
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'LISTEID'
          Position.ColIndex = 18
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object Panel9: TPanel
        Left = 0
        Top = 0
        Width = 1084
        Height = 41
        Align = alTop
        Caption = 'Panel9'
        TabOrder = 1
        object ToolBar4: TToolBar
          Left = 1
          Top = 1
          Width = 146
          Height = 39
          Margins.Bottom = 0
          Align = alLeft
          AutoSize = True
          ButtonHeight = 39
          ButtonWidth = 46
          Caption = 'AletCubugu'
          Color = clTeal
          Ctl3D = False
          DockSite = True
          DrawingStyle = dsGradient
          EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
          EdgeInner = esNone
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
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object GorevEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = GorevEkleTusClick
          end
          object GorevSilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = GorevSilTusClick
          end
          object ToolButton2: TToolButton
            Left = 92
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object GorevDuzenleTus: TToolButton
            Left = 100
            Top = 0
            Caption = 'D'#252'zenle'
            ImageIndex = 7
            ImageName = 'PngImage7'
            OnClick = TreeListGorevDblClick
          end
        end
        object JvNavPanelHeader5: TJvNavPanelHeader
          Left = 147
          Top = 1
          Width = 936
          Height = 39
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
          object CheckTamamlanan: TcxCheckBox
            Left = 47
            Top = 12
            Caption = 'Tamamlananlar'#305' da g'#246'ster'
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 0
            Transparent = True
            OnClick = CheckTamamlananClick
          end
          object ComboTamamlanan: TcxImageComboBox
            Left = 229
            Top = 12
            RepositoryItem = Tablo.RepGorevSonKac
            Properties.Items = <>
            Properties.OnEditValueChanged = CheckTamamlananClick
            Style.Color = clSilver
            TabOrder = 1
            Visible = False
            Width = 115
          end
        end
      end
    end
    object TabSheetMasraflar: TcxTabSheet
      Tag = 6
      Caption = 'Masraflar'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object MasrafGrid: TcxGrid
        Left = 0
        Top = 0
        Width = 1084
        Height = 220
        Align = alClient
        PopupMenu = PopupMasraflar
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object MasrafGridView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMasraflar
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              Column = MasrafGridViewTutar
            end
            item
              Kind = skSum
              Column = MasrafGridViewKDV
            end
            item
              Kind = skSum
              Column = MasrafGridViewToplam
            end
            item
              Kind = skCount
              Column = MasrafGridViewBelgeTipi
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          object MasrafGridViewBelgeTipi: TcxGridDBColumn
            DataBinding.FieldName = 'BelgeTipi'
            DataBinding.IsNullValueType = True
          end
          object MasrafGridViewSatici: TcxGridDBColumn
            Caption = 'Sat'#305'c'#305
            DataBinding.FieldName = 'Satici'
            DataBinding.IsNullValueType = True
            Width = 133
          end
          object MasrafGridViewBelgeTarihi: TcxGridDBColumn
            DataBinding.FieldName = 'BelgeTarihi'
            DataBinding.IsNullValueType = True
          end
          object MasrafGridViewBelgeNo: TcxGridDBColumn
            DataBinding.FieldName = 'BelgeNo'
            DataBinding.IsNullValueType = True
            Width = 129
          end
          object MasrafGridViewAciklama: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'Aciklama'
            DataBinding.IsNullValueType = True
            Width = 120
          end
          object MasrafGridViewTutar: TcxGridDBColumn
            DataBinding.FieldName = 'Tutar'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object MasrafGridViewKDV: TcxGridDBColumn
            DataBinding.FieldName = 'KDV'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object MasrafGridViewToplam: TcxGridDBColumn
            DataBinding.FieldName = 'Toplam'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object MasrafGridViewKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object MasrafGridViewPersonel: TcxGridDBColumn
            DataBinding.FieldName = 'Personel'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = MasrafGridView
        end
      end
    end
  end
  object GridDemirbas: TcxGrid
    Left = 0
    Top = 35
    Width = 1092
    Height = 369
    Align = alClient
    PopupMenu = PopupDemirbasListe
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridDemirbasView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridDemirbasViewCanFocusRecord
      OnFocusedRecordChanged = GridDemirbasViewFocusedRecordChanged
      DataController.DataSource = DtsDemirbaslar
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = 'Say'#305' : ######'
          Kind = skCount
          Position = spFooter
          FieldName = 'DEMIRBASADI'
          Column = GridDemirbasViewDEMIRBASADI
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Say'#305' : ######'
          Kind = skCount
          FieldName = 'DEMIRBASADI'
          Column = GridDemirbasViewDEMIRBASADI
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Editing = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.Footer = True
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Preview.Visible = True
      Styles.OnGetContentStyle = GridDemirbasViewStylesGetContentStyle
      object GridDemirbasViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridDemirbasViewDEMIRBASNO: TcxGridDBColumn
        Caption = 'Demirba'#351' No'
        DataBinding.FieldName = 'DEMIRBASNO'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
        Width = 88
      end
      object GridDemirbasViewDEMIRBASADI: TcxGridDBColumn
        Caption = 'Demirba'#351' Ad'#305
        DataBinding.FieldName = 'DEMIRBASADI'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
        Width = 179
      end
      object GridDemirbasViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepDemirbas_Durum
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Styles.Header = cxStyle8
        Width = 87
      end
      object GridDemirbasViewZIMMETLI: TcxGridDBColumn
        Caption = 'Zimmet Sahibi'
        DataBinding.FieldName = 'ZIMMETLIADI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Styles.Header = cxStyle8
        Width = 145
      end
      object GridDemirbasViewLOKASYONADI: TcxGridDBColumn
        Caption = 'Lokasyon'
        DataBinding.FieldName = 'LOKASYONADI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Styles.Header = cxStyle8
        Width = 94
      end
      object GridDemirbasViewKATEGORIADI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORIADI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Styles.Header = cxStyle8
        Width = 144
      end
      object GridDemirbasViewMARKA: TcxGridDBColumn
        Caption = 'Marka'
        DataBinding.FieldName = 'MARKA'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.Demirbas_Marka
        Styles.Header = cxStyle8
        Width = 107
      end
      object GridDemirbasViewMODEL: TcxGridDBColumn
        Caption = 'Model'
        DataBinding.FieldName = 'MODELAD'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
        Width = 90
      end
      object GridDemirbasViewLOKASYONID: TcxGridDBColumn
        Caption = 'LokasyonId'
        DataBinding.FieldName = 'LOKASYONID'
        DataBinding.IsNullValueType = True
        Visible = False
        Styles.Header = cxStyle8
        VisibleForCustomization = False
      end
      object GridDemirbasViewREHBERID: TcxGridDBColumn
        Caption = 'Zimmet.Per.Id'
        DataBinding.FieldName = 'REHBERID'
        DataBinding.IsNullValueType = True
        Visible = False
        Styles.Header = cxStyle8
        VisibleForCustomization = False
      end
      object GridDemirbasViewTEKNIKSORUMLU: TcxGridDBColumn
        Caption = 'Servis Sorumlusu'
        DataBinding.FieldName = 'TEKNIKSORUMLU'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repGenelPersonelListesiHerkes
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewTEKNIKBILGI: TcxGridDBColumn
        Caption = 'Servis Bilgilendirilecek'
        DataBinding.FieldName = 'TEKNIKBILGI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repGenelPersonelListesiHerkes
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewOZELLIK1: TcxGridDBColumn
        Caption = #214'zellik1'
        DataBinding.FieldName = 'OZELLIK1'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewOZELLIK2: TcxGridDBColumn
        Caption = #214'zellik2'
        DataBinding.FieldName = 'OZELLIK2'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewOZELLIK3: TcxGridDBColumn
        Caption = #214'zellik3'
        DataBinding.FieldName = 'OZELLIK3'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewOZELLIK4: TcxGridDBColumn
        Caption = #214'zellik4'
        DataBinding.FieldName = 'OZELLIK4'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
      end
      object GridDemirbasViewOZELLIK5: TcxGridDBColumn
        Caption = #214'zellik5'
        DataBinding.FieldName = 'OZELLIK5'
        DataBinding.IsNullValueType = True
        Styles.Header = cxStyle8
      end
    end
    object GridDemirbasLevel3: TcxGridLevel
      GridView = GridDemirbasView
    end
  end
  object SQLMemo: TcxMemo
    Left = 137
    Top = 128
    Lines.Strings = (
      'SELECT    D.*, '
      'ZIMMETLIADI = R.FIRMA,'
      'LOKASYONADI=L.ACIKLAMA,'
      'KATEGORIADI = DU.AD,'
      'StokModel.ANAHTAR AS MODELAD,'#9
      
        'KALBITTARIH =  (SELECT MAX(GECERLILIKTARIHI)  FROM KALIBRASYON K' +
        ' WHERE K.DEMIRBASID=D.ID)  '
      'FROM DEMIRBAS D '
      ' LEFT OUTER JOIN DEMIRBAS_KATEGORI AS DU ON DU.ID=D.KATEGORIID  '
      
        ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = D.MODEL A' +
        'ND StokModel.BOLUM=convert(int,'#39'-2804'#39'+convert(varchar(10),D.MAR' +
        'KA))  '
      ' LEFT OUTER JOIN REHBER AS R ON R.ID = D.REHBERID'
      
        ' LEFT OUTER JOIN LOKASYON AS L  ON L.ID = (select top 1 LOKASYON' +
        'ID from DEMIRBAS_TUTANAK DT inner join DEMIRBAS_TUTANAK_DETAY DT' +
        'D on DT.ID=DTD.TUTANAKID '
      'and DTD.DEMIRBASID=D.ID  ORDER  BY ID DESC)'
      '--YETKIEK'
      'where 1=1')
    Properties.WordWrap = False
    TabOrder = 4
    Visible = False
    Height = 65
    Width = 588
  end
  object DtsDemirbaslar: TDataSource
    DataSet = DEMIRBAS
    Left = 162
    Top = 147
  end
  object DEMIRBAS: TFDQuery
    AfterOpen = DEMIRBASAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT    D.*, '
      
        'ZIMMETLI = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = (select to' +
        'p 1  DT.ALANID from DEMIRBAS_TUTANAK DT where DT.TIP=21 and DT.I' +
        'D in (select DTD.TUTANAKID from DEMIRBAS_TUTANAK_DETAY DTD where' +
        ' DTD.DEMIRBASID=D.ID)order by DT.ID desc)),'
      
        'LOKASYONADI = (select L.ACIKLAMA from LOKASYON L where L.ID = (s' +
        'elect top 1 LOKASYONID from DEMIRBAS_TUTANAK DT where isnull(DT.' +
        'LOKASYONID,0)>0 and DT.ID in (select DTD.TUTANAKID from DEMIRBAS' +
        '_TUTANAK_DETAY DTD where DTD.DEMIRBASID=D.ID)order by DT.ID desc' +
        ')),'
      
        'SERVISILGILI = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = (selec' +
        't top 1 case when DT.TIP=23 then DT.ALANID else 0 end from DEMIR' +
        'BAS_TUTANAK DT where DT.ID in (select DTD.TUTANAKID from DEMIRBA' +
        'S_TUTANAK_DETAY DTD where DTD.DEMIRBASID=D.ID)order by DT.ID des' +
        'c)),'
      'DU.STOKADI AS KATEGORIADI,'
      ' StokModel.ANAHTAR as MODELADI, R2.FIRMA as SUBEADI,'
      
        'KALBITTARIH =  (SELECT MAX(GECERLILIKTARIHI)  FROM KALIBRASYON K' +
        ' WHERE K.DEMIRBASID=D.ID)  '
      'FROM DEMIRBAS D '
      ' LEFT OUTER JOIN DEMIRBAS_URUN AS DU ON DU.ID=D.KATEGORIID  '
      
        ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = D.MODEL A' +
        'ND StokModel.BOLUM=convert(int,'#39'-2804'#39'+convert(varchar(10),D.MAR' +
        'KA))  '
      ' LEFT OUTER JOIN REHBER AS R2 ON R2.ID = D.SUBEID'
      'where 1=1')
    Left = 101
    Top = 129
  end
  object PopupMenuYaz: TPopupMenu
    Left = 375
    Top = 125
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
  object frxDemirbas: TfrxDBDataset
    UserName = 'Demirbas'
    CloseDataSource = False
    DataSet = DEMIRBAS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 258
    Top = 101
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'STOKID'
        FieldAlias = 'STOKID'
      end
      item
        FieldName = 'STOKKODU'
        FieldAlias = 'STOKKODU'
      end
      item
        FieldName = 'SERINO'
        FieldAlias = 'SERINO'
      end
      item
        FieldName = 'MARKA'
        FieldAlias = 'MARKA'
      end
      item
        FieldName = 'MODEL'
        FieldAlias = 'MODEL'
      end
      item
        FieldName = 'DURUM'
        FieldAlias = 'DURUM'
      end
      item
        FieldName = 'NOTLAR'
        FieldAlias = 'NOTLAR'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'KATEGORIID'
        FieldAlias = 'KATEGORIID'
      end
      item
        FieldName = 'RFID'
        FieldAlias = 'RFID'
      end
      item
        FieldName = 'BARKOD'
        FieldAlias = 'BARKOD'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'SKT'
        FieldAlias = 'SKT'
      end
      item
        FieldName = 'SUBEID'
        FieldAlias = 'SUBEID'
      end
      item
        FieldName = 'DEMIRBASNO'
        FieldAlias = 'DEMIRBASNO'
      end
      item
        FieldName = 'DEMIRBASADI'
        FieldAlias = 'DEMIRBASADI'
      end
      item
        FieldName = 'TAKIP'
        FieldAlias = 'TAKIP'
      end
      item
        FieldName = 'KALIBRASYON'
        FieldAlias = 'KALIBRASYON'
      end
      item
        FieldName = 'SERVIS'
        FieldAlias = 'SERVIS'
      end
      item
        FieldName = 'AMORTISMANORANID'
        FieldAlias = 'AMORTISMANORANID'
      end
      item
        FieldName = 'R'
        FieldAlias = 'R'
      end
      item
        FieldName = 'SERVISDURUM'
        FieldAlias = 'SERVISDURUM'
      end
      item
        FieldName = 'TEKNIKSORUMLU'
        FieldAlias = 'TEKNIKSORUMLU'
      end
      item
        FieldName = 'TEKNIKBILGI'
        FieldAlias = 'TEKNIKBILGI'
      end
      item
        FieldName = 'MASRAF'
        FieldAlias = 'MASRAF'
      end
      item
        FieldName = 'AMORTISMAN'
        FieldAlias = 'AMORTISMAN'
      end
      item
        FieldName = 'ZIMMETLI'
        FieldAlias = 'ZIMMETLI'
      end
      item
        FieldName = 'LOKASYONADI'
        FieldAlias = 'LOKASYONADI'
      end
      item
        FieldName = 'SERVISILGILI'
        FieldAlias = 'SERVISILGILI'
      end
      item
        FieldName = 'KATEGORIADI'
        FieldAlias = 'KATEGORIADI'
      end
      item
        FieldName = 'MODELADI'
        FieldAlias = 'MODELADI'
      end
      item
        FieldName = 'SUBEADI'
        FieldAlias = 'SUBEADI'
      end
      item
        FieldName = 'KALBITTARIH'
        FieldAlias = 'KALBITTARIH'
      end>
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 616
    Top = 226
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11796479
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
  end
  object TabDemirbasTutanak: TFDQuery
    AutoCalcFields = False
    AfterScroll = TabDemirbasTutanakAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @DID int'
      'set @DID= :prm1'
      ''
      
        'SELECT DT.*, DI.ANAHTAR AS TUTANAK,  L.ACIKLAMA AS LOKASYON, R.F' +
        'IRMA,'
      'ALANADI=RA.FIRMA,ALANROL=ROA.ROL,'
      'VERENADI=RV.FIRMA,VERENROL=ROV.ROL,'
      
        'ALANTC=(select BILGI from REHBERBILGI where YERI=3 and ETIKET = ' +
        #39'T.C.Kmlik No'#39' and YER_ID = RA.ID),'
      
        'VERENTC=(select BILGI from REHBERBILGI where YERI=3 and ETIKET =' +
        ' '#39'T.C.Kmlik No'#39' and YER_ID = RV.ID),'
      '--@Zimmet'
      'DTD.DEMIRBASID'
      'FROM DEMIRBAS_TUTANAK_DETAY AS DTD '
      
        '    LEFT OUTER JOIN DEMIRBAS_TUTANAK AS DT ON DT.ID = DTD.TUTANA' +
        'KID '
      '    LEFT OUTER JOIN REHBER AS R ON R.ID = DT.REHBERID '
      '    LEFT OUTER JOIN REHBER AS RA ON RA.ID = DT.ALANID '
      '    LEFT OUTER JOIN REHBER AS RV ON RV.ID = DT.VERENID '
      
        #9'LEFT OUTER JOIN ROLLER ROA on ROA.ID=(select K1.ROLID from KULL' +
        'ANICI K1 where K1.REHBERID=DT.ALANID)'
      
        #9'LEFT OUTER JOIN ROLLER ROV on ROV.ID=(select K1.ROLID from KULL' +
        'ANICI K1 where K1.REHBERID=DT.VERENID)'
      '    LEFT OUTER JOIN (SELECT BOLUM, ANAHTAR, DEGER'
      '                     FROM GENINI'
      
        '                     WHERE (BOLUM =-2801 and DIL=-1)) AS DI ON D' +
        'I.DEGER = DT.TIP '
      #9'LEFT OUTER JOIN LOKASYON as L on L.ID=DT.LOKASYONID'
      'Where DTD.DEMIRBASID=@DID'
      'order by DT.ID')
    Left = 303
    Top = 390
    ParamData = <
      item
        Name = 'prm1'
        DataType = ftWideString
        Size = 2
        Value = '10'
      end>
  end
  object dtsTabDemirbasTutanak: TDataSource
    DataSet = TabDemirbasTutanak
    Left = 220
    Top = 246
  end
  object frxDemirbasTutanak: TfrxDBDataset
    UserName = 'DemirbasTutanak'
    CloseDataSource = False
    DataSet = TabDemirbasTutanak
    BCDToCurrency = False
    DataSetOptions = []
    Left = 305
    Top = 246
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'TIP'
        FieldAlias = 'TIP'
      end
      item
        FieldName = 'TARIH'
        FieldAlias = 'TARIH'
      end
      item
        FieldName = 'VERENID'
        FieldAlias = 'VERENID'
      end
      item
        FieldName = 'ALANID'
        FieldAlias = 'ALANID'
      end
      item
        FieldName = 'LOKASYONID'
        FieldAlias = 'LOKASYONID'
      end
      item
        FieldName = 'BELGENO'
        FieldAlias = 'BELGENO'
      end
      item
        FieldName = 'NOTLAR'
        FieldAlias = 'NOTLAR'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'SUBEID'
        FieldAlias = 'SUBEID'
      end
      item
        FieldName = 'BELGETIPI'
        FieldAlias = 'BELGETIPI'
      end
      item
        FieldName = 'BELGETARIH'
        FieldAlias = 'BELGETARIH'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'TUTAR'
        FieldAlias = 'TUTAR'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'REHBERPERSONELID'
        FieldAlias = 'REHBERPERSONELID'
      end
      item
        FieldName = 'TUTANAK'
        FieldAlias = 'TUTANAK'
      end
      item
        FieldName = 'LOKASYON'
        FieldAlias = 'LOKASYON'
      end
      item
        FieldName = 'FIRMA'
        FieldAlias = 'FIRMA'
      end
      item
        FieldName = 'ALANADI'
        FieldAlias = 'ALANADI'
      end
      item
        FieldName = 'ALANROL'
        FieldAlias = 'ALANROL'
      end
      item
        FieldName = 'VERENADI'
        FieldAlias = 'VERENADI'
      end
      item
        FieldName = 'VERENROL'
        FieldAlias = 'VERENROL'
      end
      item
        FieldName = 'ALANTC'
        FieldAlias = 'ALANTC'
      end
      item
        FieldName = 'VERENTC'
        FieldAlias = 'VERENTC'
      end
      item
        FieldName = 'DEMIRBASID'
        FieldAlias = 'DEMIRBASID'
      end>
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 503
    Top = 140
  end
  object TabKalibrasyon: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select K.ID, K.TARIH,K.GECERLILIKTARIHI,SERTIFIKA, '#39'Kalibrasyon'#39 +
        ',K.DEMIRBASID,K.MALIYET,K.KUR,K.EKLEYEN,K.FIRMAPERSONELI,K.NOTLA' +
        'R,'
      
        '                      R2.FIRMA as FIRMA,  FIRMAPERSONEL = RP.FIR' +
        'MA,K.REHBERID'
      '                      '
      'from KALIBRASYON as K LEFT OUTER JOIN'
      '        REHBER as R2 on K.REHBERID=R2.ID left outer join'
      '        REHBER as RP on RP.ID=K.FIRMAPERSONELI and RP.GRUP=334'
      '                     '
      'Where K.DEMIRBASID=:DID '
      ''
      'ORDER BY TARIH DESC')
    Left = 183
    Top = 189
    ParamData = <
      item
        Name = 'DID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object dtsKalibrasyon: TDataSource
    DataSet = TabKalibrasyon
    Left = 284
    Top = 198
  end
  object PopupDemirbasListe: TPopupMenu
    OnPopup = PopupDemirbasListePopup
    Left = 448
    Top = 96
    object DemirbasInfoMenu: TMenuItem
      Caption = 'info'
      OnClick = DemirbasInfoMenuClick
    end
    object N4: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object KalibrasyonBilgisiGirMenu: TMenuItem
      Tag = -1
      Caption = 'Se'#231'ililere Kalibrasyon Bilgisi Gir'
      OnClick = KalibrasyonBilgisiGirMenuClick
    end
    object N5: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object TeknikServisAtaMenu: TMenuItem
      Tag = -1
      Caption = 'Taknik Servis '
      object TeknikServisSorumlusuAtaMenu: TMenuItem
        Tag = 335
        Caption = 'Sorumlusu Ata'
        OnClick = TeknikServisSorumlusuAtaMenuClick
      end
      object BilgilendirilecekAtaMenu: TMenuItem
        Tag = 337
        Caption = 'Bilgilendirilecek Ata'
        OnClick = TeknikServisSorumlusuAtaMenuClick
      end
    end
    object N6: TMenuItem
      Tag = -5
      Caption = '-'
    end
    object Exceldenverial: TMenuItem
      Tag = -5
      Caption = 'Excelden Veri Al'
      OnClick = ExceldenverialClick
    end
  end
  object tabDemirbasTutanakIcerik: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @TID int'
      'set @TID=  :prm1'
      ''
      'SELECT D.ID,DEMIRBASNO,DEMIRBASADI,SERINO,SKT,RFID,NOTLAR'
      ''
      'FROM '
      #9'DEMIRBAS D '
      
        '    INNER JOIN DEMIRBAS_TUTANAK_DETAY DTD ON DTD.DEMIRBASID = D.' +
        'ID '
      'Where '
      #9'DTD.TUTANAKID=@TID'
      'order by DEMIRBASADI')
    Left = 463
    Top = 358
    ParamData = <
      item
        Name = 'prm1'
        DataType = ftWideString
        Size = 2
        Value = '10'
      end>
  end
  object DtsDemirbasTutanakIcerik: TDataSource
    DataSet = tabDemirbasTutanakIcerik
    Left = 468
    Top = 302
  end
  object frxDemirbasTutanakIcerik: TfrxDBDataset
    UserName = 'DemirbasTutanakIcerik'
    CloseDataSource = False
    DataSet = tabDemirbasTutanakIcerik
    BCDToCurrency = False
    DataSetOptions = []
    Left = 465
    Top = 246
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'DEMIRBASNO'
        FieldAlias = 'DEMIRBASNO'
      end
      item
        FieldName = 'DEMIRBASADI'
        FieldAlias = 'DEMIRBASADI'
      end
      item
        FieldName = 'SERINO'
        FieldAlias = 'SERINO'
      end
      item
        FieldName = 'SKT'
        FieldAlias = 'SKT'
      end
      item
        FieldName = 'RFID'
        FieldAlias = 'RFID'
      end
      item
        FieldName = 'NOTLAR'
        FieldAlias = 'NOTLAR'
      end>
  end
  object PopupMenuYeniTakip: TPopupMenu
    Left = 169
    Top = 325
    object MenuItemTakipGorev: TMenuItem
      Caption = #304#351' / G'#246'rev'
      OnClick = MenuItemTakipGorevClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MenuItemTakipDuyuru: TMenuItem
      Caption = 'Duyuru'
    end
  end
  object GorevlerMenu: TOfficePopupMenu
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
    Left = 840
    Top = 244
    object DuzenleMenu: TMenuItem
      Caption = 'D'#252'zenle'
    end
    object TamamlandiIsaretleMenu: TMenuItem
      Caption = #304#351'aretliler Tamamland'#305' / Tamamlanmad'#305
    end
    object Bayraklaretle1: TMenuItem
      Caption = #304#351'aretliler  Bayrakl'#305' / Bayraks'#305'z'
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object TarihBugunMenu: TMenuItem
      Caption = #304#351'aretlilerin Tarihi Bug'#252'n'
    end
    object arihYarn1: TMenuItem
      Tag = 1
      Caption = #304#351'aretlilerin Tarihi Yar'#305'n'
    end
    object TarihiKaldirMenu: TMenuItem
      Tag = -1
      Caption = #304#351'aretlilerin Tarihini Kald'#305'r'
    end
    object MenuItem5: TMenuItem
      Caption = '-'
    end
    object Atamayap1: TMenuItem
      Caption = #304#351'aretlilere Atama yap'
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object BuiiEPostaGnder1: TMenuItem
      Caption = 'Bu i'#351'i E-Posta G'#246'nder'
    end
    object BuiYazdr1: TMenuItem
      Caption = 'Bu '#304#351'i Yazd'#305'r'
    end
    object MenuItem9: TMenuItem
      Caption = '-'
    end
    object IsiKopyalaMenu: TMenuItem
      Caption = #304#351'i Kopyala'
    end
    object IsiSilMenu: TMenuItem
      Caption = #304#351'i Sil'
    end
  end
  object TabGorevler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'exec sp_Prg_IsListesi_Demirbas  :RehberId, :AcKapa , :GunSay, :D' +
        'emirbasId')
    Left = 685
    Top = 333
    ParamData = <
      item
        Name = 'RehberId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 2
      end
      item
        Name = 'AcKapa'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end
      item
        Name = 'GunSay'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 9999
      end
      item
        Name = 'DemirbasId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 603
    Top = 384
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 728
    Top = 244
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 728
    Top = 184
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
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
    Left = 800
    Top = 225
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
    Left = 872
    Top = 280
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
    Left = 423
    Top = 276
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
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  TOP 1 ID, RESIM'
      'FROM         DEMIRBAS'#9' '
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
    Top = 182
  end
  object DtsMasraflar: TDataSource
    DataSet = TabMasraflar
    Left = 603
    Top = 384
  end
  object TabMasraflar: TFDQuery
    AfterOpen = TabMasraflarAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @DemirbasID int'
      'set @DemirbasID=:PDemirbasID'
      ''
      
        'SELECT FB.ID,FB.TUR,BelgeTipi=case when FB.TUR=11 then '#39'Fatura'#39' ' +
        'when FB.TUR=12 then '#39'Fi'#351#39' else '#39#220'retim'#39' end,'
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      
        'Aciklama=case when F.TUR=0 then (select AD from MASRAFGELIR MG w' +
        'here MG.ID=F.URUNID)'
      
        'else (select STOKADI from STOKLAR S where S.ID=F.URUNID) end +'#39' ' +
        #39'+isnull(F.ACIKLAMA,'#39#39'),'
      
        'Tutar=TUTAR/((100.0+KDV)/100.0),KDV=TUTAR-TUTAR/((100.0+KDV)/100' +
        '.0), Toplam=TUTAR,F.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=FB.SATICIKOD' +
        'U)'
      'FROM FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID'
      'where FB.TUR in (6,11,12) and F.MIKTAR>0'
      'and FB.DEMIRBASID=@DemirbasID'
      ''
      'union all '
      ''
      
        'SELECT  FB.ID,FB.TUR,BelgeTipi=case when FB.TUR=11 then '#39'FaturaS' +
        'at'#305'r'#305#39' else '#39'Fi'#351'Sat'#305'r'#305#39' end,'
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      
        'Aciklama=case when F.TUR=0 then (select AD from MASRAFGELIR MG w' +
        'here MG.ID=F.URUNID) else (select STOKADI from STOKLAR S where S' +
        '.ID=F.URUNID) end +'#39' '#39'+isnull(F.ACIKLAMA,'#39#39'),'
      
        'Tutar=TUTAR/((100.0+KDV)/100.0),KDV=TUTAR-TUTAR/((100.0+KDV)/100' +
        '.0), Toplam=TUTAR,F.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=F.SATICIKODU' +
        ')'
      'FROM FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID'
      'where FB.TUR in (11,12)'
      'and F.DEMIRBASID=@DemirbasID'
      ''
      'union all '
      ''
      ' SELECT FB.ID,FB.TUR,BelgeTipi='#39'Tahakkuk'#39','
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      'Aciklama=ACIKLAMA,'
      'Tutar=FATURA_TUTARI,KDV=0, Toplam=FATURA_TUTARI,FB.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=FB.SATICIKOD' +
        'U)'
      'FROM FATBASLIK FB'
      'where FB.TUR= 13'
      'and FB.DEMIRBASID=@DemirbasID'
      ''
      'order by 4')
    Left = 685
    Top = 389
    ParamData = <
      item
        Name = 'PDemirbasID'
        Size = -1
        Value = Null
      end>
  end
  object PopupMasraflar: TPopupMenu
    Left = 784
    Top = 392
    object BtnTahakkukEkle: TMenuItem
      Caption = 'Tahakkuk Ekle'
      OnClick = BtnTahakkukEkleClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Dzenle1: TMenuItem
      Caption = 'D'#252'zenle'
      OnClick = Dzenle1Click
    end
    object Sil1: TMenuItem
      Caption = 'Sil'
      OnClick = Sil1Click
    end
  end
end
