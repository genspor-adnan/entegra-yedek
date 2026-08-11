object KYKontrolListeDlg: TKYKontrolListeDlg
  Left = 0
  Top = 0
  Width = 876
  Height = 517
  Align = alClient
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 876
    Height = 107
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 451
    object PanelUrunLot: TPanel
      Left = 1
      Top = 1
      Width = 874
      Height = 105
      Align = alClient
      BevelOuter = bvNone
      Color = clActiveCaption
      ParentBackground = False
      TabOrder = 0
      ExplicitWidth = 449
      object ButtonYenile: TJvTransparentButton
        Left = 439
        Top = 21
        Width = 53
        Height = 79
        Caption = 'Listele'
        TextAlign = ttaBottom
        OnClick = ButtonYenileClick
        Images.ActiveImage = Tablo.cxImageList1
        Images.ActiveIndex = 28
        Images.GrayImage = Tablo.cxImageList1
        Images.GrayIndex = 28
        Images.DisabledImage = Tablo.cxImageList1
        Images.DownImage = Tablo.cxImageList1
        Images.HotImage = Tablo.cxImageList1
      end
      object EditAdet: TcxSpinEdit
        Left = 305
        Top = 68
        TabOrder = 3
        Value = 50
        Width = 59
      end
      object LabelAdet: TcxLabel
        Left = 217
        Top = 72
        Caption = 'Adet'
        Style.Shadow = False
        Style.TransparentBorder = True
        Transparent = True
      end
      object cxLabel5: TcxLabel
        Left = 10
        Top = 73
        Caption = 'Seri No'
        Style.Shadow = False
        Style.TransparentBorder = True
        Transparent = True
      end
      object EditSNO: TcxTextEdit
        Left = 61
        Top = 71
        TabOrder = 2
        Width = 140
      end
      object EditLNO: TcxTextEdit
        Left = 61
        Top = 47
        TabOrder = 1
        Width = 141
      end
      object cxLabel6: TcxLabel
        Left = 10
        Top = 50
        Caption = 'Lot No'
        Style.Shadow = False
        Style.TransparentBorder = True
        Transparent = True
      end
      object cxLabel3: TcxLabel
        Left = 11
        Top = 21
        Caption = #220'r'#252'n No'
        Style.Shadow = False
        Style.TransparentBorder = True
        Transparent = True
      end
      object EditUNO: TcxButtonEdit
        Left = 61
        Top = 23
        Properties.Buttons = <
          item
            Kind = bkEllipsis
          end>
        TabOrder = 0
        Width = 140
      end
      object CheckBaslamaTarih: TcxCheckBox
        Left = 211
        Top = 23
        Caption = 'Ba'#351'lama Tarihi'
        State = cbsChecked
        TabOrder = 8
      end
      object DateEditBasla: TcxDateEdit
        Left = 305
        Top = 20
        Properties.ShowTime = False
        TabOrder = 9
        Width = 104
      end
      object CheckBitisTarih: TcxCheckBox
        Left = 211
        Top = 45
        Caption = 'Biti'#351' Tarihi'
        State = cbsChecked
        TabOrder = 10
      end
      object DateEditBitis: TcxDateEdit
        Left = 305
        Top = 44
        Properties.ShowTime = False
        TabOrder = 11
        Width = 104
      end
      object LabelSecim: TcxLabel
        Left = 563
        Top = 21
        Caption = '---------------------'
        Style.Shadow = False
        Style.TransparentBorder = True
        Transparent = True
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 107
    Width = 876
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer9Style'
    AlignSplitter = salTop
    ExplicitWidth = 451
  end
  object SQLDetay: TcxMemo
    Left = 645
    Top = 313
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
      '                [ZORUNLU] [bit] NULL,'
      #9'[LIMIT] [nvarchar](250) NULL,'
      #9'[LIMITBIRIM] [nvarchar](20) NULL,'
      #9'[LIMITNOT] [nvarchar](250) NULL'
      ')'
      'INSERT INTO #DETAY_:SPID_'
      'select '
      'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
      'RA.KAYNAK,RA.ZORUNLU ,'
      'LIMIT= case '
      'when isnull(RA.LIMIT,'#39#39')<>'#39#39' then RA.LIMIT '
      
        'when (isnull(RA.LIMITALT,'#39#39')<>'#39#39')and(isnull(RA.LIMITUST,'#39#39')<>'#39#39')' +
        ' then '
      
        ' convert(nvarchar(10), isnull(RA.LIMITALT,'#39#39'))+'#39'-'#39'+convert(nvarc' +
        'har'
      '(10),isnull(RA.LIMITUST,'#39#39')) '
      'else '#39#39' end,'
      ' RA.LIMITBIRIM, RA.LIMITNOT'
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
      'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
      'where RB.YERI= @yeri and YER_ID= @yerid '
      'and isnull(RA.BOLUM,'#39#39')=@bolum '
      ''
      'union all'
      ''
      
        'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
        ' ,'
      'LIMIT= case '
      'when isnull(RA.LIMIT,'#39#39')<>'#39#39' then RA.LIMIT '
      
        'when (isnull(RA.LIMITALT,'#39#39')<>'#39#39')and(isnull(RA.LIMITUST,'#39#39')<>'#39#39')' +
        ' then '
      
        ' convert(nvarchar(10), isnull(RA.LIMITALT,'#39#39'))+'#39'-'#39'+convert(nvarc' +
        'har'
      '(10),isnull(RA.LIMITUST,'#39#39')) '
      'else '#39#39' end,'
      ' RA.LIMITBIRIM, RA.LIMITNOT '
      ' from REHBERAYAR  RA'
      'where  YERI=@yeri '
      'and isnull(BOLUM,'#39#39')=@Bolum  '
      'and ETIKET not in (select ETIKET from REHBERBILGI where  '
      'YERI=@yeri  and YER_ID= @yerid )'
      ''
      'order by 1'
      ''
      'select * from #DETAY_:SPID_'
      'order by SIRA')
    TabOrder = 2
    Visible = False
    Height = 109
    Width = 387
  end
  object PanelSol: TPanel
    Left = 0
    Top = 115
    Width = 876
    Height = 402
    Align = alClient
    TabOrder = 3
    ExplicitWidth = 451
    ExplicitHeight = 189
    object GridSorgu: TcxGrid
      Left = 1
      Top = 1
      Width = 191
      Height = 400
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      ExplicitWidth = 228
      ExplicitHeight = 187
      object GridSorguView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridKontrolViewCanFocusRecord
        OnFocusedRecordChanged = GridSorguViewFocusedRecordChanged
        DataController.DataSource = DtsSorgu
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = 'Kay'#305't Say'#305's'#305': ######'
            Kind = skCount
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnTab = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.CancelOnExit = False
        OptionsData.Editing = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.Footer = True
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        Preview.Visible = True
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridSorguView
      end
    end
    object cxSplitter2: TcxSplitter
      Left = 192
      Top = 1
      Width = 8
      Height = 400
      HotZoneClassName = 'TcxMediaPlayer9Style'
      AlignSplitter = salRight
      Control = PageControlKalite
      ExplicitLeft = -233
      ExplicitHeight = 187
    end
    object PageControlKalite: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 200
      Top = 1
      Width = 675
      Height = 400
      Align = alRight
      TabOrder = 2
      Properties.ActivePage = TabSheetKontrol
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControlKaliteChange
      ExplicitLeft = -225
      ExplicitHeight = 187
      ClientRectBottom = 396
      ClientRectLeft = 4
      ClientRectRight = 671
      ClientRectTop = 27
      object TabSheetKontrol: TcxTabSheet
        Caption = 'Kalite Kontrol'
        ImageIndex = 19
        ExplicitHeight = 156
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 661
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
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
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          ExplicitHeight = 29
          object KaliteKontrolTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'De'#287'erler'
            ImageIndex = 7
            ImageName = 'PngImage6'
            Style = tbsTextButton
            OnClick = KaliteKontrolTusClick
          end
          object KaliteKaydetTus: TToolButton
            Left = 78
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 10
            ImageName = 'PngImage9'
            OnClick = KaliteKaydetTusClick
          end
          object ToolButton1: TToolButton
            Left = 156
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 22
            ImageName = 'PngImage22'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 164
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
          end
        end
        object GridProjeDetay: TcxGrid
          Left = 0
          Top = 35
          Width = 667
          Height = 334
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
          LookAndFeel.ScrollbarMode = sbmClassic
          ExplicitHeight = 121
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
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = 'Test'
              DataBinding.FieldName = 'ETIKET'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = True
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
              Caption = 'Sonu'#231
              DataBinding.FieldName = 'BILGI'
              PropertiesClassName = 'TcxTextEditProperties'
              OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
              MinWidth = 150
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
              Width = 150
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
            object GridDetayViewLIMITBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'LIMITBIRIM'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = True
            end
            object GridDetayViewLIMIT: TcxGridDBColumn
              Caption = 'Limit'
              DataBinding.FieldName = 'LIMIT'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = True
              Width = 138
            end
            object GridDetayViewLIMITNOT: TcxGridDBColumn
              Caption = 'Notlar'
              DataBinding.FieldName = 'LIMITNOT'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = False
              Width = 186
            end
          end
          object cxGridDetay: TcxGridLevel
            GridView = GridDetayView
          end
        end
      end
      object TabSheetYorumMedya: TcxTabSheet
        Caption = 'Yorum/Medya'
        ImageIndex = 38
        ExplicitHeight = 156
        object Panel1: TPanel
          Left = 0
          Top = 308
          Width = 667
          Height = 41
          Align = alBottom
          TabOrder = 0
          ExplicitTop = 95
          object MemoChat: TcxRichEdit
            Left = 1
            Top = 1
            Align = alClient
            Properties.ScrollBars = ssVertical
            TabOrder = 1
            Height = 39
            Width = 519
          end
          object BtnMesajGonder: TcxButton
            Left = 520
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
            Left = 605
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
          Top = 349
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
          AnchorX = 667
        end
        object GridYorum: TcxGrid
          Left = 0
          Top = 0
          Width = 667
          Height = 308
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
            object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
              DataBinding.FieldName = 'EKLEMETARIHI'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Position.Width = 120
            end
            object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YAZAN'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
            end
            object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
              DataBinding.FieldName = 'ATAC'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 25
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
              DataBinding.FieldName = 'DOKUMANAD'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 300
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YORUM'
              PropertiesClassName = 'TcxRichEditProperties'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
            end
          end
          object GridYorumLevel1: TcxGridLevel
            GridView = GridYorumDBCardView1
          end
        end
      end
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 773
    Top = 443
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
  object KONTROL: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = KONTROLAfterScroll
    ParamData = <>
    Left = 171
    Top = 181
  end
  object DtsKontrol: TDataSource
    DataSet = KONTROL
    Left = 284
    Top = 131
  end
  object frxKontrol: TfrxDBDataset
    Description = 'Kontrol'
    UserName = 'Kontrol'
    CloseDataSource = False
    DataSet = KONTROL
    BCDToCurrency = False
    DataSetOptions = []
    Left = 282
    Top = 193
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupMenu1Popup
    Left = 423
    Top = 200
    object Kabul1: TMenuItem
      Tag = 1
      Caption = 'Kabul'
      ImageIndex = 15
      OnClick = Kabul1Click
    end
    object Red1: TMenuItem
      Tag = 2
      Caption = 'Red'
      ImageIndex = 15
      OnClick = Kabul1Click
    end
    object RedKabul1: TMenuItem
      Tag = 3
      Caption = 'Red / Onay'
      ImageIndex = 23
      OnClick = Kabul1Click
    end
  end
  object DtsSorgu: TDataSource
    Left = 712
    Top = 48
  end
  object DETAY: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = DETAYBeforeEdit
    ParamData = <
      item
        Name = 'Yeri'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end
      item
        Name = 'Yeri_Id'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'Bolum'
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = Null
      end>
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU,' +
        'RA.BOLUM,'
      
        'LIMIT= case when isnull(RA.LIMIT,'#39#39')<>'#39#39' then RA.LIMIT else conv' +
        'ert(nvarchar(10),'
      
        ' isnull(RA.NDALT,0))+'#39'-'#39'+convert(nvarchar(10),isnull(RA.NDUST,0)' +
        ') end'
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id '
      'and RA.BOLUM=:Bolum  '
      'order by  1')
    Left = 368
    Top = 363
  end
  object DtsDetay: TDataSource
    DataSet = DETAY
    Left = 439
    Top = 397
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
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 832
    Top = 320
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
      ImageIndex = 37
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 43
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
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
    Left = 1003
    Top = 337
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 1020
    Top = 396
  end
  object TabSorgu: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabSorguAfterScroll
    ParamData = <>
    Left = 632
    Top = 46
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
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object frxDETAY: TfrxDBDataset
    UserName = 'DETAY'
    CloseDataSource = False
    DataSet = DETAY
    BCDToCurrency = False
    DataSetOptions = []
    Left = 289
    Top = 264
  end
end


