object TeminatMektuplariListeFrame: TTeminatMektuplariListeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object GridTakvim: TcxGrid
    Left = 0
    Top = 35
    Width = 451
    Height = 269
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitTop = 32
    ExplicitHeight = 272
    object TakvimView: TcxGridDBTableView
      OnDblClick = TakvimViewDblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = TakvimViewCanFocusRecord
      DataController.DataSource = DtsTeminatMektubu
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
      OptionsView.CellAutoHeight = True
      OptionsView.Indicator = True
      object akvimViewLOGO: TcxGridDBColumn
        DataBinding.FieldName = 'LOGO'
        PropertiesClassName = 'TcxImageProperties'
        Properties.GraphicClassName = 'TdxPNGImage'
        IsCaptionAssigned = True
      end
      object TakvimViewBANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
        Width = 125
      end
      object TakvimViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = True
          end
          item
            Description = 'Pasif'
            Value = False
          end>
        Width = 60
      end
      object TakvimViewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        Width = 112
      end
      object akvimViewSURESI: TcxGridDBColumn
        Caption = 'S'#252're'
        DataBinding.FieldName = 'SURESI'
        Width = 45
      end
      object TakvimViewMUHATAPADI: TcxGridDBColumn
        Caption = 'Muhatap'
        DataBinding.FieldName = 'MUHATAPADI'
        Width = 222
      end
      object TakvimViewTUTARI: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTARI'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 63
      end
      object TakvimViewKUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        Width = 67
      end
      object TakvimViewEKLEYEN: TcxGridDBColumn
        Caption = 'Kul.'
        DataBinding.FieldName = 'EKLEYEN'
        Width = 75
      end
      object akvimViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtak
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
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object DegisTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
  end
  object DtsTeminatMektubu: TDataSource
    DataSet = TabTeminatMektubu
    Left = 202
    Top = 195
  end
  object TabTeminatMektubu: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select T.*,B.LOGO,B.BANKAADI,BS.SUBEADI  from TEMINATMEKTUBU T'
      'inner join BANKAHESAPLAR BH ON  BH.ID = T.HESAPID'
      'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU')
    Left = 90
    Top = 205
  end
end

