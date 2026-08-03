object RehberWizardDlg: TRehberWizardDlg
  Left = 0
  Top = 0
  ActiveControl = ComboGRUP
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Cari Kart Sihirbaz'#305
  ClientHeight = 574
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 18
  object WizardKontrol: TJvWizard
    Left = 105
    Top = 0
    Width = 755
    Height = 574
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
    OnNextButtonClick = WizardKontrolNextButtonClick
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      755
      574)
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
      Header.Subtitle.Text = #304'stedi'#287'iniz ekranda "Son" tu'#351'una basarak kaydedip '#231#305'kabilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      Color = 11776947
      OnPage = GirisEkrPage
      OnNextButtonClick = GirisEkrNextButtonClick
      WaterMark.Visible = False
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel1: TPanel
        Left = 0
        Top = 70
        Width = 755
        Height = 291
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object EditKOD: TcxDBTextEdit
          Left = 103
          Top = 60
          TabStop = False
          DataBinding.DataField = 'KOD'
          DataBinding.DataSource = DtsRehber
          Enabled = False
          StyleDisabled.BorderColor = clWindowFrame
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 1
          OnEditing = EditKODEditing
          Width = 165
        end
        object LabelKod: TcxLabel
          Left = 25
          Top = 63
          Caption = 'Kod'
          Transparent = True
        end
        object KodAgaciTus: TcxButton
          Left = 269
          Top = 61
          Width = 25
          Height = 24
          OptionsImage.Glyph.SourceDPI = 96
          OptionsImage.Glyph.Data = {
            424DC60700000000000036000000280000001600000016000000010020000000
            000000000000C40E0000C40E00000000000000000000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
            00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
            00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
            00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000000000FF000000FF000000FF000000FFC0C0C000000000FFC0C0C0000000
            00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
            C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
            C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
            00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
            00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000000000FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
            00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
            C000C0C0C000}
          TabOrder = 18
          OnClick = KodAgaciTusClick
        end
        object EditFIRMA: TcxDBTextEdit
          Left = 103
          Top = 87
          DataBinding.DataField = 'FIRMA'
          DataBinding.DataSource = DtsRehber
          TabOrder = 2
          Width = 352
        end
        object LblUnvan: TcxLabel
          Left = 25
          Top = 88
          Caption = #220'nvan'
          Transparent = True
        end
        object ComboGRUP: TcxDBImageComboBox
          Left = 103
          Top = 33
          HelpType = htKeyword
          HelpKeyword = 'REHBER.GRUP'
          DataBinding.DataField = 'GRUP'
          DataBinding.DataSource = DtsRehber
          Properties.Alignment.Horz = taLeftJustify
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnChange = ComboGRUPPropertiesChange
          TabOrder = 0
          Width = 165
        end
        object LabelGrup: TcxLabel
          Left = 25
          Top = 35
          Cursor = crHandPoint
          Hint = 'CariKart_Grup'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.GRUP'
          Caption = 'Grup'
          FocusControl = ComboGRUP
          Transparent = True
        end
        object LabelKategori: TcxLabel
          Left = 25
          Top = 169
          Cursor = crHandPoint
          Hint = 'CariKart_Kategori'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.KATEGORI'
          Caption = 'Kategori'
          FocusControl = EditKATEGORI
          Transparent = True
          OnClick = LabelKategoriClick
        end
        object EditKATEGORI: TcxButtonEdit
          Tag = -2208
          Left = 103
          Top = 168
          Hint = 'KATEGORI'
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
          Properties.ClearKey = 46
          Properties.MaxLength = 0
          Properties.OnButtonClick = ComboKATEGORIPropertiesButtonClick
          ShowHint = True
          TabOrder = 6
          Width = 165
        end
        object ComboSINIF: TcxDBImageComboBox
          Left = 103
          Top = 195
          DataBinding.DataField = 'SINIF'
          DataBinding.DataSource = DtsRehber
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 7
          Width = 165
        end
        object LabelSinif: TcxLabel
          Left = 25
          Top = 198
          Cursor = crHandPoint
          Hint = 'CariKart_S'#305'n'#305'f'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.SINIF'
          Caption = 'S'#305'n'#305'f'
          FocusControl = ComboSINIF
          Transparent = True
        end
        object cxDBLabel1: TcxDBLabel
          Left = 412
          Top = 63
          DataBinding.DataField = 'KATEGORI'
          DataBinding.DataSource = DtsRehber
          Transparent = True
          Visible = False
          Height = 21
          Width = 33
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 610
          Top = 141
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsRehber
          Properties.ImageAlign = iaRight
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 13
          Width = 140
        end
        object Label34: TcxLabel
          Left = 512
          Top = 143
          Cursor = crHandPoint
          Hint = 'CariKart_Durum'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.DURUM'
          Caption = 'Durum'
          FocusControl = ComboDURUM
          Transparent = True
        end
        object cxDBLabel2: TcxDBLabel
          Left = 103
          Top = 6
          DataBinding.DataField = 'ID'
          DataBinding.DataSource = DtsRehber
          Transparent = True
          OnClick = cxDBLabel2Click
          Height = 21
          Width = 37
        end
        object EditTEMSILCI: TcxButtonEdit
          Left = 103
          Top = 249
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
          Properties.ClearKey = 46
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditMUSTEMSILCIPropertiesButtonClick
          ShowHint = True
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 10
          OnKeyDown = EditTEMSILCIKeyDown
          Width = 168
        end
        object LabelSorumlu: TcxLabel
          Left = 24
          Top = 253
          Cursor = crHandPoint
          Caption = 'Temsilci'
          FocusControl = EditTEMSILCI
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
          OnClick = LabelSorumluClick
        end
        object ComboSube: TcxDBImageComboBox
          Left = 610
          Top = 112
          DataBinding.DataField = 'SUBEID'
          DataBinding.DataSource = DtsRehber
          Properties.ImmediatePost = True
          Properties.Items = <
            item
            end>
          Properties.OnCloseUp = ComboSubePropertiesCloseUp
          TabOrder = 12
          OnKeyUp = ComboSubeKeyUp
          Width = 140
        end
        object LblSube: TcxLabel
          Left = 512
          Top = 115
          Caption = #350'ube'
          Transparent = True
        end
        object LabelBolge: TcxLabel
          Left = 25
          Top = 227
          Cursor = crHandPoint
          Hint = 'CariKart_Bolge'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.BOLGE'
          Caption = 'B'#246'lge'
          FocusControl = ComboBolge
          Transparent = True
        end
        object ComboBolge: TcxDBImageComboBox
          Left = 103
          Top = 222
          DataBinding.DataField = 'BOLGE'
          DataBinding.DataSource = DtsRehber
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          Properties.OnEditValueChanged = ComboBolgePropertiesEditValueChanged
          TabOrder = 8
          Width = 165
        end
        object DBCheckBox1: TDBCheckBox
          Left = 276
          Top = 201
          Width = 16
          Height = 17
          DataField = 'R'
          DataSource = DtsRehber
          TabOrder = 29
        end
        object CheckPersonel: TcxCheckBox
          Left = 274
          Top = 33
          Caption = 'Personel'
          TabOrder = 30
          Transparent = True
          OnClick = CheckPersonelClick
        end
        object ComboAltBolge: TcxDBImageComboBox
          Left = 333
          Top = 223
          DataBinding.DataField = 'ALTBOLGE'
          DataBinding.DataSource = DtsRehber
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 9
          Width = 148
        end
        object LabelAltBolge: TcxLabel
          Left = 274
          Top = 227
          Cursor = crHandPoint
          Hint = 'CariKart_Bolge'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.BOLGE'
          Caption = 'Alt B'#246'lge'
          FocusControl = ComboAltBolge
          Transparent = True
          OnClick = LabelAltBolgeClick
        end
        object LabelSektor: TcxLabel
          Left = 26
          Top = 144
          Cursor = crHandPoint
          Hint = 'CariKart_Sektor'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.SEKTOR'
          Caption = 'Sekt'#246'r'
          FocusControl = EditSektor
          Transparent = True
          OnClick = LabelSektorClick
        end
        object EditSektor: TcxButtonEdit
          Tag = -2204
          Left = 103
          Top = 141
          Hint = 'SEKTOR'
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
          Properties.ClearKey = 46
          Properties.MaxLength = 0
          Properties.OnButtonClick = ComboKATEGORIPropertiesButtonClick
          Properties.OnEditValueChanged = EditSektorPropertiesEditValueChanged
          ShowHint = True
          TabOrder = 4
          Width = 165
        end
        object cxLabel2: TcxLabel
          Left = 512
          Top = 197
          Cursor = crHandPoint
          HelpType = htKeyword
          Caption = 'Ziyaret Frekans'#305
          Transparent = True
        end
        object EditPERYOT: TcxDBSpinEdit
          Left = 610
          Top = 193
          DataBinding.DataField = 'PERYOT'
          DataBinding.DataSource = DtsRehber
          Properties.MaxValue = 60.000000000000000000
          TabOrder = 14
          Width = 51
        end
        object cxLabel5: TcxLabel
          Left = 757
          Top = 231
          Caption = 'ay'
          Properties.WordWrap = True
          Transparent = True
          Width = 16
        end
        object EditAltSektor: TcxButtonEdit
          Tag = -2204
          Left = 333
          Top = 141
          Hint = 'ALTSEKTOR'
          Enabled = False
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
          Properties.ClearKey = 46
          Properties.MaxLength = 0
          Properties.OnButtonClick = ComboKATEGORIPropertiesButtonClick
          ShowHint = True
          TabOrder = 5
          Width = 148
        end
        object LabelAltSektor: TcxLabel
          Left = 274
          Top = 145
          Cursor = crHandPoint
          Hint = 'CariKart_Sektor'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.SEKTOR'
          Caption = 'Alt Sekt'#246'r'
          Enabled = False
          FocusControl = EditAltSektor
          ParentColor = False
          Style.BorderColor = clBlack
          Style.Color = clBlack
          Style.TextColor = clBlack
          StyleDisabled.TextColor = clBlack
          Transparent = True
          OnClick = LabelAltSektorClick
        end
        object EditOzelKod: TcxDBTextEdit
          Left = 334
          Top = 251
          DataBinding.DataField = 'OZELKOD'
          DataBinding.DataSource = DtsRehber
          TabOrder = 11
          Width = 148
        end
        object Label3: TcxLabel
          Left = 275
          Top = 254
          Caption = #214'zel Kod'
          Properties.WordWrap = True
          Transparent = True
          Width = 53
        end
        object cxLabel4: TcxLabel
          Left = 512
          Top = 251
          Caption = 'Muhasebe Kodu'
          Properties.WordWrap = True
          Transparent = True
          Width = 92
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 610
          Top = 249
          DataBinding.DataField = 'MUHKODU'
          DataBinding.DataSource = DtsRehber
          TabOrder = 16
          Width = 140
        end
        object cxLabel3: TcxLabel
          Left = 667
          Top = 197
          Cursor = crHandPoint
          HelpType = htKeyword
          Caption = 'ay'
          Transparent = True
        end
        object LabelID: TcxLabel
          Left = 26
          Top = 7
          Cursor = crHandPoint
          Hint = 'CariKart_Grup'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.GRUP'
          Caption = 'ID'
          FocusControl = ComboGRUP
          Transparent = True
        end
        object LogoResim: TcxDBImage
          Left = 614
          Top = 9
          DataBinding.DataField = 'RESIM'
          DataBinding.DataSource = DtsRehber
          Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
          Properties.FitMode = ifmProportionalStretch
          Properties.GraphicClassName = 'TdxSmartImage'
          TabOrder = 40
          OnClick = LogoResimClick
          Height = 97
          Width = 128
        end
        object EditTEMAS: TcxButtonEdit
          Tag = -2207
          Left = 104
          Top = 114
          Hint = 'TEMAS'
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
          Properties.ClearKey = 46
          Properties.MaxLength = 0
          Properties.OnButtonClick = ComboKATEGORIPropertiesButtonClick
          ShowHint = True
          TabOrder = 3
          Width = 164
        end
        object LabelTemas: TcxLabel
          Left = 26
          Top = 116
          Cursor = crHandPoint
          Hint = 'CariKart_Kategori'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.TEMAS'
          Caption = #304'lk Temas'
          FocusControl = EditTEMAS
          Transparent = True
          OnClick = LabelTemasClick
        end
        object cxDBCheckBox3: TcxDBCheckBox
          Left = 512
          Top = 272
          Caption = 'E-Fatura'
          DataBinding.DataField = 'EFATURA'
          DataBinding.DataSource = DtsRehber
          Properties.Alignment = taRightJustify
          Properties.ImmediatePost = True
          Properties.ReadOnly = True
          TabOrder = 42
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 512
          Top = 225
          Caption = 'Google Konum'
          Properties.WordWrap = True
          Transparent = True
          Width = 83
        end
        object cxDBTextEdit2: TcxDBTextEdit
          Left = 610
          Top = 221
          DataBinding.DataField = 'KONUM'
          DataBinding.DataSource = DtsRehber
          TabOrder = 15
          Width = 140
        end
      end
      object CariPageControl: TcxPageControl
        Left = 0
        Top = 361
        Width = 755
        Height = 171
        Cursor = crHandPoint
        Align = alClient
        TabOrder = 1
        Properties.ActivePage = SheetNotlar
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 167
        ClientRectLeft = 4
        ClientRectRight = 751
        ClientRectTop = 29
        object SheetNotlar: TcxTabSheet
          Caption = 'Not / Uyar'#305
          ImageIndex = 0
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CariGridNotlar: TcxGrid
            Left = 0
            Top = 27
            Width = 747
            Height = 111
            Align = alClient
            TabOrder = 0
            object CariGridNotlarView: TcxGridDBCardView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsNotlar
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              LayoutDirection = ldVertical
              OptionsSelection.CellSelect = False
              OptionsView.ScrollBars = ssVertical
              OptionsView.CardBorderWidth = 1
              OptionsView.CardIndent = 2
              OptionsView.CardWidth = 760
              OptionsView.CategoryIndent = 1
              OptionsView.CategorySeparatorWidth = 1
              OptionsView.CellAutoHeight = True
              OptionsView.CellTextMaxLineCount = 5
              RowLayout = rlVertical
              object CariGridNotlarViewBILGI: TcxGridDBCardViewRow
                DataBinding.FieldName = 'BILGI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
              end
              object CariGridNotlarViewYORUM: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YORUM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxMemoProperties'
                Properties.MaxLength = 0
                Properties.ReadOnly = True
                Properties.ScrollBars = ssVertical
                Options.Editing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
              end
            end
            object CariGridNotlarLevel1: TcxGridLevel
              GridView = CariGridNotlarView
            end
          end
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 741
            Height = 24
            Margins.Bottom = 0
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
            List = True
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object YorumEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = ' Ekle'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsTextButton
              OnClick = YorumEkleTusClick
            end
            object YorumSil: TToolButton
              Left = 51
              Top = 0
              Caption = 'Sil'
              ImageIndex = 5
              ImageName = 'PngImage5'
              Style = tbsTextButton
              OnClick = YorumSilClick
            end
            object YorumDuzenle: TToolButton
              Tag = 3
              Left = 102
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsTextButton
              OnClick = YorumDuzenleClick
            end
          end
        end
        object SheetEkAlanlar: TcxTabSheet
          Caption = 'Ek Alanlar'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PanelEkAlanlar: TPanel
            Left = 0
            Top = 0
            Width = 747
            Height = 138
            Align = alClient
            BevelOuter = bvNone
            Color = clSilver
            ParentBackground = False
            TabOrder = 0
          end
        end
      end
    end
    object IletisimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #304'leti'#351'im bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'IletisimEkr'
      Enabled = False
      OnEnterPage = IletisimEkrEnterPage
      OnPage = IletisimEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 749
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 63
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
        object YeniAdresTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = YeniAdresTusClick
        end
        object AdresSilTus: TToolButton
          Left = 63
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = AdresSilTusClick
        end
        object ToolButton2: TToolButton
          Left = 126
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object AdresDegistir: TToolButton
          Left = 134
          Top = 0
          Caption = 'De'#287'i'#351'tir'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = AdresDegistirClick
        end
      end
      object GridKurIlet: TcxGrid
        Left = 167
        Top = 97
        Width = 588
        Height = 435
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridKurIletView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridKurIletViewCellClick
          OnEditChanged = GridKurIletViewEditChanged
          OnEditValueChanged = GridKurIletViewEditValueChanged
          OnFocusedItemChanged = GridKurIletViewFocusedItemChanged
          OnInitEdit = GridKurIletViewInitEdit
          OnSelectionChanged = GridKurIletViewSelectionChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsKurIlet
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Etiketi'
            DataBinding.FieldName = 'ETIKET'
            DataBinding.IsNullValueType = True
            MinWidth = 150
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 150
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
            MinWidth = 400
            Options.Filtering = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 400
          end
          object GridKurIletViewColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            DataBinding.IsNullValueType = True
            Visible = False
            MinWidth = 64
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
          end
          object GridKurIletViewColumnsec: TcxGridDBColumn
            Caption = 'Zorunlu'
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Visible = False
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = GridKurIletView
        end
      end
      object SQLKurIlet: TcxMemo
        Left = 220
        Top = 183
        Lines.Strings = (
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
          'name LIKE '
          #39'#KURILET_:SPID_%'#39')'
          'DROP TABLE #KURILET_:SPID_'
          ''
          'CREATE TABLE #KURILET_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](100) NULL,'
          #9'[BILGI] [nvarchar](1000) NULL,'
          #9'[ORJINAL] [nvarchar](1000) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #KURILET_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB LEFT OUTER JOIN REHBERAYAR RA ON '
          'RB.ETIKET=RA.ETIKET AND RB.YERI=RA.YERI'
          'where RB.YERI= :Yeri  and YER_ID= :Yeri_Id1   '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
            '  '
          ' from REHBERAYAR  where  YERI=1  '
          'and ETIKET not in (select ETIKET from REHBERBILGI '
          'where  YERI=1 and YER_ID= :Yeri_Id2)'
          'order by 1'
          ''
          'select * from #KURILET_:SPID_'
          'order by SIRA')
        TabOrder = 3
        Visible = False
        Height = 100
        Width = 387
      end
      object cxGrid1: TcxGrid
        Left = 0
        Top = 97
        Width = 167
        Height = 435
        Align = alLeft
        PopupMenu = PopupIletisim
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridAdresAdView: TcxGridDBTableView
          OnDblClick = AdresDegistirClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnSelectionChanged = GridAdresAdViewSelectionChanged
          DataController.DataSource = DtsRehberIlet
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.GroupByBox = False
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'Ad'#305' '
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 131
          end
          object cxGridDBColumn11: TcxGridDBColumn
            DataBinding.FieldName = 'AKTIF'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Kurumda'
                Value = '1'
              end
              item
                Description = 'Ta'#351#305'nd'#305
                ImageIndex = 12
                Value = '2'
              end
              item
                Description = 'Ayr'#305'ld'#305
                ImageIndex = 10
                Value = '3'
              end>
            Properties.ShowDescriptions = False
            Width = 31
            IsCaptionAssigned = True
          end
          object cxGridDBColumn12: TcxGridDBColumn
            Caption = 'Var.'
            DataBinding.FieldName = 'VARSAYILAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ReadOnly = True
            Visible = False
            Options.Editing = False
            Width = 30
          end
        end
        object cxGridLevel7: TcxGridLevel
          GridView = GridAdresAdView
        end
      end
    end
    object TicariEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Ticari Bilgiler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Alta yeni '#246'zellik ekleyebilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Enabled = False
      OnEnterPage = TicariEkrEnterPage
      OnPage = TicariEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar4: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 749
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 48
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
        object ToolButton5: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
        end
        object ToolButton6: TToolButton
          Left = 48
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = ToolButton6Click
        end
      end
      object GridTicari: TcxGrid
        Left = 0
        Top = 97
        Width = 755
        Height = 435
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridTicariView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridKurIletViewCellClick
          OnEditChanged = GridTicariViewEditChanged
          DataController.DataSource = DtsTicari
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'Etiketi'
            DataBinding.FieldName = 'ETIKET'
            DataBinding.IsNullValueType = True
            MinWidth = 150
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 150
          end
          object cxGridDBColumn6: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
            MinWidth = 400
            Options.Filtering = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 400
          end
          object GridTicariViewColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridTicariViewColumn2: TcxGridDBColumn
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = GridTicariView
        end
      end
      object SQLTicari: TcxMemo
        Left = 143
        Top = 137
        Lines.Strings = (
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects '
          'WHERE '
          'name LIKE '
          #39'#TICARI_:SPID_%'#39')'
          'DROP TABLE #TICARI_:SPID_'
          ''
          'CREATE TABLE #TICARI_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](100) NULL,'
          #9'[BILGI] [nvarchar](1000) NULL,'
          #9'[ORJINAL] [nvarchar](1000) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL,'
          '                [VARSAYILAN] [int] NULL'
          ')'
          'INSERT INTO #TICARI_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,'
          'RA.GIRIS,RA.KAYNAK,RA.ZORUNLU ,RA.VARSAYILAN'
          'from REHBERBILGI RB LEFT OUTER JOIN REHBERAYAR '
          'RA ON '
          'RB.ETIKET=RA.ETIKET AND RB.YERI=RA.YERI'
          'where RB.YERI= :Yeri  and YER_ID= :Yeri_Id1   '
          ''
          'union all'
          ''
          'select  SIRA, ETIKET, '
          'BILGI='#39#39', ORJINAL='#39#39' '
          ',GIRIS,KAYNAK,ZORUNLU,VARSAYILAN from'
          'REHBERAYAR  where  YERI=2  '
          'and ETIKET not in (select ETIKET from REHBERBILGI '
          'where  YERI=2  and YER_ID= :Yeri_Id2)'
          'order by 1'
          ''
          'select * from #TICARI_:SPID_'
          'order by SIRA')
        TabOrder = 2
        Visible = False
        Height = 112
        Width = 303
      end
    end
    object PersonelIletisimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Ki'#351'i Bilgi Formu'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Enabled = False
      OnEnterPage = PersonelIletisimEkrEnterPage
      OnPage = PersonelIletisimEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 749
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 98
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
        object YeniPerTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni '#304'lgili'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = YeniPerTusClick
        end
        object SilPerTus: TToolButton
          Left = 98
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilPerTusClick
        end
        object ToolButton8: TToolButton
          Left = 196
          Top = 0
          Width = 8
          Caption = 'ToolButton8'
          ImageIndex = 8
          ImageName = 'PngImage15'
          Style = tbsSeparator
        end
        object DegisPerTus: TToolButton
          Left = 204
          Top = 0
          Caption = 'De'#287'i'#351'tir'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = DegisPerTusClick
        end
        object VarsayPerTus: TToolButton
          Left = 302
          Top = 0
          Caption = 'Varsaylan Yap'
          ImageIndex = 6
          ImageName = 'PngImage6'
          OnClick = VarsayPerTusClick
        end
      end
      object GridIlet: TcxGrid
        Left = 273
        Top = 97
        Width = 482
        Height = 435
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridIletView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridKurIletViewCellClick
          OnEditChanged = GridIletViewEditChanged
          DataController.DataSource = DtsPerIlet
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
          object GridIletViewColumn1: TcxGridDBColumn
            Caption = 'Etiketi'
            DataBinding.FieldName = 'ETIKET'
            DataBinding.IsNullValueType = True
            MinWidth = 150
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 150
          end
          object GridIletViewColumn3: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridIletViewColumn4: TcxGridDBColumn
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridIletViewColumnBilgi: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
            MinWidth = 311
            Options.Filtering = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 311
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridIletView
        end
      end
      object SQLPerIlet: TcxMemo
        Left = 305
        Top = 208
        Lines.Strings = (
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
          'name LIKE '
          #39'#KURILET_:SPID_%'#39')'
          'DROP TABLE #KURILET_:SPID_'
          ''
          'CREATE TABLE #KURILET_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](100) NULL,'
          #9'[BILGI] [nvarchar](1000) NULL,'
          #9'[ORJINAL] [nvarchar](1000) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #KURILET_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB LEFT OUTER JOIN REHBERAYAR RA '
          'ON '
          'RB.ETIKET=RA.ETIKET AND RB.YERI=RA.YERI'
          'where RB.YERI= :Yeri  and YER_ID= :Yeri_Id1   '
          ''
          'union all'
          ''
          'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' '
          ',GIRIS,KAYNAK,ZORUNLU  '
          ' from REHBERAYAR  where  YERI=1  '
          'and ETIKET not in (select ETIKET from REHBERBILGI '
          'where  YERI=1 and YER_ID= :Yeri_Id2)'
          'order by 1'
          ''
          'select * from #KURILET_:SPID_'
          'order by SIRA'
          '')
        TabOrder = 3
        Visible = False
        Height = 107
        Width = 329
      end
      object cxGrid2: TcxGrid
        Left = 0
        Top = 97
        Width = 273
        Height = 435
        Align = alLeft
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridPersonellerView: TcxGridDBTableView
          PopupMenu = PopupIlgili
          OnDblClick = DegisPerTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnSelectionChanged = GridPersonellerViewSelectionChanged
          DataController.DataSource = DtsIlgili
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.GroupByBox = False
          object PersonelAdi: TcxGridDBColumn
            Caption = 'Ad'#305' Soyad'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 131
          end
          object GridPersonellerViewGOREV: TcxGridDBColumn
            Caption = 'G'#246'revi'
            DataBinding.FieldName = 'GOREVI'
            DataBinding.IsNullValueType = True
            Width = 77
          end
          object PersonelNEREDE: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Kurumda'
                Value = '1'
              end
              item
                Description = 'Ta'#351#305'nd'#305
                ImageIndex = 12
                Value = '2'
              end
              item
                Description = 'Ayr'#305'ld'#305
                ImageIndex = 10
                Value = '3'
              end>
            Properties.ShowDescriptions = False
            Width = 31
            IsCaptionAssigned = True
          end
          object PersonelVARSAYILAN: TcxGridDBColumn
            Caption = 'Var.'
            DataBinding.FieldName = 'STATU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ReadOnly = True
            Visible = False
            Options.Editing = False
            Width = 30
          end
        end
        object GridPersoneller: TcxGridLevel
          GridView = GridPersonellerView
        end
      end
    end
    object DokumanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Yorum / Medya'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'DokumanEkr'
      OnEnterPage = DokumanEkrEnterPage
      OnPage = DokumanEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel4: TPanel
        Left = 0
        Top = 491
        Width = 755
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
          Width = 607
        end
        object BtnMesajGonder: TcxButton
          Left = 608
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
          Left = 693
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
        Top = 471
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
        ExplicitTop = 470
        AnchorX = 755
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 755
        Height = 401
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
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
    end
    object CRMEkstreEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'CRM Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'M'#252#351'teriye yap'#305'lm'#305#351' Proje, Aktivite, G'#246'rev, Teklif, Teknik Servis' +
        ', Fatura ve Tahsilatlar'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'CRMEkstreEkr'
      OnEnterPage = CRMEkstreEkrEnterPage
      OnPage = CRMEkstreEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar7: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 749
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 43
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
      end
      object cxGridCRM: TcxGrid
        Left = 0
        Top = 97
        Width = 755
        Height = 435
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 3
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object cxGridCRMView: TcxGridDBTableView
          OnDblClick = cxGridCRMViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridCRMViewCanFocusRecord
          DataController.DataSource = DtsCRMEkstre
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.Indicator = True
          object cxGridCRMViewMODUL: TcxGridDBColumn
            Caption = 'Mod'#252'l'
            DataBinding.FieldName = 'MODUL'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Aksiyon'
            DataBinding.FieldName = 'AKSIYONTARIH'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
          end
          object cxGridCRMViewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
          end
          object cxGridCRMViewKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGridLevel6: TcxGridLevel
          GridView = cxGridCRMView
        end
      end
      object cxLabel1: TcxLabel
        Left = 536
        Top = 38
        Caption = 'Zaman Aral'#305#287#305' '
        Transparent = True
      end
      object ComboZamanAraligi: TcxComboBox
        Left = 614
        Top = 37
        Properties.Items.Strings = (
          '1 ay'
          '3 ay'
          '6 ay'
          '1 y'#305'l'
          '2 y'#305'l'
          'T'#252'm Kay'#305'tlar')
        Properties.OnChange = ComboZamanAraligiPropertiesChange
        TabOrder = 0
        Text = '1 Ay'
        Width = 83
      end
      object MemoCRM: TcxMemo
        Left = 228
        Top = 229
        Lines.Strings = (
          'Declare @RehID integer'
          'set @RehID= :pRM'
          ''
          
            'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE  '#39'##' +
            'CRMEKSTRE99_:SPID_%'#39')'
          '  DROP TABLE ##CRMEKSTRE99_:SPID_  '
          ' '
          '  CREATE TABLE ##CRMEKSTRE99_:SPID_('
          '  '#9'[SIRANO] [int] IDENTITY(1,1) NOT NULL,'
          '  '#9'[ID] [int] NULL,'
          '    [MODUL] [nvarchar](30) NULL,'
          '  '#9'[TARIH] [datetime] NULL,'
          '  '#9'[AKSIYONTARIH] [datetime] NULL,'
          '  '#9'[NO] [nvarchar](100) NULL,'
          '    [TUR] [nvarchar](50) NULL,'
          '  '#9'[REHBERID] [int] NULL,'
          '  '#9'[ACIKLAMA] [nvarchar](500) NULL,'
          '  '#9'[DURUM] [nvarchar](50) NULL,'
          '  '#9'[TUTAR] [money] NULL,'
          '  '#9'[KUR] [nvarchar](6) NULL,'
          '  '#9'[ISLEMTIPI] [int] NULL,'
          '  '#9'[ISLEMTURU] [int] NULL'
          '  )'
          '  INSERT INTO ##CRMEKSTRE99_:SPID_ '
          '--Proje='
          
            'Select  ID=P.ID,MODUL='#39'CRM/Proje'#39', BASLAMATARIHI AS TARIH,BITIST' +
            'ARIHI as  AKSIYONTARIH,P.PROJEKODU as NO, '
          '     TUR=ProjeTur.ANAHTAR, '
          '     P.REHBERID,  ACIKLAMA=P.KONUSU,'
          '     DURUM = ProjeDurum.ANAHTAR,'
          '     TUTAR = isnull(P.SATISFIYATI,0.0), '
          '     KUR=isnull(P.SATISKUR,'#39#39') ,'
          '    ISLEMTIPI=1,'
          '   ISLEMTURU=P.TURU    '
          '     From PROJELER P  (NOLOCK)'
          
            #9'LEFT OUTER JOIN GENINI ProjeTur ON ProjeTur.DEGER = P.TURU AND ' +
            'ProjeTur.BOLUM =-2112 and ProjeTur.DIL=-1'
          
            #9'LEFT OUTER JOIN GENINI ProjeDurum ON ProjeDurum.DEGER = P.DURUM' +
            ' AND ProjeDurum.BOLUM =-2114 and ProjeDurum.DIL=-1'
          '    where REHBERID=@RehID'
          '    --i'#350' l'#304'STES'#304'='
          ' UNION ALL '
          
            ' Select  ID=G.ID,MODUL='#39'CRM/'#304#351' Listesi'#39', BASLAMATARIHI AS TARIH,' +
            'BITISTARIHI as  AKSIYONTARIH,[NO] = cast(G.ID as [nvarchar](100)' +
            '), '
          '     TUR = IsTur.ANAHTAR, '
          '     G.REHBERID,  ACIKLAMA=G.KONUSU,'
          '     DURUM = IsDurum.ANAHTAR,'
          '     TUTAR = 0.0, '
          '     KUR='#39#39','
          '     ISLEMTIPI=2 ,'
          '     ISLEMTURU=G.TURU      '
          '     From GOREVLER G  (NOLOCK)'
          
            #9'LEFT OUTER JOIN GENINI IsTur   ON IsTur.DEGER = G.TURU AND IsTu' +
            'r.BOLUM =-21044 and IsTur.DIL=-1'
          
            #9'LEFT OUTER JOIN GENINI IsDurum ON IsDurum.DEGER = G.DURUM AND I' +
            'sDurum.BOLUM =-21042 and IsDurum.DIL=-1'
          '    where G.REHBERID=@RehID    '
          ' --Teklif='
          ' UNION ALL '
          
            ' Select  ID=T.ID, MODUL='#39'Teklif'#39', TARIH, TARIH as  AKSIYONTARIH,' +
            ' TEKLIFNO as NO, '
          '     TUR=ProjeTur.ANAHTAR, '
          '     T.REHBERID,  ACIKLAMA = T.KONUSU,'
          '     DURUM = ProjeDurum.ANAHTAR,'
          '     TUTAR = T.TEKLIF_TUTARI, '
          '     KUR=T.KUR,'
          '    ISLEMTIPI=3,'
          '   ISLEMTURU=T.TURU      '
          '     From TEKLIF T  (NOLOCK)'
          
            #9'LEFT OUTER JOIN GENINI ProjeTur ON ProjeTur.DEGER = T.TURU AND ' +
            'ProjeTur.BOLUM =-2901 and ProjeTur.DIL=-1'
          
            #9'LEFT OUTER JOIN GENINI ProjeDurum ON ProjeDurum.DEGER = T.DURUM' +
            ' AND ProjeDurum.BOLUM =-2902 and ProjeDurum.DIL=-1'
          '    where REHBERID=@RehID'
          ' --Servis='
          ' UNION ALL '
          
            ' Select  ID=S.ID, MODUL='#39'Servis'#39',  TARIH = S.BASLAMATARIHI, AKSI' +
            'YONTARIH=S.BITISTARIHI, SERVISNO as NO, '
          '     TUR='#39'-'#39',--ProjeTur.ANAHTAR, '
          '     S.REHBERID,  ACIKLAMA = S.KONUSU,'
          '     DURUM = ProjeDurum.ANAHTAR,'
          '     TUTAR = 0, '
          '     KUR='#39#39' ,'
          '    ISLEMTIPI=4,'
          '    ISLEMTURU=CONVERT(smallint, 0)--S.TURU     '
          '     From SERVIS S  (NOLOCK)'
          
            #9'--LEFT OUTER JOIN GENINI ProjeTur ON ProjeTur.DEGER = S.TURU AN' +
            'D ProjeTur.BOLUM =-3006 and ProjeTur.DIL=-1'
          
            #9'LEFT OUTER JOIN GENINI ProjeDurum ON ProjeDurum.DEGER = S.DURUM' +
            ' AND ProjeDurum.BOLUM =-3007 and ProjeDurum.DIL=-1'
          '    where REHBERID=@RehID    '
          '--SQLKasa='
          ' UNION ALL '
          
            'Select  ID=K.ID,MODUL='#39'Finans'#39', ISLEMTARIHI AS TARIH,PLANTARIHI ' +
            'as  AKSIYONTARIH,BELGENO as NO, '
          
            '     TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER' +
            '=K.TUR AND DIL=-1), '
          '     K.REHBERID,  K.ACIKLAMA,'
          '     DURUM='#39#39','
          
            '     TUTAR = (case when K.BORC>0 and K.DOVIZ_TUTARI>0 then K.DOV' +
            'IZ_TUTARI else K.BORC end '
          
            '          + case when K.ALACAK>0 and K.DOVIZ_TUTARI>0 then K.DOV' +
            'IZ_TUTARI else K.ALACAK end),'
          
            '     KUR = case when K.DOVIZ_TUTARI>0 then K.DOVIZ_KURU else K.K' +
            'UR end,'
          '    ISLEMTIPI=5 ,'
          '    ISLEMTURU=K.TUR      '
          
            '     From KASA K (NOLOCK)  left outer join KASALAR KS on KS.ID= ' +
            'K.HESAPID  '
          '    where K.REHBERID=@RehID'
          '--SQLFatura ='
          ' UNION ALL '
          
            '    Select ID=F.ID,MODUL='#39'Finans'#39',  TARIH, FATURATARIH AS AKSIYO' +
            'NTARIH, FATURANO as NO, '
          
            '     TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER' +
            '=F.TUR AND DIL=-1), '
          '    REHBERID,'
          
            '    F.ACIKLAMA, DURUM=(select ANAHTAR from REHBERINI where BOLUM' +
            '='#39'Fat'#39' and DEGER=F.TUR),'
          
            '    TUTAR = (case when F.TUR in (11,12,13) then 0.0 else case wh' +
            'en DOVIZ_TUTARI>0 then'
          '    DOVIZ_TUTARI else FATURA_TUTARI end end +'
          
            '    case when F.TUR in (15,16,17) then 0.0 else case when DOVIZ_' +
            'TUTARI>0 then'
          '    DOVIZ_TUTARI else FATURA_TUTARI end end),'
          
            '     KUR = case when DOVIZ_TUTARI>0 then DOVIZ_CINSI else KUR en' +
            'd,'
          '    ISLEMTIPI=6,'
          '    ISLEMTURU=F.TUR'
          '   From FATBASLIK F (NOLOCK)'
          '    where REHBERID=@RehID '
          '    and F.TUR in (11,12,13,15,16,17)'
          '  ---- '#199'ek SQLCek= '
          '  UNION ALL'
          
            '  Select ID=C.ID,MODUL='#39'Finans'#39' ,TARIH, VADE as AKSIYONTARIH, MA' +
            'KBUZNO as NO,  '
          
            '   TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER=C' +
            '.TUR AND DIL=-1), '
          '  C.REHBERID,  ACIKLAMA=rtrim(C.ACIKLAMA),'
          
            ' --HESAPID=C.BANKASUBELERID, HESAPKODU=B.BANKAADI, HESAPADI=SUBE' +
            'ADI,'
          
            ' DURUM=(select ANAHTAR from GENINI where BOLUM=-2601 and DEGER=C' +
            '.TUR AND DIL=-1),  '
          ' C.TUTAR,C.KUR,    '
          'ISLEMTIPI=7,'
          'ISLEMTURU=C.TUR '
          '  From CEKLER C (NOLOCK)'
          '   inner join BANKASUBELER BS on BS.ID=C.BANKASUBELERID'
          '   inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
          '    where REHBERID=@RehID'
          '   ---- '#199'ek Ciro SQLCekCiro='
          '  UNION ALL'
          
            '  Select ID=C.ID,MODUL='#39'Finans'#39' ,TARIH, VADE as AKSIYONTARIH, MA' +
            'KBUZNO as NO, '
          
            '   TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER=3' +
            '3 AND DIL=-1), '
          '  C.REHBERID,'
          '  ACIKLAMA=rtrim(C.ACIKLAMA),'
          
            ' --HESAPID=C.BANKASUBELERID, HESAPKODU=B.BANKAADI, HESAPADI=SUBE' +
            'ADI,'
          
            ' DURUM=(select ANAHTAR from GENINI where BOLUM=-2601 and DEGER=C' +
            '.TUR AND DIL=-1),  '
          ' C.TUTAR,C.KUR,'
          '    ISLEMTIPI=8,'
          'ISLEMTURU=C.TUR         '
          '  From CEKLER C (NOLOCK)'
          '   inner join BANKASUBELER BS on BS.ID=C.BANKASUBELERID'
          '   inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
          '    where REHBERID=@RehID'
          '   '
          '---- Senet SQLSenet ='#39
          '  UNION ALL'
          
            '  Select ID=C.ID,MODUL='#39'Finans'#39' ,TARIH, VADE as AKSIYONTARIH, MA' +
            'KBUZNO as NO,'
          
            '   TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER=C' +
            '.TUR AND DIL=-1), '
          '  C.REHBERID, C.ACIKLAMA,'
          '  '
          
            '  DURUM=(select ANAHTAR from GENINI where BOLUM=-2601 and DEGER=' +
            'C.TUR AND DIL=-1), '
          ' C.TUTAR,C.KUR,'
          '    ISLEMTIPI=9,'
          'ISLEMTURU=C.TUR '
          '  From SENETLER C (NOLOCK)'
          '  where REHBERID=@RehID'
          'UNION ALL  --SQLPersonel=   '#39
          
            '   Select ID=P.ID,MODUL='#39'Finans'#39' ,TARIH, TARIH as AKSIYONTARIH, ' +
            'NO = null, '
          
            '    TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DEGER=' +
            'TUR AND DIL=-1), '
          '   P.YERID, ACIKLAMA='#39'Personel '#220'cret'#39','
          ' DURUM='#39#39', P.TUTAR, P.KUR,'
          '    ISLEMTIPI=10,'
          '   ISLEMTURU=P.TUR '
          '  From PLANMAAS P (NOLOCK)'
          '  --tahakkuklar'#305' getirmek laz'#305'm'
          '   inner join REHBERAYAR RA on RA.YERI=5 and RA.SIRA=P.SIRA'
          ' and RA.VARSAYILAN = 15'
          '      where YERID=@RehID'
          ' '
          '   '
          
            'select * from   ##CRMEKSTRE99_:SPID_  Where TARIH > DATEADD(mont' +
            'h,-1,GETDATE())')
        Properties.WordWrap = False
        TabOrder = 4
        Visible = False
        Height = 107
        Width = 443
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 12
      Width = 121
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 105
    Height = 574
    Align = alLeft
    TabOrder = 0
    object btnCariKart: TcxButton
      Left = 7
      Top = 78
      Width = 83
      Height = 29
      Caption = 'Cari Kart'
      TabOrder = 0
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object BtnDokuman: TcxButton
      Tag = 4
      Left = 7
      Top = 242
      Width = 83
      Height = 29
      Caption = 'Yorum/Medya'
      TabOrder = 4
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object BtnKisiBilgiFormu: TcxButton
      Tag = 3
      Left = 7
      Top = 207
      Width = 83
      Height = 29
      Caption = #304'lgililer'
      TabOrder = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object Btniletisim: TcxButton
      Tag = 1
      Left = 7
      Top = 113
      Width = 83
      Height = 29
      Caption = #304'leti'#351'im'
      TabOrder = 1
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object btnTicariBilgiler: TcxButton
      Tag = 2
      Left = 7
      Top = 148
      Width = 83
      Height = 54
      Caption = 'Ticari Bilgiler'
      TabOrder = 2
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnClick = btnCariKartClick
    end
    object BtnCRM: TcxButton
      Tag = 5
      Left = 7
      Top = 320
      Width = 83
      Height = 29
      Caption = 'CRM'
      TabOrder = 5
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
  end
  object TabCariIlet: TFDQuery
    OnNewRecord = TabCariIletNewRecord
    SQL.Strings = (
      ''
      
        'select RB.ID,RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZO' +
        'RUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id'
      'order by  1')
    Left = 627
    Top = 36
    ParamData = <
      item
        Name = 'YERI'
        ParamType = ptInput
      end
      item
        Name = 'YERI_ID'
        ParamType = ptInput
      end>
  end
  object DtsKurIlet: TDataSource
    DataSet = TabCariIlet
    Left = 149
    Top = 510
  end
  object TabPerIlet: TFDQuery
    OnNewRecord = TabPerIletNewRecord
    SQL.Strings = (
      
        'select RB.ID,RB.SIRA,RB.ETIKET,RB.BILGI,GIRIS=isnull(RA.GIRIS,0)' +
        ',KAYNAK=(RA.KAYNAK,0) ,ZORUNLU=(RA.ZORUNLU,0)'
      'from REHBERBILGI RB left JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   AND RA.YERI=4'
      'order by  1')
    Left = 693
    Top = 72
  end
  object DtsPerIlet: TDataSource
    DataSet = TabPerIlet
    Left = 294
    Top = 520
  end
  object TabTicari: TFDQuery
    BeforePost = TabTicariBeforePost
    OnNewRecord = TabTicariNewRecord
    SQL.Strings = (
      ''
      
        'select RB.ID,RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZO' +
        'RUNLU  '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 676
    Top = 360
  end
  object DtsTicari: TDataSource
    DataSet = TabTicari
    Left = 119
    Top = 512
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 301
    Top = 472
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor]
      Color = clRed
    end
  end
  object TabRehber: TFDQuery
    BeforeEdit = TabRehberBeforeEdit
    BeforePost = TabRehberBeforePost
    AfterPost = TabRehberAfterPost
    AfterScroll = TabRehberAfterScroll
    OnNewRecord = TabRehberNewRecord
    SQL.Strings = (
      'select  * from REHBER'
      'where ID=:PAR')
    Left = 239
    Top = 24
    ParamData = <
      item
        Name = 'PAR'
        ParamType = ptInput
      end>
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 343
    Top = 515
  end
  object TabIlgili: TFDQuery
    BeforeOpen = TabIlgiliBeforeOpen
    BeforePost = TabIlgiliBeforePost
    AfterPost = TabIlgiliAfterPost
    AfterScroll = TabIlgiliAfterScroll
    OnNewRecord = TabIlgiliNewRecord
    SQL.Strings = (
      
        'select R.ID, R.BAGID, R.FIRMA, R.STATU,GRUP,EKLEYEN,DURUM,SUBEID' +
        ',DEGISTIREN,DEGISTIRMETARIHI,'
      'GOREVI=(select RB.BILGI from REHBERBILGI RB'
      'INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and '
      'RA.SIRA=RB.SIRA --AND RA.YERI=RB.YERI '
      'WHERE  RA.VARSAYILAN=175'
      
        'and RB.YER_ID=(select ID from REHBERILETISIM where REHBERID = R.' +
        'ID)'
      ')'
      ' from REHBER R where R.GRUP=334 and BAGID=:PID '
      ' and (:PID2=0 or R.ID=:PID2)'
      'order by R.STATU  desc')
    Left = 450
    Top = 247
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 258
    Top = 511
  end
  object dtsSonAktivite: TDataSource
    DataSet = TabSonAktivite
    Left = 116
    Top = 472
  end
  object TabSonAktivite: TFDQuery
    SQL.Strings = (
      'SELECT TOP 1 ID, BITISTARIHI , KONUSU, NOTLAR'
      'FROM AKTIVITELER A '
      'WHERE MUSTERIID = :PID AND'
      '     1  = CASE WHEN A.TURU = 1 AND A.DURUM = 9 THEN 1  '
      '               WHEN A.TURU <> 1 AND A.DURUM = 8 THEN 1 '
      '               ELSE  0'
      '         END '
      ''
      '         ORDER BY BITISTARIHI DESC')
    Left = 275
    Top = 423
  end
  object TabImaj: TFDQuery
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM,ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 519
    Top = 465
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    OnStateChange = DtsImajStateChange
    Left = 453
    Top = 473
  end
  object OpenDialog1: TOpenDialog
    Left = 382
    Top = 470
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 654
    Top = 525
  end
  object DtsCRMEkstre: TDataSource
    DataSet = TabCRMEkstre
    OnStateChange = DtsImajStateChange
    Left = 461
    Top = 525
  end
  object TabCRMEkstre: TFDQuery
    AfterScroll = TabCRMEkstreAfterScroll
    Left = 544
    Top = 520
  end
  object PopupIlgili: TPopupMenu
    Left = 25
    Top = 15
    object lgiliKurumdanAyrld1: TMenuItem
      Caption = #304'lgilinin durumunu '#39'Ayr'#305'ld'#305#39' olarak '
      ImageIndex = 10
      ImageName = 'PngImage10'
      OnClick = lgiliKurumdanAyrld1Click
    end
    object DurumuSfrla1: TMenuItem
      Caption = #304'lgilinin durumunu bo'#351' olarak i'#351'aretle'
      OnClick = DurumuSfrla1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object lgiliyeletiimBilgisiKopyala1: TMenuItem
      Caption = #304'lgiliye '#304'leti'#351'im Bilgisi Kopyala'
      OnClick = lgiliyeletiimBilgisiKopyala1Click
    end
    object lgiliyiKopyala1: TMenuItem
      Caption = #304'lgiliyi Kopyala'
      OnClick = lgiliyiKopyala1Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Varsaylan1: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      OnClick = Varsaylan1Click
    end
  end
  object DtsRehberIlet: TDataSource
    DataSet = TabRehberIletisim
    Left = 200
    Top = 519
  end
  object TabRehberIletisim: TFDQuery
    OnNewRecord = TabRehberIletisimNewRecord
    SQL.Strings = (
      ''
      'select *'
      'from REHBERILETISIM'
      'where REHBERID=:PID '
      'Order by VARSAYILAN  desc')
    Left = 540
    Top = 131
  end
  object PopupIletisim: TPopupMenu
    Left = 705
    Top = 511
    object MenuItem7: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      OnClick = MenuItem7Click
    end
  end
  object TabNotlar: TFDQuery
    SQL.Strings = (
      'select '
      #9'GY.ID, GY.TUR, GY.TARIH,GY.EKLEMETARIHI, GY.EKLEYEN,'
      
        #9'BILGI=(select ANAHTAR from GENINI where BOLUM=-22035 and DEGER=' +
        'GY.TUR and DIL=-1)+'#39' / '#39'+ '
      #9'CONVERT(varchar(11),GY.TARIH,103)+'#39' / '#39'+ R.FIRMA,GY.YORUM'
      'from '
      #9'GOREVYORUM GY inner join REHBER R on R.ID=GY.EKLEYEN'
      'where '
      #9'GOREVID = :PId '
      'AND TUR between 11 and 13'
      'order by 3 DESC')
    Left = 547
    Top = 353
  end
  object DtsNotlar: TDataSource
    DataSet = TabNotlar
    Left = 628
    Top = 356
  end
  object TabPerIletisim: TFDQuery
    SQL.Strings = (
      ''
      'select *'
      'from REHBERILETISIM'
      'where REHBERID=:PID '
      '')
    Left = 540
    Top = 251
  end
  object TabYorum: TFDQuery
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
    Left = 585
    Top = 369
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 587
    Top = 428
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
    Left = 768
    Top = 400
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
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
  object YorumAtacMenu: TOfficePopupMenu
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
    Left = 408
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
end
