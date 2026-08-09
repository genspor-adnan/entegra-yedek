object AnaForm: TAnaForm
  Left = 260
  Top = 149
  ClientHeight = 719
  ClientWidth = 1192
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object KimlikTus: TButton
    Left = 16
    Top = 152
    Width = 73
    Height = 25
    Caption = 'KimlikTus'
    TabOrder = 2
    Visible = False
  end
  object GelislerTus: TButton
    Left = 96
    Top = 152
    Width = 73
    Height = 25
    Caption = 'GelislerTus'
    TabOrder = 3
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 700
    Width = 1192
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 460
      end
      item
        Width = 300
      end
      item
        Width = 50
      end
      item
        Alignment = taCenter
        Width = 300
      end
      item
        Alignment = taRightJustify
        Width = 100
      end>
  end
  object Button1: TButton
    Left = 476
    Top = 96
    Width = 49
    Height = 37
    Caption = 'MCtrl'
    TabOrder = 1
    Visible = False
  end
  object Ekranyaz: TBitBtn
    Left = 319
    Top = 173
    Width = 65
    Height = 22
    Caption = 'Ekranyaz'
    TabOrder = 4
    Visible = False
  end
  object ToolBarNavigator: TDBNavigator
    Left = 389
    Top = 173
    Width = 108
    Height = 20
    VisibleButtons = [nbInsert, nbDelete]
    Flat = True
    Ctl3D = False
    Hints.Strings = (
      #304'lk F5'
      #214'nceki F6'
      'Sonraki F7'
      'Son F8'
      'Yeni F9'
      'Sil F10'
      'De'#287'i'#351'tir'
      'Kaydet F11'
      #304'ptal F12')
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    Visible = False
  end
  object YaziciYaz: TBitBtn
    Left = 326
    Top = 180
    Width = 65
    Height = 22
    Caption = 'Ekranyaz'
    TabOrder = 6
    Visible = False
  end
  object AnaSayfaDenetimi: TcxPageControl
    Left = 0
    Top = 0
    Width = 1192
    Height = 700
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Properties.CustomButtons.Buttons = <>
    Properties.Images = Tablo.PNGImageList1
    Properties.Options = [pcoAlwaysShowGoDialogButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize, pcoUsePageColorForTab]
    Properties.TabWidth = 95
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'Black'
    OnCanClose = AnaSayfaDenetimiCanClose
    OnPageChanging = AnaSayfaDenetimiPageChanging
    ClientRectBottom = 695
    ClientRectLeft = 2
    ClientRectRight = 1187
    ClientRectTop = 2
  end
  object LblSube: TcxLabel
    Left = 24
    Top = 477
    Cursor = crHandPoint
    Caption = 'LblSube'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clNavy
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsUnderline]
    Style.IsFontAssigned = True
    Transparent = True
    OnClick = LblSubeClick
  end
  object MainMenu1: TMainMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    Left = 82
    Top = 162
    object N1: TMenuItem
      Caption = 'Gen'
      ImageIndex = 11
      object KasiyerMenu: TMenuItem
        Caption = 'Kasiyer'
        ImageIndex = 34
        OnClick = KasiyerMenuClick
      end
      object CafeRestMenu: TMenuItem
        Caption = 'Cafe / Rest'
        ImageIndex = 34
        OnClick = CafeRestMenuClick
      end
      object N4: TMenuItem
        Caption = '-'
        Visible = False
      end
      object k1: TMenuItem
        Caption = #199#305'k'#305#351
        ImageIndex = 24
        ShortCut = 16465
        OnClick = k1Click
      end
    end
    object Seenekler1: TMenuItem
      Caption = 'Se'#231'enekler'
      ImageIndex = 11
      object HesapPlanMenu: TMenuItem
        Caption = 'Hesap Plan'#305
        ImageIndex = 32
        OnClick = HesapPlanMenuClick
      end
      object FirmaBilgileri1: TMenuItem
        Caption = 'Firma Bilgileri'
        ImageIndex = 11
        OnClick = FirmaBilgileri1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object DovizBilgileriMenu: TMenuItem
        Caption = 'D'#246'viz Bilgileri'
        ImageIndex = 34
        OnClick = DovizBilgileriMenuClick
      end
      object BankaBilgileriMenu: TMenuItem
        Caption = 'Banka Bilgileri'
        ImageIndex = 34
        OnClick = BankaBilgileriMenuClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object KullancAyarlar1: TMenuItem
        Caption = 'Kullan'#305'c'#305' Ayarlar'#305
        ImageIndex = 35
        OnClick = KullancAyarlar1Click
      end
      object Opsiyonlar1: TMenuItem
        Caption = 'Opsiyonlar'
        ImageIndex = 11
        object GenelOpsMenu: TMenuItem
          Caption = 'Genel'
          ImageIndex = 11
          OnClick = GenelOpsMenuClick
        end
        object N3: TMenuItem
          Caption = '-'
        end
        object CRMOpsMenu: TMenuItem
          Caption = 'CRM'
          ImageIndex = 36
          OnClick = CRMOpsMenuClick
        end
        object CariOpsMenu: TMenuItem
          Caption = 'Cari'
          ImageIndex = 35
          OnClick = CariOpsMenuClick
        end
        object KasaOpsMenu: TMenuItem
          Caption = 'Kasa'
          ImageIndex = 34
          OnClick = KasaOpsMenuClick
        end
        object KasiyerOpsMenu: TMenuItem
          Caption = 'Kasiyer'
          ImageIndex = 34
          OnClick = KasiyerOpsMenuClick
        end
        object BankaOpsMenu: TMenuItem
          Caption = 'Banka'
          ImageIndex = 34
          OnClick = BankaOpsMenuClick
        end
        object FaturaOpsMenu: TMenuItem
          Caption = 'Al'#305#351' Sat'#305#351
          ImageIndex = 34
          OnClick = FaturaOpsMenuClick
        end
        object CekSenetOpsMenu: TMenuItem
          Caption = #199'ek Senet'
          ImageIndex = 34
          OnClick = CekSenetOpsMenuClick
        end
        object StokOpsMenu: TMenuItem
          Caption = 'Stok'
          ImageIndex = 12
          OnClick = StokOpsMenuClick
        end
        object UretimOpsMenu: TMenuItem
          Caption = #220'retim'
          ImageIndex = 12
          OnClick = UretimOpsMenuClick
        end
        object IKOpsMenu: TMenuItem
          Caption = #304'K'
          ImageIndex = 35
          OnClick = IKOpsMenuClick
        end
        object DemirbasOpsMenu: TMenuItem
          Caption = 'Demirba'#351
          ImageIndex = 12
          OnClick = DemirbasOpsMenuClick
        end
        object TeklifOpsMenu: TMenuItem
          Caption = 'Teklif'
          ImageIndex = 4
          OnClick = TeklifOpsMenuClick
        end
        object ServisOpsMenu: TMenuItem
          Caption = 'Servis'
          ImageIndex = 7
          OnClick = ServisOpsMenuClick
        end
        object DokumanOpsMenu: TMenuItem
          Caption = 'Dok'#252'man'
          ImageIndex = 19
          OnClick = DokumanOpsMenuClick
        end
        object KaliteOpsMenu: TMenuItem
          Caption = 'Kalite'
          ImageIndex = 23
          OnClick = KaliteOpsMenuClick
        end
      end
      object EntegrasyonMenu: TMenuItem
        Caption = 'Replikasyon'
        ImageIndex = 9
        Visible = False
        OnClick = EntegrasyonMenuClick
      end
      object tslemleri1: TMenuItem
        Caption = #304'ts '#304#351'lemleri'
        ImageIndex = 20
        Visible = False
        OnClick = tslemleri1Click
      end
      object VeriAlImport1: TMenuItem
        Caption = 'Veri Al (Import)'
        ImageIndex = 32
        object KullaniciTanimliMenu: TMenuItem
          Caption = 'Kullan'#305'c'#305' Tan'#305'ml'#305
          ImageIndex = 0
          OnClick = KullaniciTanimliMenuClick
        end
        object N8: TMenuItem
          Caption = '-'
        end
        object AcilisKaydiDegerleriMenu: TMenuItem
          Caption = 'A'#231#305'l'#305#351' Kayd'#305' De'#287'erleri'
          ImageIndex = 4
          OnClick = AcilisKaydiDegerleriMenuClick
        end
      end
      object YedekAl1: TMenuItem
        Caption = 'Yedekleme'
        ImageIndex = 2
        OnClick = YedekAl1Click
      end
      object MenuGenelInfo: TMenuItem
        Caption = 'Log info'
        ImageIndex = 22
        OnClick = MenuGenelInfoClick
      end
    end
    object Yardm1: TMenuItem
      Caption = 'Yard'#305'm'
      ImageIndex = 22
      object Hakknda1: TMenuItem
        Caption = 'Hakk'#305'nda'
        ImageIndex = 22
        OnClick = Hakknda1Click
      end
      object KullanmKlavuzu1: TMenuItem
        Caption = 'Kullan'#305'm Klavuzu'
        ImageIndex = 19
        OnClick = KullanmKlavuzu1Click
      end
      object MesajGnder1: TMenuItem
        Caption = 'Mesaj G'#246'nder'
        ImageIndex = 18
        ShortCut = 49229
        Visible = False
        OnClick = MesajGnder1Click
      end
      object MenuSifreIslemleri: TMenuItem
        Caption = #350'ifre '#304#351'lemleri'
        ImageIndex = 29
        OnClick = MenuSifreIslemleriClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object Haklar1: TMenuItem
        Caption = 'Haklar'
        ImageIndex = 29
        OnClick = Haklar1Click
      end
      object N9: TMenuItem
        Caption = '..'
        OnClick = N9Click
      end
    end
    object DilMenu: TMenuItem
      Caption = 'Dil'
      object rke1: TMenuItem
        Tag = -1
        Caption = 'T'#252'rk'#231'e'
        Checked = True
        RadioItem = True
        OnClick = rke1Click
      end
      object EnglishUS1: TMenuItem
        Tag = -2
        Caption = 'English (US)'
        RadioItem = True
        OnClick = EnglishUS1Click
      end
    end
    object DuyuruMenu: TMenuItem
      Hint = 'Gelen duyurular'#305' listeler'
      ImageIndex = 12
      ImageName = 'PngImage12'
      OnClick = DuyuruMenuClick
    end
    object MesajMenu: TMenuItem
      Hint = 'Gelen ve giden konu'#351'malar'#305' listeler'
      ImageIndex = 7
      ImageName = 'PngImage7'
      OnClick = MesajMenuClick
    end
  end
  object HEADER: TcxStyleRepository
    Left = 664
    Top = 248
    PixelsPerInch = 96
    object cxstyl19: TcxStyle
    end
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clInactiveBorder
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBtnHighlight
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
  end
  object treeQuery: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE @tbl TABLE ('
      #9'RAPORADI varchar(100),'
      #9'GRUBU varchar(100)'
      ')'
      'INSERT INTO @tbl '
      
        'select GRUBU,'#39'-'#39' from DOKUMLER WHERE MODUL = '#39'K'#39' AND ISNULL(GRUB' +
        'U,'#39#39') <> '#39#39'  GROUP BY GRUBU'
      ''
      'INSERT INTO @tbl '
      
        'select RAPORADI,GRUBU from DOKUMLER WHERE MODUL = '#39'K'#39' AND ISNULL' +
        '(GRUBU,'#39#39') <> '#39#39' ORDER BY GRUBU'
      ''
      'select * from @tbl')
    Left = 412
    Top = 110
  end
  object treeQueryDataSource: TDataSource
    DataSet = treeQuery
    Left = 409
    Top = 187
  end
  object PopupMDI: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 811
    Top = 61
    object Tabs1: TMenuItem
      Caption = 'Sekme'
      ImageIndex = 15
      GroupIndex = 100
      RadioItem = True
      OnClick = Tabs1Click
    end
    object Buttons1: TMenuItem
      Tag = 1
      Caption = 'Buton'
      ImageIndex = 15
      GroupIndex = 100
      RadioItem = True
      OnClick = Tabs1Click
    end
    object Flat1: TMenuItem
      Tag = 2
      Caption = 'D'#252'z'
      ImageIndex = 15
      Checked = True
      GroupIndex = 100
      RadioItem = True
      OnClick = Tabs1Click
    end
  end
  object TabGorevAnimsat: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC [dbo].[sp_Prg_IsListesiHatirlatma] @Kullan=:Kullan')
    Left = 471
    Top = 135
  end
  object TimerGorevAnimsat: TJvThreadTimer
    Enabled = True
    OnTimer = TimerGorevAnimsatTimer
    Left = 628
    Top = 28
  end
  object pmGridStil: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = pmGridStilPopup
    Left = 887
    Top = 59
    object AlanYnetimi1: TMenuItem
      Caption = 'Alan Y'#246'netimi'
      ImageIndex = 15
      OnClick = AlanYnetimi1Click
    end
    object EnUygunGenilieAyarla1: TMenuItem
      Caption = 'En Uygun Geni'#351'li'#287'e Ayarla'
      ImageIndex = 11
      OnClick = EnUygunGenilieAyarla1Click
    end
    object GrupAKapa1: TMenuItem
      Caption = 'Grup A'#231'/Kapa'
      ImageIndex = 32
      object GrupA1: TMenuItem
        Caption = 'Grup A'#231' (-)'
        ImageIndex = 32
        OnClick = GrupA1Click
      end
      object GrupKapat1: TMenuItem
        Caption = 'Grup Kapat (+)'
        ImageIndex = 32
        OnClick = GrupKapat1Click
      end
    end
    object Kaydet: TMenuItem
      Caption = 'Ayar'#305' Kaydet'
      ImageIndex = 2
      object ButunkullanclarMenu: TMenuItem
        Caption = 'T'#252'm kullan'#305'c'#305'lar i'#231'in Varsay'#305'lan'
        ImageIndex = 23
        OnClick = KaydetClick
      end
      object KullancVarsaylanolarak1: TMenuItem
        Tag = 1
        Caption = 'Bana '#214'zel Varsay'#305'lan'
        ImageIndex = 23
        OnClick = KaydetClick
      end
      object FarklKaydet1: TMenuItem
        Tag = 2
        Caption = 'Farkl'#305' Kaydet'
        ImageIndex = 2
        OnClick = KaydetClick
      end
    end
    object DierKullancAyarlar1: TMenuItem
      Caption = 'Kay'#305'tl'#305' Kullan'#305'c'#305' Ayar'#305' Uygula'
      ImageIndex = 35
    end
    object KaytlKullancAyarSil: TMenuItem
      Caption = 'Kay'#305'tl'#305' Kullan'#305'c'#305' Ayar'#305' Sil'
      ImageIndex = 1
    end
    object GridAyarlarnSfrla1: TMenuItem
      Caption = 'Varsay'#305'lan Ayarlara D'#246'n'
      ImageIndex = 23
      OnClick = GridAyarlarnSfrla1Click
    end
    object StilOlutur1: TMenuItem
      Caption = 'Stil D'#252'zenle'
      ImageIndex = 7
      OnClick = StilOlutur1Click
    end
    object ExceleAktar1: TMenuItem
      Caption = 'Excele Aktar'
      ImageIndex = 32
      OnClick = ExceleAktar1Click
    end
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 504
    Top = 256
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtRowIndicator, gvhtBand, gvhtBandHeader]
        Index = 0
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 1
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 2
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 3
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 4
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 5
        PopupMenu = pmGridStil
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 6
        PopupMenu = pmGridStil
      end>
    Left = 992
    Top = 56
  end
  object WSocketCLI: TWSocket
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    KeepAliveOnOff = wsKeepAliveOnSystem
    KeepAliveTime = 30000
    KeepAliveInterval = 1000
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    ReqVerLow = 1
    ReqVerHigh = 1
    WSDebugOptions = []
    SocketErrs = wsErrTech
    Left = 91
    Top = 420
  end
  object WSocket: TWSocket
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    KeepAliveOnOff = wsKeepAliveOnSystem
    KeepAliveTime = 30000
    KeepAliveInterval = 1000
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    ReqVerLow = 1
    ReqVerHigh = 1
    WSDebugOptions = []
    OnDataAvailable = WSocketDataAvailable
    SocketErrs = wsErrTech
    Left = 33
    Top = 422
  end
  object alertAktivite: TJvDesktopAlert
    AutoFree = True
    Colors.Frame = 16384
    Colors.WindowFrom = 8454016
    Colors.WindowTo = clGreen
    Colors.CaptionFrom = 8454016
    Colors.CaptionTo = clGreen
    Location.Top = 0
    Location.Left = 0
    Location.Width = 0
    Location.Height = 0
    HeaderFont.Charset = TURKISH_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Trebuchet MS'
    HeaderFont.Style = [fsBold]
    ShowHint = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    Buttons = <
      item
        ImageIndex = 4
        Tag = 2
      end>
    Image.Data = {
      07544269746D617076060000424D760600000000000036040000280000001800
      000018000000010008000000000040020000130B0000130B0000000100000001
      000000000000A54A0000CE630000DE7B0000006363003163630063636300E7A5
      6300846B6B00A5737300639C9C00CE9C9C00FF9C9C007B39B5009CCECE00FFCE
      CE00B5DEDE00FFEFEF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00121212121212121212121212121212121212121212121212121212121212
      1212121212121212121212121212121212121212121212121212121212121212
      080808080812121212121212120101010101010101010808080C000908080808
      12121212120A0A0A0A0A0A060808090C0C0F000F0C0C09080812121205050505
      0505050808090F0F0F0F0F0F0F0F0F09081212120404040404040408090F0F0F
      0F0F0F0F0F0F0F0B080812120A0E0E0E0E0E06080F0F0F0F0F0F0F0F0F0F0F0F
      09081212120A1010101008080F0F0F0F0F0F0F0F0F0F0F000C081212120A1313
      131008090F110F0F0F0F0F0F0F00000F0F091212120A13131310080000110F0F
      0F0F0000000F0F0F0F081212120A1010100D08090F13110F0F0F000F0F0F0F0F
      0F091212120A1313130D08080F1311110F0F000F0F0F0F0F0C081212120A1313
      130D0908091113110F0F000F0F0F0F0F0C081212120A1010100D0D08080F1113
      0F0F000F0F0F0F0F09081212120A13131310130908090F0F110F0F0F0F0F0F09
      08121212120A131313101313080808090F0F000F0C0C090808121212120A1010
      1010101010060808080900090808080812121212120202020202020202020202
      0808080808050502121212121202020202020202020202020202020202020202
      1212121212030303030303030303030303030303030302021212121212120707
      0707070707070707070707070707070212121212121212121212121212121212
      1212121212121212121212121212121212121212121212121212121212121212
      1212}
    Left = 480
    Top = 368
  end
  object AlertUyari: TJvDesktopAlert
    Colors.Frame = 284415
    Colors.WindowFrom = 7972351
    Colors.WindowTo = 4227327
    Colors.CaptionFrom = 7972351
    Colors.CaptionTo = 4227327
    Location.Top = 0
    Location.Left = 0
    Location.Width = 0
    Location.Height = 0
    StyleOptions.DisplayDuration = 10000
    HeaderFont.Charset = TURKISH_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = [fsBold]
    ShowHint = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Buttons = <>
    Image.Data = {
      07544269746D617076060000424D760600000000000036040000280000001800
      000018000000010008000000000040020000130B0000130B0000000100000001
      000000000000A54A0000CE630000DE7B0000006363003163630063636300E7A5
      6300846B6B00A5737300639C9C00CE9C9C00FF9C9C007B39B5009CCECE00FFCE
      CE00B5DEDE00FFEFEF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00121212121212121212121212121212121212121212121212121212121212
      1212121212121212121212121212121212121212121212121212121212121212
      080808080812121212121212120101010101010101010808080C000908080808
      12121212120A0A0A0A0A0A060808090C0C0F000F0C0C09080812121205050505
      0505050808090F0F0F0F0F0F0F0F0F09081212120404040404040408090F0F0F
      0F0F0F0F0F0F0F0B080812120A0E0E0E0E0E06080F0F0F0F0F0F0F0F0F0F0F0F
      09081212120A1010101008080F0F0F0F0F0F0F0F0F0F0F000C081212120A1313
      131008090F110F0F0F0F0F0F0F00000F0F091212120A13131310080000110F0F
      0F0F0000000F0F0F0F081212120A1010100D08090F13110F0F0F000F0F0F0F0F
      0F091212120A1313130D08080F1311110F0F000F0F0F0F0F0C081212120A1313
      130D0908091113110F0F000F0F0F0F0F0C081212120A1010100D0D08080F1113
      0F0F000F0F0F0F0F09081212120A13131310130908090F0F110F0F0F0F0F0F09
      08121212120A131313101313080808090F0F000F0C0C090808121212120A1010
      1010101010060808080900090808080812121212120202020202020202020202
      0808080808050502121212121202020202020202020202020202020202020202
      1212121212030303030303030303030303030303030302021212121212120707
      0707070707070707070707070707070212121212121212121212121212121212
      1212121212121212121212121212121212121212121212121212121212121212
      1212}
    Left = 553
    Top = 365
  end
  object AlertDuyuru: TJvDesktopAlert
    Colors.Frame = 284415
    Colors.WindowFrom = 7972351
    Colors.WindowTo = 4227327
    Colors.CaptionFrom = 7972351
    Colors.CaptionTo = 4227327
    Location.Top = 0
    Location.Left = 0
    Location.Width = 0
    Location.Height = 0
    StyleOptions.DisplayDuration = 10000
    HeaderFont.Charset = TURKISH_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Trebuchet MS'
    HeaderFont.Style = [fsBold]
    ShowHint = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    Buttons = <>
    Image.Data = {
      07544269746D617076060000424D760600000000000036040000280000001800
      000018000000010008000000000040020000D30E0000D30E0000000100000001
      000042424200524A4200635A4A005A5A5A00635A5A00636363006B6363006B6B
      6B00737373007B737300847373007B7B7300B59473007B7B7B00A5847B008484
      84008C8484008C8C84009C948400A59C8400C6AD84008C8C8C00948C8C009C8C
      8C00A58C8C00AD8C8C00AD948C00A59C8C00A5A58C00B5A58C00ADAD8C00B5AD
      8C00949494009C949400AD9494009C9C9400CEAD9400DEBD94009C9C9C00A59C
      9C00AD9C9C00BD9C9C00B5AD9C00C6BD9C00D6BD9C00DECE9C00A5A5A500B5A5
      A500BDA5A500C6B5A500D6C6A500CECEA500DECEA500EFD6A5007B94AD00A5A5
      AD00ADADAD00C6ADAD00CECEAD00EFD6AD00F7DEAD00FFDEAD00FFE7AD00B5B5
      B500BDB5B500D6BDB500D6C6B500D6CEB500DECEB500FFE7B500B5BDBD00BDBD
      BD00E7CEBD00EFD6BD00EFDEBD00FFEFBD00425AC6007BA5C600CEC6C600EFDE
      C600F7DEC600EFE7C600FFE7C600FFF7C600CECECE00D6CECE00DEDECE00E7DE
      CE00FFEFCE00FFFFCE004263D6009CADD600BDC6D600C6C6D600D6D6D600DEDE
      D600E7DED600EFE7D600F7F7D600FFF7D600FFFFD600738CDE00ADC6DE00C6CE
      DE00CED6DE00D6DEDE00DEDEDE00E7DEDE00E7E7DE00F7EFDE00FFFFDE008494
      E700ADBDE700ADC6E700BDCEE700DEE7E700E7E7E700FFFFE7004A7BEF00D6E7
      EF00EFEFEF00FFF7EF00FFFFEF005A94F70084ADF700ADD6F700EFF7F700F7F7
      F700FFFFF700FF00FF001052FF00185AFF003173FF00217BFF00317BFF002984
      FF00318CFF004A94FF00ADD6FF00F7F7FF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
      FF0081811D262617818181818181818181818181818181818181811D317F744E
      210A0F178181818181818181818181818181811D426B746A74786B4016091781
      81818181818181818181811D486B8C5F7F746A74744E410E1781818181818181
      8181811D495F74677471785F74746A4E19178181818181818181811D506B8B5F
      8C746A686A5F74744E171781818181818181811D50565E5C74708C5F7F6A6A77
      694E1781818181818181811D5051615F7F6A74676A667E675528818181818181
      8181811D514F515F73707E5F8C5F74692F178181818181818181811D4F4A4F51
      6160605E685C775C170707070F8181818181818976655B5D57616D6D79792C0B
      1027223022040781818181868683828283847B7C72241115121F371E13291803
      8181818181898989888887855A20233258636F7F793A1A190581818181818181
      8181814D3638344B453D3D3D52804329068181818181818181818181812A4B4B
      4B4B453D3D527913220F8181818181818181810F544F595959532D3C3E3D792B
      390D8181818181818181810F5E3F7D80643A0D01020C6C4C300D818181818181
      8181810F6A4F7F806E621C00143B632A280F8181818181818181810F5E4F808C
      7A75643A0125581B160F818181818181818181810F5F4F8C8C8C7A6433023510
      080F818181818181818181810F6A564F808C8A7F533B23150F81818181818181
      81818181810F6A5E4F4446424F2E260F81818181818181818181818181810F54
      6A6A5454472E0F818181818181818181818181818181810F0F0F0F0F0F0F8181
      8181}
    Left = 616
    Top = 360
  end
  object TabGorevAnimsat2: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE '
      #9'@RehberID int,'
      #9'@Simdi DATETIME'
      #9'SET @RehberID = :PRehberID'
      #9'SET @Simdi = GETDATE()'
      'select '
      #9'ID,'
      #9'TUR='#39'G'#246'rev'#39','
      'TURU,'
      #9'DURUM,'
      #9'BITISTARIHI,'
      #9'ATAYAN,'
      #9'SORUMLU, '
      #9'KONUSU,'
      #9'NOTLAR,'
      #9'TAMAMLANMAORANI,'
      #9'ANIMSAT,'
      #9'ANIMSATMATARIHI, '
      #9'ALARMTARIHI= ANIMSATMATARIHI,'
      
        #9'YaziTarih=dbo.fn_TarihFarkiGunAyYilSaatDakikaTextOlarak(BITISTA' +
        'RIHI,@Simdi) ,'
      
        '                FIRMA=isnull((Select FIRMA from REHBER R where R' +
        '.ID=A.MUSTERIID),'#39#39')'
      'from '
      #9'AKTIVITELER A'
      'where '
      #9'SORUMLU=@RehberID '
      #9'and ANIMSAT>0 and DURUM<>9'
      #9'and @Simdi >  ANIMSATMATARIHI '
      ''
      ''
      #9'--tamamlanmam'#305#351' ba'#287'l'#305' aktiviteler i'#231'in;'
      
        #9'and (select COUNT(ID) from AKTIVITELER A2 where ID=A.BAGLIAKTIV' +
        'ITEID and A2.DURUM not in (9) )=0'
      #9'--iptal edilmi'#351' ba'#287'l'#305' aktiviteler i'#231'in;'
      
        #9'and (select COUNT(ID) from AKTIVITELER A2 where ID=A.BAGLIAKTIV' +
        'ITEID and A2.DURUM in (4) )=0'
      ''
      'Order by '
      '             2,4 desc'
      '')
    Left = 575
    Top = 135
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 40
    Top = 8
  end
  object PopupMenuTree: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 879
    Top = 131
    object MenuItem1: TMenuItem
      Caption = 'Alan Y'#246'netimi'
      ImageIndex = 15
      OnClick = MenuItem1Click
    end
    object MenuItem2: TMenuItem
      Caption = 'En Uygun Geni'#351'li'#287'e Ayarla'
      ImageIndex = 11
      OnClick = MenuItem2Click
    end
    object MenuItem3: TMenuItem
      Caption = 'Kaydet'
      ImageIndex = 2
      OnClick = MenuItem3Click
    end
    object MenuItem4: TMenuItem
      Caption = 'Varsay'#305'lan Ayarlara D'#246'n'
      ImageIndex = 23
      OnClick = MenuItem4Click
    end
    object MenuItem5: TMenuItem
      Caption = 'Stil D'#252'zenle'
      ImageIndex = 7
      Visible = False
    end
    object MenuItem6: TMenuItem
      Caption = 'Excele Aktar'
      ImageIndex = 32
      OnClick = MenuItem6Click
    end
  end
  object MsgClient: TIdTCPClient
    OnConnected = MsgClientConnected
    ConnectTimeout = 0
    Host = '192.168.0.18'
    Port = 7777
    ReadTimeout = -1
    Left = 215
    Top = 126
  end
  object ChatTimer: TJvTimer
    OnTimer = ChatTimerTimer
    Left = 264
    Top = 16
  end
end
