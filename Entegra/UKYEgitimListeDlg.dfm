object KYEgitimListeDlg: TKYEgitimListeDlg
  Left = 0
  Top = 0
  Width = 975
  Height = 502
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
    Width = 969
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
  object GridEgitim: TcxGrid
    Left = 0
    Top = 35
    Width = 975
    Height = 467
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridEgitimView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridEgitimViewCanFocusRecord
      DataController.DataSource = DtsEgitim
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Kay'#305't Say'#305's'#305': ######'
          Kind = skCount
          Column = GridEgitimViewEGITIMKONUSU
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
      object GridEgitimViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Visible = False
      end
      object GridEgitimViewEGITIMNO: TcxGridDBColumn
        Caption = 'E'#287'itim No'
        DataBinding.FieldName = 'EGITIMNO'
      end
      object GridEgitimViewEGITIMKONUSU: TcxGridDBColumn
        Caption = 'E'#287'itim Konusu'
        DataBinding.FieldName = 'EGITIMKONUSU'
        Width = 86
      end
      object GridEgitimViewEGITIMBASLAMATARIHI: TcxGridDBColumn
        Caption = 'E'#287'itim Ba'#351'lama Tarihi'
        DataBinding.FieldName = 'EGITIMBASLAMATARIHI'
      end
      object GridEgitimViewEGITIMBITISTARIHI: TcxGridDBColumn
        Caption = 'E'#287'itim Biti'#351' Tarihi'
        DataBinding.FieldName = 'EGITIMBITISTARIHI'
      end
      object GridEgitimViewEGITIMTURU: TcxGridDBColumn
        Caption = 'E'#287'itim T'#252'r'#252
        DataBinding.FieldName = 'EGITIMTURU'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = #350'irket '#304#231'i'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = #350'irket D'#305#351#305
            Value = 1
          end>
        Width = 91
      end
      object GridEgitimViewEGITIMSORUMLU: TcxGridDBColumn
        DataBinding.FieldName = 'SORUMLU'
        Width = 96
      end
      object GridEgitimViewREHBERID: TcxGridDBColumn
        Caption = 'M'#252#351'teri'
        DataBinding.FieldName = 'FIRMA'
      end
      object GridEgitimViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKaliteToplantiDurum
      end
    end
    object GridEgitimLevel3: TcxGridLevel
      GridView = GridEgitimView
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 197
    Top = 155
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
  object TabEgitim: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabEgitimAfterOpen
    ParamData = <>
    SQL.Strings = (
      
        'Select distinct KE.ID, R1.FIRMA as REHBER,R2.FIRMA as SORUMLU,R3' +
        '.FIRMA as ACAN, KE.* '
      'from KALITEEGITIM KE'
      ' left outer join REHBER R1 on KE.REHBERID=R1.ID'
      ' left outer join REHBER R2 on KE.EGITIMSORUMLU=R2.ID'
      ' left outer join REHBER R3 on KE.EGITIMACAN=R3.ID')
    Left = 331
    Top = 157
  end
  object DtsEgitim: TDataSource
    DataSet = TabEgitim
    Left = 284
    Top = 131
  end
  object frxEgitim: TfrxDBDataset
    Description = 'Egitim'
    UserName = 'Egitim'
    CloseDataSource = False
    DataSet = TabEgitim
    BCDToCurrency = False
    DataSetOptions = []
    Left = 282
    Top = 193
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

