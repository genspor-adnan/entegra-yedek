object HizliGirisKKTahsilatDlg: THizliGirisKKTahsilatDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'HizliGirisKKTahsilatDlg'
  ClientHeight = 304
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 304
    Align = alClient
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 0
    DesignSize = (
      426
      300)
    object BtnTamam: TJvNavPanelButton
      Left = 4
      Top = 261
      Width = 208
      Height = 36
      Align = alCustom
      AllowAllUp = True
      Caption = 'Ekle'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 0
      Images = Tablo.cxImageList1
      OnClick = BtnTamamClick
    end
    object BtnIptal: TJvNavPanelButton
      Left = 213
      Top = 261
      Width = 211
      Height = 36
      Align = alCustom
      AllowAllUp = True
      Caption = #304'ptal'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 1
      Images = Tablo.cxImageList1
      OnClick = BtnIptalClick
    end
    object EditToplamTutar: TcxCurrencyEdit
      Left = 190
      Top = -43
      Anchors = [akRight, akBottom]
      EditValue = 0.000000000000000000
      Enabled = False
      ParentFont = False
      Properties.Alignment.Horz = taRightJustify
      Properties.ClearKey = 46
      Properties.DisplayFormat = ',0.00;-,0.00'
      Properties.Nullable = False
      Properties.Nullstring = '0'
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -21
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      StyleDisabled.BorderColor = clBtnText
      StyleDisabled.Color = clMoneyGreen
      StyleDisabled.TextColor = clBackground
      TabOrder = 0
      Width = 149
    end
    object LabelKur: TcxLabel
      Left = 391
      Top = 14
      Anchors = [akRight, akBottom]
      Caption = 'TL'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextStyle = [fsBold]
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxGrid1: TcxGrid
      Left = 213
      Top = 37
      Width = 210
      Height = 220
      Align = alCustom
      BevelInner = bvLowered
      BevelOuter = bvRaised
      BevelKind = bkSoft
      BorderStyle = cxcbsNone
      TabOrder = 4
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridViewPOS: TcxGridDBTableView
        OnKeyUp = FormKeyUp
        Navigator.Buttons.CustomButtons = <>
        OnSelectionChanged = GridViewPOSSelectionChanged
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsPOSListesi
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.ScrollBars = ssVertical
        OptionsView.DataRowHeight = 50
        OptionsView.GroupByBox = False
        OptionsView.Header = False
        object GridViewPOSSEC: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Width = 34
        end
        object GridViewPOSLOGO: TcxGridDBColumn
          PropertiesClassName = 'TcxImageProperties'
          Properties.ImmediatePost = True
          Properties.ReadOnly = True
          Width = 61
        end
        object GridViewPOSADI: TcxGridDBColumn
          DataBinding.FieldName = 'ADI'
          PropertiesClassName = 'TcxLabelProperties'
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridViewPOS
      end
    end
    object cxLabel1: TcxLabel
      Left = 11
      Top = 10
      Anchors = [akRight, akBottom]
      Caption = 'Kredi Kart'#305' '#304#351'lemleri'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextStyle = [fsBold]
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxGrid2: TcxGrid
      Left = 2
      Top = 37
      Width = 210
      Height = 219
      Align = alCustom
      BevelInner = bvLowered
      BevelOuter = bvRaised
      BevelKind = bkSoft
      BorderStyle = cxcbsNone
      TabOrder = 2
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridViewKartTipi: TcxGridDBTableView
        OnKeyUp = FormKeyUp
        Navigator.Buttons.CustomButtons = <>
        OnSelectionChanged = GridViewKartTipiSelectionChanged
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsKrediKartiTipi
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.ScrollBars = ssVertical
        OptionsView.DataRowHeight = 50
        OptionsView.GroupByBox = False
        OptionsView.Header = False
        object cxGridDBColumn1: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Width = 34
        end
        object cxGridDBColumn2: TcxGridDBColumn
          Width = 61
        end
        object cxGridDBColumn3: TcxGridDBColumn
          DataBinding.FieldName = 'KARTADI'
          PropertiesClassName = 'TcxLabelProperties'
        end
      end
      object cxGridLevel2: TcxGridLevel
        GridView = GridViewKartTipi
      end
    end
  end
  object TabPOSListesi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select P.*,B.LOGO'
      'from POS P'
      'inner join BANKAHESAPLAR BH on P.BANKAHESAPID=BH.ID'
      'inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on BS.BANKAKODU=B.BANKAKODU'
      ''
      'where P.DURUM=1')
    Left = 341
    Top = 55
  end
  object DtsPOSListesi: TDataSource
    DataSet = TabPOSListesi
    Left = 339
    Top = 99
  end
  object TabKrediKartiTipi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from KREDIKARTITURLERI where DURUM=1')
    Left = 158
    Top = 71
  end
  object DtsKrediKartiTipi: TDataSource
    DataSet = TabKrediKartiTipi
    Left = 156
    Top = 115
  end
end
