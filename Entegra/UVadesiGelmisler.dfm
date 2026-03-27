object VadesiGelmislerDlg: TVadesiGelmislerDlg
  Left = 233
  Top = 53
  Caption = 'Vadesi Gelmi'#351' '#304#351'lemler'
  ClientHeight = 545
  ClientWidth = 923
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 923
    Height = 42
    Align = alTop
    Caption = 'Vadesi Gelmi'#351' '#304#351'lemler'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 1
      Width = 53
      Height = 13
      Caption = 'Ba'#351'lang'#305#231
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 122
      Top = 1
      Width = 24
      Height = 13
      Caption = 'Biti'#351
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object GrupIslemTuru: TRadioGroup
      Left = 560
      Top = 1
      Width = 185
      Height = 34
      Columns = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ItemIndex = 0
      Items.Strings = (
        'T'#252'm'#252
        'Bor'#231
        'Alacak')
      ParentFont = False
      TabOrder = 0
      OnClick = GrupIslemTuruClick
    end
    object DateTimeBasla: TDateTimePicker
      Left = 8
      Top = 16
      Width = 97
      Height = 21
      Date = 38975.663042152780000000
      Time = 38975.663042152780000000
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnChange = GrupIslemTuruClick
    end
    object DateTimeBitis: TDateTimePicker
      Left = 121
      Top = 16
      Width = 97
      Height = 21
      Date = 38975.663042152780000000
      Time = 38975.663042152780000000
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnChange = GrupIslemTuruClick
    end
    object ToolBar1: TToolBar
      Left = 752
      Top = -1
      Width = 172
      Height = 40
      Align = alNone
      ButtonHeight = 36
      ButtonWidth = 53
      Caption = 'ToolBar1'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Images = Tablo.ImageList1
      ParentFont = False
      ShowCaptions = True
      TabOrder = 3
      object EkranYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'VadeListe'
        ImageIndex = 2
        OnClick = YaziciYazClick
      end
      object YaziciYaz: TToolButton
        Left = 53
        Top = 0
        Caption = 'VadeListe'
        ImageIndex = 1
        OnClick = YaziciYazClick
      end
      object ToolButton2: TToolButton
        Left = 106
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 114
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 3
        OnClick = ToolButton1Click
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 414
    Width = 923
    Height = 131
    Align = alBottom
    TabOrder = 1
    object DBGrid2: TDBGrid
      Left = 3
      Top = 4
      Width = 374
      Height = 122
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = TURKISH_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'GIREN'
          Title.Caption = 'Giren/Bor'#231
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 111
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'KUR'
          Title.Caption = 'Kur'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 35
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CIKAN'
          Title.Caption = #199#305'kan/Alacak'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 133
          Visible = True
        end>
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 42
    Width = 923
    Height = 372
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 2
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 921
      Height = 370
      Align = alClient
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = TURKISH_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'CARIKOD'
          Title.Caption = 'Cari Kod'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 74
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CARIAD'
          Title.Caption = 'Cari Ad'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 187
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ACIKLAMA'
          Title.Caption = 'A'#231#305'klama'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 101
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'GIREN'
          Title.Caption = 'Giren/Bor'#231
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 81
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CIKAN'
          Title.Caption = #199#305'kan/Alacak'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 73
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'KUR'
          Title.Caption = 'Kur'
          Width = 53
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'HESAPKODU'
          Title.Caption = 'Hesap Kodu'
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 76
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'HESAPADI'
          Title.Caption = 'Hesap Ad'#305
          Title.Font.Charset = TURKISH_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = []
          Width = 214
          Visible = True
        end>
    end
  end
end
