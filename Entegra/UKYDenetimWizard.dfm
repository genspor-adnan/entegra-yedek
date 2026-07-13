object KYDenetimWizardDlg: TKYDenetimWizardDlg
  Left = 0
  Top = 0
  ActiveControl = editKALITENO
  BorderIcons = [biSystemMenu]
  Caption = 'Denetim Olu'#351'turma Sihirbaz'#305
  ClientHeight = 588
  ClientWidth = 847
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
    Width = 847
    Height = 588
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
      847
      588)
    object PageDOF: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Denetim Faaliyeti Bilgileri'
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
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGroupBox1: TcxGroupBox
        Left = 0
        Top = 70
        Align = alTop
        Caption = 'Denetim Faaliyet '#304'ste'#287'ini Talep Eden'
        PanelStyle.OfficeBackgroundKind = pobkGradient
        Style.LookAndFeel.Kind = lfStandard
        Style.LookAndFeel.NativeStyle = False
        Style.LookAndFeel.SkinName = 'LondonLiquidSky'
        StyleDisabled.LookAndFeel.Kind = lfStandard
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
        TabOrder = 0
        ExplicitWidth = 624
        Height = 171
        Width = 847
        object ComboTipi: TcxDBImageComboBox
          Left = 125
          Top = 90
          RepositoryItem = Tablo.RepKYDenetimTipi
          DataBinding.DataField = 'TIPI'
          DataBinding.DataSource = DtsDenetim
          Properties.Items = <>
          Properties.OnChange = ComboFaaliyetPropertiesChange
          TabOrder = 6
          Width = 205
        end
        object cxLabel1: TcxLabel
          Left = 12
          Top = 91
          Caption = 'Tipi'
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 12
          Top = 45
          Caption = 'Durum'
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 12
          Top = 20
          Caption = 'Denetim No/Tarih'
          Style.TextColor = clRed
          Transparent = True
        end
        object editKALITENO: TcxDBTextEdit
          Left = 125
          Top = 21
          DataBinding.DataField = 'DENETIMNO'
          DataBinding.DataSource = DtsDenetim
          TabOrder = 0
          Width = 88
        end
        object cxLabel8: TcxLabel
          Left = 12
          Top = 139
          Caption = 'Talep Eden'
          Style.TextColor = clRed
          Transparent = True
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 125
          Top = 44
          RepositoryItem = Tablo.RepKYDenetimDurum
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsDenetim
          Properties.ImmediatePost = True
          Properties.Items = <>
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 5
          Width = 202
        end
        object EditTalepEden: TcxButtonEdit
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
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditTalepEdenPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 8
          Width = 205
        end
        object DateTarih: TcxDBDateEdit
          Left = 214
          Top = 21
          DataBinding.DataField = 'TARIH'
          DataBinding.DataSource = DtsDenetim
          TabOrder = 1
          Width = 113
        end
        object ComboKATEGORI: TcxDBImageComboBox
          Left = 125
          Top = 67
          RepositoryItem = Tablo.RepKYDenetimKategori
          DataBinding.DataField = 'KATEGORI'
          DataBinding.DataSource = DtsDenetim
          Properties.ImmediatePost = True
          Properties.Items = <>
          StyleDisabled.Color = clWindow
          StyleDisabled.TextColor = clWindowText
          TabOrder = 2
          Width = 202
        end
        object LabelKategori: TcxLabel
          Left = 12
          Top = 68
          Cursor = crHandPoint
          Caption = 'Kategori'
          Transparent = True
          OnClick = LabelKategoriClick
        end
        object EditADI: TcxDBTextEdit
          Left = 446
          Top = 20
          DataBinding.DataField = 'ADI'
          DataBinding.DataSource = DtsDenetim
          TabOrder = 3
          Width = 372
        end
        object cxLabel12: TcxLabel
          Left = 363
          Top = 46
          Caption = 'Konusu'
          Transparent = True
        end
        object MemoKONUSU: TcxDBMemo
          Left = 448
          Top = 44
          Align = alCustom
          DataBinding.DataField = 'KONUSU'
          DataBinding.DataSource = DtsDenetim
          Properties.ScrollBars = ssVertical
          TabOrder = 4
          Height = 117
          Width = 371
        end
        object cxLabel13: TcxLabel
          Left = 363
          Top = 22
          Caption = 'Denetim Ad'#305
          Style.TextColor = clRed
        end
        object BeditProje: TcxButtonEdit
          Left = 125
          Top = 113
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
          TabOrder = 7
          Width = 205
        end
        object cxLabel7: TcxLabel
          Left = 12
          Top = 116
          Caption = 'Proje'
          Transparent = True
        end
      end
      object cxGroupBox2: TcxGroupBox
        Left = 0
        Top = 241
        Align = alTop
        Caption = 'Denetim Faaliyeti'
        TabOrder = 1
        Height = 92
        Width = 847
        object cxLabel11: TcxLabel
          Left = 355
          Top = 30
          Caption = 'Sorumlu Ki'#351'i'
          Transparent = True
        end
        object EditSorumlu: TcxButtonEdit
          Left = 446
          Top = 29
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
          Properties.OnButtonClick = EditSorumluPropertiesButtonClick
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 0
          Width = 146
        end
        object cxLabel5: TcxLabel
          Left = 355
          Top = 57
          Caption = 'Sorumlu B'#246'l'#252'm'
          Transparent = True
        end
        object DateBASLAMATARIHI: TcxDBDateEdit
          Left = 675
          Top = 29
          DataBinding.DataField = 'BASLAMATARIHI'
          DataBinding.DataSource = DtsDenetim
          TabOrder = 2
          Width = 147
        end
        object cxLabel3: TcxLabel
          Left = 597
          Top = 30
          Caption = 'Ba'#351'lama Tarihi'
          Transparent = True
        end
        object cxLabel15: TcxLabel
          Left = 595
          Top = 57
          Caption = 'Biti'#351' Tarihi'
          Transparent = True
        end
        object DateBITISTARIHI: TcxDBDateEdit
          Left = 675
          Top = 53
          DataBinding.DataField = 'BITISTARIHI'
          DataBinding.DataSource = DtsDenetim
          TabOrder = 3
          Width = 147
        end
        object EditDepartman: TcxButtonEdit
          Left = 446
          Top = 56
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
          TabOrder = 1
          Width = 146
        end
        object LabelKurum: TcxLabel
          Left = 10
          Top = 30
          Caption = 'Denetleyen Kurum'
          Transparent = True
        end
        object ComboKurum: TcxButtonEdit
          Left = 127
          Top = 29
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
          TabOrder = 9
          Width = 204
        end
        object cxLabel9: TcxLabel
          Left = 10
          Top = 57
          Caption = 'Denet'#231'i'
          Transparent = True
        end
        object EditDenetci: TcxButtonEdit
          Tag = 1
          Left = 126
          Top = 56
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
          Properties.MaxLength = 0
          Properties.OnButtonClick = EditDenetciPropertiesButtonClick
          ShowHint = True
          TabOrder = 11
          TextHint = 'DENETCI'
          Width = 205
        end
      end
      object cxGroupBox3: TcxGroupBox
        Left = 0
        Top = 333
        Align = alClient
        Caption = 'Denetim Faaliyeti Sonucu'
        TabOrder = 2
        Height = 213
        Width = 847
        object PageControl1: TcxPageControl
          Left = 2
          Top = 18
          Width = 843
          Height = 193
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = TabSheetSonuc
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 189
          ClientRectLeft = 4
          ClientRectRight = 839
          ClientRectTop = 24
          object TabSheetSonuc: TcxTabSheet
            Caption = '   Sonu'#231'   '
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object MemoSONUC: TcxDBMemo
              Left = 0
              Top = 0
              Align = alClient
              DataBinding.DataField = 'SONUC'
              DataBinding.DataSource = DtsDenetim
              Properties.ScrollBars = ssVertical
              TabOrder = 0
              Height = 165
              Width = 835
            end
          end
          object TabSheetDOF: TcxTabSheet
            Caption = 'A'#231#305'lan D'#214'F'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object Panel9: TPanel
              Left = 0
              Top = 0
              Width = 835
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
                Width = 627
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
              Width = 835
              Height = 141
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
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object Panel4: TPanel
              Left = 0
              Top = 124
              Width = 835
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
                Width = 687
              end
              object BtnMesajGonder: TcxButton
                Left = 688
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
                Left = 773
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
              Top = 104
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
              ExplicitTop = 103
              AnchorX = 835
            end
            object GridYorum: TcxGrid
              Left = 0
              Top = 0
              Width = 835
              Height = 104
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
        end
      end
    end
  end
  object TabDenetim: TFDQuery
    OnNewRecord = TabDenetimNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from KALITEDENETIM'
      'Where ID=:ID')
    Left = 437
    Top = 14
  end
  object DtsDenetim: TDataSource
    DataSet = TabDenetim
    Left = 439
    Top = 62
  end
  object OpenDialog1: TOpenDialog
    Left = 652
    Top = 44
  end
  object TabDOF: TFDQuery
    Connection = Tablo.FDCnn
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
      'YER=451'
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
    Left = 495
    Top = 434
  end
  object TabIlgili: TFDQuery
    Connection = Tablo.FDCnn
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
    Left = 449
    Top = 406
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
    Left = 708
    Top = 396
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
    Left = 392
    Top = 313
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 392
    Top = 372
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
end
