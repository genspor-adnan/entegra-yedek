object YeniDilDlg: TYeniDilDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Dil Ekran'#305
  ClientHeight = 337
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GridGenIniYeniDil: TcxGrid
    Left = 0
    Top = 24
    Width = 651
    Height = 313
    Align = alClient
    TabOrder = 0
    object GridGenIniYeniDilDBTableView1: TcxGridDBTableView
      DragMode = dmAutomatic
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsDiller
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.DragFocusing = dfDragDrop
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.Appending = True
      OptionsView.GroupByBox = False
      object GridGenIniYeniDilDBTableView1DEGER: TcxGridDBColumn
        Caption = 'De'#287'er'
        DataBinding.FieldName = 'DEGER'
        Visible = False
        Width = 40
      end
      object GridGenIniYeniDilDBTableView1SIRA: TcxGridDBColumn
        Caption = 'S'#305'ra'
        DataBinding.FieldName = 'SIRA'
        Visible = False
        Width = 30
      end
      object GridGenIniYeniDilDBTableView1BOLUM: TcxGridDBColumn
        Caption = 'Bolum'
        DataBinding.FieldName = 'BOLUM'
        Visible = False
      end
    end
    object GridGenIniYeniDilLevel1: TcxGridLevel
      GridView = GridGenIniYeniDilDBTableView1
    end
  end
  object ToolBarProblem: TToolBar
    Left = 0
    Top = 0
    Width = 651
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 47
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object BtnYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = BtnYeniClick
    end
    object BtnSil: TToolButton
      Left = 47
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = BtnSilClick
    end
    object BtnKaydet: TToolButton
      Left = 94
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 141
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
    end
  end
  object TabDiller: TFDQuery
    Connection = Tablo.FDCnn
    AfterPost = TabDillerAfterPost
    ParamData = <>
    Left = 48
    Top = 120
  end
  object DtsDiller: TDataSource
    DataSet = TabDiller
    OnStateChange = DtsDillerStateChange
    Left = 104
    Top = 104
  end
  object GENINIKullanimdakiDil: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      '  * '
      'from '
      '  GENINI'
      'where '
      ' DIL <> 0 AND'
      '  DIL = :PDil'
      'order by '
      '  SIRA')
    Left = 44
    Top = 232
  end
  object GENINITumDiller: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      '  * '
      'from '
      '  GENINI'
      'where '
      'DIL<>0 '
      '--and   BOLUM=:PBolum '
      ' order by '
      '  SIRA')
    Left = 45
    Top = 181
  end
  object Query1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 256
    Top = 104
  end
  object Query2: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 240
    Top = 184
  end
end



