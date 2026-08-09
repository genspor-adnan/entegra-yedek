object IskontoDlg: TIskontoDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #304'skonto Ekran'#305
  ClientHeight = 429
  ClientWidth = 799
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar4: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 793
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 66
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object BtnSonucYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      DropdownMenu = Menu1
      ImageIndex = 0
    end
    object BtnSonucSil: TToolButton
      Left = 66
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = BtnSonucSilClick
    end
    object BtnDuzenle: TToolButton
      Left = 132
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = BtnDuzenleClick
    end
  end
  object gridIskonto: TcxGrid
    Left = 0
    Top = 27
    Width = 799
    Height = 402
    Align = alClient
    TabOrder = 1
    object gridIskontoView: TcxGridDBTableView
      OnDblClick = BtnDuzenleClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsIskonto
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Appending = True
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object gridIskontoViewANAHTAR: TcxGridDBColumn
        Caption = 'Grup'
        DataBinding.FieldName = 'ANAHTAR'
        Width = 91
      end
      object gridIskontoViewKOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 74
      end
      object gridIskontoViewSTOKADI: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'STOKADI'
        Width = 316
      end
      object gridIskontoViewMIKTAR: TcxGridDBColumn
        Caption = 'Oran'
        DataBinding.FieldName = 'MIKTAR'
      end
      object gridIskontoViewDURUM: TcxGridDBColumn
        Caption = 'Aktif'
        DataBinding.FieldName = 'DURUM'
        Width = 58
      end
    end
    object gridIskontoLevel1: TcxGridLevel
      GridView = gridIskontoView
    end
  end
  object TabIskonto: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select KC.ID,KC.KAMPANYAID,G.ANAHTAR,'
      'SID=(case KC.KAMPANYAID'
      '  when -1 THEN (select S.ID from STOKLAR S where S.ID=KC.URUNID)'
      
        '  when -2 THEN (select K.ID from KATEGORI K where K.ID=KC.URUNID' +
        ')'
      'end),'
      'KOD=(case KC.KAMPANYAID'
      
        '  when -1 THEN (select S.KOD from STOKLAR S where S.ID=KC.URUNID' +
        ')'
      
        '  when -2 THEN (select K.KOD from KATEGORI K where K.ID=KC.URUNI' +
        'D)'
      
        '  when -11 THEN (select M.KOD from MASRAFGELIR M where M.ID=KC.U' +
        'RUNID)'
      
        '  when -12 THEN (select M.KOD from MASRAFGELIR M where M.ID=KC.U' +
        'RUNID)'
      'end),'
      'STOKADI=(case KC.KAMPANYAID'
      
        '  when -1 THEN (select S.STOKADI from STOKLAR S where S.ID=KC.UR' +
        'UNID)'
      
        '  when -2 THEN (select K.AD from KATEGORI K where K.ID=KC.URUNID' +
        ')'
      
        '  when -11 THEN (select M.AD from MASRAFGELIR M where M.ID=KC.UR' +
        'UNID)'
      
        '  when -12 THEN (select M.AD from MASRAFGELIR M where M.ID=KC.UR' +
        'UNID)'
      'end),'
      'KC.MIKTAR,KC.DURUM '
      'from KAMPANYACARI KC'
      
        'inner join GENINI G on G.BOLUM=-2221 and DIL=-1 and G.DEGER=KC.K' +
        'AMPANYAID'
      'where REHBERID=:PRehberID '
      'order by 2 DESC ,5'
      '')
    Left = 494
    Top = 101
    object TabIskontoID: TIntegerField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabIskontoKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabIskontoANAHTAR: TWideStringField
      FieldName = 'ANAHTAR'
      Size = 100
    end
    object TabIskontoSID: TIntegerField
      FieldName = 'SID'
      ReadOnly = True
    end
    object TabIskontoKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 50
    end
    object TabIskontoSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      ReadOnly = True
      Size = 150
    end
    object TabIskontoMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object TabIskontoDURUM: TBooleanField
      FieldName = 'DURUM'
    end
  end
  object DtsIskonto: TDataSource
    DataSet = TabIskonto
    Left = 609
    Top = 109
  end
  object Menu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 33
    Top = 84
    object TumUrunlerMenu: TMenuItem
      Tag = -3
      Caption = 'T'#252'm '#220'r'#252'nler'
      ImageIndex = 12
      OnClick = TumUrunlerMenuClick
    end
    object UrunMenu: TMenuItem
      Tag = -1
      Caption = #220'r'#252'n Ekle'
      ImageIndex = 12
      OnClick = UrunMenuClick
    end
    object UrunKategorisiMenu: TMenuItem
      Tag = -2
      Caption = #220'r'#252'n Kategorisi Ekle'
      ImageIndex = 12
      OnClick = UrunKategorisiMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object TumHizmetlerMenu: TMenuItem
      Tag = -13
      Caption = 'T'#252'm Hizmetler'
      ImageIndex = 15
      OnClick = TumUrunlerMenuClick
    end
    object Hizmet1: TMenuItem
      Tag = -11
      Caption = 'Hizmet Ekle'
      ImageIndex = 0
      OnClick = UrunMenuClick
    end
    object HizmetKategorisi1: TMenuItem
      Tag = -12
      Caption = 'Hizmet Kategorisi Ekle'
      ImageIndex = 0
      Visible = False
      OnClick = UrunKategorisiMenuClick
    end
  end
end

