object EntegrasyonEslestirmeDlg: TEntegrasyonEslestirmeDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Ba'#287'lant'#305' Entegrasyon Kodlar'#305
  ClientHeight = 453
  ClientWidth = 839
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pgctrl: TcxPageControl
    Left = 0
    Top = 0
    Width = 839
    Height = 453
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tsRehber
    Properties.CustomButtons.Buttons = <>
    OnPageChanging = pgctrlPageChanging
    ClientRectBottom = 449
    ClientRectLeft = 4
    ClientRectRight = 835
    ClientRectTop = 27
    object tsRehber: TcxTabSheet
      Caption = 'Rehber Kay'#305'tlar'#305
      ImageIndex = 4
      object cxPageControl3: TcxPageControl
        Left = 0
        Top = 0
        Width = 831
        Height = 422
        Align = alClient
        Enabled = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet4
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 418
        ClientRectLeft = 4
        ClientRectRight = 827
        ClientRectTop = 27
        object cxTabSheet4: TcxTabSheet
          Caption = 'Aktar'#305'm Ayarlar'#305
          ImageIndex = 0
          object PnAktarimAyarlari: TPanel
            Left = 0
            Top = 0
            Width = 823
            Height = 391
            Align = alClient
            TabOrder = 0
            object cxGrid1: TcxGrid
              Left = 1
              Top = 25
              Width = 821
              Height = 365
              Align = alClient
              TabOrder = 0
              object cxGrid1DBTableView1: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsAktarimAyarlari
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                object cxGrid1DBTableView1SUBEADI: TcxGridDBColumn
                  Caption = 'Ba'#287'lant'#305
                  DataBinding.FieldName = 'SUBEADI'
                  PropertiesClassName = 'TcxLabelProperties'
                  Width = 192
                end
                object cxGrid1DBTableView1Aktarim: TcxGridDBColumn
                  Caption = 'Aktar'#305'm'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Width = 50
                end
              end
              object cxGrid1Level1: TcxGridLevel
                GridView = cxGrid1DBTableView1
              end
            end
            object ToolBar2: TToolBar
              Left = 1
              Top = 1
              Width = 821
              Height = 24
              Margins.Bottom = 0
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
              TabOrder = 1
              Transparent = True
              Wrapable = False
              object BtnAAKaydet: TToolButton
                Left = 0
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                Visible = False
                OnClick = BtnAAKaydetClick
              end
              object BtnAAIptal: TToolButton
                Left = 46
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                Visible = False
                OnClick = BtnAAIptalClick
              end
              object ToolButton1: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton1'
                ImageIndex = 4
                Style = tbsSeparator
              end
            end
          end
        end
        object cxTabSheet5: TcxTabSheet
          Caption = 'A'#231#305'klama'
          ImageIndex = 1
          object cxMemo2: TcxMemo
            Left = 0
            Top = 0
            Align = alClient
            Lines.Strings = (
              '-Aktar'#305'm Gentegre '#252'zerinden veritaban'#305'ndaki trigger ile yap'#305'l'#305'r.'
              
                '-Rehber kay'#305'tlar'#305'ndaki d'#252'zenlemeler sadece Gentegre '#252'zerinde yap' +
                #305'lmal'#305'd'#305'r.'
              ' --Genot'#305'p-Kay'#305'tkabul ve kullan'#305'mdaki di'#287'er mod'#252'llerden '
              '    ---Rehber Ekleme'
              '    ---Rehber De'#287'i'#351'tirme'
              '    ---Rehber Silme yetkilerinin kald'#305'r'#305'lmas'#305' gerekir.'
              
                '-"G'#252'n Sonu","Stok Giri'#351' Faturalar'#305'","Kurum Faturalar'#305'" entegrasy' +
                'onlar'#305'n'#305'n sa'#287'l'#305'kl'#305' '#231'al'#305#351'abilmesi i'#231'in aktif kalmal'#305'd'#305'r.')
            Properties.ReadOnly = True
            TabOrder = 0
            Height = 391
            Width = 823
          end
        end
      end
      object cbRehberKayitlariAktarimi: TcxCheckBox
        Left = 159
        Top = 3
        Caption = 'Rehber Aktar'#305'm'#305' Aktif'
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = cbRehberKayitlariAktarimiPropertiesEditValueChanged
        TabOrder = 0
        Width = 155
      end
    end
    object tsStokKart: TcxTabSheet
      Caption = 'Stok Kartlar'#305
      ImageIndex = 1
      object cxPageControl4: TcxPageControl
        Left = 0
        Top = 0
        Width = 831
        Height = 422
        Align = alClient
        Enabled = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet6
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 418
        ClientRectLeft = 4
        ClientRectRight = 827
        ClientRectTop = 27
        object cxTabSheet6: TcxTabSheet
          Caption = 'Aktar'#305'm Ayarlar'#305
          ImageIndex = 0
        end
        object cxTabSheet7: TcxTabSheet
          Caption = 'A'#231#305'klama'
          ImageIndex = 1
          object cxMemo3: TcxMemo
            Left = 0
            Top = 0
            Align = alClient
            Lines.Strings = (
              '-Aktar'#305'm Genot'#305'p '#252'zerinden veritaban'#305'ndaki trigger ile yap'#305'l'#305'r.'
              
                '-Stok kay'#305'tlar'#305'ndaki d'#252'zenlemeler ve her t'#252'rl'#252' stok i'#351'lemi sadec' +
                'e Genot'#305'p Stok '#252'zerinde takip edilmelidir.'
              ' --Entegra Stok yetkilerinden '#252'zerinden '
              '    ---Stok Ekleme'
              '    ---Stok De'#287'i'#351'tirme yetkilerinin kald'#305'r'#305'lmas'#305' gerekir.'
              
                '-"Stok Giri'#351' Faturalar'#305'"entegrasyonlar'#305'n'#305'n sa'#287'l'#305'kl'#305' '#231'al'#305#351'abilmes' +
                'i i'#231'in aktif kalmal'#305'd'#305'r.'
              '')
            Properties.ReadOnly = True
            TabOrder = 0
            Height = 391
            Width = 823
          end
        end
      end
      object cbStokKartAktarimi: TcxCheckBox
        Left = 159
        Top = 3
        Caption = 'Stok Kart Aktar'#305'm'#305' Aktif'
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = cbStokKartAktarimiPropertiesEditValueChanged
        TabOrder = 0
        Width = 155
      end
    end
    object tsStokGiris: TcxTabSheet
      Caption = 'Stok Giri'#351' Faturalar'#305
      ImageIndex = 2
      object cxPageControl5: TcxPageControl
        Left = 0
        Top = 0
        Width = 831
        Height = 422
        Align = alClient
        Enabled = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet8
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 418
        ClientRectLeft = 4
        ClientRectRight = 827
        ClientRectTop = 27
        object cxTabSheet8: TcxTabSheet
          Caption = 'Aktar'#305'm Ayarlar'#305
          ImageIndex = 0
        end
        object cxTabSheet9: TcxTabSheet
          Caption = 'A'#231#305'klama'
          ImageIndex = 1
          object cxMemo4: TcxMemo
            Left = 0
            Top = 0
            Align = alClient
            Lines.Strings = (
              '-Aktar'#305'm Genot'#305'p '#252'zerinden veritaban'#305'ndaki trigger ile yap'#305'l'#305'r.'
              
                '-Stok Giri'#351' kay'#305'tlar'#305'ndaki d'#252'zenlemeler sadece Genot'#305'p-Stok '#252'zer' +
                'inde yap'#305'lmal'#305'd'#305'r.'
              ' --Gentegre ve kullan'#305'mdaki di'#287'er mod'#252'llerden '
              '    ---Stok Ekleme'
              '    ---Stok De'#287'i'#351'tirme yetkilerinin kald'#305'r'#305'lmas'#305' gerekir.'
              
                '-Sa'#287'l'#305'kl'#305' '#231'al'#305#351'abilmesi i'#231'in "Rehber Kay'#305'tlar'#305'" ve "StokKartlar'#305 +
                '" entegrasyonlar'#305'n'#305'n aktif olmas'#305' gereklidir.'
              
                '-Stok Mod'#252'l'#252'nden, Giri'#351' kay'#305'tlar'#305' eklendikten sonra "Onay" alan'#305 +
                'n'#305'n i'#351'aretlenmesi sonras'#305'nda kay'#305'tlar aktar'#305'l'#305'r. '
              '-Onay kald'#305'r'#305'l'#305'r ise kay'#305'tlar tekrar silinir.'
              '')
            Properties.ReadOnly = True
            TabOrder = 0
            Height = 391
            Width = 823
          end
        end
      end
      object cbStokGirisAktarimiAktif: TcxCheckBox
        Left = 159
        Top = 3
        Caption = 'Stok Giri'#351' Aktar'#305'm'#305' Aktif'
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = cbStokGirisAktarimiAktifPropertiesEditValueChanged
        TabOrder = 0
        Width = 155
      end
    end
    object tsGunSonu: TcxTabSheet
      Caption = 'G'#252'n Sonu'
      ImageIndex = 0
      object cxPageControl2: TcxPageControl
        Left = 0
        Top = 0
        Width = 831
        Height = 422
        Align = alClient
        Enabled = False
        TabOrder = 0
        Properties.ActivePage = cxTabSheet1
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 418
        ClientRectLeft = 4
        ClientRectRight = 827
        ClientRectTop = 27
        object cxTabSheet1: TcxTabSheet
          Caption = 'Aktar'#305'm Ayarlar'#305
          ImageIndex = 0
          object Panel2: TPanel
            Left = 0
            Top = 97
            Width = 823
            Height = 294
            Align = alClient
            TabOrder = 0
            object gridEslestirme: TcxGrid
              Left = 1
              Top = 1
              Width = 821
              Height = 292
              Align = alClient
              TabOrder = 0
              object tvEslestirme: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = dtsEslestirme
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                object clmKaynakDeger: TcxGridDBColumn
                  Caption = 'Kaynak De'#287'er'
                  DataBinding.FieldName = 'KAYNAKDEGER'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.OnButtonClick = clmKaynakDegerPropertiesButtonClick
                  Width = 99
                end
                object clmHedefDeger: TcxGridDBColumn
                  Caption = 'Hedef De'#287'er'
                  DataBinding.FieldName = 'HEDEFDEGER'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  Width = 127
                end
                object clmHedefCari: TcxGridDBColumn
                  Caption = 'Cari'
                  DataBinding.FieldName = 'HEDEFREHBERID'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.OnButtonClick = clmHedefCariPropertiesButtonClick
                  OnGetDisplayText = clmHedefCariGetDisplayText
                end
              end
              object gridEslestirmeLevel1: TcxGridLevel
                GridView = tvEslestirme
              end
            end
          end
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 823
            Height = 97
            Align = alTop
            TabOrder = 1
            object comboBaglanti: TcxImageComboBox
              Left = 269
              Top = 9
              Properties.Items = <>
              Properties.OnEditValueChanged = comboBaglantiPropertiesEditValueChanged
              TabOrder = 0
              Width = 146
            end
            object cxLabel1: TcxLabel
              Left = 151
              Top = 11
              Caption = 'Ba'#287'lant'#305
            end
            object comboEntegrasyonTuru: TcxImageComboBox
              Left = 269
              Top = 38
              EditValue = '301'
              Properties.ImmediatePost = True
              Properties.Items = <
                item
                  Description = 'Cari Nakit Aktar'#305'm'
                  ImageIndex = 0
                  Value = '301'
                end
                item
                  Description = 'Cari Pos Aktar'#305'm'
                  Value = '302'
                end>
              Properties.OnEditValueChanged = comboBaglantiPropertiesEditValueChanged
              TabOrder = 2
              Width = 146
            end
            object cxLabel2: TcxLabel
              Left = 151
              Top = 40
              Caption = 'Entegrasyon T'#252'r'#252
            end
            object ToolBar1: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 74
              Width = 815
              Height = 22
              Margins.Bottom = 0
              Align = alBottom
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
              TabOrder = 4
              Transparent = True
              object EslestirmeEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Ekle'
                ImageIndex = 4
                Style = tbsTextButton
                OnClick = EslestirmeEkleTusClick
              end
              object EslestirmeSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 5
                Style = tbsTextButton
                OnClick = EslestirmeSilTusClick
              end
              object ToolButton4: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton2'
                ImageIndex = 7
                Style = tbsSeparator
              end
              object EslestirmeKaydetTus: TToolButton
                Left = 100
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                Visible = False
                OnClick = EslestirmeKaydetTusClick
              end
              object EslestirmeIptalTus: TToolButton
                Left = 146
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                Visible = False
                OnClick = EslestirmeIptalTusClick
              end
            end
            object GroupBox9: TGroupBox
              Left = 8
              Top = 3
              Width = 91
              Height = 59
              Caption = 'G'#252'n Sonu'
              TabOrder = 5
              object RepGSCariHar: TcxRadioButton
                Left = 3
                Top = 20
                Width = 113
                Height = 17
                Caption = 'Cari Kay'#305'tlar'
                Checked = True
                TabOrder = 0
                TabStop = True
                Transparent = True
              end
              object RepGSTahsilat: TcxRadioButton
                Left = 3
                Top = 37
                Width = 113
                Height = 17
                Caption = 'Tahsilatlar'
                TabOrder = 1
                Transparent = True
              end
            end
          end
        end
        object cxTabSheet2: TcxTabSheet
          Caption = 'A'#231#305'klama'
          ImageIndex = 1
          object cxMemo1: TcxMemo
            Left = 0
            Top = 0
            Align = alClient
            Lines.Strings = (
              'Kasa sihirbaz'#305' '#252'zerinden manuel olarak '#231'al'#305#351#305'r:'
              
                ' -Sihirbaz'#305'n a'#231#305'l'#305#351' sayfas'#305'ndan aktar'#305'm'#305' yap'#305'lmak istenen t'#252'r se' +
                #231'ilir(Nakit ya da POS)'
              
                ' -Gelen yeni sayfadan Tarih ve aktar'#305'm'#305'n yap'#305'laca'#287#305' Veritaban'#305' s' +
                'e'#231'ilir.'
              
                '   --"Se'#231'enekler/Opsiyonlar/Ba'#287'lant'#305' bilgileri" i'#231'erisinden, kul' +
                'lan'#305'lacak veritabanlar'#305'n'#305'n Gentegreye tan'#305'mlanmas'#305' '
              'gereklidir.'
              
                '   --Veritaban'#305' listesinde t'#252'r b'#246'l'#252'm'#252'nden "Genot'#305'p" se'#231'ilmi'#351' ola' +
                'n t'#252'm veritabanlar'#305' bu listeye gelir.'
              
                ' -Gelen i'#351'lem listesinden aktar'#305'lmak istenen kay'#305'tlar se'#231'ilerek ' +
                '"Son" tu'#351'una bas'#305'l'#305'r.'
              
                '   --Entegrasyon e'#351'le'#351'tirme tablosunda bulunmayan t'#252'rlerin aktar' +
                #305'm'#305' yap'#305'lmaz.'
              
                '   --Gelir merkezi de'#287'eri, e'#351'le'#351'tirmedeki cari kayd'#305'n varsay'#305'lan' +
                ' gelir merkezidir. '
              
                ' -'#304#351'lem bitiminde makbuzlar: "Kasa" ve "Kullan'#305'c'#305'" ya g'#246're gurup' +
                'lanm'#305#351' olarak '#231#305'kar.  ')
            Properties.ReadOnly = True
            TabOrder = 0
            Height = 391
            Width = 823
          end
        end
      end
      object cbGSAktarimiAktif: TcxCheckBox
        Left = 159
        Top = 3
        Caption = 'G'#252'n Sonu Aktar'#305'm'#305' Aktif'
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = cbGSAktarimiAktifPropertiesEditValueChanged
        TabOrder = 1
        Width = 155
      end
    end
    object tsKurumFaturalari: TcxTabSheet
      Caption = 'Kurum Faturalar'#305
      ImageIndex = 3
      object cxPageControl6: TcxPageControl
        Left = 0
        Top = 0
        Width = 831
        Height = 422
        Align = alClient
        Enabled = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet10
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 418
        ClientRectLeft = 4
        ClientRectRight = 827
        ClientRectTop = 27
        object cxTabSheet10: TcxTabSheet
          Caption = 'Aktar'#305'm Ayarlar'#305
          ImageIndex = 0
        end
        object cxTabSheet11: TcxTabSheet
          Caption = 'A'#231#305'klama'
          ImageIndex = 1
          object cxMemo5: TcxMemo
            Left = 0
            Top = 0
            Align = alClient
            Lines.Strings = (
              'Aktar'#305'm Genot'#305'p-Kay'#305'tKabul Mod'#252'l'#252' '#252'zerinden yap'#305'lmaktad'#305'r.')
            Properties.ReadOnly = True
            TabOrder = 0
            Height = 391
            Width = 823
          end
        end
      end
      object cbKurumFaturalariAktarimi: TcxCheckBox
        Left = 159
        Top = 3
        Caption = 'G'#252'n Sonu Aktar'#305'm'#305' Aktif'
        Enabled = False
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = cbKurumFaturalariAktarimiPropertiesEditValueChanged
        TabOrder = 0
        Width = 155
      end
    end
  end
  object MemoRehber: TcxMemo
    Left = 265
    Top = 133
    Lines.Strings = (
      
        'create TRIGGER [dbo].[TG_GenotipRehberEntegrasyon] ON [dbo].[REH' +
        'BER] for UPDATE,INSERT,DELETE'
      'as'
      'BEGIN'
      #9'Set NoCount On'
      #9'declare @CurID integer'
      #9'declare @RehberID int'
      #9'declare @Kod varchar(40)'
      #9'declare @Firma varchar(50)'
      #9'declare DeleteCursor cursor for select ID from Deleted'
      #9'declare InsertCursor cursor for select ID from Inserted  '
      
        '----------------------------------------------------------------' +
        '---------'
      '--deleted i'#231'in yaz'#305'lacak kodlar...'
      'if exists (select ID from Deleted)'
      #9'begin'
      #9#9'open DeleteCursor '
      #9#9'fetch next from DeleteCursor into @CurID'
      #9#9'while @@FETCH_STATUS = 0 '
      #9#9#9'begin'#9#9#9
      
        #9#9#9#9'Select @RehberID=ID,@Kod=KOD,@Firma=FIRMA from Deleted where' +
        ' ID=@CurID'#9#9#9
      #9#9#9#9'Delete from GEN2005.dbo.REHBER where KOD=@Kod'
      #9#9#9'fetch next from DeleteCursor into @CurID'
      #9#9'End'
      #9#9'close DeleteCursor'
      #9#9'deallocate DeleteCursor'
      #9'end'
      
        '----------------------------------------------------------------' +
        '----------'
      '--inserted i'#231'in yaz'#305'lacak olan kodlar...'
      'if exists (select ID from Inserted)'
      #9'begin'
      #9#9#9'open InsertCursor '
      #9#9#9'fetch next from InsertCursor into @CurID'
      #9#9#9'while @@FETCH_STATUS = 0 '
      #9#9#9#9'begin'#9
      
        #9#9#9#9#9'Select @RehberID=ID,@Kod=KOD,@Firma=FIRMA from Inserted'#9'whe' +
        're ID=@CurID'#9#9#9#9#9
      #9#9#9#9#9'INSERT INTO '
      #9#9#9#9#9'--select * from '
      #9#9#9#9#9'GEN2005.dbo.REHBER'
      
        #9#9#9#9#9'(KOD,FIRMA,GRUP,ISTEL,CEP,FAX,EMAIL,WEB,ADRES,ILCE,IL,PK,VE' +
        'RGIDAI,VERGINO,FATURABASLIK,'
      
        #9#9#9#9#9'NOTLAR,ARAMADACIKSIN,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGIST' +
        'IRMETARIHI)'#9#9#9#9#9#9#9#9
      #9#9#9#9#9'SELECT top 1 KOD,FIRMA,GRUP=convert(varchar(10),GRUP), '
      
        #9#9#9#9#9'ISTEL=convert(varchar(20),(SELECT TOP 1 BILGI FROM REHBERAY' +
        'AR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=R' +
        'B.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=40)), '
      
        #9#9#9#9#9'CEP=convert(varchar(20),(SELECT  TOP 1 BILGI FROM REHBERAYA' +
        'R RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB' +
        '.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=42)),   '
      
        #9#9#9#9#9'FAX=convert(varchar(20),(SELECT  TOP 1 BILGI FROM REHBERAYA' +
        'R RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB' +
        '.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=41)),   '
      
        #9#9#9#9#9'EMAIL=convert(varchar(50),(SELECT  TOP 1 BILGI FROM REHBERA' +
        'YAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=' +
        'RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=46)),       ' +
        ' '
      
        #9#9#9#9#9'WEB=convert(varchar(50),(SELECT TOP 1  BILGI FROM REHBERAYA' +
        'R RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB' +
        '.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=48)),         ' +
        ' '
      
        #9#9#9#9#9'ADRES=convert(varchar(70),(SELECT TOP 1  BILGI FROM REHBERA' +
        'YAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=' +
        'RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=2)),   '
      
        #9#9#9#9#9'ILCE=convert(varchar(20),(SELECT TOP 1  BILGI FROM REHBERAY' +
        'AR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=R' +
        'B.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=6)),     '
      
        #9#9#9#9#9'IL=convert(varchar(25),(SELECT TOP 1  BILGI FROM REHBERAYAR' +
        ' RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.' +
        'YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=8)),        '
      
        #9#9#9#9#9'PK=convert(varchar(6),(SELECT TOP 1  BILGI FROM REHBERAYAR ' +
        'RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.Y' +
        'ERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=4)),         '
      
        #9#9#9#9#9'VERGIDAI=convert(varchar(15),(SELECT TOP 1  BILGI FROM REHB' +
        'ERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YE' +
        'RI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20)),   '
      
        #9#9#9#9#9'VERGINO=convert(varchar(15),(SELECT TOP 1  BILGI FROM REHBE' +
        'RAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YER' +
        'I=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22)),     '
      
        #9#9#9#9#9'FATURABASLIK=convert(varchar(100),(SELECT TOP 1  BILGI FROM' +
        ' REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=10))' +
        ',   '
      
        #9#9#9#9#9'NOTLAR,ARAMADACIKSIN=case when DURUM=1 then '#39'E'#39' else '#39'H'#39' en' +
        'd,'
      
        #9#9#9#9#9'EKLEYEN=Convert(varchar(5),EKLEYEN),EKLEMETARIHI,DEGISTIREN' +
        '=Convert(varchar(5),DEGISTIREN),DEGISTIRMETARIHI'
      #9#9#9#9#9'from Inserted'
      #9#9#9#9'fetch next from InsertCursor into @CurID'#9
      #9#9#9'End'
      #9#9'close InsertCursor'#9
      #9#9'deallocate InsertCursor'
      #9'End'
      
        '----------------------------------------------------------------' +
        '-----------'#9#9#9#9#9#9#9#9#9#9#9#9
      ''
      'Set NoCount Off'
      'END'
      '')
    Properties.WordWrap = False
    TabOrder = 1
    Visible = False
    Height = 59
    Width = 387
  end
  object MemoRehberBilgi: TcxMemo
    Left = 253
    Top = 164
    Lines.Strings = (
      
        'create TRIGGER [dbo].[TG_GenotipRehberBilgiEntegrasyon] ON [dbo]' +
        '.[REHBERBILGI] for UPDATE,INSERT,DELETE'
      'as'
      'BEGIN'
      #9'Set NoCount On'
      #9'declare @CurID integer'
      #9'declare @RehberBilgiID int'#9
      #9'declare @Yeri int'
      #9'declare @YerID int'
      #9'declare @Varsayilan int'
      #9'declare @Kod varchar(40)'
      #9'declare @Bilgi varchar(100)'
      #9'declare DeleteCursor cursor for select ID from Deleted'
      #9'declare InsertCursor cursor for select ID from Inserted  '
      
        '----------------------------------------------------------------' +
        '---------'
      
        '--deleted i'#231'in yaz'#305'lacak kodlar... rehberbilgideki delete ve ins' +
        'ertler asl'#305'nda rehberde update olarak '#231'al'#305#351'acak..'
      'if exists(select BILGI from Deleted)'
      #9'begin'
      #9#9'open DeleteCursor '
      #9#9'fetch next from DeleteCursor into @CurID'
      #9#9'while @@FETCH_STATUS = 0 '
      #9#9#9'begin'
      #9#9#9#9'if (select YERI from Deleted where ID=@CurID)in(1,2)'
      #9#9#9#9'begin'#9#9#9
      
        #9#9#9#9#9'Select @RehberBilgiID=D.ID,@Yeri=D.YERI,@YerID=D.YER_ID,@Bi' +
        'lgi=D.BILGI,'
      
        #9#9#9#9#9'@Varsayilan=(select top 1 VARSAYILAN from REHBERAYAR RA whe' +
        're RA.SIRA=D.SIRA AND RA.YERI=D.YERI),'
      
        #9#9#9#9#9'@Kod=(case when D.YERI = 2 then (select R.KOD from REHBER R' +
        ' where R.ID=D.YER_ID) when D.YERI=1 then (select R.KOD from REHB' +
        'ER R where R.ID=(select RI.REHBERID from REHBERILETISIM RI where' +
        ' RI.ID=D.YER_ID)) end )'
      #9#9#9#9#9'from Deleted D where ID = @CurID'
      #9#9#9#9#9
      #9#9#9#9#9'if @Varsayilan in (2,4,6,8,10,20,22,40,41,42,46,48) '
      #9#9#9#9#9#9'Begin'
      #9#9#9#9#9#9#9'if @Varsayilan=2 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ADRES=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=4 begin '#9
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set PK=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=6 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ILCE=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=8 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set IL=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=10 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set FATURABASLIK=null where KO' +
        'D=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=20 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set VERGIDAI=null where KOD=@K' +
        'od'
      #9#9#9#9#9#9#9'end else if @Varsayilan=22 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set VERGINO=null where KOD=@Ko' +
        'd'
      #9#9#9#9#9#9#9'end else if @Varsayilan=40 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ISTEL=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=43 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set FAX=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=42 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set CEP=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=46 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set EMAIL=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=48 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set WEB=null where KOD=@Kod'
      #9#9#9#9#9#9#9'end'#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9'End'
      #9#9#9#9#9'End'
      #9#9#9'fetch next from DeleteCursor into @CurID'#9#9
      #9#9#9'end'#9
      #9'close DeleteCursor'
      #9'deallocate DeleteCursor'#9#9#9#9#9#9
      #9'end'
      
        '----------------------------------------------------------------' +
        '----------'
      '--inserted i'#231'in yaz'#305'lacak olan kodlar...'
      'if exists(select BILGI from Inserted) '
      #9'begin'
      #9#9'open InsertCursor '
      #9#9'fetch next from InsertCursor into @CurID'
      #9#9'while @@FETCH_STATUS = 0 '
      #9#9#9'begin'
      #9#9#9#9'if (select YERI from Inserted where ID=@CurID)in(1,2)'
      #9#9#9#9'begin'#9#9#9
      
        #9#9#9#9#9'Select @RehberBilgiID=I.ID,@Yeri=I.YERI,@YerID=I.YER_ID,@Bi' +
        'lgi=I.BILGI,'
      
        #9#9#9#9#9'@Varsayilan=(select top 1 VARSAYILAN from REHBERAYAR RA whe' +
        're RA.SIRA=I.SIRA AND RA.YERI=I.YERI),'
      
        #9#9#9#9#9'@Kod=(case when I.YERI = 2 then (select R.KOD from REHBER R' +
        ' where R.ID=I.YER_ID) when I.YERI=1 then (select R.KOD from REHB' +
        'ER R where R.ID=(select RI.REHBERID from REHBERILETISIM RI where' +
        ' RI.ID=I.YER_ID)) end )'
      #9#9#9#9#9'from Inserted I where ID = @CurID'
      #9#9#9#9#9
      #9#9#9#9#9'if @Varsayilan in (2,4,6,8,10,20,22,40,41,42,46,48) '
      #9#9#9#9#9#9'Begin'
      #9#9#9#9#9#9#9'if @Varsayilan=2 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ADRES=@Bilgi where KOD=@Ko' +
        'd'
      #9#9#9#9#9#9#9'end else if @Varsayilan=4 begin '#9
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set PK=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=6 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ILCE=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=8 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set IL=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=10 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set FATURABASLIK=@Bilgi where ' +
        'KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=20 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set VERGIDAI=@Bilgi where KOD=' +
        '@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=22 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set VERGINO=@Bilgi where KOD=@' +
        'Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=40 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set ISTEL=@Bilgi where KOD=@Ko' +
        'd'
      #9#9#9#9#9#9#9'end else if @Varsayilan=43 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set FAX=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=42 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set CEP=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end else if @Varsayilan=46 begin'
      
        #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set EMAIL=@Bilgi where KOD=@Ko' +
        'd'
      #9#9#9#9#9#9#9'end else if @Varsayilan=48 begin'
      #9#9#9#9#9#9#9#9'update GEN2005.dbo.REHBER set WEB=@Bilgi where KOD=@Kod'
      #9#9#9#9#9#9#9'end'#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9'End'
      #9#9#9#9#9'End'
      #9#9#9'fetch next from InsertCursor into @CurID'#9#9
      #9#9#9'end'#9
      #9'close InsertCursor'
      #9'deallocate InsertCursor'#9#9#9#9#9#9
      #9'end'
      
        '----------------------------------------------------------------' +
        '-----------'#9#9#9#9#9#9#9#9#9#9#9#9
      ''
      'Set NoCount Off'
      'END'
      ''
      '')
    Properties.WordWrap = False
    TabOrder = 2
    Visible = False
    Height = 59
    Width = 387
  end
  object MemoStokKart: TcxMemo
    Left = 241
    Top = 199
    Lines.Strings = (
      
        'create TRIGGER [dbo].[TG_EntegraStokEntegrasyon] ON [dbo].[STOKK' +
        'ART] for UPDATE,INSERT,DELETE'
      'as'
      'BEGIN'
      #9'Set NoCount On'
      #9'declare @CurID varchar(20),@StokKod varchar(40)'
      #9'declare @Grubu int,@Ozellik int,@Anabirim int,@Birim2 int'
      
        #9'declare @AGrubu nvarchar(40),@AOzellik nvarchar(40),@AAnabirim ' +
        'nvarchar(40),@ABirim2 nvarchar(40)'
      #9'declare DeleteCursor cursor for select KOD from Deleted'
      #9'declare InsertCursor cursor for select KOD from Inserted  '
      
        '----------------------------------------------------------------' +
        '---------'
      '--deleted i'#231'in yaz'#305'lacak kodlar...'
      #9#9'open DeleteCursor '
      #9#9'fetch next from DeleteCursor into @CurID'
      #9#9'while @@FETCH_STATUS = 0 '
      #9#9#9'begin'#9
      #9#9#9#9'select @StokKod=KOD from Deleted where KOD=@CurID '#9#9
      #9#9#9#9'if not exists (select KOD from inserted where KOD=@StokKod)'#9
      #9#9#9#9#9'begin'
      #9#9#9#9#9#9'Delete from ENTEGRA.Dbo.STOKLAR where KOD=@StokKod'#9#9#9#9#9
      #9#9#9#9#9'end'
      #9#9#9#9'fetch next from DeleteCursor into @CurID'
      #9#9#9'End'
      
        '----------------------------------------------------------------' +
        '----------'
      '--inserted ve updated!! i'#231'in yaz'#305'lacak olan kodlar...'
      #9'open InsertCursor '
      #9'fetch next from InsertCursor into @CurID'
      #9'while @@FETCH_STATUS = 0 '#9
      #9#9'begin'#9
      
        #9#9#9'select @StokKod=KOD,@AGrubu=GRUBU,@AOzellik=OZELLIK,@AAnabiri' +
        'm=ANABIRIM,@ABirim2=BIRIM2'
      #9#9#9'from inserted where KOD=@CurID '#9
      #9#9#9
      
        #9#9#9'exec ENTEGRA.dbo.p_INIdenDegerGetirYoksaEkle -2704,@AGrubu,@G' +
        'rubu output--'#39'StokKart_Grubu'#39
      
        #9#9#9'exec ENTEGRA.dbo.p_INIdenDegerGetirYoksaEkle -2705,@AOzellik,' +
        '@Ozellik output--'#39'StokKart_'#214'zellik'#39
      
        #9#9#9'exec ENTEGRA.dbo.p_INIdenDegerGetirYoksaEkle -2702,@AAnabirim' +
        ',@Anabirim output--'#39'StokKart_Anabirim'#39
      
        #9#9#9'exec ENTEGRA.dbo.p_INIdenDegerGetirYoksaEkle -2702,@ABirim2,@' +
        'Birim2 output--'#39'StokKart_Anabirim'#39
      #9#9#9#9
      #9#9#9'if (exists(select KOD from Deleted where KOD=@StokKod))'
      
        #9#9#9'and(exists(select ID from ENTEGRA.dbo.STOKLAR where KOD=@Stok' +
        'Kod))'#9
      #9#9#9#9'begin--iki tarafta da varsa update yoksa delete...'
      #9#9#9#9#9'UPDATE ENTEGRA.dbo.STOKLAR'
      #9#9#9#9#9'SET '
      #9#9#9#9#9#9'KOD=I.KOD,'
      #9#9#9#9#9#9'STOKADI=I.STOKADI,'
      #9#9#9#9#9#9'GRUBU=@Grubu,'
      #9#9#9#9#9#9'OZELLIK=@Ozellik,'
      #9#9#9#9#9#9'OZELKOD=I.OZELKOD,'
      #9#9#9#9#9#9'MUHKODU=I.MUHKODU,'
      #9#9#9#9#9#9'ANABIRIM=@Anabirim,'
      #9#9#9#9#9#9'BIRIM2=@Birim2,'
      #9#9#9#9#9#9'BIRIM2MIKTAR=I.BIRIM2MIKTAR,'
      #9#9#9#9#9#9'MINSTOK=I.MINSTOK,'
      #9#9#9#9#9#9'KDV=I.KDV,'
      #9#9#9#9#9#9'DURUM=I.AKTIF,'
      
        #9#9#9#9#9#9'IZLEME=case when ISNULL(I.SKT_VAR,'#39#39')<>'#39#39' then 1 else 0 en' +
        'd,'
      #9#9#9#9#9#9'EKLEYEN=I.EKLEYEN,'
      #9#9#9#9#9#9'EKLEMETARIHI=I.EKLEMETARIHI,'
      #9#9#9#9#9#9'DEGISTIREN=I.DEGISTIREN,'
      #9#9#9#9#9#9'DEGISTIRMETARIHI=I.DEGISTIRMETARIHI'
      #9#9#9#9#9'from'
      #9#9#9#9#9'ENTEGRA.dbo.STOKLAR S inner join Inserted I on S.KOD=I.KOD'#9
      #9#9#9#9#9'WHERE I.KOD=@StokKod'#9#9#9
      #9#9#9#9'end '
      #9#9#9'else '
      #9#9#9#9'begin'
      #9#9#9#9#9'INSERT INTO ENTEGRA.dbo.STOKLAR'
      #9#9#9#9#9#9'(KOD,STOKADI,GRUBU,OZELLIK,OZELKOD,MUHKODU,'
      #9#9#9#9#9#9'ANABIRIM,BIRIM2,BIRIM2MIKTAR,MINSTOK,KDV,DURUM,'
      #9#9#9#9#9#9'IZLEME,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI)'
      #9#9#9#9#9'select '#9#9#9#9#9#9
      #9#9#9#9#9#9'KOD,STOKADI,@Grubu,@Ozellik,OZELKOD,MUHKODU,'
      #9#9#9#9#9#9'@Anabirim,@Birim2,BIRIM2MIKTAR,MINSTOK,KDV,DURUM=AKTIF,'
      
        #9#9#9#9#9#9'IZLEME=case when ISNULL(SKT_VAR,'#39#39')<>'#39#39' then 1 else 0 end,' +
        ' '
      #9#9#9#9#9#9'EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI'
      #9#9#9#9#9'from inserted where KOD=@CurID '#9#9#9#9#9
      #9#9#9#9'end'
      ''
      #9#9#9'fetch next from DeleteCursor into @CurID'
      #9#9'End'#9#9#9#9#9#9#9#9#9#9
      'close DeleteCursor'
      'close InsertCursor'
      'deallocate DeleteCursor'
      'deallocate InsertCursor'
      'Set NoCount Off'
      'END'
      '')
    Properties.WordWrap = False
    TabOrder = 3
    Visible = False
    Height = 59
    Width = 387
  end
  object MemoStokKartEkProcedure: TcxMemo
    Left = 228
    Top = 231
    Lines.Strings = (
      
        'create procedure [dbo].[p_INIdenDegerGetirYoksaEkle](@Bolum int,' +
        '@Anahtar Varchar(50),@Deger int output)'
      'as'
      'BEGIN'
      #9'declare @maxdeger int'
      #9'declare @mindeger int'
      
        #9'select @Deger=DEGER from GENINI where BOLUM=@Bolum and ANAHTAR=' +
        '@Anahtar'
      #9'if @Deger is null '
      #9#9'begin'
      #9#9#9'select @maxdeger = max(DEGER)from GENINI where BOLUM=@Bolum'
      #9#9#9'select @mindeger = min(DEGER)from GENINI where BOLUM=@Bolum'
      #9#9#9'if @maxdeger>=0 '
      #9#9#9#9'begin'
      #9#9#9#9#9'set @Deger = @maxdeger+1'
      #9#9#9#9'end '
      #9#9#9'else if @mindeger<0 '
      #9#9#9#9'begin'
      #9#9#9#9#9'set @Deger = @mindeger-1'
      #9#9#9#9'end'
      #9#9#9'else  '
      #9#9#9#9'begin'
      #9#9#9#9#9'set @Deger = 1'
      #9#9#9#9'end'
      
        #9#9#9'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)values(@Bolum' +
        ',@Anahtar,@Deger,-1,@Deger)'
      #9#9'end'
      'END'
      '')
    Properties.WordWrap = False
    TabOrder = 4
    Visible = False
    Height = 59
    Width = 387
  end
  object MemoStokFatura: TcxMemo
    Left = 215
    Top = 261
    Lines.Strings = (
      
        'create TRIGGER [dbo].[TG_EntegraStokFaturaAktarimi] ON [dbo].[ST' +
        'OKGIRIS] FOR UPDATE'
      'as'
      'BEGIN'
      'if (select ONAY from inserted)='#39'E'#39'--g'#252'ncellenmesi gerekiyor.'
      #9'Begin'
      ''
      #9#9'--Fatba'#351'l'#305'k Eklenir...'
      #9#9'Declare @FatBasID int'
      #9#9'Declare @RehberID int'
      #9#9'Declare @GirNo int'
      #9#9'Declare @MasrafID int'
      #9#9'Declare @RehIletID int'
      
        #9#9'select @RehberID=R1.ID from ENTEGRA.dbo.REHBER R1 where R1.KOD' +
        '=(Select FIRMAKODU from inserted)'
      #9#9'select @GirNo=GIRNO from inserted'
      
        #9#9'select @MasrafID=ID from ENTEGRA.dbo.MASRAFGELIR M where M.KOD' +
        '=(Select MASRAFMERKEZKOD from inserted)'
      
        #9#9'select top 1 @RehIletID=ID from ENTEGRA.dbo.REHBERILETISIM whe' +
        're REHBERID=@RehberID'
      #9#9'INSERT INTO ENTEGRA.dbo.FATBASLIK'
      
        #9#9#9'(TARIH,TUR,TIPI,REHBERID,FATURATARIH,FATURANO,GIRISDEPO,CIKIS' +
        'DEPO'
      #9#9#9',BASLIK,ADRES,ILCE,IL,VD,VNO,KDVDURUM,FATURA_GON_TARIHI'
      
        #9#9#9',FATURA_MATRAHI,KDV_TUTARI,FATURA_TUTARI,KUR,MASRAFID,ACIKLAM' +
        'A,DURUM,OZELKOD'
      #9#9#9',PROJEID,AKTIVITEID,ACIK_KAPALI)'
      #9#9'SELECT '
      #9#9#9'TARIH,11,1,@RehberID,'
      
        #9#9#9'BELGETARIH,BELGENO,(select D1.ID from ENTEGRA.dbo.DEPOLAR D1 ' +
        'where D1.DEPOADI=HEDEFDEPO),null,'
      #9#9#9'FIRMAADI,'
      
        #9#9#9'ADRES=(SELECT TOP 1 BILGI FROM ENTEGRA.dbo.REHBERBILGI RB (no' +
        'lock) INNER JOIN ENTEGRA.dbo.REHBERAYAR RA (nolock) ON RA.YERI=1' +
        ' and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehIle' +
        'tID AND RA.VARSAYILAN=2),'
      
        #9#9#9'ILCE=(SELECT TOP 1 BILGI FROM ENTEGRA.dbo.REHBERBILGI RB (nol' +
        'ock) INNER JOIN ENTEGRA.dbo.REHBERAYAR RA (nolock) ON RA.YERI=1 ' +
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehIlet' +
        'ID AND RA.VARSAYILAN=6),'
      
        #9#9#9'IL=(SELECT TOP 1 BILGI FROM ENTEGRA.dbo.REHBERBILGI RB (noloc' +
        'k) INNER JOIN ENTEGRA.dbo.REHBERAYAR RA (nolock) ON RA.YERI=1 an' +
        'd RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehIletID' +
        ' AND RA.VARSAYILAN=8),'
      
        #9#9#9'VERGIDAI=(SELECT TOP 1  BILGI FROM ENTEGRA.dbo.REHBERAYAR RA ' +
        'INNER JOIN ENTEGRA.dbo.REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.' +
        'YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20),'
      
        #9#9#9'VERGINO=(SELECT TOP 1  BILGI FROM ENTEGRA.dbo.REHBERAYAR RA I' +
        'NNER JOIN ENTEGRA.dbo.REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.Y' +
        'ERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22),'
      #9#9#9#39'Hari'#231#39',GetDate(),'
      
        #9#9#9'FATURA_MATRAHI=(select sum(SGH2.TUTAR) from GEN2005.dbo.STOKG' +
        'IRHAR SGH2 where SGH2.GIRNO=I.GIRNO) ,'
      
        #9#9#9'KDV_TUTARI=(select sum(SGH2.TUTAR*SGH2.KDV/100) from GEN2005.' +
        'dbo.STOKGIRHAR SGH2 where SGH2.GIRNO=I.GIRNO) ,'
      
        #9#9#9'FATURA_TUTARI=(select sum(SGH2.TUTAR*(SGH2.KDV+100)/100) from' +
        ' GEN2005.dbo.STOKGIRHAR SGH2 where SGH2.GIRNO=I.GIRNO) ,'
      
        #9#9#9#39'TL'#39',@MasrafID,NOTLAR,1,convert(varchar(10),@GirNo),-1,-1,0  ' +
        '  '
      #9#9'FROM inserted I'
      #9#9'--BURADA SCOPE '#199'ALI'#350'MIYOR..'
      #9#9'select @FatBasID=MAX(ID) FROM ENTEGRA.dbo.FATBASLIK'
      #9#9
      #9#9'--Sat'#305'rlar Eklenir...'
      #9#9'INSERT INTO ENTEGRA.dbo.FATURA'
      '           (FATBASID,REHBERID,TUR,URUNID'
      '          ,ACIKLAMA,MASRAFID,SKT'
      
        '           ,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,ISKONTO,ISKONTO2,' +
        'KDV,KUR)'
      
        #9#9'SELECT @FatBasID,@RehberID,1,(select S1.ID from ENTEGRA.dbo.ST' +
        'OKLAR S1 where S1.KOD=SGH.STOKKOD)'
      #9#9#9'  ,'#39#39',@MasrafID,SKT'
      
        #9#9#9'  ,ADET,(select convert(int,R3.DEGER) from ENTEGRA.dbo.GENINI' +
        ' R3 where R3.BOLUM=-2702 and R3.ANAHTAR=SGH.BIRIM)'
      #9#9#9'  ,MIKTAR,BIRIMFIYAT,TUTAR,ISK1,ISK2,KDV,'#39'TL'#39
      #9#9'FROM GEN2005.dbo.STOKGIRHAR SGH'
      #9#9'WHERE SGH.GIRNO=@GirNo'
      #9#9'  '
      #9#9'--Son olarak kasaya bir plan olu'#351'tural'#305'm...'
      #9#9'if (select ODEME_TURU from inserted) in ('#39'KASA'#39','#39'BANKA'#39')'
      #9#9'begin'
      #9#9#9'INSERT INTO ENTEGRA.dbo.KASA'
      #9#9#9#9'   (TUR,PLANTARIHI,REHBERID,HESAPID,MUSTERIHESAPID'
      #9#9#9#9'   ,BORC,ALACAK,KUR,HESAPTURU,MASRAFID,ACIKLAMA,FATURAID)'
      #9#9#9'select'
      #9#9#9#9'   71,ODEME_TARIHI,@RehberID'
      #9#9#9#9'   ,HESAPID=case '
      
        #9#9#9#9'   when ODEME_TURU='#39'KASA'#39' then (select top 1 ID from ENTEGRA' +
        '.dbo.KASALAR where KUR='#39'TL'#39' and KASATUR=1)'
      
        #9#9#9#9'   when ODEME_TURU='#39'BANKA'#39' then (select top 1 ID from ENTEGR' +
        'A.dbo.BANKAHESAPLAR where REHBERID=-1 and VARSAYILAN=1) end'
      #9#9#9#9'   ,MUSTERIHESAPID=case '
      #9#9#9#9'   when ODEME_TURU='#39'KASA'#39' then null'
      
        #9#9#9#9'   when ODEME_TURU='#39'BANKA'#39' then (select top 1 ID from ENTEGR' +
        'A.dbo.BANKAHESAPLAR where REHBERID=@RehberID and VARSAYILAN=1) e' +
        'nd'
      
        #9#9#9#9'   ,0,(select TUTAR from ENTEGRA.dbo.FATBASLIK FB2 where FB2' +
        '.ID=@FatBasID)'
      #9#9#9#9'   ,'#39'TL'#39
      #9#9#9#9'   ,HESAPTURU=case'
      #9#9#9#9'   when ODEME_TURU='#39'KASA'#39' then '#39'K'#39
      #9#9#9#9'   when ODEME_TURU='#39'BANKA'#39' then '#39'B'#39' end'
      #9#9#9#9'   ,@MasrafID,BELGENO+'#39' nolu fatura '#246'demesi.'#39',@FatBasID'
      #9#9#9'from'
      #9#9#9#9#9'inserted'#9#9#9#9' '
      #9#9'end'#9
      #9'End'
      'END'
      '')
    Properties.WordWrap = False
    TabOrder = 5
    Visible = False
    Height = 59
    Width = 387
  end
  object tabEslestirme: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = tabEslestirmeBeforePost
    OnNewRecord = tabEslestirmeNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM ENTEGRASYONESLESTIRME'
      'WHERE BAGLANTIID = :PBAGLANTIID AND'
      'YER = :PYER')
    Left = 380
    Top = 119
  end
  object dtsEslestirme: TDataSource
    DataSet = tabEslestirme
    OnStateChange = dtsEslestirmeStateChange
    Left = 379
    Top = 166
  end
  object TabAktarimAyarlari: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabAktarimAyarlariBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM BAGLANTILAR where TUR=1')
    Left = 326
    Top = 196
  end
  object DtsAktarimAyarlari: TDataSource
    DataSet = TabAktarimAyarlari
    OnStateChange = DtsAktarimAyarlariStateChange
    Left = 326
    Top = 242
  end
  object cnn2query: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 99
    Top = 160
  end
end
