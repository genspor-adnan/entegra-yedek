object DBSListeFrame: TDBSListeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
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
    Font.Name = 'Arial'
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
  object cxGrid: TcxGrid
    Left = 0
    Top = 35
    Width = 451
    Height = 269
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridTview: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridTviewCanFocusRecord
      DataController.DataSource = DtsDBS
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.CellAutoHeight = True
      OptionsView.Indicator = True
      object GridTviewLOGO: TcxGridDBColumn
        DataBinding.FieldName = 'LOGO'
        PropertiesClassName = 'TcxImageProperties'
        Properties.GraphicClassName = 'TdxPNGImage'
        IsCaptionAssigned = True
      end
      object GridTviewBANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
      end
      object GridTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Pasif'
            Value = 0
          end>
        Width = 43
      end
      object GridTviewSOZLESME_TARIHI: TcxGridDBColumn
        Caption = 'S'#246'zl.Tarihi'
        DataBinding.FieldName = 'SOZLESME_TARIHI'
        Width = 65
      end
      object GridTviewKREDIHESAPKODU: TcxGridDBColumn
        Caption = 'Kredi Hs.Kodu'
        DataBinding.FieldName = 'KREDIHESAPKODU'
        Width = 63
      end
      object GridTviewKREDIHESAPADI: TcxGridDBColumn
        Caption = 'Kredi Hs.Ad'#305
        DataBinding.FieldName = 'KREDIHESAPADI'
        Width = 109
      end
      object GridTviewBORCLUKOD: TcxGridDBColumn
        Caption = 'Bor'#231'lu Kodu'
        DataBinding.FieldName = 'BORCLUKOD'
        Width = 68
      end
      object GridTviewBORCLUUNVAN: TcxGridDBColumn
        Caption = 'Bor'#231'lu Ad'#305
        DataBinding.FieldName = 'BORCLUUNVAN'
        Width = 134
      end
      object GridTviewALACAKLIKOD: TcxGridDBColumn
        Caption = 'Alacakl'#305' Kodu'
        DataBinding.FieldName = 'ALACAKLIKOD'
        Width = 75
      end
      object GridTviewALACAKLIFIRMA: TcxGridDBColumn
        Caption = 'Alacakl'#305' Ad'#305
        DataBinding.FieldName = 'ALACAKLIFIRMA'
        Width = 148
      end
      object GridTviewTICARIHESAPKODU: TcxGridDBColumn
        Caption = 'Ticari Hs.Kodu'
        DataBinding.FieldName = 'TICARIHESAPKODU'
      end
      object GridTviewTICARIHESAPADI: TcxGridDBColumn
        Caption = 'Ticari Hs.Ad'#305
        DataBinding.FieldName = 'TICARIHESAPADI'
        Width = 134
      end
      object GridTviewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtak
        Width = 106
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = GridTview
    end
  end
  object DtsDBS: TDataSource
    DataSet = TabDBS
    Left = 169
    Top = 136
  end
  object TabDBS: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'SELECT  D.ID, D.DURUM,SOZLESME_TARIHI,BH2.HESAPKODU AS KREDIHESA' +
        'PKODU,BH2.HESAPADI AS KREDIHESAPADI,'
      
        ' R2.KOD AS BORCLUKOD, R2.FIRMA AS BORCLUUNVAN, R1.KOD AS ALACAKL' +
        'IKOD, '
      'R1.FIRMA AS ALACAKLIFIRMA,B.LOGO,B.BANKAADI,BS.SUBEADI,  '
      
        '      BH1.HESAPKODU AS TICARIHESAPKODU,BH1.HESAPADI AS TICARIHES' +
        'APADI '
      '  FROM DBS D'
      '  left outer join REHBER R1 on R1.ID = D.REHBERID'
      '  left outer join REHBER R2 on R2.ID = D.BORCLUREHBERID'
      
        '  left outer join BANKAHESAPLAR BH1 on D.BANKA_ID_TICARI = BH1.I' +
        'D'
      '  left outer join BANKAHESAPLAR BH2 on D.BANKA_ID_KREDI = BH2.ID'
      'inner join BANKASUBELER BS ON BH1.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU')
    Left = 137
    Top = 136
  end
end

