object UretimEmriWizardDlg: TUretimEmriWizardDlg
  Left = 0
  Top = 0
  ActiveControl = PageControlUst
  Caption = #220'retim Sihirbaz'#305
  ClientHeight = 670
  ClientWidth = 1196
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 1196
    Height = 670
    ActivePage = JvWizardInteriorPage1
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Back'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Next >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = 'Son'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      1196
      670)
    object JvWizardInteriorPage1: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #220'retim Emri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      Caption = 'JvWizardInteriorPage1'
      object PanelUst: TPanel
        Left = 0
        Top = 70
        Width = 1196
        Height = 168
        Align = alTop
        BevelOuter = bvNone
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1190
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 70
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
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object KaydetTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 10
            ImageName = 'PngImage9'
            Style = tbsTextButton
            OnClick = KaydetTusClick
          end
          object IptalTus: TToolButton
            Left = 70
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsTextButton
            OnClick = IptalTusClick
          end
          object ToolButton8: TToolButton
            Left = 140
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 148
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
        end
        object PageControlUst: TcxPageControl
          Left = 0
          Top = 35
          Width = 1196
          Height = 230
          Align = alTop
          Color = clSilver
          ParentBackground = False
          ParentColor = False
          TabOrder = 1
          Properties.ActivePage = cxTabSheet1
          Properties.CustomButtons.Buttons = <>
          OnChange = PageControlUstChange
          ClientRectBottom = 226
          ClientRectLeft = 4
          ClientRectRight = 1192
          ClientRectTop = 27
          object cxTabSheet1: TcxTabSheet
            AllowCloseButton = False
            Caption = 'Genel'
            ImageIndex = 0
            object PanelGenelUst: TPanel
              Left = 0
              Top = 0
              Width = 1188
              Height = 199
              Align = alClient
              BevelOuter = bvNone
              Color = clMedGray
              ParentBackground = False
              TabOrder = 0
              object Label19: TcxLabel
                Left = 875
                Top = 28
                Caption = 'Ba'#351'lama Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditBasTar: TcxDBDateEdit
                Left = 970
                Top = 27
                DataBinding.DataField = 'BASTAR'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Kind = ckDateTime
                TabOrder = 8
                Width = 125
              end
              object EditBitTar: TcxDBDateEdit
                Left = 970
                Top = 51
                DataBinding.DataField = 'BITTAR'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Kind = ckDateTime
                TabOrder = 9
                Width = 125
              end
              object cxLabel4: TcxLabel
                Left = 875
                Top = 54
                Caption = 'Biti'#351' Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxLabel3: TcxLabel
                Left = 627
                Top = 52
                Caption = 'Onaylayan'
                Transparent = True
              end
              object EditUrunSec: TcxDBButtonEdit
                Left = 88
                Top = 27
                DataBinding.DataField = 'STOKADI'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = BeUrunPropertiesButtonClick
                TabOrder = 4
                Width = 314
              end
              object cxLabel2: TcxLabel
                Left = 3
                Top = 29
                Caption = #220'r'#252'n'
                Transparent = True
              end
              object cxLabel6: TcxLabel
                Left = 3
                Top = 52
                Caption = #304'stenen Miktar'
                Transparent = True
              end
              object CbBirim: TcxDBImageComboBox
                Left = 271
                Top = 53
                RepositoryItem = Tablo.repStokAnaBirim
                DataBinding.DataField = 'BIRIM'
                DataBinding.DataSource = DtsUretimEmri
                Enabled = False
                Properties.Items = <>
                TabOrder = 6
                Width = 131
              end
              object EditAdet: TcxDBCurrencyEdit
                Left = 89
                Top = 53
                RepositoryItem = Tablo.RepCurrencyAdetGenel
                DataBinding.DataField = 'ADET'
                DataBinding.DataSource = DtsUretimEmri
                Enabled = False
                TabOrder = 5
                Width = 89
              end
              object cxLabel7: TcxLabel
                Left = 236
                Top = 52
                Caption = 'Birim'
                Transparent = True
              end
              object BEOnaylayan: TcxButtonEdit
                Left = 701
                Top = 51
                Properties.Buttons = <
                  item
                    Default = True
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      424D360400000000000036000000280000001000000010000000010020000000
                      000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00EFF7EFFF4AA54AFF189418FFA5D6A5FFFFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00EFF7EFFF39A539FF10AD29FF18B529FF089410FFA5D6A5FFFFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FF
                      F7FF39AD39FF18AD31FF18B531FF10AD29FF10B529FF089410FFADDEADFFFFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF7FF42B5
                      42FF18B531FF18B539FF18B531FF31BD4AFF18AD31FF10AD29FF089410FFADDE
                      ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0052BD5AFF21B5
                      42FF21BD42FF21B542FF10A521FF189418FF63C673FF18B531FF10B529FF0894
                      10FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039BD4AFF42C6
                      63FF21BD4AFF18B529FF63C663FFEFF7EFFF39AD39FF63C673FF18B531FF10B5
                      29FF109410FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF009CE7A5FF42C6
                      5AFF39BD4AFF63CE6BFFFFFFFF00FFFFFF00EFF7EFFF31A531FF63CE73FF18B5
                      31FF10B529FF109410FFB5E7B5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7
                      D6FFB5EFBDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7EFFF31A531FF63CE
                      73FF18B531FF10B529FF109410FFBDDEBDFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7E7FF29A5
                      29FF63CE73FF18B531FF18B531FF189418FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7
                      E7FF29A529FF63CE7BFF29BD4AFF299C31FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00E7F7E7FF31AD31FF31A531FFCEE7CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                    Kind = bkGlyph
                  end
                  item
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      424D360400000000000036000000280000001000000010000000010020000000
                      000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFEFF7FF3939
                      BDFF2129B5FF8484D6FFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B
                      CEFF7373C6FFD6D6EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007373CEFF1842
                      F7FF184AF7FF1031D6FF3131BDFFDEDEF7FFFFFFFF00FFFFFF006B6BD6FF0829
                      D6FF0831D6FF0010B5FF7373CEFFFFFFFF00FFFFFF00FFFFFF003131BDFF2152
                      F7FF2152FFFF2152FFFF1842E7FF1821B5FFC6C6EFFF6B6BCEFF1031DEFF1042
                      F7FF1039F7FF0839EFFF0018BDFFA5A5DEFFFFFFFF00FFFFFF00BDBDE7FF1831
                      DEFF295AFFFF2152FFFF2152FFFF184AEFFF0810B5FF1031DEFF184AFFFF1042
                      F7FF1042F7FF1042F7FF0839EFFF4242B5FFFFFFFF00FFFFFF00ADADE7FF2139
                      DEFF396BFFFF295AFFFF295AFFFF295AFFFF2152FFFF1852FFFF184AFFFF184A
                      F7FF1042F7FF1039EFFF1821B5FFBDBDE7FFFFFFFF00FFFFFF00FFFFFF009C9C
                      E7FF2129CEFF396BFFFF316BFFFF295AFFFF295AFFFF2152FFFF214AFFFF184A
                      FFFF1039EFFF3139BDFFE7E7F7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00E7E7F7FF4242CEFF314AE7FF396BFFFF315AFFFF295AFFFF2152FFFF1839
                      E7FF4242BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00B5B5EFFF2142DEFF396BFFFF3163FFFF315AFFFF295AFFFF184A
                      E7FF3131BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF004242D6FF4A7BFFFF4273FFFF396BFFFF396BFFFF295AFFFF215A
                      FFFF1039D6FF6B6BD6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00D6D6F7FF2939DEFF5284FFFF4273FFFF3963F7FF1018C6FF396BFFFF295A
                      FFFF2152FFFF1021C6FFB5B5EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF007373E7FF527BF7FF5284FFFF4A7BFFFF2129CEFFBDBDEFFF2129CEFF396B
                      FFFF2152FFFF184AEFFF2121BDFFEFEFFFFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF003139DEFF6B9CFFFF5A8CFFFF294AE7FFA5A5EFFFFFFFFF00CECEF7FF1829
                      CEFF3163FFFF2152FFFF1039DEFF6363CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF006B6BEFFF3952E7FF5A84FFFF4242DEFFFFFFFF00FFFFFF00FFFFFF00B5B5
                      EFFF1829D6FF295AFFFF1031E7FF3131C6FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00C6C6F7FF5A5AD6FFCECEF7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF009C9CE7FF4242CEFFB5B5E7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                    Kind = bkGlyph
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = BeOnaylayanPropertiesButtonClick
                TabOrder = 15
                Width = 163
              end
              object cbOnaylayacak: TcxDBImageComboBox
                Left = 701
                Top = 27
                DataBinding.DataField = 'ONAYLAYACAK'
                DataBinding.DataSource = DtsUretimEmri
                Properties.ImmediatePost = True
                Properties.ImmediateUpdateText = True
                Properties.Items = <>
                TabOrder = 16
                Width = 163
              end
              object cxLabel9: TcxLabel
                Left = 627
                Top = 28
                Caption = 'Onaylayacak'
                Transparent = True
              end
              object memoACIKLAMA: TcxDBMemo
                Left = 509
                Top = 76
                Align = alCustom
                DataBinding.DataField = 'ACIKLAMA'
                DataBinding.DataSource = DtsUretimEmri
                TabOrder = 18
                Height = 25
                Width = 355
              end
              object cxLabel1: TcxLabel
                Left = 408
                Top = 76
                Caption = 'A'#231#305'klama'
                Transparent = True
              end
              object BeditProje: TcxButtonEdit
                Left = 88
                Top = 78
                ParentShowHint = False
                Properties.Buttons = <
                  item
                    Caption = '++'
                    Default = True
                    Hint = 'Ekle'
                    Kind = bkText
                  end
                  item
                    Caption = '+'
                    Hint = 'Sil'
                    Kind = bkText
                  end
                  item
                    Caption = '-'
                    Kind = bkText
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = BeditProjePropertiesButtonClick
                ShowHint = True
                Style.BorderStyle = ebsOffice11
                Style.LookAndFeel.Kind = lfStandard
                Style.LookAndFeel.NativeStyle = False
                StyleDisabled.LookAndFeel.Kind = lfStandard
                StyleDisabled.LookAndFeel.NativeStyle = False
                StyleFocused.LookAndFeel.Kind = lfStandard
                StyleFocused.LookAndFeel.NativeStyle = False
                StyleHot.LookAndFeel.Kind = lfStandard
                StyleHot.LookAndFeel.NativeStyle = False
                StyleReadOnly.LookAndFeel.Kind = lfStandard
                StyleReadOnly.LookAndFeel.NativeStyle = False
                TabOrder = 7
                Width = 314
              end
              object LabelProje: TcxLabel
                Left = 3
                Top = 76
                Caption = 'Proje Kodu'
                Transparent = True
              end
              object ComboDURUM: TcxDBImageComboBox
                Left = 509
                Top = 51
                RepositoryItem = Tablo.RepAktifPasif
                DataBinding.DataField = 'DURUM'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Items = <>
                TabOrder = 21
                Width = 110
              end
              object LabelDurum: TcxLabel
                Left = 408
                Top = 54
                Caption = 'Durum'
                FocusControl = ComboDURUM
                Transparent = True
                OnClick = LabelDurumClick
              end
              object cxLabel11: TcxLabel
                Left = 627
                Top = 4
                Caption = 'Talep Eden'
                Transparent = True
              end
              object cbTalepEden: TcxDBImageComboBox
                Left = 701
                Top = 2
                RepositoryItem = Tablo.repOnlinePersonel
                DataBinding.DataField = 'TALEPEDEN'
                DataBinding.DataSource = DtsUretimEmri
                Properties.ImmediatePost = True
                Properties.ImmediateUpdateText = True
                Properties.Items = <>
                TabOrder = 24
                Width = 163
              end
              object cxLabel12: TcxLabel
                Left = 877
                Top = 3
                Caption = 'Talep/Teslim Trh'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditTalepTar: TcxDBDateEdit
                Left = 970
                Top = 2
                DataBinding.DataField = 'TALEPTARIHI'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Kind = ckDateTime
                TabOrder = 26
                Width = 125
              end
              object cxLabel13: TcxLabel
                Left = 3
                Top = 5
                Caption = 'Emir No'
                Transparent = True
              end
              object EditEmirNo: TcxDBTextEdit
                Left = 125
                Top = 2
                DataBinding.DataField = 'EMIRNO'
                DataBinding.DataSource = DtsUretimEmri
                TabOrder = 2
                Width = 89
              end
              object cxLabel14: TcxLabel
                Left = 408
                Top = 5
                Caption = 'Emir T'#252'r'#252
                FocusControl = ComboEMIRTURU
                Transparent = True
                OnClick = LabelDurumClick
              end
              object ComboEMIRTURU: TcxDBImageComboBox
                Left = 509
                Top = 1
                RepositoryItem = Tablo.repUretimEmirTuru
                DataBinding.DataField = 'EMIRTURU'
                DataBinding.DataSource = DtsUretimEmri
                Properties.DropDownRows = 10
                Properties.Items = <>
                TabOrder = 29
                Width = 110
              end
              object cxLabel15: TcxLabel
                Left = 877
                Top = 78
                Caption = 'Sipari'#351' No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditSIPARISNO: TcxDBTextEdit
                Left = 970
                Top = 75
                DataBinding.DataField = 'SIPARIS_NO'
                DataBinding.DataSource = DtsUretimEmri
                Enabled = False
                TabOrder = 32
                Width = 125
              end
              object cxLabel8: TcxLabel
                Left = 408
                Top = 28
                Caption = 'Ana Kaynak'
                Transparent = True
                OnClick = LabelDurumClick
              end
              object EditKaynak: TcxButtonEdit
                Left = 509
                Top = 26
                ParentShowHint = False
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.MaxLength = 0
                Properties.ReadOnly = True
                Properties.OnButtonClick = EditKaynakPropertiesButtonClick
                ShowHint = True
                TabOrder = 30
                TextHint = 'KABUL_EDEN'
                Width = 110
              end
              object EditSERINO: TcxDBTextEdit
                Left = 87
                Top = 2
                DataBinding.DataField = 'SERINO'
                DataBinding.DataSource = DtsUretimEmri
                TabOrder = 1
                Width = 37
              end
              object EditSTOKKOD: TcxDBTextEdit
                Left = 279
                Top = 2
                DataBinding.DataField = 'STOKKOD'
                DataBinding.DataSource = DtsUretimEmri
                Enabled = False
                Properties.ReadOnly = True
                TabOrder = 3
                Width = 123
              end
              object cxLabel10: TcxLabel
                Left = 218
                Top = 5
                Caption = #220'r'#252'n Kodu'
                Transparent = True
              end
              object cxDBDateEdit1: TcxDBDateEdit
                Left = 1098
                Top = 2
                DataBinding.DataField = 'TERMINTARIHI'
                DataBinding.DataSource = DtsUretimEmri
                Properties.Kind = ckDateTime
                Properties.ReadOnly = True
                Style.Color = clMedGray
                TabOrder = 35
                Width = 88
              end
            end
          end
          object EkAlanlarEkr: TcxTabSheet
            Caption = 'Ek Alanlar'
            ImageIndex = 1
          end
          object EkAlanlarEkr2: TcxTabSheet
            Caption = 'Ek Alanlar2'
            ImageIndex = 2
          end
          object EkAlanlarEkr3: TcxTabSheet
            Caption = 'EkAlanlarEkr3'
            ImageIndex = 3
          end
        end
      end
      object cxPageControl1: TcxPageControl
        Left = 0
        Top = 246
        Width = 1196
        Height = 382
        Align = alClient
        TabOrder = 1
        Properties.ActivePage = SheetUretimAgaci
        Properties.CustomButtons.Buttons = <>
        OnPageChanging = cxPageControl1PageChanging
        ClientRectBottom = 378
        ClientRectLeft = 4
        ClientRectRight = 1192
        ClientRectTop = 24
        object SheetUretimAgaci: TcxTabSheet
          Caption = #220'retim A'#287'ac'#305
          ImageIndex = 0
          object ToolBar5: TToolBar
            Left = 0
            Top = 0
            Width = 1188
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 89
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
            Images = Tablo.PNGImageList2
            List = True
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object SatirKaydet: TToolButton
              Left = 0
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = SatirKaydetClick
            end
            object SatirIptal: TToolButton
              Left = 89
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = SatirIptalClick
            end
            object Yenile: TToolButton
              Left = 178
              Top = 0
              Caption = 'Yenile'
              ImageIndex = 9
              ImageName = 'PngImage9'
              OnClick = YenileClick
            end
            object OpOlustur: TToolButton
              Left = 267
              Top = 0
              Caption = 'Opr. Olu'#351'tur'
              DropdownMenu = PopupOperasyonOlustur
              EnableDropdown = True
              ImageIndex = 12
              ImageName = 'PngImage12'
              Indeterminate = True
            end
            object SatirSil: TToolButton
              Left = 356
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = SatirSilClick
            end
            object ToolButton2: TToolButton
              Left = 445
              Top = 0
              Width = 8
              Caption = 'ToolButton2'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object BtnDonustur: TToolButton
              Left = 453
              Top = 0
              Caption = 'D'#246'n'#252#351't'#252'r'
              ImageIndex = 11
              ImageName = 'PngImage11'
              OnClick = BtnDonusturClick
            end
          end
          object TreeUretimAgaci: TcxDBTreeList
            Left = 0
            Top = 24
            Width = 1188
            Height = 330
            Align = alClient
            Bands = <
              item
              end>
            DataController.DataSource = DtsUretimEmriDetay
            DataController.ParentField = 'USTID'
            DataController.KeyField = 'ID'
            LookAndFeel.ScrollbarMode = sbmClassic
            Navigator.Buttons.CustomButtons = <>
            OptionsData.Editing = False
            OptionsData.Deleting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideFocusRect = False
            OptionsSelection.InvertSelect = False
            OptionsSelection.MultiSelect = True
            OptionsView.Footer = True
            OptionsView.Indicator = True
            PopupMenu = PopupOperasyonOlustur
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 1
            OnCustomDrawDataCell = TreeUretimAgaciCustomDrawDataCell
            object TreeUretimAgacicxDBTreeListID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'ID'
              Width = 100
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListGereksinim: TcxDBTreeListColumn
              Caption.Text = #304'stenen'
              DataBinding.FieldName = 'MIKTAR'
              Width = 59
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListBirim: TcxDBTreeListColumn
              RepositoryItem = Tablo.repStokAnaBirim
              Visible = False
              Caption.Text = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              Width = 100
              Position.ColIndex = 10
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListAd: TcxDBTreeListColumn
              Caption.Text = 'Ad'
              DataBinding.FieldName = 'AD'
              Width = 190
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxURUNNO: TcxDBTreeListColumn
              Caption.Text = #220'r'#252'n No'
              DataBinding.FieldName = 'URUNNO'
              Options.Editing = False
              Width = 90
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListANABIRIM: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.repStokAnaBirim
              VisibleForExpressionEditor = bTrue
              Caption.Text = 'Birim'
              DataBinding.FieldName = 'ANABIRIM'
              Width = 28
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListKod: TcxDBTreeListColumn
              Caption.Text = 'Kod'
              DataBinding.FieldName = 'KOD'
              Width = 111
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListUretilecek: TcxDBTreeListColumn
              Caption.Text = #220'retilecek(Op.)'
              DataBinding.FieldName = 'URETILECEK'
              Width = 80
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListYuzde: TcxDBTreeListColumn
              PropertiesClassName = 'TcxProgressBarProperties'
              Properties.OverloadValue = 100.000000000000000000
              Properties.ShowPeak = True
              Visible = False
              Caption.Text = 'Y'#252'zde'
              DataBinding.FieldName = 'YuzdeHesap'
              Width = 87
              Position.ColIndex = 12
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListTuketilen: TcxDBTreeListColumn
              Caption.Text = 'T'#252'ketilen(Fi'#351')'
              DataBinding.FieldName = 'TUKETILEN'
              Width = 73
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListUretilen: TcxDBTreeListColumn
              Caption.Text = #220'retilen(Fi'#351')'
              DataBinding.FieldName = 'URETILEN'
              Width = 69
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListDepo: TcxDBTreeListColumn
              Caption.Text = 'Depo Durumu'
              DataBinding.FieldName = 'DEPODURUMU'
              Width = 75
              Position.ColIndex = 9
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListBirimMaliyet: TcxDBTreeListColumn
              RepositoryItem = Tablo.RepCurrencyBF
              Caption.Text = 'Birim Maliyet'
              DataBinding.FieldName = 'BIRIMMALIYET'
              Options.Editing = False
              Width = 91
              Position.ColIndex = 13
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListToplamMaliyet: TcxDBTreeListColumn
              RepositoryItem = Tablo.RepCurrencyGenel
              Caption.Text = 'Toplam Maliyet'
              DataBinding.FieldName = 'TOPLAMMALIYET'
              Options.Editing = False
              Width = 87
              Position.ColIndex = 15
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <
                item
                  AlignHorz = taLeftJustify
                  Kind = skSum
                end>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListKur: TcxDBTreeListColumn
              Caption.Text = 'P. Birimi'
              DataBinding.FieldName = 'KUR'
              Options.Editing = False
              Width = 54
              Position.ColIndex = 16
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListBIRIMURETIMMALIYETI: TcxDBTreeListColumn
              RepositoryItem = Tablo.RepCurrencyBF
              Caption.Text = 'Birim '#220'retim Maliyeti'
              DataBinding.FieldName = 'BIRIMURETIMMALIYETI'
              Options.Editing = False
              Width = 105
              Position.ColIndex = 14
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <
                item
                  AlignHorz = taLeftJustify
                  Kind = skSum
                end>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeUretimAgacicxDBTreeListDEPOGEREKSINIM: TcxDBTreeListColumn
              Caption.Text = 'Depo Gereksinimi'
              DataBinding.FieldName = 'DEPOGEREKSINIM'
              Width = 89
              Position.ColIndex = 11
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
        end
        object SheetOperasyonlar: TcxTabSheet
          Caption = 'Operasyon'
          ImageIndex = 1
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 1188
            Height = 209
            Align = alTop
            TabOrder = 0
            object GridUrtOperasyon: TcxGrid
              Left = 1
              Top = 25
              Width = 1186
              Height = 183
              Align = alClient
              TabOrder = 0
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridUrtOperasyonView: TcxGridDBTableView
                PopupMenu = PopupUretimFisi
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridUrtOperasyonViewCanFocusRecord
                DataController.DataSource = DtsUretimOperasyon
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridUrtOperasyonViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  Visible = False
                  Options.Editing = False
                  Options.Focusing = False
                end
                object GridUrtOperasyonViewURUNNO: TcxGridDBColumn
                  Caption = #220'r'#252'n No'
                  DataBinding.FieldName = 'URUNNO'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                end
                object GridUrtOperasyonViewSTOKKODU: TcxGridDBColumn
                  Caption = 'Stok Kodu'
                  DataBinding.FieldName = 'STOKKODU'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                end
                object GridUrtOperasyonViewSTOKADI: TcxGridDBColumn
                  Caption = #220'retilecek Stok'
                  DataBinding.FieldName = 'STOKADI'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                  Width = 89
                end
                object EditRESIM: TcxGridDBColumn
                  Caption = 'Resim'
                  DataBinding.FieldName = 'RESIM'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.DropDownRows = 1
                  Properties.Images = Tablo.imgScheduler
                  Properties.ImmediateDropDownWhenKeyPressed = False
                  Properties.Items = <
                    item
                      Value = 0
                    end
                    item
                      ImageIndex = 19
                      Value = 1
                    end>
                  Properties.OnButtonClick = EditRESIMPropertiesButtonClick
                end
                object GridUrtOperasyonDDOKUMAN: TcxGridDBColumn
                  Caption = 'Dok'#252'man'
                  DataBinding.FieldName = 'DOKUMAN'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.DropDownRows = 1
                  Properties.Images = Tablo.imgScheduler
                  Properties.ImmediateDropDownWhenKeyPressed = False
                  Properties.Items = <
                    item
                      Value = 0
                    end
                    item
                      ImageIndex = 15
                      Value = 1
                    end>
                  Properties.OnButtonClick = GridUrtOperasyonDDOKUMANPropertiesButtonClick
                end
                object GridUrtOperasyonViewPERSONEL: TcxGridDBColumn
                  Caption = 'Sorumlu'
                  DataBinding.FieldName = 'PERSONELAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.OnButtonClick = GridUrtOperasyonViewPERSONELPropertiesButtonClick
                  Width = 56
                end
                object GridUrtOperasyonViewBASTAR: TcxGridDBColumn
                  Caption = 'Ba'#351'lama(Plan)'
                  DataBinding.FieldName = 'BASTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.DateButtons = [btnClear, btnNow, btnToday]
                  Properties.ImmediatePost = True
                  Properties.Kind = ckDateTime
                  Width = 115
                end
                object GridUrtOperasyonViewBITTAR: TcxGridDBColumn
                  Caption = 'Biti'#351'(Plan)'
                  DataBinding.FieldName = 'BITTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.DateButtons = [btnClear, btnNow, btnToday]
                  Properties.ImmediatePost = True
                  Properties.Kind = ckDateTime
                  Width = 115
                end
                object GridUrtOperasyonViewLOKASYON: TcxGridDBColumn
                  Caption = 'Lokasyon'
                  DataBinding.FieldName = 'LOKASYONADI'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = True
                  Properties.OnButtonClick = GridUrtOperasyonDBTableView1LOKASYONPropertiesButtonClick
                  Width = 75
                end
                object GridUrtOperasyonViewISMERKEZI: TcxGridDBColumn
                  Caption = #304'stasyon'
                  DataBinding.FieldName = 'ISMERKEZIADI'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = True
                  Properties.OnButtonClick = GridUrtOperasyonDBTableView1ISMERKEZIPropertiesButtonClick
                  Width = 71
                end
                object GridUrtOperasyonViewGIRISDEPO: TcxGridDBColumn
                  Caption = 'Giri'#351' Depo'
                  DataBinding.FieldName = 'GIRISDEPO'
                  RepositoryItem = Tablo.RepStokUretimDepolar
                end
                object GridUrtOperasyonViewCIKISDEPO: TcxGridDBColumn
                  Caption = #199#305'k'#305#351' Depo'
                  DataBinding.FieldName = 'CIKISDEPO'
                  RepositoryItem = Tablo.RepStokUretimDepolar
                end
                object GridUrtOperasyonViewADET: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                end
                object GridUrtOperasyonViewBIRIM: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  RepositoryItem = Tablo.repStokAnaBirim
                  Options.Editing = False
                  Options.Focusing = False
                end
                object GridUrtOperasyonViewGERCEKLESEN: TcxGridDBColumn
                  Caption = 'Ger'#231'ekle'#351'en'
                  DataBinding.FieldName = 'GERCEKLESEN'
                  Options.Editing = False
                  Options.Focusing = False
                  Width = 78
                end
                object GridUrtOperasyonViewGBASTAR: TcxGridDBColumn
                  Caption = 'Ba'#351'lama(Ger'#231'ekle'#351'en)'
                  DataBinding.FieldName = 'GBASTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.ImmediatePost = True
                  Properties.Kind = ckDateTime
                  Options.Editing = False
                  Options.Focusing = False
                  Width = 115
                end
                object GridUrtOperasyonViewGBITTAR: TcxGridDBColumn
                  Caption = 'Biti'#351'(Ger'#231'ekle'#351'en)'
                  DataBinding.FieldName = 'GBITTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.ImmediatePost = True
                  Properties.Kind = ckDateTime
                  Options.Editing = False
                  Options.Focusing = False
                  Width = 115
                end
                object GridUrtOperasyonViewACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 274
                end
              end
              object GridUrtOperasyonLevel1: TcxGridLevel
                GridView = GridUrtOperasyonView
              end
            end
            object ToolBar1: TToolBar
              Left = 1
              Top = 1
              Width = 1186
              Height = 24
              Margins.Bottom = 0
              AutoSize = True
              ButtonWidth = 62
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
              Images = Tablo.PNGImageList2
              List = True
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 1
              Transparent = True
              object OperasyonKaydet: TToolButton
                Left = 0
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = OperasyonKaydetClick
              end
              object OperasyonIptal: TToolButton
                Left = 62
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = OperasyonIptalClick
              end
              object OperasyonSil: TToolButton
                Left = 124
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = OperasyonSilClick
              end
              object OperasyonYenile: TToolButton
                Left = 186
                Top = 0
                Caption = 'Yenile'
                ImageIndex = 9
                ImageName = 'PngImage9'
                OnClick = OperasyonYenileClick
              end
              object ToolButton1: TToolButton
                Left = 248
                Top = 0
                Caption = #220'ret'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = kalaniuretClick
              end
            end
          end
          object Panel3: TPanel
            Left = 0
            Top = 209
            Width = 1188
            Height = 145
            Align = alClient
            TabOrder = 1
            object cxPageControl2: TcxPageControl
              Left = 1
              Top = 1
              Width = 1186
              Height = 143
              Align = alClient
              TabOrder = 0
              Properties.ActivePage = SheetIsZaman
              Properties.CustomButtons.Buttons = <>
              ClientRectBottom = 139
              ClientRectLeft = 4
              ClientRectRight = 1182
              ClientRectTop = 24
              object SheetIsZaman: TcxTabSheet
                Caption = #304#351' Zaman Personel'
                ImageIndex = 2
                object GridIsZaman: TcxGrid
                  Left = 0
                  Top = 23
                  Width = 1178
                  Height = 92
                  Align = alClient
                  TabOrder = 0
                  object GridIsZamanView: TcxGridDBTableView
                    PopupMenu = PopupIsZamanPer
                    OnDblClick = IsZamanDuzenleClick
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    OnCanFocusRecord = GridIsZamanViewCanFocusRecord
                    DataController.DataSource = DtsUretimOperasyonPersonel
                    DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <>
                    DataController.Summary.SummaryGroups = <>
                    OptionsCustomize.ColumnsQuickCustomization = True
                    OptionsView.GroupByBox = False
                    OptionsView.Indicator = True
                    object cxGridDBTARIH: TcxGridDBColumn
                      Caption = 'Tarih'
                      DataBinding.FieldName = 'BASLAMA'
                      PropertiesClassName = 'TcxDateEditProperties'
                      Properties.DateButtons = [btnClear, btnToday]
                      Options.Editing = False
                      Width = 68
                    end
                    object cxGridDBKONUSU: TcxGridDBColumn
                      Caption = 'Konusu'
                      DataBinding.FieldName = 'KONUSU'
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Options.Editing = False
                      Width = 191
                    end
                    object cxGridDBColumn2: TcxGridDBColumn
                      Caption = 'Sorumlu'
                      DataBinding.FieldName = 'SORUMLUADI'
                      Options.Editing = False
                      Width = 125
                    end
                    object GridIsZamanViewPLANSURE: TcxGridDBColumn
                      Caption = 'Planlanan'
                      DataBinding.FieldName = 'PLANSURE'
                      PropertiesClassName = 'TcxTimeEditProperties'
                      Properties.ReadOnly = True
                      Properties.TimeFormat = tfHourMin
                      Styles.Content = Tablo.cxStyle10
                    end
                    object cxGridDBBASLAMA: TcxGridDBColumn
                      Caption = 'Ba'#351'lama'
                      DataBinding.FieldName = 'BASLAMA'
                      PropertiesClassName = 'TcxTimeEditProperties'
                      Properties.SpinButtons.Visible = False
                      Properties.TimeFormat = tfHourMin
                      Options.Editing = False
                      Width = 52
                    end
                    object cxGridDBBITIS: TcxGridDBColumn
                      Caption = 'Biti'#351
                      DataBinding.FieldName = 'BITIS'
                      PropertiesClassName = 'TcxTimeEditProperties'
                      Properties.SpinButtons.Visible = False
                      Properties.TimeFormat = tfHourMin
                      Options.Editing = False
                      Width = 48
                    end
                    object GridIsZamanViewMOLA: TcxGridDBColumn
                      Caption = 'Mola'
                      DataBinding.FieldName = 'MOLA'
                      PropertiesClassName = 'TcxTimeEditProperties'
                      Properties.SpinButtons.Visible = False
                      Properties.TimeFormat = tfHourMin
                      Options.Editing = False
                      Width = 48
                    end
                    object GridIsZamanViewSURE: TcxGridDBColumn
                      Caption = 'S'#252're'
                      DataBinding.FieldName = 'SURE'
                      PropertiesClassName = 'TcxMaskEditProperties'
                      Properties.EditMask = '!90:00;1;_'
                      Options.Editing = False
                    end
                    object GridIsZamanViewOLCUMSAY: TcxGridDBColumn
                      Caption = #214'l'#231#252'm Say'#305
                      DataBinding.FieldName = 'OLCUMSAY'
                      PropertiesClassName = 'TcxTextEditProperties'
                      Properties.ReadOnly = True
                    end
                    object GridIsZamanViewOLCUM: TcxGridDBColumn
                      Caption = #214'l'#231#252'm'
                      DataBinding.FieldName = 'OLCUM'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Images = Tablo.ImgListGridResimleri
                      Properties.Items = <
                        item
                          ImageIndex = 6
                          Value = 1
                        end>
                      Width = 59
                    end
                    object cxGridDBColumn5: TcxGridDBColumn
                      Caption = 'Lokasyon'
                      DataBinding.FieldName = 'LOKASYONADI'
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Properties.ReadOnly = True
                      Options.Editing = False
                      Width = 75
                    end
                    object cxGridDBColumn6: TcxGridDBColumn
                      Caption = 'Kaynak'
                      DataBinding.FieldName = 'KAYNAKADI'
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Properties.ReadOnly = True
                      Options.Editing = False
                      Width = 71
                    end
                    object cxGridDBColumn9: TcxGridDBColumn
                      Caption = 'Adet'
                      DataBinding.FieldName = 'ADET'
                      Options.Editing = False
                    end
                    object cxGridDBColumn10: TcxGridDBColumn
                      Caption = 'Birim'
                      DataBinding.FieldName = 'BIRIM'
                      RepositoryItem = Tablo.repStokAnaBirim
                      Options.Editing = False
                      Options.Focusing = False
                    end
                    object cxGridDBColumn15: TcxGridDBColumn
                      DataBinding.FieldName = 'ID'
                      Visible = False
                      Options.Editing = False
                      Options.Focusing = False
                    end
                    object GridIsZamanViewDURUM: TcxGridDBColumn
                      Caption = 'Durum'
                      DataBinding.FieldName = 'DURUM'
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Items = <
                        item
                          Description = 'Bekliyor'
                          ImageIndex = 0
                          Value = 0
                        end
                        item
                          Description = #199'al'#305#351#305'l'#305'yor'
                          Value = 1
                        end
                        item
                          Description = 'Tamamland'#305
                          Value = 9
                        end>
                      Options.Editing = False
                    end
                    object GridIsZamanViewACIKLAMA: TcxGridDBColumn
                      Caption = 'A'#231#305'klama'
                      DataBinding.FieldName = 'ACIKLAMA'
                      PropertiesClassName = 'TcxTextEditProperties'
                      Properties.ReadOnly = True
                      Width = 195
                    end
                    object GridIsZamanViewSIRA: TcxGridDBColumn
                      Caption = 'S'#305'ra'
                      DataBinding.FieldName = 'SIRA'
                      PropertiesClassName = 'TcxSpinEditProperties'
                    end
                  end
                  object cxGridLevel2: TcxGridLevel
                    GridView = GridIsZamanView
                  end
                end
                object Panel9: TPanel
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 23
                  Align = alTop
                  Caption = 'Panel9'
                  TabOrder = 1
                  object JvNavPanelHeader5: TJvNavPanelHeader
                    Left = 201
                    Top = 1
                    Width = 976
                    Height = 21
                    Align = alClient
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clWhite
                    Font.Height = -16
                    Font.Name = 'Arial'
                    Font.Style = [fsBold]
                    ParentFont = False
                    ColorFrom = 14540253
                    ColorTo = 11776947
                    ImageIndex = 0
                    object CheckTamamlananlar: TcxCheckBox
                      Left = 6
                      Top = 0
                      Caption = 'Tamamlananlar'#305' da G'#246'ster'
                      ParentFont = False
                      Properties.ImmediatePost = True
                      Style.Font.Charset = DEFAULT_CHARSET
                      Style.Font.Color = clWhite
                      Style.Font.Height = -13
                      Style.Font.Name = 'Arial'
                      Style.Font.Style = [fsBold]
                      Style.TextStyle = []
                      Style.TransparentBorder = True
                      Style.IsFontAssigned = True
                      TabOrder = 0
                      Transparent = True
                      OnClick = CheckTamamlananlarClick
                    end
                  end
                  object ToolBar4: TToolBar
                    Left = 1
                    Top = 1
                    Width = 200
                    Height = 21
                    Margins.Bottom = 0
                    Align = alLeft
                    AutoSize = True
                    ButtonWidth = 66
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
                    Images = Tablo.PNGImageList2
                    List = True
                    ParentColor = False
                    ParentFont = False
                    ShowCaptions = True
                    TabOrder = 1
                    Transparent = True
                    object IsZamanYeni: TToolButton
                      Left = 0
                      Top = 0
                      Caption = 'Yeni'
                      ImageIndex = 0
                      ImageName = 'PngImage0'
                      OnClick = IsZamanYeniClick
                    end
                    object IsZamanSil: TToolButton
                      Left = 66
                      Top = 0
                      Caption = 'Sil'
                      ImageIndex = 1
                      ImageName = 'PngImage1'
                      OnClick = IsZamanSilClick
                    end
                    object IsZamanDuzenle: TToolButton
                      Left = 132
                      Top = 0
                      Caption = 'D'#252'zenle'
                      ImageIndex = 7
                      ImageName = 'PngImage7'
                      OnClick = IsZamanDuzenleClick
                    end
                  end
                end
              end
              object SheetPlanlama: TcxTabSheet
                Caption = 'Malzeme Planlama'
                ImageIndex = 4
                object GridPlanlama: TcxGrid
                  Left = 0
                  Top = 25
                  Width = 1178
                  Height = 90
                  Align = alClient
                  PopupMenu = PopupOperasyonPlanlama
                  TabOrder = 0
                  object GridPlanlamaView: TcxGridDBTableView
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    OnCanFocusRecord = GridPlanlamaViewCanFocusRecord
                    DataController.DataSource = DtsPlanlama
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <>
                    DataController.Summary.SummaryGroups = <>
                    OptionsData.CancelOnExit = False
                    OptionsData.Deleting = False
                    OptionsData.DeletingConfirmation = False
                    OptionsView.GroupByBox = False
                    OptionsView.Indicator = True
                    object cxGridDBColumn8: TcxGridDBColumn
                      DataBinding.FieldName = 'ID'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                    object cxGridDBColumn11: TcxGridDBColumn
                      Caption = 'Kod'
                      DataBinding.FieldName = 'KOD'
                      DataBinding.IsNullValueType = True
                      Width = 103
                    end
                    object cxGridDBColumn12: TcxGridDBColumn
                      Caption = 'Ad'
                      DataBinding.FieldName = 'STOKADI'
                      DataBinding.IsNullValueType = True
                      Width = 170
                    end
                    object GridPlanlamaViewColumn6: TcxGridDBColumn
                      Caption = 'Resim'
                      DataBinding.FieldName = 'RESIM'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.DropDownRows = 1
                      Properties.Images = Tablo.imgScheduler
                      Properties.Items = <
                        item
                          Value = 0
                        end
                        item
                          ImageIndex = 19
                          Value = 1
                        end>
                      Properties.OnButtonClick = GridPlanlamaViewColumn6PropertiesButtonClick
                    end
                    object GridPlanlamaViewDOKUMAN: TcxGridDBColumn
                      Caption = 'Dok'#252'man'
                      DataBinding.FieldName = 'DOKUMAN'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.DropDownRows = 1
                      Properties.Images = Tablo.imgScheduler
                      Properties.Items = <
                        item
                          Value = 0
                        end
                        item
                          ImageIndex = 15
                          Value = 1
                        end>
                      Properties.OnButtonClick = GridPlanlamaViewDOKUMANPropertiesButtonClick
                    end
                    object cxGridDBColumn14: TcxGridDBColumn
                      Caption = 'Birim'
                      DataBinding.FieldName = 'ANABIRIM'
                      DataBinding.IsNullValueType = True
                      RepositoryItem = Tablo.repStokAnaBirim
                    end
                    object cxGridDBColumn13: TcxGridDBColumn
                      Caption = 'Gereksinim'
                      DataBinding.FieldName = 'GEREKSINIM'
                      DataBinding.IsNullValueType = True
                    end
                    object cxGridDBColumn16: TcxGridDBColumn
                      Caption = 'Depo Durum'
                      DataBinding.FieldName = 'DEPODURUM'
                      DataBinding.IsNullValueType = True
                      Width = 68
                    end
                    object GridPlanlamaViewColumn7: TcxGridDBColumn
                      Caption = 'Girecek/'#199#305'kacak'
                      DataBinding.FieldName = 'GIRECEKCIKACAK'
                      DataBinding.IsNullValueType = True
                      Width = 84
                    end
                    object GridPlanlamaViewColumn1: TcxGridDBColumn
                      Caption = 'Genel Durum'
                      DataBinding.FieldName = 'GENELDURUM'
                      DataBinding.IsNullValueType = True
                      Width = 84
                    end
                    object GridPlanlamaViewColumn2: TcxGridDBColumn
                      DataBinding.FieldName = 'Sat'#305'nalma Talep'
                      DataBinding.IsNullValueType = True
                      Width = 80
                    end
                    object GridPlanlamaViewColumn3: TcxGridDBColumn
                      Caption = 'Depo Talep'
                      DataBinding.IsNullValueType = True
                      Width = 78
                    end
                    object GridPlanlamaViewColumn4: TcxGridDBColumn
                      Caption = 'Koltuk Ambar'#305
                      DataBinding.IsNullValueType = True
                      Width = 87
                    end
                    object GridPlanlamaViewColumn5: TcxGridDBColumn
                      Caption = 'Fark'
                      DataBinding.IsNullValueType = True
                    end
                    object GridPlanlamaViewSTOKTALEP: TcxGridDBColumn
                      Caption = 'Stok Talep'
                      DataBinding.FieldName = 'STOKTALEP'
                      DataBinding.IsNullValueType = True
                      Width = 56
                    end
                    object GridPlanlamaViewSATINALMATALEP: TcxGridDBColumn
                      Caption = 'Sat'#305'nalma Talep'
                      DataBinding.FieldName = 'SATINALMATALEP'
                      DataBinding.IsNullValueType = True
                      Width = 57
                    end
                  end
                  object cxGridLevel3: TcxGridLevel
                    GridView = GridPlanlamaView
                  end
                end
                object PanelMalzemePlanlamaUst: TPanel
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 25
                  Align = alTop
                  Ctl3D = True
                  ParentBackground = False
                  ParentCtl3D = False
                  ShowCaption = False
                  TabOrder = 1
                  object PanelMalzemePlanlamaOp: TPanel
                    Left = 1
                    Top = 1
                    Width = 256
                    Height = 23
                    Margins.Left = 0
                    Margins.Top = 0
                    Margins.Right = 0
                    Margins.Bottom = 0
                    Align = alLeft
                    ParentBackground = False
                    TabOrder = 0
                    object cxRBTumOplar: TcxRadioButton
                      Left = 114
                      Top = 1
                      Width = 113
                      Height = 21
                      Align = alLeft
                      Caption = 'T'#252'm Operasyonlar'
                      TabOrder = 0
                      OnClick = cxRBSeciliOpClick
                      Transparent = True
                    end
                    object cxRBSeciliOp: TcxRadioButton
                      Left = 1
                      Top = 1
                      Width = 113
                      Height = 21
                      Align = alLeft
                      Caption = 'Se'#231'ili Operasyon'
                      Checked = True
                      TabOrder = 1
                      TabStop = True
                      OnClick = cxRBSeciliOpClick
                      Transparent = True
                    end
                  end
                  object Panel1: TPanel
                    Left = 257
                    Top = 1
                    Width = 280
                    Height = 23
                    Margins.Left = 0
                    Margins.Top = 0
                    Margins.Right = 0
                    Margins.Bottom = 0
                    Align = alLeft
                    ParentBackground = False
                    TabOrder = 1
                    object cxRBTumSarflar: TcxRadioButton
                      Left = 127
                      Top = 1
                      Width = 130
                      Height = 21
                      Align = alLeft
                      Caption = 'T'#252'm Sarf Malzemeleri'
                      TabOrder = 0
                      OnClick = cxRBSeciliOpClick
                      Transparent = True
                    end
                    object cxRBSadeceHammadde: TcxRadioButton
                      Left = 1
                      Top = 1
                      Width = 126
                      Height = 21
                      Align = alLeft
                      Caption = 'Sadece Hammaddeler'
                      Checked = True
                      TabOrder = 1
                      TabStop = True
                      OnClick = cxRBSeciliOpClick
                      Transparent = True
                    end
                  end
                end
              end
              object SheetOpIslemler: TcxTabSheet
                Caption = 'T'#252'ketilenler'
                ImageIndex = 0
                object GridUrtOpDetay: TcxGrid
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 115
                  Align = alClient
                  TabOrder = 0
                  object GridUrtOpDetayDBTableView1: TcxGridDBTableView
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    DataController.DataSource = DtsTabUretimOperasyonDetay
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <>
                    DataController.Summary.SummaryGroups = <>
                    OptionsData.CancelOnExit = False
                    OptionsData.Deleting = False
                    OptionsData.DeletingConfirmation = False
                    OptionsData.Editing = False
                    OptionsData.Inserting = False
                    OptionsSelection.CellSelect = False
                    OptionsSelection.HideFocusRectOnExit = False
                    OptionsSelection.InvertSelect = False
                    OptionsSelection.UnselectFocusedRecordOnExit = False
                    OptionsView.GroupByBox = False
                    object GridUrtOpDetayDBTableView1ID: TcxGridDBColumn
                      DataBinding.FieldName = 'ID'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                    object GridUrtOpDetayDBTableView1FATURANO: TcxGridDBColumn
                      Caption = #220'retim No'
                      DataBinding.FieldName = 'FATURANO'
                      DataBinding.IsNullValueType = True
                      Width = 71
                    end
                    object GridUrtOpDetayDBTableView1TARIH: TcxGridDBColumn
                      Caption = 'Ba'#351'lama'
                      DataBinding.FieldName = 'TARIH'
                      DataBinding.IsNullValueType = True
                    end
                    object GridUrtOpDetayDBTableView1FATURATARIH: TcxGridDBColumn
                      Caption = 'Biti'#351
                      DataBinding.FieldName = 'FATURATARIH'
                      DataBinding.IsNullValueType = True
                    end
                    object GridUrtOpDetayDBTableView1GRP: TcxGridDBColumn
                      Caption = 'Grup'
                      DataBinding.FieldName = 'GRP'
                      DataBinding.IsNullValueType = True
                    end
                    object GridUrtOpDetayDBTableView1KOD: TcxGridDBColumn
                      Caption = 'Kod'
                      DataBinding.FieldName = 'KOD'
                      DataBinding.IsNullValueType = True
                      Width = 103
                    end
                    object GridUrtOpDetayDBTableView1AD: TcxGridDBColumn
                      Caption = 'Ad'
                      DataBinding.FieldName = 'AD'
                      DataBinding.IsNullValueType = True
                      Width = 170
                    end
                    object GridUrtOpDetayDBTableView1ADET: TcxGridDBColumn
                      Caption = 'Adet'
                      DataBinding.FieldName = 'ADET'
                      DataBinding.IsNullValueType = True
                    end
                    object GridUrtOpDetayDBTableView1BIRIM: TcxGridDBColumn
                      Caption = 'Birim'
                      DataBinding.FieldName = 'BIRIM'
                      DataBinding.IsNullValueType = True
                      RepositoryItem = Tablo.repStokAnaBirim
                    end
                    object GridUrtOpDetayDBTableView1ACIKLAMA: TcxGridDBColumn
                      Caption = 'A'#231#305'klama'
                      DataBinding.FieldName = 'ACIKLAMA'
                      DataBinding.IsNullValueType = True
                      Width = 307
                    end
                  end
                  object GridUrtOpDetayLevel1: TcxGridLevel
                    GridView = GridUrtOpDetayDBTableView1
                  end
                end
              end
              object SheetOpMaliyet: TcxTabSheet
                Caption = 'Ekstra Maliyet'
                ImageIndex = 1
                object ToolBar2: TToolBar
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 24
                  Margins.Bottom = 0
                  AutoSize = True
                  ButtonWidth = 62
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
                  Images = Tablo.PNGImageList2
                  List = True
                  ParentColor = False
                  ParentFont = False
                  ShowCaptions = True
                  TabOrder = 0
                  Transparent = True
                  object BtnOpMaliyetYeni: TToolButton
                    Left = 0
                    Top = 0
                    Caption = 'Yeni'
                    ImageIndex = 0
                    ImageName = 'PngImage0'
                    OnClick = BtnOpMaliyetYeniClick
                  end
                  object BtnOpMaliyetSil: TToolButton
                    Left = 62
                    Top = 0
                    Caption = 'Sil'
                    ImageIndex = 1
                    ImageName = 'PngImage1'
                    OnClick = BtnOpMaliyetSilClick
                  end
                  object BtnOpMaliyetKaydet: TToolButton
                    Left = 124
                    Top = 0
                    Caption = 'Kaydet'
                    ImageIndex = 2
                    ImageName = 'PngImage2'
                    Visible = False
                    OnClick = BtnOpMaliyetKaydetClick
                  end
                  object BtnOpMaliyetIptal: TToolButton
                    Left = 186
                    Top = 0
                    Caption = #304'ptal'
                    ImageIndex = 3
                    ImageName = 'PngImage3'
                    Visible = False
                    OnClick = BtnOpMaliyetIptalClick
                  end
                end
                object GridUrtOpMaliyet: TcxGrid
                  Left = 0
                  Top = 24
                  Width = 1178
                  Height = 91
                  Align = alClient
                  TabOrder = 1
                  object GridUrtOpMaliyetDBTableView1: TcxGridDBTableView
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    DataController.DataSource = DtsOperasyonEkMaliyet
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <
                      item
                        Kind = skSum
                        Column = GridUrtOpMaliyetDBTableView1TUTAR
                      end>
                    DataController.Summary.SummaryGroups = <>
                    OptionsView.Footer = True
                    OptionsView.GroupByBox = False
                    object GridUrtOpMaliyetDBTableView1ID: TcxGridDBColumn
                      DataBinding.FieldName = 'ID'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                    object GridUrtOpMaliyetDBTableView1KOD: TcxGridDBColumn
                      Caption = 'Kod'
                      DataBinding.FieldName = 'KOD'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Width = 58
                    end
                    object GridUrtOpMaliyetDBTableView1AD: TcxGridDBColumn
                      Caption = 'Ad'
                      DataBinding.FieldName = 'AD'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Width = 119
                    end
                    object GridUrtOpMaliyetDBTableView1MASRAFID: TcxGridDBColumn
                      DataBinding.FieldName = 'MASRAFID'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                    object GridUrtOpMaliyetDBTableView1TUTAR: TcxGridDBColumn
                      Caption = 'Tutar'
                      DataBinding.FieldName = 'TUTAR'
                      DataBinding.IsNullValueType = True
                      RepositoryItem = Tablo.RepCurrencyGenel
                      Width = 82
                    end
                    object GridUrtOpMaliyetDBTableView1KUR: TcxGridDBColumn
                      Caption = 'Kur'
                      DataBinding.FieldName = 'KUR'
                      DataBinding.IsNullValueType = True
                      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                    end
                    object GridUrtOpMaliyetDBTableView1ACIKLAMA: TcxGridDBColumn
                      Caption = 'A'#231#305'klama'
                      DataBinding.FieldName = 'ACIKLAMA'
                      DataBinding.IsNullValueType = True
                      Width = 518
                    end
                    object GridUrtOpMaliyetDBTableView1OZELKOD: TcxGridDBColumn
                      DataBinding.FieldName = 'OZELKOD'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                    object GridUrtOpMaliyetDBTableView1MUHKODU: TcxGridDBColumn
                      DataBinding.FieldName = 'MUHKODU'
                      DataBinding.IsNullValueType = True
                      Visible = False
                    end
                  end
                  object GridUrtOpMaliyetLevel1: TcxGridLevel
                    GridView = GridUrtOpMaliyetDBTableView1
                  end
                end
              end
              object cxTabSheet2: TcxTabSheet
                Caption = 'D'#305#351' Kaynak Kullan'#305'm'#305' (Fason)'
                ImageIndex = 5
                object ToolBar6: TToolBar
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 24
                  Margins.Bottom = 0
                  AutoSize = True
                  ButtonWidth = 62
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
                  Images = Tablo.PNGImageList2
                  List = True
                  ParentColor = False
                  ParentFont = False
                  ShowCaptions = True
                  TabOrder = 0
                  Transparent = True
                  object BtnOpDisKaynakYeni: TToolButton
                    Left = 0
                    Top = 0
                    Caption = 'Yeni'
                    ImageIndex = 0
                    ImageName = 'PngImage0'
                    OnClick = BtnOpDisKaynakYeniClick
                  end
                  object BtnOpDisKaynakSil: TToolButton
                    Left = 62
                    Top = 0
                    Caption = 'Sil'
                    ImageIndex = 1
                    ImageName = 'PngImage1'
                    OnClick = BtnOpDisKaynakSilClick
                  end
                  object BtnOpDisKaynakKaydet: TToolButton
                    Left = 124
                    Top = 0
                    Caption = 'Kaydet'
                    ImageIndex = 2
                    ImageName = 'PngImage2'
                    Visible = False
                    OnClick = BtnOpDisKaynakKaydetClick
                  end
                  object BtnOpDisKaynakIptal: TToolButton
                    Left = 186
                    Top = 0
                    Caption = #304'ptal'
                    ImageIndex = 3
                    ImageName = 'PngImage3'
                    Visible = False
                    OnClick = BtnOpDisKaynakIptalClick
                  end
                end
                object GridFason: TcxGrid
                  Left = 0
                  Top = 24
                  Width = 1178
                  Height = 91
                  Align = alClient
                  TabOrder = 1
                  object GridFasonView: TcxGridDBTableView
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    DataController.DataSource = DtsOperasyonFason
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <
                      item
                        Kind = skSum
                      end>
                    DataController.Summary.SummaryGroups = <>
                    OptionsView.Footer = True
                    OptionsView.GroupByBox = False
                    object GridFasonViewID: TcxGridDBColumn
                      DataBinding.FieldName = 'ID'
                      Visible = False
                    end
                    object GridFasonViewOLAY: TcxGridDBColumn
                      Caption = 'Olay'
                      DataBinding.FieldName = 'OLAY'
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Items = <
                        item
                          Description = 'Giri'#351
                          ImageIndex = 0
                          Value = 1
                        end
                        item
                          Description = #199#305'k'#305#351
                          Value = 0
                        end>
                    end
                    object GridFasonViewTARIH: TcxGridDBColumn
                      Caption = 'Tarih'
                      DataBinding.FieldName = 'TARIH'
                      PropertiesClassName = 'TcxDateEditProperties'
                      Properties.Kind = ckDateTime
                      Width = 97
                    end
                    object GridFasonViewREHBERID: TcxGridDBColumn
                      Caption = 'Cari ID'
                      DataBinding.FieldName = 'REHBERID'
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Visible = False
                      Width = 78
                    end
                    object GridFasonViewCARIAD: TcxGridDBColumn
                      Caption = 'Cari '
                      DataBinding.FieldName = 'CARIAD'
                      PropertiesClassName = 'TcxButtonEditProperties'
                      Properties.Buttons = <
                        item
                          Default = True
                          Kind = bkEllipsis
                        end>
                      Properties.OnButtonClick = ButtonEdit
                      Width = 186
                    end
                    object GridFasonViewFASONTIPI: TcxGridDBColumn
                      Caption = 'Fason Tipi'
                      DataBinding.FieldName = 'FASONTIPI'
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Items = <>
                      RepositoryItem = Tablo.RepFasonTipi
                    end
                    object GridFasonViewTUR: TcxGridDBColumn
                      Caption = 'T'#252'r'
                      DataBinding.FieldName = 'TUR'
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Items = <
                        item
                          Description = #304'rsaliye'
                          ImageIndex = 0
                          Value = 1
                        end
                        item
                          Description = 'Di'#287'er'
                          Value = 2
                        end>
                      Width = 85
                    end
                    object GridFasonViewBELGENO: TcxGridDBColumn
                      Caption = 'Belge No'
                      DataBinding.FieldName = 'BELGENO'
                      Width = 110
                    end
                    object GridFasonViewACIKLAMA: TcxGridDBColumn
                      Caption = 'A'#231#305'klama'
                      DataBinding.FieldName = 'ACIKLAMA'
                      Width = 150
                    end
                    object GridFasonViewGIREN: TcxGridDBColumn
                      Caption = 'Giren'
                      DataBinding.FieldName = 'GIREN'
                      Width = 71
                    end
                    object GridFasonViewCIKAN: TcxGridDBColumn
                      Caption = #199#305'kan'
                      DataBinding.FieldName = 'CIKAN'
                      Width = 82
                    end
                    object GridFasonViewBIRIM: TcxGridDBColumn
                      Caption = 'Birim'
                      DataBinding.FieldName = 'BIRIM'
                      PropertiesClassName = 'TcxImageComboBoxProperties'
                      Properties.Items = <>
                      RepositoryItem = Tablo.repStokAnaBirim
                    end
                  end
                  object cxGridLevel4: TcxGridLevel
                    GridView = GridFasonView
                  end
                end
              end
              object SheetYorumMedya: TcxTabSheet
                Caption = 'Yorum/Medya'
                ImageIndex = 3
                object Panel4: TPanel
                  Left = 0
                  Top = 54
                  Width = 1178
                  Height = 41
                  Align = alBottom
                  TabOrder = 0
                  object MemoChat: TcxRichEdit
                    Left = 1
                    Top = 1
                    Align = alClient
                    Properties.ScrollBars = ssVertical
                    TabOrder = 1
                    Height = 39
                    Width = 1030
                  end
                  object BtnMesajGonder: TcxButton
                    Left = 1031
                    Top = 1
                    Width = 85
                    Height = 39
                    Align = alRight
                    OptionsImage.ImageIndex = 39
                    OptionsImage.Images = Tablo.cxImageList1
                    TabOrder = 0
                    OnClick = BtnMesajGonderClick
                  end
                  object BtnDosyaGonder: TcxButton
                    Left = 1116
                    Top = 1
                    Width = 61
                    Height = 39
                    Align = alRight
                    DropDownMenu = YorumAtacMenu
                    Kind = cxbkDropDown
                    OptionsImage.ImageIndex = 38
                    OptionsImage.Images = Tablo.cxImageList1
                    TabOrder = 2
                  end
                end
                object labelFileName: TcxLabel
                  Left = 0
                  Top = 95
                  ParentCustomHint = False
                  Align = alBottom
                  ParentColor = False
                  ParentFont = False
                  ParentShowHint = False
                  ShowHint = False
                  Style.Edges = [bLeft, bRight]
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.Shadow = False
                  Style.IsFontAssigned = True
                  Properties.Alignment.Horz = taRightJustify
                  Transparent = True
                  Visible = False
                  AnchorX = 1178
                end
                object GridYorum: TcxGrid
                  Left = 0
                  Top = 0
                  Width = 1178
                  Height = 54
                  Align = alClient
                  TabOrder = 2
                  LookAndFeel.ScrollbarMode = sbmClassic
                  object GridYorumDBCardView1: TcxGridDBCardView
                    Navigator.Buttons.CustomButtons = <>
                    ScrollbarAnnotations.CustomAnnotations = <>
                    OnCellDblClick = GridYorumDBCardView1CellDblClick
                    DataController.DataSource = DtsYorum
                    DataController.Summary.DefaultGroupSummaryItems = <>
                    DataController.Summary.FooterSummaryItems = <>
                    DataController.Summary.SummaryGroups = <>
                    LayoutDirection = ldVertical
                    OptionsView.CardBorderWidth = 1
                    OptionsView.CardIndent = 2
                    OptionsView.CardWidth = 900
                    OptionsView.CategoryIndent = 1
                    OptionsView.CategorySeparatorWidth = 1
                    OptionsView.CellAutoHeight = True
                    OptionsView.CellTextMaxLineCount = 5
                    Styles.Content = Tablo.cxStyle6
                    Styles.CardBorder = Tablo.cxStyle19
                    object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
                      DataBinding.FieldName = 'EKLEMETARIHI'
                      DataBinding.IsNullValueType = True
                      Options.Editing = False
                      Options.Focusing = False
                      Options.ShowCaption = False
                      Position.BeginsLayer = True
                      Position.Width = 120
                    end
                    object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
                      DataBinding.FieldName = 'YAZAN'
                      DataBinding.IsNullValueType = True
                      Options.Editing = False
                      Options.Focusing = False
                      Options.ShowCaption = False
                      Position.BeginsLayer = False
                    end
                    object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
                      DataBinding.FieldName = 'ATAC'
                      DataBinding.IsNullValueType = True
                      RepositoryItem = Tablo.repFileExtensionList
                      Options.Editing = False
                      Options.Focusing = False
                      Options.ShowCaption = False
                      Position.BeginsLayer = False
                      Position.Width = 25
                      IsCaptionAssigned = True
                    end
                    object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
                      DataBinding.FieldName = 'DOKUMANAD'
                      DataBinding.IsNullValueType = True
                      Options.Editing = False
                      Options.Focusing = False
                      Options.ShowCaption = False
                      Position.BeginsLayer = False
                      Position.Width = 300
                      IsCaptionAssigned = True
                    end
                    object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
                      DataBinding.FieldName = 'YORUM'
                      DataBinding.IsNullValueType = True
                      PropertiesClassName = 'TcxRichEditProperties'
                      Options.Editing = False
                      Options.Focusing = False
                      Options.ShowCaption = False
                      Position.BeginsLayer = True
                      Styles.Content = Tablo.cxStyle12
                      Styles.CategoryRow = Tablo.cxStyle4
                    end
                  end
                  object GridYorumLevel1: TcxGridLevel
                    GridView = GridYorumDBCardView1
                  end
                end
              end
            end
          end
        end
        object SheetMaliyet: TcxTabSheet
          Caption = 'Maliyet'
          ImageIndex = 2
          object cxGrid1: TcxGrid
            Left = 0
            Top = 0
            Width = 1188
            Height = 354
            Align = alClient
            TabOrder = 0
            LookAndFeel.ScrollbarMode = sbmClassic
            object cxGridDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsUrToplamMaliyet
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Kind = skSum
                  Position = spFooter
                  Column = cxGridDBTableView1TUTAR
                end
                item
                  Kind = skSum
                  Position = spFooter
                  Column = cxGridDBTableView1BIRIMMALIYET
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                  Column = cxGridDBTableView1TUTAR
                end
                item
                  Kind = skSum
                  Column = cxGridDBTableView1BIRIMMALIYET
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsSelection.CellSelect = False
              OptionsSelection.HideFocusRectOnExit = False
              OptionsSelection.InvertSelect = False
              OptionsSelection.UnselectFocusedRecordOnExit = False
              OptionsView.Footer = True
              OptionsView.FooterAutoHeight = True
              OptionsView.FooterMultiSummaries = True
              OptionsView.GroupFooterMultiSummaries = True
              OptionsView.GroupFooters = gfVisibleWhenExpanded
              object cxGridDBTableView1TIP: TcxGridDBColumn
                Caption = 'Tip'
                DataBinding.FieldName = 'TIP'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Hizmet'
                    ImageIndex = 0
                    Value = '2'
                  end
                  item
                    Description = 'Hammadde'
                    Value = '1'
                  end>
              end
              object cxGridDBTableView1KOD: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBTableView1AD: TcxGridDBColumn
                Caption = 'Ad'
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                Width = 164
              end
              object cxGridDBTableView1BIRIMMALIYET: TcxGridDBColumn
                Caption = 'Birim Maliyet'
                DataBinding.FieldName = 'BIRIMMALIYET'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 87
              end
              object cxGridDBTableView1TUTAR: TcxGridDBColumn
                Caption = 'Maliyet'
                DataBinding.FieldName = 'TUTAR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 94
              end
              object cxGridDBTableView1KUR: TcxGridDBColumn
                Caption = 'Kur'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 422
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridDBTableView1
            end
          end
        end
        object SheetGereksinim: TcxTabSheet
          Caption = 'Gereksinim'
          ImageIndex = 3
          object GridGereksinim: TcxGrid
            Left = 0
            Top = 0
            Width = 1188
            Height = 354
            Align = alClient
            TabOrder = 0
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridGereksinimView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsGereksinim
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Kind = skSum
                  Position = spFooter
                end
                item
                  Kind = skSum
                  Position = spFooter
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                end
                item
                  Kind = skSum
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsSelection.CellSelect = False
              OptionsSelection.HideFocusRectOnExit = False
              OptionsSelection.InvertSelect = False
              OptionsSelection.UnselectFocusedRecordOnExit = False
              OptionsView.Footer = True
              OptionsView.FooterAutoHeight = True
              OptionsView.FooterMultiSummaries = True
              OptionsView.GroupFooterMultiSummaries = True
              OptionsView.GroupFooters = gfVisibleWhenExpanded
              object GridGereksinimViewGRP: TcxGridDBColumn
                Caption = 'Grup'
                DataBinding.FieldName = 'GRP'
                DataBinding.IsNullValueType = True
                Width = 65
              end
              object GridGereksinimViewAD: TcxGridDBColumn
                Caption = 'Ad'
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                Width = 137
              end
              object GridGereksinimViewKOD: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
                Width = 84
              end
              object GridGereksinimViewURUNNO: TcxGridDBColumn
                Caption = #220'r'#252'n No'
                DataBinding.FieldName = 'URUNNO'
                DataBinding.IsNullValueType = True
                Width = 82
              end
              object GridGereksinimViewISTENEN: TcxGridDBColumn
                Caption = #304'stenen'
                DataBinding.FieldName = 'ISTENEN'
                DataBinding.IsNullValueType = True
              end
              object GridGereksinimViewURETILECEK: TcxGridDBColumn
                Caption = #220'retilecek'
                DataBinding.FieldName = 'URETILECEK'
                DataBinding.IsNullValueType = True
              end
              object GridGereksinimViewURETILEN: TcxGridDBColumn
                Caption = #220'retilen'
                DataBinding.FieldName = 'URETILEN'
                DataBinding.IsNullValueType = True
                Width = 132
              end
              object GridGereksinimViewTUKETILEN: TcxGridDBColumn
                Caption = 'T'#252'ketilen'
                DataBinding.FieldName = 'TUKETILEN'
                DataBinding.IsNullValueType = True
                Width = 190
              end
              object GridGereksinimViewDEPODURUMU: TcxGridDBColumn
                Caption = 'Depo Durumu'
                DataBinding.FieldName = 'DEPODURUMU'
                DataBinding.IsNullValueType = True
              end
              object GridGereksinimViewDEPOGEREKSINIM: TcxGridDBColumn
                Caption = 'Depo Gereksinim'
                DataBinding.FieldName = 'DEPOGEREKSINIM'
                DataBinding.IsNullValueType = True
              end
              object GridGereksinimViewGIRECEKCIKACAK: TcxGridDBColumn
                Caption = 'Girecek '#199#305'kacak'
                DataBinding.FieldName = 'GIRECEKCIKACAK'
                DataBinding.IsNullValueType = True
              end
              object GridGereksinimViewTAHMINIKALAN: TcxGridDBColumn
                Caption = 'Tahmini Kalan'
                DataBinding.FieldName = 'TAHMINIKALAN'
                DataBinding.IsNullValueType = True
              end
            end
            object cxGridLevel5: TcxGridLevel
              GridView = GridGereksinimView
            end
          end
        end
      end
      object cxLabel5: TcxLabel
        Left = 3
        Top = 38
        Caption = 'ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxDBLabel1: TcxDBLabel
        Left = 23
        Top = 38
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsUretimEmri
        Transparent = True
        Height = 21
        Width = 39
      end
      object LabelKod: TcxLabel
        Left = 124
        Top = 3
        Cursor = crHandPoint
        Caption = 'Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
      end
      object LabelAd: TcxLabel
        Left = 124
        Top = 35
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.ShowEndEllipsis = True
        Transparent = True
        OnClick = LabelAdClick
        Height = 28
        Width = 573
      end
      object lblMusteriAdres: TcxLabel
        Left = 703
        Top = 31
        AutoSize = False
        Caption = 'Adres'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Height = 18
        Width = 331
      end
      object lblMusteriTel: TcxLabel
        Left = 703
        Top = 1
        Caption = 'Tel'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lblMusteriEposta: TcxLabel
        Left = 704
        Top = 15
        Caption = 'Eposta'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelSevk: TcxLabel
        Left = 705
        Top = 48
        AutoSize = False
        Caption = 'Sevk'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        OnClick = LabelSevkClick
        Height = 18
        Width = 331
      end
      object cxSplitter1: TcxSplitter
        Left = 0
        Top = 238
        Width = 1196
        Height = 8
        HotZoneClassName = 'TcxMediaPlayer8Style'
        AlignSplitter = salTop
        Control = PanelGenelUst
        Color = clNavy
        ParentColor = False
      end
    end
  end
  object TabUretimEmri: TFDQuery
    AfterOpen = TabUretimEmriAfterOpen
    BeforeEdit = TabUretimEmriBeforeEdit
    BeforePost = TabUretimEmriBeforePost
    AfterPost = TabUretimEmriAfterPost
    BeforeDelete = TabUretimEmriBeforeDelete
    OnNewRecord = TabUretimEmriNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'UE.*,'
      #9'STOKKOD = S.KOD, S.STOKADI,'
      
        '    TALEPEDENADI=(select  R.FIRMA from REHBER R where UE.TALEPED' +
        'EN=R.ID),'
      
        #9'ONAYLAYACAKADI=(select  R.FIRMA from REHBER R where UE.ONAYLAYA' +
        'CAK=R.ID),'
      
        #9'ONAYLAYANADI=(select  R.FIRMA from REHBER R where UE.ONAYLAYAN=' +
        'R.ID) '
      'from '
      #9'URETIMEMRI UE left outer join '
      #9'STOKLAR S on UE.STOKID=S.ID '
      #9
      'where '
      #9'UE.ID=:PID')
    Left = 61
    Top = 291
  end
  object DtsUretimEmri: TDataSource
    DataSet = TabUretimEmri
    OnStateChange = DtsUretimEmriStateChange
    Left = 150
    Top = 191
  end
  object TabUretimEmriDetay: TFDQuery
    BeforeOpen = TabUretimEmriDetayBeforeOpen
    AfterOpen = TabUretimEmriDetayAfterOpen
    AfterInsert = TabUretimEmriDetayAfterInsert
    BeforeEdit = TabUretimEmriDetayBeforeEdit
    BeforePost = TabUretimEmriDetayBeforePost
    AfterPost = TabUretimEmriDetayAfterPost
    AfterDelete = TabUretimEmriDetayAfterDelete
    AfterScroll = TabUretimEmriDetayAfterScroll
    OnNewRecord = TabUretimEmriDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      ' UD.* ,'
      
        '               GRP = case when MIKTAR>0 then '#39#220'r'#252'n'#39' else '#39'Bile'#351'e' +
        'n'#39' end,'
      
        '               AD =  CASE WHEN UD.TUR =1 THEN S.STOKADI  ELSE  (' +
        'SELECT AD FROM MASRAFGELIR WHERE ID = UD.URUNID)  END,'
      
        '               KOD =  CASE WHEN UD.TUR =1 THEN S.KOD ELSE  (SELE' +
        'CT KOD FROM MASRAFGELIR WHERE ID= UD.URUNID )  END,'
      'URUNNO =  CASE WHEN UD.TUR =1 THEN S.URUNNO  ELSE '#39'0'#39'  END,'
      'ANABIRIM =  CASE WHEN UD.TUR =1 THEN S.ANABIRIM  ELSE '#39'0'#39'  END,'
      
        'URETILECEK = isnull((select sum(UO.MIKTAR) from URETIMOPERASYON ' +
        'UO where UO.URETIMEMRIID=UD.URETIMEMRIID and UO.URETIMEMRIDETAYI' +
        'D=UD.ID and UO.STOKID=UD.URUNID ),0),'
      
        #9'URETILEN = isnull((select SUM(F.MIKTAR) from FATURA F where MIK' +
        'TAR>0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'TUKETILEN =- isnull((select SUM(F.MIKTAR) from FATURA F where M' +
        'IKTAR<0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'DEPODURUMU=case when UD.TUR=1 then isnull((select SUM(KALAN) fr' +
        'om STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end,'
      
        #9'DEPOGEREKSINIM=case when (UD.MIKTAR-(case when UD.TUR=1 then is' +
        'null((select SUM(KALAN) from STOKDURUM where STOKID=UD.URUNID),0' +
        ') else 999999.0 end))<=0 then 0 else'
      
        #9#9#9#9' (UD.MIKTAR-(case when UD.TUR=1 then isnull((select SUM(KALA' +
        'N) from STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end))' +
        ' end  '
      ''
      'from URETIMEMRIDETAY UD '
      'left outer join STOKLAR S on S.ID = UD.URUNID'
      'where'
      '--UD.MIKTAR>0 and'
      'URETIMEMRIID = :PUrtEmrID')
    Left = 383
  end
  object DtsUretimEmriDetay: TDataSource
    DataSet = TabUretimEmriDetay
    OnStateChange = DtsUretimEmriDetayStateChange
    Left = 257
    Top = 413
  end
  object PopupMenuYaz: TPopupMenu
    Left = 45
    Top = 350
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxUretimEmriDetay: TfrxDBDataset
    UserName = 'UretimEmriDetay'
    CloseDataSource = False
    DataSet = TabUretimEmriDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 174
    Top = 355
  end
  object frxUretimEmri: TfrxDBDataset
    UserName = 'UretimEmri'
    CloseDataSource = False
    DataSet = TabUretimEmri
    BCDToCurrency = False
    DataSetOptions = []
    Left = 117
    Top = 389
  end
  object TabUretimOperasyon: TFDQuery
    AfterOpen = TabUretimOperasyonAfterOpen
    AfterPost = TabUretimOperasyonAfterPost
    AfterScroll = TabUretimOperasyonAfterScroll
    OnCalcFields = TabUretimOperasyonCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @UEID int'
      'set @UEID=:PUrtEmrID'
      ''
      
        'select UO.*,ASD.GBASTAR,ASD.GBITTAR,GERCEKLESEN=isnull(ASD.GERCE' +
        'KLESEN,0.0) ,'
      'STOKKODU=S.KOD,'
      'STOKADI=S.STOKADI, S.URUNNO,'
      'PERSONELAD=(select FIRMA from REHBER where ID = PERSONEL),'
      'RESIM=(case when RESIM is null then 0 else 1 end),'
      
        'DOKUMAN=(case when exists(select GY.ID, STOKID=GY.GOREVID, DOKUM' +
        'ANID=D.ID, DOKUMANAD=D.AD'
      
        #9'from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MO' +
        'DULID=GY.ID '
      #9'where GY.TUR=88 and GOREVID=S.ID) then 1 else 0 end), '
      'LOKASYONADI=L1.ACIKLAMA,'
      'ISMERKEZIADI=L2.ACIKLAMA'
      'from '
      #9'URETIMOPERASYON UO left outer join'
      #9'('#9'select '
      
        #9#9#9'UOID=UO1.ID,GBASTAR=min(FB.TARIH),GBITTAR=max(FB.FATURATARIH)' +
        ',GERCEKLESEN=SUM(F.MIKTAR) '
      #9#9'from '
      #9#9#9'URETIMOPERASYON UO1 inner join '
      #9#9#9'FATBASLIK FB on FB.YERI=142 and FB.YERID=UO1.ID inner join'
      
        #9#9#9'FATURA F on F.FATBASID=FB.ID and F.TUR=1 and UO1.STOKID=F.URU' +
        'NID'
      #9#9'where UO1.URETIMEMRIID=@UEID'
      #9#9'group by UO1.ID'
      #9') as ASD on'
      #9'UO.ID=ASD.UOID'
      'left outer join LOKASYON L1 on UO.LOKASYON=L1.ID'
      'left outer join LOKASYON L2 on UO.ISMERKEZI=L2.ID'
      'left outer join STOKLAR S on UO.STOKID=S.ID'
      'where UO.URETIMEMRIID=@UEID'
      '')
    Left = 316
    Top = 149
    object TabUretimOperasyonID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabUretimOperasyonURETIMEMRIID: TIntegerField
      FieldName = 'URETIMEMRIID'
    end
    object TabUretimOperasyonURETIMEMRIDETAYID: TIntegerField
      FieldName = 'URETIMEMRIDETAYID'
    end
    object TabUretimOperasyonHEDEFOPERASYON: TIntegerField
      FieldName = 'HEDEFOPERASYON'
    end
    object TabUretimOperasyonSTOKID: TIntegerField
      FieldName = 'STOKID'
    end
    object TabUretimOperasyonRECETEID: TIntegerField
      FieldName = 'RECETEID'
    end
    object TabUretimOperasyonLOKASYON: TIntegerField
      FieldName = 'LOKASYON'
    end
    object TabUretimOperasyonISMERKEZI: TIntegerField
      FieldName = 'ISMERKEZI'
    end
    object TabUretimOperasyonPERSONEL2: TIntegerField
      FieldName = 'PERSONEL'
    end
    object TabUretimOperasyonBASTAR: TSQLTimeStampField
      FieldName = 'BASTAR'
    end
    object TabUretimOperasyonBITTAR: TSQLTimeStampField
      FieldName = 'BITTAR'
    end
    object TabUretimOperasyonADET: TFloatField
      FieldName = 'ADET'
    end
    object TabUretimOperasyonBIRIM: TIntegerField
      FieldName = 'BIRIM'
    end
    object TabUretimOperasyonMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object TabUretimOperasyonACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabUretimOperasyonOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
    end
    object TabUretimOperasyonMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabUretimOperasyonYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabUretimOperasyonYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabUretimOperasyonEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabUretimOperasyonEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabUretimOperasyonDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabUretimOperasyonDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabUretimOperasyonSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabUretimOperasyonGIRISDEPO: TIntegerField
      FieldName = 'GIRISDEPO'
    end
    object TabUretimOperasyonCIKISDEPO: TIntegerField
      FieldName = 'CIKISDEPO'
    end
    object TabUretimOperasyonRECETEDETAYID: TIntegerField
      FieldName = 'RECETEDETAYID'
    end
    object TabUretimOperasyonURETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object TabUretimOperasyonURETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object TabUretimOperasyonGBASTAR: TSQLTimeStampField
      FieldName = 'GBASTAR'
      ReadOnly = True
    end
    object TabUretimOperasyonGBITTAR: TSQLTimeStampField
      FieldName = 'GBITTAR'
      ReadOnly = True
    end
    object TabUretimOperasyonGERCEKLESEN: TFMTBCDField
      FieldName = 'GERCEKLESEN'
      ReadOnly = True
      Precision = 38
      Size = 6
    end
    object TabUretimOperasyonSTOKKODU: TWideStringField
      FieldName = 'STOKKODU'
      Size = 25
    end
    object TabUretimOperasyonSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabUretimOperasyonURUNNO: TWideStringField
      FieldName = 'URUNNO'
    end
    object TabUretimOperasyonRESIM: TIntegerField
      FieldName = 'RESIM'
      ReadOnly = True
    end
    object TabUretimOperasyonDOKUMAN: TIntegerField
      FieldName = 'DOKUMAN'
      ReadOnly = True
    end
    object TabUretimOperasyonLOKASYONADI: TWideStringField
      FieldName = 'LOKASYONADI'
      Size = 100
    end
    object TabUretimOperasyonISMERKEZIADI: TWideStringField
      FieldName = 'ISMERKEZIADI'
      Size = 100
    end
    object TabUretimOperasyonPERSONELAD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'PERSONELAD'
      Size = 64
      Calculated = True
    end
  end
  object DtsUretimOperasyon: TDataSource
    DataSet = TabUretimOperasyon
    OnStateChange = DtsUretimOperasyonStateChange
    Left = 245
    Top = 321
  end
  object frxUretimOperasyon: TfrxDBDataset
    UserName = 'UretimOperasyon'
    CloseDataSource = False
    DataSet = TabUretimOperasyon
    BCDToCurrency = False
    DataSetOptions = []
    Left = 242
    Top = 335
  end
  object TabUretimOperasyonDetay: TFDQuery
    AfterPost = TabUretimOperasyonDetayAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select F.*, '
      'GRP = case when MIKTAR>0 then '#39#220'r'#252'n'#39' else '#39'Bile'#351'en'#39' end,'
      
        'AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FROM STOKLAR WHERE' +
        ' ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = F.' +
        'URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM STOKLAR WHERE ID' +
        ' =F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= F.URUN' +
        'ID )  END,'
      'FB.TARIH,FB.FATURATARIH,FB.FATURANO'
      ''
      'from FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID'
      ''
      'where FB.YERI=142 and FB.YERID = :POpID')
    Left = 725
    Top = 312
  end
  object DtsTabUretimOperasyonDetay: TDataSource
    DataSet = TabUretimOperasyonDetay
    Left = 341
    Top = 308
  end
  object frxUretimOperasyonDetay: TfrxDBDataset
    UserName = 'UretimOperasyonDetay'
    CloseDataSource = False
    DataSet = TabUretimOperasyonDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 342
    Top = 355
  end
  object TabOperasyonEkMaliyet: TFDQuery
    AfterPost = TabOperasyonEkMaliyetAfterPost
    OnNewRecord = TabOperasyonEkMaliyetNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      'UOM.* ,'
      
        '               AD =   (SELECT AD FROM MASRAFGELIR WHERE ID = UOM' +
        '.MASRAFID),'
      
        '               KOD =   (SELECT KOD FROM MASRAFGELIR WHERE ID= UO' +
        'M.MASRAFID )'
      ''
      
        'from URETIMOPERASYONMALIYET UOM where URETIMOPERASYONID=:PUrtOpI' +
        'D')
    Left = 522
    Top = 172
  end
  object DtsOperasyonEkMaliyet: TDataSource
    DataSet = TabOperasyonEkMaliyet
    OnStateChange = DtsOperasyonEkMaliyetStateChange
    Left = 451
    Top = 321
  end
  object frxOperasyonEkMaliyet: TfrxDBDataset
    UserName = 'OperasyonEkMaliyet'
    CloseDataSource = False
    DataSet = TabOperasyonEkMaliyet
    BCDToCurrency = False
    DataSetOptions = []
    Left = 432
    Top = 335
  end
  object TabUrToplamMaliyet: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @UEID int'
      'set @UEID=:PUrtOpID'
      ''
      
        'select TIP=2,MG.KOD,MG.AD,UOM.TUTAR,UOM.KUR,UOM.ACIKLAMA,BIRIMMA' +
        'LIYET= UOM.TUTAR/UE.ADET '
      'from '
      #9'URETIMOPERASYONMALIYET UOM inner join '
      #9'MASRAFGELIR MG on UOM.MASRAFID=MG.ID inner join '
      #9'URETIMEMRI UE on UOM.URETIMEMRIID=UE.ID'
      'where UOM.URETIMEMRIID=@UEID'
      ''
      'union all'
      ''
      'select '
      
        #9'TIP=1,S.KOD,S.STOKADI,UED.TOPLAMMALIYET,UED.KUR,UED.ACIKLAMA,BI' +
        'RIMMALIYET= UED.TOPLAMMALIYET/UE.ADET'
      'from '
      #9'URETIMEMRIDETAY UED  inner join'
      #9'STOKLAR S on UED.URUNID=S.ID and UED.TUR=1 inner join '
      #9'URETIMEMRI UE on UED.URETIMEMRIID=UE.ID'
      'where UED.TOPLAMMALIYET>0 and UED.URETIMEMRIID=@UEID'
      ''
      '')
    Left = 506
    Top = 24
  end
  object DtsUrToplamMaliyet: TDataSource
    DataSet = TabUrToplamMaliyet
    OnStateChange = DtsOperasyonEkMaliyetStateChange
    Left = 667
    Top = 21
  end
  object frxUrToplamMaliyet: TfrxDBDataset
    UserName = 'UrToplamMaliyet'
    CloseDataSource = False
    DataSet = TabUrToplamMaliyet
    BCDToCurrency = False
    DataSetOptions = []
    Left = 512
    Top = 347
  end
  object PopupOperasyonOlustur: TPopupMenu
    OnPopup = PopupOperasyonOlusturPopup
    Left = 24
    Top = 128
    object SeiliOperasyonuOlutur1: TMenuItem
      Caption = 'Se'#231'ili Operasyonu Olu'#351'tur'
      OnClick = SeiliOperasyonuOlutur1Click
    end
    object EksikOperasyonuOlustu: TMenuItem
      Caption = 'Eksik '#304#351'aretli Operasyonlar'#305' Olu'#351'tur'
      OnClick = EksikOperasyonuOlustuClick
    end
    object TumOperasyonuOlutur: TMenuItem
      Caption = 'T'#252'm Operasyonlar'#305' Olu'#351'tur'
      OnClick = TumOperasyonuOluturClick
    end
  end
  object TabUretimOperasyonPersonel: TFDQuery
    AfterOpen = TabUretimOperasyonPersonelAfterOpen
    OnCalcFields = TabUretimOperasyonPersonelCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      'UO.*,'
      '----SURE=[dbo].[fn_TarihFarkiFormatli]( BASLAMA, BITIS ),'
      
        'OLCUMSAY=(select count(*) from URETIMOLCUM OLC where OLC.OPERASY' +
        'ONPERSONELID = UO.ID),'
      'OLCUM=CASE WHEN exists(select * from URETIMOLCUM UOLC '
      ' where UOLC.OPERASYONID= UO.OPERASYONID) THEN 1 ELSE 0 END,'
      
        'SORUMLUADI=(select r.FIRMA from REHBER R where UO.PERSONEL=R.ID)' +
        ','
      
        'LOKASYONADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.LOKASY' +
        'ON=L1.ID),'
      
        'KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L' +
        '1.ID)'
      'from URETIMOPERASYONPERSONEL UO '
      'where UO.OPERASYONID=:PRM1'
      'and  UO.DURUM<=:PRM2'
      'order by SIRA, ID')
    Left = 749
    Top = 144
    object TabUretimOperasyonPersonelID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabUretimOperasyonPersonelOPERASYONID: TIntegerField
      FieldName = 'OPERASYONID'
    end
    object TabUretimOperasyonPersonelTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
    end
    object TabUretimOperasyonPersonelPERSONEL: TIntegerField
      FieldName = 'PERSONEL'
    end
    object TabUretimOperasyonPersonelLOKASYON: TIntegerField
      FieldName = 'LOKASYON'
    end
    object TabUretimOperasyonPersonelKAYNAK: TIntegerField
      FieldName = 'KAYNAK'
    end
    object TabUretimOperasyonPersonelBASLAMA: TSQLTimeStampField
      FieldName = 'BASLAMA'
    end
    object TabUretimOperasyonPersonelBITIS: TSQLTimeStampField
      FieldName = 'BITIS'
    end
    object TabUretimOperasyonPersonelMOLA: TSQLTimeStampField
      FieldName = 'MOLA'
    end
    object TabUretimOperasyonPersonelSURE: TStringField
      FieldKind = fkCalculated
      FieldName = 'SURE'
      Size = 5
      Calculated = True
    end
    object TabUretimOperasyonPersonelADET: TFloatField
      FieldName = 'ADET'
    end
    object TabUretimOperasyonPersonelBIRIM: TIntegerField
      FieldName = 'BIRIM'
    end
    object TabUretimOperasyonPersonelMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object TabUretimOperasyonPersonelKONUSU: TWideStringField
      FieldName = 'KONUSU'
      Size = 100
    end
    object TabUretimOperasyonPersonelDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabUretimOperasyonPersonelEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabUretimOperasyonPersonelEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabUretimOperasyonPersonelDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabUretimOperasyonPersonelDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabUretimOperasyonPersonelLOKASYONADI: TWideStringField
      FieldName = 'LOKASYONADI'
      ReadOnly = True
      Size = 100
    end
    object TabUretimOperasyonPersonelKAYNAKADI: TWideStringField
      FieldName = 'KAYNAKADI'
      ReadOnly = True
      Size = 100
    end
    object TabUretimOperasyonPersonelSORUMLUADI: TWideStringField
      FieldName = 'SORUMLUADI'
      ReadOnly = True
      Size = 120
    end
    object TabUretimOperasyonPersonelACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabUretimOperasyonPersonelSIRA: TSmallintField
      FieldName = 'SIRA'
    end
    object TabUretimOperasyonPersonelPLANSURE: TSQLTimeStampField
      FieldName = 'PLANSURE'
    end
    object TabUretimOperasyonPersonelOLCUMSAY: TIntegerField
      FieldName = 'OLCUMSAY'
    end
  end
  object DtsUretimOperasyonPersonel: TDataSource
    DataSet = TabUretimOperasyonPersonel
    Left = 885
    Top = 300
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 719
    Top = 364
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 688
    Top = 496
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 840
    Top = 400
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
    end
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 1020
    Top = 396
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 1003
    Top = 337
  end
  object TabPlanlama: TFDQuery
    AfterPost = TabUretimOperasyonDetayAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'declare @UretimEmriID int=:PUretimEmriID , @OperasyonID int=:POp' +
        'ID, @SadeceHammadde int=:PSadeceHammadde'
      ''
      'select '
      #9'UED2.ID, STOKID=S.ID, S.KOD, S.STOKADI,'
      'RESIM=(case when S.RESIM is null then 0 else 1 end),'
      
        'DOKUMAN=(case when exists(select GY.ID, STOKID=GY.GOREVID, DOKUM' +
        'ANID=D.ID, DOKUMANAD=D.AD'
      
        #9'from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MO' +
        'DULID=GY.ID '
      #9'where GY.TUR=88 and GOREVID=S.ID) then 1 else 0 end), '
      ''
      ''
      'S.ANABIRIM, GEREKSINIM=(UED.MIKTAR/OP.MIKTAR)*UED2.MIKTAR,'
      
        #9'DEPODURUM=(select ADET from fn_StokDurumDetay(S.ID,0) where TIP' +
        '='#39'Depo Toplam'#39'),'
      
        #9'GIRECEKCIKACAK=(select ADET from fn_StokDurumDetay(S.ID,0) wher' +
        'e TIP='#39'Sipari'#351' Toplam'#39'),'
      
        #9'GENELDURUM=(select ADET from fn_StokDurumDetay(S.ID,0) where TI' +
        'P='#39'Genel Toplam'#39'),'
      
        '    STOKTALEP=  (select isnull(sum(MIKTAR),0) from SIPARISDETAY ' +
        'SD where SD.YERI=467 and SD.YERID = UED2.ID),'
      
        '    SATINALMATALEP=  (select isnull(sum(MIKTAR),0) from SIPARISD' +
        'ETAY SD where SD.YERI=465 and SD.YERID = UED2.ID),'
      #9'UED2.ACIKLAMA'
      ''
      'from URETIMEMRIDETAY UED '
      'inner join URETIMEMRIDETAY UED2 on UED2.USTID=UED.ID '
      'inner join URETIMOPERASYON OP on OP.URETIMEMRIDETAYID=UED.ID'
      'inner join STOKLAR S on S.ID=UED2.URUNID'
      'where '
      #9'UED.URETIMEMRIID = @UretimEmriID and'
      #9'@OperasyonID in (0,OP.ID) and'
      
        #9'1 = case when @SadeceHammadde = 0  then 1 when @SadeceHammadde ' +
        '= 1 and UED2.KAYNAKRECETEDETAYID is null then 1 else 0 end'
      '')
    Left = 637
    Top = 152
  end
  object DtsPlanlama: TDataSource
    DataSet = TabPlanlama
    Left = 621
    Top = 308
  end
  object PopupOperasyonPlanlama: TPopupMenu
    OnPopup = PopupOperasyonOlusturPopup
    Left = 800
    Top = 448
    object IsaretlilereAlimTalebiOlustur: TMenuItem
      Tag = 101
      Caption = 'Gereksinime G'#246're Sat'#305'nalma Talebi Olu'#351'tur'
      OnClick = IsaretlilereAlimTalebiOlusturClick
    end
    object GenelDurumaGreSatnalmaTalebiOlutur1: TMenuItem
      Tag = 101
      Caption = 'Genel Duruma G'#246're Sat'#305'nalma Talebi Olu'#351'tur'
      OnClick = GenelDurumaGreSatnalmaTalebiOlutur1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object GereksinimOlanlaraStoktanTalepOlutur1: TMenuItem
      Tag = 105
      Caption = 'Gereksinime G'#246're Stoktan Talep Olu'#351'tur'
      OnClick = IsaretlilereAlimTalebiOlusturClick
    end
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 398
    Top = 411
  end
  object PopupUretimFisi: TPopupMenu
    Left = 133
    Top = 336
    object kalaniuret: TMenuItem
      Caption = #220'ret'
      OnClick = kalaniuretClick
    end
  end
  object PopupIsZamanPer: TPopupMenu
    Left = 109
    Top = 568
    object MenuTumKonular: TMenuItem
      Caption = 'T'#252'm '#304#351' Emri Konular'#305'n'#305' Ekle'
      OnClick = MenuTumKonularClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object RecetedenKonularEkleMenu: TMenuItem
      Caption = 'Re'#231'eteden Konular'#305' Ekle'
      OnClick = RecetedenKonularEkleMenuClick
    end
  end
  object frxUretimOperasyonPersonel: TfrxDBDataset
    UserName = 'UrOperasyonPersonel'
    CloseDataSource = False
    DataSet = TabUretimOperasyonPersonel
    BCDToCurrency = False
    DataSetOptions = []
    Left = 600
    Top = 411
  end
  object Query20: TFDQuery
    Connection = Tablo.FDCnn
    Left = 386
    Top = 67
  end
  object Query19: TFDQuery
    Connection = Tablo.FDCnn
    Left = 210
    Top = 179
  end
  object TabOperasyonFason: TFDQuery
    BeforePost = TabOperasyonFasonBeforePost
    OnCalcFields = TabOperasyonFasonCalcFields
    OnNewRecord = TabOperasyonFasonNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      '* '
      'from URETIMOPERASYONFASON UOF '
      'where URETIMOPERASYONID=:PUrtOpID'
      'order by TARIH asc')
    Left = 314
    Top = 228
    object TabOperasyonFasonID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabOperasyonFasonURETIMEMRIID: TIntegerField
      FieldName = 'URETIMEMRIID'
    end
    object TabOperasyonFasonURETIMOPERASYONID: TIntegerField
      FieldName = 'URETIMOPERASYONID'
    end
    object TabOperasyonFasonTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
    end
    object TabOperasyonFasonREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabOperasyonFasonCARIAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'CARIAD'
      Size = 120
      Calculated = True
    end
    object TabOperasyonFasonBELGENO: TWideStringField
      FieldName = 'BELGENO'
      Size = 30
    end
    object TabOperasyonFasonACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabOperasyonFasonGIREN: TFMTBCDField
      FieldName = 'GIREN'
      Precision = 18
    end
    object TabOperasyonFasonCIKAN: TFMTBCDField
      FieldName = 'CIKAN'
      Precision = 18
    end
    object TabOperasyonFasonBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object TabOperasyonFasonYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabOperasyonFasonYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabOperasyonFasonEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabOperasyonFasonEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabOperasyonFasonDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabOperasyonFasonDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabOperasyonFasonSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabOperasyonFasonOLAY: TWordField
      FieldName = 'OLAY'
    end
    object TabOperasyonFasonTUR: TWordField
      FieldName = 'TUR'
    end
    object TabOperasyonFasonFASONTIPI: TWordField
      FieldName = 'FASONTIPI'
    end
  end
  object DtsOperasyonFason: TDataSource
    DataSet = TabOperasyonFason
    OnStateChange = DtsOperasyonFasonStateChange
    Left = 453
    Top = 228
  end
  object DtsGereksinim: TDataSource
    DataSet = TabGereksinim
    OnStateChange = DtsOperasyonEkMaliyetStateChange
    Left = 667
    Top = 77
  end
  object TabGereksinim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE @URETIMEMRIID INT'
      ''
      'SET @URETIMEMRIID = :PRM1'
      ''
      'select'
      #9'GRP = case when UD.MIKTAR>0 then '#39#220'r'#252'n'#39' else '#39'Bile'#351'en'#39' end,'
      
        #9'AD =  CASE WHEN UD.TUR =1 THEN (SELECT STOKADI FROM STOKLAR WHE' +
        'RE ID = UD.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID =' +
        ' UD.URUNID)  END,'
      
        #9'KOD =  CASE WHEN UD.TUR =1 THEN (SELECT KOD FROM STOKLAR WHERE ' +
        'ID =UD.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= UD.' +
        'URUNID )  END,'
      
        #9'URUNNO =  CASE WHEN UD.TUR =1 THEN (SELECT URUNNO FROM STOKLAR ' +
        'WHERE ID =UD.URUNID ) ELSE '#39'0'#39'  END,'
      #9'ISTENEN = UD.MIKTAR,'
      
        #9'URETILECEK = isnull((select sum(UO.MIKTAR) from URETIMOPERASYON' +
        ' UO where UO.URETIMEMRIID=UD.URETIMEMRIID and UO.URETIMEMRIDETAY' +
        'ID=UD.ID and UO.STOKID=UD.URUNID ),0),'
      
        #9'URETILEN = isnull((select SUM(F.MIKTAR) from FATURA F where MIK' +
        'TAR>0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'TUKETILEN =- isnull((select SUM(F.MIKTAR) from FATURA F where M' +
        'IKTAR<0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'DEPODURUMU=case when UD.TUR=1 then isnull((select SUM(KALAN) fr' +
        'om STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end,'
      
        #9'DEPOGEREKSINIM=case when (UD.MIKTAR-(case when UD.TUR=1 then is' +
        'null((select SUM(KALAN) from STOKDURUM where STOKID=UD.URUNID),0' +
        ') else 999999.0 end))<=0 then 0 else'#9'(UD.MIKTAR-(case when UD.TU' +
        'R=1 then isnull((select SUM(KALAN) from STOKDURUM where STOKID=U' +
        'D.URUNID),0) else 999999.0 end)) end,'
      
        #9'GIRECEKCIKACAK = CAST(ISNULL((select ADET from fn_StokDurumDeta' +
        'y(UD.URUNID,0) where TIP='#39'Sipari'#351' Toplam'#39'),0) AS DECIMAL(18,2)),'
      
        #9'TAHMINIKALAN = ISNULL((select ADET from fn_StokDurumDetay(UD.UR' +
        'UNID,0) where TIP='#39'Genel Toplam'#39'),0)'
      
        #9'--CAST(ISNULL(case when UD.TUR=1 then isnull((select SUM(KALAN)' +
        ' from STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end,0) ' +
        '- ABS(ISNULL((select ADET from fn_StokDurumDetay(UD.URUNID,0) wh' +
        'ere TIP='#39'Sipari'#351' Toplam'#39'),0)) AS DECIMAL(18,2))'
      'from '
      
        #9'URETIMEMRIDETAY UD INNER JOIN URETIMEMRI U ON U.ID = UD.URETIME' +
        'MRIID'
      'where'
      #9'URETIMEMRIID = @URETIMEMRIID'
      #9'AND U.DURUM <> -1')
    Left = 506
    Top = 80
  end
  object frxFasonSatir: TfrxDBDataset
    UserName = 'FasonSatir'
    CloseDataSource = False
    DataSet = TabFasonSatir
    BCDToCurrency = False
    DataSetOptions = []
    Left = 285
    Top = 549
  end
  object TabFasonSatir: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT *,'
      ' OLAYAD= case when OLAY=0 then '#39#199'IKI'#350#39' else '#39'G'#304'R'#304#350#39' end '
      ',CARIAD=(select FIRMA from REHBER where ID=REHBERID)'
      ', TURAD= case when TUR=1 then '#39#304'rsaliye'#39' else '#39'Di'#287'er'#39' end '
      
        ',BIRIMAD =  (select ANAHTAR from GENINI where BOLUM=-2702 and DE' +
        'GER=BIRIM) '
      
        ',FASONTIPIAD = (select ANAHTAR from GENINI where BOLUM=-2799 and' +
        ' DEGER=FASONTIPI) '
      'from URETIMOPERASYONFASON UOF '
      'where ID=:PUrtFasonID')
    Left = 418
    Top = 548
  end
end
