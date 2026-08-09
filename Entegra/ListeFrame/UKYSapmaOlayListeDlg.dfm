object KYSapmaOlayListeDlg: TKYSapmaOlayListeDlg
  Left = 0
  Top = 0
  Width = 954
  Height = 485
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
    Width = 948
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
    ExplicitWidth = 841
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
  object GridSapmaOlay: TcxGrid
    Left = 0
    Top = 35
    Width = 954
    Height = 450
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitWidth = 847
    ExplicitHeight = 269
    object GridSapmaOlayView: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridSapmaOlayViewCanFocusRecord
      DataController.DataSource = DtsSapmaOlay
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
      object GridSapmaOlayViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Width = 40
      end
      object GridSapmaOlayViewTIPI: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'TIPI'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Sapma'
            Value = 1
          end
          item
            Description = 'Olay'
            Value = 2
          end>
        Width = 57
      end
      object GridSapmaOlayViewREFERANSNO: TcxGridDBColumn
        Caption = 'Referans No'
        DataBinding.FieldName = 'REFERANSNO'
        Width = 80
      end
      object GridSapmaOlayViewSORUMLU: TcxGridDBColumn
        Caption = 'Ba'#351'latan'
        DataBinding.FieldName = 'BASLATAN'
        Width = 80
      end
      object GridSapmaOlayViewSORUMLU_ONAYLAYACAK: TcxGridDBColumn
        Caption = 'Y'#246'netici'
        DataBinding.FieldName = 'YONETICI'
        Width = 106
      end
      object GridSapmaOlayViewDEPARTMAN: TcxGridDBColumn
        Caption = 'Departman'
        DataBinding.FieldName = 'DEPARTMAN'
        Width = 91
      end
      object GridSapmaOlayViewKONUSU: TcxGridDBColumn
        Caption = 'Konusu'
        DataBinding.FieldName = 'KONUSU'
        Width = 145
      end
      object GridSapmaOlayViewTARIH: TcxGridDBColumn
        Caption = 'Tarihi'
        DataBinding.FieldName = 'TARIH'
        Width = 80
      end
      object GridSapmaOlayViewKAYITTARIHI: TcxGridDBColumn
        Caption = 'Kay'#305't'
        DataBinding.FieldName = 'KAYITTARIHI'
      end
      object GridSapmaOlayViewSORUMLU_ONAYLAYAN_TARIHI: TcxGridDBColumn
        Caption = 'Onay Tarihi'
        DataBinding.FieldName = 'SORUMLU_ONAYLAYAN_TARIHI'
      end
      object GridSapmaOlayViewURUNADI: TcxGridDBColumn
        Caption = 'Etkilenen'
        DataBinding.FieldName = 'URUNADI'
        Width = 86
      end
      object GridSapmaOlayViewSERINO: TcxGridDBColumn
        Caption = 'Seri No'
        DataBinding.FieldName = 'SERINO'
        Width = 43
      end
      object GridSapmaOlayViewDOF: TcxGridDBColumn
        Caption = 'D'#214'F'
        DataBinding.FieldName = 'DOF'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Width = 34
      end
      object GridSapmaOlayViewYORUM: TcxGridDBColumn
        Caption = 'Yorum'
        DataBinding.FieldName = 'YORUM'
        PropertiesClassName = 'TcxCheckBoxProperties'
      end
      object GridSapmaOlayViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKYSapmaOlayDurum
        Width = 80
      end
      object GridSapmaOlayViewPROJEKODU: TcxGridDBColumn
        Caption = 'Proje'
        DataBinding.FieldName = 'PROJEKODU'
        Width = 80
      end
      object GridSapmaOlayViewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKYSapmaOlayKategori
        Width = 80
      end
      object GridSapmaOlayViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubeler
        Visible = False
        Width = 80
      end
    end
    object GridSapmaOlayLevel3: TcxGridLevel
      GridView = GridSapmaOlayView
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
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
  object TabSapmaOlay: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabSapmaOlayAfterOpen
    ParamData = <>
    SQL.Strings = (
      'Select '
      #9'R2.FIRMA as YONETICI,R3.FIRMA as BASLATAN,P.PROJEKODU, '
      
        #9'DEPARTMAN = (select top 1 ANAHTAR from GENINI where BOLUM=-2251' +
        ' and DEGER=ROL.DEPARTMAN and DIL=-1),'
      
        #9'YORUM = cast(case when exists(select ID from GOREVYORUM where  ' +
        'TUR=452 AND GOREVID = KYSO.ID) then 1 else 0 end as bit),'
      
        #9'DOF = cast(case when exists(select ID from KALITEDOF where  YER' +
        '=452 AND YER_ID = KYSO.ID) then 1 else 0 end as bit),'
      #9'KYSO.* '
      'from '
      #9'KY_SAPMAOLAY KYSO'
      #9'left outer join REHBER R2 on KYSO.SORUMLU_ONAYLAYAN = R2.ID'
      #9'left outer join REHBER R3 on KYSO.BASLATAN = R3.ID'
      #9'left outer join PROJELER P on KYSO.PROJEID = P.ID'
      #9'left outer join ROLLER ROL on KYSO.DEPARTMAN=ROL.ID')
    Left = 323
    Top = 101
  end
  object DtsSapmaOlay: TDataSource
    DataSet = TabSapmaOlay
    Left = 260
    Top = 131
  end
  object frxSapmaOlay: TfrxDBDataset
    Description = 'DOF'
    UserName = 'DOF'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 290
    Top = 185
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 423
    Top = 200
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
  end
end

