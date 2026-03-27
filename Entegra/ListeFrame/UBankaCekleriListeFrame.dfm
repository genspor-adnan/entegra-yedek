object BankaCekleriListeFrame: TBankaCekleriListeFrame
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
  object cxGrid2: TcxGrid
    Left = 0
    Top = 35
    Width = 451
    Height = 269
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = False
    ExplicitTop = 32
    ExplicitHeight = 272
    object CekTview: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      OnCanFocusRecord = CekTviewCanFocusRecord
      DataController.DataSource = DtsCekler
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'TAKSIT'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'KDVSIZ'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'ANAPARA'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'FAIZ'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'KKDF'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'BSMV'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.CellAutoHeight = True
      OptionsView.Footer = True
      OptionsView.Indicator = True
      object CekTviewLOGO: TcxGridDBColumn
        DataBinding.FieldName = 'LOGO'
        PropertiesClassName = 'TcxImageProperties'
        Properties.GraphicClassName = 'TdxPNGImage'
        IsCaptionAssigned = True
      end
      object CekTviewBANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
        Width = 147
      end
      object CekTviewKREDIKODU: TcxGridDBColumn
        Caption = 'Kodu'
        DataBinding.FieldName = 'KREDIKODU'
        Width = 69
      end
      object CekTviewKREDIACIKLAMA: TcxGridDBColumn
        Caption = 'Ad'#305
        DataBinding.FieldName = 'KREDIADI'
        Width = 104
      end
      object CekTviewKREDITEMINAT: TcxGridDBColumn
        Caption = 'Teminat'
        DataBinding.FieldName = 'KREDITEMINAT'
        Width = 87
      end
      object CekTviewKREDILIMIT: TcxGridDBColumn
        Caption = 'Limit'
        DataBinding.FieldName = 'KREDILIMIT'
        Width = 90
      end
      object CekTviewCEKMIN: TcxGridDBColumn
        Caption = 'Min.'
        DataBinding.FieldName = 'CEKMIN'
        Width = 48
      end
      object CekTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepAktifPasif
        Width = 38
      end
      object CekTviewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtak
        Width = 109
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = CekTview
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
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 148
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 156
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
  end
  object DtsCekler: TDataSource
    DataSet = TabCekKredi
    Left = 169
    Top = 136
  end
  object TabCekKredi: TFDQuery
    Connection = Tablo.FDCnn
    BeforeOpen = TabCekKrediBeforeOpen
    ParamData = <>
    SQL.Strings = (
      'select CK.*,B.LOGO,B.BANKAADI, BS.SUBEADI from CEKKREDI CK '
      'inner join BANKAHESAPLAR BH ON  BH.ID = CK.HESAPID'
      'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU')
    Left = 102
    Top = 136
  end
end

