object MailDokumDlg: TMailDokumDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'MailDokumDlg'
  ClientHeight = 399
  ClientWidth = 463
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
  object Panel1: TPanel
    Left = 0
    Top = 32
    Width = 463
    Height = 256
    Align = alClient
    TabOrder = 0
    object GridMailAdresleri: TcxGrid
      Left = 1
      Top = 59
      Width = 461
      Height = 196
      Align = alBottom
      TabOrder = 0
      object GridMailAdresleriView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtstabMailAdresleri
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object TvAdi: TcxGridDBColumn
          Caption = 'Ad'#305
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 177
        end
        object TvMailAdresi: TcxGridDBColumn
          Caption = 'Mail Adresi'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 280
        end
      end
      object GridMailAdresleriLevel1: TcxGridLevel
        GridView = GridMailAdresleriView
      end
    end
    object cxLabel3: TcxLabel
      Left = 30
      Top = 3
      Caption = 'Arama :'
    end
    object TxtArama: TcxTextEdit
      Left = 30
      Top = 26
      TabOrder = 2
      Width = 267
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 288
    Width = 463
    Height = 111
    Align = alBottom
    TabOrder = 1
    object Kime: TcxMemo
      Left = 72
      Top = 5
      TabOrder = 0
      Height = 30
      Width = 384
    end
    object Bilgi: TcxMemo
      Left = 72
      Top = 38
      TabOrder = 1
      Height = 30
      Width = 384
    end
    object cxLabel1: TcxLabel
      Left = 4
      Top = 14
      Caption = 'Kime'
    end
    object cxLabel2: TcxLabel
      Left = 4
      Top = 47
      Caption = 'Bilgi'
    end
    object Gizli: TcxMemo
      Left = 72
      Top = 70
      TabOrder = 4
      Height = 30
      Width = 384
    end
    object cxLabel4: TcxLabel
      Left = 4
      Top = 79
      Caption = 'Gizli'
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 457
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 68
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
    TabOrder = 2
    Transparent = True
    object btnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Tamam'
      ImageIndex = 11
      Style = tbsTextButton
      OnClick = btnKaydetClick
    end
    object ToolButton1: TToolButton
      Left = 68
      Top = 0
      Width = 12
      Caption = 'ToolButton1'
      ImageIndex = 18
      Style = tbsSeparator
    end
    object btnkapat: TToolButton
      Left = 80
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
    end
  end
  object tabMailAdresleri: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 352
    Top = 96
  end
  object dtstabMailAdresleri: TDataSource
    DataSet = tabMailAdresleri
    Left = 400
    Top = 96
  end
end

