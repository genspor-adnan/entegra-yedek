object OpsiyonDlg: TOpsiyonDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Se'#231'enekler'
  ClientHeight = 471
  ClientWidth = 835
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox10: TGroupBox
    Left = 0
    Top = 0
    Width = 835
    Height = 177
    Align = alTop
    Caption = 'Hesap Bilgileri'
    TabOrder = 0
    object ToolBar6: TToolBar
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 825
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 61
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object BtnITSHesapEkle: TToolButton
        Left = 0
        Top = 0
        Caption = 'Ekle'
        ImageIndex = 4
        Style = tbsTextButton
        OnClick = BtnITSHesapEkleClick
      end
      object BtnITSHesapSil: TToolButton
        Left = 61
        Top = 0
        Caption = 'Sil'
        ImageIndex = 5
        Style = tbsTextButton
        OnClick = BtnITSHesapSilClick
      end
      object ToolButton8: TToolButton
        Left = 122
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object BtnITSHesapKaydet: TToolButton
        Left = 130
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Visible = False
        OnClick = BtnITSHesapKaydetClick
      end
      object BtnITSHesapVazgec: TToolButton
        Left = 191
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Visible = False
        OnClick = BtnITSHesapVazgecClick
      end
      object VarsayilanKaydet: TcxButton
        Left = 252
        Top = 0
        Width = 307
        Height = 22
        Align = alRight
        Caption = 'ITS G'#246'nderimleri i'#231'in bu hesab'#305' kullan'
        LookAndFeel.NativeStyle = True
        TabOrder = 0
        OnClick = VarsayilanKaydetClick
      end
    end
    object GridITSHesaplari: TcxGrid
      Left = 2
      Top = 42
      Width = 831
      Height = 133
      Align = alClient
      TabOrder = 1
      LookAndFeel.NativeStyle = True
      object TvITSHesaplari: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = DtsITSHesaplari
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object TvITSHesaplariID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object TvITSHesaplariGONDEREN: TcxGridDBColumn
          Caption = 'G'#246'nderici'
          DataBinding.FieldName = 'GONDEREN'
          Width = 100
        end
        object TvITSHesaplariKULLANICIADI: TcxGridDBColumn
          Caption = 'Kullanc'#305' Ad'#305
          DataBinding.FieldName = 'KULLANICIADI'
          Width = 150
        end
        object TvITSHesaplariSIFRE: TcxGridDBColumn
          Caption = #350'ifre'
          DataBinding.FieldName = 'SIFRE'
          Width = 150
        end
        object TvITSHesaplariSERVIS: TcxGridDBColumn
          Caption = 'Servis'
          DataBinding.FieldName = 'SERVIS'
          Width = 300
        end
      end
      object cxGridLevel3: TcxGridLevel
        GridView = TvITSHesaplari
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 177
    Width = 835
    Height = 258
    Align = alClient
    TabOrder = 1
    object cxLabel1: TcxLabel
      Left = 6
      Top = 17
      Caption = 'GS1 Firma Numaras'#305
    end
    object EdtGS1FirmaNumarasi: TcxTextEdit
      Left = 111
      Top = 16
      TabOrder = 1
      Width = 162
    end
    object cxLabel2: TcxLabel
      Left = 111
      Top = 0
      Caption = '7 veya 9 karekter olmal'#305'd'#305'r.'
    end
    object GroupBox1: TGroupBox
      Left = 6
      Top = 67
      Width = 267
      Height = 150
      Caption = 'Kapasiteler'
      TabOrder = 3
      object cxLabel3: TcxLabel
        Left = 6
        Top = 17
        Caption = 'Palet'
      end
      object cxLabel4: TcxLabel
        Left = 6
        Top = 40
        Caption = 'Koli'
      end
      object cxLabel5: TcxLabel
        Left = 6
        Top = 63
        Caption = 'Ba'#287
      end
      object cxLabel6: TcxLabel
        Left = 6
        Top = 86
        Caption = 'Koli '#304#231'i Kutu'
      end
      object cxLabel7: TcxLabel
        Left = 6
        Top = 109
        Caption = 'K'#252#231#252'k Ba'#287
      end
      object EdtKapasitePalet: TcxSpinEdit
        Left = 111
        Top = 16
        TabOrder = 5
        Width = 58
      end
      object EdtKapasiteKoli: TcxSpinEdit
        Left = 111
        Top = 39
        TabOrder = 6
        Width = 58
      end
      object EdtKapasiteBag: TcxSpinEdit
        Left = 111
        Top = 62
        TabOrder = 7
        Width = 58
      end
      object EdtKapasiteKutu: TcxSpinEdit
        Left = 111
        Top = 85
        TabOrder = 8
        Width = 58
      end
      object EdtKapasiteKucukBag: TcxSpinEdit
        Left = 111
        Top = 108
        TabOrder = 9
        Width = 58
      end
    end
    object GroupBox2: TGroupBox
      Left = 279
      Top = 67
      Width = 267
      Height = 150
      Caption = 'Pts Bilgileri'
      TabOrder = 4
      object cxLabel8: TcxLabel
        Left = 5
        Top = 32
        Caption = 'Pts yenileme zaman'#305
      end
      object EdPaketYenilemeZamani: TcxSpinEdit
        Left = 127
        Top = 31
        TabOrder = 1
        Width = 58
      end
      object dk: TcxLabel
        Left = 188
        Top = 32
        Caption = 'dk'
      end
      object cxLabel9: TcxLabel
        Left = 5
        Top = 55
        Caption = 'Pts kontrol edilecek g'#252'n '
      end
      object EdPaketKontrolEdilecekGun: TcxSpinEdit
        Left = 127
        Top = 51
        TabOrder = 4
        Width = 58
      end
      object ChkPaketlerGuncellesin: TcxCheckBox
        Left = 0
        Top = 12
        Caption = 'Paketler G'#252'ncellesin'
        TabOrder = 5
        Width = 264
      end
    end
    object ChkListelerGuncellesin: TcxCheckBox
      Left = 279
      Top = 16
      Caption = 'Listeler G'#252'ncellesin'
      TabOrder = 5
      Width = 267
    end
    object cxLabel10: TcxLabel
      Left = 6
      Top = 40
      Caption = 'Oto Sat'#305#351' Gln'
    end
    object EdtOtoSatısGln: TcxTextEdit
      Left = 111
      Top = 40
      TabOrder = 7
      Width = 162
    end
    object ChkITSYeniServis: TcxCheckBox
      Left = 6
      Top = 223
      Caption = 'ITS Yeni Servis'
      TabOrder = 8
      Width = 267
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 435
    Width = 835
    Height = 36
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 2
    object CancelBtn: TBitBtn
      Left = 464
      Top = 6
      Width = 72
      Height = 24
      Cancel = True
      Caption = 'Ka&pat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000220B0000220B000000010000000100000031DE000031
        E7000031EF000031F700FF00FF000031FF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00040404040404
        0404040404040404000004000004040404040404040404000004040000000404
        0404040404040000040404000000000404040404040000040404040402000000
        0404040400000404040404040404000000040000000404040404040404040400
        0101010004040404040404040404040401010204040404040404040404040400
        0201020304040404040404040404030201040403030404040404040404050203
        0404040405030404040404040303050404040404040303040404040303030404
        0404040404040403040403030304040404040404040404040404030304040404
        0404040404040404040404040404040404040404040404040404}
      Margin = 2
      ModalResult = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      OnClick = CancelBtnClick
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 542
      Top = 6
      Width = 73
      Height = 24
      Caption = '&Kaydet'
      Default = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
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
      Margin = 2
      ModalResult = 1
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object DtsITSHesaplari: TDataSource
    DataSet = TabITSHesaplari
    OnStateChange = DtsITSHesaplariStateChange
    Left = 703
    Top = 228
  end
  object TabITSHesaplari: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITSHESAPLARI')
    Left = 760
    Top = 229
  end
end
