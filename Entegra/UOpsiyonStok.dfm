object OpsiyonStokDlg: TOpsiyonStokDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Stok Opsiyonlar'
  ClientHeight = 633
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 592
    Width = 528
    Height = 41
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 427
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
      TabOrder = 1
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 350
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
      TabOrder = 0
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object PageControl1: TPageControl
    Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 528
    Height = 592
    ActivePage = TsGenel
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object TsGenel: TTabSheet
      Caption = 'Genel'
      ImageIndex = 11
      object Label2: TLabel
        Left = 5
        Top = 495
        Width = 131
        Height = 16
        Caption = 'Stok '#304#231'in Varsay'#305'lan Klasor'
      end
      object StokSayTus: TBitBtn
        Left = 162
        Top = 6
        Width = 157
        Height = 25
        Caption = 'Stok Say'#305'mlar'#305
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000420B0000420B00000001000000010000000000000084
          0000210021005A4A29004A3939005A5242004A4A4A005A524A0073524A005A52
          52006300630073737300BD847B00C6947B00CE9C7B00B58484009C948400BD94
          9400EFCE9400F7CE9400C6A59C00EFCE9C00F7CE9C00F7D69C00C6ADA500CEAD
          A500F7D6A500C6ADAD00CEB5AD00D6B5AD00EFD6AD00F7D6AD00C6B5B500D6BD
          B500DEBDB500DEC6B500E7C6B500EFC6B500EFCEB500F7D6B500F7DEB500D6C6
          BD00DECEBD00EFCEBD00F7DEBD0000C6C600C6C6C600D6CEC600F7DEC600F7E7
          C600E7CECE00E7D6CE00F7E7CE00E7D6D600F7E7D600FFE7D600FFEFD600FFEF
          DE00FFEFE700FFF7E70021F7EF00FFF7EF0018F7F700FFF7F700FFFFF700FF00
          FF0000FFFF0021FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0041410F0F0F0F
          0F0F0F0F0F0F0F0F0F4141411438312C281E1A15121212170F41414114382E2E
          2E2E2E2E2E2E2E150F414141183A3634302C1E15151512150F414141183B3634
          31302805151515120F4141411C402E2E2E2E2E06002E2E150F4141411D443D3A
          363431070000291E0F41414121443F3D39363407422D00290F41414121442E2E
          2E2E2E0B3E2D002911414141224444443F3A393609422D001B41414123444444
          443F3A3910432D002041414124442E2E2E2E2E2E3604422D0041414124444444
          4444444032083C2D004141412B44444444444444330D030001004141243F3D3D
          3D3D3D3D320D0801010241412426262626242426210C410A0A41}
        TabOrder = 0
        OnClick = StokSayTusClick
      end
      object RadioStokDurum: TcxRadioGroup
        Left = 163
        Top = 117
        Caption = 'Stok Durum Kontrol Kural'#305
        Properties.Items = <
          item
            Caption = 'Yetersizse '#231#305'kamas'#305'n'
          end
          item
            Caption = 'Yetersizse onay als'#305'n'
          end
          item
            Caption = 'Yetersizse de '#231#305'kabilsin'
          end>
        ItemIndex = 0
        TabOrder = 4
        Height = 81
        Width = 158
      end
      object cxLabel1: TcxLabel
        Left = 5
        Top = 304
        Caption = 'Varsay'#305'lan Birim'
      end
      object cbVarsBrm: TcxImageComboBox
        Left = 230
        Top = 302
        RepositoryItem = Tablo.repStokAnaBirim
        Properties.ImmediatePost = True
        Properties.Items = <>
        TabOrder = 5
        Width = 158
      end
      object cxLabel2: TcxLabel
        Left = 5
        Top = 330
        Caption = 'Bu Kullan'#305'c'#305'da Varsay'#305'lan Depo:'
        Transparent = True
      end
      object CbVarsDepo: TcxImageComboBox
        Left = 230
        Top = 328
        RepositoryItem = Tablo.RepStokDepolarAktif
        Properties.ImmediatePost = True
        Properties.Items = <>
        TabOrder = 7
        Width = 158
      end
      object BtnFiyatListeleri: TcxButton
        Left = 162
        Top = 33
        Width = 157
        Height = 27
        Caption = 'Fiyat Listeleri'
        TabOrder = 2
        OnClick = BtnFiyatListeleriClick
      end
      object cxLabel3: TcxLabel
        Left = 5
        Top = 356
        Caption = 'Stok Aramalar'#305'nda Focus:'
        Transparent = True
      end
      object CbStokFocus: TcxImageComboBox
        Left = 230
        Top = 354
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Kod'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Ad'
            Value = 2
          end
          item
            Description = 'Barkod'
            Value = 3
          end>
        TabOrder = 9
        Width = 158
      end
      object cxLabel4: TcxLabel
        Left = 5
        Top = 382
        Caption = 'Stok Kod Giri'#351'i'
        Transparent = True
      end
      object cbStokKodGirisi: TcxImageComboBox
        Left = 230
        Top = 380
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
        TabOrder = 11
        Width = 158
      end
      object checkSayimOnaydanSonraDegissin: TcxCheckBox
        Left = 2
        Top = 517
        Caption = 'Say'#305'm Tutanaklar'#305' Onaydan sonra tekrar de'#287'i'#351'tirilebilsin'
        Properties.Alignment = taRightJustify
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        TabOrder = 16
        Transparent = True
      end
      object cxLabel5: TcxLabel
        Left = 5
        Top = 408
        Caption = 'Kalmayan Stok G'#246'r'#252'ns'#252'n m'#252
        Transparent = True
      end
      object cbKalmayanStok: TcxImageComboBox
        Left = 230
        Top = 406
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'G'#246'r'#252'ns'#252'n'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'G'#246'r'#252'nmesin'
            Value = 0
          end>
        TabOrder = 13
        Width = 158
      end
      object BtnKampanyalar: TcxButton
        Left = 162
        Top = 61
        Width = 157
        Height = 27
        Caption = 'Kampanyalar'
        TabOrder = 3
        OnClick = BtnKampanyalarClick
      end
      object GBGidFatListe: TcxGroupBox
        Left = 3
        Top = 6
        Caption = 'Listeleri Ayarlama'
        TabOrder = 1
        Height = 282
        Width = 156
        object GridListeDuzenle: TcxGrid
          Left = 2
          Top = 21
          Width = 152
          Height = 259
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
              Width = 149
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
      object VarsayilanKlasorStok: TcxButtonEdit
        Left = 232
        Top = 488
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorStokPropertiesButtonClick
        TabOrder = 18
        Text = 'VarsayilanKlasor'
        Width = 156
      end
      object cxLabel6: TcxLabel
        Left = 6
        Top = 462
        Caption = 'G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler: TcxImageComboBox
        Left = 231
        Top = 460
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Sadece Ortak'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Sadece Kendi '#350'ubesi'
            Value = 1
          end
          item
            Description = 'Ortak + Kendi '#350'ubesi'
            Value = 2
          end
          item
            Description = 'Ortak + T'#252'm '#350'ubeler'
            Value = 3
          end>
        TabOrder = 14
        Width = 158
      end
      object checkLokasyonVar: TcxCheckBox
        Left = 165
        Top = 204
        Caption = 'Stok hareketleri lokasyonlara g'#246're yap'#305'ls'#305'n'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        TabOrder = 19
        Transparent = True
      end
      object chckStokSeviyeSorma: TcxCheckBox
        Left = 165
        Top = 226
        Caption = 'Stok seviyeleri yeni kart'#39'da sorulsun'
        TabOrder = 20
        Transparent = True
      end
      object CheckOtomatikKombinasyon: TcxCheckBox
        Left = 165
        Top = 248
        Caption = 'Varolmayan Stok Boyutlar'#305'n'#305' Oto. Olu'#351'tur'
        TabOrder = 21
        Transparent = True
      end
      object BtnMuhasebKodlari: TButton
        Left = 162
        Top = 89
        Width = 156
        Height = 25
        Caption = 'Muhasebe Kodlar'#305
        TabOrder = 22
        OnClick = BtnMuhasebKodlariClick
      end
      object cxLabel11: TcxLabel
        Left = 6
        Top = 435
        Caption = 'Hareketler Tarih Ba'#351'lang'#305'c'#305
        Transparent = True
      end
      object cbHareketBasla: TcxImageComboBox
        Left = 231
        Top = 433
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'G'#252'n ba'#351#305'ndan'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Ay ba'#351#305'ndan'
            Value = 1
          end
          item
            Description = 'Y'#305'l ba'#351#305'ndan'
            Value = 2
          end>
        TabOrder = 24
        Width = 158
      end
      object RadioStokMaliyet: TcxRadioGroup
        Left = 327
        Top = 117
        Caption = 'Stok Maliyet Hesap Y'#246'ntemi'
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Caption = 'Hesaplama Yok'
          end
          item
            Caption = 'Ortalama'
            Tag = 1
          end
          item
            Caption = 'FIFO'
            Tag = 2
          end>
        ItemIndex = 0
        TabOrder = 25
        Height = 81
        Width = 158
      end
      object cxButton1: TcxButton
        Left = 327
        Top = 89
        Width = 158
        Height = 25
        Caption = 'T'#252'm Stok Maliyetlerini Yenile'
        TabOrder = 26
        OnClick = BtnMaliyetYenileClick
      end
      object CheckMuhasebeKodlar: TcxCheckBox
        Left = 165
        Top = 271
        Caption = 'Stok Kart'#305'nda Muhasebe Kodlar'#305' G'#246'r'#252'ns'#252'n'
        TabOrder = 27
        Transparent = True
      end
      object CheckUrunNoTek: TcxCheckBox
        Left = 5
        Top = 540
        Caption = 'Stok Kart'#305'nda '#220'r'#252'n No Tek Olmal'#305' '
        Properties.Alignment = taRightJustify
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Style.TransparentBorder = False
        TabOrder = 28
        Transparent = True
      end
    end
    object tsDepolar: TTabSheet
      Caption = 'Depolar'
      ImageIndex = 12
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 514
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
        object DepoEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
          OnClick = DepoEkleTusClick
        end
        object DepoSilTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
          OnClick = DepoSilTusClick
        end
        object ToolButton2: TToolButton
          Left = 122
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsSeparator
        end
        object DepoKaydetTus: TToolButton
          Left = 130
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = DepoKaydetTusClick
        end
        object DepoIptalTus: TToolButton
          Left = 191
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = DepoIptalTusClick
        end
      end
      object gridDepolar: TcxGrid
        Left = 0
        Top = 62
        Width = 520
        Height = 499
        Align = alClient
        TabOrder = 2
        object tvDepolar: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dtsDepolar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object clmDepoId: TcxGridDBColumn
            Caption = 'Id'
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 40
          end
          object clmDepoAdi: TcxGridDBColumn
            Caption = 'Depo Ad'#305
            DataBinding.FieldName = 'DEPOADI'
            DataBinding.IsNullValueType = True
            Width = 115
          end
          object clmDepoAktif: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.DefaultImageIndex = 1
            Properties.Items = <
              item
                Description = 'Aktif'
                ImageIndex = 0
                Value = '1'
              end
              item
                Description = 'Pasif'
                Value = '0'
              end>
          end
          object ClmVarsayilan: TcxGridDBColumn
            Caption = 'Varsay'#305'lan'
            DataBinding.FieldName = 'VARSAYILAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepDepoVarsayilanListesi
            Width = 90
          end
          object tvDepolarMALIYETI_ETKILESIN: TcxGridDBColumn
            Caption = 'Maliyeti Etkilesin'
            DataBinding.FieldName = 'MALIYETI_ETKILESIN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 98
          end
          object tvDepolarColumn1: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = tvDepolarColumn1PropertiesButtonClick
            Width = 67
          end
        end
        object gridDepolarLevel1: TcxGridLevel
          GridView = tvDepolar
        end
      end
      object PanelSube: TPanel
        Left = 0
        Top = 27
        Width = 520
        Height = 35
        Align = alTop
        TabOrder = 1
        object ComboSubeler: TcxImageComboBox
          Left = 38
          Top = 6
          RepositoryItem = Tablo.RepSubeler
          Properties.Items = <>
          Properties.OnCloseUp = PageControl1Change
          TabOrder = 0
          Width = 371
        end
        object cxLabel10: TcxLabel
          Left = 6
          Top = 9
          Caption = #350'ube'
          Transparent = True
        end
      end
    end
    object TsITS: TTabSheet
      Caption = #220'TS'
      ImageIndex = 19
      object cxGroupBox1: TcxGroupBox
        Left = 158
        Top = 344
        Caption = 'Fiyat Adlar'#305
        TabOrder = 0
        Visible = False
        Height = 145
        Width = 359
        object cxLabel7: TcxLabel
          Left = 3
          Top = 32
          Caption = #304'malatc'#305' Fiyat Ad'#305
        end
        object cxLabel8: TcxLabel
          Left = 3
          Top = 58
          Caption = 'Depocu Fiyat Ad'#305
        end
        object cxLabel9: TcxLabel
          Left = 3
          Top = 84
          Caption = 'Etiket Fiyat Ad'#305
        end
        object ComboImalatci: TcxImageComboBox
          Left = 187
          Top = 31
          RepositoryItem = Tablo.RepFiyatAdlari
          Properties.Items = <>
          TabOrder = 0
          Width = 134
        end
        object ComboDepocu: TcxImageComboBox
          Left = 187
          Top = 57
          RepositoryItem = Tablo.RepFiyatAdlari
          Properties.Items = <>
          TabOrder = 2
          Width = 134
        end
        object ComboEtiket: TcxImageComboBox
          Left = 187
          Top = 83
          RepositoryItem = Tablo.RepFiyatAdlari
          Properties.Items = <>
          TabOrder = 4
          Width = 134
        end
      end
      object cxLabel12: TcxLabel
        Left = 21
        Top = 93
        Caption = 'Token'
      end
      object CheckUTSKullanimda: TcxCheckBox
        Left = 96
        Top = 32
        Caption = #220'TS Kullan'#305'mda'
        TabOrder = 2
      end
      object EditUTSToken: TcxTextEdit
        Left = 94
        Top = 91
        Properties.EchoMode = eemPassword
        TabOrder = 3
        Width = 385
      end
      object cxLabel13: TcxLabel
        Left = 21
        Top = 65
        Caption = #220'TS Firma No'
      end
      object EditUTSFirmaNo: TcxTextEdit
        Left = 94
        Top = 63
        TabOrder = 5
        Width = 191
      end
      object CheckTest: TcxCheckBox
        Left = 94
        Top = 123
        Caption = 'Test Kullan'#305'm'#305'nda'
        TabOrder = 6
      end
      object MemoUTSKomut: TcxMemo
        Left = 21
        Top = 216
        Lines.Strings = (
          'alter table STOKLAR add SUTKODU nvarchar(30)'
          'alter table STOKLAR add BRANSKODU nvarchar(30)'
          'alter table STOKLAR add GMDN nvarchar(30)'
          'alter table STOKLAR add GMDNADI nvarchar(100)'
          'alter table STOKLAR add MEDIKALSINIF smallint'
          'alter table STOKLAR add ITHALIMAL smallint'
          'alter table STOKLAR add MENSEIULKE smallint'
          '')
        TabOrder = 7
        Visible = False
        Height = 89
        Width = 458
      end
    end
    object tsStokBoyutlar: TTabSheet
      Caption = 'Boyutlar'
      ImageIndex = 19
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 520
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
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
          OnClick = ToolButton1Click
        end
        object ToolButton3: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
          OnClick = ToolButton3Click
        end
        object ToolButton4: TToolButton
          Left = 122
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsSeparator
        end
        object ToolButton5: TToolButton
          Left = 130
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = ToolButton5Click
        end
        object ToolButton6: TToolButton
          Left = 191
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = ToolButton6Click
        end
      end
      object GridStokBoyutlar: TcxGrid
        Left = 0
        Top = 24
        Width = 520
        Height = 217
        Align = alTop
        TabOrder = 1
        object GridStokBoyutlarDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellDblClick = GridStokBoyutlarDBTableView1CellDblClick
          DataController.DataSource = DtsStokBoyutlar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object GridStokBoyutlarDBTableView1ANAHTAR: TcxGridDBColumn
            Caption = 'Boyut Ad'#305
            DataBinding.FieldName = 'ANAHTAR'
            DataBinding.IsNullValueType = True
            Width = 303
          end
          object GridStokBoyutlarDBTableView1SIRA: TcxGridDBColumn
            DataBinding.FieldName = 'SIRA'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object GridStokBoyutlarLevel1: TcxGridLevel
          GridView = GridStokBoyutlarDBTableView1
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 241
        Width = 520
        Height = 320
        Align = alClient
        TabOrder = 2
        object ToolBar3: TToolBar
          Left = 1
          Top = 1
          Width = 518
          Height = 22
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 20
          ButtonWidth = 46
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
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton7: TToolButton
            Left = 0
            Top = 0
            Caption = 'Ekle'
            ImageIndex = 4
            Style = tbsTextButton
            OnClick = ToolButton7Click
          end
          object ToolButton8: TToolButton
            Left = 46
            Top = 0
            Caption = 'Sil'
            ImageIndex = 5
            Style = tbsTextButton
            OnClick = ToolButton8Click
          end
          object ToolButton9: TToolButton
            Left = 92
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 7
            Style = tbsSeparator
          end
          object ToolButton10: TToolButton
            Left = 100
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            Visible = False
            OnClick = ToolButton10Click
          end
          object ToolButton11: TToolButton
            Left = 146
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            Visible = False
            OnClick = ToolButton11Click
          end
        end
        object GridBoyutKombinasyon: TcxGrid
          Left = 1
          Top = 23
          Width = 518
          Height = 296
          Align = alClient
          TabOrder = 1
          object GridBoyutKombinasyonDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridStokBoyutlarDBTableView1CellDblClick
            DataController.DataSource = DtsBoyutKombinasyon
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object GridBoyutKombinasyonDBTableView1ADI: TcxGridDBColumn
              Caption = 'Ad'#305
              DataBinding.FieldName = 'ADI'
              DataBinding.IsNullValueType = True
              Width = 184
            end
            object GridBoyutKombinasyonDBTableView1BOYUT1: TcxGridDBColumn
              Caption = '1. Boyut'
              DataBinding.FieldName = 'BOYUT1'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepStokBoyutlar
            end
            object GridBoyutKombinasyonDBTableView1BOYUT2: TcxGridDBColumn
              Caption = '2. Boyut'
              DataBinding.FieldName = 'BOYUT2'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepStokBoyutlar
            end
            object GridBoyutKombinasyonDBTableView1BOYUT3: TcxGridDBColumn
              Caption = '3. Boyut'
              DataBinding.FieldName = 'BOYUT3'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepStokBoyutlar
            end
          end
          object GridBoyutKombinasyonLevel1: TcxGridLevel
            GridView = GridBoyutKombinasyonDBTableView1
          end
        end
      end
    end
    object tsBarkodUretimi: TTabSheet
      Caption = 'Barkod '#220'retimi'
      ImageIndex = 19
      object GridBarkodAyar: TcxGrid
        Left = 0
        Top = 24
        Width = 520
        Height = 537
        Align = alClient
        TabOrder = 1
        object GridBarkodAyarDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsBarkodAyar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object GridBarkodAyarDBTableView1AD: TcxGridDBColumn
            Caption = 'Ad'#305
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 111
          end
          object GridBarkodAyarDBTableView1TIP: TcxGridDBColumn
            Caption = 'Tipi'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokKartBarkodTipi
            Width = 70
          end
          object GridBarkodAyarDBTableView1BASLANGIC: TcxGridDBColumn
            Caption = 'Ba'#351'lang'#305#231
            DataBinding.FieldName = 'BASLANGIC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            MinWidth = 50
            Width = 146
          end
          object GridBarkodAyarDBTableView1SONDANSIL: TcxGridDBColumn
            Caption = 'Sondan Sil'
            DataBinding.FieldName = 'SONDANSIL'
            DataBinding.IsNullValueType = True
          end
        end
        object GridBarkodAyarLevel1: TcxGridLevel
          GridView = GridBarkodAyarDBTableView1
        end
      end
      object ToolBar4: TToolBar
        Left = 0
        Top = 0
        Width = 520
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
        object tbBarkodAyarEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
          OnClick = tbBarkodAyarEkleClick
        end
        object tbBarkodAyarSil: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
          OnClick = tbBarkodAyarSilClick
        end
        object ToolButton14: TToolButton
          Left = 122
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsSeparator
        end
        object tbBarkodAyarKaydet: TToolButton
          Left = 130
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = tbBarkodAyarKaydetClick
        end
        object tbBarkodAyarIptal: TToolButton
          Left = 191
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = tbBarkodAyarIptalClick
        end
        object ToolButton12: TToolButton
          Left = 252
          Top = 0
          AutoSize = True
          Caption = 'Bilgi'
          ImageIndex = 22
          ImageName = 'PngImage22'
          OnClick = ToolButton12Click
        end
      end
    end
    object TabSheetKarekod: TTabSheet
      Caption = 'Karekod Format'#305
      ImageIndex = 19
      object ToolBar5: TToolBar
        Left = 0
        Top = 0
        Width = 520
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
        object tbKarekodAyarEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
          OnClick = tbKarekodAyarEkleClick
        end
        object tbKarekodAyarSil: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
          OnClick = tbKarekodAyarSilClick
        end
        object ToolButton16: TToolButton
          Left = 122
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsSeparator
        end
        object tbKarekodAyarKaydet: TToolButton
          Left = 130
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = tbKarekodAyarKaydetClick
        end
        object tbKarekodAyarIptal: TToolButton
          Left = 191
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = tbKarekodAyarIptalClick
        end
        object ToolButton19: TToolButton
          Left = 252
          Top = 0
          AutoSize = True
          Caption = 'Bilgi'
          ImageIndex = 22
          ImageName = 'PngImage22'
          OnClick = ToolButton12Click
        end
      end
      object GridKarekod: TcxGrid
        Left = 0
        Top = 24
        Width = 520
        Height = 537
        Align = alClient
        TabOrder = 1
        object GridKarekodTableView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKarekodAyar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'Tipi'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'GTIN'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Lot No'
                Value = 10
              end
              item
                Description = #220'retim Tarihi ('#220'RT)'
                Value = 11
              end
              item
                Description = 'So Kullan'#305'm Tarihi (SKT)'
                Value = 17
              end
              item
                Description = 'Seri No'
                Value = 21
              end>
            Width = 136
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Ba'#351'lama Simgesi'
            DataBinding.FieldName = 'BASLANGIC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            MinWidth = 50
            Width = 270
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridKarekodTableView
        end
      end
    end
  end
  object tabDepolar: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabDepolarBeforeEdit
    BeforePost = tabDepolarBeforePost
    AfterPost = tabDepolarAfterPost
    OnNewRecord = tabDepolarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from DEPOLAR ')
    Left = 152
    Top = 108
  end
  object dtsDepolar: TDataSource
    DataSet = tabDepolar
    OnStateChange = dtsDepolarStateChange
    Left = 458
    Top = 61
  end
  object TabListeDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select * from GENINI where BOLUM=0 and ANAHTAR like '#39'%StokKart_%' +
        #39)
    Left = 41
    Top = 166
  end
  object DtsListeDuzenle: TDataSource
    DataSet = TabListeDuzenle
    Left = 467
    Top = 189
  end
  object DtsStokBoyutlar: TDataSource
    DataSet = TabStokBoyutlar
    OnStateChange = DtsStokBoyutlarStateChange
    Left = 486
    Top = 153
  end
  object TabStokBoyutlar: TFDQuery
    Connection = Tablo.FDCnn
    AfterPost = TabStokBoyutlarAfterPost
    ParamData = <>
    SQL.Strings = (
      'select * from GENINI'
      ''
      'where BOLUM=0'
      'and DEGER like '#39'-2799____'#39
      'and DIL=:PDil')
    Left = 116
    Top = 201
  end
  object DtsBoyutKombinasyon: TDataSource
    DataSet = TabBoyutKombinasyon
    OnStateChange = DtsBoyutKombinasyonStateChange
    Left = 460
    Top = 297
  end
  object TabBoyutKombinasyon: TFDQuery
    Connection = Tablo.FDCnn
    AfterPost = TabBoyutKombinasyonAfterPost
    ParamData = <>
    SQL.Strings = (
      'select * from STOKBOYUTGRUPLARI')
    Left = 202
    Top = 186
  end
  object TabBarkodAyar: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabBarkodAyarBeforePost
    OnNewRecord = TabBarkodAyarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from BARKODAYARLAR'
      'where SUBEID=0')
    Left = 353
    Top = 234
  end
  object DtsBarkodAyar: TDataSource
    DataSet = TabBarkodAyar
    OnStateChange = DtsBarkodAyarStateChange
    Left = 329
    Top = 179
  end
  object TabKarekodAyar: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabKarekodAyarBeforePost
    OnNewRecord = TabKarekodAyarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from BARKODAYARLAR'
      'where SUBEID=100')
    Left = 345
    Top = 322
  end
  object DtsKarekodAyar: TDataSource
    DataSet = TabKarekodAyar
    OnStateChange = DtsKarekodAyarStateChange
    Left = 225
    Top = 323
  end
end

