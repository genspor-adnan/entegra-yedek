object PirimDlg: TPirimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'PirimDlg'
  ClientHeight = 531
  ClientWidth = 938
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGridPirim: TcxGrid
    Left = 0
    Top = 44
    Width = 938
    Height = 487
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    ExplicitWidth = 886
    object cxGridDBTableViewPirim: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsPersPirim
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object cxGridDBTableViewPirimID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        RepositoryItem = Tablo.cxEditRepository1Label1
        Visible = False
        MinWidth = 60
      end
      object cxGridDBTableViewPirimBASTAR: TcxGridDBColumn
        Caption = 'Ba'#351'lama'
        DataBinding.FieldName = 'BASTAR'
        RepositoryItem = Tablo.cxEditRepository1DateItem1
        MinWidth = 80
      end
      object cxGridDBTableViewPirimBITTAR: TcxGridDBColumn
        Caption = 'Biti'#351
        DataBinding.FieldName = 'BITTAR'
        RepositoryItem = Tablo.cxEditRepository1DateItem1
        MinWidth = 80
      end
      object cxGridDBTableViewPirimTUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Stok '#220'r'#252'n'
            Value = 1
          end
          item
            Description = 'Stok Kategori'
            Value = 2
          end
          item
            Description = 'Stok T'#252'm'#252
            Value = 3
          end
          item
            Description = 'Hizmet '#220'r'#252'n'
            Value = 11
          end
          item
            Description = 'Hizmet Kategori'
            Value = 12
          end
          item
            Description = 'Hizmet T'#252'm'#252
            Value = 13
          end>
        MinWidth = 80
      end
      object cxGridDBTableViewPirimURUNKODU: TcxGridDBColumn
        Caption = #220'r'#252'n Kod'
        DataBinding.FieldName = 'URUNKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxGridDBTableViewPirimURUNKODUPropertiesButtonClick
        MinWidth = 80
        Width = 80
      end
      object cxGridDBTableViewPirimURUNADI: TcxGridDBColumn
        Caption = #220'r'#252'n Ad'
        DataBinding.FieldName = 'URUNADI'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxGridDBTableViewPirimURUNKODUPropertiesButtonClick
        MinWidth = 120
        Width = 168
      end
      object cxGridDBTableViewPirimDEGER_YUZDE: TcxGridDBColumn
        Caption = 'Prim %'
        DataBinding.FieldName = 'DEGER_YUZDE'
        RepositoryItem = Tablo.cxEditRepository1SpinItem1
        MinWidth = 60
      end
      object cxGridDBTableViewPirimDEGER_TUTAR: TcxGridDBColumn
        Caption = 'Prim Sabit'
        DataBinding.FieldName = 'DEGER_TUTAR'
        RepositoryItem = Tablo.RepCurrencyGenel
        MinWidth = 80
        Width = 82
      end
      object cxGridDBTableViewPirimDEGER_KUR: TcxGridDBColumn
        Caption = 'Para Birimi'
        DataBinding.FieldName = 'DEGER_KUR'
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        MinWidth = 60
        Width = 65
      end
      object cxGridDBTableViewPirimISKONTODAHIL: TcxGridDBColumn
        Caption = 'Iskonto Dahil'
        DataBinding.FieldName = 'ISKONTODAHIL'
        PropertiesClassName = 'TcxCheckBoxProperties'
        MinWidth = 60
        Width = 77
      end
      object cxGridDBTableViewPirimKDVDAHIL: TcxGridDBColumn
        Caption = 'KDV Dahil'
        DataBinding.FieldName = 'KDVDAHIL'
        PropertiesClassName = 'TcxCheckBoxProperties'
      end
    end
    object cxGridLevelPirim: TcxGridLevel
      GridView = cxGridDBTableViewPirim
    end
  end
  object ToolBar13: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 932
    Height = 41
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 39
    ButtonWidth = 42
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
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    ExplicitWidth = 880
    object BtnPirimYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = BtnPirimYeniClick
    end
    object BtnPirimSil: TToolButton
      Left = 42
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = BtnPirimSilClick
    end
    object BtnPirimKaydet: TToolButton
      Left = 84
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      OnClick = BtnPirimKaydetClick
    end
    object BtnPirimIptal: TToolButton
      Left = 126
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      OnClick = BtnPirimIptalClick
    end
  end
  object TabPersPirim: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabPersPirimAfterOpen
    AfterPost = TabPersPirimAfterPost
    OnNewRecord = TabPersPirimNewRecord
    ParamData = <>
    SQL.Strings = (
      'select '
      #9'PP.*,'
      #9'TURADI=case '
      #9#9'when PP.TUR=1 then '#39'Stok '#220'r'#252'n'#39
      #9#9'when PP.TUR=2 then '#39'Stok Kategori'#39
      #9#9'when PP.TUR=3 then '#39'Stok T'#252'm'#252#39
      #9#9'when PP.TUR=11 then '#39'Hizmet '#220'r'#252'n'#39
      #9#9'when PP.TUR=12 then '#39'Hizmet Kategori'#39
      #9#9'when PP.TUR=13 then '#39'Hizmet T'#252'm'#252#39
      #9#9'else '#39#39' end,'
      #9'URUNKODU=case '
      
        #9#9'when PP.TUR=1 then (select S.KOD from STOKLAR S where S.ID=PP.' +
        'URUNID)'
      
        #9#9'when PP.TUR=2 then (select K.KOD from KATEGORI K where K.ID=PP' +
        '.URUNID)'
      #9#9'when PP.TUR=3 then '#39'Stok T'#252'm'#252#39
      
        #9#9'when PP.TUR=11 then (select M.KOD from MASRAFGELIR M where M.I' +
        'D=PP.URUNID)'
      
        #9#9'when PP.TUR=12 then (select M.KOD from MASRAFGELIR M where M.I' +
        'D=PP.URUNID)'
      #9#9'when PP.TUR=13 then '#39'Hizmet T'#252'm'#252#39
      #9#9'else '#39#39' end,'
      #9'URUNADI=case '
      
        #9#9'when PP.TUR=1 then (select S.STOKADI from STOKLAR S where S.ID' +
        '=PP.URUNID)'
      
        #9#9'when PP.TUR=2 then (select K.AD from KATEGORI K where K.ID=PP.' +
        'URUNID)'
      #9#9'when PP.TUR=3 then '#39'Stok T'#252'm'#252#39
      
        #9#9'when PP.TUR=11 then (select M.AD from MASRAFGELIR M where M.ID' +
        '=PP.URUNID)'
      
        #9#9'when PP.TUR=12 then (select M.AD from MASRAFGELIR M where M.ID' +
        '=PP.URUNID)'
      #9#9'when PP.TUR=13 then '#39'Hizmet T'#252'm'#252#39
      #9#9'else '#39#39' end'
      'from PERS_PIRIM PP '
      'where PP.REHBERID = :PRehID')
    Left = 68
    Top = 249
  end
  object DtsPersPirim: TDataSource
    DataSet = TabPersPirim
    OnStateChange = DtsPersPirimStateChange
    Left = 68
    Top = 297
  end
end

