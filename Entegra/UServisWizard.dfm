object ServisWizardDlg: TServisWizardDlg
  Left = 0
  Top = 0
  ActiveControl = EditServisNo
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Servis Sihirbaz'#305
  ClientHeight = 637
  ClientWidth = 1370
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object Label6: TLabel
    Left = 93
    Top = 32
    Width = 11
    Height = 18
    Caption = 'ID'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 177
    Height = 637
    Align = alLeft
    Color = 14540253
    ParentBackground = False
    TabOrder = 0
    object TreeListGecmisServisler: TcxDBTreeList
      Left = 1
      Top = 205
      Width = 175
      Height = 431
      Align = alClient
      Bands = <
        item
        end>
      DataController.DataSource = DtsGecmisServisler
      DataController.ParentField = 'USTID'
      DataController.KeyField = 'ALTID'
      LookAndFeel.ScrollbarMode = sbmClassic
      Navigator.Buttons.CustomButtons = <>
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsSelection.CellSelect = False
      OptionsView.ScrollBars = ssVertical
      OptionsView.Headers = False
      RootValue = -1
      ScrollbarAnnotations.CustomAnnotations = <>
      Styles.Background = Tablo.cxStyle15
      TabOrder = 0
      OnClick = TreeListGecmisServislerClick
      object TreeListGecmisServislerUSTID: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'USTID'
        Width = 100
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListGecmisServislerALTID: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'ALTID'
        Width = 100
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListGecmisServislerTARIH: TcxDBTreeListColumn
        DataBinding.FieldName = 'TARIH'
        Width = 110
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListGecmisServislerDURUM: TcxDBTreeListColumn
        DataBinding.FieldName = 'DURUM'
        Width = 89
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListGecmisServislerID: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'ID'
        Width = 100
        Position.ColIndex = 4
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 175
      Height = 204
      Align = alTop
      Caption = 'Panel2'
      TabOrder = 1
      object Label2: TLabel
        Left = 94
        Top = 156
        Width = 20
        Height = 18
        Caption = 'Son'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object btnServis: TcxButton
        Left = 27
        Top = 49
        Width = 100
        Height = 29
        Caption = 'Servis'
        TabOrder = 0
        OnClick = btnServisClick
      end
      object btnDetay: TcxButton
        Tag = 1
        Left = 27
        Top = 83
        Width = 100
        Height = 29
        Caption = 'Detay'
        TabOrder = 1
        OnClick = btnDetayClick
      end
      object cxLabel3: TcxLabel
        Left = 3
        Top = 180
        Caption = #214'nceki Servisler'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboSay: TcxComboBox
        Left = 120
        Top = 153
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          '10'
          '20'
          '30'
          '40+')
        TabOrder = 3
        Text = '10'
        Width = 54
      end
    end
  end
  object WizardKontrol: TJvWizard
    Left = 185
    Top = 0
    Width = 1185
    Height = 637
    ActivePage = ServisEkr
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
      1185
      637)
    object ServisEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Servis bilgileri'
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
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnLastButtonClick = ServisEkrLastButtonClick
      OnFinishButtonClick = ServisEkrFinishButtonClick
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        1185
        595)
      object ServisPageControl: TcxPageControl
        Left = 0
        Top = 242
        Width = 1185
        Height = 353
        Align = alClient
        TabOrder = 4
        Properties.ActivePage = SheetHareketlerAlt
        Properties.CustomButtons.Buttons = <>
        OnChange = ServisPageControlChange
        ClientRectBottom = 349
        ClientRectLeft = 4
        ClientRectRight = 1181
        ClientRectTop = 27
        object SheetHareketlerAlt: TcxTabSheet
          Caption = 'Hareketler'
          ImageIndex = 4
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PanelYorumMedya: TPanel
            Left = 595
            Top = 0
            Width = 582
            Height = 322
            Align = alClient
            Caption = 'PanelYorumMedya'
            TabOrder = 0
            object ToolBarYorum: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 574
              Height = 24
              Margins.Bottom = 0
              AutoSize = True
              ButtonWidth = 100
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
              object YorumEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yorum Ekle'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsTextButton
                OnClick = YorumEkleTusClick
              end
              object YorumSil: TToolButton
                Left = 100
                Top = 0
                Caption = 'Yorum Sil'
                ImageIndex = 5
                ImageName = 'PngImage5'
                Style = tbsTextButton
                OnClick = YorumSilClick
              end
              object YorumDuzenle: TToolButton
                Tag = 3
                Left = 200
                Top = 0
                Caption = 'Yorum D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                Style = tbsTextButton
                OnClick = YorumDzenle1Click
              end
            end
            object Panel4: TPanel
              Left = 1
              Top = 280
              Width = 580
              Height = 41
              Align = alBottom
              TabOrder = 1
              object MemoChat: TcxRichEdit
                Left = 1
                Top = 1
                Align = alClient
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 39
                Width = 432
              end
              object BtnMesajGonder: TcxButton
                Left = 433
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
                Left = 518
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
              Left = 1
              Top = 260
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
              ExplicitTop = 259
              AnchorX = 581
            end
            object GridYorum: TcxGrid
              Left = 1
              Top = 28
              Width = 580
              Height = 232
              Align = alClient
              PopupMenu = PopupYorumlar
              TabOrder = 3
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridYorumDBCardView1: TcxGridDBCardView
                OnKeyUp = GridYorumDBCardView1KeyUp
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
          object PanelHrkt: TPanel
            Left = 0
            Top = 0
            Width = 587
            Height = 322
            Align = alLeft
            Caption = 'PanelHrkt'
            TabOrder = 1
            object GridHareketler: TcxGrid
              Left = 1
              Top = 28
              Width = 585
              Height = 293
              Align = alClient
              TabOrder = 0
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridHareketlerDBTableView1: TcxGridDBTableView
                OnDblClick = GridHareketlerDBTableView1DblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsHareketler
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.CellHints = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsSelection.HideFocusRectOnExit = False
                OptionsSelection.InvertSelect = False
                OptionsSelection.UnselectFocusedRecordOnExit = False
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridHareketlerDBTableView1DURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repServisDurum
                end
                object GridHareketlerDBTableView1PERSONEL: TcxGridDBColumn
                  Caption = 'Personel'
                  DataBinding.FieldName = 'PERSONEL'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repGenelPersonelListesiHerkes
                end
                object GridHareketlerDBTableView1BASLAMA: TcxGridDBColumn
                  Caption = 'Ba'#351'lama'
                  DataBinding.FieldName = 'BASLAMA'
                  DataBinding.IsNullValueType = True
                  SortIndex = 0
                  SortOrder = soAscending
                end
                object GridHareketlerDBTableView1BITIS: TcxGridDBColumn
                  Caption = 'Biti'#351
                  DataBinding.FieldName = 'BITIS'
                  DataBinding.IsNullValueType = True
                end
                object GridHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxLabelProperties'
                  Properties.WordWrap = True
                  Width = 155
                end
                object GridHareketlerDBTableView1UYARITURU: TcxGridDBColumn
                  Caption = #304#231
                  DataBinding.FieldName = 'UYARITURU'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repUyariTurleri
                  Width = 24
                end
                object GridHareketlerDBTableView1DISUYARITURU: TcxGridDBColumn
                  Caption = 'D'#305#351
                  DataBinding.FieldName = 'DISUYARITURU'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repUyariTurleri
                  Width = 24
                end
                object GridHareketlerDBTableView1SURE: TcxGridDBColumn
                  Caption = 'S'#252're'
                  DataBinding.FieldName = 'SURE'
                  DataBinding.IsNullValueType = True
                end
              end
              object GridHareketlerLevel1: TcxGridLevel
                GridView = GridHareketlerDBTableView1
              end
            end
            object ToolBarHareketler: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 579
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
              object BtnHareketlerYeni: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = BtnHareketlerYeniClick
              end
              object BtnHareketlerSil: TToolButton
                Left = 66
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = BtnHareketlerSilClick
              end
              object ToolButton6: TToolButton
                Left = 132
                Top = 0
                Width = 8
                Caption = 'ToolButton4'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object BtnHareketlerKaydet: TToolButton
                Left = 140
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = BtnHareketlerKaydetClick
              end
              object BtnHareketlerIptal: TToolButton
                Left = 206
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = BtnHareketlerIptalClick
              end
              object BtnHareketlerDuzenle: TToolButton
                Left = 272
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = GridHareketlerDBTableView1DblClick
              end
              object ToolButton3: TToolButton
                Left = 338
                Top = 0
                Width = 8
                Caption = 'ToolButton3'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsSeparator
              end
            end
          end
          object cxSplitterHareket: TcxSplitter
            Left = 587
            Top = 0
            Width = 8
            Height = 322
            HotZoneClassName = 'TcxMediaPlayer8Style'
            Control = PanelHrkt
          end
        end
        object SheetGenel: TcxTabSheet
          Caption = 'Genel '
          ImageIndex = 10
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object GenelTreeList: TcxDBTreeList
            Left = 0
            Top = 27
            Width = 1177
            Height = 295
            Align = alClient
            Bands = <
              item
                Caption.Text = 'aa'
              end>
            DataController.DataSource = DtsGenel
            DataController.ParentField = 'USTID'
            DataController.KeyField = 'ID'
            DefaultRowHeight = 20
            DragCursor = crDrag
            DragMode = dmAutomatic
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            LookAndFeel.SkinName = 'LondonLiquidSky'
            Navigator.Buttons.CustomButtons = <>
            OptionsBehavior.IncSearch = True
            OptionsData.SummaryNullIgnore = True
            OptionsData.SmartRefresh = True
            OptionsSelection.HideFocusRect = False
            OptionsView.CellAutoHeight = True
            OptionsView.Buttons = False
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 0
            OnBeginDragNode = GenelTreeListBeginDragNode
            OnDragOver = GenelTreeListDragOver
            object GenelTreeListROOTKOD: TcxDBTreeListColumn
              Visible = False
              Caption.AlignVert = vaTop
              DataBinding.FieldName = 'ROOTKOD'
              Width = 100
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListSERVISID: TcxDBTreeListColumn
              Visible = False
              Caption.AlignVert = vaTop
              DataBinding.FieldName = 'SERVISID'
              Width = 100
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListKOD: TcxDBTreeListColumn
              Caption.AlignVert = vaTop
              Caption.Text = 'Kod'
              DataBinding.FieldName = 'KOD'
              Width = 100
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListID: TcxDBTreeListColumn
              Visible = False
              Caption.AlignVert = vaTop
              DataBinding.FieldName = 'ID'
              Width = 100
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListGRUP: TcxDBTreeListColumn
              Styles.Content = Tablo.cxStSerinoCikilmis
              Caption.AlignVert = vaTop
              Caption.Text = 'Grup'
              DataBinding.FieldName = 'GRUP'
              Width = 100
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListSNO: TcxDBTreeListColumn
              Caption.Text = 'No'
              DataBinding.FieldName = 'SNO'
              Width = 56
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListAD: TcxDBTreeListColumn
              Caption.AlignVert = vaTop
              Caption.Text = 'Ad'
              DataBinding.FieldName = 'AD'
              Width = 100
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListACIKLAMA: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = GenelTreeListACIKLAMAPropertiesButtonClick
              Caption.AlignVert = vaTop
              Caption.Text = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              Width = 250
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object GenelTreeListCOZUM: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = GenelTreeListCOZUMPropertiesButtonClick
              Styles.Content = cxStyle1
              Caption.AlignVert = vaTop
              Caption.Text = 'Sonu'#231
              DataBinding.FieldName = 'COZUM'
              Width = 500
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object ToolBarGenel: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1171
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
            TabOrder = 1
            Transparent = True
            object ToolButton26: TToolButton
              Left = 0
              Top = 0
              Width = 8
              Caption = 'ToolButton3'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsSeparator
            end
            object GenelSilTus: TToolButton
              Left = 8
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = GenelSilTusClick
            end
            object ToolButton8: TToolButton
              Left = 86
              Top = 0
              Width = 8
              Caption = 'ToolButton8'
              ImageIndex = 1
              ImageName = 'PngImage1'
              Style = tbsSeparator
            end
            object GenelKaydetTus: TToolButton
              Left = 94
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = BtnEkipmanDetayKaydetClick
            end
            object GenelIptalTus: TToolButton
              Left = 172
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = BtnEkipmanDetayIptalClick
            end
            object ToolButton27: TToolButton
              Left = 250
              Top = 0
              Caption = 'Tam Ekran'
              ImageIndex = 6
              ImageName = 'PngImage6'
              OnClick = TamEkranTusClick
            end
            object ToolButton21: TToolButton
              Left = 328
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object CozumlerTus: TToolButton
              Left = 336
              Top = 0
              Caption = 'Sonu'#231'lar'
              ImageIndex = 22
              ImageName = 'PngImage22'
              OnClick = CozumlerTusClick
            end
          end
          object SQLGenelTekTus: TcxMemo
            Left = 280
            Top = 103
            Lines.Strings = (
              'select '
              'SB.ID,SERVISID,SB.SERVISLISTEID, '
              
                'KOD = cast(SB.SERVISTUR as varchar(5))+'#39'.'#39'+(select KOD from SERV' +
                'ISLISTE SL where SL.ID=SB.SERVISLISTEID),'
              
                'GRUP=(select top 1 ANAHTAR from GENINI G WHERE BOLUM=-3015 and D' +
                'EGER=SB.SERVISTUR),'
              
                'AD=(select AD from SERVISLISTE SL where SL.ID=SB.SERVISLISTEID),' +
                ' '
              'SB.ACIKLAMA, SB.COZUM ,SB.USTID, SB.SNO'
              ''
              'from SERVISBILGI SB'
              'where'
              'SB.SERVISTUR <>200'
              'and'
              'SERVISID=:PRM1')
            Properties.WordWrap = False
            TabOrder = 2
            Visible = False
            Height = 45
            Width = 588
          end
          object SQLKullan: TMemo
            Left = 78
            Top = 252
            Width = 480
            Height = 33
            Color = 13426846
            Lines.Strings = (
              ''
              'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
              'G'#246'rev=(select ANAHTAR from GENINI where BOLUM=-2205 and DEGER = '
              'ROL.GOREVID), '
              
                'Departman=(select ANAHTAR from GENINI where BOLUM=-2206 and DEGE' +
                'R = '
              'ROL.DEPARTMAN),'
              #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
              'Kategori='#39'Personel'#39',T'#252'r=1'
              'from REHBER R '
              'inner join KULLANICI K on R.ID=K.REHBERID '
              'left outer join ROLLER ROL on ROL.ID=R.SINIF'
              'where '
              'R.GRUP=335 and R.DURUM=1 '
              'order by 2'
              '')
            TabOrder = 3
            Visible = False
          end
        end
        object SheetBelgeler: TcxTabSheet
          Tag = 250
          Caption = 'Belgeler'
          ImageIndex = 1
          object ToolBar8: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1171
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
            TabOrder = 0
            Transparent = True
            object BtnBelgelerYeni: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              DropdownMenu = PopupYeniBelge
              ImageIndex = 0
              ImageName = 'PngImage0'
              PopupMenu = PopupYeniBelge
            end
            object BtnBelgelerSil: TToolButton
              Left = 66
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = BtnBelgelerSilClick
            end
            object BtnBelgelerDuzenle: TToolButton
              Left = 132
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = BtnBelgelerDuzenleClick
            end
          end
          object PanelPlanlananAlt: TPanel
            Left = 0
            Top = 214
            Width = 1177
            Height = 108
            Align = alBottom
            Color = 11776947
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentBackground = False
            ParentFont = False
            TabOrder = 1
            DesignSize = (
              1177
              108)
            object GridFaturaToplam: TStringGrid
              Left = 30769
              Top = -6
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
          end
          object cxGridBelgeler: TcxGrid
            Left = 0
            Top = 27
            Width = 1177
            Height = 187
            Align = alClient
            TabOrder = 2
            LookAndFeel.ScrollbarMode = sbmClassic
            object cxGridBelgelerDBTableView1: TcxGridDBTableView
              PopupMenu = PopupBelgeDonusum
              OnDblClick = cxGridBelgelerDBTableView1DblClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsServisBelge
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.HideFocusRectOnExit = False
              OptionsSelection.InvertSelect = False
              OptionsSelection.UnselectFocusedRecordOnExit = False
              OptionsView.GroupByBox = False
              object cxGridBelgelerDBTableView1TUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepKasaTurleri
                Width = 78
              end
              object cxGridBelgelerDBTableView1KAYNAK: TcxGridDBColumn
                Caption = 'Kaynak Belge'
                DataBinding.FieldName = 'KAYNAK'
                DataBinding.IsNullValueType = True
                Width = 105
              end
              object cxGridBelgelerDBTableView1HEDEF: TcxGridDBColumn
                Caption = 'Hedef Belge'
                DataBinding.FieldName = 'HEDEF'
                DataBinding.IsNullValueType = True
                Width = 98
              end
              object cxGridBelgelerDBTableView1TARIH: TcxGridDBColumn
                Caption = 'Tarih'
                DataBinding.FieldName = 'TARIH'
                DataBinding.IsNullValueType = True
                Width = 69
              end
              object cxGridBelgelerDBTableView1BELGENO: TcxGridDBColumn
                Caption = 'Belgeno'
                DataBinding.FieldName = 'BELGENO'
                DataBinding.IsNullValueType = True
              end
              object cxGridBelgelerDBTableView1TUTAR: TcxGridDBColumn
                Caption = 'Tutar'
                DataBinding.FieldName = 'TUTAR'
                DataBinding.IsNullValueType = True
                Width = 106
              end
              object cxGridBelgelerDBTableView1KUR: TcxGridDBColumn
                Caption = 'Kur'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
              end
              object cxGridBelgelerDBTableView1FIRMA: TcxGridDBColumn
                Caption = 'Firma'
                DataBinding.FieldName = 'FIRMA'
                DataBinding.IsNullValueType = True
                Width = 133
              end
              object cxGridBelgelerDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 280
              end
            end
            object cxGridBelgelerLevel1: TcxGridLevel
              GridView = cxGridBelgelerDBTableView1
            end
          end
        end
      end
      object LabelKod: TcxLabel
        Left = 124
        Top = 3
        Cursor = crHandPoint
        Caption = 'Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
      end
      object LabelAd: TcxLabel
        Left = 124
        Top = 35
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.ShowEndEllipsis = True
        Transparent = True
        OnClick = LabelAdClick
        Height = 28
        Width = 596
      end
      object cxDBLabel5: TcxDBLabel
        Left = 6
        Top = 44
        Align = alCustom
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsServis
        Transparent = True
        Height = 21
        Width = 106
      end
      object PanelUst: TPanel
        Left = 0
        Top = 70
        Width = 1185
        Height = 172
        Align = alTop
        BevelOuter = bvNone
        Color = clSilver
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object cxDBLabel6: TcxDBLabel
          Left = 487
          Top = 48
          DataBinding.DataField = 'MUS_ILGILI'
          DataBinding.DataSource = DtsServis
          Visible = False
          Height = 21
          Width = 56
        end
        object PanelSolBilgi: TPanel
          Left = 0
          Top = 0
          Width = 543
          Height = 172
          Align = alLeft
          Color = clSilver
          ParentBackground = False
          TabOrder = 0
          object LabelFatNo: TcxLabel
            Left = 5
            Top = 37
            Caption = 'Servis No*'
            Transparent = True
          end
          object EditServisNo: TcxDBTextEdit
            Left = 82
            Top = 32
            DataBinding.DataField = 'SERVISNO'
            DataBinding.DataSource = DtsServis
            TabOrder = 0
            Width = 103
          end
          object LabelKonusu: TcxLabel
            Left = 6
            Top = 60
            Cursor = crHandPoint
            Hint = 'Servis_Konusu'
            HelpType = htKeyword
            HelpKeyword = 'SERVIS.KONUSU'
            Caption = 'Konusu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelKonusuClick
          end
          object cxLabel20: TcxLabel
            Left = 5
            Top = 81
            Caption = #220'r'#252'n Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditSERINO: TcxDBTextEdit
            Left = 345
            Top = 79
            DataBinding.DataField = 'SERINO'
            DataBinding.DataSource = DtsServis
            TabOrder = 2
            Width = 194
          end
          object BEUrunAdi: TcxButtonEdit
            Left = 82
            Top = 79
            ParentShowHint = False
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
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = cxDBButtonEdit1PropertiesButtonClick
            ShowHint = True
            TabOrder = 1
            Width = 220
          end
          object LabelSeriNo: TcxLabel
            Left = 307
            Top = 81
            HelpType = htKeyword
            Caption = 'Serino'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel7: TcxLabel
            Left = 5
            Top = 149
            Caption = 'Bildirim Yapan'
            Transparent = True
          end
          object BEMusIlgili: TcxButtonEdit
            Tag = 1
            Left = 82
            Top = 145
            ParentShowHint = False
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
            Properties.MaxLength = 0
            Properties.OnButtonClick = BEBildirimYapanPropertiesButtonClick
            ShowHint = True
            TabOrder = 3
            Text = ' '
            TextHint = 'MUS_ILGILI'
            Width = 220
          end
          object cxLabel1: TcxLabel
            Left = 307
            Top = 35
            Cursor = crHandPoint
            Hint = 'Servis_Kabul_Sekli'
            HelpType = htKeyword
            HelpKeyword = 'SERVIS.TESLIM_SEKLI'
            Caption = 'T'#252'r'#252
            FocusControl = CBServisTuru
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelKonusuClick
          end
          object CBServisTuru: TcxDBImageComboBox
            Left = 345
            Top = 32
            RepositoryItem = Tablo.repServisTuru
            DataBinding.DataField = 'TURU'
            DataBinding.DataSource = DtsServis
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 10
            Width = 194
          end
          object LabelLokasyon: TcxLabel
            Left = 5
            Top = 125
            Caption = 'Lokasyon'
            Transparent = True
          end
          object BELokasyon: TcxButtonEdit
            Left = 82
            Top = 123
            ParentShowHint = False
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
            Properties.MaxLength = 0
            Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
            ShowHint = True
            TabOrder = 12
            Width = 220
          end
          object cxDBMemo1: TcxDBMemo
            Left = 345
            Top = 102
            DataBinding.DataField = 'NOTLAR'
            DataBinding.DataSource = DtsServis
            Properties.ScrollBars = ssVertical
            TabOrder = 13
            Height = 67
            Width = 194
          end
          object cxLabel13: TcxLabel
            Left = 307
            Top = 102
            Caption = 'Notlar'
            Transparent = True
          end
          object BeditKonusu: TcxDBButtonEdit
            Left = 82
            Top = 56
            DataBinding.DataField = 'KONUSU'
            DataBinding.DataSource = DtsServis
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = BeditKonusuPropertiesButtonClick
            Style.Color = clMoneyGreen
            TabOrder = 15
            Width = 457
          end
          object PanelKaydet: TPanel
            Left = 1
            Top = 1
            Width = 541
            Height = 30
            Align = alTop
            Caption = 'PanelKaydet'
            TabOrder = 16
            object JvNavPanelHeader5: TJvNavPanelHeader
              Left = 77
              Top = 1
              Width = 463
              Height = 28
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
              object ComboGaranti: TcxDBImageComboBox
                Left = 63
                Top = 3
                RepositoryItem = Tablo.repServisKapsam
                DataBinding.DataField = 'KAPSAM'
                DataBinding.DataSource = DtsServis
                ParentFont = False
                Properties.Items = <>
                Style.Color = clSilver
                TabOrder = 0
                Width = 157
              end
              object CheckBoxDISSERVIS: TcxDBCheckBox
                Left = 235
                Top = 6
                Caption = 'D'#305#351' Servis'
                DataBinding.DataField = 'DISSERVIS'
                DataBinding.DataSource = DtsServis
                ParentBackground = False
                ParentColor = False
                ParentFont = False
                Style.Color = clSilver
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clNavy
                Style.Font.Height = -13
                Style.Font.Name = 'Tahoma'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                TabOrder = 1
              end
              object CheckBoxACIL: TcxDBCheckBox
                Left = 322
                Top = 6
                Caption = 'AC'#304'L'
                DataBinding.DataField = 'ACIL'
                DataBinding.DataSource = DtsServis
                ParentColor = False
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clRed
                Style.Font.Height = -13
                Style.Font.Name = 'Tahoma'
                Style.Font.Style = [fsBold]
                Style.LookAndFeel.Kind = lfOffice11
                Style.LookAndFeel.NativeStyle = True
                Style.TransparentBorder = True
                Style.IsFontAssigned = True
                StyleDisabled.LookAndFeel.Kind = lfOffice11
                StyleDisabled.LookAndFeel.NativeStyle = True
                StyleDisabled.TextColor = clRed
                StyleFocused.LookAndFeel.Kind = lfOffice11
                StyleFocused.LookAndFeel.NativeStyle = True
                StyleHot.LookAndFeel.Kind = lfOffice11
                StyleHot.LookAndFeel.NativeStyle = True
                StyleReadOnly.LookAndFeel.Kind = lfOffice11
                StyleReadOnly.LookAndFeel.NativeStyle = True
                TabOrder = 2
                Transparent = True
              end
              object cxDBCheckBox1: TcxDBCheckBox
                Left = 376
                Top = 6
                Caption = #214'nemli'
                DataBinding.DataField = 'ONEMLI'
                DataBinding.DataSource = DtsServis
                ParentBackground = False
                ParentColor = False
                ParentFont = False
                Style.Color = clSilver
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clRed
                Style.Font.Height = -13
                Style.Font.Name = 'Tahoma'
                Style.Font.Style = [fsBold]
                Style.LookAndFeel.NativeStyle = True
                Style.IsFontAssigned = True
                StyleDisabled.LookAndFeel.NativeStyle = True
                StyleFocused.LookAndFeel.NativeStyle = True
                StyleHot.LookAndFeel.NativeStyle = True
                StyleReadOnly.LookAndFeel.NativeStyle = True
                TabOrder = 3
              end
            end
            object ToolBar3: TToolBar
              Left = 1
              Top = 1
              Width = 76
              Height = 28
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 30
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
              Font.Name = 'Arial'
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
                ImageName = 'PngImage15'
                Style = tbsTextButton
              end
              object ToolButton10: TToolButton
                Left = 66
                Top = 0
                Width = 8
                Caption = 'ToolButton10'
                ImageIndex = 20
                ImageName = 'PngImage20'
                Style = tbsSeparator
              end
            end
          end
          object cxDBDateEdit1: TcxDBDateEdit
            Left = 182
            Top = 32
            DataBinding.DataField = 'TARIH'
            DataBinding.DataSource = DtsServis
            Properties.ClearKey = 46
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Style.Color = clSilver
            TabOrder = 17
            OnKeyDown = DateTESLIMTARIHIKeyDown
            Width = 120
          end
          object LabelProje: TcxLabel
            Left = 5
            Top = 103
            Caption = 'Proje'
            Transparent = True
          end
          object BeditProje: TcxButtonEdit
            Left = 82
            Top = 101
            ParentShowHint = False
            Properties.Buttons = <
              item
                Caption = '++'
                Default = True
                Kind = bkText
              end
              item
                Caption = '+'
                Kind = bkText
              end
              item
                Caption = '-'
                Hint = 'Temizle'
                Kind = bkText
              end>
            Properties.MaxLength = 0
            Properties.OnButtonClick = BeditProjePropertiesButtonClick
            ShowHint = True
            TabOrder = 19
            OnDblClick = BeditProjeDblClick
            Width = 220
          end
        end
        object PageControl1: TcxPageControl
          Left = 543
          Top = 0
          Width = 642
          Height = 172
          Align = alClient
          TabOrder = 1
          Properties.ActivePage = SheetTeslim
          Properties.CustomButtons.Buttons = <>
          Properties.NavigatorPosition = npLeftBottom
          Properties.TabSlants.Positions = [spLeft, spRight]
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          OnChange = PageControl1Change
          ClientRectBottom = 168
          ClientRectLeft = 4
          ClientRectRight = 638
          ClientRectTop = 27
          object SheetTeslim: TcxTabSheet
            Caption = 'Teslim'
            Color = clGray
            ImageIndex = 1
            ParentColor = False
            object cxLabel14: TcxLabel
              Left = 5
              Top = 7
              Cursor = crHandPoint
              Hint = 'Servis_Teslim_Sekli'
              HelpType = htKeyword
              HelpKeyword = 'SERVIS.TESLIM_SEKLI'
              Caption = 'Teslim '#350'ekli/Tarihi'
              FocusControl = CBTeslimSekli
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsUnderline]
              Style.IsFontAssigned = True
              Transparent = True
              OnClick = LabelKonusuClick
            end
            object CBTeslimSekli: TcxDBImageComboBox
              Left = 134
              Top = 5
              RepositoryItem = Tablo.repServisKabulSekli
              DataBinding.DataField = 'TESLIM_SEKLI'
              DataBinding.DataSource = DtsServis
              Properties.ImmediatePost = True
              Properties.Items = <>
              Properties.OnCloseUp = CBTeslimSekliPropertiesCloseUp
              TabOrder = 0
              Width = 131
            end
            object cxLabel15: TcxLabel
              Left = 5
              Top = 34
              Caption = 'Teslim Alan / Teslim Eden'
              Transparent = True
            end
            object BETeslimAlan: TcxButtonEdit
              Tag = 1
              Left = 134
              Top = 31
              ParentShowHint = False
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
              Properties.MaxLength = 0
              Properties.ReadOnly = True
              Properties.OnButtonClick = BEBildirimYapanPropertiesButtonClick
              ShowHint = True
              TabOrder = 3
              TextHint = 'TESLIM_ALAN'
              Width = 131
            end
            object BETeslimEden: TcxButtonEdit
              Left = 273
              Top = 31
              ParentShowHint = False
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
              Properties.MaxLength = 0
              Properties.ReadOnly = True
              ShowHint = True
              TabOrder = 5
              TextHint = 'TESLIM_EDEN'
              Width = 126
            end
            object cxLabel23: TcxLabel
              Left = 5
              Top = 88
              Caption = 'A'#231#305'klama'
              Transparent = True
            end
            object EditKargoNo: TcxDBTextEdit
              Left = 134
              Top = 87
              DataBinding.DataField = 'TESLIMNOTU'
              DataBinding.DataSource = DtsServis
              TabOrder = 7
              Width = 249
            end
            object DateTESLIMTARIHI: TcxDBDateEdit
              Left = 273
              Top = 5
              DataBinding.DataField = 'TESLIM_TARIHI'
              DataBinding.DataSource = DtsServis
              Properties.ClearKey = 46
              Properties.DateButtons = [btnClear, btnNow, btnToday]
              Properties.ImmediatePost = True
              Properties.Kind = ckDateTime
              TabOrder = 1
              OnKeyDown = DateTESLIMTARIHIKeyDown
              Width = 126
            end
            object lblSevkAdresi: TcxLabel
              Left = 7
              Top = 63
              Caption = 'Servis Adresi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object btnSevkAdresi: TcxButtonEdit
              Left = 134
              Top = 59
              ParentShowHint = False
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
              Properties.OnButtonClick = btnSevkAdresiPropertiesButtonClick
              ShowHint = True
              TabOrder = 9
              TextHint = 'SERVISADRESI'
              Width = 196
            end
            object cbStokDepo: TcxDBImageComboBox
              Left = 134
              Top = 114
              RepositoryItem = Tablo.RepStokDepolarAktif
              DataBinding.DataField = 'DEPO'
              DataBinding.DataSource = DtsServis
              Properties.ImageAlign = iaRight
              Properties.ImmediatePost = True
              Properties.Items = <>
              TabOrder = 10
              Width = 110
            end
            object lbDepo: TcxLabel
              Left = 5
              Top = 116
              Caption = 'Depo'
              Transparent = True
            end
          end
          object EkAlanlarEkr: TcxTabSheet
            Caption = 'Ek Alanlar'
            ImageIndex = 4
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
          end
          object SheetOzellik: TcxTabSheet
            Caption = #214'zellikler'
            ImageIndex = 5
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object GridEkEkipman: TcxGrid
              Left = 0
              Top = 0
              Width = 634
              Height = 141
              Align = alClient
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object GridEkEkipmanView: TcxGridDBTableView
                OnDblClick = GridEkEkipmanViewDblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsEkipmanEkBilgi
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsView.ColumnAutoWidth = True
                OptionsView.GridLines = glNone
                OptionsView.GroupByBox = False
                OptionsView.Header = False
                Styles.Background = cxStyle2
                Styles.Content = cxStyle2
                Styles.Header = cxStyle2
                Styles.Inactive = cxStyle2
                object cxGridDBColumn8: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  MinWidth = 125
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
                  Options.Sorting = False
                  Width = 125
                end
                object cxGridDBColumn11: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  DataBinding.IsNullValueType = True
                  MinWidth = 250
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
                  Options.Sorting = False
                  Width = 250
                end
              end
              object cxGridLevel11: TcxGridLevel
                GridView = GridEkEkipmanView
              end
            end
          end
        end
      end
      object ComboSube: TcxDBImageComboBox
        Left = 760
        Top = 40
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        DataBinding.DataField = 'SUBEID'
        DataBinding.DataSource = DtsServis
        Properties.Items = <>
        TabOrder = 5
        Width = 164
      end
      object CheckKapali: TcxDBCheckBox
        Left = 930
        Top = 44
        Caption = 'Kapal'#305
        DataBinding.DataField = 'ACKAPA'
        DataBinding.DataSource = DtsServis
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        Properties.ReadOnly = False
        Style.Color = clSilver
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        TabOrder = 7
        Transparent = True
        OnClick = CheckKapaliClick
      end
      object lblMusteriAdres: TcxLabel
        Left = 313
        Top = 3
        AutoSize = False
        Caption = 'Adres'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Height = 43
        Width = 331
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 1104
        Top = 4
        RepositoryItem = Tablo.repServisDurum
        Anchors = [akTop, akRight]
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsServis
        Enabled = False
        Properties.ImmediatePost = True
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
        Properties.ReadOnly = True
        Style.Color = clAqua
        StyleDisabled.Color = clSkyBlue
        TabOrder = 8
        Width = 136
      end
      object lblMusteriTel: TcxLabel
        Left = 703
        Top = 1
        Caption = 'Tel'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lblMusteriEposta: TcxLabel
        Left = 704
        Top = 15
        Caption = 'Eposta'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object DetayEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #350'ablondan girmek istedi'#287'iniz detay'#305' se'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnPage = DetayEkrPage
      OnExitPage = DetayEkrExitPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 1185
        Height = 525
        Align = alClient
        BevelOuter = bvNone
        Color = 14540253
        ParentBackground = False
        TabOrder = 2
        object GridProjeDetay: TcxGrid
          Left = 0
          Top = 27
          Width = 1185
          Height = 498
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
            object cxGridDBColumn1: TcxGridDBColumn
              Caption = 'Etiketi'
              DataBinding.FieldName = 'ETIKET'
              DataBinding.IsNullValueType = True
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
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Bilgisi'
              DataBinding.FieldName = 'BILGI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              OnGetPropertiesForEdit = cxGridDBColumn2GetPropertiesForEdit
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
              Width = 400
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
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1179
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
          object YeniTemelTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
          end
          object SilTemelTus: TToolButton
            Left = 48
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
          end
        end
        object SQLDetay: TcxMemo
          Left = 98
          Top = 86
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
          TabOrder = 2
          Visible = False
          Height = 264
          Width = 387
        end
      end
      object LabelSablon: TcxLabel
        Left = 15
        Top = 45
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = LabelSablonClick
      end
      object ComboBolum: TcxDBComboBox
        Left = 92
        Top = 44
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsServis
        Properties.ImmediatePost = True
        Properties.MaxLength = 0
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 0
        Width = 153
      end
    end
  end
  object cxDBLabel4: TcxDBLabel
    Left = 191
    Top = 25
    Align = alCustom
    DataBinding.DataField = 'ID'
    DataBinding.DataSource = DtsServis
    Transparent = True
    Height = 21
    Width = 106
  end
  object cxSplitter2: TcxSplitter
    Left = 177
    Top = 0
    Width = 8
    Height = 637
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = Panel1
  end
  object OpenDialog1: TOpenDialog
    Left = 113
    Top = 290
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 45
    Top = 123
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
  object TabServis: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabServisAfterOpen
    BeforeEdit = TabEkipmanDetayBeforeEdit
    BeforePost = TabServisBeforePost
    AfterPost = TabServisAfterPost
    BeforeDelete = TabEkipmanDetayBeforeDelete
    OnNewRecord = TabServisNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM '
      #9'SERVIS'
      'WHERE '
      #9'ID=:PID')
    Left = 12
    Top = 348
  end
  object DtsServis: TDataSource
    DataSet = TabServis
    Left = 12
    Top = 400
  end
  object PopupMenuYaz: TPopupMenu
    Left = 101
    Top = 551
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
  object frxServis: TfrxDBDataset
    UserName = 'Servis'
    CloseDataSource = False
    DataSet = SERVIS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 10
    Top = 452
  end
  object PopupMenuKopya: TPopupMenu
    Left = 336
    Top = 456
    object MenuButunServisKopyala: TMenuItem
      Caption = 'B'#252't'#252'n Servisi kopyala'
      ImageIndex = 0
    end
    object MenuSadeceDetay: TMenuItem
      Tag = 1
      Caption = 'Sadece detay sat'#305'rlar'#305' kopyala'
      ImageIndex = 1
    end
  end
  object TabServisBelge: TFDQuery
    AutoCalcFields = False
    AfterScroll = TabServisBelgeAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @ServisID int'
      'set @ServisID=:PSerID'
      ''
      
        'select TUR=80,ID,TARIH,BELGENO=TEKLIFNO,TUTAR=DOVIZ_TUTARI,KUR=D' +
        'OVIZ_KURU,ACIKLAMA,'
      #9'FIRMA=(select R.FIRMA from REHBER R where R.ID=T.REHBERID),'
      #9'KAYNAK='#39#39','
      
        #9'HEDEF = case when 412 in (select YERI from SIPARISDETAY where Y' +
        'ERID in (select ID from TEKLIFDETAY where TEKLIFID=T.ID)) then '#39 +
        'Verilen Sipari'#351' '#39' else '#39#39' end '
      
        #9#9'  + case when 413 in (select YERI from SIPARISDETAY where YERI' +
        'D in (select ID from TEKLIFDETAY where TEKLIFID=T.ID)) then '#39'Al'#305 +
        'nan Sipari'#351#39' else '#39#39' end '
      'from TEKLIF T where SERVISID=@ServisID'
      ''
      'union all'
      ''
      
        'select TUR,ID,TARIH,BELGENO=SIPARISNO,TUTAR=SIPARIS_TUTARI,KUR,A' +
        'CIKLAMA,'
      #9'FIRMA=(select R.FIRMA from REHBER R where R.ID=S.REHBERID),'
      
        #9'KAYNAK = case when (S.TUR=9)and(412 in (select YERI from SIPARI' +
        'SDETAY where SIPARISID=S.ID)) then '#39'Teklifden'#39
      
        #9#9#9'when (S.TUR=19)and(413 in (select YERI from SIPARISDETAY wher' +
        'e SIPARISID=S.ID)) then '#39'Teklifden'#39
      #9#9#9'else '#39#39' end, '
      #9'HEDEF = case '
      
        #9#9#9'when (S.TUR=9)and(407 in (select YERI from FATURA where YERID' +
        ' in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39'F' +
        'aturaya'#39
      
        #9#9#9'when (S.TUR=9)and(406 in (select YERI from FATURA where YERID' +
        ' in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39#304 +
        'rsaliyeye'#39
      
        #9#9#9'when (S.TUR=19)and(410 in (select YERI from FATURA where YERI' +
        'D in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39 +
        'Faturaya'#39
      
        #9#9#9'when (S.TUR=19)and(409 in (select YERI from FATURA where YERI' +
        'D in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39 +
        #304'rsaliyeye'#39
      
        #9#9#9'when (S.TUR=19)and(415 in (select YERI from FATURA where YERI' +
        'D in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39 +
        #220'retim Fi'#351'ine'#39
      
        #9#9#9'when (S.TUR=19)and(420 in (select YERI from FATURA where YERI' +
        'D in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then '#39 +
        #220'retim Fi'#351'ine'#39
      #9#9#9'else '#39#39' end   '
      'from SIPARIS S where SERVISID=@ServisID'
      ''
      'union all '
      ''
      
        'select TUR,ID,TARIH,BELGENO=FATURANO,TUTAR=FATURA_TUTARI,KUR,ACI' +
        'KLAMA,'
      #9'FIRMA=(select R.FIRMA from REHBER R where R.ID=F.REHBERID),'
      #9'KAYNAK = case '
      
        #9#9#9'when (F.TUR=10)and(406 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Sipari'#351'ten'#39
      
        #9#9#9'when (F.TUR=14)and(409 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Sipari'#351'ten'#39
      
        #9#9#9'when (F.TUR=11)and(407 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Sipari'#351'ten'#39
      
        #9#9#9'when (F.TUR=11)and(408 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39#304'rsaliyeden'#39
      
        #9#9#9'when (F.TUR=15)and(410 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Sipari'#351'ten'#39
      
        #9#9#9'when (F.TUR=15)and(411 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39#304'rsaliyeden'#39
      
        #9#9#9'when (F.TUR=11)and(461 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Konsinyeden'#39
      
        #9#9#9'when (F.TUR=15)and(462 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39'Konsinyeden'#39
      
        #9#9#9'when (F.TUR=15)and(426 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39#220'retimden'#39
      
        #9#9#9'when (F.TUR=14)and(425 in (select YERI from FATURA where FATB' +
        'ASID=F.ID)) then '#39#220'retimden'#39
      #9#9#9'else '#39#39' end,  '
      #9'HEDEF = case '
      
        #9#9#9'when (F.TUR=10)and(408 in (select YERI from FATURA where YERI' +
        'D in (select ID from FATURA where FATBASID=F.ID))) then '#39'Faturay' +
        'a'#39
      
        #9#9#9'when (F.TUR=14)and(411 in (select YERI from FATURA where YERI' +
        'D in (select ID from FATURA where FATBASID=F.ID))) then '#39'Faturay' +
        'a'#39
      
        #9#9#9'when (F.TUR=109)and(461 in (select YERI from FATURA where YER' +
        'ID in (select ID from FATURA where FATBASID=F.ID))) then '#39'Fatura' +
        'ya'#39
      
        #9#9#9'when (F.TUR=119)and(462 in (select YERI from FATURA where YER' +
        'ID in (select ID from FATURA where FATBASID=F.ID))) then '#39'Fatura' +
        'ya'#39
      #9#9#9'else '#39#39' end'
      'from FATBASLIK F where SERVISID=@ServisID')
    Left = 436
    Top = 328
  end
  object DtsServisBelge: TDataSource
    DataSet = TabServisBelge
    Left = 439
    Top = 389
  end
  object frxServisBelge: TfrxDBDataset
    UserName = 'SERVISBELGE'
    CloseDataSource = False
    DataSet = TabServisBelge
    BCDToCurrency = False
    DataSetOptions = []
    Left = 438
    Top = 432
  end
  object frxServisGenel: TfrxDBDataset
    UserName = 'ServisGenel'
    CloseDataSource = False
    DataSet = TabGenel
    BCDToCurrency = False
    DataSetOptions = []
    Left = 244
    Top = 442
  end
  object TabServisNotlar: TFDQuery
    Tag = 200
    AutoCalcFields = False
    BeforeEdit = TabEkipmanDetayBeforeEdit
    BeforePost = TabServisBeforePost
    AfterPost = TabServisAfterPost
    BeforeDelete = TabEkipmanDetayBeforeDelete
    OnCalcFields = TabServisNotlarCalcFields
    OnNewRecord = TabServisProblemNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select ID,SERVISID,EKLEMETARIHI,COZUM,EKLEYEN, SERVISTUR, ACIKLA' +
        'MA'
      'from SERVISBILGI SB'
      'Where '
      'SERVISID = :Par1'
      'and SERVISTUR=200'
      'order by ID')
    Left = 507
    Top = 354
    object TabServisNotlarID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabServisNotlarSERVISID: TIntegerField
      FieldName = 'SERVISID'
    end
    object TabServisNotlarEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabServisNotlarCOZUM: TWideStringField
      FieldName = 'COZUM'
      Size = 1000
    end
    object TabServisNotlarEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabServisNotlarEKLEYENAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'EKLEYENAD'
      Size = 50
      Calculated = True
    end
    object TabServisNotlarSERVISTUR: TSmallintField
      FieldName = 'SERVISTUR'
    end
    object TabServisNotlarACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
  end
  object DtsServisNotlar: TDataSource
    Tag = 200
    DataSet = TabServisNotlar
    OnStateChange = DtsServisNotlarStateChange
    Left = 504
    Top = 396
  end
  object frxServisNotlar: TfrxDBDataset
    UserName = 'ServisNotlar'
    CloseDataSource = False
    DataSet = TabServisNotlar
    BCDToCurrency = False
    DataSetOptions = []
    Left = 502
    Top = 455
  end
  object TabEkipmanDetay: TFDQuery
    AutoCalcFields = False
    BeforeEdit = TabEkipmanDetayBeforeEdit
    BeforePost = TabServisBeforePost
    AfterPost = TabServisAfterPost
    BeforeDelete = TabEkipmanDetayBeforeDelete
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'WITH Liste (USTID,ALTID,EKIPMANID) AS'
      '('#9'SELECT'
      #9#9'USTID=0,'
      #9#9'ALTID=ER.ID,'
      #9#9'EKIPMANID'
      #9'FROM EKIPMANREHBER ER'
      
        #9'where ER.ID= (select S.EKIPMANREHBERID from SERVIS S where S.ID' +
        '=:PServisID)'
      #9'UNION ALL'#9
      #9'SELECT'
      #9#9'USTID=P.ALTID,'
      #9#9'ALTID=ER.ID,'
      #9#9'EKIPMANID=ER.EKIPMANID'
      #9'From Liste p INNER JOIN EKIPMANREHBER ER ON ER.USTID=p.ALTID'
      ')'
      'SELECT ER.*,'
      #9'KOD=(Select KOD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      #9'AD=(Select AD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      
        'MARKAAD = (case when ER.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=-2727 and DEGER=ER.MARKA and DIL=-1)'
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
        'DEGER=ER.MARKA and DIL=-1) end) ,'
      
        'MODELAD = (case when ER.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),ER.MA' +
        'RKA)) and DEGER=ER.MODEL and DIL=-1) '
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
        't,'#39'-2701'#39'+convert(varchar(10),ER.MARKA)) and DEGER=ER.MODEL and ' +
        'DIL=-1) end),'
      ''
      
        #9'ACIKLAMA=(Select ACIKLAMA FROM EKIPMANLAR E where E.ID=ER.EKIPM' +
        'ANID) '
      'FROM '
      #9'EKIPMANREHBER ER inner join '
      #9'Liste p on p.ALTID=ER.ID ')
    Left = 174
    Top = 235
  end
  object DtsEkipmanDetay: TDataSource
    DataSet = TabEkipmanDetay
    Left = 190
    Top = 288
  end
  object frxEkipmanDetay: TfrxDBDataset
    UserName = 'EkipmanDetay'
    CloseDataSource = False
    DataSet = TabEkipmanDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 164
    Top = 491
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 64
    Top = 211
  end
  object DtsDetay: TDataSource
    Tag = 260
    DataSet = TabDetay
    Left = 567
    Top = 413
  end
  object TabDetay: TFDQuery
    Tag = 260
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU,' +
        'RA.BOLUM '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id '
      'and RA.BOLUM=:Bolum  '
      'order by  1')
    Left = 568
    Top = 363
  end
  object TabGecmisServisler: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM ('
      ''
      'select'
      
        'DISTINCT USTID=convert(varchar(15),isnull(EKIPMANID,0))+isnull(S' +
        'ERINO,'#39#39'),ALTID=convert(varchar(15),isnull(EKIPMANID,0))+isnull(' +
        'SERINO,'#39#39'),ID=0, TARIH=E.AD,DURUM=isnull(SERINO,'#39#39')'
      'from SERVIS S1 INNER JOIN EKIPMANLAR E ON S1.EKIPMANID=E.ID'
      'WHERE'
      '        REHBERID=:pRehID1'
      ''
      'union all'
      ''
      'select'
      
        'USTID=convert(varchar(15),isnull(EKIPMANID,0))+isnull(SERINO,'#39#39')' +
        ',ALTID=convert(varchar(15),isnull(EKIPMANID,0))+isnull(SERINO,'#39#39 +
        ')+'#39'.X.'#39'+isnull(SERINO,'#39'0'#39'),ID,TARIH=convert(varchar(15),'
      
        'TARIH,103),DURUM=(select ANAHTAR from GENINI where BOLUM = -3007' +
        ' and DEGER=S2.DURUM and DIL=-1 )'
      'from SERVIS S2'
      'where'
      'REHBERID = :pRehID2'
      ') AS X'
      'order by USTID,ALTID,TARIH desc'
      '')
    Left = 94
    Top = 351
    object TabGecmisServislerUSTID: TWideStringField
      FieldName = 'USTID'
      ReadOnly = True
      Size = 15
    end
    object TabGecmisServislerALTID: TWideStringField
      FieldName = 'ALTID'
      ReadOnly = True
      Size = 15
    end
    object TabGecmisServislerID: TIntegerField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGecmisServislerTARIH: TWideStringField
      FieldName = 'TARIH'
      ReadOnly = True
      Size = 100
    end
    object TabGecmisServislerDURUM: TWideStringField
      FieldName = 'DURUM'
      ReadOnly = True
      Size = 100
    end
  end
  object DtsGecmisServisler: TDataSource
    DataSet = TabGecmisServisler
    Left = 92
    Top = 399
  end
  object DtsGenel: TDataSource
    DataSet = TabGenel
    OnStateChange = DtsGenelStateChange
    Left = 245
    Top = 389
  end
  object TabGenel: TFDQuery
    Tag = 210
    AutoCalcFields = False
    AfterOpen = TabGenelAfterOpen
    Connection = Tablo.FDCnn
    Left = 245
    Top = 343
  end
  object SERVIS: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      #9'S.*,'
      
        '        BASLAMASURE=dbo.fn_TarihFarkiFormatli(S.TARIH, S.BASLAMA' +
        'TARIHI),'
      
        '        SERVISSURE=dbo.fn_TarihFarkiFormatli(S.BASLAMATARIHI,S.B' +
        'ITISTARIHI),'
      
        #9'KABUL_EDENAD=(select FIRMA from REHBER R7 where R7.ID = S.KABUL' +
        '_EDEN),'
      '        KATEGORIAD=K.AD,'
      '        EKIPMANAD=E.AD,'
      #9'R1.FIRMA,'
      #9'R2.FIRMA as SORUMLUAD,'
      #9'MUS_ILGILI,'
      #9'RP.FIRMA as MUS_ILGILIAD,'
      
        #9'LOKASYON =(select ACIKLAMA from LOKASYON L where L.ID=S.LOKASYO' +
        'NID),'
      
        #9'ONAYLAYANAD=(select FIRMA from REHBER R5 where R5.ID = S.ONAYLA' +
        'YAN),'
      
        #9'ONAYALANAD=(select FIRMA from REHBER R6 where R6.ID = S.ONAYALA' +
        'N),'
      
        #9'SERVISADRESIAD=(select RI.AD from REHBERILETISIM RI where RI.ID' +
        '=S.SERVISADRESI),'
      ''
      
        'SERVIS_ADRES=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN R' +
        'EHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YE' +
        'R_ID=S.SERVISADRESI AND RB.YERI=1 AND RA.VARSAYILAN=2),'
      
        'SERVIS_ILCE=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN RE' +
        'HBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER' +
        '_ID=S.SERVISADRESI AND RB.YERI=1 AND RA.VARSAYILAN=6),'
      
        'SERVIS_IL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.SERVISADRESI AND RB.YERI=1 AND RA.VARSAYILAN=8),'
      ''
      ''
      
        #9'EKLEYENAD=(select FIRMA from REHBER R5 where R5.ID = S.EKLEYEN)' +
        ' ,'
      
        'SERVISTURADI=(select G.ANAHTAR from GENINI G where G.BOLUM=-3006' +
        ' and G.DIL=-1 and G.DEGER=S.TURU),'
      
        #9'TESLIM_ALANAD=(select FIRMA from REHBER R5 where R5.ID = S.TESL' +
        'IM_ALAN),'
      
        #9'TESLIM_EDENAD=(select FIRMA from REHBER R6 where R6.ID = S.TESL' +
        'IM_EDEN),'
      
        #9'ONAYSEKLIAD=(select ANAHTAR from GENINI G where BOLUM=-3005 and' +
        ' G.DEGER=S.ONAYSEKLI ),'
      
        'PROJEKODU=(SELECT PROJEKODU FROM PROJELER P WHERE P.ID=S.PROJEID' +
        '),'
      
        'PROJEADI=(SELECT PROJEADI FROM PROJELER P2 WHERE P2.ID=S.PROJEID' +
        '),'
      'EKLEYENAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=S.EKLEYEN)'
      #9'--FB.FATURATARIH, FB.FATURANO,FB.FATURA_TUTARI'
      'from SERVIS S'
      'left outer join EKIPMANLAR E on E.ID=S.EKIPMANID'
      'left outer join KATEGORI K on K.ID=E.KATEGORI'
      'left outer join REHBER R1 on R1.ID=S.REHBERID'
      'left outer join REHBER R2 on R2.ID=S.SORUMLU'
      'left outer join REHBER RP on RP.ID=S.MUS_ILGILI'
      '--left outer join FATBASLIK FB on FB.ID=S.FATURAID'
      'where S.ID=:PRM1'
      '')
    Left = 53
    Top = 330
  end
  object DtsEkipmanEkBilgi: TDataSource
    DataSet = TabEkipmanEkBilgi
    Left = 630
    Top = 394
  end
  object TabEkipmanEkBilgi: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI,ID from REHBERBILGI'
      'where YERI=:Yeri_1  and YER_ID= :YerID_2 '
      'order by 1   ')
    Left = 628
    Top = 343
  end
  object TabHareketler: TFDQuery
    AfterOpen = TabHareketlerAfterOpen
    AfterPost = TabHareketlerAfterPost
    AfterScroll = TabHareketlerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *,'
      'SURE=[dbo].[fn_TarihFarkiFormatli] (BASLAMA,BITIS) '
      'from SERVISHAREKET where SERVISID=:PServisID order by ID')
    Left = 874
    Top = 340
  end
  object DtsHareketler: TDataSource
    DataSet = TabHareketler
    OnStateChange = DtsHareketlerStateChange
    Left = 883
    Top = 390
  end
  object PopupYeniBelge: TPopupMenu
    Left = 112
    Top = 496
    object eklif1: TMenuItem
      Tag = 80
      Caption = 'Teklif'
      OnClick = eklif1Click
    end
    object Sipari1: TMenuItem
      Caption = 'Sipari'#351
      object VerilenSipari1: TMenuItem
        Tag = 9
        Caption = 'Verilen Sipari'#351
        OnClick = eklif1Click
      end
      object AlnanSipari1: TMenuItem
        Tag = 19
        Caption = 'Al'#305'nan Sipari'#351
        OnClick = eklif1Click
      end
    end
    object rsaliye1: TMenuItem
      Caption = #304'rsaliye'
      object Al1: TMenuItem
        Tag = 10
        Caption = 'Al'#305#351' '#304'rsaliyesi'
        OnClick = eklif1Click
      end
      object Satrsaliyesi1: TMenuItem
        Tag = 14
        Caption = 'Sat'#305#351' '#304'rsaliyesi'
        OnClick = eklif1Click
      end
    end
    object Fatura2: TMenuItem
      Caption = 'Fatura'
      object AlFaturas1: TMenuItem
        Tag = 11
        Caption = 'Al'#305#351' Faturas'#305
        OnClick = eklif1Click
      end
      object SatFaturas1: TMenuItem
        Tag = 15
        Caption = 'Sat'#305#351' Faturas'#305
        OnClick = eklif1Click
      end
    end
    object Fi1: TMenuItem
      Caption = 'Fi'#351
      object AlFii1: TMenuItem
        Tag = 12
        Caption = 'Al'#305#351' Fi'#351'i'
        OnClick = eklif1Click
      end
      object SatFii1: TMenuItem
        Tag = 16
        Caption = 'Sat'#305#351' Fi'#351'i'
        OnClick = eklif1Click
      end
    end
  end
  object PopupBelgeDonusum: TPopupMenu
    Left = 376
    Top = 520
    object BelgeyiA1: TMenuItem
      Caption = 'Belgeyi A'#231
    end
    object KaynakBelgeyiA1: TMenuItem
      Caption = 'Kaynak Belgeyi A'#231
      OnClick = KaynakBelgeyiA1Click
    end
    object HedefBelgeyiA1: TMenuItem
      Caption = 'Hedef Belgeyi A'#231
      OnClick = HedefBelgeyiA1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object SipariOlutur1: TMenuItem
      Tag = 19
      Caption = 'Al'#305'nan Sipari'#351'e D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object VerSipariineDntr1: TMenuItem
      Tag = 9
      Caption = 'Verilen Sipari'#351'ine D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object rsaliyeOlutur2: TMenuItem
      Tag = 10
      Caption = 'Al'#305#351' '#304'rsaliyesine D'#246'n'#252#351't'#252'r'
      OnClick = SipariOlutur1Click
    end
    object FaturaOlutur1: TMenuItem
      Tag = 11
      Caption = 'Al'#305#351' Faturas'#305'na D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object FiOlutur1: TMenuItem
      Tag = 12
      Caption = 'Al'#305#351' Fi'#351'ine D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object SatrsaliyesineDntr1: TMenuItem
      Tag = 14
      Caption = 'Sat'#305#351' '#304'rsaliyesine D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object SatFaturasnaDntr1: TMenuItem
      Tag = 15
      Caption = 'Sat'#305#351' Faturas'#305'na D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
    object SatFiineDntr1: TMenuItem
      Tag = 16
      Caption = 'Sat'#305#351' Fi'#351'ine D'#246'n'#252#351't'#252'r'
      Visible = False
      OnClick = SipariOlutur1Click
    end
  end
  object TabYorum: TFDQuery
    AfterScroll = TabYorumAfterScroll
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
    Left = 1003
    Top = 337
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 1020
    Top = 396
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = YorumSilClick
    end
    object N4: TMenuItem
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
  object cxGridPopupYorumlar: TcxGridPopupMenu
    PopupMenus = <
      item
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
    Left = 712
    Top = 332
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
end
