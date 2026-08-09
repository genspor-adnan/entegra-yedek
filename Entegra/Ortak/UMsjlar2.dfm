object MesajDlg: TMesajDlg
  Left = 300
  Top = 166
  Width = 465
  Height = 272
  BorderIcons = [biSystemMenu]
  Caption = 'Mesaj Ekraný'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 457
    Height = 41
    Align = alTop
    TabOrder = 0
    object DBCheckBox1: TDBCheckBox
      Left = 291
      Top = 14
      Width = 76
      Height = 17
      Caption = 'Okudum'
      DataField = 'OKUNDU'
      DataSource = DtsMesajlar
      TabOrder = 0
      ValueChecked = 'True'
      ValueUnchecked = 'False'
      OnMouseUp = DBCheckBox1MouseUp
    end
    object DBNavigator1: TDBNavigator
      Left = 10
      Top = 8
      Width = 180
      Height = 25
      DataSource = DtsMesajlar
      VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete]
      Flat = True
      Ctl3D = False
      Hints.Strings = (
        'Ýlk F5'
        'Önceki F6'
        'Sonraki F7'
        'Son F8'
        'Yeni F9'
        'Sil F10'
        'Deðiþtir'
        'Kaydet F11'
        'Ýptal F12')
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = DBNavigator1Click
    end
    object BitBtn2: TBitBtn
      Left = 374
      Top = 10
      Width = 69
      Height = 24
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Kind = bkCancel
    end
  end
  object PageControl1: TPageControl
    Images = Tablo.PNGImageList2
    Left = 0
    Top = 41
    Width = 33
    Height = 204
    ActivePage = TabSheetGelen
    Align = alLeft
    MultiLine = True
    TabOrder = 1
    TabPosition = tpLeft
    OnChange = PageControl1Change
    object TabSheetGelen: TTabSheet
      Caption = 'Gelen'
      ImageIndex = 19
    end
    object TabSheetGiden: TTabSheet
      Caption = 'Giden'
      ImageIndex = 19
    end
  end
  object Panel2: TPanel
    Left = 33
    Top = 41
    Width = 424
    Height = 204
    Align = alClient
    TabOrder = 2
    object Label3: TLabel
      Left = 14
      Top = 92
      Width = 43
      Height = 16
      Caption = '&Mesaj'
      FocusControl = DBMemo1
    end
    object Label2: TLabel
      Left = 22
      Top = 57
      Width = 35
      Height = 16
      Alignment = taRightJustify
      Caption = '&Kime'
      FocusControl = ComboKime
    end
    object DBText1: TDBText
      Left = 13
      Top = 16
      Width = 65
      Height = 17
      DataField = 'KIMIN'
      DataSource = DtsMesajlar
    end
    object DBText2: TDBText
      Left = 261
      Top = 17
      Width = 145
      Height = 17
      DataField = 'TARIH'
      DataSource = DtsMesajlar
    end
    object DBMemo1: TDBMemo
      Left = 61
      Top = 78
      Width = 353
      Height = 113
      DataField = 'MESAJ'
      DataSource = DtsMesajlar
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object ComboKime: TDBComboBox
      Left = 61
      Top = 52
      Width = 233
      Height = 24
      DataField = 'KIMDENKIME'
      DataSource = DtsMesajlar
      ItemHeight = 16
      TabOrder = 1
      OnDropDown = ComboKimeDropDown
    end
  end
  object DtsMesajlar: TDataSource
    DataSet = TabMesajlar
    OnStateChange = DtsMesajlarStateChange
    Left = 231
    Top = 124
  end
  object LD: TQuery
    DatabaseName = 'GENOTIP'
    SQL.Strings = (
      
        'INSERT INTO MESAJLAR (KIMIN, TARIH, KIMDENKIME, GIREN_CIKAN, OKU' +
        'NDU, MESAJ) '
      
        'VALUES (:KIMIN, :TARIH, :KIMDENKIME, :GIREN_CIKAN, :OKUNDU, :MES' +
        'AJ) ')
    Left = 196
    Top = 176
    ParamData = <
      item
        DataType = ftString
        Name = 'KIMIN'
        ParamType = ptInput
      end
      item
        DataType = ftDateTime
        Name = 'TARIH'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'KIMDENKIME'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'GIREN_CIKAN'
        ParamType = ptInput
      end
      item
        DataType = ftBoolean
        Name = 'OKUNDU'
        ParamType = ptUnknown
      end
      item
        DataType = ftMemo
        Name = 'MESAJ'
        ParamType = ptInput
      end>
  end
  object TabMesajlar: TQuery
    AutoCalcFields = False
    AfterInsert = TabMesajlarAfterInsert
    BeforeEdit = TabMesajlarBeforeEdit
    AfterPost = TabMesajlarAfterPost
    OnNewRecord = TabMesajlarNewRecord
    DatabaseName = 'GENOTIP'
    SessionName = 'Default'
    RequestLive = True
    Left = 201
    Top = 124
  end
end
