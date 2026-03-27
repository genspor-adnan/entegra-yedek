object HataKontrolForm: THataKontrolForm
  Left = 246
  Top = 180
  BorderStyle = bsSingle
  Caption = 'Hatal'#305' Kay'#305'tlar'
  ClientHeight = 464
  ClientWidth = 677
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    677
    464)
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 209
    Width = 677
    Height = 5
    Cursor = crVSplit
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 677
    Height = 209
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 0
      Width = 107
      Height = 13
      Caption = 'Hatal'#305' olan kay'#305'tlar'
    end
  end
  object closeButton: TButton
    Left = 595
    Top = 433
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Kapat'
    TabOrder = 0
    OnClick = closeButtonClick
  end
  object altPanel: TPanel
    Left = 0
    Top = 214
    Width = 677
    Height = 250
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      677
      250)
    object Image1: TImage
      Left = 8
      Top = 223
      Width = 17
      Height = 17
      Anchors = [akLeft, akBottom]
      Transparent = True
    end
    object Label2: TLabel
      Left = 29
      Top = 218
      Width = 269
      Height = 26
      Anchors = [akLeft, akBottom]
      Caption = 
        'Listede g'#246'r'#252'nen kay'#305'tlar aktar'#305'lmam'#305#351't'#305'r.'#13#10'Hatalar'#305' d'#252'zeltip tek' +
        'rar deneyin.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end
