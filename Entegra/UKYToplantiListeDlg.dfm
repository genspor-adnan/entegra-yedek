object KYToplantiListeDlg: TKYToplantiListeDlg
  Left = 0
  Top = 0
  Width = 1426
  Height = 544
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
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1420
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 74
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
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object DegisTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
    object SilTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 222
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 230
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
  end
  object GridToplanti: TcxGrid
    Left = 0
    Top = 35
    Width = 1426
    Height = 509
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.ScrollbarMode = sbmClassic
    object DBToplanti: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = DBToplantiCanFocusRecord
      OnCellDblClick = DBToplantiCellDblClick
      DataController.DataSource = DtsToplanti
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object DBToplantiID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
      end
      object DBToplantiTOPLANTINO: TcxGridDBColumn
        Caption = 'Toplant'#305' No'
        DataBinding.FieldName = 'TOPLANTINO'
      end
      object BASLAMATARIHI: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'BASLAMATARIH'
        PropertiesClassName = 'TcxDateEditProperties'
        Options.Editing = False
        Width = 89
      end
      object ADI: TcxGridDBColumn
        Caption = 'Toplant'#305' Konusu'
        DataBinding.FieldName = 'ADI'
        Options.Editing = False
        Width = 117
      end
      object DBToplantiKURUM: TcxGridDBColumn
        Caption = 'Kurum'
        DataBinding.FieldName = 'KURUM'
        Width = 138
      end
      object DBToplantiPROJE: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJE'
        Width = 143
      end
      object TOPLANTIYERI: TcxGridDBColumn
        Caption = 'Toplanti Yeri'
        DataBinding.FieldName = 'TOPLANTIYERI'
        Options.Editing = False
        Width = 121
      end
      object DURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        RepositoryItem = Tablo.RepKaliteToplantiDurum
        Options.Editing = False
      end
      object DBToplantiSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
      object EKLEYEN: TcxGridDBColumn
        Caption = 'Ekleyen'
        DataBinding.FieldName = 'EKLEYEN'
        RepositoryItem = Tablo.repGenelPersonelListesiHerkes
        Options.Editing = False
      end
    end
    object GridToplantiLevel1: TcxGridLevel
      GridView = DBToplanti
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 189
    Top = 75
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
  object TabToplanti: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabToplantiAfterOpen
    ParamData = <>
    SQL.Strings = (
      'Select  distinct'
      #9'KURUM=(SELECT FIRMA FROM REHBER WHERE ID=KT.REHBERID), '
      
        #9'PROJE=(SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=KT.PROJEID' +
        '), '
      #9'KT.*  '
      'from '
      #9'KALITETOPLANTI KT'
      'order by '
      #9'BASLAMATARIH desc')
    Left = 283
    Top = 77
  end
  object DtsToplanti: TDataSource
    DataSet = TabToplanti
    Left = 284
    Top = 131
  end
  object frxToplanti: TfrxDBDataset
    Description = 'Toplanti'
    UserName = 'Toplanti'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 282
    Top = 193
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 464
    Top = 200
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
  end
end

