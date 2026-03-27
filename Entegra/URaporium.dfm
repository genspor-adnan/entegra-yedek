object RaporiumDlg: TRaporiumDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Gentegre Rapor G'#252'ncellemeleri'
  ClientHeight = 525
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 522
    Width = 726
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 406
    ExplicitWidth = 792
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 726
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnDblClick = Panel1DblClick
    object cxProgressBar1: TcxProgressBar
      Left = 152
      Top = 9
      Properties.PeakValue = 20.000000000000000000
      TabOrder = 0
      Width = 433
    end
  end
  object RaporiumGrid: TcxGrid
    Left = 0
    Top = 41
    Width = 726
    Height = 440
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object RaporiumGridTableView: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      OnCanFocusRecord = RaporiumGridTableViewCanFocusRecord
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.Indicator = True
      object RaporiumGridTvSec: TcxGridColumn
        Caption = 'Se'#231
        DataBinding.ValueType = 'Boolean'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Visible = False
        HeaderAlignmentHorz = taCenter
        Options.Sorting = False
        Width = 35
      end
      object RaporiumGridTvTarih: TcxGridColumn
        Caption = 'Tarih'
        PropertiesClassName = 'TcxDateEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 111
      end
      object RaporiumGridTvModul: TcxGridColumn
        Caption = 'Mod'#252'l'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 107
      end
      object RaporiumGridTvGrubu: TcxGridColumn
        Caption = 'Grubu'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 100
      end
      object RaporiumGridTvRaporAdi: TcxGridColumn
        Caption = 'Rapor Ad'#305
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 251
      end
      object RaporiumGridTvDurum: TcxGridColumn
        Caption = 'Durum'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 95
      end
      object RaporiumGridTvID: TcxGridColumn
        Caption = 'ID'
        Visible = False
      end
      object RaporiumGridTvSqlVersiyon: TcxGridColumn
        Visible = False
      end
      object RaporiumGridTvEkranVersiyon: TcxGridColumn
        Visible = False
      end
    end
    object RaporiumGridLevel3: TcxGridLevel
      GridView = RaporiumGridTableView
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 481
    Width = 726
    Height = 41
    Align = alBottom
    TabOrder = 2
    object TamamTus: TcxButton
      Left = 280
      Top = 6
      Width = 113
      Height = 25
      Caption = 'Tamam'
      TabOrder = 0
      Visible = False
      OnClick = TamamTusClick
    end
  end
end
