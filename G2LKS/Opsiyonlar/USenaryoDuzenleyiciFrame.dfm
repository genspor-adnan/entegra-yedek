object SenaryoDuzenleyiciFrame: TSenaryoDuzenleyiciFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinWidth = 376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      451
      97)
    object Label1: TLabel
      Left = 8
      Top = 5
      Width = 87
      Height = 13
      Caption = 'Senaryo Listesi'
    end
    object Label2: TLabel
      Left = 8
      Top = 80
      Width = 109
      Height = 13
      Caption = #199'al'#305#351#305'lan Senaryo :'
    end
    object suAnkiSenaryoAdiLabel: TLabel
      Left = 120
      Top = 80
      Width = 313
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel1: TBevel
      Left = 8
      Top = 72
      Width = 373
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
      ExplicitWidth = 365
    end
    object kodListesiComboBox: TComboBox
      Left = 8
      Top = 20
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object yukleButton: TButton
      Left = 157
      Top = 20
      Width = 75
      Height = 21
      Action = YukleAction
      TabOrder = 1
    end
    object kaydetButton: TButton
      Left = 157
      Top = 44
      Width = 75
      Height = 21
      Action = SaklaAction
      TabOrder = 2
    end
    object yeniButton: TButton
      Left = 235
      Top = 20
      Width = 67
      Height = 21
      Action = YeniAction
      TabOrder = 3
    end
    object Button1: TButton
      Left = 235
      Top = 44
      Width = 67
      Height = 21
      Action = SilAction
      TabOrder = 4
    end
  end
  object SenaryoDuzenleyiciSynEdit: TSynEdit
    Left = 0
    Top = 97
    Width = 451
    Height = 207
    Align = alClient
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 1
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Highlighter = SynPasSyn2
    WantTabs = True
    OnChange = SenaryoDuzenleyiciSynEditChange
  end
  object SynPasSyn2: TSynPasSyn
    CommentAttri.Foreground = clGreen
    KeyAttri.Foreground = clBlue
    StringAttri.Foreground = clMaroon
    SymbolAttri.Foreground = clFuchsia
    Left = 16
    Top = 88
  end
  object KodDuzenActionList: TActionList
    Left = 56
    Top = 136
    object YukleAction: TAction
      Category = 'Kod D'#252'zenleme'
      Caption = 'Yukle'
      OnExecute = YukleActionExecute
      OnUpdate = YukleActionUpdate
    end
    object YeniAction: TAction
      Category = 'Kod D'#252'zenleme'
      Caption = 'Yeni'
      OnExecute = YeniActionExecute
    end
    object SaklaAction: TAction
      Category = 'Kod D'#252'zenleme'
      Caption = 'Sakla'
      OnExecute = SaklaActionExecute
      OnUpdate = SaklaActionUpdate
    end
    object SilAction: TAction
      Category = 'Kod D'#252'zenleme'
      Caption = 'Sil'
      OnExecute = SilActionExecute
      OnUpdate = SilActionUpdate
    end
  end
  object SynXMLSyn: TSynXMLSyn
    WantBracesParsed = False
    Left = 112
    Top = 96
  end
end
