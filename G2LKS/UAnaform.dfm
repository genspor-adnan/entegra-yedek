object AnaForm: TAnaForm
  Left = 297
  Top = 136
  Caption = 'Gentegrasyon'
  ClientHeight = 640
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  Position = poDefault
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 1008
    Height = 38
    BandBorderStyle = bsNone
    Bands = <
      item
        Control = AletCubugu
        ImageIndex = -1
        MinHeight = 36
        Width = 1006
      end>
    EdgeBorders = []
    EdgeInner = esNone
    EdgeOuter = esNone
    Images = Tablo.ImageList1
    Visible = False
    ExplicitWidth = 1004
    object AletCubugu: TToolBar
      Left = 11
      Top = 0
      Width = 364
      Height = 36
      Align = alNone
      AutoSize = True
      ButtonHeight = 36
      ButtonWidth = 56
      Caption = 'AletCubugu'
      DockSite = True
      EdgeInner = esNone
      EdgeOuter = esNone
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Images = Tablo.ImageList1
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      object G2LKSTus: TToolButton
        Left = 0
        Top = 0
        Hint = 'Fatura Listesi Ekran'#305' Ctrl+F'
        Caption = 'Muhasebe'
        ImageIndex = 14
        ParentShowHint = False
        ShowHint = True
        OnClick = G2LKSTusClick
      end
      object ToolButton1: TToolButton
        Left = 56
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object EkranYaz: TToolButton
        Left = 64
        Top = 0
        Hint = 'Bas'#305'lacak sayfay'#305' ekranda g'#246'sterir'
        Caption = 'Muhasebe'
        ImageIndex = 6
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = EkranYazClick
      end
      object YaziciYaz: TToolButton
        Left = 120
        Top = 0
        Hint = 'Yaz'#305'c'#305'ya yazd'#305'r'#305'r'
        Caption = 'Muhasebe'
        ImageIndex = 5
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = EkranYazClick
      end
      object ToolButton5: TToolButton
        Left = 176
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object ToolBarNavigator: TDBNavigator
        Left = 184
        Top = 0
        Width = 180
        Height = 36
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete]
        Flat = True
        Ctl3D = False
        Hints.Strings = (
          #304'lk F5'
          #214'nceki F6'
          'Sonraki F7'
          'Son F8'
          'Yeni Kay'#305't Ekle F9'
          'Kay'#305't Sil F10'
          'De'#287'i'#351'tir'
          'Kaydet F11'
          #304'ptal F12')
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Visible = False
      end
    end
  end
  object KimlikTus: TButton
    Left = 280
    Top = 152
    Width = 25
    Height = 25
    Caption = '-'
    TabOrder = 1
    Visible = False
  end
  object GelislerTus: TButton
    Left = 312
    Top = 152
    Width = 89
    Height = 25
    Caption = 'GelislerTus'
    TabOrder = 2
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 621
    Width = 1008
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 250
      end
      item
        Width = 250
      end
      item
        Width = 50
      end>
    ExplicitTop = 620
    ExplicitWidth = 1004
  end
  object MainMenu1: TMainMenu
    Images = Tablo.ImageList1
    Left = 168
    Top = 136
    object G2Likom1: TMenuItem
      Caption = 'Muhasebe'
      object G2Likom2: TMenuItem
        Caption = 'Muhasebe'
        ImageIndex = 14
        ShortCut = 16455
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object k1: TMenuItem
        Caption = #199#305'k'#305#351
        ImageIndex = 7
        OnClick = k1Click
      end
    end
    object Dkmler1: TMenuItem
      Caption = 'D'#246'k'#252'mler'
      object GenelDokumler: TMenuItem
        Caption = 'Genel D'#246'k'#252'mler'
      end
    end
    object mnAraclar: TMenuItem
      Caption = 'Ara'#231'lar'
      object Opsiyonlar1: TMenuItem
        Caption = 'Se'#231'enekler...'
        OnClick = Opsiyonlar1Click
      end
      object Eletirmeler1: TMenuItem
        Caption = 'E'#351'le'#351'tirmeler'
        object KurumEletirmeleri1: TMenuItem
          Caption = 'Kurum E'#351'le'#351'tirmeleri'
          OnClick = KurumEletirmeleri1Click
        end
        object mnTahsilatEsletir: TMenuItem
          Caption = 'Tahsilat T'#252'rleri E'#351'le'#351'tirme'
          OnClick = mnTahsilatEsletirClick
        end
      end
    end
    object Hakknda1: TMenuItem
      Caption = 'Yard'#305'm'
      object nerimvar1: TMenuItem
        Caption = #214'nerim var...'
        Enabled = False
        Visible = False
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Hakknda2: TMenuItem
        Caption = 'Hakk'#305'nda...'
        OnClick = Hakknda2Click
      end
      object KullanmKlavuzu1: TMenuItem
        Caption = 'Kullan'#305'm Klavuzu'
        OnClick = KullanmKlavuzu1Click
      end
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtRowIndicator, gvhtBand, gvhtBandHeader]
        Index = 0
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 1
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 2
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 3
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 4
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 5
      end
      item
        HitTypes = [gvhtRowIndicator]
        Index = 6
      end>
    Left = 812
    Top = 88
  end
  object pmGridStil: TPopupMenu
    Left = 887
    Top = 59
    object AlanYnetimi1: TMenuItem
      Caption = 'Alan Y'#246'netimi'
    end
    object EnUygunGenilieAyarla1: TMenuItem
      Caption = 'En Uygun Geni'#351'li'#287'e Ayarla'
    end
    object GrupAKapa1: TMenuItem
      Caption = 'Grup A'#231'/Kapa'
      object GrupA1: TMenuItem
        Caption = 'Grup A'#231' (-)'
      end
      object GrupKapat1: TMenuItem
        Caption = 'Grup Kapat (+)'
      end
    end
    object Kaydet: TMenuItem
      Caption = 'Ayar'#305' Kaydet'
      object ButunkullanclarMenu: TMenuItem
        Caption = 'T'#252'm kullan'#305'c'#305'lar i'#231'in Varsay'#305'lan'
      end
      object KullancVarsaylanolarak1: TMenuItem
        Tag = 1
        Caption = 'Bana '#214'zel Varsay'#305'lan'
      end
      object FarklKaydet1: TMenuItem
        Tag = 2
        Caption = 'Farkl'#305' Kaydet'
      end
    end
    object DierKullancAyarlar1: TMenuItem
      Caption = 'Kay'#305'tl'#305' Kullan'#305'c'#305' Ayar'#305' Uygula'
    end
    object KaytlKullancAyarSil: TMenuItem
      Caption = 'Kay'#305'tl'#305' Kullan'#305'c'#305' Ayar'#305' Sil'
    end
    object GridAyarlarnSfrla1: TMenuItem
      Caption = 'Varsay'#305'lan Ayarlara D'#246'n'
    end
    object StilOlutur1: TMenuItem
      Caption = 'Stil D'#252'zenle'
    end
    object ExceleAktar1: TMenuItem
      Caption = 'Excele Aktar'
    end
  end
end
