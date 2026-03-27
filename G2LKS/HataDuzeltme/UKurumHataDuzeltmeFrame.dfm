object KurumHataDuzeltmeFrame: TKurumHataDuzeltmeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 168
  Align = alTop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    451
    168)
  object Bevel1: TBevel
    Left = 0
    Top = 40
    Width = 650
    Height = 9
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object kodDBText: TDBText
    Left = 8
    Top = 71
    Width = 193
    Height = 17
    DataField = 'KURUM'
    DataSource = KurumTableDataSource
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
  object JvPanel1: TJvPanel
    Left = 0
    Top = 0
    Width = 451
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
    ExplicitWidth = 621
    object hataStaticText: TStaticText
      Left = 2
      Top = 2
      Width = 138
      Height = 17
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
    DataField = 'CARIKODU'
    DataSource = KurumTableDataSource
    TabOrder = 1
  end
  object karsiMuhasebeKodDBEdit: TDBEdit
    Left = 361
    Top = 68
    Width = 145
    Height = 21
    DataField = 'MUHASEBEKODU'
    DataSource = KurumTableDataSource
    TabOrder = 2
  end
  object KurumTableDataSource: TDataSource
    DataSet = KurumTable
    Left = 208
  end
  object KurumTable: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'KURUM'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 30
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT KURUM,CARIKODU,MUHASEBEKODU FROM KURUM WHERE KURUM = :KUR' +
        'UM')
    Left = 240
  end
end
