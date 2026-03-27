object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Dental Diyagram (Delphi 12 '#226#8364#8220' VCL)'
  ClientHeight = 700
  ClientWidth = 1100
  Color = 986895
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 15
  object Paint: TPaintBox
    Left = 0
    Top = 48
    Width = 760
    Height = 652
    Align = alClient
    PopupMenu = Popup
    OnMouseDown = PaintMouseDown
    OnPaint = PaintPaint
    ExplicitTop = 0
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object CmbView: TComboBox
      Left = 10
      Top = 10
      Width = 230
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Hekim g'#195#182'r'#195#188'n'#195#188'm'#195#188' (FDI)'
      OnChange = CmbViewChange
      Items.Strings = (
        'Hekim g'#195#182'r'#195#188'n'#195#188'm'#195#188' (FDI)'
        'Hasta g'#195#182'r'#195#188'n'#195#188'm'#195#188' (ayna)')
    end
    object BtnExport: TButton
      Left = 260
      Top = 10
      Width = 120
      Height = 24
      Caption = 'D'#196#177#197#376'a aktar (JSON)'
      TabOrder = 1
      OnClick = BtnExportClick
    end
    object BtnImport: TButton
      Left = 390
      Top = 10
      Width = 90
      Height = 24
      Caption = #196#176#195#167'e aktar'
      TabOrder = 2
      OnClick = BtnImportClick
    end
    object BtnReset: TButton
      Left = 486
      Top = 10
      Width = 80
      Height = 24
      Caption = 'S'#196#177'f'#196#177'rla'
      TabOrder = 3
      OnClick = BtnResetClick
    end
  end
  object RightPanel: TPanel
    Left = 760
    Top = 48
    Width = 340
    Height = 652
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object LblSel: TLabel
      Left = 12
      Top = 12
      Width = 84
      Height = 15
      Caption = 'Se'#195#167'ili di'#197#376': '#226#8364#8221
    end
    object MemoJSON: TMemo
      Left = 10
      Top = 40
      Width = 320
      Height = 560
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Popup: TPopupMenu
    Left = 32
    Top = 88
    object miHealthy: TMenuItem
      Tag = 1
      Caption = #63458' Sa'#287'l'#305'kl'#305
      OnClick = MenuStatusClick
    end
    object miCaries: TMenuItem
      Tag = 2
      Caption = #62772' '#199#252'r'#252'k'
      OnClick = MenuStatusClick
    end
    object miFilled: TMenuItem
      Tag = 3
      Caption = #62769' Dolgu'
      OnClick = MenuStatusClick
    end
    object miRoot: TMenuItem
      Tag = 4
      Caption = #63465' Kanal'
      OnClick = MenuStatusClick
    end
    object miCrown: TMenuItem
      Tag = 5
      Caption = #62545' Kuron'
      OnClick = MenuStatusClick
    end
    object miImplant: TMenuItem
      Tag = 6
      Caption = #63927' '#304'mplant'
      OnClick = MenuStatusClick
    end
    object miFracture: TMenuItem
      Tag = 7
      Caption = #9889' K'#305'r'#305'k'
      OnClick = MenuStatusClick
    end
    object miSep: TMenuItem
      Caption = '-'
    end
    object miMissing: TMenuItem
      Tag = 8
      Caption = #63147' Eksik'
      OnClick = MenuStatusClick
    end
    object miClear: TMenuItem
      Caption = #10226' Temizle'
      OnClick = MenuStatusClick
    end
  end
end
