object OpsiyonServisDlg: TOpsiyonServisDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Servis Opsiyonlar'#305
  ClientHeight = 562
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 521
    Width = 692
    Height = 41
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 0
    object CancelBtn: TBitBtn
      Left = 376
      Top = 7
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
      Left = 297
      Top = 7
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
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 692
    Height = 521
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = SheetGenel
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 517
    ClientRectLeft = 4
    ClientRectRight = 688
    ClientRectTop = 24
    object SheetGenel: TcxTabSheet
      Caption = '    Genel    '
      ImageIndex = 11
      object Label1: TLabel
        Left = 24
        Top = 205
        Width = 128
        Height = 13
        Caption = 'Dok'#252'man Varsay'#305'lan Klas'#246'r'
      end
      object cbServisTuru: TcxImageComboBox
        Left = 187
        Top = 121
        RepositoryItem = Tablo.repServisTuru
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 0
        Width = 121
      end
      object cxLabel1: TcxLabel
        Left = 26
        Top = 123
        Caption = 'Varsay'#305'lan Servis T'#252'r'#252
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 185
        Top = 202
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
        TabOrder = 2
        Text = 'VarsayilanKlasor'
        Width = 121
      end
      object cxGroupBox2: TcxGroupBox
        Left = 21
        Top = 268
        Caption = 'G'#246'ster/G'#246'sterme'
        TabOrder = 3
        Height = 183
        Width = 284
        object CheckSerino: TcxCheckBox
          Left = 9
          Top = 20
          Caption = 'Seri No'
          State = cbsChecked
          TabOrder = 0
          Transparent = True
        end
        object CheckTeslimSekmesi: TcxCheckBox
          Left = 9
          Top = 96
          Caption = 'Teslim Sekmesi'
          State = cbsChecked
          TabOrder = 1
          Transparent = True
        end
        object CheckEkAlanlarSekmesi: TcxCheckBox
          Left = 9
          Top = 121
          Caption = 'Ek Alanlar Sekmesi'
          State = cbsChecked
          TabOrder = 2
          Transparent = True
        end
        object CheckBelgelerSekmesi: TcxCheckBox
          Left = 161
          Top = 71
          Caption = 'Belgeler Sekmesi'
          State = cbsChecked
          TabOrder = 3
          Transparent = True
        end
        object CheckGenelSekmesi: TcxCheckBox
          Left = 161
          Top = 18
          Caption = 'Genel Sekmesi'
          State = cbsChecked
          TabOrder = 4
          Transparent = True
        end
        object CheckYorumSekmesi: TcxCheckBox
          Left = 161
          Top = 45
          Caption = 'Yorum Sekmesi'
          State = cbsChecked
          TabOrder = 5
          Transparent = True
        end
        object CheckProje: TcxCheckBox
          Left = 9
          Top = 45
          State = cbsChecked
          TabOrder = 6
          Transparent = True
        end
        object CheckLokasyon: TcxCheckBox
          Left = 9
          Top = 70
          Caption = 'Lokasyon'
          State = cbsChecked
          TabOrder = 7
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 161
          Top = 100
          Caption = 'Hareketler Sekmesi'
        end
        object ComboHareketlerSekmesi: TcxImageComboBox
          Left = 161
          Top = 119
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <
            item
              Description = 'G'#246'r'#252'nmesin'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = #220'stte G'#246'r'#252'ns'#252'n'
              Value = 1
            end
            item
              Description = 'Altta G'#246'r'#252'ns'#252'n'
              Value = 2
            end>
          TabOrder = 9
          Width = 115
        end
        object CheckOzellikSekmesi: TcxCheckBox
          Left = 10
          Top = 145
          Caption = #214'zellik Sekmesi'
          State = cbsChecked
          TabOrder = 10
          Transparent = True
        end
        object ComboProjeFirsatSec: TcxImageComboBox
          Left = 30
          Top = 45
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <
            item
              Description = 'Proje'
              ImageIndex = 0
              Value = 11
            end
            item
              Description = 'F'#305'rsat'
              Value = 1
            end>
          TabOrder = 11
          Width = 91
        end
      end
      object cbServisKapsami: TcxImageComboBox
        Left = 187
        Top = 97
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'M'#252#351'teriler (Ekipmanlar)'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Kurum i'#231'i (Demirba'#351'lar)'
            Value = 1
          end
          item
            Description = 'Mu'#351'teri + Kurum '#304#231'i'
            Value = 2
          end>
        TabOrder = 4
        Width = 121
      end
      object cxLabel6: TcxLabel
        Left = 26
        Top = 99
        Caption = 'Servis Kapsam'#305
      end
      object BtnTakipTurleri: TcxButton
        Left = 30
        Top = 21
        Width = 120
        Height = 25
        Caption = 'Servis Durumlar'#305
        LookAndFeel.NativeStyle = False
        TabOrder = 6
        OnClick = BtnTakipTurleriClick
      end
      object cxButton2: TcxButton
        Left = 30
        Top = 52
        Width = 120
        Height = 25
        Caption = 'Servis Genel Bilgiler'
        LookAndFeel.NativeStyle = False
        TabOrder = 7
        OnClick = cxButton2Click
      end
      object checkBirdenFazlaPers: TcxCheckBox
        Left = 24
        Top = 229
        Caption = 'Birden fazla personel tek bir servisin sorumlusu olabilir.'
        State = cbsChecked
        TabOrder = 8
        Transparent = True
      end
      object btnMailSablon: TcxButton
        Left = 187
        Top = 21
        Width = 143
        Height = 25
        Caption = 'E-Posta '#350'ablonlar'#305
        TabOrder = 9
        OnClick = btnMailSablonClick
      end
    end
    object cxTabSheet1: TcxTabSheet
      Caption = 'Durum Ba'#287'lant'#305'lar'#305
      ImageIndex = 19
      object GridDurumBaglanti: TcxGrid
        Left = 0
        Top = 37
        Width = 684
        Height = 456
        Align = alClient
        PopupMenu = PopupDurumBglanti
        TabOrder = 0
        object GridDurumBaglantiDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridDurumBaglantiDBTableView1CanFocusRecord
          DataController.DataSource = DtsDurumBaglanti
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.Indicator = True
          object GridDurumBaglantiDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridDurumBaglantiDBTableView1AKTIF: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'AKTIF'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 32
          end
          object GridDurumBaglantiDBTableView1KAYNAKDURUM: TcxGridDBColumn
            Caption = 'Kaynak'
            DataBinding.FieldName = 'KAYNAKDURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisDurum
            Options.Editing = False
            Options.Focusing = False
            Width = 60
          end
          object GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn
            Caption = 'Hedef'
            DataBinding.FieldName = 'HEDEFDURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisDurum
            Options.Editing = False
            Options.Focusing = False
            Width = 64
          end
          object GridDurumBaglantiDBTableView1UYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (i'#231')'
            DataBinding.FieldName = 'UYARITURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUyariTurleri
            Width = 67
          end
          object GridDurumBaglantiDBTableView1DISUYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (d'#305#351')'
            DataBinding.FieldName = 'DISUYARITURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUyariTurleri
          end
          object GridDurumBaglantiDBTableView1ACILIS: TcxGridDBColumn
            Caption = 'A'#231#305'l'#305#351
            DataBinding.FieldName = 'ACILIS'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 51
          end
          object GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn
            Caption = 'Kapan'#305#351
            DataBinding.FieldName = 'KAPANIS'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Visible = False
            Width = 51
          end
          object GridDurumBaglantiDBTableView1OTOKAPAT: TcxGridDBColumn
            Caption = 'Kaynak Kapat'
            DataBinding.FieldName = 'OTOKAPAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 73
          end
          object GridDurumBaglantiDBTableView1TARIHIDESOR: TcxGridDBColumn
            Caption = 'Tarihe Zorla'
            DataBinding.FieldName = 'TARIHIDESOR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 66
          end
          object GridDurumBaglantiDBTableView1HEDEFALANADI: TcxGridDBColumn
            Caption = 'Hedef Alan'
            DataBinding.FieldName = 'HEDEFALANADI'
            DataBinding.IsNullValueType = True
          end
          object GridDurumBaglantiDBTableView1HEDEFALANDEGERI: TcxGridDBColumn
            Caption = 'Hedef De'#287'er'
            DataBinding.FieldName = 'HEDEFALANDEGERI'
            DataBinding.IsNullValueType = True
          end
        end
        object GridDurumBaglantiLevel1: TcxGridLevel
          GridView = GridDurumBaglantiDBTableView1
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 684
        Height = 37
        Align = alTop
        TabOrder = 1
        object CheckTumListe: TcxCheckBox
          Left = 520
          Top = 7
          Align = alCustom
          Caption = 'T'#252'm Listeyi G'#246'ster'
          TabOrder = 0
          OnClick = CheckTumListeClick
        end
        object ComboTuru: TcxImageComboBox
          Left = 69
          Top = 7
          RepositoryItem = Tablo.repServisTuru
          Properties.Items = <>
          Properties.OnEditValueChanged = ComboTuruPropertiesEditValueChanged
          TabOrder = 1
          Width = 194
        end
        object cxLabel5: TcxLabel
          Left = 3
          Top = 8
          Cursor = crHandPoint
          Hint = 'Servis_Kabul_Sekli'
          HelpType = htKeyword
          HelpKeyword = 'SERVIS.TESLIM_SEKLI'
          Caption = 'Servis T'#252'r'#252
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object CheckTureDurum: TcxCheckBox
          Left = 267
          Top = 6
          Caption = 'Durumlar t'#252're g'#246're ayarlans'#305'n'
          TabOrder = 3
          Transparent = True
          OnClick = CheckTureDurumClick
        end
      end
    end
    object SheetMusteri: TcxTabSheet
      Caption = 'M'#252#351'teri Etkile'#351'imli'
      ImageIndex = 35
      object ComboSenaryo: TcxImageComboBox
        Left = 9
        Top = 36
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Etkile'#351'im Yok'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Kapatma Onay'#305
            Value = 1
          end
          item
            Description = 'De'#287'erlendirme'
            Value = 2
          end
          item
            Description = 'Kapatma Onay'#305'+De'#287'erlendirme'
            Value = 3
          end>
        Properties.OnChange = ComboSenaryoPropertiesChange
        TabOrder = 0
        Width = 359
      end
      object cxLabel11: TcxLabel
        Left = 7
        Top = 13
        Caption = 'Senaryo'
      end
      object MemoSenaryo: TcxMemo
        Left = 9
        Top = 63
        ParentFont = False
        Properties.ReadOnly = True
        Style.Color = clBtnFace
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 2
        Height = 156
        Width = 475
      end
      object Panel2: TPanel
        Left = -9
        Top = 378
        Width = 395
        Height = 73
        BevelOuter = bvNone
        TabOrder = 3
      end
      object PanelOnay: TPanel
        Left = 7
        Top = 212
        Width = 447
        Height = 134
        BevelOuter = bvNone
        TabOrder = 4
        Visible = False
        object cxLabel3: TcxLabel
          Left = 14
          Top = 17
          Caption = '"Evet" Onay'#305'nda Olu'#351'acak Durum'
        end
        object ComboOnayEvetDurum: TcxImageComboBox
          Left = 219
          Top = 13
          RepositoryItem = Tablo.repServisDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 1
          Width = 121
        end
        object cxLabel4: TcxLabel
          Left = 11
          Top = 42
          Caption = '"Hay'#305'r" Onay'#305'nda Olu'#351'acak Durum'
        end
        object ComboOnayHayirDurum: TcxImageComboBox
          Left = 219
          Top = 40
          RepositoryItem = Tablo.repServisDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 3
          Width = 121
        end
        object cxLabel7: TcxLabel
          Left = 11
          Top = 105
          Caption = 'M'#252#351'teri Cevap Vermezse Olu'#351'acak Durum'
        end
        object ComboOnayCevapsizDurum: TcxImageComboBox
          Left = 219
          Top = 103
          RepositoryItem = Tablo.repServisDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 5
          Width = 121
        end
        object cxLabel8: TcxLabel
          Left = 11
          Top = 82
          Caption = 'M'#252#351'teri '#304#231'in Cevap Verme S'#252'resi'
        end
        object cxLabel9: TcxLabel
          Left = 285
          Top = 80
          Caption = 'Saat'
        end
        object EditCevapSure: TcxSpinEdit
          Left = 219
          Top = 76
          TabOrder = 8
          Value = 24
          Width = 60
        end
      end
    end
  end
  object TabDurumBaglanti: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * '
      'from DURUMBAGLANTI '
      'where '
      ' YERI = :PYeri '
      ' and BOLUM= :PBolum'
      ' and AKTIF >=:Akt'
      'order by ACILIS DESC, KAYNAKDURUM,HEDEFDURUM')
    Left = 424
    Top = 104
  end
  object DtsDurumBaglanti: TDataSource
    DataSet = TabDurumBaglanti
    Left = 400
    Top = 160
  end
  object PopupDurumBglanti: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 48
    Top = 208
    object ServisDurumlarnDzenle1: TMenuItem
      Caption = 'Servis Durumlar'#305'n'#305' D'#252'zenle'
      ImageIndex = 7
      OnClick = BtnTakipTurleriClick
    end
    object BalantlarOlutur1: TMenuItem
      Caption = 'Eksik Ba'#287'lant'#305'lar'#305' Olu'#351'tur'
      ImageIndex = 13
      OnClick = BalantlarOlutur1Click
    end
    object KopmuBalantlarTemizle1: TMenuItem
      Caption = 'Kopmu'#351' Ba'#287'lant'#305'lar'#305' Temizle'
      ImageIndex = 9
      OnClick = KopmuBalantlarTemizle1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuTumSec: TMenuItem
      Tag = 1
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ImageIndex = 23
      OnClick = MenuTumSecClick
    end
    object MenuTumBirak: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' B'#305'rak'
      ImageIndex = 15
      OnClick = MenuTumSecClick
    end
    object MenuSecimiTersCevir: TMenuItem
      Tag = 2
      Caption = 'Se'#231'imi Ters '#199'evir'
      ImageIndex = 9
      OnClick = MenuTumSecClick
    end
  end
end

