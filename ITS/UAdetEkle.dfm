object AdetEkleDlg: TAdetEkleDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Adet Ekle'
  ClientHeight = 145
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 412
    Height = 94
    Align = alClient
    TabOrder = 0
    object EdtGonAdet: TcxSpinEdit
      Left = 255
      Top = 37
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -35
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      OnKeyPress = EdtGonAdetKeyPress
      Width = 148
    end
    object cxLabel1: TcxLabel
      Left = 16
      Top = 8
      Caption = #304'stenen Adet'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -21
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 254
      Top = 8
      Caption = 'G'#246'nderilen Adet'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -21
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel1: TcxDBLabel
      Left = 21
      Top = 38
      DataBinding.DataField = 'ADET'
      DataBinding.DataSource = HizliUrunCikisDlg.dtsUrunler
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -35
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Height = 40
      Width = 49
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 94
    Width = 412
    Height = 51
    Align = alBottom
    TabOrder = 1
    object BtnTamam: TcxButton
      Left = 255
      Top = 1
      Width = 156
      Height = 49
      Align = alRight
      Caption = 'Tamam'
      TabOrder = 0
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnTamamClick
    end
  end
end
