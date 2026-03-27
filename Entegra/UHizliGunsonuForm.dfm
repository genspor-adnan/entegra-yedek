object HizliGunsonuForm: THizliGunsonuForm
  Left = 0
  Top = 0
  Caption = 'HizliGunsonuForm'
  ClientHeight = 402
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TcxLabel
    Left = 31
    Top = 84
    Caption = 'Devir'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 745
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
      Left = 621
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
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 120
    end
    object cxLabel1: TcxLabel
      Left = 3
      Top = 6
      Caption = 'G'#252'n Sonu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -19
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
  end
  object cxLabel2: TcxLabel
    Left = 31
    Top = 132
    Caption = 'Gelen'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel4: TcxDBLabel
    Left = 287
    Top = 135
    DataBinding.DataField = 'GELEN'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel3: TcxLabel
    Left = 31
    Top = 180
    Caption = #220'retim'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel5: TcxDBLabel
    Left = 96
    Top = 183
    DataBinding.DataField = 'URETIM_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit3: TcxDBTextEdit
    Left = 176
    Top = 179
    DataBinding.DataField = 'URETIM_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 6
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel6: TcxDBLabel
    Left = 287
    Top = 183
    DataBinding.DataField = 'URETIM'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel4: TcxLabel
    Left = 31
    Top = 228
    Caption = #304'ade'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel7: TcxDBLabel
    Left = 96
    Top = 231
    DataBinding.DataField = 'IADE_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit4: TcxDBTextEdit
    Left = 176
    Top = 227
    DataBinding.DataField = 'IADE_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 10
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel8: TcxDBLabel
    Left = 287
    Top = 231
    DataBinding.DataField = 'IADE'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel5: TcxLabel
    Left = 407
    Top = 86
    Caption = 'Sat'#305#351
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel9: TcxDBLabel
    Left = 472
    Top = 89
    DataBinding.DataField = 'SATIS_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit5: TcxDBTextEdit
    Left = 552
    Top = 85
    DataBinding.DataField = 'SATIS_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 14
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel10: TcxDBLabel
    Left = 663
    Top = 89
    DataBinding.DataField = 'SATIS'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel6: TcxLabel
    Left = 407
    Top = 134
    Caption = 'Giden'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel11: TcxDBLabel
    Left = 472
    Top = 137
    DataBinding.DataField = 'GIDEN_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit6: TcxDBTextEdit
    Left = 552
    Top = 133
    DataBinding.DataField = 'GIDEN_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 18
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel12: TcxDBLabel
    Left = 663
    Top = 137
    DataBinding.DataField = 'GIDEN'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel7: TcxLabel
    Left = 407
    Top = 182
    Caption = 'Sarf'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel13: TcxDBLabel
    Left = 472
    Top = 185
    DataBinding.DataField = 'SARF_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit7: TcxDBTextEdit
    Left = 552
    Top = 181
    DataBinding.DataField = 'SARF_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 22
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel14: TcxDBLabel
    Left = 663
    Top = 185
    DataBinding.DataField = 'SARF'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel8: TcxLabel
    Left = 407
    Top = 230
    Caption = 'Kay'#305'p'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel15: TcxDBLabel
    Left = 472
    Top = 233
    DataBinding.DataField = 'KAYIP_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit8: TcxDBTextEdit
    Left = 552
    Top = 229
    DataBinding.DataField = 'KAYIP_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 26
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel16: TcxDBLabel
    Left = 663
    Top = 228
    DataBinding.DataField = 'KAYIP'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel9: TcxLabel
    Left = 407
    Top = 278
    Caption = 'Bozuk'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBLabel17: TcxDBLabel
    Left = 472
    Top = 281
    DataBinding.DataField = 'BOZUK_1'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxDBTextEdit9: TcxDBTextEdit
    Left = 552
    Top = 277
    DataBinding.DataField = 'BOZUK_2'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 30
    OnKeyUp = cxDBTextEdit2KeyUp
    Width = 89
  end
  object cxDBLabel18: TcxDBLabel
    Left = 663
    Top = 281
    DataBinding.DataField = 'BOZUK'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object cxLabel10: TcxLabel
    Left = 31
    Top = 275
    Caption = 'Toplam'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel11: TcxLabel
    Left = 407
    Top = 325
    Caption = 'Toplam'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel13: TcxLabel
    Left = 96
    Top = 52
    Caption = 'G'#252'n '#304#231'i'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel14: TcxLabel
    Left = 184
    Top = 52
    Caption = 'G'#252'n Sonu'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel15: TcxLabel
    Left = 287
    Top = 52
    Caption = 'Toplam'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel16: TcxLabel
    Left = 470
    Top = 52
    Caption = 'G'#252'n '#304#231'i'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel17: TcxLabel
    Left = 558
    Top = 52
    Caption = 'G'#252'n Sonu'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel18: TcxLabel
    Left = 661
    Top = 52
    Caption = 'Toplam'
    ParentColor = False
    ParentFont = False
    Style.Color = clBlue
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object JvNavPanelHeader1: TJvNavPanelHeader
    Left = 0
    Top = 365
    Width = 745
    Height = 37
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clSilver
    ColorTo = clSilver
    ImageIndex = 0
    object JvNavPanelButton1: TJvNavPanelButton
      Left = 621
      Top = 0
      Width = 124
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Onayla'
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
      ImageIndex = -1
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = 120
    end
    object cxLabel12: TcxLabel
      Left = 412
      Top = 5
      Caption = 'Kalan'
      ParentColor = False
      ParentFont = False
      Style.Color = clBlue
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clTeal
      Style.Font.Height = -21
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = 427007
      Style.TransparentBorder = False
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel21: TcxDBLabel
      Left = 484
      Top = 3
      DataBinding.DataField = 'KALAN'
      DataBinding.DataSource = DtsGunSonuStokDetay
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlue
      Style.Font.Height = -21
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Transparent = True
      Height = 33
      Width = 65
    end
    object cxLabel19: TcxLabel
      Left = 31
      Top = 5
      Caption = 'Say'#305'lan'
      ParentColor = False
      ParentFont = False
      Style.Color = clBlue
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clGreen
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBTextEdit1: TcxDBTextEdit
      Left = 176
      Top = 6
      DataBinding.DataField = 'SAYILAN'
      DataBinding.DataSource = DtsGunSonuStokDetay
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 3
      Width = 89
    end
  end
  object cxDBLabel2: TcxDBLabel
    Left = 287
    Top = 87
    DataBinding.DataField = 'DEVIR'
    DataBinding.DataSource = DtsGunSonuStokDetay
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Height = 21
    Width = 65
  end
  object LabelGirenToplam: TcxLabel
    Left = 287
    Top = 281
    Caption = '--'
  end
  object LabelCikanToplam: TcxLabel
    Left = 663
    Top = 325
    Caption = '--'
  end
  object DtsGunSonuStokDetay: TDataSource
    DataSet = TabGunSonuStokDetay
    Left = 177
    Top = 310
  end
  object TabGunSonuStokDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'SELECT'
      'SGS.*,'
      
        'KATEGORIADI= (SELECT K.AD FROM KATEGORI K INNER JOIN STOKLAR S O' +
        'N S.ID=SGS.STOKID WHERE S.KATEGORI =K.ID),'
      'STOKADI=(SELECT STOKADI FROM STOKLAR S WHERE SGS.STOKID=S.ID),'
      
        'BARKOD=(SELECT BARKOD FROM STOKBARKOD SB WHERE SGS.STOKID=SB.STO' +
        'KID AND SB.VARSAYILAN=1),'
      
        'BIRIM=(SELECT G.ANAHTAR FROM GENINI G INNER JOIN STOKLAR S ON S.' +
        'ID=SGS.STOKID WHERE S.ANABIRIM=G.DEGER AND G.BOLUM=-2702 AND G.D' +
        'IL=-1)'
      ''
      'FROM STOKGUNSONU SGS'
      '--WHERE '
      '--TARIH=:PRM1 '
      '--AND DEPOID=:PRM2'
      ''
      '')
    Left = 184
    Top = 78
  end
end


