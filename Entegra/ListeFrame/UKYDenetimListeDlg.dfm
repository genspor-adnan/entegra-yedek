object KYDenetimListeDlg: TKYDenetimListeDlg
  Left = 0
  Top = 0
  Width = 942
  Height = 506
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 936
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
      Enabled = False
      ImageIndex = 8
      ImageName = 'PngImage7'
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
  object GridDOF: TcxGrid
    Left = 0
    Top = 35
    Width = 942
    Height = 471
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridDOFView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridDOFViewCanFocusRecord
      DataController.DataSource = DtsDenetim
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
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
      object GridDOFViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Width = 25
      end
      object GridDOFViewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewDENETIMNO: TcxGridDBColumn
        Caption = 'Denetim No'
        DataBinding.FieldName = 'DENETIMNO'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKYDenetimDurum
        Width = 80
      end
      object GridDOFViewADI: TcxGridDBColumn
        Caption = 'Denetim Ad'#305
        DataBinding.FieldName = 'ADI'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object GridDOFViewKURUM: TcxGridDBColumn
        Caption = 'Denetleyen Kurum'
        DataBinding.FieldName = 'KURUM'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewDENETCI: TcxGridDBColumn
        Caption = 'Denet'#231'i'
        DataBinding.FieldName = 'DENETCI'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewSORUMLU: TcxGridDBColumn
        Caption = 'Sorumlu'
        DataBinding.FieldName = 'SORUMLU'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewBASLAMATARIHI: TcxGridDBColumn
        Caption = 'Ba'#351'lama'
        DataBinding.FieldName = 'BASLAMATARIHI'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewBITISTARIHI: TcxGridDBColumn
        Caption = 'Biti'#351
        DataBinding.FieldName = 'BITISTARIHI'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewPROJEKODU: TcxGridDBColumn
        Caption = 'Proje'
        DataBinding.FieldName = 'PROJEKODU'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKYDenetimKategori
        Width = 80
      end
      object GridDOFViewTIPI: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'TIPI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKYDenetimTipi
        Width = 80
      end
      object GridDOFViewDEPARTMAN: TcxGridDBColumn
        Caption = 'Departman'
        DataBinding.FieldName = 'DEPARTMAN'
        DataBinding.IsNullValueType = True
        Width = 80
      end
      object GridDOFViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubeler
        Width = 80
      end
    end
    object GridDOFLevel3: TcxGridLevel
      GridView = GridDOFView
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 341
    Top = 11
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
  object TabDenetim: TFDQuery
    AfterOpen = TabDenetimAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select '
      
        #9'R1.FIRMA as KURUM,R2.FIRMA as SORUMLU,R3.FIRMA as TALEPEDEN, RP' +
        '.FIRMA  as DENETCI,P.PROJEKODU, '
      
        #9'DEPARTMAN = (select top 1 ANAHTAR from GENINI where BOLUM=-2251' +
        ' and DEGER=ROL.DEPARTMAN and DIL=-1),'
      #9'KD.* '
      'from '
      #9'KALITEDENETIM KD'
      #9'left outer join REHBER R1 on KD.REHBERID = R1.ID'
      #9'left outer join REHBER R2 on KD.SORUMLU = R2.ID'
      #9'left outer join REHBER R3 on KD.TALEPEDEN = R3.ID'
      
        #9'left outer join REHBER RP on RP.BAGID=KD.REHBERID and KD.DENETC' +
        'I = RP.ID'
      #9'left outer join PROJELER P on KD.PROJEID = P.ID'
      #9'left outer join ROLLER ROL on KD.DEPARTMAN=ROL.ID')
    Left = 323
    Top = 101
  end
  object DtsDenetim: TDataSource
    DataSet = TabDenetim
    Left = 260
    Top = 131
  end
  object frxDOF: TfrxDBDataset
    Description = 'DOF'
    UserName = 'DOF'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 290
    Top = 185
  end
  object PopupMenu1: TPopupMenu
    Left = 423
    Top = 200
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
  end
end
