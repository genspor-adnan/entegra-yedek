object TakvimGenelHareketDlg: TTakvimGenelHareketDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'TakvimGenelHareketDlg'
  ClientHeight = 245
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelUst: TJvPanel
    Left = 157
    Top = 112
    Width = 152
    Height = 14
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Color = clRed
    Font.Charset = TURKISH_CHARSET
    Font.Color = clHighlightText
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
  end
  object JvPanel12: TJvPanel
    Left = 157
    Top = 88
    Width = 152
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Caption = ' '#199#305'kan'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object JvPanel2: TJvPanel
    Left = 2
    Top = 112
    Width = 152
    Height = 14
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Color = clGreen
    Font.Charset = TURKISH_CHARSET
    Font.Color = clHighlightText
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
  end
  object JvPanel8: TJvPanel
    Left = 2
    Top = 88
    Width = 152
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Caption = ' Giren'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clGreen
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object cxDBLabel9: TcxDBLabel
    Left = 245
    Top = 2
    DataBinding.DataField = 'ISLEMTARIHI'
    DataBinding.DataSource = DtsKasa
    Properties.Alignment.Vert = taVCenter
    Style.BorderColor = clNone
    Style.BorderStyle = ebsNone
    Style.TransparentBorder = False
    Transparent = True
    Height = 21
    Width = 62
    AnchorY = 13
  end
  object JvPanel1: TJvPanel
    Left = 157
    Top = 126
    Width = 152
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    object cxDBLabel1: TcxDBLabel
      Left = 0
      Top = 2
      DataBinding.DataField = 'ALACAK'
      DataBinding.DataSource = DtsKasa
      Properties.Alignment.Vert = taVCenter
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 120
      AnchorY = 13
    end
    object cxDBLabel2: TcxDBLabel
      Left = 123
      Top = 2
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsKasa
      Properties.Alignment.Vert = taVCenter
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 24
      AnchorY = 13
    end
  end
  object JvPanel3: TJvPanel
    Left = 2
    Top = 126
    Width = 152
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Font.Charset = TURKISH_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    object cxDBLabel3: TcxDBLabel
      Left = -1
      Top = 2
      DataBinding.DataField = 'BORC'
      DataBinding.DataSource = DtsKasa
      Properties.Alignment.Vert = taVCenter
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 121
      AnchorY = 13
    end
    object cxDBLabel4: TcxDBLabel
      Left = 123
      Top = 2
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsKasa
      Properties.Alignment.Vert = taVCenter
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 24
      AnchorY = 13
    end
  end
  object JvPanel4: TJvPanel
    Left = 2
    Top = 1
    Width = 237
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Caption = 'M'#252#351'teri Bilgileri'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
  end
  object JvDBImage1: TJvDBImage
    Left = 1
    Top = 29
    Width = 121
    Height = 55
    DataField = 'LOGO'
    DataSource = DtsMusteri
    ParentColor = True
    Stretch = True
    TabOrder = 8
    Transparent = True
  end
  object JvPanel5: TJvPanel
    Left = 126
    Top = 30
    Width = 182
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Caption = 'Kod:'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 9
    object cxDBLabel5: TcxDBLabel
      Left = 45
      Top = 2
      DataBinding.DataField = 'KOD'
      DataBinding.DataSource = DtsMusteri
      Properties.Alignment.Horz = taRightJustify
      Properties.Alignment.Vert = taVCenter
      Properties.Orientation = cxoRight
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 133
      AnchorX = 178
      AnchorY = 13
    end
  end
  object JvPanel6: TJvPanel
    Left = 126
    Top = 58
    Width = 182
    Height = 25
    HotTrackFont.Charset = TURKISH_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Alignment = taLeftJustify
    Caption = 'Firma:'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    object cxDBLabel6: TcxDBLabel
      Left = 45
      Top = 2
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = DtsMusteri
      Properties.Alignment.Horz = taRightJustify
      Properties.Alignment.Vert = taVCenter
      Properties.Orientation = cxoRight
      Style.BorderColor = clNone
      Style.BorderStyle = ebsNone
      Style.TransparentBorder = False
      Transparent = True
      Height = 21
      Width = 133
      AnchorX = 178
      AnchorY = 13
    end
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    Left = 207
    Top = 114
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 82
      end>
    SQL.Strings = (
      'SELECT * FROM KASA'
      'WHERE ID = :PID')
    Left = 205
    Top = 78
  end
  object TabMusteri: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 5582
      end>
    SQL.Strings = (
      'SELECT r.* ,'
      
        'LOGO= (SELECT BELGE FROM IMAJ I WHERE VARSAYILAN=1 AND YERI=11 A' +
        'ND YER_ID=r.ID )'
      ''
      ''
      'FROM REHBER r'
      'WHERE ID = :PID')
    Left = 61
    Top = 75
  end
  object DtsMusteri: TDataSource
    DataSet = TabMusteri
    Left = 64
    Top = 111
  end
end

