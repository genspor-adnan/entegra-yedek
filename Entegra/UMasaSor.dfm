object MasaSorDlg: TMasaSorDlg
  Left = 0
  Top = 0
  Caption = 'MasaForm'
  ClientHeight = 340
  ClientWidth = 146
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 33
    Height = 13
    Caption = 'Masa:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 43
    Height = 13
    Caption = 'Garson:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 112
    Width = 29
    Height = 13
    Caption = 'S'#252're:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 72
    Top = 8
    Width = 41
    Height = 13
    Caption = 'Mekan:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 72
    Top = 24
    Width = 31
    Height = 13
    Caption = 'Label6'
  end
  object cxTextEdit1: TcxTextEdit
    Left = 8
    Top = 72
    TabOrder = 0
    Width = 121
  end
  object cxTextEdit2: TcxTextEdit
    Left = 8
    Top = 128
    TabOrder = 1
    Width = 121
  end
  object cxButton1: TcxButton
    Left = 8
    Top = 168
    Width = 121
    Height = 33
    Caption = 'Servis A'#231
    TabOrder = 2
    OnClick = cxButton1Click
  end
  object cxButton2: TcxButton
    Left = 8
    Top = 216
    Width = 121
    Height = 33
    Caption = 'Servis Sonland'#305'r'
    TabOrder = 3
    OnClick = cxButton2Click
  end
  object cxButton3: TcxButton
    Left = 8
    Top = 283
    Width = 121
    Height = 49
    Caption = 'Kapat'
    TabOrder = 4
    OnClick = cxButton3Click
  end
end
