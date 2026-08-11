object MesajlasmaDlg: TMesajlasmaDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Mesajla'#351'ma Ekran'#305
  ClientHeight = 572
  ClientWidth = 1370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 13
  object pnlMesajlasma: TPanel
    Left = 0
    Top = 0
    Width = 1370
    Height = 572
    Align = alClient
    Color = clGradientInactiveCaption
    ParentBackground = False
    TabOrder = 0
    object Panel18: TPanel
      Left = 1
      Top = 1
      Width = 1368
      Height = 24
      Align = alTop
      Color = clSkyBlue
      ParentBackground = False
      TabOrder = 0
      object Label12: TLabel
        Left = 6
        Top = 3
        Width = 70
        Height = 18
        Caption = 'Mesajla'#351'ma'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object MesajLED: TJvLED
        Left = 83
        Top = 4
        Status = False
      end
    end
    object ScrollBox2: TScrollBox
      Left = 1
      Top = 25
      Width = 408
      Height = 546
      Align = alLeft
      TabOrder = 1
      object GridPersonel: TcxGrid
        Left = 0
        Top = 31
        Width = 404
        Height = 511
        Align = alClient
        PopupMenu = MesajMenu
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridPersonelDBTableViewKisiler: TcxGridDBTableView
          PopupMenu = MesajMenu
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMesajKisiler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Images = Tablo.PNGImageList2
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.DataRowHeight = 40
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          object GridPersonelDBTableViewKisilerColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Width = 180
            IsCaptionAssigned = True
          end
          object GridPersonelDBTableViewKisilerColumn2: TcxGridDBColumn
            DataBinding.FieldName = 'OKUNMAMIS'
            DataBinding.IsNullValueType = True
            Width = 20
          end
          object GridPersonelDBTableViewKisilerColumn3: TcxGridDBColumn
            DataBinding.FieldName = 'SONMESAJ'
            DataBinding.IsNullValueType = True
          end
          object GridPersonelDBTableViewKisilerColumn4: TcxGridDBColumn
            DataBinding.FieldName = 'SONTARIH'
            DataBinding.IsNullValueType = True
          end
        end
        object GridPersonelCardView1: TcxGridCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.CardIndent = 7
          object GridPersonelCardView1Row1: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row2: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row3: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row4: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
        end
        object GridPersonelDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridPersonelDBCardView1CellClick
          OnCellDblClick = GridPersonelDBCardView1CellDblClick
          DataController.DataSource = DtsMesajKisiler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsView.CaptionSeparator = #0
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 372
          Styles.Background = Tablo.cxStyle1
          object GridPersonelDBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ADI'
            DataBinding.IsNullValueType = True
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 70
          end
          object GridPersonelDBCardView1Row4: TcxGridDBCardViewRow
            DataBinding.FieldName = 'SONTARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 60
          end
          object GridPersonelDBCardView1Row3: TcxGridDBCardViewRow
            DataBinding.FieldName = 'OKUNMAMIS'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 15
          end
          object GridPersonelDBCardView1Row2: TcxGridDBCardViewRow
            DataBinding.FieldName = 'SONMESAJ'
            DataBinding.IsNullValueType = True
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
        end
        object GridPersonelLevel1: TcxGridLevel
          GridView = GridPersonelDBCardView1
        end
      end
      object Panel10: TPanel
        Left = 0
        Top = 0
        Width = 404
        Height = 31
        Align = alTop
        TabOrder = 0
        Visible = False
        object MesajPersonAra: TcxButtonEdit
          AlignWithMargins = True
          Left = 7
          Top = 4
          Hint = 'Personel ara'
          ParentShowHint = False
          Properties.Buttons = <>
          ShowHint = True
          TabOrder = 0
          TextHint = 'Ara'
          Visible = False
          Width = 257
        end
      end
    end
    object PanelChat: TPanel
      Left = 409
      Top = 25
      Width = 960
      Height = 546
      Align = alClient
      TabOrder = 2
      object Panel4: TPanel
        Left = 1
        Top = 504
        Width = 958
        Height = 41
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 0
          OnKeyUp = MemoChatKeyUp
          Height = 39
          Width = 810
        end
        object BtnMesajGonder: TcxButton
          Left = 811
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 1
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 896
          Top = 1
          Width = 61
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
          OnClick = BtnDosyaGonderClick
        end
      end
      object GridMesaj: TcxGrid
        Left = 1
        Top = 1
        Width = 958
        Height = 503
        Align = alClient
        PopupMenu = MesajMenu
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridDBTableView1: TcxGridDBTableView
          PopupMenu = MesajMenu
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMesajKisiler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Images = Tablo.PNGImageList2
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.DataRowHeight = 40
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
        end
        object GridMesajDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMesajlar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsData.Deleting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.CaptionSeparator = #0
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 845
          OptionsView.CellAutoHeight = True
          Styles.Background = Tablo.cxStyle10
          Styles.CardBorder = Tablo.cxStyle10
          object GridMesajDBCardView1Row4: TcxGridDBCardViewRow
            DataBinding.FieldName = 'GONDEREN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 100
          end
          object GridMesajDBCardView1Row2: TcxGridDBCardViewRow
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            CaptionAlignmentHorz = taRightJustify
            Options.Editing = False
            Position.BeginsLayer = False
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
          object GridMesajDBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'METIN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Position.BeginsLayer = True
            Position.Width = 400
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
          object GridMesajDBCardView1Row3: TcxGridDBCardViewRow
            DataBinding.FieldName = 'BENIMMI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Position.BeginsLayer = False
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
        end
        object GridMesajLevel1: TcxGridLevel
          GridView = GridMesajDBCardView1
        end
      end
    end
  end
  object MesajMenu: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 477
    Top = 115
    object KonusmaGecmisiMenu: TMenuItem
      Caption = 'Konu'#351'ma Ge'#231'mi'#351'ini G'#246'ster'
      ImageIndex = 19
    end
  end
  object DtsMesajKisiler: TDataSource
    DataSet = TabMesajKisiler
    Left = 115
    Top = 302
  end
  object TabMesajKisiler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '')
    Left = 175
    Top = 96
  end
  object TabMesajlar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '')
    Left = 855
    Top = 184
  end
  object DtsMesajlar: TDataSource
    DataSet = TabMesajlar
    Left = 739
    Top = 174
  end
end
