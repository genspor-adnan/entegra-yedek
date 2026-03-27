object OpsiyonDemirbasDlg: TOpsiyonDemirbasDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Demirba'#351' Opsiyonlar'#305
  ClientHeight = 546
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 511
    Width = 683
    Height = 35
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 0
    object CancelBtn: TBitBtn
      Left = 255
      Top = 5
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
      TabOrder = 1
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 169
      Top = 5
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
      TabOrder = 0
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 0
    Width = 683
    Height = 511
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = SheetGenel
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 507
    ClientRectLeft = 4
    ClientRectRight = 679
    ClientRectTop = 24
    object SheetGenel: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 0
      object Label1: TLabel
        Left = 4
        Top = 81
        Width = 148
        Height = 13
        Caption = 'Demirba'#351' '#304#231'in Varsay'#305'lan Klasor'
      end
      object checkDemirbasStok: TcxCheckBox
        Left = 5
        Top = 164
        Caption = 'Demirba'#351' ekleme '#39'Stoktan'#39' olsun'
        Properties.Alignment = taRightJustify
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        TabOrder = 0
        Transparent = True
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 167
        Top = 78
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
        Style.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        TabOrder = 1
        Text = 'VarsayilanKlasor'
        Width = 158
      end
      object BtnTakipTurleri: TcxButton
        Left = 368
        Top = 37
        Width = 132
        Height = 25
        Caption = 'Demirba'#351' Takip T'#252'rleri'
        LookAndFeel.NativeStyle = False
        TabOrder = 2
        Visible = False
        OnClick = BtnTakipTurleriClick
      end
      object cxLabel4: TcxLabel
        Left = 4
        Top = 109
        Caption = 'Demirba'#351' Kod Giri'#351'i'
        Transparent = True
      end
      object cbDemirbasKodGirisi: TcxImageComboBox
        Left = 167
        Top = 105
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Manuel'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kod A'#287'ac'#305'ndan'
            Value = 2
          end>
        TabOrder = 4
        Width = 158
      end
      object BtnAmortisman: TcxButton
        Left = 173
        Top = 37
        Width = 132
        Height = 25
        Caption = 'Amortisman'
        LookAndFeel.NativeStyle = False
        TabOrder = 5
        OnClick = BtnAmortismanClick
      end
      object cxLabel2: TcxLabel
        Left = 4
        Top = 135
        Caption = 'Servis Durumu'
        Transparent = True
      end
      object cbDemirbasServisDurumu: TcxImageComboBox
        Left = 167
        Top = 133
        RepositoryItem = Tablo.repDemirbasAksiyon
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 7
        Width = 158
      end
      object cxGroupBox1: TcxGroupBox
        Left = 3
        Top = 209
        Caption = 'Demirba'#351' Ar'#305'za Bildiriminde'
        TabOrder = 8
        Height = 152
        Width = 449
        object cxLabel1: TcxLabel
          Left = 7
          Top = 27
          Caption = 'Olu'#351'acak Aksiyon'
          Transparent = True
        end
        object ComboOlusacakAksiyon: TcxImageComboBox
          Left = 170
          Top = 25
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              Description = #304#351' Listesi Olu'#351'tursun'
              Value = 1
            end
            item
              Description = 'Teknik Servis Kayd'#305' Olu'#351'tursun'
              Value = 2
            end
            item
              Description = 'Duyuru Olu'#351'tursun'
              Value = 3
            end>
          Properties.OnChange = ComboOlusacakAksiyonPropertiesChange
          TabOrder = 1
          Width = 158
        end
        object cxLabel3: TcxLabel
          Left = 7
          Top = 55
          Caption = 'Aksiyonun Tetiklenmesi'
          Transparent = True
        end
        object ComboAksiyonTetik: TcxImageComboBox
          Left = 170
          Top = 53
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <
            item
              Description = 'Otomatik'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Sorsun'
              Value = 2
            end>
          TabOrder = 3
          Width = 158
        end
        object ComboMailSablon: TcxImageComboBox
          Left = 170
          Top = 81
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              Description = #304#351' Listesi Olu'#351'tursun'
              Value = 1
            end
            item
              Description = 'Teknik Servis Kayd'#305' Olu'#351'tursun'
              Value = 2
            end
            item
              Description = 'Duyuru Olu'#351'tursun'
              Value = 3
            end>
          TabOrder = 4
          Width = 158
        end
        object cxLabel5: TcxLabel
          Left = 7
          Top = 83
          Caption = 'Aksiyon Sonucu E-Posta '#350'ablonu'
          Transparent = True
        end
        object ComboTURU: TcxImageComboBox
          Left = 170
          Top = 108
          Align = alCustom
          RepositoryItem = Tablo.RepGorevTuru
          Properties.Items = <
            item
              Description = 'Ba'#351'lama Tarihine G'#246're'
              ImageIndex = 0
              Value = '0'
            end
            item
              Description = 'Biti'#351' Tarihine G'#246're'
              Value = '1'
            end>
          TabOrder = 6
          Width = 158
        end
        object cxLabel6: TcxLabel
          Left = 7
          Top = 109
          Caption = 'G'#246'rev Olu'#351'unca T'#252'r'#252
          Transparent = True
        end
      end
    end
    object SheetDurumBaglanti: TcxTabSheet
      Caption = 'Durum Ba'#287'lant'#305'lar'#305
      ImageIndex = 1
      object GridAksiyonDurum: TcxGrid
        Left = 0
        Top = 0
        Width = 345
        Height = 483
        Align = alLeft
        TabOrder = 0
        object GridAksiyonDurumDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsAksiyonDurum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object GridAksiyonDurumDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object GridAksiyonDurumDBTableView1AKTIF: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'AKTIF'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 48
          end
          object GridAksiyonDurumDBTableView1KAYNAKDURUM: TcxGridDBColumn
            Caption = 'Aksiyon -->'
            DataBinding.FieldName = 'KAYNAKDURUM'
            RepositoryItem = Tablo.repDemirbasAksiyon
            Options.Editing = False
            Options.Focusing = False
            Width = 159
          end
          object GridAksiyonDurumDBTableView1UYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (i'#231')'
            DataBinding.FieldName = 'UYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Visible = False
            Width = 67
          end
          object GridAksiyonDurumDBTableView1DISUYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (d'#305#351')'
            DataBinding.FieldName = 'DISUYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Visible = False
          end
          object GridAksiyonDurumDBTableView1ACILIS: TcxGridDBColumn
            Caption = 'Al'#305#351' Belgesi Sor'
            DataBinding.FieldName = 'ACILIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 78
          end
          object GridAksiyonDurumDBTableView1KAPANIS: TcxGridDBColumn
            Caption = 'Sat'#305#351' Belgesi Sor'
            DataBinding.FieldName = 'KAPANIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 83
          end
          object GridAksiyonDurumDBTableView1OTOKAPAT: TcxGridDBColumn
            Caption = 'Cari Sor'
            DataBinding.FieldName = 'OTOKAPAT'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 49
          end
          object GridAksiyonDurumDBTableView1TARIHIDESOR: TcxGridDBColumn
            Caption = 'Cari Personel Sor'
            DataBinding.FieldName = 'TARIHIDESOR'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 93
          end
          object GridAksiyonDurumDBTableView1HEDEFALANADI: TcxGridDBColumn
            Caption = 'Hedef Alan'
            DataBinding.FieldName = 'HEDEFALANADI'
            Visible = False
            Width = 71
          end
          object GridAksiyonDurumDBTableView1HEDEFALANDEGERI: TcxGridDBColumn
            Caption = 'Hedef Deger'
            DataBinding.FieldName = 'HEDEFALANDEGERI'
            Visible = False
            Width = 70
          end
          object GridAksiyonDurumDBTableView1Column1: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepDemirbas_Durum
            Width = 113
          end
        end
        object GridAksiyonDurumLevel1: TcxGridLevel
          GridView = GridAksiyonDurumDBTableView1
        end
      end
      object GridDurumAksiyon: TcxGrid
        Left = 345
        Top = 0
        Width = 330
        Height = 483
        Align = alClient
        TabOrder = 1
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsDurumAksiyon
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGridDBColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'AKTIF'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 48
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bildirim (i'#231')'
            DataBinding.FieldName = 'UYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Visible = False
            Width = 67
          end
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'Bildirim (d'#305#351')'
            DataBinding.FieldName = 'DISUYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Visible = False
          end
          object cxGridDBColumn6: TcxGridDBColumn
            Caption = 'Al'#305#351' Belgesi Sor'
            DataBinding.FieldName = 'ACILIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 78
          end
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = 'Sat'#305#351' Belgesi Sor'
            DataBinding.FieldName = 'KAPANIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 83
          end
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Cari Sor'
            DataBinding.FieldName = 'OTOKAPAT'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 49
          end
          object cxGridDBColumn9: TcxGridDBColumn
            Caption = 'Cari Personel Sor'
            DataBinding.FieldName = 'TARIHIDESOR'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 93
          end
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'Hedef Alan'
            DataBinding.FieldName = 'HEDEFALANADI'
            Visible = False
            Width = 71
          end
          object cxGridDBColumn11: TcxGridDBColumn
            Caption = 'Hedef Deger'
            DataBinding.FieldName = 'HEDEFALANDEGERI'
            Visible = False
            Width = 70
          end
          object cxGridDBColumn12: TcxGridDBColumn
            Caption = 'Durum -->'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepDemirbas_Durum
            Width = 113
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Aksiyon'
            DataBinding.FieldName = 'KAYNAKDURUM'
            RepositoryItem = Tablo.repDemirbasAksiyon
            Options.Editing = False
            Options.Focusing = False
            Width = 159
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
  end
  object TabAksiyonDurum: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from DURUMBAGLANTI '
      'where YERI = :PYeri and BOLUM= -2801 '
      'order by KAYNAKDURUM, ID')
    Left = 136
    Top = 144
  end
  object DtsAksiyonDurum: TDataSource
    DataSet = TabAksiyonDurum
    Left = 176
    Top = 184
  end
  object PopupDurumBglanti: TPopupMenu
    Left = 504
    Top = 296
    object TeklifDurumlarnDzenle1: TMenuItem
      Caption = 'Demirba'#351' Aksiyonlar'#305'n'#305' D'#252'zenle'
      OnClick = TeklifDurumlarnDzenle1Click
    end
    object DemirbaDurumlarnDzenle1: TMenuItem
      Caption = 'Demirba'#351' Durumlar'#305'n'#305' D'#252'zenle'
      OnClick = DemirbaDurumlarnDzenle1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object BalantlarOlutur1: TMenuItem
      Caption = 'Eksik Ba'#287'lant'#305'lar'#305' Olu'#351'tur'
      OnClick = BalantlarOlutur1Click
    end
    object KopmuBalantlarTemizle1: TMenuItem
      Caption = 'Kopmu'#351' Ba'#287'lant'#305'lar'#305' Temizle'
      OnClick = KopmuBalantlarTemizle1Click
    end
  end
  object DtsDurumAksiyon: TDataSource
    DataSet = TabDurumAksiyon
    Left = 424
    Top = 224
  end
  object TabDurumAksiyon: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from DURUMBAGLANTI '
      'where YERI = :PYeri and BOLUM= -2803 '
      'order by DURUM,ID')
    Left = 424
    Top = 160
  end
end

