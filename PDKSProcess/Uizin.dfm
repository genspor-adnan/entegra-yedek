object IzinDlg: TIzinDlg
  Left = 341
  Top = 214
  Caption = #304'zin Ekran'#305
  ClientHeight = 308
  ClientWidth = 509
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 63
    Height = 13
    Caption = 'Ad - Soyad'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 448
    Top = 278
    Width = 57
    Height = 25
    Caption = 'Kapat'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = SpeedButton1Click
  end
  object DBizin: TDBGrid
    Left = 8
    Top = 127
    Width = 497
    Height = 145
    DataSource = Tablo.dtsBasitIzin
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'PERKOD'
        ReadOnly = True
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'BASTAR'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'BITTAR'
        Width = 64
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'GUN'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ACIKLAMA'
        Width = 64
        Visible = True
      end>
  end
  object DBNavigator1: TDBNavigator
    Left = 8
    Top = 278
    Width = 240
    Height = 25
    DataSource = Tablo.dtsBasitIzin
    TabOrder = 1
  end
  object Eara: TEdit
    Left = 77
    Top = 5
    Width = 209
    Height = 21
    TabOrder = 2
    OnChange = EaraChange
  end
  object DBara: TDBGrid
    Left = 8
    Top = 32
    Width = 497
    Height = 89
    DataSource = Tablo.dtsizinara
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = DBaraDblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'PERKOD'
        ReadOnly = True
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ADI'
        ReadOnly = True
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'SOYADI'
        ReadOnly = True
        Width = 130
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'OZELGRUP'
        ReadOnly = True
        Width = 147
        Visible = True
      end>
  end
end
