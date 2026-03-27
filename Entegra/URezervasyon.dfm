object RezervasyonDlg: TRezervasyonDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'RezervasyonDlg'
  ClientHeight = 393
  ClientWidth = 642
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
  object IptalTus: TJvNavPanelButton
    Tag = 3
    Left = 340
    Top = 319
    Height = 49
    Alignment = taCenter
    Caption = #304'ptal Edildi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -12
    HotTrackFont.Name = 'Segoe UI'
    HotTrackFont.Style = [fsBold]
    ParentFont = False
    ImageIndex = 0
    OnClick = KaydetTusClick
  end
  object KaydetTus: TJvNavPanelButton
    Tag = 2
    Left = 494
    Top = 318
    Height = 49
    Alignment = taCenter
    Caption = 'Kaydet'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -12
    HotTrackFont.Name = 'Segoe UI'
    HotTrackFont.Style = [fsBold]
    ParentFont = False
    ImageIndex = 0
    OnClick = KaydetTusClick
  end
  object JvNavPanelButton1: TJvNavPanelButton
    Tag = 1
    Left = 36
    Top = 321
    Height = 49
    Alignment = taCenter
    Caption = 'Geldi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -12
    HotTrackFont.Name = 'Segoe UI'
    HotTrackFont.Style = [fsBold]
    ParentFont = False
    ImageIndex = 0
    OnClick = KaydetTusClick
  end
  object JvNavPanelButton2: TJvNavPanelButton
    Left = 186
    Top = 320
    Height = 49
    Alignment = taCenter
    Caption = 'Gelmedi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -12
    HotTrackFont.Name = 'Segoe UI'
    HotTrackFont.Style = [fsBold]
    ParentFont = False
    ImageIndex = 0
    OnClick = KaydetTusClick
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 642
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
      Left = 532
      Top = 0
      Width = 110
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
      ExplicitLeft = 1060
    end
    object RezTarih: TJvDateTimePicker
      Left = 0
      Top = 0
      Width = 282
      Height = 37
      Align = alLeft
      Date = 41465.055934965280000000
      Format = 'dd/mm/yyyy ddd'
      Time = 41465.055934965280000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -32
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Visible = False
      DropDownDate = 41465.000000000000000000
      ExplicitHeight = 45
    end
  end
  object cxLabel1: TcxLabel
    Left = 27
    Top = 68
    Caption = 'Tarih'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxDBDateEdit1: TcxDBDateEdit
    Left = 141
    Top = 67
    DataBinding.DataField = 'TARIH'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 1
    Width = 200
  end
  object cxLabel2: TcxLabel
    Left = 27
    Top = 150
    Caption = 'Kime'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxLabel3: TcxLabel
    Left = 27
    Top = 233
    Caption = 'Telefon'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxLabel4: TcxLabel
    Left = 27
    Top = 192
    Caption = 'Ki'#351'i'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxLabel5: TcxLabel
    Left = 27
    Top = 275
    Caption = 'A'#231#305'klama'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxDBTextEdit1: TcxDBTextEdit
    Left = 141
    Top = 234
    DataBinding.DataField = 'TELEFON'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 12
    Width = 200
  end
  object cxDBSpinEdit1: TcxDBSpinEdit
    Left = 141
    Top = 192
    DataBinding.DataField = 'KISI'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 10
    Width = 76
  end
  object cxDBTextEdit2: TcxDBTextEdit
    Left = 141
    Top = 276
    DataBinding.DataField = 'ACIKLAMA'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 14
    Width = 415
  end
  object EditKime: TcxButtonEdit
    Left = 141
    Top = 150
    ParentFont = False
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 7
    Text = 'EditKime'
    Width = 202
  end
  object cxDBTextEdit3: TcxDBTextEdit
    Left = 357
    Top = 104
    DataBinding.DataField = 'MASAID'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 3
    Visible = False
    Width = 73
  end
  object cxLabel6: TcxLabel
    Left = 27
    Top = 109
    Caption = 'Masa'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object cxDBTextEdit4: TcxDBTextEdit
    Left = 141
    Top = 108
    DataBinding.DataField = 'MASANO'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 4
    Width = 136
  end
  object cxDBTextEdit5: TcxDBTextEdit
    Left = 351
    Top = 156
    DataBinding.DataField = 'REHBERID'
    DataBinding.DataSource = DtsRezervasyon
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -21
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 8
    Visible = False
    Width = 73
  end
  object DtsRezervasyon: TDataSource
    DataSet = TabRezervasyon
    Left = 490
    Top = 140
  end
  object TabRezervasyon: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabRezervasyonNewRecord
    ParamData = <>
    Left = 488
    Top = 69
  end
end

