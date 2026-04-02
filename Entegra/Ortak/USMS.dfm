object SmsDlg: TSmsDlg
  Left = 679
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'SMS / E-Posta  G'#246'nderim Ekran'#305
  ClientHeight = 567
  ClientWidth = 961
  Color = 16744576
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 507
    Width = 38
    Height = 16
    Caption = 'Mesaj'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object rgTercih: TRadioGroup
    Left = 0
    Top = 0
    Width = 961
    Height = 33
    Align = alTop
    Caption = 'Tercih'
    Color = clSkyBlue
    Columns = 3
    Items.Strings = (
      'SMS'
      'E-Posta'
      'SMS + E-Posta')
    ParentColor = False
    TabOrder = 0
    OnClick = rgTercihClick
  end
  object rgZamanlama: TRadioGroup
    Left = 0
    Top = 33
    Width = 961
    Height = 33
    Align = alTop
    Caption = 'SMS G'#246'nderme Zaman'#305
    Color = clSkyBlue
    Columns = 2
    Items.Strings = (
      'Hemen '#350'imdi'
      #304'leriki Bir Zamanda')
    ParentColor = False
    TabOrder = 1
    OnClick = rgZamanlamaClick
  end
  object gbZamanli: TGroupBox
    Left = 0
    Top = 66
    Width = 961
    Height = 80
    Align = alTop
    Caption = 'Zamanlama'
    Color = clSkyBlue
    ParentColor = False
    TabOrder = 2
    object lbBaslangicTarihi: TLabel
      Left = 24
      Top = 21
      Width = 73
      Height = 13
      Caption = 'Ba'#351'lang'#305#231' Tarihi'
    end
    object lbBitisTarihi: TLabel
      Left = 24
      Top = 52
      Width = 48
      Height = 13
      Caption = 'Biti'#351' Tarihi'
    end
    object dtpBaslangic: TDateTimePicker
      Left = 128
      Top = 16
      Width = 89
      Height = 21
      Date = 38668.513087557900000000
      Time = 38668.513087557900000000
      TabOrder = 0
      OnChange = dtpBaslangicChange
    end
    object dtpBaslangicSaat: TDateTimePicker
      Left = 224
      Top = 16
      Width = 73
      Height = 21
      Date = 38668.513087557900000000
      Time = 38668.513087557900000000
      Kind = dtkTime
      TabOrder = 1
    end
    object dtpBitis: TDateTimePicker
      Left = 128
      Top = 47
      Width = 89
      Height = 21
      Date = 38668.513087557900000000
      Time = 38668.513087557900000000
      TabOrder = 2
    end
    object dtpBitisSaat: TDateTimePicker
      Left = 224
      Top = 47
      Width = 73
      Height = 21
      Date = 38668.513087557900000000
      Time = 38668.513087557900000000
      Kind = dtkTime
      TabOrder = 3
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 146
    Width = 961
    Height = 162
    Align = alTop
    Caption = 'Panel1'
    Color = clSkyBlue
    TabOrder = 3
    object TabControl1: TTabControl
      Left = 1
      Top = 1
      Width = 959
      Height = 160
      Align = alClient
      TabOrder = 0
      object Label1: TLabel
        Left = 18
        Top = 12
        Width = 37
        Height = 13
        Caption = 'GSM No'
      end
      object Label3: TLabel
        Left = 18
        Top = 56
        Width = 28
        Height = 13
        Caption = 'Mesaj'
      end
      object sbGonder: TSpeedButton
        Left = 366
        Top = 133
        Width = 100
        Height = 22
        Caption = 'G'#246'nder'
        Flat = True
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000D30E0000D30E00000001000000010000008C00000094
          0000009C000000A5000000940800009C100000AD100000AD180000AD210000B5
          210000BD210018B5290000C62900319C310000CE310029AD390031B5420018C6
          420000D6420052A54A0029AD4A0029CE5A006BB5630000FF63008CBD7B00A5C6
          94005AE7A500FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001B1B1B1B1B13
          04161B1B1B1B1B1B1B1B1B1B1B1B1B0B0A01181B1B1B1B1B1B1B1B1B1B1B160A
          0C030D1B1B1B1B1B1B1B1B1B1B1B050E0C0601191B1B1B1B1B1B1B1B1B130E0C
          170E02001B1B1B1B1B1B1B1B1B0B1517170A0C01181B1B1B1B1B1B1B1B111717
          13130C030D1B1B1B1B1B1B1B1B1B08081B1B070C01191B1B1B1B1B1B1B1B1B1B
          1B1B100C02001B1B1B1B1B1B1B1B1B1B1B1B1B090C01181B1B1B1B1B1B1B1B1B
          1B1B1B130C0F101B1B1B1B1B1B1B1B1B1B1B1B1B141A0F181B1B1B1B1B1B1B1B
          1B1B1B1B1012181B1B1B1B1B1B1B1B1B1B1B1B1B1B191B1B1B1B1B1B1B1B1B1B
          1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B}
        ParentFont = False
        OnClick = sbGonderClick
      end
      object lbKalKarakter: TLabel
        Left = 51
        Top = 108
        Width = 37
        Height = 18
        Alignment = taCenter
        AutoSize = False
        Color = clMedGray
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object Label4: TLabel
        Left = 279
        Top = 12
        Width = 55
        Height = 13
        Caption = 'Haz'#305'r Mesaj'
      end
      object sbKaydet: TSpeedButton
        Left = 91
        Top = 133
        Width = 155
        Height = 22
        Caption = 'Haz'#305'r Mesaj Olarak Kaydet'
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000220B0000220B00000001000000010000942929009431
          31009C3131009C393900A53939009C4242009C4A4A00A54A4A00B54A4A00AD52
          4A00B5524A00A5525200AD525200B5525200B55A5200AD525A00AD5A5A00B55A
          5A00BD5A5A00C65A5A00CE5A5A00CE636300CE6B6B00D66B6B00B5737300BD7B
          73009C7B7B009C848400AD848400B5848400C6848400AD8C8C00B58C8C00C694
          8C00AD949400C6949400A59C9C00B59C9C00D69C9C00BDA5A500D6A5A500D6AD
          A500CEADAD00D6ADAD00DEADAD00CEB5B500D6B5B500CEBDBD00DEBDBD00E7BD
          BD00E7C6C600C6CEC600CECEC600C6CECE00CECECE00D6CECE00E7CECE00E7D6
          CE00D6D6D600DED6D600EFD6D600DEDED600D6DEDE00DEDEDE00E7DEDE00E7E7
          E700EFEFEF00F7EFEF00F7F7EF00F7F7F700FFF7F700FFFFF700FF00FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF004848100C0722
          33343433332505050B4848191516111B27384647452D0002131048191515111A
          05184046492E0102121048191515111C03032F42493200011210481915151120
          0601243A493200011210481915151221231D1F27322C04041310481915151515
          1515151313151515160F48190D111E282B292B2828292B26150C481909384544
          4545454545454530130F48190A3C46434343434343434530130F48190A3C423A
          3A3A3A3A3A3A4230130F48190A3C423B3F3F3F3F3F3B4230130F48190A3C4440
          4040404040404230130F48190A3C423A3A3A3A3A3A3A4230130F48190A394643
          4343434343434630130F4848092D3A363636363636363A2A0748}
        OnClick = sbKaydetClick
      end
      object Label5: TLabel
        Left = 18
        Top = 36
        Width = 37
        Height = 13
        Caption = 'E-Posta'
      end
      object mMesaj: TMemo
        Left = 89
        Top = 56
        Width = 376
        Height = 72
        Color = 15263976
        TabOrder = 2
        OnChange = mMesajChange
      end
      object EditGSMNo: TEdit
        Left = 90
        Top = 8
        Width = 123
        Height = 21
        Color = 15263976
        TabOrder = 0
      end
      object cbHazirMesaj: TComboBox
        Left = 336
        Top = 8
        Width = 130
        Height = 21
        Color = 15263976
        TabOrder = 3
        TabStop = False
        OnChange = cbHazirMesajChange
        OnDblClick = cbHazirMesajDblClick
        OnDropDown = cbHazirMesajDropDown
      end
      object EditEPosta: TEdit
        Left = 90
        Top = 32
        Width = 375
        Height = 21
        Color = 15263976
        TabOrder = 1
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 308
    Width = 961
    Height = 259
    Align = alClient
    Color = 16744576
    TabOrder = 4
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 959
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'G'#246'nderilmi'#351' Mesajlar'
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object DBGrid1: TDBGrid
      Left = 1
      Top = 26
      Width = 959
      Height = 232
      TabStop = False
      Align = alClient
      Color = 16046785
      DataSource = DtsSMS
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      TitleFont.Charset = TURKISH_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ILETITURU'
          Title.Caption = #304'leti'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 41
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'TARIH'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'Tarih'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 62
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'GONDERIMTARIHI'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'G'#246'nderim Tarihi'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 79
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MODUL'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'Mod'#252'l'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 31
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MESAJ'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'Mesaj'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 165
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SONUC'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'Sonu'#231
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 54
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'GONDEREN'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Caption = 'G'#246'nderen'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clMaroon
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 21
          Visible = True
        end>
    end
  end
  object TabSMS: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'PKAYITNO'
        Attributes = [paNullable]
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 30
        Value = Null
      end>
    SQL.Strings = (
      'SELECT *  FROM SMSPOSTA'
      'WHERE KAYITNO=:PKAYITNO'
      'ORDER BY TARIH DESC ')
    Left = 136
    Top = 372
  end
  object DtsSMS: TDataSource
    DataSet = TabSMS
    Left = 168
    Top = 372
  end
  object InMailGonderme: TIdSMTP
    SASLMechanisms = <>
    Left = 16
    Top = 232
  end
  object IdEpostaMesaj: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 8
    Top = 272
  end
end
