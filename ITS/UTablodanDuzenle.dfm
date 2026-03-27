object TablodanDuzenleDlg: TTablodanDuzenleDlg
  Left = 0
  Top = 0
  Caption = 'TablodanDuzenleDlg'
  ClientHeight = 468
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 32
    Width = 639
    Height = 436
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 0
    object DBGrid1: TcxGrid
      Left = 6
      Top = 6
      Width = 627
      Height = 421
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      ExplicitHeight = 424
      object DBGrid1DBTableView1: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        OnCellDblClick = DBGrid1DBTableView1CellDblClick
        DataController.DataSource = DataSource1
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Kind = skSum
            Position = spFooter
          end
          item
            Kind = skSum
          end
          item
            Kind = skSum
            Position = spFooter
          end
          item
            Kind = skSum
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skSum
          end
          item
            Kind = skSum
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object DBGrid1DBTableView1Column1: TcxGridDBColumn
          PropertiesClassName = 'TcxTextEditProperties'
        end
      end
      object DBGrid1Level1: TcxGridLevel
        GridView = DBGrid1DBTableView1
      end
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 633
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
    object KaydetTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 222
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = IptalTusClick
    end
    object ToolButton3: TToolButton
      Left = 296
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 18
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 304
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      OnClick = GorTusClick
    end
    object ToolButton1: TToolButton
      Left = 378
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object SecTus: TToolButton
      Left = 386
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 1
      Visible = False
      OnClick = SecTusClick
    end
  end
  object DataSource1: TDataSource
    DataSet = Query1
    OnStateChange = DataSource1StateChange
    Left = 328
    Top = 105
  end
  object Query1: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterOpen = Query1AfterOpen
    Parameters = <>
    Left = 261
    Top = 105
  end
end
