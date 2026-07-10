object DosyaMigrasyonDlg: TDosyaMigrasyonDlg
  Left = 0
  Top = 0
  Caption = 'Belgeleri DOSYA Deposuna Ta'#351#305'ma (Migrasyon)'
  ClientHeight = 461
  ClientWidth = 641
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 16
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 641
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblToplam: TLabel
      Left = 12
      Top = 10
      Width = 96
      Height = 16
      Caption = 'Tasinacak toplam: -'
    end
    object lblIstatistik: TLabel
      Left = 12
      Top = 30
      Width = 46
      Height = 16
      Caption = 'Islenen: -'
    end
    object lblDurum: TLabel
      Left = 12
      Top = 50
      Width = 3
      Height = 16
    end
    object ProgressBar1: TProgressBar
      Left = 323
      Top = 28
      Width = 309
      Height = 21
      TabOrder = 0
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 420
    Width = 641
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnBaslat: TButton
      Left = 12
      Top = 8
      Width = 90
      Height = 27
      Caption = 'Ba'#351'lat'
      TabOrder = 0
      OnClick = btnBaslatClick
    end
    object btnDurdur: TButton
      Left = 110
      Top = 8
      Width = 90
      Height = 27
      Caption = 'Durdur'
      Enabled = False
      TabOrder = 1
      OnClick = btnDurdurClick
    end
    object btnKapat: TButton
      Left = 539
      Top = 6
      Width = 90
      Height = 27
      Caption = 'Kapat'
      TabOrder = 2
      OnClick = btnKapatClick
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 73
    Width = 641
    Height = 347
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
