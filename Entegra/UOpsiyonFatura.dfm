object OpsiyonFaturaDlg: TOpsiyonFaturaDlg
  Left = 0
  Top = 0
  Caption = 'Belge Opsiyonlar'
  ClientHeight = 518
  ClientWidth = 501
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 501
    Height = 492
    ActivePage = TabSheetGenel
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheetGenel: TTabSheet
      Caption = 'Genel'
      OnShow = TabSheetGenelShow
      object Label1: TLabel
        Left = 153
        Top = 77
        Width = 116
        Height = 13
        Caption = 'Fatura Varsay'#305'lan Klasor'
      end
      object Label2: TLabel
        Left = 153
        Top = 121
        Width = 115
        Height = 13
        Caption = 'Sipari'#351' Varsay'#305'lan Klasor'
      end
      object CheckFaturaPlaniOlustur: TcxCheckBox
        Left = 4
        Top = 49
        Caption = 'T'#252'm Faturalara '#214'deme Plan'#305' Olu'#351'turmay'#305' Zorunlu Tut.'
        TabOrder = 0
        Transparent = True
      end
      object cxGroupBox9: TcxGroupBox
        Left = 0
        Top = 0
        Caption = 'Vade Kullan'#305'm'#305
        TabOrder = 1
        Height = 45
        Width = 291
        object rdSatirlaraVade: TcxRadioButton
          Left = 7
          Top = 18
          Width = 113
          Height = 17
          Caption = 'Her sat'#305'rda kullan'
          TabOrder = 0
        end
        object rdBasligaVade: TcxRadioButton
          Left = 146
          Top = 18
          Width = 113
          Height = 17
          Caption = 'Ba'#351'l'#305'kta kullan'
          Checked = True
          TabOrder = 1
          TabStop = True
        end
      end
      object cxGroupBox1: TcxGroupBox
        Left = 4
        Top = 73
        Caption = 'Ondal'#305'k Basamak Say'#305's'#305
        TabOrder = 2
        Height = 90
        Width = 143
        object ComboDijitBr: TcxComboBox
          Left = 90
          Top = 18
          Properties.DropDownListStyle = lsFixedList
          Properties.HideSelection = False
          Properties.Items.Strings = (
            '2'
            '4'
            '6'
            '8')
          Properties.ReadOnly = False
          Properties.OnCloseUp = ComboDijitBrPropertiesCloseUp
          Properties.OnPopup = ComboDijitBrPropertiesPopup
          TabOrder = 0
          Width = 46
        end
        object ComboDijitTut: TcxComboBox
          Left = 90
          Top = 39
          Properties.DropDownListStyle = lsFixedList
          Properties.HideSelection = False
          Properties.Items.Strings = (
            '2'
            '4'
            '6'
            '8')
          Properties.ReadOnly = False
          TabOrder = 1
          Width = 46
        end
        object cxLabel2: TcxLabel
          Left = 3
          Top = 40
          Caption = 'Tutar :'
        end
        object cxLabel1: TcxLabel
          Left = 3
          Top = 19
          Caption = 'Birim Fiyat :'
        end
        object ComboDijitMiktar: TcxComboBox
          Left = 90
          Top = 60
          Properties.DropDownListStyle = lsFixedList
          Properties.HideSelection = False
          Properties.Items.Strings = (
            '2'
            '3'
            '4'
            '5'
            '6')
          Properties.ReadOnly = False
          TabOrder = 4
          Text = '2'
          Width = 46
        end
        object cxLabel10: TcxLabel
          Left = 3
          Top = 62
          Caption = 'Miktar :'
        end
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 153
        Top = 96
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
        TabOrder = 3
        Text = 'VarsayilanKlasor'
        Width = 138
      end
      object VarsayilanKlasorSiparis: TcxButtonEdit
        Left = 153
        Top = 140
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorSiparisPropertiesButtonClick
        TabOrder = 4
        Text = 'VarsayilanKlasor'
        Width = 138
      end
      object chStkVarsKalmayanGoster: TcxCheckBox
        Left = 2
        Top = 169
        Caption = 'Stok eklerken varsay'#305'lan olarak kalmayanlar'#305' da g'#246'ster.'
        TabOrder = 5
        Transparent = True
      end
      object cxGroupBox2: TcxGroupBox
        Left = 9
        Top = 390
        Caption = 'Excel Kolon Bilgileri'
        TabOrder = 6
        Transparent = True
        Height = 72
        Width = 174
        object btnExcelKolon: TcxButton
          Left = 20
          Top = 44
          Width = 124
          Height = 25
          Caption = 'Excel Kolon Ayarla'
          TabOrder = 0
          OnClick = btnExcelKolonClick
        end
        object cxLabel4: TcxLabel
          Left = 3
          Top = 20
          Caption = 'Belge Olu'#351'um '#350'ekli'
          Properties.WordWrap = True
          Transparent = True
          Width = 92
        end
        object cbbelgeOlusturma: TcxImageComboBox
          Left = 101
          Top = 17
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              Description = 'Toplu'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Ayr'#305'k'
              Value = 1
            end>
          TabOrder = 2
          Width = 68
        end
      end
      object BtnIskontoYetki: TcxButton
        Left = 186
        Top = 390
        Width = 110
        Height = 25
        Caption = #304'skonto Yetkileri'
        TabOrder = 7
        Visible = False
        OnClick = BtnIskontoYetkiClick
      end
      object CheckDovizTakibi: TcxCheckBox
        Left = 2
        Top = 190
        Caption = 'Al'#305#351'/Sat'#305#351' Belgelerinde D'#246'vizli Fiyat Bilgisi Bulunsun'
        TabOrder = 8
        Transparent = True
      end
      object cxButton1: TcxButton
        Left = 186
        Top = 414
        Width = 110
        Height = 25
        Caption = 'Mail '#350'ablonu'
        TabOrder = 9
        OnClick = cxButton1Click
      end
      object CheckDonusumGozuksun: TcxCheckBox
        Left = 2
        Top = 211
        Caption = 'D'#246'n'#252#351#252'm bilgileri listelerde g'#246'z'#252'ks'#252'n'
        TabOrder = 10
        Transparent = True
      end
      object TevkifatOranlariTus: TcxButton
        Left = 186
        Top = 438
        Width = 110
        Height = 25
        Caption = 'Tevkifat Oranlar'#305
        TabOrder = 11
        OnClick = TevkifatOranlariTusClick
      end
      object CheckKDVDahil: TcxCheckBox
        Left = 2
        Top = 232
        Caption = 'Fi'#351'lerde '#252'cret girerken otomatik "KDV dahil" i'#351'aretli olsun'
        State = cbsChecked
        TabOrder = 12
        Transparent = True
      end
      object CheckBoxEksiskontoya: TcxCheckBox
        Left = 2
        Top = 253
        Caption = 'Eksi iskontoya izin ver'
        TabOrder = 13
        Transparent = True
      end
      object cxGroupBox3: TcxGroupBox
        Left = 297
        Top = 0
        Caption = 'Bo'#351'luk Kontrolleri'
        TabOrder = 14
        Height = 163
        Width = 185
        object CheckBCBaslik: TcxCheckBox
          Left = 11
          Top = 19
          Caption = 'Ba'#351'l'#305'k'
          TabOrder = 0
          Transparent = True
        end
        object CheckBCAdres: TcxCheckBox
          Left = 11
          Top = 44
          Caption = 'Adres'
          TabOrder = 1
          Transparent = True
        end
        object CheckBCIl: TcxCheckBox
          Left = 11
          Top = 94
          Caption = #304'l'
          TabOrder = 2
          Transparent = True
        end
        object CheckBCIlce: TcxCheckBox
          Left = 11
          Top = 69
          Caption = #304'l'#231'e'
          TabOrder = 3
          Transparent = True
        end
        object CheckBCVNo: TcxCheckBox
          Left = 81
          Top = 44
          Caption = 'Vergi No'
          TabOrder = 4
          Transparent = True
        end
        object CheckBCVD: TcxCheckBox
          Left = 81
          Top = 19
          Caption = 'Vergi Dairesi'
          TabOrder = 5
          Transparent = True
        end
        object CheckBCFiyatAdi: TcxCheckBox
          Left = 81
          Top = 94
          Caption = 'Fiyat Ad'#305
          TabOrder = 6
          Transparent = True
        end
        object CheckBCDepo: TcxCheckBox
          Left = 81
          Top = 69
          Caption = 'Depo'
          TabOrder = 7
          Transparent = True
        end
        object chkVade: TcxCheckBox
          Left = 11
          Top = 118
          Caption = 'Vade'
          TabOrder = 8
          Transparent = True
        end
      end
      object ChkProjeGozuksun: TcxCheckBox
        Left = 2
        Top = 274
        Caption = 'Proje Bilgileri Fatura ve Tahakkukda G'#246'z'#252'ks'#252'n'
        TabOrder = 15
        Transparent = True
      end
      object ChkDemirbasGozuksun: TcxCheckBox
        Left = 2
        Top = 293
        Caption = 'Demirba'#351' Bilgileri Fatura ve Tahakkukda G'#246'z'#252'ks'#252'n'
        TabOrder = 16
        Transparent = True
      end
      object ComboProjeFirsatSec: TcxImageComboBox
        Left = 112
        Top = 362
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
        TabOrder = 17
        Width = 91
      end
      object cxLabel15: TcxLabel
        Left = 7
        Top = 364
        Caption = 'Proje / F'#305'rsat Se'#231'imi'
        Properties.WordWrap = True
        Transparent = True
        Width = 98
      end
      object CheckEnBoy: TcxCheckBox
        Left = 3
        Top = 313
        Caption = 'En x Boy y'#252'zey bilgileri girilebilsin'
        TabOrder = 19
        Transparent = True
      end
      object CheckPozNo: TcxCheckBox
        Left = 6
        Top = 335
        Caption = 'Poz No otomatik versin. Aral'#305'k'
        Style.TransparentBorder = False
        TabOrder = 20
        Transparent = True
      end
      object SpinEditPozNo: TcxSpinEdit
        Left = 172
        Top = 335
        TabOrder = 21
        Value = 10
        Width = 45
      end
      object CheckFaturaHastaSekmesi: TcxCheckBox
        Left = 310
        Top = 339
        Caption = 'Ba'#351'l'#305'kta Hasta Bilgisi Sekmesi'
        Style.TransparentBorder = False
        TabOrder = 22
        Transparent = True
      end
      object cxGroupBox4: TcxGroupBox
        Left = 312
        Top = 389
        Caption = #214'zelkod Giri'#351' Se'#231'imi'
        TabOrder = 23
        Transparent = True
        Height = 72
        Width = 174
        object cxLabel16: TcxLabel
          Left = 5
          Top = 20
          Caption = #214'zelkod 1 '
          Properties.WordWrap = True
          Transparent = True
          Width = 54
        end
        object ComboOzelkod1: TcxImageComboBox
          Left = 57
          Top = 17
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              Description = 'Yaz'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Liste'
              Value = 1
            end>
          Properties.OnChange = ComboOzelkod1PropertiesChange
          TabOrder = 1
          Width = 55
        end
        object ComboOzelkod2: TcxImageComboBox
          Left = 58
          Top = 44
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              Description = 'Yaz'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Liste'
              Value = 1
            end>
          Properties.OnChange = ComboOzelkod2PropertiesChange
          TabOrder = 2
          Width = 55
        end
        object cxLabel17: TcxLabel
          Left = 5
          Top = 47
          Caption = #214'zelkod 2'
          Properties.WordWrap = True
          Transparent = True
          Width = 51
        end
        object BtnOzelkodListe1: TcxButton
          Left = 118
          Top = 15
          Width = 48
          Height = 25
          Caption = 'Liste Gir'
          TabOrder = 4
          OnClick = BtnOzelkodListe1Click
        end
        object BtnOzelkodListe2: TcxButton
          Left = 119
          Top = 42
          Width = 48
          Height = 25
          Caption = 'Liste Gir'
          TabOrder = 5
          OnClick = BtnOzelkodListe2Click
        end
      end
    end
    object GelenFaturaPage: TTabSheet
      Caption = 'Gelen Fatura'
      object GBGelFatListe: TcxGroupBox
        Left = 148
        Top = 172
        Caption = 'Listeleri Ayarlama'
        TabOrder = 0
        Height = 154
        Width = 137
        object cxButtonEdit1: TcxButtonEdit
          Left = 32
          Top = 64
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          TabOrder = 0
          Text = 'cxButtonEdit1'
          Width = 121
        end
      end
      object GBGelFatDetay: TcxGroupBox
        Left = 147
        Top = 3
        Caption = 'Detay'
        TabOrder = 1
        Height = 158
        Width = 137
      end
      object cxGroupBox5: TcxGroupBox
        Left = 3
        Top = 3
        Caption = 'Gelen Fatura Ek Alanlar'#305
        TabOrder = 2
        Height = 159
        Width = 134
        object GelenFaturaDetaySablonList: TcxListBox
          Left = 2
          Top = 45
          Width = 130
          Height = 112
          Align = alClient
          ItemHeight = 16
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          OnClick = GelenFaturaDetaySablonListClick
        end
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 5
          Top = 21
          Width = 124
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          List = True
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Transparent = True
          object GelenFaturaDetaySablonEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Projeye Ba'#287'la'
            ImageIndex = 0
            OnClick = GelenFaturaDetaySablonEkleTusClick
          end
          object GelenFaturaDetayDuzeltTus: TToolButton
            Left = 23
            Top = 0
            Caption = 'GelenFaturaDetayDuzeltTus'
            ImageIndex = 7
            OnClick = GelenFaturaDetayDuzeltTusClick
          end
          object GelenFaturaDetaySilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'ToolButton1'
            ImageIndex = 1
            OnClick = GelenFaturaDetaySilTusClick
          end
        end
      end
      object cxGroupBox7: TcxGroupBox
        Left = 3
        Top = 171
        Caption = 'Gelen Sipari'#351' Ek Alanlar'#305
        TabOrder = 3
        Height = 154
        Width = 134
        object GelenSiparisDetaySablonList: TcxListBox
          Left = 2
          Top = 45
          Width = 130
          Height = 107
          Align = alClient
          ItemHeight = 16
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          OnClick = GelenSiparisDetaySablonListClick
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 5
          Top = 21
          Width = 124
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          List = True
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Transparent = True
          object GelenSiparisDetaySablonEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Projeye Ba'#287'la'
            ImageIndex = 0
            OnClick = GelenSiparisDetaySablonEkleTusClick
          end
          object GelenSiparisDetaySablonDuzenleTus: TToolButton
            Left = 23
            Top = 0
            Caption = 'GelenFaturaDetayDuzeltTus'
            ImageIndex = 7
            OnClick = GelenSiparisDetaySablonDuzenleTusClick
          end
          object GelenSiparisDetaySablonSilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'ToolButton1'
            ImageIndex = 1
            OnClick = GelenSiparisDetaySablonSilTusClick
          end
        end
      end
      object cxLabel11: TcxLabel
        Left = 2
        Top = 341
        Caption = 'S.Meslek Stopaj'#305' Hesab'#305
      end
      object EditSerbestMeslek: TcxTextEdit
        Left = 147
        Top = 340
        TabOrder = 5
        Width = 138
      end
      object cxLabel3: TcxLabel
        Left = 2
        Top = 363
        Caption = 'Kira Stopaj'#305' Hesab'#305
      end
      object EditKira: TcxTextEdit
        Left = 147
        Top = 362
        TabOrder = 7
        Width = 138
      end
      object cxLabel13: TcxLabel
        Left = 2
        Top = 385
        Caption = 'Gider Pusulas'#305' Stopaj'#305' Hesab'#305
      end
      object EditGiderPusulasi: TcxTextEdit
        Left = 148
        Top = 384
        TabOrder = 9
        Width = 138
      end
    end
    object GidenFaturaPage: TTabSheet
      Caption = 'Giden Fatura'
      ImageIndex = 1
      object GBGidFatListe: TcxGroupBox
        Left = 147
        Top = 168
        Caption = 'Listeleri Ayarlama'
        TabOrder = 0
        Height = 161
        Width = 137
        object GridListeDuzenle: TcxGrid
          Left = 2
          Top = 18
          Width = 133
          Height = 141
          Align = alClient
          TabOrder = 0
          object GridListeDuzenleDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridListeDuzenleDBTableView1CellDblClick
            DataController.DataSource = DtsListeDuzenle
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.InvertSelect = False
            OptionsView.GroupByBox = False
            object GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn
              Caption = 'B'#246'l'#252'm'
              DataBinding.FieldName = 'ANAHTAR'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object GridListeDuzenleLevel1: TcxGridLevel
            GridView = GridListeDuzenleDBTableView1
          end
        end
      end
      object GBGidFatDetay: TcxGroupBox
        Left = 147
        Top = 3
        Caption = 'Detay'
        TabOrder = 1
        Height = 161
        Width = 137
        object GridListeDetayDuzenle: TcxGrid
          Left = 2
          Top = 18
          Width = 133
          Height = 141
          Align = alClient
          TabOrder = 0
          object GridListeDetayDuzenleTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridListeDetayDuzenleTableView1CellDblClick
            DataController.DataSource = DtsTabListeDetayDuzenle
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.InvertSelect = False
            OptionsView.GroupByBox = False
            object cxGridDBColumn1: TcxGridDBColumn
              Caption = 'B'#246'l'#252'm'
              DataBinding.FieldName = 'ANAHTAR'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object cxGridDBColumn2: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridListeDetayDuzenleTableView1
          end
        end
      end
      object cxGroupBox6: TcxGroupBox
        Left = 5
        Top = 3
        Caption = 'Giden Fatura Ek Alanlar'#305
        TabOrder = 2
        Height = 161
        Width = 134
        object GidenFaturaDetaySablonList: TcxListBox
          Left = 2
          Top = 45
          Width = 130
          Height = 114
          Align = alClient
          ItemHeight = 16
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          OnClick = GidenFaturaDetaySablonListClick
        end
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 5
          Top = 21
          Width = 124
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          List = True
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Transparent = True
          object GidenFaturaDetayEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Projeye Ba'#287'la'
            ImageIndex = 0
            OnClick = GidenFaturaDetayEkleTusClick
          end
          object GidenFaturaDetayDuzeltTus: TToolButton
            Left = 23
            Top = 0
            Caption = 'ToolButton4'
            ImageIndex = 7
            OnClick = GidenFaturaDetayDuzeltTusClick
          end
          object GidenFaturaDetaySilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'ToolButton1'
            ImageIndex = 1
            OnClick = GidenFaturaDetaySilTusClick
          end
        end
      end
      object cxGroupBox8: TcxGroupBox
        Left = 4
        Top = 169
        Caption = 'Giden Sipari'#351' Ek Alanlar'#305
        TabOrder = 3
        Height = 160
        Width = 134
        object GidenSiparisDetaySablonList: TcxListBox
          Left = 2
          Top = 45
          Width = 130
          Height = 113
          Align = alClient
          ItemHeight = 16
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          OnClick = GidenSiparisDetaySablonListClick
        end
        object ToolBar4: TToolBar
          AlignWithMargins = True
          Left = 5
          Top = 21
          Width = 124
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          List = True
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Transparent = True
          object GidenSiparisDetaySablonEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Projeye Ba'#287'la'
            ImageIndex = 0
            OnClick = GidenSiparisDetaySablonEkleTusClick
          end
          object GidenSiparisDetaySablonDuzeltTus: TToolButton
            Left = 23
            Top = 0
            Caption = 'ToolButton4'
            ImageIndex = 7
            OnClick = GidenSiparisDetaySablonDuzeltTusClick
          end
          object GidenSiparisDetaySablonSilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'ToolButton1'
            ImageIndex = 1
            OnClick = GidenSiparisDetaySablonSilTusClick
          end
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'E-Belge'
      ImageIndex = 3
      OnShow = TabSheetEBelgeShow
      object cxPageControl1: TcxPageControl
        Left = 0
        Top = 0
        Width = 493
        Height = 464
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = TabGenel
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 8
        ClientRectBottom = 464
        ClientRectRight = 493
        ClientRectTop = 24
        object TabGenel: TcxTabSheet
          Caption = 'Genel'
          ImageIndex = 0
          object GroupEFaturaBag: TcxGroupBox
            Left = 3
            Top = 71
            Caption = 'Ba'#287'lant'#305
            TabOrder = 0
            Height = 101
            Width = 475
            object cxLabel5: TcxLabel
              Left = 4
              Top = 19
              Caption = 'Entegrat'#246'r  '
              Transparent = True
            end
            object Entegrator: TcxTextEdit
              Left = 96
              Top = 18
              TabOrder = 1
              Text = #304'zibiz'
              Width = 289
            end
            object cxLabel7: TcxLabel
              Left = 4
              Top = 45
              Caption = 'Kullan'#305'c'#305
              Transparent = True
            end
            object EditEnt_Kullanici: TcxTextEdit
              Left = 96
              Top = 44
              TabOrder = 3
              Text = 'gentegre'
              Width = 289
            end
            object cxLabel8: TcxLabel
              Left = 4
              Top = 72
              Caption = #350'ifre'
              Transparent = True
            end
            object EditEnt_Sifre: TcxTextEdit
              Left = 96
              Top = 71
              Cursor = crHandPoint
              Properties.EchoMode = eemPassword
              TabOrder = 5
              Text = 'gen321'
              Width = 289
            end
            object CheckTestAktif: TcxCheckBox
              Left = 393
              Top = 20
              Caption = 'Test'
              State = cbsChecked
              Style.TransparentBorder = False
              TabOrder = 6
              Transparent = True
            end
            object EditEnt_KullaniciTest: TcxTextEdit
              Left = 391
              Top = 43
              TabOrder = 7
              Text = 'izibiz-test2'
              Width = 77
            end
            object EditEnt_SifreTest: TcxTextEdit
              Left = 391
              Top = 70
              Properties.EchoMode = eemPassword
              TabOrder = 8
              Text = 'izi321'
              Width = 77
            end
          end
          object cxLabel14: TcxLabel
            Left = 9
            Top = 44
            Caption = 'Vergi / Kimlik No'
            Transparent = True
          end
          object EditVergiNo: TcxTextEdit
            Left = 99
            Top = 44
            TabOrder = 2
            Text = '4840847211'
            Width = 289
          end
          object ChecEFatKullanimda: TcxCheckBox
            Left = 20
            Top = 15
            Caption = 'E-Fatura Aktif'
            Style.TransparentBorder = False
            TabOrder = 3
            Transparent = True
          end
          object EFaturaDB: TcxTextEdit
            Left = 111
            Top = 3
            TabOrder = 4
            Visible = False
            Width = 75
          end
          object ButtonSQLBaslik: TcxButton
            Left = 194
            Top = 13
            Width = 139
            Height = 25
            Caption = 'Ba'#351'l'#305'k SQL Sorgusu'
            TabOrder = 5
          end
          object ButtonSQLDetay: TcxButton
            Left = 339
            Top = 13
            Width = 139
            Height = 25
            Caption = 'Detay SQL Sorgusu'
            TabOrder = 6
          end
          object cxGroupBox10: TcxGroupBox
            Left = 3
            Top = 178
            Caption = 'XSLT Listesi'
            TabOrder = 7
            Height = 255
            Width = 475
            object GridXSLT: TcxGrid
              Left = 2
              Top = 41
              Width = 471
              Height = 212
              Align = alClient
              TabOrder = 0
              object GridXSLTView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                Navigator.Buttons.Insert.Visible = True
                Navigator.Buttons.Append.Visible = False
                Navigator.Buttons.Delete.Visible = True
                Navigator.Buttons.Edit.Visible = True
                Navigator.Buttons.Post.Visible = True
                Navigator.Buttons.Cancel.Visible = True
                Navigator.Visible = True
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsXSLT
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsSelection.InvertSelect = False
                OptionsView.GroupByBox = False
                object GridXSLTViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 33
                end
                object GridXSLTViewRAPORID: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'RAPORID'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'E-Fatura Gelen'
                      ImageIndex = 0
                      Value = 1
                    end
                    item
                      Description = 'E-Fatura Giden'
                      Value = 2
                    end
                    item
                      Description = 'E-Ar'#351'iv Gelen'
                      Value = 11
                    end
                    item
                      Description = 'E-Ar'#351'iv Giden'
                      Value = 12
                    end
                    item
                      Description = 'Ei'#304'rsaliye Gelen'
                      Value = 51
                    end
                    item
                      Description = 'E-'#304'rsaliye Giden'
                      Value = 52
                    end>
                end
                object GridXSLTViewRAPORADI: TcxGridDBColumn
                  Caption = 'Ad'#305
                  DataBinding.FieldName = 'RAPORADI'
                  DataBinding.IsNullValueType = True
                  Width = 244
                end
                object GridXSLTViewVERSIYON: TcxGridDBColumn
                  Caption = 'Versiyon'
                  DataBinding.FieldName = 'VERSIYON'
                  DataBinding.IsNullValueType = True
                  Width = 38
                end
                object GridXSLTViewSQL: TcxGridDBColumn
                  Caption = #304#231'erik'
                  DataBinding.FieldName = 'SQL'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = True
                  Properties.OnButtonClick = GridXSLTViewSQLPropertiesButtonClick
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = GridXSLTView
              end
            end
            object Panel3: TPanel
              Left = 2
              Top = 18
              Width = 471
              Height = 23
              Align = alTop
              BevelOuter = bvNone
              ParentBackground = False
              TabOrder = 1
              object LabelXSLTYukle: TcxLabel
                Left = 334
                Top = 4
                Cursor = crHandPoint
                Caption = 'Dosyadan XSLT Y'#252'kle'
                Style.TextStyle = [fsBold]
                OnClick = LabelXSLTYukleClick
              end
              object LabelXSLTKaydet: TcxLabel
                Left = 10
                Top = 3
                Cursor = crHandPoint
                Caption = 'XSLT yi Dosyaya Kaydet'
                Style.TextStyle = [fsBold]
              end
            end
          end
        end
        object TabSeri: TcxTabSheet
          Caption = 'Seri Bilgileri'
          ImageIndex = 5
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object GridEFaturaSeriKurallari: TcxGrid
            Left = 3
            Top = 47
            Width = 650
            Height = 352
            TabOrder = 0
            object GridEFaturaSeriKurallariView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Visible = True
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsEFaturaSeriKurallari
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Appending = True
              OptionsView.GroupByBox = False
              object GridEFaturaSeriKurallariViewBOLUM: TcxGridDBColumn
                Caption = 'E-Belge T'#252'r'#252
                DataBinding.FieldName = 'BOLUM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'E-Fatura'
                    Value = -24130
                  end
                  item
                    Description = 'E-Ar'#351'iv'
                    Value = -24131
                  end
                  item
                    Description = 'E-'#304'rsaliye'
                    Value = -24133
                  end>
                Width = 110
              end
              object GridEFaturaSeriKurallariViewANAHTAR: TcxGridDBColumn
                Caption = 'Seri'
                DataBinding.FieldName = 'SERI'
                DataBinding.IsNullValueType = True
                Width = 47
              end
              object GridEFaturaSeriKurallariViewDEGER: TcxGridDBColumn
                Caption = 'Senaryo'
                DataBinding.FieldName = 'SENARYO'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                Width = 116
              end
              object GridEFaturaSeriKurallariViewKULLANICI: TcxGridDBColumn
                Caption = 'Kullan'#305'c'#305
                DataBinding.FieldName = 'KULLANICI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end
                  item
                  end>
                Properties.OnButtonClick = GridEFaturaSeriKurallariViewKULLANICIPropertiesButtonClick
                Width = 160
              end
              object GridEFaturaSeriKurallariViewONCELIK: TcxGridDBColumn
                Caption = 'S'#305'ra'
                DataBinding.FieldName = 'SIRA'
                DataBinding.IsNullValueType = True
                Width = 40
              end
            end
            object GridEFaturaSeriKurallariLevel: TcxGridLevel
              GridView = GridEFaturaSeriKurallariView
            end
          end
        end
        object TabAlanEsleme: TcxTabSheet
          Caption = 'Alan E'#351'le'#351'tirme'
          ImageIndex = 6
          TabVisible = False
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PanelAlanEslemeSag: TPanel
            Left = 0
            Top = 0
            Width = 493
            Height = 29
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object BtnAlanEslemeDoldur: TcxButton
              Left = 1
              Top = 1
              Width = 104
              Height = 25
              Caption = 'Alan Doldur'
              TabOrder = 0
              OnClick = BtnAlanEslemeDoldurClick
            end
          end
          object GridAlanEsleme: TcxGrid
            Left = 0
            Top = 29
            Width = 493
            Height = 411
            Align = alClient
            TabOrder = 0
            object GridAlanEslemeView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              Navigator.Visible = True
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Appending = True
              OptionsView.GroupByBox = False
              object GridAlanEslemeViewBELGETURU: TcxGridDBColumn
                Caption = 'Belge T'#252'r'#252
                DataBinding.FieldName = 'BELGETURU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'E-Fatura'
                    Value = 1
                  end
                  item
                    Description = 'E-Ar'#351'iv'
                    Value = 2
                  end
                  item
                    Description = 'E-'#304'rsaliye'
                    Value = 7
                  end>
                Width = 90
              end
              object GridAlanEslemeViewSENARYO: TcxGridDBColumn
                Caption = 'Senaryo'
                DataBinding.FieldName = 'SENARYO'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                Width = 110
              end
              object GridAlanEslemeViewCARIOZELKOD: TcxGridDBColumn
                Caption = 'Cari '#214'zel Kod'
                DataBinding.FieldName = 'CARIOZELKOD'
                DataBinding.IsNullValueType = True
                Width = 90
              end
              object GridAlanEslemeViewALANTIPI: TcxGridDBColumn
                Caption = 'Alan Tipi'
                DataBinding.FieldName = 'ALANTIPI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Standart'
                    Value = 'Stn'
                  end
                  item
                    Description = 'Ek'
                    Value = 'Ek'
                  end>
                Width = 70
              end
              object GridAlanEslemeViewUBLALAN: TcxGridDBColumn
                Caption = 'UBL Alan'#305
                DataBinding.FieldName = 'UBLALAN'
                DataBinding.IsNullValueType = True
                Width = 160
              end
              object GridAlanEslemeViewKAYNAK: TcxGridDBColumn
                Caption = 'Kaynak'
                DataBinding.FieldName = 'KAYNAK'
                DataBinding.IsNullValueType = True
                Width = 170
              end
              object GridAlanEslemeViewVARSAYILAN: TcxGridDBColumn
                Caption = 'Varsay'#305'lan'
                DataBinding.FieldName = 'VARSAYILAN'
                DataBinding.IsNullValueType = True
                Width = 170
              end
              object GridAlanEslemeViewAKTIF: TcxGridDBColumn
                Caption = 'Aktif'
                DataBinding.FieldName = 'AKTIF'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Width = 45
              end
              object GridAlanEslemeViewSIRA: TcxGridDBColumn
                Caption = 'S'#305'ra'
                DataBinding.FieldName = 'SIRA'
                DataBinding.IsNullValueType = True
                Width = 45
              end
            end
            object GridAlanEslemeLevel: TcxGridLevel
              GridView = GridAlanEslemeView
            end
          end
        end
        object TabEFatura: TcxTabSheet
          Caption = 'E-Fatura'
          ImageIndex = 1
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckIhracatGonderilsin: TcxCheckBox
            Left = 16
            Top = 410
            Caption = #304'hracat Faturalar'#305' da G'#246'nderilsin'
            Style.TransparentBorder = False
            TabOrder = 0
            Transparent = True
          end
          object cxLabel9: TcxLabel
            Left = 14
            Top = 136
            Caption = 'Varsay'#305'lan Senaryo'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 96
          end
          object ComboSENARYO: TcxImageComboBox
            Left = 121
            Top = 134
            Properties.Alignment.Horz = taLeftJustify
            Properties.ImageAlign = iaRight
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                Description = 'Temel'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Ticari'
                Value = 2
              end
              item
                Description = #304'la'#231'_T'#305'bbiCihaz'
                Value = 8
              end>
            Style.Color = clWhite
            TabOrder = 2
            Width = 197
          end
          object ComboEFaturaXSLT: TcxImageComboBox
            Tag = 2
            Left = 122
            Top = 214
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 3
            Width = 197
          end
          object cxLabel18: TcxLabel
            Left = 15
            Top = 216
            Caption = 'Giden E-Fatura XSLT'
            Properties.WordWrap = True
            Transparent = True
            Width = 102
          end
          object cxLabel22: TcxLabel
            Left = 16
            Top = 302
            Caption = 'Sabit Notlar'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 60
          end
          object MemoEFaturaNotlar: TcxMemo
            Left = 121
            Top = 302
            Lines.Strings = (
              '{ACIKLAMA}'
              '{ACIKLAMA2}'
              'Yaln'#305'z {PaymentTotalAsText}'
              #304'RSAL'#304'YE YER'#304'NE GE'#199'ER.')
            TabOrder = 6
            Height = 89
            Width = 343
          end
          object cxLabel6: TcxLabel
            Left = 15
            Top = 63
            Caption = 'Test Servis URL'
            Transparent = True
          end
          object URLEFaturaTest: TcxTextEdit
            Left = 121
            Top = 62
            TabOrder = 8
            Text = 'https://portaltest.izibiz.com.tr/'
            Width = 356
          end
          object cxLabel26: TcxLabel
            Left = 15
            Top = 93
            Caption = #220'retim Servis URL'
            Transparent = True
          end
          object URLEFaturaUretim: TcxTextEdit
            Left = 121
            Top = 92
            TabOrder = 10
            Text = 'https://efaturaws.izibiz.com.tr/EInvoiceWS'
            Width = 356
          end
          object cxLabel12: TcxLabel
            Left = 15
            Top = 192
            Caption = 'Gelen E-Fatura XSLT'
            Properties.WordWrap = True
            Transparent = True
            Width = 102
          end
          object ComboGelenXSLT: TcxImageComboBox
            Tag = 1
            Left = 122
            Top = 190
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 15
            Width = 197
          end
          object ComboCariKod: TcxComboBox
            Left = 122
            Top = 262
            Properties.DropDownListStyle = lsFixedList
            Properties.HideSelection = False
            Properties.Items.Strings = (
              '2'
              '4'
              '6'
              '8')
            Properties.ReadOnly = False
            Properties.OnCloseUp = ComboDijitBrPropertiesCloseUp
            Properties.OnPopup = ComboDijitBrPropertiesPopup
            TabOrder = 12
            Width = 197
          end
          object cxLabel44: TcxLabel
            Left = 15
            Top = 263
            Caption = 'Cari Eklerken Kod'
            Transparent = True
          end
          object CheckGelenEFaturaAl: TcxCheckBox
            Left = 122
            Top = 31
            Caption = 'Gelen Faturay'#305' Al'
            Style.TransparentBorder = False
            TabOrder = 13
            Transparent = True
          end
        end
        object TabEArsivFatura: TcxTabSheet
          Caption = 'E-Ar'#351'iv Fatura'
          ImageIndex = 2
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckEArsivFaturaAktif: TcxCheckBox
            Left = 113
            Top = 35
            Caption = 'Gelen E-Ar'#351'ivi Al'
            Style.TransparentBorder = False
            TabOrder = 0
            Transparent = True
          end
          object ComboEArsivFaturaXSLT: TcxImageComboBox
            Tag = 12
            Left = 113
            Top = 209
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 1
            Width = 197
          end
          object cxLabel19: TcxLabel
            Left = 16
            Top = 211
            Caption = 'Giden E-Ar'#351'iv XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 94
          end
          object MemoEArsivFaturaNotlar: TcxMemo
            Left = 113
            Top = 277
            Lines.Strings = (
              '{ACIKLAMA}'
              '{ACIKLAMA2}'
              'Yaln'#305'z {PaymentTotalAsText}'
              #304'RSAL'#304'YE YER'#304'NE GE'#199'ER.')
            TabOrder = 3
            Height = 89
            Width = 356
          end
          object cxLabel23: TcxLabel
            Left = 16
            Top = 277
            Caption = 'Sabit Notlar'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 60
          end
          object cxLabel27: TcxLabel
            Left = 16
            Top = 67
            Caption = 'Test Giden URL'
            Transparent = True
          end
          object URLEArsivFaturaTest: TcxTextEdit
            Left = 113
            Top = 66
            TabOrder = 6
            Text = 'https://efaturatest.izibiz.com.tr/EIArchiveWS/EFaturaArchive'
            Width = 356
          end
          object cxLabel28: TcxLabel
            Left = 16
            Top = 97
            Caption = #220'retim Giden URL'
            Transparent = True
          end
          object URLEArsivUretim: TcxTextEdit
            Left = 113
            Top = 96
            TabOrder = 8
            Text = 'https://earsivws.izibiz.com.tr/EIArchiveWS/EFaturaArchive'
            Width = 356
          end
          object ComboGelenEArsivXSLT: TcxImageComboBox
            Tag = 11
            Left = 112
            Top = 185
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 12
            Width = 197
          end
          object cxLabel33: TcxLabel
            Left = 15
            Top = 187
            Caption = 'Gelen E-Ar'#351'iv XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 94
          end
          object cxLabel45: TcxLabel
            Left = 15
            Top = 126
            Caption = #220'retim Gelen URL'
            Transparent = True
          end
          object URLEArsivGelen: TcxTextEdit
            Left = 112
            Top = 125
            TabOrder = 9
            Text = 'https://api.izibiz.com.tr/v1/earchives-gib-ivd/inbox/GIB'
            Width = 356
          end
        end
        object TabESMM: TcxTabSheet
          Caption = 'E-SMM'
          ImageIndex = 3
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckESMMAktif: TcxCheckBox
            Left = 119
            Top = 24
            Caption = 'Aktif'
            Style.TransparentBorder = False
            TabOrder = 0
            Transparent = True
          end
          object ComboESMMXSLT: TcxImageComboBox
            Tag = 32
            Left = 119
            Top = 164
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 1
            Width = 197
          end
          object cxLabel20: TcxLabel
            Left = 17
            Top = 165
            Caption = 'Giden E-SMM XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 92
          end
          object MemoESMMNotlar: TcxMemo
            Left = 118
            Top = 230
            Lines.Strings = (
              '{ACIKLAMA}'
              '{ACIKLAMA2}'
              'Yaln'#305'z {PaymentTotalAsText}'
              #304'RSAL'#304'YE YER'#304'NE GE'#199'ER.')
            TabOrder = 3
            Height = 89
            Width = 354
          end
          object cxLabel24: TcxLabel
            Left = 17
            Top = 230
            Caption = 'Sabit Notlar'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 60
          end
          object cxLabel29: TcxLabel
            Left = 17
            Top = 60
            Caption = 'Test Servis URL'
            Transparent = True
          end
          object URLESMMTest: TcxTextEdit
            Left = 119
            Top = 59
            TabOrder = 6
            Text = 'https://efaturatest.izibiz.com.tr/SmmWS'
            Width = 356
          end
          object cxLabel30: TcxLabel
            Left = 17
            Top = 90
            Caption = #220'retim Servis URL'
            Transparent = True
          end
          object URLESMMUretim: TcxTextEdit
            Left = 119
            Top = 89
            TabOrder = 8
            Text = 'https://smmws.izibiz.com.tr/SmmWS'
            Width = 356
          end
          object ComboGidenESMMXSLT: TcxImageComboBox
            Tag = 31
            Left = 119
            Top = 140
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 9
            Width = 197
          end
          object cxLabel42: TcxLabel
            Left = 17
            Top = 141
            Caption = 'Giden E-SMM XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 92
          end
        end
        object TabEIrsaliye: TcxTabSheet
          Caption = 'E-'#304'rsaliye'
          ImageIndex = 4
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckEIrsaliyeAktif: TcxCheckBox
            Left = 122
            Top = 13
            Caption = 'E-'#304'rsaliyeyi Aktif'
            Style.TransparentBorder = False
            TabOrder = 0
            Transparent = True
          end
          object ComboEIrsaliyeXSLT: TcxImageComboBox
            Tag = 52
            Left = 122
            Top = 204
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 1
            Width = 197
          end
          object cxLabel21: TcxLabel
            Left = 17
            Top = 205
            Caption = 'Giden E-'#304'rsaliye XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 105
          end
          object MemoEIrsaliyeNotlar: TcxMemo
            Left = 122
            Top = 268
            Lines.Strings = (
              '{ACIKLAMA}'
              '{ACIKLAMA2}'
              'Yaln'#305'z {PaymentTotalAsText}'
              #304'RSAL'#304'YE YER'#304'NE GE'#199'ER.')
            TabOrder = 3
            Height = 89
            Width = 355
          end
          object cxLabel25: TcxLabel
            Left = 16
            Top = 243
            Caption = 'Sabit Notlar'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 60
          end
          object cxLabel31: TcxLabel
            Left = 16
            Top = 60
            Caption = 'Test Servis URL'
            Transparent = True
          end
          object URLEIrsaliyeTest: TcxTextEdit
            Left = 121
            Top = 59
            TabOrder = 6
            Text = 'https://efaturatest.izibiz.com.tr/EIrsaliyeWS/EIrsaliye'
            Width = 356
          end
          object cxLabel32: TcxLabel
            Left = 16
            Top = 90
            Caption = #220'retim Servis URL'
            Transparent = True
          end
          object URLEIrsaliyeUretim: TcxTextEdit
            Left = 121
            Top = 89
            TabOrder = 8
            Text = 'https://eirsaliyews.izibiz.com.tr/EIrsaliyeWS/EIrsaliye'
            Width = 356
          end
          object LblEIrsaliyeGIBAlias: TcxLabel
            Left = 16
            Top = 125
            Hint = 'G'#304'B Portal Adresi'
            Caption = 'G'#304'B Portal Adresi'
            ParentShowHint = False
            ShowHint = True
            Transparent = True
          end
          object EditEIrsaliyeGIBAlias: TcxTextEdit
            Left = 121
            Top = 122
            TabOrder = 9
            Text = 'irsaliyepk@gib.gov.tr'
            Width = 356
          end
          object ComboGelenEIrsaliyeXSLT: TcxImageComboBox
            Tag = 51
            Left = 122
            Top = 180
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            Properties.OnPopup = ComboXSLTPropertiesPopup
            Style.Color = clWhite
            TabOrder = 11
            Width = 197
          end
          object cxLabel43: TcxLabel
            Left = 17
            Top = 181
            Caption = 'Gelen E-'#304'rsaliye XSLT'
            FocusControl = ComboSENARYO
            Properties.WordWrap = True
            Transparent = True
            Width = 105
          end
          object CheckGelenEIrsaliyeyiAl: TcxCheckBox
            Left = 121
            Top = 36
            Caption = 'Gelen E-'#304'rsaliyeyi Al'
            Style.TransparentBorder = False
            TabOrder = 13
            Transparent = True
          end
        end
      end
    end
    object SheetSiparis: TTabSheet
      Caption = 'Sipari'#351
      ImageIndex = 4
      object PCSiparis: TcxPageControl
        Left = 0
        Top = 73
        Width = 493
        Height = 391
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = SheetAlinanSip
        Properties.CustomButtons.Buttons = <>
        OnPageChanging = PCSiparisPageChanging
        ClientRectBottom = 387
        ClientRectLeft = 4
        ClientRectRight = 489
        ClientRectTop = 24
        object SheetAlinanSip: TcxTabSheet
          Tag = 19
          Caption = 'Al'#305'nan Sipari'#351' Durum Ba'#287'lant'#305'lar'#305
          ImageIndex = 0
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object GridDurumBaglanti: TcxGrid
            Left = 0
            Top = 0
            Width = 485
            Height = 363
            Align = alClient
            PopupMenu = PopupDurumBglanti
            TabOrder = 0
            object GridDurumBaglantiDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsDurumBaglanti
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
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
                RepositoryItem = Tablo.repTeklifDurumu
                Options.Editing = False
                Options.Focusing = False
                Width = 66
              end
              object GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn
                Caption = 'Hedef'
                DataBinding.FieldName = 'HEDEFDURUM'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.repTeklifDurumu
                Options.Editing = False
                Options.Focusing = False
                Width = 72
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
                Width = 51
              end
              object GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn
                Caption = 'Kapan'#305#351
                DataBinding.FieldName = 'KAPANIS'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
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
                Width = 83
              end
            end
            object GridDurumBaglantiLevel1: TcxGridLevel
              GridView = GridDurumBaglantiDBTableView1
            end
          end
        end
        object SheetVerilenSip: TcxTabSheet
          Tag = 9
          Caption = 'Verilen Sipari'#351' Durum Ba'#287'lant'#305'lar'#305
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 493
        Height = 73
        Align = alTop
        TabOrder = 1
        object AlSiparisTus: TcxButton
          Left = 292
          Top = 11
          Width = 165
          Height = 25
          Caption = 'Al'#305'nan Sipari'#351' Durumlar'
          TabOrder = 0
          OnClick = AlSiparisTusClick
        end
        object VerSiparisTus: TcxButton
          Left = 292
          Top = 42
          Width = 165
          Height = 25
          Caption = 'Verilen Sipari'#351' Durumlar'
          TabOrder = 1
          OnClick = VerSiparisTusClick
        end
        object CheckSiparisHastaSekmesi: TcxCheckBox
          Left = 22
          Top = 11
          Caption = 'Ba'#351'l'#305'kta Hasta Bilgisi Sekmesi'
          Style.TransparentBorder = False
          TabOrder = 2
          Transparent = True
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 492
    Width = 501
    Height = 26
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 255
      Top = 0
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
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 176
      Top = 0
      Width = 73
      Height = 26
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
  object TabListeDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from GENINI where BOLUM=0 and DIL=:PDil and LEN(ABS(DEG' +
        'ER))=4 and DEGER like '#39'-21__'#39' and ANAHTAR like :PAnahtar+'#39'%'#39' '
      '')
    Left = 332
    Top = 208
  end
  object DtsListeDuzenle: TDataSource
    DataSet = TabListeDuzenle
    Left = 308
    Top = 29
  end
  object TabListeDetayDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from GENINI where BOLUM=0 and DIL=:PDil and LEN(ABS(DEG' +
        'ER))=4 and DEGER like '#39'-21__'#39' and ANAHTAR like :PAnahtar+'#39'%'#39' '
      '')
    Left = 258
    Top = 185
  end
  object DtsTabListeDetayDuzenle: TDataSource
    DataSet = TabListeDetayDuzenle
    Left = 483
    Top = 272
  end
  object TabDurumBaglanti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from DURUMBAGLANTI where YERI = :PYeri and BOLUM= :PBol' +
        'um'
      'order by ACILIS DESC, KAYNAKDURUM,HEDEFDURUM')
    Left = 408
    Top = 8
  end
  object DtsDurumBaglanti: TDataSource
    DataSet = TabDurumBaglanti
    Left = 64
    Top = 96
  end
  object TabEFaturaSeriKurallari: TFDQuery
    AfterOpen = TabEFaturaSeriKurallariAfterOpen
    BeforePost = TabEFaturaSeriKurallariBeforePost
    OnNewRecord = TabEFaturaSeriKurallariNewRecord
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'GENINI'
    UpdateOptions.KeyFields = 'BOLUM;DEGER;DIL'
    SQL.Strings = (
      'select *,'
      'BELGETURU=case BOLUM'
      ' when -24130 then '#39'E-Fatura'#39
      ' when -24131 then '#39'E-Ar'#351'iv'#39
      ' when -24133 then '#39'E-'#304'rsaliye'#39
      ' else '#39#39' end,'
      'SERI=left(ANAHTAR, charindex('#39','#39', ANAHTAR+'#39','#39')-1),'
      'SENARYO=try_convert(int, parsename(replace(ANAHTAR,'#39','#39','#39'.'#39'),2)),'
      
        'KULLANICIID=try_convert(int, parsename(replace(ANAHTAR,'#39','#39','#39'.'#39'),' +
        '1))'
      'from GENINI'
      'where BOLUM in (-24130,-24131,-24133) and DIL=-1'
      'order by BOLUM, SIRA, ANAHTAR')
    Left = 584
    Top = 96
  end
  object DtsEFaturaSeriKurallari: TDataSource
    DataSet = TabEFaturaSeriKurallari
    Left = 704
    Top = 96
  end
  object PopupDurumBglanti: TPopupMenu
    Left = 464
    Top = 24
    object ServisDurumlarnDzenle1: TMenuItem
      Caption = 'Servis Durumlar'#305'n'#305' D'#252'zenle'
      OnClick = ServisDurumlarnDzenle1Click
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
  object TabXSLT: TFDQuery
    BeforePost = TabXSLTBeforePost
    OnNewRecord = TabXSLTNewRecord
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'DOKUMLER'
    UpdateOptions.KeyFields = 'ID'
    UpdateOptions.AutoIncFields = 'ID'
    SQL.Strings = (
      'SELECT * FROM DOKUMLER where GRUBU='#39'XSLT'#39)
    Left = 60
    Top = 376
  end
  object DtsXSLT: TDataSource
    DataSet = TabXSLT
    Left = 165
    Top = 384
  end
end
