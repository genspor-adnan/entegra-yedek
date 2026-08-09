object KampanyalarDlg: TKampanyalarDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Kampanyalar'
  ClientHeight = 442
  ClientWidth = 805
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object PageCtrlDetaylar: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 228
    Width = 805
    Height = 214
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = SheetUrunListe
    Properties.CustomButtons.Buttons = <>
    OnPageChanging = PageCtrlDetaylarPageChanging
    ClientRectBottom = 212
    ClientRectLeft = 2
    ClientRectRight = 803
    ClientRectTop = 28
    object SheetUrunListe: TcxTabSheet
      Caption = #220'r'#252'n Kartlar'#305
      ImageIndex = 12
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 795
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
        object BtnUrunYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = BtnUrunYeniClick
        end
        object BtnUrunSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = BtnUrunSilClick
        end
        object BtnUrunKaydet: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = BtnUrunKaydetClick
        end
        object BtnUrunIptal: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = BtnUrunIptalClick
        end
      end
      object gridKampanyaUrun: TcxGrid
        Left = 0
        Top = 27
        Width = 801
        Height = 157
        Align = alClient
        TabOrder = 1
        object gridKampanyaUrunTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsKampUrun
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Appending = True
          OptionsView.GroupByBox = False
          object gridKampanyaUrunTableView1TUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            RepositoryItem = Tablo.RepFatDetayTur
            Width = 70
          end
          object gridKampanyaUrunTableView1URUNKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'URUNKOD'
            OnGetPropertiesForEdit = gridKampanyaUrunTableView1URUNKODGetPropertiesForEdit
          end
          object gridKampanyaUrunTableView1URUNAD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'URUNAD'
            OnGetPropertiesForEdit = gridKampanyaUrunTableView1URUNKODGetPropertiesForEdit
            Width = 377
          end
          object gridKampanyaUrunTableView1DURUM: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 34
          end
        end
        object gridKampanyaUrunLevel1: TcxGridLevel
          GridView = gridKampanyaUrunTableView1
        end
      end
    end
    object SheetCariListe: TcxTabSheet
      Caption = 'Cari Kartlar'
      ImageIndex = 35
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 795
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
        object BtnCariYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = BtnCariYeniClick
        end
        object BtnCariSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = BtnCariSilClick
        end
        object BtnCariKaydet: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          OnClick = BtnCariKaydetClick
        end
        object BtnCariIptal: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          OnClick = BtnCariIptalClick
        end
      end
      object gridKampanyaCari: TcxGrid
        Left = 0
        Top = 27
        Width = 801
        Height = 157
        Align = alClient
        TabOrder = 1
        object gridKampanyaCariTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsKampCari
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Appending = True
          OptionsView.GroupByBox = False
          object gridKampanyaCariTableView1KOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = gridKampanyaCariTableView1KODPropertiesButtonClick
            Width = 90
          end
          object gridKampanyaCariTableView1FIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = True
            Properties.OnButtonClick = gridKampanyaCariTableView1KODPropertiesButtonClick
            Width = 421
          end
          object gridKampanyaCariTableView1DURUM: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 34
          end
        end
        object gridLevelKampanyaCari: TcxGridLevel
          GridView = gridKampanyaCariTableView1
        end
      end
    end
    object SheetKosullar: TcxTabSheet
      Caption = 'Ko'#351'ullar'
      ImageIndex = 19
      OnExit = SheetKosullarExit
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 795
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
        object BtnKosulYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = BtnKosulYeniClick
        end
        object BtnKosulSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = BtnKosulSilClick
        end
        object BtnKosulKaydet: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = BtnKosulKaydetClick
        end
        object BtnKosulIptal: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = BtnKosulIptalClick
        end
      end
      object gridKampanyaKosul: TcxGrid
        Left = 0
        Top = 27
        Width = 801
        Height = 157
        Align = alClient
        TabOrder = 1
        object gridKampanyaKosulTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsKampKosul
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Appending = True
          OptionsView.GroupByBox = False
          object gridKampanyaKosulTableView1TUR: TcxGridDBColumn
            DataBinding.FieldName = 'TUR'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 209
          end
          object gridKampanyaKosulTableView1KOSUL: TcxGridDBColumn
            DataBinding.FieldName = 'KOSUL'
            OnGetPropertiesForEdit = gridKampanyaKosulTableView1KOSULGetPropertiesForEdit
            Width = 189
          end
        end
        object gridKampanyaKosulLevel1: TcxGridLevel
          GridView = gridKampanyaKosulTableView1
        end
      end
    end
    object SheetSonuclar: TcxTabSheet
      Caption = 'Sonu'#231'lar'
      ImageIndex = 19
      OnExit = SheetSonuclarExit
      object ToolBar4: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 795
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
        object BtnSonucYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = BtnSonucYeniClick
        end
        object BtnSonucSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = BtnSonucSilClick
        end
        object BtnSonucKaydet: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = BtnSonucKaydetClick
        end
        object BtnSonucIptal: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = BtnSonucIptalClick
        end
      end
      object gridKampanyaSonuc: TcxGrid
        Left = 0
        Top = 27
        Width = 801
        Height = 157
        Align = alClient
        TabOrder = 1
        object gridKampanyaSonucTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsKampSonuc
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Appending = True
          OptionsView.GroupByBox = False
          object gridKampanyaSonucTableView1TUR: TcxGridDBColumn
            DataBinding.FieldName = 'TUR'
            RepositoryItem = Tablo.repKampanyaSonucTur
            Width = 219
          end
          object gridKampanyaSonucTableView1SONUC: TcxGridDBColumn
            DataBinding.FieldName = 'SONUC'
            OnGetDisplayText = gridKampanyaSonucTableView1SONUCGetDisplayText
            OnGetPropertiesForEdit = gridKampanyaSonucTableView1SONUCGetPropertiesForEdit
            Width = 183
          end
        end
        object gridKampanyaSonucLevel1: TcxGridLevel
          GridView = gridKampanyaSonucTableView1
        end
      end
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 805
    Height = 228
    Align = alTop
    TabOrder = 1
    DesignSize = (
      805
      228)
    object EditKampanyaAdi: TcxDBTextEdit
      Left = 524
      Top = 113
      Anchors = [akTop, akRight]
      DataBinding.DataField = 'ADI'
      DataBinding.DataSource = DtsKampanya
      TabOrder = 2
      Width = 220
    end
    object cxLabel1: TcxLabel
      Left = 435
      Top = 114
      Anchors = [akTop, akRight]
      Caption = 'Kampanya Ad'#305
      Transparent = True
    end
    object gridKampanyalar: TcxGrid
      Left = 1
      Top = 59
      Width = 426
      Height = 168
      Align = alLeft
      Anchors = [akLeft, akTop, akRight, akBottom]
      PopupMenu = PmKopyalama
      TabOrder = 5
      object tvKampanyalar: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsKampanya
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        object tvKampanyalarKODU: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KODU'
          Width = 92
        end
        object tvKampanyalarADI: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'ADI'
          Width = 264
        end
        object tvKampanyalarDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          Width = 47
        end
        object tvKampanyalarID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
      end
      object gridKampanyalarLevel1: TcxGridLevel
        GridView = tvKampanyalar
      end
    end
    object EditKampanyaKodu: TcxDBTextEdit
      Left = 524
      Top = 87
      Anchors = [akTop, akRight]
      DataBinding.DataField = 'KODU'
      DataBinding.DataSource = DtsKampanya
      TabOrder = 1
      Width = 220
    end
    object cxLabel4: TcxLabel
      Left = 435
      Top = 88
      Anchors = [akTop, akRight]
      Caption = 'Kampanya Kodu'
      Transparent = True
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 797
      Height = 29
      Margins.Bottom = 0
      ButtonHeight = 30
      ButtonWidth = 70
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
      TabOrder = 7
      Transparent = True
      object BtnKaydet: TToolButton
        Left = 0
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 10
        Visible = False
        OnClick = BtnKaydetClick
      end
      object BtnIptal: TToolButton
        Left = 70
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 17
        Visible = False
        OnClick = BtnIptalClick
      end
      object BtnYeni: TToolButton
        Left = 140
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 7
        OnClick = BtnYeniClick
      end
      object BtnSil: TToolButton
        Left = 210
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        OnClick = BtnSilClick
      end
      object ToolButton10: TToolButton
        Left = 280
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 20
        Style = tbsSeparator
      end
      object YaziciYaz: TToolButton
        Left = 288
        Top = 0
        Caption = 'Yazd'#305'r'
        ImageIndex = 16
        Style = tbsTextButton
      end
    end
    object PanelArama: TPanel
      Left = 1
      Top = 33
      Width = 803
      Height = 26
      Align = alTop
      TabOrder = 8
      DesignSize = (
        803
        26)
      object ComboAramaTuru: TcxImageComboBox
        Left = 2
        Top = 1
        EditValue = 1
        Properties.Items = <
          item
            Description = 'Kampanya Kodu'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kampanya Ad'#305
            Value = 2
          end
          item
            Description = #220'r'#252'n Kodu'
            Value = 11
          end
          item
            Description = #220'r'#252'n Ad'#305
            Value = 12
          end
          item
            Description = 'Cari Kodu'
            Value = 21
          end
          item
            Description = 'Cari Ad'#305
            Value = 22
          end>
        Properties.OnEditValueChanged = ComboAramaTuruPropertiesEditValueChanged
        TabOrder = 0
        Width = 121
      end
      object EditArama: TcxTextEdit
        Left = 126
        Top = 1
        TabOrder = 1
        OnKeyUp = EditAramaKeyUp
        Width = 182
      end
      object CheckPasiflerideGoster: TcxCheckBox
        Left = 681
        Top = 2
        Anchors = [akTop, akRight]
        Caption = 'Pasifleri G'#246'ster'
        TabOrder = 2
        Visible = False
        Width = 102
      end
    end
    object cxDBMemo1: TcxDBMemo
      Left = 524
      Top = 139
      Align = alCustom
      Anchors = [akTop, akRight, akBottom]
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsKampanya
      TabOrder = 3
      Height = 85
      Width = 220
    end
    object cxLabel2: TcxLabel
      Left = 435
      Top = 140
      Anchors = [akTop, akRight]
      Caption = 'A'#231#305'klama'
      Transparent = True
    end
    object cxDBCheckBox1: TcxDBCheckBox
      Left = 689
      Top = 59
      Anchors = [akTop, akRight]
      Caption = 'Aktif'
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsKampanya
      TabOrder = 10
      Width = 55
    end
    object cbKampanyaTur: TcxDBImageComboBox
      Left = 524
      Top = 61
      RepositoryItem = Tablo.repKampanyaTur
      DataBinding.DataField = 'TUR'
      DataBinding.DataSource = DtsKampanya
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.OnEditValueChanged = cbKampanyaTurPropertiesEditValueChanged
      TabOrder = 0
      Width = 148
    end
    object cxLabel3: TcxLabel
      Left = 435
      Top = 63
      Anchors = [akTop, akRight]
      Caption = 'Kampanya T'#252'r'#252
      Transparent = True
    end
  end
  object TabKampanya: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabKampanyaAfterOpen
    BeforePost = TabKampanyaBeforePost
    AfterScroll = TabKampanyaAfterScroll
    OnNewRecord = TabKampanyaNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT  *  FROM  KAMPANYA'
      'WHERE 1=1 ')
    Left = 98
    Top = 302
  end
  object DtsKampanya: TDataSource
    DataSet = TabKampanya
    OnStateChange = DtsKampanyaStateChange
    Left = 97
    Top = 347
  end
  object TabKampUrun: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabKampKosulNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT KU.*,  '
      'URUNKOD = (CASE '
      
        'when TUR=1 then (SELECT KOD FROM STOKLAR S WHERE S.ID=KU.URUNID)' +
        ' '
      
        'when TUR=0 then (SELECT KOD FROM MASRAFGELIR MG WHERE MG.ID=KU.U' +
        'RUNID) '
      'else '#39#39' end),'
      'URUNAD = (CASE '
      
        'when TUR=1 then (SELECT STOKADI FROM STOKLAR S WHERE S.ID=KU.URU' +
        'NID) '
      
        'when TUR=0 then (SELECT AD FROM MASRAFGELIR MG WHERE MG.ID=KU.UR' +
        'UNID) '
      'else '#39#39' end),'
      'BIRIM = (CASE '
      
        'when TUR=1 then (SELECT ANABIRIM FROM STOKLAR S WHERE S.ID=KU.UR' +
        'UNID) '
      
        'when TUR=0 then (SELECT BIRIM FROM MASRAFGELIR MG WHERE MG.ID=KU' +
        '.URUNID) '
      'else 0 end) '
      'FROM  KAMPANYAURUN KU'
      'where KU.KAMPANYAID=:PKampanyaID')
    Left = 157
    Top = 318
  end
  object DtsKampUrun: TDataSource
    DataSet = TabKampUrun
    OnStateChange = DtsKampUrunStateChange
    Left = 157
    Top = 365
  end
  object TabKampCari: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabKampCariBeforePost
    OnNewRecord = TabKampKosulNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT  KC.*,R.KOD,R.FIRMA '
      'FROM '
      #9'KAMPANYACARI KC left outer join '
      #9'REHBER R on KC.REHBERID=R.ID'
      'where KAMPANYAID=:PKampanyaID')
    Left = 206
    Top = 303
  end
  object DtsKampCari: TDataSource
    DataSet = TabKampCari
    OnStateChange = DtsKampCariStateChange
    Left = 215
    Top = 344
  end
  object TabKampKosul: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabKampKosulBeforePost
    OnNewRecord = TabKampKosulNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT  '
      #9'KK.*'
      ''
      'FROM  KAMPANYAKOSUL KK'
      ''
      'where KK.KAMPANYAID=:PKampanyaID')
    Left = 271
    Top = 322
  end
  object TabKampSonuc: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabKampSonucBeforePost
    OnNewRecord = TabKampKosulNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT KS.*'
      ''
      'FROM  KAMPANYASONUC KS'
      ''
      'where KS.KAMPANYAID=:PKampanyaID')
    Left = 326
    Top = 304
  end
  object DtsKampKosul: TDataSource
    DataSet = TabKampKosul
    OnStateChange = DtsKampKosulStateChange
    Left = 271
    Top = 365
  end
  object DtsKampSonuc: TDataSource
    DataSet = TabKampSonuc
    OnStateChange = DtsKampSonucStateChange
    Left = 329
    Top = 350
  end
  object PmKopyalama: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 449
    Top = 164
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
  end
end
