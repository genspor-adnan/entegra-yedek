object HizmetHataDuzeltmeFrame: THizmetHataDuzeltmeFrame
  Left = 0
  Top = 0
  Width = 443
  Height = 101
  Align = alTop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    427
    85)
  object Bevel1: TBevel
    Left = 0
    Top = 40
    Width = 626
    Height = 9
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object kodDBText: TDBText
    Left = 8
    Top = 71
    Width = 193
    Height = 17
    DataField = 'KOD'
    DataSource = HizmetTableDataSource
  end
  object Label1: TLabel
    Left = 16
    Top = 48
    Width = 24
    Height = 13
    Caption = 'Kod'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 208
    Top = 48
    Width = 61
    Height = 13
    Caption = 'Kar'#351#305' Kod'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 361
    Top = 48
    Width = 130
    Height = 13
    Caption = 'Kar'#351#305' Muhasebe Kod'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object araButton: TSpeedButton
    Left = 334
    Top = 67
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = araButtonClick
  end
  object DBNavToolBtn1: TDBNavToolBtn
    Left = 512
    Top = 66
    Width = 53
    Height = 25
    Hint = 'Yap'#305'lan de'#287'i'#351'iklikleri g'#246'nderir'
    Caption = 'Kaydet'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    DataSource = HizmetTableDataSource
    BtnFunction = nbPost
  end
  object DBNavToolBtn2: TDBNavToolBtn
    Left = 568
    Top = 66
    Width = 53
    Height = 25
    Hint = 'Yap'#305'lan de'#287'i'#351'iklikleri iptal eder'
    Caption = #304'ptal'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    DataSource = HizmetTableDataSource
    BtnFunction = nbCancel
  end
  object JvPanel1: TJvPanel
    Left = 0
    Top = 0
    Width = 621
    Height = 33
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    FlatBorder = True
    FlatBorderColor = clRed
    Align = alTop
    BorderWidth = 1
    Color = 10198015
    TabOrder = 0
    object hataStaticText: TStaticText
      Left = 2
      Top = 2
      Width = 617
      Height = 29
      Align = alClient
      Caption = 'Hata a'#231#305'klamas'#305' buraya'
      TabOrder = 0
    end
  end
  object karsiKodDBEdit: TDBEdit
    Left = 208
    Top = 68
    Width = 121
    Height = 21
    DataField = 'OZELKOD'
    DataSource = HizmetTableDataSource
    TabOrder = 1
  end
  object karsiMuhasebeKodDBEdit: TDBEdit
    Left = 361
    Top = 68
    Width = 145
    Height = 21
    DataField = 'MUHKODU'
    DataSource = HizmetTableDataSource
    TabOrder = 2
  end
  object HizmetTableDataSource: TDataSource
    DataSet = HizmetTable
    Left = 208
  end
  object HizmetTable: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'KOD'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 15
        Value = Null
      end>
    SQL.Strings = (
      'SELECT KOD,OZELKOD,MUHKODU  FROM ISLEMLER WHERE KOD = :KOD')
    Left = 240
  end
end
