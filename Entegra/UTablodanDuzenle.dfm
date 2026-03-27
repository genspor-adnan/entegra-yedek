object TablodanDuzenleDlg: TTablodanDuzenleDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'TablodanDuzenleDlg'
  ClientHeight = 468
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 35
    Width = 639
    Height = 433
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 1
    ExplicitTop = 32
    ExplicitWidth = 635
    ExplicitHeight = 435
    object DBGrid1: TcxGrid
      Left = 6
      Top = 6
      Width = 627
      Height = 421
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      ExplicitWidth = 623
      ExplicitHeight = 423
      object DBGrid1DBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = DBGrid1DBTableView1CanFocusRecord
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
        FilterRow.Visible = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
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
    ExplicitWidth = 629
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
    object KaydetTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 222
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      OnClick = IptalTusClick
    end
    object ToolButton3: TToolButton
      Left = 296
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 304
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = GorTusClick
    end
    object ToolButton1: TToolButton
      Left = 378
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object SecTus: TToolButton
      Left = 386
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 1
      ImageName = 'PngImage0'
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
  object Query1: TFDQuery
    AfterOpen = Query1AfterOpen
    OnNewRecord = Query1NewRecord
    ParamData = <>
    Left = 261
    Top = 105
  end
end

