object YedekCalistirDlg: TYedekCalistirDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Yedekleme Bilgileri'
  ClientHeight = 352
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 531
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
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
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object btnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = btnKaydetClick
    end
    object ToolButton1: TToolButton
      Left = 71
      Top = 0
      Width = 356
      Caption = 'ToolButton1'
      ImageIndex = 18
      Style = tbsSeparator
    end
    object btnkapat: TToolButton
      Left = 427
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = btnkapatClick
    end
  end
  object gbServerBilgileri: TGroupBox
    Left = 0
    Top = 35
    Width = 537
    Height = 73
    Align = alTop
    Caption = 'Server Yedekleme Bilgileri'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 29
    object Label1: TcxLabel
      Left = 5
      Top = 20
      Caption = 'Dizin'
    end
    object Label9: TcxLabel
      Left = 5
      Top = 46
      Caption = 'Ad'#305
    end
    object CheckTarihSaat: TcxCheckBox
      Left = 239
      Top = 45
      Caption = 'Sonuna Tarih/Saat ekle'
      Enabled = False
      State = cbsChecked
      TabOrder = 4
      Transparent = True
      Visible = False
      Width = 157
    end
    object ServerDizin: TcxButtonEdit
      Left = 71
      Top = 19
      Hint = #214'rnek  D:\Yedekler'
      ParentColor = True
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      Properties.OnButtonClick = ServerDizinPropertiesButtonClick
      ShowHint = True
      TabOrder = 0
      Width = 301
    end
    object BakcupAdi: TcxTextEdit
      Left = 71
      Top = 45
      Hint = 'Yedek ismini giriniz.'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'GENYEDEK'
      Width = 161
    end
    object cxLabel1: TcxLabel
      Left = 378
      Top = 21
      Caption = '(Dikkat Serverda Olmal'#305')'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
  end
  object gbTerminalBilgileri: TGroupBox
    Left = 0
    Top = 108
    Width = 537
    Height = 53
    Align = alTop
    Caption = 'Winrar dizin ve exe bilgisi'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    object cxLabel2: TcxLabel
      Left = 5
      Top = 23
      Caption = 'Dizin'
    end
    object WinrarDizin: TcxButtonEdit
      Left = 73
      Top = 23
      Hint = #214'rnek  C:\Program Files\WinRAR\Rar.exe'
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      Properties.OnButtonClick = WinrarDizinPropertiesButtonClick
      ShowHint = True
      TabOrder = 0
      Width = 301
    end
    object cxLabel3: TcxLabel
      Left = 380
      Top = 25
      Caption = '(Dikkat Serverda Olmal'#305')'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 161
    Width = 537
    Height = 191
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentColor = True
    ParentFont = False
    TabOrder = 3
    ExplicitTop = 232
    ExplicitHeight = 188
    object SpeedButton1: TSpeedButton
      Left = 149
      Top = 128
      Width = 161
      Height = 30
      Caption = #350'imdi Yedekle'
      OnClick = SpeedButton1Click
    end
    object Label2: TcxLabel
      Left = 64
      Top = 60
      Caption = 'g'#252'nden '#246'nceki yedekler silinsin'
      Transparent = True
    end
    object CheckTutulacakGun: TcxCheckBox
      Left = 7
      Top = 59
      TabOrder = 1
      Transparent = True
      OnClick = CheckTutulacakGunClick
      Width = 15
    end
    object txtTutulacakGun: TSpinEdit
      Left = 23
      Top = 57
      Width = 38
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object CheckprgKapanirkenYedek: TcxCheckBox
      Left = 5
      Top = 13
      Caption = 'Program kapan'#305'rken yedekle (G'#252'nde 1 kez)'
      Properties.ImmediatePost = True
      TabOrder = 3
      Transparent = True
      OnClick = CheckprgKapanirkenYedekClick
      Width = 238
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 304
  end
end
