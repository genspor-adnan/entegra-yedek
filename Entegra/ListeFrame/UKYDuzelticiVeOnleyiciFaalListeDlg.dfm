object KYDuzelticiVeOnleyiciFaalListeDlg: TKYDuzelticiVeOnleyiciFaalListeDlg
  Left = 0
  Top = 0
  Width = 966
  Height = 479
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
    Width = 960
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
    Width = 966
    Height = 444
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
      DataController.DataSource = DtsDOF
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
      end
      object GridDOFViewDOFNO: TcxGridDBColumn
        Caption = 'D'#214'F No'
        DataBinding.FieldName = 'DOFNO'
      end
      object GridDOFViewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'EKLENMETARIHI'
      end
      object GridDOFViewACIL: TcxGridDBColumn
        Caption = 'AC'#304'L'
        DataBinding.FieldName = 'ACIL'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Width = 35
      end
      object GridDOFViewONEMLI: TcxGridDBColumn
        Caption = #214'nemli'
        DataBinding.FieldName = 'ONEMLI'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Width = 45
      end
      object GridDOFViewTIPI: TcxGridDBColumn
        Caption = 'Faaliyet T'#252'r'#252
        DataBinding.FieldName = 'FAALIYETTURU'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKaliteDofFaaliyet
        Width = 96
      end
      object GridDOFViewKONU: TcxGridDBColumn
        Caption = 'Konu'
        DataBinding.FieldName = 'KONU'
        Width = 106
      end
      object GridDOFViewHATAKAYNAGI: TcxGridDBColumn
        Caption = 'Tespit Kayna'#287#305
        DataBinding.FieldName = 'TESPITKAYNAGI'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKaliteTespitKaynagi
        Width = 82
      end
      object GridDOFViewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        RepositoryItem = Tablo.RepKaliteDofKategori
      end
      object GridDOFViewBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'DEPARTMANAD'
        Width = 165
      end
      object GridDOFViewPROJE: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJE'
        Width = 127
      end
      object GridDOFViewDOF_ACAN: TcxGridDBColumn
        Caption = 'D'#214'F A'#231'an'
        DataBinding.FieldName = 'ACAN'
        Width = 110
      end
      object GridDOFViewDOF_SORUMLUSU: TcxGridDBColumn
        Caption = 'D'#214'F Sorumlu'
        DataBinding.FieldName = 'SORUMLU'
        Width = 99
      end
      object GridDOFViewREHBERID: TcxGridDBColumn
        Caption = 'Kurum'
        DataBinding.FieldName = 'KURUM'
        Width = 143
      end
      object GridDOFViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repAktiviteDurum
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
  object TabDOF: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDOFAfterOpen
    ParamData = <>
    SQL.Strings = (
      
        'Select KD.*,R1.FIRMA as KURUM, R2.FIRMA as SORUMLU,R3.FIRMA as A' +
        'CAN, '
      
        'PROJE=(SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=KD.PROJEID)' +
        ','
      
        'DEPARTMANAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 ' +
        'and DEGER=ROL.DEPARTMAN and DIL=-1)'
      'from KALITEDOF KD'
      ' left outer join REHBER R1 on KD.REHBERID=R1.ID'
      ' left outer join REHBER R2 on KD.DOFSORUMLU=R2.ID'
      ' left outer join REHBER R3 on KD.DOFACAN=R3.ID'
      ' left outer join ROLLER ROL on KD.DEPARTMAN=ROL.ID'
      ' ORDER BY EKLENMETARIHI DESC')
    Left = 323
    Top = 101
  end
  object DtsDOF: TDataSource
    DataSet = TabDOF
    Left = 284
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
    Left = 464
    Top = 200
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
  end
end

