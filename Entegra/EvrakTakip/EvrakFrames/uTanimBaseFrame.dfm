object EvrakTanimBaseFrame: TEvrakTanimBaseFrame
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object PanelTop: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 634
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object buttonKaydet: TSpeedButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 66
      Height = 32
      Action = actKaydet
      Align = alLeft
      ExplicitLeft = 4
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonListele: TSpeedButton
      AlignWithMargins = True
      Left = 75
      Top = 3
      Width = 68
      Height = 32
      Action = actListele
      Align = alLeft
      ExplicitLeft = 77
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonYeniKayit: TSpeedButton
      AlignWithMargins = True
      Left = 149
      Top = 3
      Width = 80
      Height = 32
      Action = actYeniKayit
      Align = alLeft
      ExplicitLeft = 150
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonSil: TSpeedButton
      AlignWithMargins = True
      Left = 235
      Top = 3
      Width = 60
      Height = 32
      Action = actSil
      Align = alLeft
      ExplicitLeft = 246
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonDetay: TSpeedButton
      AlignWithMargins = True
      Left = 301
      Top = 3
      Width = 102
      Height = 32
      Action = actDetayDuzenle
      Align = alLeft
      ExplicitLeft = 302
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonYazdir: TSpeedButton
      AlignWithMargins = True
      Left = 409
      Top = 3
      Width = 62
      Height = 32
      Action = actYazdir
      Align = alLeft
      ExplicitLeft = 410
      ExplicitTop = 4
      ExplicitHeight = 30
    end
    object buttonReset: TSpeedButton
      AlignWithMargins = True
      Left = 477
      Top = 3
      Width = 139
      Height = 32
      Action = actReset
      Align = alLeft
      ExplicitLeft = 478
      ExplicitTop = 4
      ExplicitHeight = 30
    end
  end
  object ActionListFrame: TActionList
    Images = dmEvrakModule.ImagesEvrak
    Left = 480
    Top = 96
    object actKaydet: TAction
      Caption = 'Kaydet'
      ImageIndex = 14
    end
    object actListele: TAction
      Caption = 'Listele'
      ImageIndex = 104
    end
    object actYeniKayit: TAction
      Caption = 'Yeni Kay'#305't'
      ImageIndex = 2
    end
    object actSil: TAction
      Caption = 'Sil'
      ImageIndex = 9
    end
    object actDetayDuzenle: TAction
      Caption = 'Detay D'#252'zenle'
      ImageIndex = 105
    end
    object actYazdir: TAction
      Caption = 'Yazd'#305'r'
      ImageIndex = 108
    end
    object Action7: TAction
      Caption = 'Action7'
    end
    object actReset: TAction
      Caption = #304'lk Kay'#305'ttan Olu'#351'tur'
      ImageIndex = 27
    end
  end
end
