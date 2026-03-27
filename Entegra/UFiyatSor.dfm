object FiyatSorDlg: TFiyatSorDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Fiyat Bilgisi'
  ClientHeight = 553
  ClientWidth = 467
  Color = 12774133
  Font.Charset = DEFAULT_CHARSET
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
  object AltPanelStokAdi: TPanel
    Left = 0
    Top = 0
    Width = 467
    Height = 46
    Align = alTop
    BevelOuter = bvNone
    Caption = '---'
    Color = 12774133
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    ShowCaption = False
    TabOrder = 2
    object PanelStokAdi: TcxLabel
      Left = 0
      Top = 0
      Align = alClient
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -17
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 46
    Width = 467
    Height = 458
    Align = alClient
    TabOrder = 0
    TabStop = False
    Properties.ActivePage = SheetFiyatlandirma
    Properties.CustomButtons.Buttons = <>
    Properties.Style = 10
    Properties.TabSlants.Kind = skCutCorner
    OnPageChanging = cxPageControl1PageChanging
    ClientRectBottom = 458
    ClientRectRight = 467
    ClientRectTop = 19
    object SheetFiyatlandirma: TcxTabSheet
      Caption = '  Fiyatland'#305'rma  '
      ImageIndex = 0
      object PanelUst: TPanel
        Left = 0
        Top = 0
        Width = 467
        Height = 64
        Align = alTop
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 0
        TabStop = True
        object Bevel1: TBevel
          Left = 0
          Top = 0
          Width = 467
          Height = 64
          Align = alClient
          Shape = bsFrame
          Visible = False
          ExplicitTop = 24
          ExplicitWidth = 464
          ExplicitHeight = 69
        end
        object cxLabel8: TcxLabel
          Left = 41
          Top = 33
          Caption = 'P.Birimi'
          Properties.WordWrap = True
          Width = 38
        end
        object ComboKur: TcxComboBox
          Left = 86
          Top = 26
          TabStop = False
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          ParentColor = True
          ParentFont = False
          Properties.DropDownListStyle = lsEditFixedList
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.OnCloseUp = ComboKurPropertiesCloseUp
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -15
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextStyle = [fsBold]
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          TabOrder = 3
          Width = 60
        end
        object EditDovizBirimFiyat: TcxCurrencyEdit
          Left = 152
          Top = 27
          RepositoryItem = Tablo.RepCurrencyBF
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clMoneyGreen
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          OnKeyUp = EditDovizBirimFiyatKeyUp
          Height = 26
          Width = 152
        end
        object EditKurDegeri: TcxCurrencyEdit
          Left = 328
          Top = 32
          RepositoryItem = Tablo.RepCurrencyDovizKuru
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clSkyBlue
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          OnKeyUp = EditKurDegeriKeyUp
          Height = 26
          Width = 100
        end
        object CheckKur: TcxCheckBox
          Left = 300
          Top = 6
          TabStop = False
          Caption = 'Kur'
          State = cbsChecked
          TabOrder = 4
          OnClick = CheckKurClick
        end
        object CheckDovizBirimFiyat: TcxCheckBox
          Left = 170
          Top = 3
          TabStop = False
          Caption = 'D'#246'viz Birim Fiyat'
          State = cbsChecked
          TabOrder = 5
          OnClick = CheckDovizBirimFiyatClick
        end
      end
      object PanelAciklama: TPanel
        Left = 0
        Top = 304
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 6
        object Bevel5: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitTop = 5
          ExplicitWidth = 459
        end
        object cxLabel1: TcxLabel
          Left = 60
          Top = 15
          Caption = 'Personel'
          Properties.WordWrap = True
          Transparent = True
          Width = 45
        end
        object BeditPersonel: TcxButtonEdit
          Left = 152
          Top = 8
          TabStop = False
          ParentFont = False
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = BeditPersonelPropertiesButtonClick
          ShowHint = True
          Style.Color = clMoneyGreen
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.Shadow = False
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 269
        end
      end
      object PanelToplamTutar: TPanel
        Left = 0
        Top = 208
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 5
        object Bevel6: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitLeft = 7
          ExplicitTop = 11
          ExplicitWidth = 678
          ExplicitHeight = 48
        end
        object cxLabel6: TcxLabel
          Left = 60
          Top = 18
          Caption = 'Toplam Tutar'
          Transparent = True
        end
        object EditToplamTutar: TcxCurrencyEdit
          Left = 152
          Top = 13
          TabStop = False
          RepositoryItem = Tablo.RepCurrencyBF
          AutoSize = False
          EditValue = 0.000000000000000000
          Enabled = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = True
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clMoneyGreen
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 2
          OnKeyUp = EditBirimFiyatKeyUp
          Height = 26
          Width = 193
        end
        object CheckTutar: TcxCheckBox
          Left = 353
          Top = 16
          TabStop = False
          Caption = 'Aktif'
          TabOrder = 1
          Transparent = True
          OnClick = CheckTutarClick
        end
      end
      object PanelIskonto: TPanel
        Left = 0
        Top = 160
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 3
        TabStop = True
        object Bevel4: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitTop = -3
          ExplicitWidth = 459
        end
        object EditIsk2: TcxCurrencyEdit
          Left = 264
          Top = 12
          AutoSize = False
          EditValue = 0.000000000000000000
          Enabled = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0;-,0'
          Properties.EditFormat = ',0;-,0'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clScrollBar
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          OnKeyUp = EditIsk1KeyUp
          Height = 26
          Width = 81
        end
        object EditIsk1: TcxCurrencyEdit
          Left = 152
          Top = 12
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          ParentShowHint = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0;-,0'
          Properties.EditFormat = ',0;-,0'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          ShowHint = False
          Style.Color = clScrollBar
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          OnKeyUp = EditIsk1KeyUp
          Height = 26
          Width = 104
        end
        object cxLabel3: TcxLabel
          Left = 60
          Top = 17
          Caption = #304'skonto %'
          Properties.WordWrap = True
          Transparent = True
          Width = 54
        end
      end
      object PanelMiktar: TPanel
        Left = 0
        Top = 112
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 2
        TabStop = True
        object Bevel3: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitTop = -4
          ExplicitWidth = 678
          ExplicitHeight = 48
        end
        object LabelBirim: TcxLabel
          Left = 426
          Top = 12
          Caption = '--'
          Properties.WordWrap = True
          Transparent = True
          Width = 12
        end
        object ArtirTus: TcxButton
          Left = 371
          Top = 6
          Width = 40
          Height = 27
          Caption = '+'
          TabOrder = 2
          TabStop = False
          OnClick = ArtirTusClick
        end
        object AzaltTus: TcxButton
          Left = 328
          Top = 6
          Width = 42
          Height = 27
          Caption = '-'
          TabOrder = 3
          TabStop = False
          OnClick = AzaltTusClick
        end
        object EditMiktar: TcxCurrencyEdit
          Left = 152
          Top = 10
          RepositoryItem = Tablo.RepCurrencyAdetGenel
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0;-,0'
          Properties.EditFormat = ',0;-,0'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clSkyBlue
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          OnKeyUp = EditMiktarKeyUp
          Height = 26
          Width = 152
        end
        object cxLabel2: TcxLabel
          Left = 60
          Top = 15
          Caption = 'Miktar'
          Properties.WordWrap = True
          Transparent = True
          Width = 33
        end
      end
      object PanelBirimFiyat: TPanel
        Left = 0
        Top = 64
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 1
        TabStop = True
        object Bevel2: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitTop = -4
          ExplicitWidth = 678
          ExplicitHeight = 48
        end
        object CheckKDV: TcxCheckBox
          Left = 386
          Top = 15
          TabStop = False
          Caption = 'KDV Dahil'
          TabOrder = 2
          Transparent = True
        end
        object ComboKDV: TcxComboBox
          Left = 328
          Top = 8
          RepositoryItem = Tablo.repStokKDV
          ParentColor = True
          ParentFont = False
          Properties.DropDownListStyle = lsEditFixedList
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.OnCloseUp = ComboKDVPropertiesCloseUp
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -15
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextStyle = [fsBold]
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 50
        end
        object cxLabel16: TcxLabel
          Left = 306
          Top = 15
          Caption = '%'
          Properties.WordWrap = True
          Transparent = True
          Width = 15
        end
        object EditBirimFiyat: TcxCurrencyEdit
          Left = 152
          Top = 10
          RepositoryItem = Tablo.RepCurrencyBF
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clMoneyGreen
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          OnKeyUp = EditBirimFiyatKeyUp
          Height = 26
          Width = 153
        end
        object CheckBirimFiyat: TcxCheckBox
          Left = 60
          Top = 15
          TabStop = False
          Caption = 'Birim Fiyat'
          TabOrder = 4
          Transparent = True
          OnClick = CheckBirimFiyatClick
        end
      end
      object Panel8: TPanel
        Left = 0
        Top = 256
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 4
        TabStop = True
        object Bevel7: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitLeft = 16
          ExplicitTop = 304
          ExplicitWidth = 464
          ExplicitHeight = 48
        end
        object EditAciklama: TcxButtonEdit
          Left = 152
          Top = 11
          AutoSize = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.Buttons = <
            item
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = EditAciklamaPropertiesButtonClick
          Style.Color = clGradientActiveCaption
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          Height = 26
          Width = 269
        end
        object cxLabel5: TcxLabel
          Left = 60
          Top = 17
          Caption = 'A'#231#305'klama'
          Transparent = True
        end
      end
      object Panel6: TPanel
        Left = 0
        Top = 352
        Width = 467
        Height = 51
        Align = alTop
        TabOrder = 7
        object Bevel8: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 49
          Align = alClient
          Shape = bsFrame
          ExplicitTop = 5
          ExplicitWidth = 459
          ExplicitHeight = 55
        end
        object EditProje: TcxButtonEdit
          Left = 170
          Top = 7
          ParentFont = False
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
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditProjePropertiesButtonClick
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          TabOrder = 0
          Width = 251
        end
        object cxLabel7: TcxLabel
          Left = 88
          Top = 15
          Caption = 'Proje'
          Properties.WordWrap = True
          Transparent = True
          Width = 29
        end
        object LabelCoklu: TcxLabel
          Left = 10
          Top = 29
          Cursor = crHandPoint
          Caption = #199'oklu Proje/Masraf'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.TextColor = clNavy
          Style.TextStyle = [fsUnderline]
          Style.IsFontAssigned = True
          Transparent = True
          Visible = False
          OnClick = LabelCokluClick
        end
      end
      object PanelTeslimTarihi: TPanel
        Left = 0
        Top = 403
        Width = 467
        Height = 48
        Align = alTop
        TabOrder = 8
        object Bevel9: TBevel
          Left = 1
          Top = 1
          Width = 465
          Height = 46
          Align = alClient
          Shape = bsFrame
          ExplicitTop = 5
          ExplicitWidth = 459
        end
        object cxLabel12: TcxLabel
          Left = 88
          Top = 15
          Caption = 'Teslim Tarihi'
          Properties.WordWrap = True
          Transparent = True
          Width = 62
        end
        object EditTeslimTarihi: TcxDateEdit
          Left = 170
          Top = 8
          TabStop = False
          ParentFont = False
          ParentShowHint = False
          Properties.ReadOnly = False
          ShowHint = True
          Style.Color = clMoneyGreen
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.Shadow = False
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 251
        end
      end
    end
    object SheetDetay: TcxTabSheet
      Caption = '  Detay  '
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 0
        object cxLabel9: TcxLabel
          Left = 20
          Top = 16
          Caption = 'Vade'
          Properties.WordWrap = True
          Transparent = True
          Width = 28
        end
        object EditVade: TcxSpinEdit
          Left = 110
          Top = 10
          AutoSize = False
          ParentFont = False
          ParentShowHint = False
          Properties.Alignment.Horz = taRightJustify
          ShowHint = False
          Style.Color = clScrollBar
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          OnKeyUp = EditIsk1KeyUp
          Height = 26
          Width = 84
        end
        object cxLabel17: TcxLabel
          Left = 200
          Top = 16
          Caption = 'g'#252'n'
          Properties.WordWrap = True
          Width = 22
        end
        object CheckStoktan: TcxCheckBox
          Left = 288
          Top = 9
          Caption = 'Stoktan D'#252#351's'#252'n'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          TabOrder = 3
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 44
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 1
        object cxLabel10: TcxLabel
          Left = 20
          Top = 15
          Caption = 'Kampanya'
          Properties.WordWrap = True
          Transparent = True
          Width = 54
        end
        object EditKampanya: TcxButtonEdit
          Left = 110
          Top = 5
          ParentFont = False
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditKampanyaPropertiesButtonClick
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 339
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 132
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 2
        Visible = False
        object cxLabel11: TcxLabel
          Left = 20
          Top = 15
          Caption = 'Masraf Merkezi'
          Properties.WordWrap = True
          Transparent = True
          Width = 76
        end
        object EditMasrafMerkezi: TcxButtonEdit
          Left = 110
          Top = 6
          ParentFont = False
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditMasrafKalemiPropertiesButtonClick
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.Shadow = False
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 339
        end
      end
      object PanelTevkifat: TPanel
        Left = 0
        Top = 176
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 3
        object cxLabel13: TcxLabel
          Left = 20
          Top = 15
          Caption = 'Tevkifat Oran'#305
          Properties.WordWrap = True
          Transparent = True
          Width = 72
        end
        object ComboTevkifatOrani: TcxImageComboBox
          Left = 110
          Top = 10
          RepositoryItem = Tablo.RepTevkifatOrani
          ParentColor = True
          ParentFont = False
          Properties.Items = <>
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -15
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextStyle = [fsBold]
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 161
        end
      end
      object PanelOzelKod: TPanel
        Left = 0
        Top = 264
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 4
        object cxLabel14: TcxLabel
          Left = 20
          Top = 15
          Caption = #214'zel Kod'
          Properties.WordWrap = True
          Transparent = True
          Width = 46
        end
        object EditOzelKod: TcxTextEdit
          Left = 110
          Top = 8
          AutoSize = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Style.Color = clGradientActiveCaption
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          Height = 26
          Width = 339
        end
      end
      object Panel7: TPanel
        Left = 0
        Top = 88
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 5
        object cxLabel4: TcxLabel
          Left = 20
          Top = 13
          Caption = 'Masraf Kalemi'
          Properties.WordWrap = True
          Transparent = True
          Width = 70
        end
        object EditMasrafKalemi: TcxButtonEdit
          Left = 110
          Top = 5
          ParentFont = False
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditMasrafKlemiPropertiesButtonClick
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.Shadow = False
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 339
        end
      end
      object SqlMemoMasrafKalemi: TMemo
        Left = 22
        Top = 314
        Width = 436
        Height = 30
        Lines.Strings = (
          
            '  select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),' +
            'CHARINDEX'
          '('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39')'
          '    )-(CHARINDEX('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
          
            ' M.ID,  M.KOD, M.AD,PROJEID,MASRAFID,SUBEID=-1,DURUM=1, GELIRMI=' +
            '0, '
          'BARKOD=0'
          
            ' from PROJEBUTCE PB inner join MASRAFGELIR M on M.ID = PB.MASRAF' +
            'ID ')
        TabOrder = 6
        Visible = False
      end
      object PanelEkipman: TPanel
        Left = 0
        Top = 352
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 7
        object cxLabel15: TcxLabel
          Left = 20
          Top = 13
          Caption = 'Ekipman'
          Properties.WordWrap = True
          Transparent = True
          Width = 43
        end
        object EditEkipman: TcxButtonEdit
          Left = 110
          Top = 5
          ParentFont = False
          ParentShowHint = False
          Properties.Buttons = <
            item
              Caption = '++'
              Default = True
              Kind = bkText
            end
            item
              Caption = '+'
              Hint = 'Temizle'
              Kind = bkText
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditEkipmanPropertiesButtonClick
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.Shadow = False
          Style.IsFontAssigned = True
          TabOrder = 1
          Width = 339
        end
      end
      object PanelPozNo: TPanel
        Left = 0
        Top = 396
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 8
        object cxLabel18: TcxLabel
          Left = 20
          Top = 15
          Caption = 'Poz No'
          Style.LookAndFeel.NativeStyle = True
          StyleDisabled.LookAndFeel.NativeStyle = True
          StyleFocused.LookAndFeel.NativeStyle = True
          StyleHot.LookAndFeel.NativeStyle = True
          Properties.WordWrap = True
          Transparent = True
          Width = 37
        end
        object EditPozNo: TcxCurrencyEdit
          Left = 110
          Top = 8
          AutoSize = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = '0;-0'
          Style.Color = clGradientActiveCaption
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          Height = 26
          Width = 339
        end
      end
      object PanelResimGoster: TPanel
        Left = 0
        Top = 440
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 9
        Visible = False
        object cxLabel19: TcxLabel
          Left = 20
          Top = 13
          Caption = 'Resim'
          Properties.WordWrap = True
          Width = 32
        end
        object CheckResimGoster: TcxCheckBox
          Left = 109
          Top = 9
          Caption = ' G'#246'ster'
          Style.TextStyle = [fsBold]
          TabOrder = 1
        end
        object CheckMedyaEkle: TcxCheckBox
          Left = 269
          Top = 8
          Caption = 'Medya Ekle'
          Style.TextStyle = [fsBold]
          TabOrder = 2
        end
      end
      object PanelYuzey: TPanel
        Left = 0
        Top = 220
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 10
        object cxLabel20: TcxLabel
          Left = 20
          Top = 15
          Caption = 'Y'#252'zey'
          Properties.WordWrap = True
          Transparent = True
          Width = 33
        end
        object cxLabel21: TcxLabel
          Left = 176
          Top = 16
          Caption = 'mm'
          Properties.WordWrap = True
          Width = 20
        end
        object cxLabel22: TcxLabel
          Left = 269
          Top = 16
          Caption = 'mm'
          Properties.WordWrap = True
          Width = 20
        end
        object cxLabel23: TcxLabel
          Left = 357
          Top = 16
          Caption = 'm2'
          Properties.WordWrap = True
          Width = 18
        end
        object cxLabel24: TcxLabel
          Left = 383
          Top = 16
          Caption = '#'
          Properties.WordWrap = True
          Width = 12
        end
        object EditEN: TcxCurrencyEdit
          Left = 110
          Top = 10
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.AssignedValues.DisplayFormat = True
          Properties.AssignedValues.EditFormat = True
          Properties.ClearKey = 46
          Properties.DecimalPlaces = 0
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clWhite
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 5
          OnKeyUp = EditENKeyUp
          Height = 26
          Width = 65
        end
        object EditBOY: TcxCurrencyEdit
          Left = 202
          Top = 10
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DecimalPlaces = 0
          Properties.DisplayFormat = '0;-0'
          Properties.EditFormat = '0;-0'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clWhite
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 6
          OnKeyUp = EditENKeyUp
          Height = 26
          Width = 65
        end
        object EditYuzey: TcxCurrencyEdit
          Left = 290
          Top = 10
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = '0.00;-0.00'
          Properties.EditFormat = '0.00;-0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = True
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clSkyBlue
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 7
          Height = 26
          Width = 65
        end
        object EditSAYI: TcxCurrencyEdit
          Left = 397
          Top = 10
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DecimalPlaces = 0
          Properties.DisplayFormat = '0;-0'
          Properties.EditFormat = '0;-0'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = False
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = clWhite
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 8
          OnKeyUp = EditENKeyUp
          Height = 26
          Width = 52
        end
      end
      object Panel9: TPanel
        Left = 0
        Top = 308
        Width = 467
        Height = 44
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 12774133
        ParentBackground = False
        TabOrder = 11
        object cxLabel25: TcxLabel
          Left = 20
          Top = 15
          Caption = #214'zel Kod 2'
          Properties.WordWrap = True
          Transparent = True
          Width = 55
        end
        object EditOzelKod2: TcxTextEdit
          Left = 110
          Top = 8
          AutoSize = False
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Style.Color = clGradientActiveCaption
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -17
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clGreen
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 1
          Height = 26
          Width = 339
        end
      end
    end
    object SheetBilgi: TcxTabSheet
      Caption = '  '#220'r'#252'n Bilgisi  '
      ImageIndex = 2
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 467
        Height = 439
        Align = alClient
        TabOrder = 0
        LevelTabs.CaptionAlignment = taLeftJustify
        LevelTabs.Style = 10
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        RootLevelOptions.DetailTabsPosition = dtpTop
        OnActiveTabChanged = cxGrid1ActiveTabChanged
        object cxGrid1DBTableViewDurum: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsStokDurumDetay
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          Styles.Inactive = Tablo.cxstSecili
          object cxGrid1DBTableViewDurumTIP: TcxGridDBColumn
            Caption = 'Tip'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            Width = 106
          end
          object cxGrid1DBTableViewDurumADET: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 69
          end
          object cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
            Width = 63
          end
        end
        object cxGrid1DBCardViewAlislar: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonAlislar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsSelection.CardBorderSelection = False
          OptionsSelection.HideSelection = True
          OptionsSelection.InvertSelect = False
          OptionsView.CellEndEllipsis = True
          OptionsView.NavigatorOffset = 10
          OptionsView.CaptionSeparator = #0
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 1
          OptionsView.CardWidth = 300
          OptionsView.SeparatorWidth = 0
          object cxGrid1DBCardViewAlislarBASLIK: TcxGridDBCardViewRow
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
          object cxGrid1DBCardViewAlislarFATURATARIH: TcxGridDBCardViewRow
            Caption = 'Tarih'
            DataBinding.FieldName = 'FATURATARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarMIKTAR: TcxGridDBCardViewRow
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Filtering = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewAlislarBIRIMTUTAR: TcxGridDBCardViewRow
            Caption = 'Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarKUR: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewAlislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarDOVIZ_KURU: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
        end
        object cxGrid1DBCardViewSatislar: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonSatislar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsSelection.CardBorderSelection = False
          OptionsSelection.HideSelection = True
          OptionsSelection.InvertSelect = False
          OptionsView.CellEndEllipsis = True
          OptionsView.NavigatorOffset = 10
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 1
          OptionsView.CardWidth = 300
          OptionsView.SeparatorWidth = 0
          object cxGrid1DBCardViewSatislarBASLIK: TcxGridDBCardViewRow
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
          object cxGrid1DBCardViewSatislarFATURATARIH: TcxGridDBCardViewRow
            Caption = 'Tarih'
            DataBinding.FieldName = 'FATURATARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarMIKTAR: TcxGridDBCardViewRow
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Filtering = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewSatislarBIRIMTUTAR: TcxGridDBCardViewRow
            Caption = 'Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarKUR: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewSatislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarDOVIZ_KURU: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
        end
        object cxGrid1DBTableViewMaliyetler: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMaliyetler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object cxGrid1DBTableViewMaliyetlerTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            Width = 111
          end
          object cxGrid1DBTableViewMaliyetlerMALIYET: TcxGridDBColumn
            Caption = 'Maliyet'
            DataBinding.FieldName = 'MALIYET'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.0000;-,0.0000'
            Width = 95
          end
          object cxGrid1DBTableViewMaliyetlerKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 52
          end
        end
        object cxGrid1DBTableViewUretim: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableViewUretimKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 59
          end
          object cxGrid1DBTableViewUretimSTOKADI: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            Width = 166
          end
          object cxGrid1DBTableViewUretimMIKTAR: TcxGridDBColumn
            Caption = 'Gereken'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
          end
          object cxGrid1DBTableViewUretimKALAN: TcxGridDBColumn
            Caption = 'Kalan'
            DataBinding.FieldName = 'KALAN'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGrid1DBTableViewTeklif: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonTeklifler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableViewTeklifColumnBASLIK: TcxGridDBColumn
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 100
            Width = 100
          end
          object cxGrid1DBTableViewTeklifColumnTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 64
          end
          object cxGrid1DBTableViewTeklifColumnMIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
          object cxGrid1DBTableViewTeklifColumnBIRIMTUTAR: TcxGridDBColumn
            Caption = 'Birim Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            BestFitMaxWidth = 60
            Width = 60
          end
          object cxGrid1DBTableViewTeklifColumnKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
          object cxGrid1DBTableViewTeklifColumnBIRIMTUTARDOVIZ: TcxGridDBColumn
            Caption = 'Doviz Birim Tutar'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CurrencyItem1
            BestFitMaxWidth = 60
            Width = 60
          end
          object cxGrid1DBTableViewTeklifColumnDOVIZ_KURU: TcxGridDBColumn
            Caption = 'Doviz Kur'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
        end
        object cxGrid1LevelDepoDurumu: TcxGridLevel
          Caption = 'Depo Durumu'
          GridView = cxGrid1DBTableViewDurum
        end
        object cxGrid1LevelSonAlislar: TcxGridLevel
          Caption = 'Son Al'#305#351'lar'
          GridView = cxGrid1DBCardViewAlislar
        end
        object cxGrid1LevelSonSatislar: TcxGridLevel
          Caption = 'Son Sat'#305#351'lar'
          GridView = cxGrid1DBCardViewSatislar
        end
        object cxGrid1LevelMaliyetler: TcxGridLevel
          Caption = 'Maliyetler'
          GridView = cxGrid1DBTableViewMaliyetler
        end
        object cxGrid1LevelUretim: TcxGridLevel
          Caption = #220'retim'
          GridView = cxGrid1DBTableViewUretim
        end
        object cxGrid1LevelTeklif: TcxGridLevel
          Caption = 'Teklifler'
          GridView = cxGrid1DBTableViewTeklif
        end
      end
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 504
    Width = 467
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    Color = 12774133
    ParentBackground = False
    TabOrder = 1
    TabStop = True
    object EkleTus: TcxButton
      Left = 104
      Top = 6
      Width = 259
      Height = 38
      Caption = 'Tamam'
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      ModalResult = 1
      OptionsImage.ImageIndex = 10
      OptionsImage.Images = Tablo.PNGImageList1
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 0
    end
  end
  object TabSonTeklifler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      'select * from ('
      'select top 10 FB.TARIH,'
      'BASLIK=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,FB.ID'
      'from TEKLIF FB inner join TEKLIFDETAY F on FB.ID=F.TEKLIFID'
      'where'
      #9'F.TUR = @URUNTUR and'
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID'
      #9'and 1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1'
      #9#9#9'else 0 end'
      'order by FB.TARIH desc) as dd')
    Left = 372
    Top = 33
  end
  object DtsSonTeklifler: TDataSource
    DataSet = TabSonTeklifler
    Left = 404
    Top = 197
  end
  object TabUretim: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select S.KOD,S.STOKADI,URD.MIKTAR,KALAN=sum(SD.KALAN) '
      'from '
      #9'URETIMRECETE UR inner join '
      #9'URETIMRECETEDETAY URD on UR.ID=URD.URETIMRECETEID inner join '
      #9'STOKLAR S on S.ID=URD.URUNID inner join '
      #9'STOKDURUM SD on S.ID=SD.STOKID'
      'where URD.MIKTAR<0.0 and UR.STOKID=:PStokID '
      'group by S.KOD,S.STOKADI,URD.MIKTAR')
    Left = 316
    Top = 23
  end
  object DtsUretim: TDataSource
    DataSet = TabUretim
    Left = 268
    Top = 237
  end
  object tabMaliyetler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '--select * from STOKMALIYET where STOKID = PStokID'
      ''
      'Select distinct ID=STOKID,FIYATADI,'
      
        'TUR=(select top 1 case when DEGER=-2 then ANAHTAR +'#39' (Son'#39'+cast(' +
        'PAKETID as varchar(5))+'#39')'#39' '
      
        'else ANAHTAR end from GENINI where BOLUM=-1008 and DEGER=FIYATAD' +
        'I),'
      'MALIYET=FIYAT,KUR,KDVDURUM from STOKFIYAT Where STOKID=:PrmId '
      'and SATIS=0 and FIYATADI < 0 '
      ''
      '')
    Left = 199
    Top = 308
  end
  object DtsMaliyetler: TDataSource
    DataSet = tabMaliyetler
    Left = 215
    Top = 228
  end
  object TabStokDurumDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from fn_StokDurumDetay(:PStokID,:PDepoID)')
    Left = 265
    Top = 288
  end
  object DtsStokDurumDetay: TDataSource
    DataSet = TabStokDurumDetay
    Left = 289
    Top = 207
  end
  object TabSonSatislar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      ''
      'select * from ('
      'select top 10 FB.FATURATARIH,'
      'BASLIK=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,'
      'FB.TARIH,FB.TUR,FB.ID'
      'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID'
      'where '
      #9'FB.TUR = 15 and'
      #9'F.TUR = @URUNTUR and '
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID and '
      #9'1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1 '
      #9#9#9'else 0 end'
      'order by FB.FATURATARIH desc) as dd')
    Left = 40
    Top = 182
  end
  object DtsSonSatislar: TDataSource
    DataSet = TabSonSatislar
    Left = 143
    Top = 44
  end
  object TabSonAlislar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      'select * from ('
      'select top 10 FB.FATURATARIH,'
      'BASLIK=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,'
      'FB.TARIH,FB.TUR,FB.ID'
      'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID'
      'where'
      #9'FB.TUR = 11 and'
      #9'F.TUR = @URUNTUR and'
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID'
      #9'and 1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1'
      #9#9#9'else 0 end'
      'order by FB.FATURATARIH desc) as dd')
    Left = 224
    Top = 17
  end
  object DtsSonAlislar: TDataSource
    DataSet = TabSonAlislar
    Left = 16
  end
end
