object KaliteToplantiDlg: TKaliteToplantiDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Toplanti Bilgileri'
  ClientHeight = 579
  ClientWidth = 1001
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 995
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
    object YaziciYaz: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      PopupMenu = AnaForm.PopupMDI
    end
    object ToolButton1: TToolButton
      Left = 70
      Top = 0
      Width = 482
      Caption = 'ToolButton1'
      ImageIndex = 17
      Style = tbsSeparator
    end
    object YeniTus: TToolButton
      Left = 552
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      OnClick = YeniTusClick
    end
    object IptalTus: TToolButton
      Left = 622
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = IptalTusClick
    end
  end
  object PanelNotlar: TJvGroupBox
    Left = 0
    Top = 81
    Width = 1001
    Height = 120
    Align = alTop
    Caption = ''
    Color = 14737602
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    object Label3: TcxLabel
      Left = 16
      Top = 24
      Caption = 'Toplant'#305' No'
      ParentFont = False
    end
    object Label4: TcxLabel
      Left = 383
      Top = 22
      Caption = 'Toplant'#305' Durum'
      ParentFont = False
    end
    object Label5: TcxLabel
      Left = 16
      Top = 54
      Caption = 'Toplant'#305' Tarihi '
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object Label6: TcxLabel
      Left = 16
      Top = 83
      Caption = 'Toplant'#305' Yeri'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object Label7: TcxLabel
      Left = 383
      Top = 46
      Caption = 'Ba'#351'lama/Biti'#351' Saati'
      ParentFont = False
    end
    object Label13: TcxLabel
      Left = 383
      Top = 69
      Caption = 'Kurum'
      ParentFont = False
    end
    object Label1: TcxLabel
      Left = 383
      Top = 93
      Caption = 'Proje'
      ParentFont = False
    end
    object EditRaporNo: TcxDBTextEdit
      Left = 166
      Top = 21
      DataBinding.DataField = 'TOPLANTINO'
      DataBinding.DataSource = DtsToplanti
      TabOrder = 0
      Width = 121
    end
    object EditToplantiYeri: TcxDBTextEdit
      Left = 166
      Top = 80
      DataBinding.DataField = 'TOPLANTIYERI'
      DataBinding.DataSource = DtsToplanti
      TabOrder = 2
      Width = 121
    end
    object EditToplantiTarihi: TcxDBDateEdit
      Left = 166
      Top = 51
      DataBinding.DataField = 'BASLAMATARIH'
      DataBinding.DataSource = DtsToplanti
      Properties.ImmediatePost = True
      Properties.ShowTime = False
      TabOrder = 1
      Width = 121
    end
    object EditBaslamaSaati: TcxDBTimeEdit
      Left = 510
      Top = 43
      DataBinding.DataField = 'BASLAMATARIH'
      DataBinding.DataSource = DtsToplanti
      TabOrder = 4
      Width = 65
    end
    object EditBitisSaati: TcxDBTimeEdit
      Left = 579
      Top = 43
      DataBinding.DataField = 'BITISTARIH'
      DataBinding.DataSource = DtsToplanti
      TabOrder = 5
      Width = 65
    end
    object ComboDurum: TcxDBImageComboBox
      Left = 510
      Top = 20
      RepositoryItem = Tablo.RepKaliteToplantiDurum
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsToplanti
      Properties.Items = <
        item
          Description = 'Plan'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Ertelendi'
          Value = 2
        end
        item
          Description = #304'ptal'
          Value = 3
        end
        item
          Description = 'Yap'#305'ld'#305
          Value = 4
        end>
      TabOrder = 3
      Width = 131
    end
    object MemoEPosta: TMemo
      Left = 834
      Top = 21
      Width = 185
      Height = 89
      TabOrder = 8
      Visible = False
    end
    object BEditMusteri: TcxButtonEdit
      Left = 510
      Top = 66
      Align = alCustom
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
      TabOrder = 6
      Width = 275
    end
    object BeditProje: TcxButtonEdit
      Left = 510
      Top = 93
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
      Width = 275
    end
  end
  object PanelKonu: TJvGroupBox
    Left = 0
    Top = 35
    Width = 1001
    Height = 46
    Align = alTop
    Caption = ''
    Color = 14737602
    ParentBackground = False
    ParentColor = False
    TabOrder = 2
    object EditKONU: TcxDBTextEdit
      Left = 169
      Top = 15
      Align = alClient
      DataBinding.DataField = 'ADI'
      DataBinding.DataSource = DtsToplanti
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -15
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 0
      Width = 830
    end
    object Panel1: TPanel
      Left = 2
      Top = 15
      Width = 167
      Height = 29
      Align = alLeft
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = '    Toplant'#305' Konusu'
      Color = 14737602
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 201
    Width = 1001
    Height = 378
    Align = alClient
    TabOrder = 3
    Properties.ActivePage = TabSheetKatilimci
    Properties.CustomButtons.Buttons = <>
    Properties.Images = Tablo.KlasorResimleri
    ClientRectBottom = 374
    ClientRectLeft = 4
    ClientRectRight = 997
    ClientRectTop = 25
    object TabSheetKarar: TcxTabSheet
      Caption = 'Kararlar'
      ImageIndex = 27
      object GridKarar: TcxGrid
        Left = 0
        Top = 27
        Width = 993
        Height = 322
        Align = alClient
        TabOrder = 0
        object GridKararDBCardView1: TcxGridDBCardView
          OnDblClick = KararDuzenleClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKarar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsView.ScrollBars = ssVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 760
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          RowLayout = rlVertical
          object GridKararDBCardView1BILGI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Styles.Content = Tablo.cxStyle4
            Styles.CategoryRow = Tablo.cxStyle4
          end
          object GridKararDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxRichEditProperties'
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Styles.Content = Tablo.cxStyle12
            Styles.CategoryRow = Tablo.cxStyle4
          end
        end
        object GridKararLevel1: TcxGridLevel
          GridView = GridKararDBCardView1
        end
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 987
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 69
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
        object KararEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          DropdownMenu = PopupMenuEkle
          ImageIndex = 4
          Style = tbsTextButton
          OnClick = KararEkleTusClick
        end
        object KararSil: TToolButton
          Left = 69
          Top = 0
          Caption = 'Sil'
          ImageIndex = 5
          Style = tbsTextButton
        end
        object KararDuzenle: TToolButton
          Tag = 3
          Left = 138
          Top = 0
          Caption = ' D'#252'zenle'
          ImageIndex = 7
          Style = tbsTextButton
          OnClick = KararDuzenleClick
        end
      end
    end
    object SheetYorum: TcxTabSheet
      Caption = 'Yorum/Medya'
      ImageIndex = 1
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 993
        Height = 288
        Align = alClient
        TabOrder = 0
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
      object Panel4: TPanel
        Left = 0
        Top = 308
        Width = 993
        Height = 41
        Align = alBottom
        TabOrder = 1
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 39
          Width = 845
        end
        object BtnMesajGonder: TcxButton
          Left = 846
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
          Left = 931
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
        Top = 288
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
        AnchorX = 993
      end
    end
    object TabSheetGundem: TcxTabSheet
      Caption = 'G'#252'ndem'
      ImageIndex = 20
      object MemoNOTLAR: TcxDBMemo
        Left = 0
        Top = 0
        Align = alClient
        DataBinding.DataField = 'GUNDEM'
        DataBinding.DataSource = DtsToplanti
        Properties.ScrollBars = ssVertical
        TabOrder = 0
        Height = 349
        Width = 993
      end
    end
    object TabSheetKatilimci: TcxTabSheet
      Caption = 'Kat'#305'l'#305'mc'#305'lar'
      ImageIndex = 24
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 987
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 87
        Caption = 
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
          'aaa'
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
        ParentShowHint = False
        ShowCaptions = True
        ShowHint = False
        TabOrder = 0
        Transparent = True
        object IcEkle: TToolButton
          Tag = 335
          Left = 0
          Top = 0
          Caption = #304#231' Kat'#305'l'#305'mc'#305
          ImageIndex = 0
          OnClick = IcEkleClick
        end
        object DisEkle: TToolButton
          Tag = -1
          Left = 87
          Top = 0
          Caption = 'D'#305#351' Kat'#305'l'#305'mc'#305
          ImageIndex = 0
          OnClick = DisEkleClick
        end
        object DuzenleTus: TToolButton
          Left = 174
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          OnClick = DuzenleTusClick
        end
        object SatirSil: TToolButton
          Left = 261
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SatirSilClick
        end
        object ToolButton4: TToolButton
          Left = 348
          Top = 0
          Width = 8
          Caption = 'ToolButton4'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object EPostaTus: TToolButton
          Left = 356
          Top = 0
          Caption = 'E-Posta'
          ImageIndex = 18
          OnClick = EPostaTusClick
        end
      end
      object cxGridKatilim: TcxGrid
        Left = 0
        Top = 27
        Width = 993
        Height = 322
        Align = alClient
        PopupMenu = PopupMenuSecim
        TabOrder = 1
        object cxGridKatilimDBTableView1: TcxGridDBTableView
          PopupMenu = PopupMenuSecim
          OnDblClick = DuzenleTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsKatilimci
          DataController.KeyFieldNames = 'ID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGridKatilimDBTableViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridKatilimDBTableViewSEC: TcxGridDBColumn
            Caption = 'Se'#231
            DataBinding.ValueType = 'Boolean'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.DisplayGrayed = 'False'
            Properties.ImmediatePost = True
            Properties.NullStyle = nssUnchecked
            Properties.ValueGrayed = 'False'
            Width = 23
          end
          object cxGridKatilimDBTableViewPERSONEL: TcxGridDBColumn
            Caption = 'Kat'#305'l'#305'mc'#305
            DataBinding.FieldName = 'PERSONEL'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 196
          end
          object cxGridKatilimDBTableViewFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Width = 206
          end
          object cxGridKatilimDBTableViewKATILDI: TcxGridDBColumn
            Caption = 'Kat'#305'ld'#305
            DataBinding.ValueType = 'Boolean'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.DisplayGrayed = 'False'
            Properties.ImmediatePost = True
            Properties.NullStyle = nssUnchecked
            Width = 77
          end
          object cxGridKatilimDBTableViewSEC2: TcxGridDBColumn
            DataBinding.FieldName = 'SEC'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridKatilimDBTableViewKATILDI2: TcxGridDBColumn
            DataBinding.FieldName = 'KATILDI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object cxGridKatilimLevel1: TcxGridLevel
          GridView = cxGridKatilimDBTableView1
        end
      end
      object SQLKullan: TMemo
        Left = 91
        Top = 92
        Width = 480
        Height = 33
        Color = 13426846
        Lines.Strings = (
          ''
          'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
          'G'#246'rev=(select ANAHTAR from GENINI where BOLUM=-2252 and DEGER = '
          'ROL.GOREVID), '
          
            'Departman=(select ANAHTAR from GENINI where BOLUM=-2251 and DEGE' +
            'R = '
          'ROL.DEPARTMAN),'
          #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
          'Kategori='#39'Personel'#39',T'#252'r=1'
          'from REHBER R '
          'inner join KULLANICI K on R.ID=K.REHBERID '
          'left outer join ROLLER ROL on ROL.ID=R.SINIF'
          'where '
          'R.GRUP=335 and R.DURUM=1 '
          'order by 2'
          '')
        TabOrder = 2
        Visible = False
      end
    end
  end
  object TabToplanti: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabToplantiBeforePost
    AfterPost = TabToplantiAfterPost
    OnNewRecord = TabToplantiNewRecord
    ParamData = <>
    SQL.Strings = (
      'select '
      #9'*'
      'from '
      #9'KALITETOPLANTI KT'
      'where'#9'      '
      #9'ID=:PToplantiId'
      ' ')
    Left = 710
    Top = 231
  end
  object DtsToplanti: TDataSource
    DataSet = TabToplanti
    Left = 776
    Top = 314
  end
  object PopupMenuSecim: TPopupMenu
    Left = 545
    Top = 205
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
    end
    object mnKaldr1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
    end
    object SeimiTersevir1: TMenuItem
      Caption = 'Se'#231'imi Ters '#199'evir'
    end
  end
  object DtsKatilimci: TDataSource
    DataSet = TabKatilimci
    Left = 358
    Top = 479
  end
  object frxToplanti: TfrxDBDataset
    UserName = 'Toplanti'
    CloseDataSource = False
    DataSource = DtsToplanti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 320
    Top = 126
  end
  object frxKatilimci: TfrxDBDataset
    UserName = 'Katilimci'
    CloseDataSource = False
    DataSource = DtsKatilimci
    BCDToCurrency = False
    DataSetOptions = []
    Left = 280
    Top = 544
  end
  object PopupMenuYaz: TPopupMenu
    Left = 349
    Top = 261
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
  object TabKatilimci: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabKatilimciAfterOpen
    ParamData = <>
    SQL.Strings = (
      'DECLARE @ID INT'
      'SET @ID=:PID'
      ''
      'select * from('
      '--D'#305#351' Kat'#305'l'#305'm'
      
        'select K.ID,REHID,FIRMA'#9'=(SELECT FIRMA FROM REHBER WHERE ID=K.RE' +
        'HID ),'
      #9'PERID,PERSONEL'#9'=(SELECT FIRMA FROM REHBER WHERE ID=K.PERID )'
      ',K.KATILDI,K.SEC'
      'from KALITEKULLANICI K'
      'where '
      'YER=450 '
      ' and YERID=@ID '
      ' AND REHID>0 '
      'UNION ALL'
      '--'#304#231' Kat'#305'l'#305'm'
      'SELECT '
      #9'K.ID,REHID,FIRMA='#39#39','
      #9'PERID,PERSONEL=R.FIRMA ,K.KATILDI,K.SEC'
      
        'FROM KALITEKULLANICI K INNER JOIN REHBER R ON K.PERID=R.ID AND K' +
        '.REHID<0'
      'where'
      'YER=450'#9
      ' and YERID=@ID  '
      ' AND REHID<0 '
      ' )as sorgu'
      ' order by 3,5')
    Left = 542
    Top = 407
  end
  object TabKarar: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabKararAfterScroll
    ParamData = <>
    SQL.Strings = (
      'declare @PId1  int;'
      'set @PId1= :ID1'
      ''
      'declare @PId2  int;'
      'set @PId2= :ID2'
      ''
      
        'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI,TUR=1, BILGI='#39'Karar '#39',' +
        'GY.YORUM'
      'from '
      #9'GOREVYORUM GY inner join REHBER R on R.ID=GY.EKLEYEN'
      'where '
      #9'GOREVID = @PId2 '
      'AND TUR=22'
      ''
      'union all'
      ''
      
        'select G.ID, GOREVID=G.ID, G.EKLEMETARIHI,TUR=2,BILGI='#39'G'#246'rev '#39'+i' +
        'snull(CONVERT(varchar(20),G.BITISTARIHI,113),'#39#39')+'#39' '#39'+ isnull(R.F' +
        'IRMA,'#39#39'), '
      'YORUM = G.KONUSU'
      ' from GOREVLER G '
      
        ' left join GOREVKULLANICI GK on G.ID=GK.LISTGOREVID and GK.TUR=1' +
        '1'
      ' left join REHBER R on R.ID=GK.REHBERID'
      'where'
      'G.YER=450 and G.YER_ID = @PId2'
      'order by 2 DESC')
    Left = 371
    Top = 289
  end
  object DtsKarar: TDataSource
    DataSet = TabKarar
    Left = 392
    Top = 342
  end
  object PopupMenuEkle: TPopupMenu
    Left = 105
    Top = 277
    object MenuItemKarar: TMenuItem
      Caption = 'Karar'
      OnClick = MenuItemKararClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MenuItemGorev: TMenuItem
      Caption = 'G'#246'rev'
      OnClick = MenuItemGorevClick
    end
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 640
    Top = 412
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
    Top = 353
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 928
    Top = 232
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
    Left = 856
    Top = 360
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
    Left = 920
    Top = 284
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
