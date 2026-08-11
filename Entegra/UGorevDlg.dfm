object GorevDlg: TGorevDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'G'#246'rev Bilgileri'
  ClientHeight = 629
  ClientWidth = 1092
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 18
  object PanelUst: TPanel
    Left = 0
    Top = 209
    Width = 1092
    Height = 230
    Align = alBottom
    BevelOuter = bvNone
    Color = 14737602
    ParentBackground = False
    TabOrder = 0
    object JvGroupBox2: TJvGroupBox
      Left = 0
      Top = 130
      Width = 1092
      Height = 49
      Align = alTop
      Caption = ''
      Color = 14737602
      ParentBackground = False
      ParentColor = False
      TabOrder = 0
      object ComboILGILI1: TcxButtonEdit
        Left = 417
        Top = 20
        Align = alLeft
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
        Properties.ReadOnly = True
        Properties.OnButtonClick = ComboILGILI1PropertiesButtonClick
        ShowHint = True
        TabOrder = 0
        TextHint = 'MUS_ILGILI'
        OnDblClick = ComboILGILI1DblClick
        Width = 160
      end
      object BEditMusteri: TcxButtonEdit
        Left = 79
        Top = 20
        Align = alLeft
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
        Properties.ReadOnly = True
        Properties.OnButtonClick = BEditMusteriPropertiesButtonClick
        ShowHint = True
        TabOrder = 1
        OnDblClick = BEditMusteriDblClick
        Width = 298
      end
      object LabelREHBERID1: TcxDBLabel
        Left = 321
        Top = 6
        DataBinding.DataField = 'MUSTERIID'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
        Height = 21
        Width = 56
      end
      object cxDBLabel6: TcxDBLabel
        Left = 673
        Top = 6
        DataBinding.DataField = 'MUS_ILGILI'
        DataBinding.DataSource = DtsGorev
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
        Height = 21
        Width = 56
      end
      object Panel6: TPanel
        Left = 577
        Top = 20
        Width = 51
        Height = 27
        Align = alLeft
        BevelOuter = bvNone
        Caption = #304'lgili'
        Color = 14737602
        ParentBackground = False
        TabOrder = 4
      end
      object Panel8: TPanel
        Left = 2
        Top = 20
        Width = 77
        Height = 27
        Align = alLeft
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = '  Cari'
        Color = 14737602
        ParentBackground = False
        TabOrder = 5
      end
      object ComboILGILI2: TcxButtonEdit
        Left = 628
        Top = 20
        Align = alClient
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
        Properties.ReadOnly = True
        Properties.OnButtonClick = ComboILGILI1PropertiesButtonClick
        ShowHint = True
        TabOrder = 6
        TextHint = 'MUS_ILGILI2'
        OnDblClick = ComboILGILI1DblClick
        Width = 462
      end
      object Panel9: TPanel
        Left = 377
        Top = 20
        Width = 40
        Height = 27
        Align = alLeft
        BevelOuter = bvNone
        Caption = #304'lgili'
        Color = 14737602
        ParentBackground = False
        TabOrder = 7
      end
    end
    object JvGroupBox5: TJvGroupBox
      Left = 0
      Top = 49
      Width = 1092
      Height = 81
      Align = alTop
      Caption = ''
      Color = 14737602
      ParentBackground = False
      ParentColor = False
      TabOrder = 1
      object GridAtanan: TcxGrid
        Left = 79
        Top = 20
        Width = 429
        Height = 59
        Align = alLeft
        TabOrder = 0
        object GridAtananView: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsAtanan
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.ScrollBars = ssHorizontal
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 113
          object GridAtananViewRow1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.MaxLength = 200
            Options.Editing = False
            Options.Filtering = False
            Options.FilteringAddValueItems = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            IsCaptionAssigned = True
          end
        end
        object GridAtananLevel1: TcxGridLevel
          GridView = GridAtananView
        end
      end
      object SQLKullan: TMemo
        Left = 85
        Top = 28
        Width = 480
        Height = 33
        Color = 13426846
        Lines.Strings = (
          'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
          
            'G'#246'rev=(select top 1 ANAHTAR from GENINI where BOLUM=-2252 and DE' +
            'GER = '
          'ROL.GOREVID and DIL=-1), '
          
            'Departman=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 an' +
            'd DEGER = '
          'ROL.DEPARTMAN and DIL=-1),'
          #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
          'Kategori='#39'Personel'#39',T'#252'r=1'
          'from REHBER R '
          'inner join KULLANICI K on R.ID=K.REHBERID '
          'left outer join ROLLER ROL on ROL.ID=R.SINIF'
          'where '
          'R.GRUP=335 and R.DURUM>0 and K.DURUM>0 '
          'order by 2'
          '')
        TabOrder = 1
        Visible = False
      end
      object Panel5: TPanel
        Left = 2
        Top = 20
        Width = 77
        Height = 59
        Align = alLeft
        BevelOuter = bvNone
        Color = 14737602
        ParentBackground = False
        TabOrder = 2
        object AtamaTus: TcxButton
          Tag = 11
          Left = 2
          Top = 14
          Width = 30
          Height = 23
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'DevExpressStyle'
          OptionsImage.ImageIndex = 2
          OptionsImage.Images = Tablo.KlasorResimleri
          SpeedButtonOptions.Transparent = True
          TabOrder = 0
          OnClick = AtamaTusClick
        end
        object cxLabel1: TcxLabel
          Left = 10
          Top = -6
          Caption = 'Atanan'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -12
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
        object AtananSilTus: TcxButton
          Left = 36
          Top = 14
          Width = 30
          Height = 23
          LookAndFeel.Kind = lfUltraFlat
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'DevExpressStyle'
          OptionsImage.ImageIndex = 15
          OptionsImage.Images = Tablo.KlasorResimleri
          SpeedButtonOptions.Transparent = True
          TabOrder = 2
          OnClick = AtananSilTusClick
        end
      end
      object Panel2: TPanel
        Left = 508
        Top = 20
        Width = 77
        Height = 59
        Align = alLeft
        BevelOuter = bvNone
        Color = 14737602
        ParentBackground = False
        TabOrder = 3
        object BilgiTus: TcxButton
          Tag = 12
          Left = 4
          Top = 14
          Width = 30
          Height = 23
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'DevExpressStyle'
          OptionsImage.ImageIndex = 2
          OptionsImage.Images = Tablo.KlasorResimleri
          SpeedButtonOptions.Transparent = True
          TabOrder = 0
          OnClick = AtamaTusClick
        end
        object cxLabel3: TcxLabel
          Left = 10
          Top = -6
          Caption = 'Bilgi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -12
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
        object BilgiSilTus: TcxButton
          Left = 36
          Top = 14
          Width = 30
          Height = 23
          LookAndFeel.Kind = lfUltraFlat
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'DevExpressStyle'
          OptionsImage.ImageIndex = 15
          OptionsImage.Images = Tablo.KlasorResimleri
          SpeedButtonOptions.Transparent = True
          TabOrder = 2
          OnClick = BilgiSilTusClick
        end
      end
      object cxGrid2: TcxGrid
        Left = 585
        Top = 20
        Width = 505
        Height = 59
        Align = alClient
        TabOrder = 4
        object GridBilgiView: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsBilgi
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.ScrollBars = ssHorizontal
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 113
          object cxGridDBCardViewRow1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.MaxLength = 200
            Options.Editing = False
            Options.Filtering = False
            Options.FilteringAddValueItems = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            IsCaptionAssigned = True
          end
        end
        object GridBilgi: TcxGridLevel
          GridView = GridBilgiView
        end
      end
    end
    object JvGroupBox7: TJvGroupBox
      Left = 0
      Top = 0
      Width = 1092
      Height = 49
      Align = alTop
      Caption = ''
      Color = 14737602
      ParentBackground = False
      ParentColor = False
      TabOrder = 2
      object DateBASTARIHI: TcxDBDateEdit
        Left = 75
        Top = 17
        DataBinding.DataField = 'BASLAMATARIHI'
        DataBinding.DataSource = DtsGorev
        Properties.ImmediatePost = True
        Properties.Kind = ckDateTime
        Properties.UseLeftAlignmentOnEditing = False
        Properties.OnCloseUp = DateBASTARIHIPropertiesCloseUp
        TabOrder = 0
        Width = 139
      end
      object DateBITTARIHI: TcxDBDateEdit
        Left = 253
        Top = 17
        DataBinding.DataField = 'BITISTARIHI'
        DataBinding.DataSource = DtsGorev
        Properties.ImmediatePost = True
        Properties.Kind = ckDateTime
        TabOrder = 1
        Width = 129
      end
      object cxLabel7: TcxLabel
        Left = 9
        Top = 21
        Caption = 'Ba'#351'lama'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        Transparent = True
      end
      object cxLabel10: TcxLabel
        Left = 220
        Top = 21
        Caption = 'Biti'#351
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 388
        Top = 18
        Caption = 'An'#305'msat'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel9: TcxLabel
        Left = 578
        Top = 19
        Caption = 'Tekrar'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboAnimsatmaZamani: TcxDBImageComboBox
        Left = 437
        Top = 18
        RepositoryItem = Tablo.RepGorevAnimsatOnce
        AutoSize = False
        DataBinding.DataField = 'ANIMSAT'
        DataBinding.DataSource = DtsGorev
        Properties.ImmediatePost = True
        Properties.Items = <>
        TabOrder = 6
        Height = 25
        Width = 132
      end
      object EditTekrar: TcxButtonEdit
        Left = 621
        Top = 16
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
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditTekrarPropertiesButtonClick
        ShowHint = True
        TabOrder = 7
        Width = 147
      end
    end
    object JvGroupBox3: TJvGroupBox
      Left = 0
      Top = 179
      Width = 1092
      Height = 49
      Align = alTop
      Caption = ''
      Color = 14737602
      ParentBackground = False
      ParentColor = False
      TabOrder = 3
      object BeditProje: TcxButtonEdit
        Left = 79
        Top = 20
        Hint = 'Proje ekran'#305'n'#305' a'#231'mak i'#231'in '#231'ift t'#305'klay'#305'n'#305'z.'
        Align = alClient
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
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = BeditProjePropertiesButtonClick
        ShowHint = True
        TabOrder = 0
        OnDblClick = BeditProjeDblClick
        Width = 495
      end
      object PanelEkipman: TPanel
        Left = 574
        Top = 20
        Width = 55
        Height = 27
        Align = alRight
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = '  Ekipman'
        Color = 14737602
        ParentBackground = False
        TabOrder = 1
      end
      object PanelFirsat: TcxLabel
        Left = 2
        Top = 20
        Align = alLeft
        Caption = '  F'#305'rsat/Proje'
      end
      object BEditEkipman: TcxButtonEdit
        Left = 629
        Top = 20
        Align = alRight
        ParentShowHint = False
        Properties.Buttons = <
          item
            Caption = '+'
            Hint = 'Temizle'
            Kind = bkEllipsis
          end
          item
            Caption = '-'
            Kind = bkText
          end>
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = BEditEkipmanPropertiesButtonClick
        ShowHint = True
        TabOrder = 3
        Width = 461
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 135
    Width = 1092
    Height = 0
    Align = alTop
    BevelOuter = bvNone
    Color = clSilver
    ParentBackground = False
    TabOrder = 1
  end
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 439
    Width = 1092
    Height = 190
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = cxTabSheet2
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 186
    ClientRectLeft = 4
    ClientRectRight = 1088
    ClientRectTop = 29
    object cxTabSheet2: TcxTabSheet
      Caption = 'Yorum/Medya'
      ImageIndex = 38
      DesignSize = (
        1084
        157)
      object Panel10: TPanel
        Left = 0
        Top = 96
        Width = 1084
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
          Width = 936
        end
        object BtnMesajGonder: TcxButton
          Left = 937
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
          Left = 1022
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
        Top = 137
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
        AnchorX = 1084
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1084
        Height = 96
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
          object cxGridDBCardViewYORUM: TcxGridDBCardViewRow
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
        object cxGridLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
      object CheckZenginMetin: TcxCheckBox
        Left = 983
        Top = 137
        Anchors = [akTop, akRight]
        Caption = 'Zengin Metin'
        TabOrder = 3
      end
    end
  end
  object PanelNotlar: TJvGroupBox
    Left = 0
    Top = 135
    Width = 1092
    Height = 66
    Align = alClient
    Caption = ''
    Color = 14737602
    ParentBackground = False
    ParentColor = False
    TabOrder = 3
    OnClick = PanelNotClick
    object MemoNOTLAR: TcxDBMemo
      Left = 79
      Top = 20
      Align = alClient
      DataBinding.DataField = 'YORUM'
      DataBinding.DataSource = DtsNotlar
      Properties.ScrollBars = ssVertical
      TabOrder = 0
      Height = 44
      Width = 1011
    end
    object PanelNot: TPanel
      Left = 2
      Top = 20
      Width = 77
      Height = 44
      Align = alLeft
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = '  Notlar'
      Color = 14737602
      ParentBackground = False
      TabOrder = 1
      OnClick = PanelNotClick
    end
  end
  object PanelEnUst: TJvGroupBox
    Left = 0
    Top = 37
    Width = 1092
    Height = 49
    Align = alTop
    Caption = ''
    Color = 14737602
    ParentBackground = False
    ParentColor = False
    TabOrder = 4
    object cxLabel8: TcxLabel
      Left = 756
      Top = 18
      Caption = 'Olu'#351'turma'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel14: TcxLabel
      Tag = -2105
      Left = 561
      Top = 19
      Cursor = crHandPoint
      Hint = 'Aktivite_Durum'
      HelpType = htKeyword
      HelpKeyword = 'AKTIVITELER.DURUM'
      Caption = 'Durum'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = cxLabel14Click
    end
    object CheckBAYRAK: TcxDBCheckBox
      Left = 370
      Top = 21
      AutoSize = False
      DataBinding.DataField = 'BAYRAK'
      DataBinding.DataSource = DtsGorev
      Properties.DisplayChecked = '1'
      Properties.DisplayUnchecked = '0'
      Style.TextColor = clRed
      TabOrder = 3
      Transparent = True
      Height = 19
      Width = 40
    end
    object LabelID: TcxDBLabel
      Left = 1029
      Top = 21
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = DtsGorev
      Transparent = True
      Height = 22
      Width = 51
    end
    object ComboDurum: TcxDBImageComboBox
      Left = 613
      Top = 17
      RepositoryItem = Tablo.RepGorevDurum
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsGorev
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = 'Ba'#351'lama Tarihine G'#246're'
          ImageIndex = 0
          Value = '0'
        end
        item
          Description = 'Biti'#351' Tarihine G'#246're'
          Value = '1'
        end>
      TabOrder = 5
      Width = 140
    end
    object TextOlusturma: TcxTextEdit
      Left = 825
      Top = 17
      ParentColor = True
      Properties.ReadOnly = True
      Style.TransparentBorder = True
      TabOrder = 6
      Width = 198
    end
    object BayrakImage: TcxImage
      Left = 387
      Top = 17
      Picture.Data = {
        0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000010
        0000001008060000001FF3FF610000000467414D410000B18F0BFC6105000000
        1974455874536F6674776172650041646F626520496D616765526561647971C9
        653C000001A749444154384FA5915D28437118C67723379272231F259AA43085
        2D1BE9582B6EA8A5DDD95C88E2D68D26A4E463F9286A73A54871414A4A927041
        ADF90825E66E75A2AC71C1B28BC7DED739673BA7A394A7DE3AFFF73CCFEFFF9E
        F718F03F191850D5390DBFBD05CFD71788C7A2FCE6F5EE1A8FFE19ECB599713E
        3AC86759B287A400264D16BC9973F0D0E744786E9483572E2B5E463CFCBC6D2D
        87B8B28053A1029BA67C2C5616A7003B27F7F0086EC0590D783B10E96AC091A5
        10A2C388CFD632C487DD0CA673C25587E5BC4CDC1EECA700A4DADE008EED8D0A
        E4C2598F504D2E124221433EC67BF8E6B9CA3244231129F50360C8DA6E10A6E6
        010E1024DAEFC0B1AD84CF54743BDD2C86C36497C54B544DE16B72FC8492A3D2
        F7AE9766F3247BC62C04FDF39293C55919C010790A5A26412844CB3A9D9DC0FB
        4D882CB2949C0A402A689F42B7CD858DA20CFE5EFAB51AA56754002A9EC2280C
        617C2CA05A56525A2F97B681CFF81703DAFB037494A5F529A56DB096560F1972
        76F92475541E55E93521BEC4184095263DAF3E80E4F56DFD690ADD66B2780ADA
        038124E9F97E07E848C707C3371A710F1AE7A76D680000000049454E44AE4260
        82}
      Properties.GraphicClassName = 'TdxPNGImage'
      Style.BorderColor = 14737602
      Style.BorderStyle = ebs3D
      Style.Color = 14737602
      Style.Edges = []
      Style.LookAndFeel.NativeStyle = False
      Style.TransparentBorder = True
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      StyleReadOnly.LookAndFeel.NativeStyle = False
      TabOrder = 7
      Transparent = True
      OnClick = BayrakImageClick
      Height = 28
      Width = 28
    end
    object ComboKlasor: TcxDBImageComboBox
      Left = 79
      Top = 20
      RepositoryItem = Tablo.RepIsKlasorListesi
      DataBinding.DataField = 'LISTEID'
      DataBinding.DataSource = DtsGorev
      Properties.ImmediatePost = True
      Properties.Items = <>
      TabOrder = 0
      Width = 252
    end
    object LabelKlasor: TcxLabel
      Tag = -2105
      Left = 5
      Top = 21
      Cursor = crHandPoint
      Hint = 'Aktivite_Durum'
      HelpType = htKeyword
      HelpKeyword = 'AKTIVITELER.DURUM'
      Caption = 'Klas'#246'r'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = cxLabel14Click
    end
    object CheckWhatsapp: TcxDBCheckBox
      Left = 453
      Top = 21
      AutoSize = False
      DataBinding.DataField = 'WHATSAPP'
      DataBinding.DataSource = DtsGorev
      Properties.DisplayChecked = '1'
      Properties.DisplayUnchecked = '0'
      Style.TextColor = clRed
      Style.TransparentBorder = False
      TabOrder = 9
      Transparent = True
      Height = 19
      Width = 40
    end
    object WhatsappImage: TcxImage
      Left = 475
      Top = 17
      Picture.Data = {
        0D546478536D617274496D61676589504E470D0A1A0A0000000D494844520000
        001B00000013080600000061877638000000017352474200AECE1CE900000004
        67414D410000B18F0BFC6105000000097048597300000EC100000EC101B8916B
        ED000002D949444154484BBD944D48545114C7FFEF63667C63A88D68E55762E1
        674225A960B471D146093706818B48B2086A192EA4828842A3850B89420C5A84
        45411A41960BA9458A7D611B45233435D3517368C69979EF76EE7B6F8679CE0C
        3305F57B5CDEBDE7DE77FEF79C7BEE13A667BFB3A2BC6CC4632DE8810411DB64
        051A63F06A9B90050929A2DD5C913C71C5B848BA9C8AD5C04FBC708F62DAFB0D
        2A18F6A4E4E068662D326D69083215364136BF484C4CB1D5E0069C9282CEAFF7
        D13DF7508F26128768435B4E133A0A4F42A0C72E26271825B61EF040911D689E
        E8C0F0CA986114046A4637922319FBF164DF7548945691AF498068BEC3A4C94E
        5CFDD2A70B1D508A71A3E81CEC1A2D63E6820846D63EA07DA627D63E626211F3
        A85E2C0736D033FF18D080DBE51771B6A0090DAEC32416438DE85D18C472708D
        7AB1E723D91219C3D0EA5B6C6A01DD79BEB2836C02AAD3CB8DE918F02219F8F1
        1A6A9CCD446211738A0AA67ECD190351C0D3C5119267E89D1D306C7198F2CE91
        A3A81389C2B282E7DECF282A737069E62E967C6E74959D8743A58A531904953E
        A246972E9C39BEA178698EC422E6D3FC2856F28D0145B6A8B9D1F2E932AAD24B
        F1B2AA1B87524A70ABE802C6ABEFE178667D58A044290013128B594A3FA8A954
        20EBA8183D81000BEA361ECD41AACA3B15EDD89B9A474EE923F23BE19941DD78
        1B6459C6544D3F5C74C98504E56F894C162564DB33D09AD3685A0849C03BDF24
        6AC75AD1F2F10A1ECD0FA37FE1155A3F5FD3537D6A6703B6CB89853851975AD3
        349C99ECC483A521D362C2B3C4D316CA16F9AEC9A8C0606517FD416C4989594B
        889CF9297D832B6F50EADC8DE6AC7AD843FF3EEE8BCE9147CA53773AF7189E55
        DED4E79311E258226324C6FF8B5ED58F5D76976E73D319F62D3EC77BCF24721D
        59284B2D44A3AB2E7C46C90A712C623C859CAD0E34A65160A68D5EBCFF272221
        2C691445BA9AD4423B0E35890A2734270AC6FCDF603DB37FCC7F14037E0329EB
        0753148C90350000000049454E44AE426082}
      Properties.GraphicClassName = 'TdxPNGImage'
      Properties.GraphicTransparency = gtTransparent
      Style.BorderColor = 14737602
      Style.BorderStyle = ebs3D
      Style.Color = 14737602
      Style.Edges = []
      Style.LookAndFeel.NativeStyle = False
      Style.TransparentBorder = True
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      StyleReadOnly.LookAndFeel.NativeStyle = False
      TabOrder = 10
      Transparent = True
      OnClick = WhatsappImageClick
      Height = 28
      Width = 28
    end
  end
  object PanelKonu: TJvGroupBox
    Left = 0
    Top = 86
    Width = 1092
    Height = 49
    Align = alTop
    Caption = ''
    Color = 14737602
    ParentBackground = False
    ParentColor = False
    TabOrder = 5
    object EditKONU: TcxDBComboBox
      Tag = -2122
      Left = 78
      Top = 20
      Hint = 'Gorev_Konusu'
      HelpType = htKeyword
      HelpKeyword = 'GOREVLER.KONUSU'
      Align = alLeft
      DataBinding.DataField = 'KONUSU'
      DataBinding.DataSource = DtsGorev
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -15
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 0
      Width = 482
    end
    object Panel4: TPanel
      Left = 560
      Top = 20
      Width = 50
      Height = 27
      Align = alLeft
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = '  T'#252'r'#252
      Color = 14737602
      ParentBackground = False
      TabOrder = 1
      OnClick = Panel4Click
    end
    object Panel1: TcxLabel
      Left = 2
      Top = 20
      Cursor = crHandPoint
      Hint = 'Gorev_Konusu'
      Align = alLeft
      Caption = ' Konu          '
      FocusControl = EditKONU
      Transparent = True
      OnClick = Panel1Click
    end
    object ComboTURU: TcxDBImageComboBox
      Left = 610
      Top = 20
      Align = alClient
      RepositoryItem = Tablo.RepGorevTuru
      DataBinding.DataField = 'TURU'
      DataBinding.DataSource = DtsGorev
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = 'Ba'#351'lama Tarihine G'#246're'
          ImageIndex = 0
          Value = '0'
        end
        item
          Description = 'Biti'#351' Tarihine G'#246're'
          Value = '1'
        end>
      TabOrder = 3
      Width = 480
    end
  end
  object YorumGenisTus: TcxButton
    Left = 833
    Top = 440
    Width = 30
    Height = 25
    Hint = 'Not alan'#305'n'#305' geni'#351'let/daralt'
    OptionsImage.ImageIndex = 45
    OptionsImage.Images = Tablo.imgScheduler
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = YorumGenisTusClick
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 201
    Width = 1092
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = PanelUst
    Color = clNavy
    ParentColor = False
  end
  object Panel11: TPanel
    Left = 0
    Top = 0
    Width = 1092
    Height = 37
    Align = alTop
    Caption = 'PanelEnUst'
    TabOrder = 8
    object JvNavPanelHeader1: TJvNavPanelHeader
      Left = 1
      Top = 1
      Width = 122
      Height = 35
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object CheckTamam: TcxDBCheckBox
        Left = 1
        Top = 9
        AutoSize = False
        Caption = 'Tamamland'#305
        DataBinding.DataField = 'ACKAPA'
        DataBinding.DataSource = DtsGorev
        Properties.DisplayChecked = '1'
        Properties.DisplayUnchecked = '0'
        Style.TextColor = clGreen
        TabOrder = 0
        Transparent = True
        Height = 19
        Width = 119
      end
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 126
      Top = 4
      Width = 962
      Margins.Bottom = 0
      Align = alClient
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 107
      Caption = 'AletCubugu'
      Color = clBlue
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
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      object YaziciYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        ImageName = 'PngImage15'
        Style = tbsTextButton
      end
      object ToolButton5: TToolButton
        Left = 107
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
        Visible = False
      end
      object IsOlusturTus: TToolButton
        Left = 115
        Top = 0
        Caption = 'Ba'#287'l'#305' '#304#351' Olu'#351'tur'
        ImageIndex = 7
        ImageName = 'PngImage6'
        Visible = False
        OnClick = IsOlusturTusClick
      end
      object ToolButton3: TToolButton
        Left = 222
        Top = 0
        Width = 21
        Caption = '2'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
        Visible = False
      end
      object ToolButton6: TToolButton
        Left = 243
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
      end
      object OnaylaTus: TToolButton
        Left = 251
        Top = 0
        Caption = 'Onayla'
        ImageIndex = 11
        ImageName = 'PngImage10'
        OnClick = OnaylaTusClick
      end
      object ReddetTus: TToolButton
        Left = 358
        Top = 0
        Caption = 'Reddet'
        ImageIndex = 31
        ImageName = 'PngImage31'
      end
      object ToolButton8: TToolButton
        Left = 465
        Top = 0
        Width = 11
        Caption = 'ToolButton8'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
      end
      object KaydetTus: TToolButton
        Left = 476
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 10
        ImageName = 'PngImage9'
        OnClick = KaydetTusClick
      end
      object ToolButton4: TToolButton
        Left = 583
        Top = 0
        Width = 14
        Caption = 'ToolButton4'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
      end
      object ToolButton2: TToolButton
        Left = 597
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        ImageName = 'PngImage17'
        OnClick = ToolButton2Click
      end
    end
  end
  object TabGorev: TFDQuery
    BeforePost = TabGorevBeforePost
    AfterPost = TabGorevAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'G.*,'
      #9'OLUSTURAN=(select FIRMA from REHBER R where R.ID=G.EKLEYEN)'
      'FROM '
      #9'GOREVLER G'
      'WHERE '
      #9'G.ID = :PID')
    Left = 57
    Top = 230
  end
  object DtsGorev: TDataSource
    DataSet = TabGorev
    OnStateChange = DtsGorevStateChange
    Left = 49
    Top = 361
  end
  object frxGorevler: TfrxDBDataset
    UserName = 'Gorevler'
    CloseDataSource = False
    DataSet = ISGOREV
    BCDToCurrency = False
    DataSetOptions = []
    Left = 247
    Top = 166
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 459
    Top = 277
  end
  object TabAtanan: TFDQuery
    AfterOpen = TabAtananAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select GK.*, AD=(select FIRMA from REHBER R where R.ID=GK.REHBER' +
        'ID)'
      'from '
      #9'GOREVKULLANICI GK'
      'where'
      'TUR=11 and [LISTGOREVID]=:PID')
    Left = 513
    Top = 372
  end
  object DtsAtanan: TDataSource
    DataSet = TabAtanan
    Left = 519
    Top = 419
  end
  object DtsNotlar: TDataSource
    DataSet = TabNotlar
    OnStateChange = DtsGorevStateChange
    Left = 145
    Top = 361
  end
  object TabNotlar: TFDQuery
    BeforePost = TabNotlarBeforePost
    OnNewRecord = TabNotlarNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *'
      'from '
      #9'GOREVYORUM'
      'where '
      #9'GOREVID=:PId '
      'AND TUR=1'
      'order by ID')
    Left = 145
    Top = 302
  end
  object TabBilgi: TFDQuery
    AfterOpen = TabAtananAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select GK.*, AD=(select FIRMA from REHBER R where R.ID=GK.REHBER' +
        'ID)'
      'from '
      #9'GOREVKULLANICI GK'
      'where'
      'TUR=12 and [LISTGOREVID]=:PID')
    Left = 625
    Top = 308
  end
  object DtsBilgi: TDataSource
    DataSet = TabBilgi
    Left = 679
    Top = 427
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 419
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 229
    Top = 488
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 37
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 43
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
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
    Left = 421
    Top = 361
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
    Left = 365
    Top = 488
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 181
    Top = 34
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YaziciyaYazdirMenu: TMenuItem
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object ISGOREV: TFDQuery
    BeforePost = TabGorevBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      'G.ID, '
      
        'LISTEID=case when G.LISTEID=0 then (select ID from PROJELER P wh' +
        'ere P.ID=G.PROJEID) else G.LISTEID end, '
      
        'LISTEADI=case when G.LISTEID=0 then (select P.PROJEKODU from PRO' +
        'JELER P where P.ID=G.PROJEID)'
      
        '   else (SELECT TOP 1 GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LI' +
        'STEID ) end,'
      'G.KONUSU,G.DURUM,'
      
        'TURU=(SELECT top 1 ANAHTAR FROM GENINI where BOLUM=-21044 and DI' +
        'L=-1 and DEGER=G.TURU),'
      
        'G.REHBERID,CARIAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.REHBE' +
        'RID),G.MUS_ILGILI,'
      
        'ILGILI1_AD=(select top 1 FIRMA from REHBER ILG1 where ILG1.ID=G.' +
        'MUS_ILGILI),'
      
        'ILGILI2_AD=(select top 1 FIRMA from REHBER ILG2 where ILG2.ID=G.' +
        'MUS_ILGILI2),'
      'ATANAN1=(SELECT [dbo].[fn_GorevVerilenKisiler](11,G.ID)),'
      'G.BASLAMATARIHI,G.BITISTARIHI,TEKRARID,'
      
        'TEKRAR_BIT=convert(bit, (CASE WHEN TEKRARID>0 THEN 1 ELSE 0 END)' +
        '),'
      
        'ANIMSAT_BIT=convert(bit, (CASE WHEN ANIMSAT>0 THEN 1 ELSE 0 END)' +
        '),'
      
        'ZINCIR_BIT=convert(bit, (CASE WHEN BAGIDUST>0 or BAGIDALT>0 THEN' +
        ' 1 ELSE 0 END)),'
      
        'NOTLAR_BIT=convert(bit, (CASE WHEN EXISTS(SELECT ID FROM GOREVYO' +
        'RUM WHERE GOREVID=G.ID AND TUR=1) THEN 1 ELSE 0 END)),'
      
        'YORUM_BIT=convert(bit, (CASE WHEN EXISTS(SELECT ID FROM GOREVYOR' +
        'UM WHERE GOREVID=G.ID AND TUR=33) THEN 1 ELSE 0 END)),'
      'G.BAGIDUST,G.BAGIDALT,'
      'G.BAYRAK,G.ACKAPA,'
      'G.EKLEYEN,G.EKLEMETARIHI,'
      
        'NOTLAR = (select YORUM from GOREVYORUM where GOREVID=G.ID AND TU' +
        'R=1),'
      
        'PROJEKODU=(SELECT PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID' +
        '),'
      
        'PROJEADI=(SELECT PROJEADI FROM PROJELER P2 WHERE P2.ID=G.PROJEID' +
        '),'
      'EKLEYENAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN)'
      'from '
      '       GOREVLER G'
      'WHERE '
      #9'G.ID = :PID')
    Left = 161
    Top = 230
  end
  object frxYorumlar: TfrxDBDataset
    UserName = 'Yorumlar'
    CloseDataSource = False
    DataSet = TabYorum
    BCDToCurrency = False
    DataSetOptions = []
    Left = 359
    Top = 158
  end
  object frxAtananlar: TfrxDBDataset
    UserName = 'Atananlar'
    CloseDataSource = False
    DataSet = TabAtanan
    BCDToCurrency = False
    DataSetOptions = []
    Left = 463
    Top = 166
  end
end
