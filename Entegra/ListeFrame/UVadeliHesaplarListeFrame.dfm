object VadeliHesaplarListeFrame: TVadeliHesaplarListeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
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
  object GridTakvim: TcxGrid
    Left = 0
    Top = 32
    Width = 451
    Height = 272
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object TakvimView: TcxGridDBTableView
      OnDblClick = TakvimViewDblClick
      Navigator.Buttons.CustomButtons = <>
      OnCanFocusRecord = TakvimViewCanFocusRecord
      DataController.DataSource = DtsVadeliHesap
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.CellAutoHeight = True
      OptionsView.GroupByBox = False
      object akvimViewLOGO: TcxGridDBColumn
        DataBinding.FieldName = 'LOGO'
        PropertiesClassName = 'TcxImageProperties'
        Properties.GraphicClassName = 'TdxPNGImage'
        IsCaptionAssigned = True
      end
      object akvimViewBANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
      end
      object TakvimViewKOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 102
      end
      object TakvimViewADI: TcxGridDBColumn
        Caption = 'Ad'#305
        DataBinding.FieldName = 'ADI'
        Width = 38
      end
      object TakvimViewVADESIZHESAPKODU: TcxGridDBColumn
        Caption = 'Vadesiz Hesap Kodu'
        DataBinding.FieldName = 'VADESIZHESAPKODU'
        Width = 101
      end
      object TakvimViewVADESIZHESAPNO: TcxGridDBColumn
        Caption = 'Vadesiz Hesap No'
        DataBinding.FieldName = 'VADESIZHESAPNO'
        Width = 90
      end
      object TakvimViewVADESIZHESAPADI: TcxGridDBColumn
        Caption = 'Vadesiz Hesap Ad'#305
        DataBinding.FieldName = 'VADESIZHESAPADI'
        Width = 98
      end
      object TakvimViewVADELIHESAPKODU: TcxGridDBColumn
        Caption = 'Vadeli Hesap Kodu'
        DataBinding.FieldName = 'VADELIHESAPKODU'
        Width = 98
      end
      object TakvimViewVADELIHESAPNO: TcxGridDBColumn
        Caption = 'Vadeli Hesap No'
        DataBinding.FieldName = 'VADELIHESAPNO'
        Width = 82
      end
      object TakvimViewVADELIHESAPADI: TcxGridDBColumn
        Caption = 'Vadeli Hesap Ad'#305
        DataBinding.FieldName = 'VADELIHESAPADI'
        Width = 99
      end
    end
    object cxGridLevel4: TcxGridLevel
      GridView = TakvimView
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 29
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
    TabOrder = 1
    Transparent = True
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = YeniTusClick
    end
    object DegisTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
  end
  object DtsVadeliHesap: TDataSource
    DataSet = TabVadeliHesap
    Left = 169
    Top = 136
  end
  object TabVadeliHesap: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'P1'
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = Null
      end
      item
        Name = 'P2'
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 50
        Value = Null
      end>
    SQL.Strings = (
      'select V.*,B.LOGO,B.BANKAADI,BS.SUBEADI  from VADELIHESAP V'
      'inner join BANKAHESAPLAR BH ON  BH.ID = V.VADESIZHESAPID'
      'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where V.KOD like :P1 or V.ADI like :P2')
    Left = 77
    Top = 135
  end
end

