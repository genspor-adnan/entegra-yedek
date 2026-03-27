object KYSapmaOlayWizardDlg: TKYSapmaOlayWizardDlg
  Left = 0
  Top = 0
  ActiveControl = ComboTipi
  BorderIcons = [biSystemMenu]
  Caption = 'Sapma / Olay Olu'#351'turma Sihirbaz'#305
  ClientHeight = 617
  ClientWidth = 1133
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 1133
    Height = 617
    ActivePage = PageDOF
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Kaydet'
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
      1133
      617)
    object PageDOF: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Sapma / Olay Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      OnExitPage = PageDOFExitPage
      object cxGroupBox1: TcxGroupBox
        Left = 0
        Top = 105
        Align = alTop
        Caption = 'Sapma / Olay '#304'ste'#287'ini Talep Eden'
        PanelStyle.OfficeBackgroundKind = pobkGradient
        Style.LookAndFeel.Kind = lfStandard
        Style.LookAndFeel.NativeStyle = False
        Style.LookAndFeel.SkinName = 'LondonLiquidSky'
        StyleDisabled.LookAndFeel.Kind = lfStandard
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
        TabOrder = 0
        Height = 197
        Width = 1133
        object ComboTipi: TcxDBImageComboBox
          Left = 125
          Top = 19
          DataBinding.DataField = 'TIPI'
          DataBinding.DataSource = DtsSapmaOlay
          Properties.Items = <
            item
              Description = 'Sapma'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Olay'
              Value = 2
            end
            item
              Description = 'Ramak Kala'
              Value = 3
            end>
          Style.Color = clWhite
          TabOrder = 0
          Width = 148
        end
        object cxLabel1: TcxLabel
          Left = 12
          Top = 21
          Caption = 'Tipi'
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 684
          Top = 17
          Caption = 'Durum'
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 12
          Top = 44
          Caption = 'Referans No'
          Style.TextColor = clRed
          Transparent = True
        end
        object editREFERANSNO: TcxDBTextEdit
          Left = 125
          Top = 43
          DataBinding.DataField = 'REFERANSNO'
          DataBinding.DataSource = DtsSapmaOlay
          Style.Color = clBtnFace
          TabOrder = 1
          Width = 148
        end
        object cxLabel8: TcxLabel
          Left = 12
          Top = 165
          Caption = 'Ba'#351'latan Ki'#351'i'
          Style.TextColor = clRed
          Transparent = True
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 733
          Top = 15
          RepositoryItem = Tablo.RepKYSapmaOlayDurum
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsSapmaOlay
          Properties.ImmediatePost = True
          Properties.Items = <>
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 15
          Width = 101
        end
        object EditBaslatanKisi: TcxButtonEdit
          Left = 125
          Top = 162
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditTalepEdenPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 7
          Width = 148
        end
        object DateTarih: TcxDBDateEdit
          Left = 319
          Top = 163
          DataBinding.DataField = 'KAYITTARIHI'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 9
          Width = 107
        end
        object ComboKATEGORI: TcxDBImageComboBox
          Left = 125
          Top = 91
          RepositoryItem = Tablo.RepKYSapmaOlayKategori
          DataBinding.DataField = 'KATEGORI'
          DataBinding.DataSource = DtsSapmaOlay
          Properties.ImmediatePost = True
          Properties.Items = <>
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 4
          Width = 300
        end
        object LabelKategori: TcxLabel
          Left = 12
          Top = 93
          Cursor = crHandPoint
          Caption = 'Kategori'
          Transparent = True
          OnClick = LabelKategoriClick
        end
        object EditURUN: TcxDBButtonEdit
          Left = 614
          Top = 39
          DataBinding.DataField = 'URUNADI'
          DataBinding.DataSource = DtsSapmaOlay
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = EditURUNPropertiesButtonClick
          TabOrder = 8
          Width = 220
        end
        object cxLabel13: TcxLabel
          Left = 501
          Top = 41
          Caption = #220'r'#252'n / Materyal'
        end
        object BeditProje: TcxButtonEdit
          Left = 125
          Top = 115
          ParentShowHint = False
          Properties.Buttons = <
            item
              Caption = '++'
              Default = True
              Kind = bkText
            end
            item
              Caption = '+'
              Kind = bkText
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.MaxLength = 0
          Properties.OnButtonClick = BeditProjePropertiesButtonClick
          ShowHint = True
          TabOrder = 5
          Width = 300
        end
        object cxLabel7: TcxLabel
          Left = 12
          Top = 116
          Caption = 'Proje'
          Transparent = True
        end
        object cxLabel5: TcxLabel
          Left = 12
          Top = 140
          Caption = 'Departman'
          Transparent = True
        end
        object EditDepartman: TcxButtonEdit
          Left = 125
          Top = 139
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
          TabOrder = 6
          Width = 300
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 614
          Top = 62
          DataBinding.DataField = 'SERINO'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 10
          Width = 220
        end
        object cxLabel6: TcxLabel
          Left = 501
          Top = 64
          Caption = 'Seri No'
        end
        object cxDBTextEdit2: TcxDBTextEdit
          Left = 614
          Top = 85
          DataBinding.DataField = 'BOYUTU'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 11
          Width = 220
        end
        object cxLabel10: TcxLabel
          Left = 501
          Top = 87
          Caption = 'Boyutu'
        end
        object cxLabel14: TcxLabel
          Left = 501
          Top = 109
          Caption = #220'retim Tarihi'
          Transparent = True
        end
        object cxDBDateEdit1: TcxDBDateEdit
          Left = 614
          Top = 109
          DataBinding.DataField = 'URETIMTARIHI'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 12
          Width = 101
        end
        object cxLabel16: TcxLabel
          Left = 721
          Top = 110
          Caption = 'SKT'
          Transparent = True
        end
        object cxDBDateEdit2: TcxDBDateEdit
          Left = 745
          Top = 109
          DataBinding.DataField = 'SKTARIHI'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 13
          Width = 89
        end
        object cxLabel18: TcxLabel
          Left = 501
          Top = 132
          Caption = 'Di'#287'er'
          Transparent = True
        end
        object cxDBMemo1: TcxDBMemo
          Left = 614
          Top = 132
          Align = alCustom
          DataBinding.DataField = 'DIGER'
          DataBinding.DataSource = DtsSapmaOlay
          Properties.ScrollBars = ssVertical
          TabOrder = 14
          Height = 53
          Width = 369
        end
        object cxDBDateEdit3: TcxDBDateEdit
          Left = 329
          Top = 43
          DataBinding.DataField = 'TARIH'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 2
          Width = 96
        end
        object cxLabel17: TcxLabel
          Left = 293
          Top = 44
          Caption = 'Tarihi'
          Transparent = True
        end
        object cxLabel28: TcxLabel
          Left = 282
          Top = 163
          Caption = 'Kay'#305't'
          Transparent = True
        end
        object EditKONUSU: TcxDBTextEdit
          Left = 125
          Top = 67
          DataBinding.DataField = 'KONUSU'
          DataBinding.DataSource = DtsSapmaOlay
          TabOrder = 3
          Width = 300
        end
        object cxLabel29: TcxLabel
          Left = 12
          Top = 68
          Caption = 'Konusu'
          Style.TextColor = clRed
        end
      end
      object cxGroupBox3: TcxGroupBox
        Left = 0
        Top = 302
        Align = alClient
        Caption = 'Denetim Faaliyeti Sonucu'
        TabOrder = 1
        Height = 273
        Width = 1133
        object PageControl1: TcxPageControl
          Left = 2
          Top = 18
          Width = 1129
          Height = 253
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = cxTabSheet1
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 249
          ClientRectLeft = 4
          ClientRectRight = 1125
          ClientRectTop = 24
          object cxTabSheet1: TcxTabSheet
            Caption = 'Detay'
            ImageIndex = 3
            object cxLabel20: TcxLabel
              Left = 17
              Top = 4
              Caption = 'Detay'
              Transparent = True
            end
            object cxLabel12: TcxLabel
              Left = 17
              Top = 80
              Caption = 'Nedeni'
              Transparent = True
            end
            object cxLabel19: TcxLabel
              Left = 17
              Top = 155
              Caption = 'K'#246'k Nedeni'
              Transparent = True
            end
            object cxDBMemo2: TcxDBMemo
              Left = 132
              Top = 3
              Align = alCustom
              DataBinding.DataField = 'DETAY'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 0
              Height = 63
              Width = 700
            end
            object MemoNEDENI: TcxDBMemo
              Left = 132
              Top = 79
              Align = alCustom
              DataBinding.DataField = 'NEDENI'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 1
              Height = 63
              Width = 700
            end
            object cxDBMemo3: TcxDBMemo
              Left = 132
              Top = 154
              Align = alCustom
              DataBinding.DataField = 'ANANEDEN'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 2
              Height = 63
              Width = 700
            end
          end
          object TabSheetSonuc: TcxTabSheet
            Caption = '   Sonu'#231'   '
            ImageIndex = 0
            object cxLabel21: TcxLabel
              Left = 20
              Top = 94
              Caption = 'Gerek'#231'e'
              Transparent = True
            end
            object cxLabel22: TcxLabel
              Left = 20
              Top = 49
              Caption = 'Eylem Plan'#305
              Transparent = True
            end
            object cxLabel23: TcxLabel
              Left = 20
              Top = 3
              Caption = 'Etki De'#287'erlendirmesi'
              Transparent = True
            end
            object cxDBMemo4: TcxDBMemo
              Left = 128
              Top = 3
              Align = alCustom
              DataBinding.DataField = 'ETKIDEGERLENDIRMESI'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 3
              Height = 41
              Width = 700
            end
            object cxDBMemo5: TcxDBMemo
              Left = 128
              Top = 50
              Align = alCustom
              DataBinding.DataField = 'EYLEMPLANI'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 4
              Height = 41
              Width = 700
            end
            object cxDBMemo6: TcxDBMemo
              Left = 128
              Top = 97
              Align = alCustom
              DataBinding.DataField = 'GEREKCE'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 5
              Height = 41
              Width = 700
            end
            object cxLabel24: TcxLabel
              Left = 20
              Top = 140
              Caption = 'Sonu'#231
              Transparent = True
            end
            object cxDBMemo7: TcxDBMemo
              Left = 128
              Top = 144
              Align = alCustom
              DataBinding.DataField = 'SONUC'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.ScrollBars = ssVertical
              TabOrder = 6
              Height = 41
              Width = 700
            end
          end
          object cxTabSheet2: TcxTabSheet
            Caption = 'Onaylar'
            ImageIndex = 4
            object cxLabel3: TcxLabel
              Left = 8
              Top = 6
              Caption = 'Onama'
              Transparent = True
            end
            object cxDBImageComboBox1: TcxDBImageComboBox
              Left = 142
              Top = 3
              DataBinding.DataField = 'ONAYRED'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.Items = <
                item
                  ImageIndex = 0
                  Value = 2
                end
                item
                  Description = 'Red'
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'Onay'
                  Value = 1
                end>
              TabOrder = 0
              Width = 203
            end
            object LabelKurum: TcxLabel
              Left = 8
              Top = 42
              Caption = 'Gereksinim belirleme Onay'
              Transparent = True
            end
            object ComboGEREKSINIM_ONAYTIPI: TcxDBImageComboBox
              Left = 142
              Top = 41
              DataBinding.DataField = 'GEREKSINIM_ONAYTIPI'
              DataBinding.DataSource = DtsSapmaOlay
              Properties.Items = <
                item
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'D'#252'zenleyici'
                  ImageIndex = 0
                  Value = 1
                end
                item
                  Description = 'M'#252#351'teri'
                  Value = 2
                end
                item
                  Description = 'S'#246'zle'#351'me Veren'
                  Value = 3
                end
                item
                  Description = 'Lisans Sahibi'
                  Value = 4
                end>
              Properties.OnCloseUp = ComboGEREKSINIM_ONAYTIPIPropertiesCloseUp
              TabOrder = 1
              Width = 203
            end
            object ComboKurum: TcxButtonEdit
              Left = 349
              Top = 40
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Kind = bkText
                end>
              Properties.MaxLength = 0
              Properties.ReadOnly = True
              Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
              Style.LookAndFeel.NativeStyle = False
              StyleDisabled.LookAndFeel.NativeStyle = False
              StyleFocused.LookAndFeel.NativeStyle = False
              StyleHot.LookAndFeel.NativeStyle = False
              StyleReadOnly.LookAndFeel.NativeStyle = False
              TabOrder = 2
              Width = 364
            end
            object cxGroupBox2: TcxGroupBox
              Left = 8
              Top = 84
              Caption = 'Sorumlu Y'#246'netici'
              TabOrder = 5
              Height = 101
              Width = 353
              object cxLabel15: TcxLabel
                Left = 10
                Top = 20
                Caption = 'Onaylayacak'
                Transparent = True
              end
              object cxLabel9: TcxLabel
                Left = 10
                Top = 50
                Caption = 'Onaylayan'
                Transparent = True
              end
              object EditOnaylayanYonetici: TcxButtonEdit
                Left = 136
                Top = 44
                Hint = 'SORUMLU'
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
                Properties.OnButtonClick = EditOnaylayanYoneticiPropertiesButtonClick
                TabOrder = 3
                Width = 201
              end
              object cxDBDateEdit4: TcxDBDateEdit
                Left = 136
                Top = 72
                DataBinding.DataField = 'SORUMLU_ONAYLAYAN_TARIHI'
                DataBinding.DataSource = DtsSapmaOlay
                TabOrder = 5
                Width = 113
              end
              object cxLabel26: TcxLabel
                Left = 10
                Top = 78
                Caption = 'Onay Tarihi'
                Transparent = True
              end
              object EditSorumluOnaylayacak: TcxButtonEdit
                Left = 134
                Top = 17
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end
                  item
                    Caption = '-'
                    Kind = bkText
                  end>
                Properties.MaxLength = 0
                Properties.ReadOnly = True
                Properties.OnButtonClick = EditSorumluOnaylayacakPropertiesButtonClick
                Style.LookAndFeel.NativeStyle = False
                StyleDisabled.LookAndFeel.NativeStyle = False
                StyleFocused.LookAndFeel.NativeStyle = False
                StyleHot.LookAndFeel.NativeStyle = False
                StyleReadOnly.LookAndFeel.NativeStyle = False
                TabOrder = 2
                Width = 205
              end
            end
            object cxGroupBox4: TcxGroupBox
              Left = 367
              Top = 84
              Caption = 'Kalite G'#252'vence Y'#246'neticisi'
              TabOrder = 6
              Height = 101
              Width = 346
              object cxLabel11: TcxLabel
                Left = 10
                Top = 50
                Caption = 'Onaylayan'
                Transparent = True
              end
              object EditOnaylayanKaliteci: TcxButtonEdit
                Left = 125
                Top = 46
                Hint = 'KALITECI'
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
                Properties.OnButtonClick = EditOnaylayanYoneticiPropertiesButtonClick
                TabOrder = 2
                Width = 201
              end
              object cxDBDateEdit5: TcxDBDateEdit
                Left = 127
                Top = 76
                DataBinding.DataField = 'KALITECI_ONAYLAYAN_TARIHI'
                DataBinding.DataSource = DtsSapmaOlay
                TabOrder = 3
                Width = 113
              end
              object cxLabel25: TcxLabel
                Left = 10
                Top = 22
                Caption = 'Onaylayacak'
                Transparent = True
              end
              object cxLabel27: TcxLabel
                Left = 10
                Top = 79
                Caption = 'Onay Tarihi'
                Transparent = True
              end
              object EditKaliteciOnaylayacak: TcxButtonEdit
                Left = 125
                Top = 19
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end
                  item
                    Caption = '-'
                    Kind = bkText
                  end>
                Properties.MaxLength = 0
                Properties.ReadOnly = True
                Properties.OnButtonClick = EditKaliteciOnaylayacakPropertiesButtonClick
                Style.LookAndFeel.NativeStyle = False
                StyleDisabled.LookAndFeel.NativeStyle = False
                StyleFocused.LookAndFeel.NativeStyle = False
                StyleHot.LookAndFeel.NativeStyle = False
                StyleReadOnly.LookAndFeel.NativeStyle = False
                TabOrder = 0
                Width = 205
              end
            end
          end
          object TabSheetDOF: TcxTabSheet
            Caption = 'A'#231#305'lan D'#214'F'
            ImageIndex = 1
            object Panel9: TPanel
              Left = 0
              Top = 0
              Width = 1121
              Height = 24
              Align = alTop
              Caption = 'Panel9'
              TabOrder = 0
              object ToolBar1: TToolBar
                Left = 1
                Top = 1
                Width = 206
                Height = 22
                Margins.Bottom = 0
                Align = alLeft
                AutoSize = True
                ButtonWidth = 66
                Caption = 'AletCubugu'
                Color = clTeal
                Ctl3D = False
                DockSite = True
                DrawingStyle = dsGradient
                EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                EdgeInner = esNone
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
                object IlgiliEkleTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  OnClick = IlgiliEkleTusClick
                end
                object IlgiliSilTus: TToolButton
                  Left = 66
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  OnClick = IlgiliSilTusClick
                end
                object ToolButton6: TToolButton
                  Left = 132
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton6'
                  ImageIndex = 2
                  Style = tbsSeparator
                end
                object IlgiliDuzenleTus: TToolButton
                  Left = 140
                  Top = 0
                  Caption = 'D'#252'zenle'
                  ImageIndex = 7
                  OnClick = IlgiliDuzenleTusClick
                end
              end
              object JvNavPanelHeader5: TJvNavPanelHeader
                Left = 207
                Top = 1
                Width = 913
                Height = 22
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
              end
            end
            object GridDOF: TcxGrid
              Left = 0
              Top = 24
              Width = 1121
              Height = 201
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object GridDOFView: TcxGridDBTableView
                OnDblClick = IlgiliDuzenleTusClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsDOF
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = 'Kay'#305't Say'#305's'#305': ######'
                    Kind = skCount
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.FocusCellOnTab = True
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.CancelOnExit = False
                OptionsData.Editing = False
                OptionsSelection.CellSelect = False
                OptionsSelection.MultiSelect = True
                OptionsView.GroupByBox = False
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.Indicator = True
                Preview.Visible = True
                object GridDOFViewDOFNO: TcxGridDBColumn
                  Caption = 'D'#214'F No'
                  DataBinding.FieldName = 'DOFNO'
                  DataBinding.IsNullValueType = True
                end
                object GridDOFViewTARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'EKLENMETARIHI'
                  DataBinding.IsNullValueType = True
                end
                object GridDOFViewKONU: TcxGridDBColumn
                  Caption = 'Konu'
                  DataBinding.FieldName = 'KONU'
                  DataBinding.IsNullValueType = True
                  Width = 327
                end
                object GridDOFViewKATEGORI: TcxGridDBColumn
                  Caption = 'Kategori'
                  DataBinding.FieldName = 'KATEGORI'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.RepKaliteDofKategori
                  Width = 158
                end
                object GridDOFViewBIRIM: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'DEPARTMANAD'
                  DataBinding.IsNullValueType = True
                  Width = 165
                end
                object GridDOFViewDURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.repAktiviteDurum
                end
              end
              object GridDOFLevel3: TcxGridLevel
                GridView = GridDOFView
              end
            end
          end
          object SheetYorum: TcxTabSheet
            Caption = 'Yorum/Medya'
            ImageIndex = 2
            object Panel4: TPanel
              Left = 0
              Top = 184
              Width = 1121
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
                Width = 973
              end
              object BtnMesajGonder: TcxButton
                Left = 974
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
                Left = 1059
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
              Top = 164
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
              AnchorX = 1121
            end
            object GridYorum: TcxGrid
              Left = 0
              Top = 0
              Width = 1121
              Height = 164
              Align = alClient
              TabOrder = 2
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
                  PropertiesClassName = 'TcxMemoProperties'
                  Properties.MaxLength = 0
                  Properties.ReadOnly = True
                  Properties.ScrollBars = ssVertical
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
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1127
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 67
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
        TabOrder = 2
        Transparent = True
        object YaziciYaz: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          Style = tbsTextButton
        end
        object ToolButton2: TToolButton
          Left = 67
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 17
          Style = tbsSeparator
        end
      end
    end
  end
  object TabSapmaOlay: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabSapmaOlayNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from KY_SAPMAOLAY'
      'Where ID=:ID')
    Left = 437
    Top = 14
  end
  object DtsSapmaOlay: TDataSource
    DataSet = TabSapmaOlay
    Left = 439
    Top = 62
  end
  object OpenDialog1: TOpenDialog
    Left = 652
    Top = 44
  end
  object TabDOF: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'Select KD.*,R1.FIRMA as KURUM, R2.FIRMA as SORUMLU,R3.FIRMA as A' +
        'CAN, '
      
        'PROJE=(SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=KD.PROJEID)' +
        ','
      
        'DEPARTMANAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 ' +
        'and DEGER=ROL.DEPARTMAN and DIL=-1)'
      'from KALITEDOF KD'
      ' left outer join REHBER R1 on KD.REHBERID=R1.ID'
      ' left outer join REHBER R2 on KD.DOFSORUMLU=R2.ID'
      ' left outer join REHBER R3 on KD.DOFACAN=R3.ID'
      ' left outer join ROLLER ROL on KD.DEPARTMAN=ROL.ID'
      'where '
      'YER=452'
      'and YER_ID=:Prm1'
      ' ORDER BY EKLENMETARIHI DESC')
    Left = 619
    Top = 397
  end
  object DtsDOF: TDataSource
    DataSet = TabDOF
    Left = 580
    Top = 427
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 519
    Top = 506
  end
  object TabIlgili: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        '  select DOKUMANILGILIID,D.AD,KLASOR = K.AD from DOKUMANILGILI I' +
        ' '
      '  inner join DOKUMAN D on D.ID = I.DOKUMANILGILIID'
      '  inner join DOKUMANKLASOR K on K.ID = D.KLASOR'
      '  '
      'where '
      'DOKUMANID = :pDID1'
      '--and'
      '--DOKUMANILGILIID = :pDID2')
    Left = 561
    Top = 382
    object TabIlgiliDOKUMANILGILIID: TIntegerField
      FieldName = 'DOKUMANILGILIID'
    end
    object TabIlgiliAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object TabIlgiliKLASOR: TWideStringField
      FieldName = 'KLASOR'
    end
  end
  object PopupDokuman: TPopupMenu
    Left = 219
    Top = 464
    object DokDizindenMenu: TMenuItem
      Caption = 'Dizinden'
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object DokListedenMenu: TMenuItem
      Caption = 'Dok'#252'man Listesinden'
    end
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    appearance.Gradient1Start = 15722724
    appearance.Gradient1End = 14599608
    appearance.Gradient2Start = 14203563
    appearance.Gradient2End = 15722724
    appearance.MarginX = 4
    appearance.MarginY = 2
    appearance.SeparatorLeading = 6
    appearance.GutterWidth = 26
    appearance.SeparatorBackgroundColor = 15656925
    appearance.SeparatorLineColor = 12961221
    appearance.GutterColor = 15658729
    appearance.ItemBackgroundColor = 16448250
    appearance.ItemSelectedColor = 15128011
    appearance.FontColor = 7214336
    appearance.FontDisabledColor = 14599640
    style = msDefault
    Left = 700
    Top = 388
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 708
    Top = 344
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object N4: TMenuItem
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
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
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
    Left = 640
    Top = 337
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 560
    Top = 316
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
    Left = 787
    Top = 368
  end
  object PopupMenuYaz: TPopupMenu
    Left = 133
    Top = 73
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
  object frxSAPMA_OLAY: TfrxDBDataset
    UserName = 'SAPMA_OLAY'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 374
    Top = 305
  end
  object SAPMAOLAY: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Select '
      '    R1.FIRMA as BASLATAN,'
      #9'R2.FIRMA as SORUMLU_ONAYLAYACAK,'
      #9'R3.FIRMA as SORUMLU_ONAYLAYAN,'
      #9'R4.FIRMA as KALITE_ONAYLAYACAK,'
      #9'R5.FIRMA as KALITE_ONAYLAYAN,'
      #9
      #9'P.PROJEKODU, '
      
        #9'KATEGORI = (select top 1 ANAHTAR from GENINI where BOLUM=-32100' +
        ' and DEGER=KYSO.KATEGORI and DIL=-1),'
      
        #9'DEPARTMAN = (select top 1 ANAHTAR from GENINI where BOLUM=-2251' +
        ' and DEGER=ROL.DEPARTMAN and DIL=-1),'
      
        #9'YORUM = cast(case when exists(select ID from GOREVYORUM where  ' +
        'TUR=452 AND GOREVID = KYSO.ID) then 1 else 0 end as bit),'
      
        #9'DOF = cast(case when exists(select ID from KALITEDOF where  YER' +
        '=452 AND YER_ID = KYSO.ID) then 1 else 0 end as bit),'
      #9'KYSO.* '
      'from '
      #9'KY_SAPMAOLAY KYSO'
      #9'left outer join REHBER R1 on KYSO.BASLATAN = R1.ID'
      #9'left outer join REHBER R2 on KYSO.SORUMLU_ONAYLAYACAK = R2.ID'
      #9'left outer join REHBER R3 on KYSO.SORUMLU_ONAYLAYAN = R3.ID'
      #9'left outer join REHBER R4 on KYSO.KALITECI_ONAYLAYACAK = R4.ID'
      #9'left outer join REHBER R5 on KYSO.KALITECI_ONAYLAYAN = R5.ID'
      #9'left outer join PROJELER P on KYSO.PROJEID = P.ID'
      #9'left outer join ROLLER ROL on KYSO.DEPARTMAN=ROL.ID'
      'Where KYSO.ID=:ID')
    Left = 531
    Top = 29
  end
  object frxDOF: TfrxDBDataset
    UserName = 'DOF'
    CloseDataSource = False
    DataSource = DtsDOF
    BCDToCurrency = False
    DataSetOptions = []
    Left = 374
    Top = 369
  end
  object frxYORUM: TfrxDBDataset
    UserName = 'YORUM'
    CloseDataSource = False
    DataSource = DtsYorum
    BCDToCurrency = False
    DataSetOptions = []
    Left = 374
    Top = 441
  end
end
