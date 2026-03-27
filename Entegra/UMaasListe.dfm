object MaasListeDlg: TMaasListeDlg
  Left = 0
  Top = 0
  Caption = 'Personelin Son Durumunu G'#246'sterir '#199'ar'#351'af Liste'
  ClientHeight = 592
  ClientWidth = 1286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object GridMaas: TcxGrid
    Left = 0
    Top = 67
    Width = 1286
    Height = 525
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitWidth = 1282
    ExplicitHeight = 524
    object GridMaasTV: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridMaasTVCanFocusRecord
      DataController.DataSource = DtsMaasListe
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
          FieldName = 'FIRMA'
          Column = GridMaasTVFIRMA
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      Styles.ContentEven = Tablo.cxStyle12
      Styles.ContentOdd = Tablo.cxStyle22
      Styles.OnGetContentStyle = GridMaasTVStylesGetContentStyle
      object GridMaasTVRecId: TcxGridDBColumn
        DataBinding.FieldName = 'RecId'
        Visible = False
      end
      object GridMaasTVID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Options.Editing = False
      end
      object GridMaasTVSUBE: TcxGridDBColumn
        DataBinding.FieldName = 'SUBE'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubeler
      end
      object GridMaasTVFIRMA: TcxGridDBColumn
        Caption = 'AD SOYAD'
        DataBinding.FieldName = 'FIRMA'
        Options.Editing = False
        Styles.Content = Tablo.cxStyle10
        Width = 143
      end
      object GridMaasTVDEPARTMAN: TcxGridDBColumn
        DataBinding.FieldName = 'DEPARTMAN'
        PropertiesClassName = 'TcxTextEditProperties'
        Options.Editing = False
        Width = 91
      end
      object GridMaasTVColumn3: TcxGridDBColumn
        Caption = 'G'#214'REV'
        DataBinding.FieldName = 'GOREV'
      end
      object GridMaasTVColumn2: TcxGridDBColumn
        Caption = #199'ALI'#350'MA'
        DataBinding.FieldName = 'PERYOT'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Maa'#351
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Maa'#351' yada Prim'
            Value = 1
          end
          item
            Description = 'Maa'#351' + Prim'
            Value = 2
          end>
        Width = 81
      end
      object GridMaasTVColumn1: TcxGridDBColumn
        DataBinding.FieldName = 'ISEGIRIS'
        PropertiesClassName = 'TcxDateEditProperties'
        Width = 176
      end
    end
    object GridMaasLevel1: TcxGridLevel
      GridView = GridMaasTV
    end
  end
  object Panel11: TPanel
    Left = 0
    Top = 0
    Width = 1286
    Height = 67
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 1282
    object PanelPrim: TJvNavPanelHeader
      Left = 373
      Top = 0
      Width = 661
      Height = 67
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object CalendarEkstreBit: TcxDateEdit
        Left = 106
        Top = 37
        ParentFont = False
        Properties.ImmediatePost = True
        Properties.OnCloseUp = CalendarEkstreBitPropertiesCloseUp
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 0
        Width = 121
      end
      object Label2: TcxLabel
        Left = 18
        Top = 39
        Caption = 'Prim Biti'#351
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object CalendarEkstreBas: TcxDateEdit
        Left = 106
        Top = 7
        ParentFont = False
        Properties.ImmediatePost = True
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 2
        Width = 121
      end
      object Label1: TcxLabel
        Left = 18
        Top = 9
        Caption = 'Prim Ba'#351'lama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object PrimHesaplaTus: TcxButton
        Left = 232
        Top = 33
        Width = 131
        Height = 31
        Caption = 'Prim Hesapla'
        TabOrder = 4
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        OnClick = PrimHesaplaTusClick
      end
    end
    object ToolBar1: TToolBar
      Left = 1034
      Top = 0
      Width = 126
      Height = 67
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = True
      ButtonHeight = 47
      ButtonWidth = 63
      Caption = 'AletCubugu'
      Color = clTeal
      DockSite = True
      DrawingStyle = dsGradient
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
      Images = Tablo.PNGImageList1
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      object KaydetTus: TToolButton
        Left = 0
        Top = 0
        Caption = '    Kaydet   '
        ImageIndex = 10
        ImageName = 'PngImage9'
        OnClick = KaydetTusClick
      end
      object btnKapat: TToolButton
        Left = 63
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        ImageName = 'PngImage17'
        Style = tbsTextButton
        OnClick = btnKapatClick
      end
    end
    object JvNavPanelHeader1: TJvNavPanelHeader
      Left = 0
      Top = 0
      Width = 373
      Height = 67
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object ComboSube: TcxImageComboBox
        Left = 71
        Top = 6
        RepositoryItem = Tablo.RepSubeler
        ParentFont = False
        Properties.Alignment.Horz = taLeftJustify
        Properties.Items = <>
        Properties.OnCloseUp = ComboSubePropertiesCloseUp
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -16
        Style.Font.Name = 'Arial'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clBlack
        TabOrder = 0
        Width = 279
      end
      object LblSube: TcxLabel
        Left = 3
        Top = 11
        Caption = #350'ube'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel5: TcxLabel
        Left = 3
        Top = 39
        Caption = 'Departman'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditDepartman: TcxButtonEdit
        Tag = 1
        Left = 71
        Top = 38
        Hint = '1'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
            Tag = 1
          end
          item
            Caption = '-'
            Kind = bkText
            Tag = 1
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
        TabOrder = 3
        Width = 116
      end
      object cxLabel1: TcxLabel
        Left = 193
        Top = 42
        Caption = 'G'#246'rev'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditGorev: TcxButtonEdit
        Tag = 2
        Left = 234
        Top = 39
        Hint = '2'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
            Tag = 2
          end
          item
            Caption = '-'
            Kind = bkText
            Tag = 2
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
        TabOrder = 5
        Width = 116
      end
    end
  end
  object DtsMaasListe: TDataSource
    DataSet = MAASLISTE
    Left = 256
    Top = 344
  end
  object MAASLISTE: TdxMemData
    Indexes = <>
    SortOptions = []
    BeforePost = MAASLISTEBeforePost
    Left = 168
    Top = 344
    object MAASLISTEID: TIntegerField
      Tag = 1
      FieldName = 'ID'
    end
    object MAASLISTEFIRMA: TStringField
      Tag = 2
      FieldName = 'FIRMA'
      Size = 100
    end
    object MAASLISTESUBE: TIntegerField
      FieldName = 'SUBE'
    end
    object MAASLISTEDEPARTMAN: TStringField
      Tag = 3
      FieldName = 'DEPARTMAN'
    end
    object MAASLISTEGOREV: TStringField
      Tag = 3
      FieldName = 'GOREV'
    end
    object MAASLISTEISEGIRIS: TDateField
      DisplayLabel = #304#350'E G'#304'R'#304#350
      FieldName = 'ISEGIRIS'
    end
    object MAASLISTEPERYOT: TSmallintField
      FieldName = 'PERYOT'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 125
    Top = 167
    object ExceldenBilgiekle1: TMenuItem
      Caption = 'Excelden Bilgi Al '
      OnClick = ExceldenBilgiekle1Click
    end
    object ExceleGnder1: TMenuItem
      Caption = 'Excele G'#246'nder'
      Visible = False
    end
    object AraCizgi1Menu: TMenuItem
      Caption = '-'
    end
    object PrimOranlariMenu: TMenuItem
      Caption = 'Prim Oranlar'#305
      OnClick = PrimOranlariMenuClick
    end
    object PrimListesiMenu: TMenuItem
      Caption = 'Prim Listesi'
      OnClick = PrimListesiMenuClick
    end
  end
end
