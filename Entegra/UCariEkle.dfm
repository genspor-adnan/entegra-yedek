object CariEkleDlg: TCariEkleDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Cari Bilgi '#214'zet'
  ClientHeight = 429
  ClientWidth = 439
  Color = clGradientActiveCaption
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cxLabel4: TcxLabel
    Left = 14
    Top = 55
    Caption = 'M'#252#351'teri Ad'#305
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditMusteri: TcxTextEdit
    Left = 117
    Top = 57
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 1
    Width = 306
  end
  object cxLabel1: TcxLabel
    Left = 14
    Top = 90
    Caption = 'Cep Tel'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditCepTel: TcxTextEdit
    Left = 117
    Top = 92
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 3
    Width = 170
  end
  object cxLabel2: TcxLabel
    Left = 14
    Top = 126
    Caption = #304#351' Tel'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditIstel: TcxTextEdit
    Left = 117
    Top = 128
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 5
    Width = 170
  end
  object cxLabel3: TcxLabel
    Left = 14
    Top = 161
    Caption = 'Ev Tel'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditEvTel: TcxTextEdit
    Left = 117
    Top = 163
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 7
    Width = 170
  end
  object cxLabel5: TcxLabel
    Left = 14
    Top = 196
    Caption = 'Adres'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel6: TcxLabel
    Left = 14
    Top = 252
    Caption = #304'l'#231'e'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
    Visible = False
  end
  object EditIlce: TcxTextEdit
    Left = 117
    Top = 253
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 11
    Visible = False
    Width = 124
  end
  object EditAdres: TcxMemo
    Left = 117
    Top = 198
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 10
    Height = 49
    Width = 306
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 439
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object KapatTus: TJvNavPanelButton
      Left = 315
      Top = 0
      Width = 124
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 18
      Images = Tablo.PNGImageList1
      OnClick = KapatTusClick
      ExplicitLeft = 120
    end
    object KaydetTus: TJvNavPanelButton
      Left = 0
      Top = 0
      Width = 124
      Height = 37
      Align = alLeft
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kaydet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 10
      Images = Tablo.PNGImageList1
      OnClick = KaydetTusClick
      ExplicitLeft = 120
    end
  end
  object cxLabel7: TcxLabel
    Left = 14
    Top = 284
    Caption = 'E-Posta'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditEPosta: TcxTextEdit
    Left = 117
    Top = 286
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 13
    Width = 306
  end
  object cxLabel8: TcxLabel
    Left = 247
    Top = 253
    Caption = #304'l'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
    Visible = False
  end
  object EditIl: TcxTextEdit
    Left = 265
    Top = 253
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 12
    Visible = False
    Width = 158
  end
  object cxLabel9: TcxLabel
    Left = 14
    Top = 317
    Caption = 'Notlar'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TextColor = clBlack
    Style.IsFontAssigned = True
    Transparent = True
  end
  object MemoNotlar: TcxMemo
    Left = 117
    Top = 319
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 14
    Height = 49
    Width = 306
  end
end
