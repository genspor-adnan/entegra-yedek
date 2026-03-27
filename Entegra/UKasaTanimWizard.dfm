object KasaTanimWizardDlg: TKasaTanimWizardDlg
  Left = 0
  Top = 0
  ActiveControl = ComboSube
  Caption = 'Kasa Tan'#305'mlama Sihirbaz'#305
  ClientHeight = 447
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 673
    Height = 447
    ActivePage = GirisEkr
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
    ButtonFinish.Caption = '&Son'
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
      673
      447)
    object GirisEkr: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Kart olu'#351'turma ve d'#252'zenleme'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #304'stedi'#287'iniz ekranda kaydet tu'#351'uyla '#231#305'kabilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkFinish, bkCancel]
      Color = 11776947
      object Label2: TcxLabel
        Left = 165
        Top = 128
        Caption = 'Kasa Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label3: TcxLabel
        Left = 165
        Top = 155
        Caption = 'Kasa Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label4: TcxLabel
        Left = 165
        Top = 183
        Caption = 'Para Birimi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label6: TcxLabel
        Left = 165
        Top = 209
        Caption = 'A'#231#305'klama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 450
        Top = 128
        Caption = 'Durum'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label8: TcxLabel
        Left = 165
        Top = 236
        Caption = #214'zel Kod'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label9: TcxLabel
        Left = 165
        Top = 263
        Caption = 'Yetki Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label13: TcxLabel
        Left = 165
        Top = 102
        Caption = 'ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object DBText1: TcxDBLabel
        Left = 258
        Top = 102
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsKasalar
        Transparent = True
        Height = 17
        Width = 65
      end
      object EditKASAKODU: TcxDBTextEdit
        Left = 258
        Top = 127
        DataBinding.DataField = 'KASAKODU'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 4
        Width = 121
      end
      object EditKASAADI: TcxDBTextEdit
        Left = 258
        Top = 154
        DataBinding.DataField = 'KASAADI'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 8
        Width = 225
      end
      object ComboKUR: TcxDBComboBox
        Left = 258
        Top = 181
        DataBinding.DataField = 'KUR'
        DataBinding.DataSource = DtsKasalar
        Properties.DropDownListStyle = lsFixedList
        Properties.MaxLength = 0
        TabOrder = 10
        Width = 122
      end
      object EditHESAPACIKLAMA: TcxDBTextEdit
        Left = 258
        Top = 208
        DataBinding.DataField = 'HESAPACIKLAMA'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 12
        Width = 225
      end
      object EditOZELKOD: TcxDBTextEdit
        Left = 258
        Top = 235
        DataBinding.DataField = 'OZELKOD'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 14
        Width = 121
      end
      object EditYETKIKODU: TcxDBTextEdit
        Left = 258
        Top = 262
        DataBinding.DataField = 'YETKIKODU'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 16
        Width = 121
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 517
        Top = 126
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsKasalar
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = True
          end
          item
            Description = 'Pasif'
            Value = False
          end>
        TabOrder = 5
        Width = 151
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 258
        Top = 352
        Caption = 'G'#252'nl'#252'k Aksiyonlarda G'#246'ster'
        DataBinding.DataField = 'GUNLUKAKSIYONDAGOSTER'
        DataBinding.DataSource = DtsKasalar
        TabOrder = 22
      end
      object cxLabel1: TcxLabel
        Left = 165
        Top = 291
        Caption = 'Kasa T'#252'r'#252
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboKasaTuru: TcxDBImageComboBox
        Left = 257
        Top = 288
        DataBinding.DataField = 'KASATUR'
        DataBinding.DataSource = DtsKasalar
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Merkez Kasa'
            ImageIndex = 0
            Value = 100
          end
          item
            Description = 'Sat'#305#351' Kasas'#305
            Value = 101
          end
          item
            Description = #304#351' Avans'#305' Kasas'#305
            Value = 195
          end
          item
            Description = 'Maa'#351' Avans'#305' Kasas'#305
            Value = 196
          end
          item
            Description = 'Kupon Kasas'#305
            Value = 200
          end>
        Properties.OnChange = ComboKasaTuruPropertiesChange
        TabOrder = 17
        Width = 121
      end
      object EditBakiye: TcxDBCurrencyEdit
        Left = 258
        Top = 315
        DataBinding.DataField = 'BAKIYE'
        DataBinding.DataSource = DtsKasalar
        Enabled = False
        TabOrder = 18
        Width = 121
      end
      object cxLabel2: TcxLabel
        Left = 165
        Top = 316
        Caption = 'Bakiye'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LblSube: TcxLabel
        Left = 450
        Top = 102
        Caption = #350'ube'
      end
      object ComboSube: TcxDBImageComboBox
        Left = 517
        Top = 100
        RepositoryItem = Tablo.RepSubeler
        DataBinding.DataField = 'SUBEID'
        DataBinding.DataSource = DtsKasalar
        Properties.Alignment.Horz = taLeftJustify
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnCloseUp = ComboSubePropertiesCloseUp
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clBlack
        TabOrder = 0
        OnKeyUp = ComboSubeKeyUp
        Width = 151
      end
      object ComboPersonel: TcxButtonEdit
        Left = 517
        Top = 290
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
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = ComboPersonelPropertiesButtonClick
        Style.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        TabOrder = 23
        Visible = False
        Width = 154
      end
      object LabelPersonel: TcxLabel
        Left = 450
        Top = 291
        Caption = 'Personel'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
      end
      object LabelREHBERID: TcxDBLabel
        Left = 450
        Top = 316
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsKasalar
        Transparent = True
        Visible = False
        Height = 17
        Width = 49
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 17
    Top = 159
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      OnClick = AcilisKaydiMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object KasaYenileMenu: TMenuItem
      Caption = 'Sadece Bu Kasan'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object BtnKasalarnToplamlarnYenile1: TMenuItem
      Caption = 'B'#252't'#252'n Kasalar'#305'n Toplamlar'#305'n'#305' Yenile'
    end
  end
  object frxKasalar: TfrxDBDataset
    UserName = 'KASALAR'
    CloseDataSource = False
    BCDToCurrency = False
    Left = 12
    Top = 98
  end
  object DtsKasalar: TDataSource
    DataSet = TabKasalar
    Left = 28
    Top = 49
  end
  object TabKasalar: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = TabKasalarBeforeEdit
    BeforePost = TabKasalarBeforePost
    AfterPost = TabKasalarAfterPost
    OnNewRecord = TabKasalarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from KASALAR where ID=:PID')
    Left = 83
    Top = 42
  end
end

