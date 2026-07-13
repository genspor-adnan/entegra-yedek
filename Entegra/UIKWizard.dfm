object IKWizardDlg: TIKWizardDlg
  Left = 0
  Top = 0
  ActiveControl = EditVKNO
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Cari Kart Sihirbaz'#305
  ClientHeight = 556
  ClientWidth = 1043
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
    Width = 938
    Height = 556
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
      938
      556)
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
      WaterMark.Width = 1
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 938
        Height = 233
        Align = alTop
        TabOrder = 0
        object Label6: TLabel
          Left = 484
          Top = 12
          Width = 11
          Height = 18
          Caption = 'ID'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          OnDblClick = Label6DblClick
        end
        object EditKOD: TcxDBTextEdit
          Left = 116
          Top = 10
          TabStop = False
          DataBinding.DataField = 'KOD'
          DataBinding.DataSource = DtsRehber
          Enabled = False
          StyleDisabled.BorderColor = clWindowFrame
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 0
          Width = 133
        end
        object Label1: TcxLabel
          Left = 19
          Top = 10
          Margins.Left = 0
          Caption = 'Kod/T.C.No'
          Transparent = True
        end
        object KodAgaciTus: TcxButton
          Left = 250
          Top = 11
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
          TabOrder = 19
          OnClick = KodAgaciTusClick
        end
        object EditFIRMA: TcxDBTextEdit
          Left = 116
          Top = 38
          DataBinding.DataField = 'FIRMA'
          DataBinding.DataSource = DtsRehber
          TabOrder = 2
          Width = 291
        end
        object LblUnvan: TcxLabel
          Left = 19
          Top = 39
          Margins.Left = 0
          Caption = 'Ad'#305' Soyad'#305
          Properties.WordWrap = True
          Transparent = True
          Width = 60
        end
        object EditOzelKod: TcxDBTextEdit
          Left = 348
          Top = 122
          DataBinding.DataField = 'OZELKOD'
          DataBinding.DataSource = DtsRehber
          TabOrder = 10
          Width = 147
        end
        object Label3: TcxLabel
          Left = 289
          Top = 124
          Caption = #214'zel Kod'
          Properties.WordWrap = True
          Transparent = True
          Width = 53
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 606
          Top = 94
          RepositoryItem = Tablo.RepCariDurum
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsRehber
          Enabled = False
          Properties.ImageAlign = iaRight
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnEditValueChanged = ComboDURUMPropertiesEditValueChanged
          TabOrder = 13
          Width = 150
        end
        object Label34: TcxLabel
          Left = 561
          Top = 96
          Cursor = crHandPoint
          Hint = 'CariKart_Durum'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.DURUM'
          Caption = 'Durum'
          FocusControl = ComboDURUM
          Transparent = True
        end
        object cxDBLabel2: TcxDBLabel
          Left = 501
          Top = 14
          DataBinding.DataField = 'ID'
          DataBinding.DataSource = DtsRehber
          Transparent = True
          Height = 21
          Width = 37
        end
        object ComboSube: TcxDBImageComboBox
          Left = 606
          Top = 66
          RepositoryItem = Tablo.RepSubeler
          DataBinding.DataField = 'SUBEID'
          DataBinding.DataSource = DtsRehber
          Enabled = False
          Properties.ImmediatePost = True
          Properties.Items = <
            item
            end>
          Properties.OnCloseUp = ComboSubePropertiesCloseUp
          TabOrder = 12
          OnKeyUp = ComboSubeKeyUp
          Width = 151
        end
        object LblSube: TcxLabel
          Left = 569
          Top = 68
          Caption = #350'ube'
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 285
          Top = 151
          Caption = 'Muh.Kodu'
          Properties.WordWrap = True
          Transparent = True
          Width = 60
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 348
          Top = 150
          DataBinding.DataField = 'MUHKODU'
          DataBinding.DataSource = DtsRehber
          TabOrder = 11
          Width = 147
        end
        object DBCheckBox1: TDBCheckBox
          Left = 413
          Top = 41
          Width = 16
          Height = 17
          DataField = 'R'
          DataSource = DtsRehber
          TabOrder = 26
        end
        object LabelDepartmani: TcxLabel
          Left = 18
          Top = 151
          Cursor = crHandPoint
          Hint = 'CariKart_Kategori'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.SINIF'
          Margins.Left = 0
          Caption = 'Departman'#305
          Transparent = True
          OnClick = LabelDepartmaniClick
        end
        object ComboCinsiyet: TcxImageComboBox
          Left = 116
          Top = 94
          RepositoryItem = Tablo.RepIKCinsiyet
          Properties.Items = <>
          Properties.OnCloseUp = ComboCinsiyetPropertiesCloseUp
          TabOrder = 5
          Width = 160
        end
        object cxLabel2: TcxLabel
          Left = 19
          Top = 95
          Cursor = crHandPoint
          Hint = 'CariKart_Kategori'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.STATU'
          Margins.Left = 0
          Caption = 'Cinsiyeti'
          FocusControl = ComboCinsiyet
          Transparent = True
        end
        object LabelGIRISTARIHI: TcxLabel
          Left = 501
          Top = 151
          Cursor = crHandPoint
          HelpType = htKeyword
          Caption = #304#351'e Ba'#351'lama Tarihi'
          Transparent = True
        end
        object DateGIRISTARIHI: TcxDateEdit
          Left = 607
          Top = 150
          Style.Color = clMoneyGreen
          TabOrder = 15
          Width = 148
        end
        object LabelCIKISTARIHI: TcxLabel
          Left = 507
          Top = 179
          Cursor = crHandPoint
          HelpType = htKeyword
          Caption = #304#351'ten '#199#305'k'#305#351' Tarihi'
          Transparent = True
        end
        object DateCIKISTARIHI: TcxDateEdit
          Left = 606
          Top = 178
          Style.Color = 8421631
          TabOrder = 16
          Width = 150
        end
        object cxLabel6: TcxLabel
          Left = 19
          Top = 66
          Cursor = crHandPoint
          HelpType = htKeyword
          Caption = 'D.Yeri/D.Tarihi'
          Transparent = True
        end
        object DateTARIH: TcxDBDateEdit
          Left = 298
          Top = 64
          DataBinding.DataField = 'DTARIH'
          DataBinding.DataSource = DtsRehber
          Properties.SaveTime = False
          Properties.ShowTime = False
          TabOrder = 4
          Width = 132
        end
        object EditDYeri: TcxButtonEdit
          Left = 116
          Top = 66
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDYeriPropertiesButtonClick
          TabOrder = 3
          Width = 159
        end
        object LabelGorevi: TcxLabel
          Left = 19
          Top = 177
          Cursor = crHandPoint
          Hint = 'CariKart_Kategori'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.SINIF'
          Margins.Left = 0
          Caption = 'G'#246'revi'
          Transparent = True
          OnClick = LabelGoreviClick
        end
        object EditVKNO: TcxTextEdit
          Left = 298
          Top = 9
          TabOrder = 1
          Width = 131
        end
        object EditDepartman: TcxButtonEdit
          Tag = 1
          Left = 117
          Top = 150
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
          TabOrder = 7
          Width = 159
        end
        object EditGorevi: TcxButtonEdit
          Tag = 2
          Left = 118
          Top = 178
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
          TabOrder = 8
          Width = 159
        end
        object ListelerTus: TcxButton
          Left = 762
          Top = 175
          Width = 83
          Height = 29
          Caption = 'Listeler'
          TabOrder = 33
          Visible = False
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          OnClick = ListelerTusClick
        end
        object ComboOgrenim: TcxDBImageComboBox
          Left = 117
          Top = 122
          RepositoryItem = Tablo.RepIKOgrenim
          DataBinding.DataField = 'KATEGORI'
          DataBinding.DataSource = DtsRehber
          Properties.Items = <>
          Properties.OnCloseUp = ComboCinsiyetPropertiesCloseUp
          TabOrder = 6
          Width = 160
        end
        object cxLabel1: TcxLabel
          Left = 19
          Top = 124
          Cursor = crHandPoint
          HelpType = htKeyword
          HelpKeyword = 'REHBER.STATU'
          Margins.Left = 0
          Caption = #214#287'r.Durumu'
          FocusControl = ComboOgrenim
          Transparent = True
          OnClick = cxLabel1Click
        end
        object cxLabel3: TcxLabel
          Left = 21
          Top = 206
          Cursor = crHandPoint
          Hint = 'ALTBOLGE'
          HelpType = htKeyword
          Caption = 'Uyru'#287'u'
          Transparent = True
        end
        object EditUyruk: TcxButtonEdit
          Left = 118
          Top = 206
          Hint = 'ALTBOLGE'
          HelpType = htKeyword
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
          Properties.OnButtonClick = EditUyrukPropertiesButtonClick
          TabOrder = 9
          Width = 159
        end
        object cxLabel5: TcxLabel
          Left = 561
          Top = 124
          Cursor = crHandPoint
          Hint = 'IK_Statu'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.DURUM'
          Caption = 'Stat'#252
          FocusControl = cxDBImageComboBox1
          Transparent = True
          OnClick = cxLabel5Click
        end
        object cxDBImageComboBox1: TcxDBImageComboBox
          Left = 606
          Top = 122
          RepositoryItem = Tablo.RepIKStatu
          DataBinding.DataField = 'BAGID'
          DataBinding.DataSource = DtsRehber
          Properties.ImageAlign = iaRight
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnEditValueChanged = ComboDURUMPropertiesEditValueChanged
          TabOrder = 14
          Width = 150
        end
        object cxDBImageComboBox2: TcxDBImageComboBox
          Left = 607
          Top = 206
          DataBinding.DataField = 'PERYOT'
          DataBinding.DataSource = DtsRehber
          Properties.ImageAlign = iaRight
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              Description = 'Maa'#351
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Maa'#351' yada Prim'
              Value = 1
            end
            item
              Description = 'Maa'#351' + Prim'
              Value = 2
            end>
          Properties.OnEditValueChanged = ComboDURUMPropertiesEditValueChanged
          TabOrder = 17
          Width = 150
        end
        object cxLabel7: TcxLabel
          Left = 528
          Top = 207
          Cursor = crHandPoint
          Hint = 'IK_Statu'
          HelpType = htKeyword
          HelpKeyword = 'REHBER.DURUM'
          Caption = #199'al'#305#351'ma '#350'ekli'
          FocusControl = cxDBImageComboBox2
          Transparent = True
        end
      end
      object CariPageControl: TcxPageControl
        Left = 0
        Top = 303
        Width = 938
        Height = 211
        Align = alClient
        TabOrder = 1
        Properties.ActivePage = SheetNotlar
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 207
        ClientRectLeft = 4
        ClientRectRight = 934
        ClientRectTop = 29
        object SheetNotlar: TcxTabSheet
          Caption = 'Not / Uyar'#305
          ImageIndex = 0
          object CariGridNotlar: TcxGrid
            Left = 0
            Top = 27
            Width = 930
            Height = 151
            Align = alClient
            TabOrder = 0
            object CariGridNotlarView: TcxGridDBCardView
              OnDblClick = YorumDuzenleClick
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
                Styles.Content = Tablo.cxStyle4
                Styles.CategoryRow = Tablo.cxStyle4
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
                Styles.Content = Tablo.cxStyle12
                Styles.CategoryRow = Tablo.cxStyle4
              end
            end
            object CariGridNotlarLevel1: TcxGridLevel
              GridView = CariGridNotlarView
            end
          end
          object ToolBar4: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 924
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
            Images = Tablo.PNGImageList2
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
              Style = tbsTextButton
              OnClick = YorumEkleTusClick
            end
            object YorumSil: TToolButton
              Left = 66
              Top = 0
              Caption = 'Sil'
              ImageIndex = 5
              Style = tbsTextButton
              OnClick = YorumSilClick
            end
            object YorumDuzenle: TToolButton
              Tag = 3
              Left = 132
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              Style = tbsTextButton
              OnClick = YorumDuzenleClick
            end
          end
        end
        object SheetEkAlanlar: TcxTabSheet
          Caption = 'Ek Alanlar'
          ImageIndex = 1
          object PanelEkAlanlar: TPanel
            Left = 0
            Top = 0
            Width = 930
            Height = 178
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
          end
        end
      end
      object LogoResim: TcxDBImage
        Left = 608
        Top = 33
        DataBinding.DataField = 'RESIM'
        DataBinding.DataSource = DtsRehber
        Properties.Caption = 'Resim i'#231'in sa'#287' t'#305'klay'#305'n'
        Properties.FitMode = ifmProportionalStretch
        Properties.GraphicClassName = 'TdxSmartImage'
        TabOrder = 2
        Height = 97
        Width = 128
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
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 932
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
          OnClick = YeniAdresTusClick
        end
        object AdresSilTus: TToolButton
          Left = 63
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = AdresSilTusClick
        end
        object ToolButton2: TToolButton
          Left = 126
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object AdresDegistir: TToolButton
          Left = 134
          Top = 0
          Caption = 'De'#287'i'#351'tir'
          ImageIndex = 7
          OnClick = AdresDegistirClick
        end
        object ToolButton1: TToolButton
          Left = 197
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 30
          Style = tbsSeparator
        end
        object BtnGoogle: TToolButton
          Left = 205
          Top = 0
          Caption = 'Google'
          ImageIndex = 29
          OnClick = BtnGoogleClick
        end
        object ToolButton3: TToolButton
          Left = 268
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 30
          Style = tbsSeparator
        end
      end
      object GridKurIlet: TcxGrid
        Left = 167
        Top = 97
        Width = 771
        Height = 417
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
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          Styles.Content = AnaForm.cxStyle1
          Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
          object cxGridDBColumn3: TcxGridDBColumn
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
            Styles.Content = Tablo.cxStyle1
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
          'RB.ETIKET=RA.ETIKET AND RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
          'where RB.YERI= :Yeri  and YER_ID= :Yeri_Id1   '
          ''
          'union all'
          ''
          'select distinct SIRA, ETIKET, BILGI=LEFT(ETIKET,0), ORJINAL=LEFT'
          '(ETIKET,0) '
          ',GIRIS,KAYNAK,ZORUNLU  '
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
        Height = 417
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
          Styles.Selection = Tablo.cxstSecili
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
            Properties.Images = Tablo.PNGImageList2
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
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 932
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
          OnClick = YeniPerTusClick
        end
        object SilPerTus: TToolButton
          Left = 98
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SilPerTusClick
        end
        object ToolButton8: TToolButton
          Left = 196
          Top = 0
          Width = 8
          Caption = 'ToolButton8'
          ImageIndex = 8
          Style = tbsSeparator
        end
        object DegisPerTus: TToolButton
          Left = 204
          Top = 0
          Caption = 'De'#287'i'#351'tir'
          ImageIndex = 7
          OnClick = DegisPerTusClick
        end
        object VarsayPerTus: TToolButton
          Left = 302
          Top = 0
          Caption = 'Varsaylan Yap'
          ImageIndex = 6
          OnClick = VarsayPerTusClick
        end
      end
      object GridIlet: TcxGrid
        Left = 167
        Top = 97
        Width = 771
        Height = 417
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
          OnCanFocusRecord = GridIletViewCanFocusRecord
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
          Styles.Content = AnaForm.cxStyle1
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
      object SQLPerIlet_Eski: TcxMemo
        Left = 290
        Top = 138
        Lines.Strings = (
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,'
          'ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU'
          'from REHBERBILGI RB LEFT OUTER JOIN REHBERAYAR RA '
          'ON RB.ETIKET=RA.ETIKET AND RB.YERI=RA.YERI'
          'where RB.YERI= :Yeri and RB.YER_ID= :Yeri_Id1'
          'union all'
          'select RA.SIRA, RA.ETIKET, BILGI=LEFT(RA.ETIKET,0), '
          'ORJINAL=LEFT(RA.ETIKET,0), RA.GIRIS, '
          'RA.KAYNAK, RA.ZORUNLU'
          'from REHBERAYAR RA where RA.YERI=1'
          'and RA.ETIKET not in (select RB.ETIKET from REHBERBILGI '
          'RB where RB.YERI=4 and RB.YER_ID= :Yeri_Id2)'
          'order by 1')
        TabOrder = 3
        Visible = False
        Height = 107
        Width = 329
      end
      object cxGrid2: TcxGrid
        Left = 0
        Top = 97
        Width = 167
        Height = 417
        Align = alLeft
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridPersonellerView: TcxGridDBTableView
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
          Styles.Selection = Tablo.cxstSecili
          object PersonelAdi: TcxGridDBColumn
            Caption = 'Ad'#305' Soyad'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 131
          end
          object PersonelNEREDE: TcxGridDBColumn
            DataBinding.FieldName = 'NEREDE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.PNGImageList2
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
      object SQLPerIlet: TcxMemo
        Left = 225
        Top = 240
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
          'RB.ETIKET=RA.ETIKET AND RB.SIRA=RA.SIRA AND '
          'RB.YERI=RA.YERI'
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
        TabOrder = 4
        Visible = False
        Height = 107
        Width = 329
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
      Header.Subtitle.Text = 'Subtitle'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Caption = 'DokumanEkr'
      OnEnterPage = DokumanEkrEnterPage
      OnPage = DokumanEkrPage
      object Panel4: TPanel
        Left = 0
        Top = 473
        Width = 938
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
          Width = 790
        end
        object BtnMesajGonder: TcxButton
          Left = 791
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
          Left = 876
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
        Top = 453
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
        AnchorX = 938
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 938
        Height = 383
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
    object PersonelOzlukEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Personel '#214'zl'#252'k Bilgileri'
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
      OnEnterPage = PersonelOzlukEkrEnterPage
      OnPage = PersonelOzlukEkrPage
      object Panel1: TPanel
        Left = 0
        Top = 70
        Width = 938
        Height = 444
        Align = alClient
        BevelOuter = bvNone
        Color = 14540253
        ParentBackground = False
        TabOrder = 0
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 932
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
          object YeniTemelTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            OnClick = YeniPerTusClick
          end
          object SilTemelTus: TToolButton
            Left = 48
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            OnClick = SilPerTusClick
          end
        end
        object GridTemel: TcxGrid
          Left = 0
          Top = 27
          Width = 938
          Height = 417
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          TabOrder = 1
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object GridTemelView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridTemelViewCanFocusRecord
            OnCellClick = GridKurIletViewCellClick
            OnEditChanged = GridTemelViewEditChanged
            DataController.DataSource = DtsPerOzluk
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            Styles.Content = AnaForm.cxStyle1
            Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
            object cxGridDBColumn1: TcxGridDBColumn
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
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Bilgisi'
              DataBinding.FieldName = 'BILGI'
              DataBinding.IsNullValueType = True
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
              Options.Sorting = False
              Width = 400
            end
            object GridTemelViewColumn1: TcxGridDBColumn
              DataBinding.FieldName = 'ORJINAL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridTemelViewColumn2: TcxGridDBColumn
              DataBinding.FieldName = 'ZORUNLU'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridTemelView
          end
        end
        object SQLTemel: TcxMemo
          Left = 100
          Top = 84
          Lines.Strings = (
            'IF OBJECT_ID('#39'tempdb..#OZLUK_:SPID_'#39') IS NOT NULL '
            'BEGIN DROP TABLE #OZLUK_:SPID_ END'
            'CREATE TABLE #OZLUK_:SPID_('
            #9'[SIRA] [smallint] NULL,'
            #9'[ETIKET] [nvarchar](100) NULL,'
            #9'[BILGI] [nvarchar](1000) NULL,'
            #9'[ORJINAL] [nvarchar](1000) NULL,'
            #9'[GIRIS] [nvarchar](50) NULL,'
            #9'[KAYNAK] [nvarchar](255) NULL,'
            '                [ZORUNLU] [bit] NULL'
            ')'
            'INSERT INTO #OZLUK_:SPID_'
            'select '
            'RB.SIRA,RB.ETIKET,RB.BILGI,'
            'ORJINAL=RB.BILGI,RA.GIRIS,'
            'RA.KAYNAK,RA.ZORUNLU'
            'from REHBERBILGI RB LEFT OUTER JOIN REHBERAYAR '
            'RA ON RB.ETIKET=RA.ETIKET AND RB.YERI=RA.YERI'
            'where RB.YERI= :Yeri and YER_ID= :Yeri_Id1'
            'union all'
            'select SIRA, ETIKET, BILGI=LEFT(ETIKET,0), '
            'ORJINAL=LEFT(ETIKET,0),'
            'GIRIS,'
            'KAYNAK, ZORUNLU'
            'from REHBERAYAR where YERI=3'
            'and ETIKET not in (select ETIKET from REHBERBILGI '
            'where YERI=3 and YER_ID= :Yeri_Id2)'
            'order by 1'
            'select * from #OZLUK_:SPID_'
            'order by SIRA')
          TabOrder = 2
          Visible = False
          Height = 91
          Width = 303
        end
      end
    end
    object PersonelUcretEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Personel '#220'cret Bilgileri'
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
      ShowHint = True
      OnEnterPage = PersonelUcretEkrEnterPage
      OnPage = PersonelUcretEkrPage
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 932
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
        TabOrder = 0
        Transparent = True
      end
      object GridUcret: TcxGrid
        Left = 0
        Top = 97
        Width = 938
        Height = 417
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridUcretView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridUcretViewCanFocusRecord
          OnCellClick = GridKurIletViewCellClick
          OnEditChanged = GridUcretViewEditChanged
          DataController.DataSource = DtsPerUcret
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = AnaForm.cxStyle1
          Styles.OnGetContentStyle = GridKurIletViewStylesGetContentStyle
          object GridUcretViewColumn1: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.SaveTime = False
            Properties.ShowTime = False
            Visible = False
          end
          object cxGridDBColumn7: TcxGridDBColumn
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
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Tutar'#305
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            MinWidth = 100
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
            Width = 100
          end
          object GridUcretViewKur: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxComboBoxProperties'
            Properties.DropDownListStyle = lsFixedList
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            Width = 52
          end
          object cxGridDBColumn9: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINALTUTAR'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridUcretViewColumn3: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINALKUR'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridUcretViewColumn2: TcxGridDBColumn
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object cxGridLevel5: TcxGridLevel
          GridView = GridUcretView
        end
      end
      object SQLPerUcret: TcxMemo
        Left = 220
        Top = 149
        Lines.Strings = (
          'IF OBJECT_ID('#39'tempdb..#PERUCRET_:SPID_'#39') IS NOT NULL'
          'BEGIN DROP TABLE'
          '#PERUCRET_:SPID_ END'
          'CREATE TABLE #PERUCRET_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](50) NULL,'
          #9'[TUTAR] [money] NULL,'
          #9'[KUR] [nvarchar](10) NULL,'
          #9'[ORJINALTUTAR] [nvarchar](50) NULL,'
          #9'[ORJINALKUR] [nvarchar](500) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #PERUCRET_:SPID_'
          'select '
          'SIRA,ETIKET,TUTAR,KUR,ORJINALTUTAR=TUTAR,'
          'ORJINALKUR=KUR,ZORUNLU=0'
          'from PLANMAAS'
          'where YER=0 and YERID= :RID1'
          'union all'
          'select SIRA, ETIKET, TUTAR=null, KUR=null,'
          'ORJINALTUTAR=null,'
          'ORJINALKUR=null, ZORUNLU'
          'FROM REHBERAYAR WHERE YERI=5'
          'AND VARSAYILAN in (11,12,13,15)'
          'and ETIKET not in (select ETIKET'
          'from PLANMAAS'
          'where YER=0 and YERID=:RID2)'
          'order by 1'
          'select * from #PERUCRET_:SPID_')
        TabOrder = 2
        Visible = False
        Height = 107
        Width = 443
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 10
      Width = 121
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 105
    Height = 556
    Align = alLeft
    TabOrder = 0
    object btnCariKart: TcxButton
      Left = 7
      Top = 79
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
      Tag = 3
      Left = 7
      Top = 216
      Width = 83
      Height = 29
      Caption = 'Yorum/Medya'
      TabOrder = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object BtnKisiBilgiFormu: TcxButton
      Tag = 2
      Left = 7
      Top = 182
      Width = 83
      Height = 29
      Caption = #304'lgililer'
      TabOrder = 2
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnCariKartClick
    end
    object BtnOzluk: TcxButton
      Tag = 4
      Left = 7
      Top = 251
      Width = 83
      Height = 50
      Caption = #214'zl'#252'k Bilgileri'
      TabOrder = 4
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      WordWrap = True
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
    object btnUcret: TcxButton
      Tag = 5
      Left = 7
      Top = 307
      Width = 83
      Height = 29
      Caption = #220'cret Bilgileri'
      TabOrder = 5
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnClick = btnCariKartClick
    end
  end
  object TabKurIlet: TFDQuery
    AfterPost = TabKurIletAfterPost
    OnNewRecord = TabKurIletNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU ' +
        'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA ' +
        'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   order by  1')
    Left = 35
    Top = 12
  end
  object DtsKurIlet: TDataSource
    DataSet = TabKurIlet
    Left = 125
    Top = 470
  end
  object DtsPers: TDataSource
    Left = 63
    Top = 300
  end
  object TabPerOzluk: TFDQuery
    AfterPost = TabKurIletAfterPost
    OnNewRecord = TabPerOzlukNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU ' +
        ' from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA' +
        ' where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   order by  1')
    Left = 594
    Top = 513
  end
  object DtsPerOzluk: TDataSource
    DataSet = TabPerOzluk
    Left = 661
    Top = 495
  end
  object TabPerIlet: TFDQuery
    AfterPost = TabKurIletAfterPost
    OnNewRecord = TabPerIletNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK ,RA.ZORUNLU' +
        ' from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA' +
        ' where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   order by  1')
    Left = 621
    Top = 304
  end
  object DtsPerIlet: TDataSource
    DataSet = TabPerIlet
    Left = 510
    Top = 496
  end
  object TabPerUcret: TFDQuery
    AfterPost = TabKurIletAfterPost
    OnNewRecord = TabPerUcretNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ETIKET,TUTAR,KUR, SIRA  from PLANMAAS where YER=0 and YER' +
        'ID=:REHID order by SIRA')
    Left = 428
    Top = 488
  end
  object DtsPerUcret: TDataSource
    DataSet = TabPerUcret
    Left = 286
    Top = 488
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 933
    Top = 328
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
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select  * from REHBER where ID=:PID')
    Left = 15
    Top = 416
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 111
    Top = 563
  end
  object TabIlgili: TFDQuery
    BeforePost = TabIlgiliBeforePost
    AfterScroll = TabIlgiliAfterScroll
    OnNewRecord = TabIlgiliNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select * from REHBER where GRUP=334 and BAGID=:PID Order by STAT' +
        'U desc')
    Left = 418
    Top = 287
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 186
    Top = 479
  end
  object dtsSonAktivite: TDataSource
    DataSet = TabSonAktivite
    Left = 804
    Top = 504
  end
  object TabSonAktivite: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT TOP 1 ID, BITISTARIHI , KONUSU, NOTLAR FROM AKTIVITELER A' +
        ' WHERE MUSTERIID = :PID AND      1  = CASE WHEN A.TURU = 1 AND A' +
        '.DURUM = 9 THEN 1                 WHEN A.TURU <> 1 AND A.DURUM =' +
        ' 8 THEN 1                ELSE  0          END ORDER BY BITISTARI' +
        'HI DESC')
    Left = 835
    Top = 311
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM,ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ] WHERE DURUM>0 AND YERI = :PYeri AND YER_ID=' +
        ':PYer_ID')
    Left = 815
    Top = 25
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 765
    Top = 25
  end
  object OpenDialog1: TOpenDialog
    Left = 30
    Top = 478
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 414
    Top = 5
  end
  object DtsRehberIlet: TDataSource
    DataSet = TabAdresAd
    Left = 160
    Top = 567
  end
  object TabAdresAd: TFDQuery
    OnNewRecord = TabAdresAdNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select * from REHBERILETISIM where REHBERID=:PID Order by VARSAY' +
        'ILAN  desc')
    Left = 36
    Top = 363
  end
  object PopupIletisim: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 729
    Top = 511
    object MenuItem7: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      OnClick = MenuItem7Click
    end
  end
  object TabDokuman: TFDQuery
    BeforeOpen = TabDokumanBeforeOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT DISTINCT D.*,TIP=1,EXT='#39'.'#39'+REVERSE( SUBSTRING(REVERSE(isn' +
        'ull((select Top 1 AD from DOKUMAN I where  I.ID=D.ID order by I.' +
        'ID desc),'#39'.'#39')),1,CHARINDEX('#39'.'#39',REVERSE(isnull((select Top 1 AD f' +
        'rom DOKUMAN I where  I.ID=D.ID order by I.ID desc),'#39'.'#39')),1)-1)) ' +
        ' FROM  DOKUMAN  D INNER JOIN DOKUMANYETKI DY  ON D.ID=DY.YERID W' +
        'HERE D.REHBERID= :PRehberID AND D.KLASOR>0')
    Left = 506
    Top = 4
  end
  object DtsDokuman: TDataSource
    DataSet = TabDokuman
    Left = 569
    Top = 19
  end
  object TabNotlar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select '#9'GY.ID, GY.TUR, GY.TARIH,GY.EKLEMETARIHI, GY.EKLEYEN,'#9'BIL' +
        'GI=(select ANAHTAR from GENINI where BOLUM=-22035 and DEGER=GY.T' +
        'UR)+'#39' / '#39'+ '#9'CONVERT(varchar(11),GY.TARIH,103)+'#39' / '#39'+ R.FIRMA,GY.' +
        'YORUM from '#9'GOREVYORUM GY inner join REHBER R on R.ID=GY.EKLEYEN' +
        ' where '#9'GOREVID = :PId AND TUR between 11 and 13 order by 3 DESC')
    Left = 547
    Top = 353
  end
  object DtsNotlar: TDataSource
    DataSet = TabNotlar
    Left = 628
    Top = 356
  end
  object TabPerIletisim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select * from REHBERILETISIM where REHBERID=:PID')
    Left = 532
    Top = 299
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,TARIH=CONV' +
        'ERT(varchar(20),GY.EKLEMETARIHI,113),YAZAN=R.FIRMA,GY.YORUM,ATAC' +
        '=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),DOKUM' +
        'ANID=D.ID,DOKUMANAD=D.AD from'#9#9'GOREVYORUM GY '#9'left outer join DO' +
        'KUMAN D on D.MODUL=210 and D.MODULID=GY.ID '#9'left outer join REHB' +
        'ER R on R.ID=GY.EKLEYEN where  GY.TUR=:PYer and GOREVID=:PYerId ' +
        'order by 2 DESC')
    Left = 585
    Top = 369
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 608
    Top = 104
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
    Left = 888
    Top = 112
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
    Left = 440
    Top = 364
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
end
