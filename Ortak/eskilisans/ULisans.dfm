object LisansDlg: TLisansDlg
  Left = 290
  Top = 216
  Width = 347
  Height = 281
  BorderIcons = []
  Caption = 'GenoTIP Lisans Bilgisi'
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clNavy
  Font.Height = -13
  Font.Name = 'Times New Roman'
  Font.Style = [fsBold]
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 15
  object Bevel1: TBevel
    Left = 24
    Top = 47
    Width = 273
    Height = 121
  end
  object Label1: TLabel
    Left = 16
    Top = 10
    Width = 292
    Height = 24
    Caption = 'Kay'#305'tl'#305' lisans bilgisi bulunamad'#305'.. '
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -21
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 74
    Top = 83
    Width = 31
    Height = 15
    Caption = 'Tarih'
  end
  object Label3: TLabel
    Left = 122
    Top = 83
    Width = 37
    Height = 15
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 60
    Top = 109
    Width = 47
    Height = 15
    Caption = 'Kay'#305't No'
    OnDblClick = Label4DblClick
  end
  object Label5: TLabel
    Left = 122
    Top = 107
    Width = 8
    Height = 15
    Caption = '--'
    Color = clBtnFace
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Label6: TLabel
    Left = 53
    Top = 135
    Width = 55
    Height = 15
    Caption = 'Lisans No'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 69
    Top = 57
    Width = 186
    Height = 15
    Caption = 'L'#252'tfen lisans numaras'#305'n'#305' giriniz :'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 161
    Top = 107
    Width = 8
    Height = 15
    Caption = '--'
    Color = clBtnFace
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Label9: TLabel
    Left = 199
    Top = 107
    Width = 8
    Height = 15
    Caption = '--'
    Color = clBtnFace
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Label10: TLabel
    Left = 238
    Top = 107
    Width = 8
    Height = 15
    Caption = '--'
    Color = clBtnFace
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 122
    Top = 131
    Width = 121
    Height = 23
    TabOrder = 0
  end
  object ToolBar1: TToolBar
    Left = 202
    Top = 214
    Width = 106
    Height = 28
    Align = alNone
    ButtonHeight = 23
    ButtonWidth = 47
    Caption = 'ToolBar1'
    EdgeBorders = []
    Flat = True
    ShowCaptions = True
    TabOrder = 1
    object CancelBtn: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 1
      OnClick = CancelBtnClick
    end
    object OKBtn: TToolButton
      Left = 47
      Top = 0
      Caption = 'Tamam'
      ImageIndex = 0
      OnClick = OKBtnClick
    end
  end
  object piKeyPass1: TpiKeyPass
    About = '(C) 2000, Programmed Integration'
    Date = 38048.872539606500000000
    Version = '1.01'
    Left = 8
    Top = 176
  end
  object BHDInfo1: TBHDInfo
    Channel = Primary
    Drive = First
    Left = 168
    Top = 200
  end
end
