object KalibrasyonDlg: TKalibrasyonDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kalibrasyon Bilgileri'
  ClientHeight = 229
  ClientWidth = 647
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar4: TToolBar
    Left = 0
    Top = 0
    Width = 647
    Height = 24
    Margins.Bottom = 0
    ButtonWidth = 62
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object KalKaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = KalKaydetTusClick
    end
    object KalIptalTus: TToolButton
      Left = 62
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = KalIptalTusClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 24
    Width = 647
    Height = 205
    Align = alClient
    BevelOuter = bvNone
    Color = 11776947
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    object SpeedButton1: TSpeedButton
      Left = 1050
      Top = 7
      Width = 64
      Height = 23
      Caption = 'Kapat'
      Flat = True
      Glyph.Data = {
        66010000424D6601000000000000760000002800000013000000140000000100
        040000000000F000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777600007777777777777777777000007777777777777777777000007777
        777777777777777000007777777777777770F77C0000777770F7777777777776
        00007777000F7777770F777000007777000F777770F77770000077777000F777
        00F7777E0000777777000F700F7777700000777777700000F777777F00007777
        7777000F777777760000777777700000F77777700000777777000F70F7777770
        000077770000F77700F7777000007770000F7777700F7770000077700F777777
        7700F77400007777777777777777777600007777777777777777777000007777
        77777777777777700000}
    end
    object cxLabel22: TcxLabel
      Left = 2
      Top = 18
      Caption = 'Tarih'
    end
    object DateKalibTarih: TcxDBDateEdit
      Left = 97
      Top = 17
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = dtsKalibrasyon
      Properties.DateButtons = [btnClear, btnNow, btnToday]
      TabOrder = 0
      Width = 123
    end
    object cxLabel23: TcxLabel
      Left = 2
      Top = 43
      Caption = 'Ge'#231'erlilik Tarihi'
    end
    object DateKalibGecerlilikTarihi: TcxDBDateEdit
      Left = 97
      Top = 42
      DataBinding.DataField = 'GECERLILIKTARIHI'
      DataBinding.DataSource = dtsKalibrasyon
      Properties.DateButtons = [btnClear, btnNow, btnToday]
      TabOrder = 1
      Width = 123
    end
    object cxLabel13: TcxLabel
      Left = 2
      Top = 68
      Caption = 'Sertifika'
    end
    object SertifikaKalibrasyon: TcxDBTextEdit
      Left = 97
      Top = 67
      DataBinding.DataField = 'SERTIFIKA'
      DataBinding.DataSource = dtsKalibrasyon
      Properties.Alignment.Horz = taLeftJustify
      Properties.ReadOnly = False
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBtnText
      TabOrder = 2
      Width = 123
    end
    object cxLabel14: TcxLabel
      Left = 312
      Top = 20
      Hint = 'Demirbas_Teslim '#350'ekli'
      Caption = 'Firma'
    end
    object BEFirmaKalibrasyon: TcxButtonEdit
      Left = 422
      Top = 18
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Hint = 'Temizle'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = BEFirmaKalibrasyonPropertiesButtonClick
      ShowHint = True
      TabOrder = 3
      Width = 211
    end
    object cxLabel15: TcxLabel
      Left = 312
      Top = 46
      Hint = 'Demirbas_Teslim '#350'ekli'
      Caption = 'Firma Yetkili'
    end
    object BEFirmaYetkiliKalibrasyon: TcxButtonEdit
      Left = 422
      Top = 43
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Hint = 'Temizle'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = BEFirmaYetkiliKalibrasyonPropertiesButtonClick
      ShowHint = True
      TabOrder = 4
      TextHint = 'FIRMAPERSONELI'
      Width = 211
    end
    object NotlarKalibrasyon: TcxDBMemo
      Tag = 20
      Left = 97
      Top = 108
      DataBinding.DataField = 'NOTLAR'
      DataBinding.DataSource = dtsKalibrasyon
      TabOrder = 7
      Height = 67
      Width = 474
    end
    object cxLabel16: TcxLabel
      Tag = 21
      Left = 2
      Top = 109
      Caption = 'Notlar'
      ParentColor = False
      Style.Color = cl3DLight
      Transparent = True
    end
    object cxLabel17: TcxLabel
      Left = 312
      Top = 73
      Caption = 'Maliyet'
    end
    object MaliyetKalibrasyon: TcxDBCurrencyEdit
      Left = 423
      Top = 68
      DataBinding.DataField = 'MALIYET'
      DataBinding.DataSource = dtsKalibrasyon
      Properties.Alignment.Horz = taRightJustify
      Properties.DisplayFormat = ',0.00;'
      Properties.EditFormat = ',0.00;'
      StyleDisabled.BorderColor = clBtnShadow
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBtnText
      TabOrder = 5
      Width = 97
    end
    object ComboKurlarKalibrasyon: TcxDBComboBox
      Left = 520
      Top = 68
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = dtsKalibrasyon
      Properties.ImmediatePost = True
      TabOrder = 6
      Width = 51
    end
    object cxDBLabel2: TcxDBLabel
      Left = 222
      Top = 19
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = dtsKalibrasyon
      Transparent = True
      Height = 21
      Width = 18
    end
  end
  object dtsKalibrasyon: TDataSource
    DataSet = TabKalibrasyon
    OnStateChange = dtsKalibrasyonStateChange
    Left = 597
    Top = 107
  end
  object TabKalibrasyon: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabKalibrasyonNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from KALIBRASYON Where ID=:PID')
    Left = 271
    Top = 83
  end
end

