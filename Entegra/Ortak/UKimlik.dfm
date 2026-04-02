object KimlikDlg: TKimlikDlg
  Left = 289
  Top = 111
  Width = 671
  Height = 459
  BorderIcons = [biSystemMenu]
  Caption = 'Kimlik Bilgileri'
  Color = 15124652
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 337
    Width = 663
    Height = 88
    Align = alBottom
    Color = 11976845
    TabOrder = 0
    object LabelKURUM: TLabel
      Left = 222
      Top = 30
      Width = 43
      Height = 13
      Alignment = taRightJustify
      Caption = '&Kurumu'
      FocusControl = ComboKURUM
    end
    object LabelREFERANS: TLabel
      Left = 212
      Top = 54
      Width = 55
      Height = 13
      Caption = '&Referansý'
      FocusControl = ComboREFERANS
    end
    object LabelGIRISTARIH: TLabel
      Left = 432
      Top = 32
      Width = 26
      Height = 13
      Caption = '&Giriþ'
      FocusControl = EditGIRISTARIH
    end
    object LabelCIKISTARIH: TLabel
      Left = 431
      Top = 55
      Width = 28
      Height = 13
      Caption = '&Çýkýþ'
      FocusControl = EditCIKISTARIH
    end
    object LabelPOLIKLINIK: TLabel
      Left = 7
      Top = 31
      Width = 52
      Height = 13
      Caption = '&Poliklinik'
      FocusControl = ComboPOLIKLINIK
    end
    object LabelDOKTOR: TLabel
      Left = 21
      Top = 55
      Width = 39
      Height = 13
      Caption = '&Doktor'
      FocusControl = ComboDOKTOR
    end
    object TextGelisNo: TDBText
      Left = 9
      Top = 4
      Width = 26
      Height = 20
      DataField = 'GELISNO'
      DataSource = DtsGelisler
      Font.Charset = TURKISH_CHARSET
      Font.Color = clRed
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelTEDAVI: TLabel
      Left = 545
      Top = 31
      Width = 40
      Height = 13
      Caption = 'Teda&vi'
      FocusControl = ComboTEDAVI
    end
    object LabelKatilimYuzde: TLabel
      Left = 551
      Top = 55
      Width = 33
      Height = 13
      Caption = 'Kat.%'
      FocusControl = EditKatilimYuzde
      WordWrap = True
    end
    object DoktorSecTus: TSpeedButton
      Left = 189
      Top = 52
      Width = 19
      Height = 21
      Caption = '...'
      OnClick = DoktorSecTusClick
    end
    object LabelYATGUNSAY: TDBText
      Left = 533
      Top = 55
      Width = 12
      Height = 17
      DataField = 'YATGUNSAY'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object RehberAraTus: TSpeedButton
      Left = 405
      Top = 51
      Width = 22
      Height = 22
      Flat = True
      Glyph.Data = {
        4E010000424D4E01000000000000760000002800000012000000120000000100
        040000000000D800000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        0007770000007777777000080077770000007777770877808777770000007700
        00877E88000007000000770FF07777870FFF07000000770F007E778700000700
        0000770F008EE7880F0E07000000770F0F087780FF0007000000770F0FF0000F
        FF0B07000000770F0FFF00F00F0007000000770F0F00F00FFF0F07000000770F
        0FFF00F00F0007000000770F0F00F0FFFF0A0700000077000FFF070FFF000700
        0000777700007770000777000000777777777777777777000000777777777777
        77777700000077777777777777770F000000}
    end
    object LabelDOKTORKOD: TDBText
      Left = 63
      Top = 73
      Width = 35
      Height = 17
      DataField = 'DOKTORKOD'
      DataSource = DtsGelisler
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object DBText2: TDBText
      Left = 271
      Top = 71
      Width = 35
      Height = 17
      DataField = 'REFERANSKOD'
      DataSource = DtsGelisler
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ComboKURUM: TDBComboBox
      Left = 269
      Top = 26
      Width = 158
      Height = 21
      DataField = 'KURUM'
      DataSource = DtsGelisler
      ItemHeight = 13
      TabOrder = 2
      OnClick = ComboKURUMClick
      OnEnter = ComboKURUMEnter
    end
    object ComboREFERANS: TDBComboBox
      Left = 269
      Top = 50
      Width = 135
      Height = 21
      DataField = 'REFERANS'
      DataSource = DtsGelisler
      ItemHeight = 13
      TabOrder = 3
      OnEnter = ComboKURUMEnter
    end
    object EditGIRISTARIH: TDBEdit
      Left = 461
      Top = 27
      Width = 70
      Height = 21
      DataField = 'GIRISTARIH'
      DataSource = DtsGelisler
      TabOrder = 4
      OnEnter = ComboKURUMEnter
    end
    object EditCIKISTARIH: TDBEdit
      Left = 461
      Top = 51
      Width = 70
      Height = 21
      DataField = 'CIKISTARIH'
      DataSource = DtsGelisler
      TabOrder = 5
      OnEnter = ComboKURUMEnter
    end
    object ComboPOLIKLINIK: TDBComboBox
      Left = 61
      Top = 27
      Width = 145
      Height = 21
      DataField = 'POLIKLINIK'
      DataSource = DtsGelisler
      ItemHeight = 13
      TabOrder = 0
      OnEnter = ComboKURUMEnter
      OnExit = ComboPOLIKLINIKExit
    end
    object ComboDOKTOR: TDBEdit
      Left = 60
      Top = 51
      Width = 127
      Height = 21
      DataField = 'DOKTOR'
      DataSource = DtsGelisler
      TabOrder = 1
      OnEnter = ComboKURUMEnter
    end
    object ComboTEDAVI: TDBComboBox
      Left = 585
      Top = 27
      Width = 74
      Height = 21
      DataField = 'TEDAVI'
      DataSource = DtsGelisler
      ItemHeight = 13
      TabOrder = 6
      OnEnter = ComboKURUMEnter
    end
    object EditKatilimYuzde: TDBEdit
      Left = 585
      Top = 51
      Width = 28
      Height = 21
      DataField = 'KATKIYUZDE'
      DataSource = DtsGelisler
      ParentColor = True
      TabOrder = 7
      OnEnter = ComboKURUMEnter
    end
    object EditPROTOKOLNO: TDBEdit
      Left = 60
      Top = 3
      Width = 64
      Height = 21
      TabStop = False
      DataSource = DtsGelisler
      ParentColor = True
      TabOrder = 8
      OnEnter = ComboKURUMEnter
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 663
    Height = 337
    Align = alClient
    TabOrder = 1
    object EvAdresiCercevesi: TBevel
      Left = 378
      Top = 57
      Width = 237
      Height = 203
    end
    object AdSoyadCercevesi: TBevel
      Left = 11
      Top = 57
      Width = 293
      Height = 203
    end
    object LabelAD: TLabel
      Left = 94
      Top = 74
      Width = 19
      Height = 13
      Alignment = taRightJustify
      Caption = 'Adý'
      FocusControl = EditAD
    end
    object LabelSOYAD: TLabel
      Left = 74
      Top = 98
      Width = 39
      Height = 13
      Alignment = taRightJustify
      Caption = 'Soyadý'
      FocusControl = EditSOYAD
    end
    object LabelDOGUMYER: TLabel
      Left = 47
      Top = 130
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'Doðum Yeri'
      FocusControl = EditDOGUMYER
    end
    object LabelDOGUMTARIH: TLabel
      Left = 37
      Top = 157
      Width = 76
      Height = 13
      Alignment = taRightJustify
      Caption = 'Doðum Tarihi'
      FocusControl = EditDOGUMTARIH
    end
    object LabelMESLEK: TLabel
      Left = 69
      Top = 181
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'Mesleði'
      FocusControl = ComboMESLEK
    end
    object LabelCINSIYET: TLabel
      Left = 24
      Top = 208
      Width = 90
      Height = 15
      AutoSize = False
      Caption = '&Cinsiyeti'
      FocusControl = ComboCINSIYET
    end
    object LabelKANGRUP: TLabel
      Left = 52
      Top = 234
      Width = 61
      Height = 13
      Alignment = taRightJustify
      Caption = 'Kan Grubu'
      FocusControl = ComboKANGRUP
    end
    object LabelEVADRES: TLabel
      Left = 398
      Top = 60
      Width = 33
      Height = 13
      Alignment = taRightJustify
      Caption = 'Adres'
      FocusControl = MemoEVADRES
    end
    object LabelYAS: TLabel
      Left = 208
      Top = 156
      Width = 26
      Height = 13
      Caption = 'Yaþ:'
    end
    object EditYAS: TLabel
      Left = 236
      Top = 156
      Width = 21
      Height = 16
      Caption = 'yyy'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelTelefonlar: TLabel
      Left = 398
      Top = 173
      Width = 58
      Height = 13
      Alignment = taRightJustify
      Caption = 'Telefonlar'
      FocusControl = EditEVTEL
    end
    object LabelMEDENIHAL: TLabel
      Left = 66
      Top = 208
      Width = 47
      Height = 13
      Alignment = taRightJustify
      Caption = '/ M.Hali'
      FocusControl = ComboMEDENIHAL
    end
    object LabelISTEL: TLabel
      Left = 402
      Top = 214
      Width = 11
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ýþ'
      FocusControl = EditISTEL
    end
    object LabelEVTEL: TLabel
      Left = 398
      Top = 191
      Width = 16
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ev'
      FocusControl = EditEVTEL
    end
    object LabelEVIL: TLabel
      Left = 508
      Top = 130
      Width = 8
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ýl'
    end
    object LabelEVILCE: TLabel
      Left = 393
      Top = 129
      Width = 22
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ýlçe'
    end
    object LabelEPOSTA: TLabel
      Left = 380
      Top = 154
      Width = 36
      Height = 13
      Caption = 'E-Mail'
      FocusControl = EditEPOSTA
    end
    object LabelCEPTEL: TLabel
      Left = 390
      Top = 237
      Width = 23
      Height = 13
      Alignment = taRightJustify
      Caption = 'Cep'
      FocusControl = EditCEPTEL
    end
    object LabelDOSYANO: TLabel
      Left = 36
      Top = 23
      Width = 56
      Height = 13
      Alignment = taRightJustify
      Caption = 'Dosya No'
      FocusControl = EditDOSYANO
    end
    object EditAD: TDBEdit
      Left = 121
      Top = 68
      Width = 170
      Height = 24
      Color = 10361616
      DataField = 'AD'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object EditSOYAD: TDBEdit
      Left = 121
      Top = 94
      Width = 170
      Height = 24
      Color = 10361616
      DataField = 'SOYAD'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnExit = EditSOYADExit
    end
    object EditDOGUMYER: TDBEdit
      Left = 121
      Top = 126
      Width = 170
      Height = 24
      DataField = 'DOGUMYER'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
    end
    object EditDOGUMTARIH: TDBEdit
      Left = 121
      Top = 152
      Width = 85
      Height = 24
      DataField = 'DOGUMTARIH'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnExit = EditDOGUMTARIHExit
    end
    object EditEVILCE: TDBEdit
      Left = 416
      Top = 125
      Width = 90
      Height = 24
      DataField = 'ILCE'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
    end
    object ComboEVIL: TDBComboBox
      Left = 517
      Top = 125
      Width = 92
      Height = 24
      DataField = 'IL'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 10
    end
    object ComboCINSIYET: TDBComboBox
      Left = 121
      Top = 204
      Width = 85
      Height = 24
      Style = csDropDownList
      DataField = 'CINSIYET'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 5
    end
    object ComboMEDENIHAL: TDBComboBox
      Left = 206
      Top = 204
      Width = 85
      Height = 24
      Style = csDropDownList
      DataField = 'MEDENIHAL'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 6
    end
    object ComboKANGRUP: TDBComboBox
      Left = 121
      Top = 230
      Width = 85
      Height = 24
      Style = csDropDownList
      DataField = 'KANGRUP'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 7
    end
    object ComboMESLEK: TDBComboBox
      Left = 121
      Top = 178
      Width = 170
      Height = 24
      DataField = 'MESLEK'
      DataSource = DtsKimlik
      DropDownCount = 20
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 4
    end
    object MemoEVADRES: TDBMemo
      Left = 416
      Top = 76
      Width = 193
      Height = 48
      DataField = 'ADRES'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
    end
    object EditEVTEL: TDBEdit
      Left = 416
      Top = 187
      Width = 193
      Height = 24
      DataField = 'EVTEL'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 12
    end
    object EditISTEL: TDBEdit
      Left = 416
      Top = 210
      Width = 193
      Height = 24
      DataField = 'ISTEL'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 13
    end
    object EditEPOSTA: TDBEdit
      Left = 416
      Top = 150
      Width = 193
      Height = 21
      DataField = 'EPOSTA'
      DataSource = DtsKimlik
      TabOrder = 11
    end
    object EditCEPTEL: TDBEdit
      Left = 416
      Top = 233
      Width = 193
      Height = 24
      DataField = 'CEPTEL'
      DataSource = DtsKimlik
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 14
    end
    object EditDOSYANO: TDBEdit
      Left = 97
      Top = 20
      Width = 96
      Height = 24
      Color = 10361616
      DataField = 'DOSYANO'
      DataSource = DtsKimlik
      Enabled = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 15
    end
    object GroupNOTLAR: TGroupBox
      Left = 9
      Top = 260
      Width = 608
      Height = 70
      Caption = 'NOTLAR'
      TabOrder = 16
      object LabelNOTLAR: TLabel
        Left = 12
        Top = -15
        Width = 59
        Height = 13
        Alignment = taRightJustify
        Caption = ' NOTLAR '
      end
      object MemoNOTLAR: TDBMemo
        Left = 6
        Top = 14
        Width = 595
        Height = 53
        DataField = 'NOTLAR'
        DataSource = DtsKimlik
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Pitch = fpVariable
        Font.Style = [fsBold]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object KapatTus: TBitBtn
      Left = 545
      Top = 17
      Width = 70
      Height = 27
      Caption = 'Kapat'
      TabOrder = 17
      TabStop = False
      Kind = bkCancel
    end
    object ToolBarNavigator: TDBNavigator
      Left = 446
      Top = 17
      Width = 93
      Height = 27
      DataSource = DtsKimlik
      VisibleButtons = [nbInsert]
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
      TabOrder = 18
    end
  end
  object DtsKimlik: TDataSource
    DataSet = TabKimlik
    OnStateChange = DtsKimlikStateChange
    Left = 256
    Top = 16
  end
  object DtsGelisler: TDataSource
    DataSet = TabGelisler
    OnStateChange = DtsGelislerStateChange
    Left = 240
    Top = 318
  end
  object TabKimlik: TADOQuery
    AutoCalcFields = False
    Connection = Tablo.cnn
    AfterOpen = TabKimlikAfterOpen
    BeforeEdit = TabKimlikBeforeEdit
    BeforePost = TabKimlikBeforePost
    AfterPost = TabKimlikAfterPost
    AfterCancel = TabKimlikAfterCancel
    AfterScroll = TabKimlikAfterScroll
    OnNewRecord = TabKimlikNewRecord
    Parameters = <
      item
        Name = 'Param1'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 15
      end>
    SQL.Strings = (
      'Select * from KIMLIK'
      'Where DOSYANO = :PDosyaNo')
    Left = 217
    Top = 20
  end
  object TabGelisler: TADOQuery
    Connection = Tablo.cnn
    BeforeEdit = TabGelislerBeforeEdit
    BeforePost = TabGelislerBeforePost
    AfterPost = TabGelislerAfterPost
    Parameters = <
      item
        Name = 'Param1'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 15
      end
      item
        Name = 'Param2'
        Attributes = [paSigned]
        DataType = ftSmallint
        Precision = 5
        Size = 2
      end>
    SQL.Strings = (
      'Select * from GELISLER'
      'Where DOSYANO = :PDosyaNo'
      'and GELISNO=:PGelisNo')
    Left = 200
    Top = 320
  end
end
