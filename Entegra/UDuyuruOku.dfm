object DuyuruOkuDlg: TDuyuruOkuDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Duyuru'
  ClientHeight = 612
  ClientWidth = 1225
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelAlt: TPanel
    Left = 0
    Top = 583
    Width = 1225
    Height = 29
    Align = alBottom
    TabOrder = 0
    object CancelBtn: TBitBtn
      Left = 1152
      Top = 1
      Width = 72
      Height = 27
      Align = alRight
      Cancel = True
      Caption = #304'ptal'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000220B0000220B000000010000000100000031DE000031
        E7000031EF000031F700FF00FF000031FF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00040404040404
        0404040404040404000004000004040404040404040404000004040000000404
        0404040404040000040404000000000404040404040000040404040402000000
        0404040400000404040404040404000000040000000404040404040404040400
        0101010004040404040404040404040401010204040404040404040404040400
        0201020304040404040404040404030201040403030404040404040404050203
        0404040405030404040404040303050404040404040303040404040303030404
        0404040404040403040403030304040404040404040404040404030304040404
        0404040404040404040404040404040404040404040404040404}
      Margin = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      Visible = False
      OnClick = CancelBtnClick
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 1079
      Top = 1
      Width = 73
      Height = 27
      Align = alRight
      Caption = 'Tamam'
      Default = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000D30E0000D30E00000001000000010000008C00000094
        0000009C000000A5000000940800009C100000AD100000AD180000AD210000B5
        210000BD210018B5290000C62900319C310000CE310029AD390031B5420018C6
        420000D6420052A54A0029AD4A0029CE5A006BB5630000FF63008CBD7B00A5C6
        94005AE7A500FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001B1B1B1B1B13
        04161B1B1B1B1B1B1B1B1B1B1B1B1B0B0A01181B1B1B1B1B1B1B1B1B1B1B160A
        0C030D1B1B1B1B1B1B1B1B1B1B1B050E0C0601191B1B1B1B1B1B1B1B1B130E0C
        170E02001B1B1B1B1B1B1B1B1B0B1517170A0C01181B1B1B1B1B1B1B1B111717
        13130C030D1B1B1B1B1B1B1B1B1B08081B1B070C01191B1B1B1B1B1B1B1B1B1B
        1B1B100C02001B1B1B1B1B1B1B1B1B1B1B1B1B090C01181B1B1B1B1B1B1B1B1B
        1B1B1B130C0F101B1B1B1B1B1B1B1B1B1B1B1B1B141A0F181B1B1B1B1B1B1B1B
        1B1B1B1B1012181B1B1B1B1B1B1B1B1B1B1B1B1B1B191B1B1B1B1B1B1B1B1B1B
        1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B}
      Margin = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      Visible = False
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object cxSplitterListe: TcxSplitter
    Left = 249
    Top = 0
    Width = 8
    Height = 583
    HotZoneClassName = 'TcxMediaPlayer9Style'
    Control = PanelListe
    Color = clBtnFace
    ParentColor = False
  end
  object PanelOrta: TPanel
    Left = 257
    Top = 0
    Width = 968
    Height = 583
    Align = alClient
    Caption = 'PanelOrta'
    TabOrder = 2
    object PanelYayinBaslama: TPanel
      Left = 1
      Top = 30
      Width = 966
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      TabOrder = 0
      Visible = False
      ExplicitTop = 53
      object cxLabel1: TcxLabel
        Left = 210
        Top = 3
        Caption = 'Yay'#305'na Ba'#351'lama'
      end
      object cxDBDateEdit1: TcxDBDateEdit
        Left = 297
        Top = 2
        DataBinding.DataField = 'GECERLILIKTARIHI'
        DataBinding.DataSource = DtsDuyurular
        Properties.Kind = ckDateTime
        TabOrder = 1
        Width = 121
      end
      object cxLabel2: TcxLabel
        Left = 5
        Top = 3
        Caption = 'Yay'#305'nlayan'
      end
      object cxDBImageComboBox1: TcxDBImageComboBox
        Left = 77
        Top = 1
        DataBinding.DataField = 'EKLEYEN'
        DataBinding.DataSource = DtsDuyurular
        Enabled = False
        Properties.Items = <>
        Properties.ReadOnly = True
        TabOrder = 0
        Width = 121
      end
      object cxLabel3: TcxLabel
        Left = 5
        Top = 26
        Caption = 'Konu'
      end
      object cbKategori: TcxDBImageComboBox
        Left = 481
        Top = 3
        DataBinding.DataField = 'KATEGORI'
        DataBinding.DataSource = DtsDuyurular
        Properties.Items = <>
        TabOrder = 5
        Width = 121
      end
      object cxLabel5: TcxLabel
        Left = 431
        Top = 3
        Cursor = crHandPoint
        Caption = 'Kategori'
        FocusControl = cbKategori
        Style.TextStyle = [fsUnderline]
        OnClick = cxLabel4Click
      end
      object CheckONEM: TcxDBCheckBox
        Left = 603
        Top = 4
        AutoSize = False
        Caption = #214'nemli'
        DataBinding.DataField = 'ONEM'
        DataBinding.DataSource = DtsDuyurular
        Properties.DisplayChecked = '1'
        Properties.DisplayUnchecked = '0'
        Style.TextColor = clRed
        TabOrder = 7
        Transparent = True
        Height = 19
        Width = 62
      end
    end
    object PanelYorum: TPanel
      Left = 1
      Top = 409
      Width = 966
      Height = 173
      Align = alBottom
      Caption = 'PanelYorum'
      TabOrder = 1
      object GridYorum: TcxGrid
        Left = 1
        Top = 1
        Width = 964
        Height = 130
        Align = alClient
        TabOrder = 0
        object GridYorumDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsDuyuruYorum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 600
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          RowLayout = rlVertical
          object GridYorumDBCardView1EKLEYEN: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEYEN'
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
          object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            PropertiesClassName = 'TcxMemoProperties'
            Properties.MaxLength = 5
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
          end
          object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEMETARIHI'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
      object PanelYorumYaz: TPanel
        Left = 1
        Top = 131
        Width = 964
        Height = 41
        Align = alBottom
        TabOrder = 1
        object YorumPaylasTus: TcxButton
          Left = 888
          Top = 1
          Width = 75
          Height = 39
          Align = alRight
          Caption = 'Payla'#351
          TabOrder = 0
          OnClick = YorumPaylasTusClick
        end
        object MemoYorum: TcxMemo
          Left = 78
          Top = 1
          Align = alClient
          TabOrder = 1
          Height = 39
          Width = 810
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 77
          Height = 39
          Align = alLeft
          BevelOuter = bvNone
          Color = clSilver
          ParentBackground = False
          TabOrder = 2
          object cxLabel6: TcxLabel
            Left = 7
            Top = 10
            Caption = 'Yorum Yaz'
          end
        end
      end
    end
    object cxSplitter3: TcxSplitter
      Left = 1
      Top = 401
      Width = 966
      Height = 8
      HotZoneClassName = 'TcxXPTaskBarStyle'
      AlignSplitter = salBottom
      Control = PanelYorum
    end
    object PanelIlgili: TPanel
      Left = 1
      Top = 88
      Width = 966
      Height = 58
      Align = alTop
      BevelOuter = bvNone
      Caption = 'PanelIlgili'
      TabOrder = 3
      ExplicitTop = 111
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 77
        Height = 58
        Align = alLeft
        BevelOuter = bvNone
        Color = clSilver
        ParentBackground = False
        TabOrder = 0
        object cxLabel4: TcxLabel
          Left = 5
          Top = 6
          Caption = 'Al'#305'c'#305'lar'
        end
      end
      object cxGridKullanici: TcxGrid
        Left = 77
        Top = 0
        Width = 889
        Height = 58
        Align = alClient
        TabOrder = 1
        object cxGridKullaniciDBCardView1: TcxGridDBCardView
          OnMouseUp = cxGridKullaniciDBCardView1MouseUp
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsDuyuruKullanici
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.CardIndent = 7
          object cxGridKullaniciDBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'AD'
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Options.Filtering = False
            Options.FilteringAddValueItems = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            IsCaptionAssigned = True
          end
        end
        object cxGridKullaniciLevel1: TcxGridLevel
          GridView = cxGridKullaniciDBCardView1
        end
      end
    end
    object PanelDosyaEkle: TPanel
      Left = 1
      Top = 146
      Width = 966
      Height = 78
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 4
      ExplicitTop = 169
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 77
        Height = 78
        Align = alLeft
        BevelOuter = bvNone
        Color = clSilver
        ParentBackground = False
        TabOrder = 0
        object cxLabel7: TcxLabel
          Left = 5
          Top = 6
          Caption = 'Belgeler'
        end
      end
      object cxGrid1: TcxGrid
        Left = 77
        Top = 0
        Width = 889
        Height = 78
        Align = alClient
        TabOrder = 1
        object cxGrid1DBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          OnCellClick = cxGridDBTableView1CellClick
          DataController.DataSource = DtsDuyuruImaj
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.CardIndent = 7
          object cxGrid1DBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'BELGEADI'
            Options.Editing = False
            Options.Filtering = False
            Options.FilteringAddValueItems = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            IsCaptionAssigned = True
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGrid1DBCardView1
        end
      end
      object SQLKullan: TMemo
        Left = 279
        Top = 25
        Width = 793
        Height = 47
        Lines.Strings = (
          'select * from('
          
            'select ID='#39'50'#39', Ad='#39'Tum_Kullanicilar'#39',G'#246'rev='#39#39',Departman='#39#39','#350'ube' +
            '='#39#39', Kategori='#39'T'#252'm'#39', T'#252'r=5  '
          'union all '
          
            '--select ID='#39'4'#39'+convert(varchar(8),ID),Ad=FIRMA,G'#246'rev='#39#350'ube'#39',Dep' +
            'artman='#39#39','#350'ube='#39#39', Kategori='#39#350'ube'#39',T'#252'r=4    '
          '--from REHBER  where ID<0'
          '--union all '
          
            '--select ID='#39'3'#39'+convert(varchar(8),DEGER), Ad= ANAHTAR,G'#246'rev='#39'De' +
            'partman'#39',Departman='#39#39','#350'ube='#39#39', Kategori='#39'Departman'#39',T'#252'r=3    '
          '--from GENINI where '
          '--BOLUM=-2205'
          '--union all '
          
            '--select ID='#39'2'#39'+convert(varchar(8),DEGER), Ad= ANAHTAR,G'#246'rev='#39'G'#246 +
            'rev'#39',Departman='#39#39','#350'ube='#39#39', Kategori='#39'G'#246'rev'#39',T'#252'r=2   '
          '-- from GENINI where BOLUM=-2206'
          '--union all '
          'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
          
            'G'#246'rev=(select ANAHTAR from GENINI where BOLUM=-2205 and DEGER = ' +
            'ROL.GOREVID), '
          
            'Departman=(select ANAHTAR from GENINI where BOLUM=-2206 and DEGE' +
            'R = ROL.DEPARTMAN),'
          #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
          'Kategori='#39'Personel'#39',T'#252'r=1'
          'from REHBER R '
          'inner join KULLANICI K on R.ID=K.REHBERID '
          'left outer join ROLLER ROL on ROL.ID=R.SINIF'
          'where '
          
            'R.GRUP=335 and R.DURUM=1 --where R.ID not in '#39'+Secilmis+'#39' order ' +
            'by FIRMA'#39
          ') as Liste'
          'order by T'#252'r desc,Ad ')
        TabOrder = 2
        Visible = False
      end
    end
    object ToolBarYayin: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 960
      Height = 26
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 24
      ButtonWidth = 76
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
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 5
      Transparent = True
      Visible = False
      object AliciEkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Al'#305'c'#305' Ekle'
        DropdownMenu = PopupMenuAlici
        ImageIndex = 44
      end
      object DosyaEkleTus: TToolButton
        Left = 76
        Top = 0
        Caption = 'Belge Ekle'
        DropdownMenu = PopupMenuDosya
        ImageIndex = 19
        OnClick = DosyaEkleTusClick
      end
      object ToolButton17: TToolButton
        Left = 152
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 14
        Style = tbsSeparator
      end
      object SilTus: TToolButton
        Left = 160
        Top = 0
        Caption = 'Taslak Sil'
        ImageIndex = 8
        OnClick = YayinlaTusClick
      end
      object ToolButton4: TToolButton
        Left = 236
        Top = 0
        Width = 8
        Caption = 'ToolButton9'
        ImageIndex = 13
        Style = tbsSeparator
      end
      object TaslakKaydetTus: TToolButton
        Tag = 1
        Left = 244
        Top = 0
        Caption = 'Taslak Kaydet'
        ImageIndex = 10
        OnClick = YayinlaTusClick
      end
      object YayinlaTus: TToolButton
        Tag = 2
        Left = 320
        Top = 0
        Caption = 'Yay'#305'nla'
        ImageIndex = 41
        OnClick = YayinlaTusClick
      end
      object ToolButton15: TToolButton
        Left = 396
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 42
        Style = tbsSeparator
      end
      object SablonKaydetTus: TToolButton
        Tag = 20
        Left = 404
        Top = 0
        Caption = #350'ablon Kaydet'
        ImageIndex = 20
        Visible = False
        OnClick = YayinlaTusClick
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 56
      Width = 966
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      TabOrder = 6
      object cxLabel8: TcxLabel
        Left = 7
        Top = 8
        Caption = 'Konu'
      end
      object EditKONU: TcxDBTextEdit
        Left = 79
        Top = 2
        DataBinding.DataField = 'KONU'
        DataBinding.DataSource = DtsDuyurular
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 1
        Width = 602
      end
      object cxLabel9: TcxLabel
        Left = 687
        Top = 6
        Caption = 'Kanal:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlue
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object CheckEPOSTA: TcxDBCheckBox
        Left = 719
        Top = 4
        Caption = '  '
        DataBinding.DataField = 'EPOSTA'
        DataBinding.DataSource = DtsDuyurular
        Style.TextColor = clBlue
        TabOrder = 3
      end
      object cxDBCheckBox2: TcxDBCheckBox
        Left = 768
        Top = 6
        Caption = '     '
        DataBinding.DataField = 'SMS'
        DataBinding.DataSource = DtsDuyurular
        Style.TextColor = clBlue
        TabOrder = 4
      end
      object cxDBCheckBox3: TcxDBCheckBox
        Left = 825
        Top = 4
        Caption = '     '
        DataBinding.DataField = 'WHATSAPP'
        DataBinding.DataSource = DtsDuyurular
        Style.TextColor = clBlue
        TabOrder = 5
      end
      object cxImage1: TcxImage
        Left = 737
        Top = 5
        Picture.Data = {
          0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000010
          000000100803000000282D0F530000000467414D410000B18F0BFC6105000000
          60504C5445FFFFFFF9FBFDA4C3E35892CC4E90D14E91D44F8FD06FA6DDC1D7EE
          5C98D5609AD45593D2508FCE9DC0E35491CE6198D0EBF3FA81ADDA70A3D58FBA
          E484B0DDDFEBF7CEDEF0C5DBF199C0E771A3D3F3F7FB689ED773A8DB99BFE5AF
          CCE97BAADA29C6885F000000774944415428539DCECD1A82201085E16364318E
          A0FC089612F77F971AB1A0459BDEC5799EF956833FCCEBBDB1CE581C735F31BB
          05D125AA774FCE4548DA155D0B4A3B49C8817DD86EA72D261E4A5059F971342A
          BF4A98ACD7429D84F6F91384D6C298F7DA492258D178043CE5A5113BA0FB52FF
          FF0D3800D14707007CA4F21B0000000049454E44AE426082}
        Properties.GraphicClassName = 'TdxPNGImage'
        TabOrder = 6
        Transparent = True
        Height = 19
        Width = 25
      end
      object cxImage2: TcxImage
        Left = 788
        Top = 6
        Picture.Data = {
          0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000010
          0000001008060000001FF3FF610000000467414D410000B18E7CFB5193000000
          206348524D0000870F00008C0F0000FD520000814000007D790000E98B00003C
          E5000019CC733C857700000A396943435050686F746F73686F70204943432070
          726F66696C65000048C79D96775454D71687CFBD777AA1CD30025286DEBBC000
          D27B935E456198196028030E3334B121A2021145449A224850C480D150245644
          B1101454B007240828311845542C6F46D68BAEACBCF7F2F2FBE3AC6FEDB3F7B9
          FBECBDCF5A170092A72F9797064B0190CA13F0833C9CE911915174EC0080011E
          608029004C5646BA5FB07B0810C9CBCD859E2172025F0401F07A58BC0270D3D0
          33804E07FF9FA459E97C81E89800119BB339192C11178838254B902EB6CF8A98
          1A972C66182566BE284111CB893961910D3EFB2CB2A398D9A93CB688C539A7B3
          53D962EE15F1B64C2147C488AF880B33B99C2C11DF12B1468A30952BE237E2D8
          540E33030014496C1770588922361131891F12E422E2E500E048095F71DC572C
          E0640BC49772494BCFE173131205741D962EDDD4DA9A41F7E464A5700402C300
          262B99C967D35DD252D399BC1C0016EFFC5932E2DAD24545B634B5B6B4343433
          32FDAA50FF75F36F4ADCDB457A19F8B96710ADFF8BEDAFFCD21A0060CC896AB3
          F38B2DAE0A80CE2D00C8DDFB62D3380080A4A86F1DD7BFBA0F4D3C2F890241BA
          8DB1715656961197C3321217F40FFD4F87BFA1AFBE67243EEE8FF2D05D39F14C
          618A802EAE1B2B2D254DC8A767A433591CBAE19F87F81F07FE751E06419C780E
          9FC313458489A68CCB4B10B59BC7E60AB8693C3A97F79F9AF80FC3FEA4C5B916
          89D2F81150638C80D4752A407EED07280A1120D1FBC55DFFA36FBEF830207E79
          E12A938B73FFEF37FD67C1A5E225839BF039CE252884CE12F23317F7C4CF12A0
          010148022A9007CA401DE800436006AC802D70046EC01BF88310100956031648
          04A9800FB2401ED8040A4131D809F6806A50071A41336805C741273805CE834B
          E01AB8016E83FB60144C80676016BC060B10046121324481E421154813D287CC
          2006640FB941BE50101409C54209100F124279D066A8182A83AAA17AA819FA1E
          3A099D87AE4083D05D680C9A867E87DEC1084C82A9B012AC051BC30CD809F681
          43E0557002BC06CE850BE01D7025DC001F853BE0F3F035F8363C0A3F83E71080
          10111AA28A18220CC405F147A29078848FAC478A900AA4016945BA913EE42632
          8ACC206F51181405454719A26C519EA850140BB506B51E5582AA461D4675A07A
          51375163A859D4473419AD88D647DBA0BDD011E8047416BA105D816E42B7A32F
          A26FA327D0AF31180C0DA38DB1C2786222314998B59812CC3E4C1BE61C661033
          8E99C362B1F2587DAC1DD61FCBC40AB085D82AEC51EC59EC107602FB0647C4A9
          E0CC70EEB8281C0F978FABC01DC19DC10DE126710B7829BC26DE06EF8F67E373
          F0A5F8467C37FE3A7E02BF4090266813EC08218424C2264225A1957091F080F0
          924824AA11AD8981442E7123B192788C789938467C4B9221E9915C48D1242169
          07E910E91CE92EE925994CD6223B92A3C802F20E7233F902F911F98D0445C248
          C24B822DB141A246A2436248E2B9245E5253D24972B564AE6485E409C9EB9233
          5278292D291729A6D47AA91AA99352235273D2146953697FE954E912E923D257
          A4A764B0325A326E326C99029983321764C62908459DE242615136531A291729
          13540C559BEA454DA21653BFA30E506765656497C986C966CBD6C89E961DA521
          342D9A172D85564A3B4E1BA6BD5BA2B4C4690967C9F625AD4B8696CCCB2D9573
          94E3C815C9B5C9DD967B274F9777934F96DF25DF29FF5001A5A0A710A890A5B0
          5FE1A2C2CC52EA52DBA5ACA5454B8F2FBDA7082BEA290629AE553CA8D8AF38A7
          A4ACE4A194AE54A57441694699A6ECA89CA45CAE7C46795A85A262AFC2552957
          39ABF2942E4B77A2A7D02BE9BDF4595545554F55A16ABDEA80EA829AB65AA85A
          BE5A9BDA4375823A433D5EBD5CBD477D564345C34F234FA345E39E265E93A199
          A8B957B34F735E4B5B2B5C6BAB56A7D694B69CB69776AE768BF6031DB28E83CE
          1A9D069D5BBA185D866EB2EE3EDD1B7AB09E855EA25E8DDE757D58DF529FABBF
          4F7FD0006D606DC0336830183124193A19661AB6188E19D18C7C8DF28D3A8D9E
          1B6B184719EF32EE33FE6862619262D26872DF54C6D4DB34DFB4DBF477333D33
          96598DD92D73B2B9BBF906F32EF317CBF4977196ED5F76C78262E167B1D5A2C7
          E283A59525DFB2D572DA4AC32AD6AAD66A84416504304A1897ADD1D6CED61BAC
          4F59BFB5B1B411D81CB7F9CDD6D036D9F688EDD472EDE59CE58DCBC7EDD4EC98
          76F576A3F674FB58FB03F6A30EAA0E4C870687C78EEA8E6CC726C749275DA724
          A7A34ECF9D4D9CF9CEEDCEF32E362EEB5CCEB922AE1EAE45AE036E326EA16ED5
          6E8FDCD5DC13DC5BDC673D2C3CD67A9CF3447BFA78EEF21CF152F26279357BCD
          7A5B79AFF3EEF521F904FB54FB3CF6D5F3E5FB76FBC17EDE7EBBFD1EACD05CC1
          5BD1E90FFCBDFC77FB3F0CD00E5813F06320263020B026F0499069505E505F30
          253826F848F0EB10E790D290FBA13AA1C2D09E30C9B0E8B0E6B0F970D7F0B2F0
          D108E3887511D7221522B9915D51D8A8B0A8A6A8B9956E2BF7AC9C88B6882E8C
          1E5EA5BD2A7BD595D50AAB53569F8E918C61C69C8845C786C71E897DCFF46736
          30E7E2BCE26AE366592EACBDAC676C4776397B9A63C729E34CC6DBC597C54F25
          D825EC4E984E7448AC489CE1BA70ABB92F923C93EA92E693FD930F257F4A094F
          694BC5A5C6A69EE4C9F09279BD69CA69D96983E9FAE985E9A36B6CD6EC5933CB
          F7E137654019AB32BA0454D1CF54BF5047B8453896699F5993F9262B2CEB44B6
          74362FBB3F472F677BCE64AE7BEEB76B516B596B7BF254F336E58DAD735A57BF
          1E5A1FB7BE6783FA86820D131B3D361EDE44D894BCE9A77C93FCB2FC579BC337
          771728156C2C18DFE2B1A5A550A2905F38B2D5766BDD36D436EEB681EDE6DBAB
          B67F2C62175D2D3629AE287E5FC22AB9FA8DE93795DF7CDA11BF63A0D4B274FF
          4ECC4EDECEE15D0EBB0E974997E5968DEFF6DBDD514E2F2F2A7FB52766CF958A
          6515757B097B857B472B7D2BBBAA34AA7656BDAF4EACBE5DE35CD356AB58BBBD
          767E1F7BDFD07EC7FDAD754A75C575EF0E700FDCA9F7A8EF68D06AA838883998
          79F049635863DFB78C6F9B9B149A8A9B3E1CE21D1A3D1C74B8B7D9AAB9F988E2
          91D216B845D8327D34FAE88DEF5CBFEB6A356CAD6FA3B5151F03C784C79E7E1F
          FBFDF0719FE33D2718275A7FD0FCA1B69DD25ED40175E474CC7626768E764576
          0D9EF43ED9D36DDBDDFEA3D18F874EA99EAA392D7BBAF40CE14CC1994F6773CF
          CE9D4B3F37733EE1FC784F4CCFFD0B11176EF506F60E5CF4B978F992FBA50B7D
          4E7D672FDB5D3E75C5E6CAC9AB8CAB9DD72CAF75F45BF4B7FF64F153FB80E540
          C775ABEB5D37AC6F740F2E1F3C33E43074FEA6EBCD4BB7BC6E5DBBBDE2F6E070
          E8F09D91E891D13BEC3B537753EEBEB897796FE1FEC607E807450FA51E563C52
          7CD4F0B3EECF6DA396A3A7C75CC7FA1F073FBE3FCE1A7FF64BC62FEF270A9E90
          9F544CAA4C364F994D9D9A769FBEF174E5D38967E9CF16660A7F95FEB5F6B9CE
          F31F7E73FCAD7F366276E205FFC5A7DF4B5ECABF3CF46AD9AB9EB980B947AF53
          5F2FCC17BD917F73F82DE36DDFBBF077930B59EFB1EF2B3FE87EE8FEE8F3F1C1
          A7D44F9FFE050398F3FCBAC4E8D3000000097048597300000B1200000B1201D2
          DD7EFC0000014F49444154384F95D2CD2B445118C7712591121B2B2985BC2424
          4D61299A8D25654563E73F5076CAC2CB4692AD52B6281B334A2244598C2CACBC
          4B9A622C4612BEBFE9B93AF7BA4C169FEE79CE9CE777EF9C73F2CA22B1A056CC
          6217F778C03EE6D109DF7A5F81057CE6B08C02FC08D8415843985314E23B6009
          610BFF124736A0DD993CC1BA8D9FF16AE3477B5E62156F5647DDB71FA314D556
          F7620E1B68460A4DA8C101B426AE80332B26A1FACA6A8DA318413EB66D6E0FFA
          5D529A78B2E21D83688416F5A00AF5A84306E3284702EAC928E0DA8A3BDCA216
          6A98460314328C1928A40DDD504F5A019B56AC41750BA6B008FDAD09E8EC8750
          81626C413D4935285D851C425FA2B17702F261CFA4F1E6C71420DEC6FD471A45
          5E80362E6CD16F5EA023F55DE50E789F9F8B2E59B6CF0D901268E32E106C3AC7
          9153DFA03218E08AA01F03E8B239E9C30AB8CEB1D12F57884A41BF0CE86A0000
          000049454E44AE426082}
        Properties.GraphicClassName = 'TdxPNGImage'
        TabOrder = 7
        Transparent = True
        Height = 19
        Width = 25
      end
      object cxImage3: TcxImage
        Left = 846
        Top = 6
        Picture.Data = {
          0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000010
          000000100803000000282D0F530000000467414D410000B18F0BFC6105000000
          9C504C5445FFFFFF47BE3238B22529A71A5FD341159B0857C93E4AC72E1E9F11
          5BD13DE8F6E63FB62DFCFEFCC8EBC245BE2EA1DC99F4FBF479C671D8EFD5BFE6
          BC8ACF849AD695AADCA532AC231DA30C59C64767C55932B11FBCEBB09EE38C97
          E18388DD7277D95ECBF1C0D9F5D252B5498BD87F99DD8F39BA21BFEBB577D363
          50C23DAAE3A367CA5754BD4596D78F64D349AAE99AE5F8E1B4DFB03CAC32CAE9
          C8D69C7151000000A74944415428536D8FEB1282201046379320A53453D3C0CA
          BC75F552EFFF6EEDA2FD68A6330CC377D81D16F88FD3749DEEA780E87689B499
          3FE58AF305C12FA369EAEBEDBE9E217549D97FA8270CCA320428DEF324C6CD90
          442806C60A089910B436460816CB8289171E480454BB8530F2E31D3603C8BDB2
          94E5491CCF751D14B0A227D76959A5B547199A712ECE798665D8921DF4B1B56D
          FBA4CD3D489AB7CFF3F3F7273F007C001CE60B45B152B4B70000000049454E44
          AE426082}
        Properties.GraphicClassName = 'TdxPNGImage'
        TabOrder = 8
        Transparent = True
        Height = 19
        Width = 25
      end
    end
    object cxPageControl1: TcxPageControl
      Left = 1
      Top = 263
      Width = 966
      Height = 138
      Align = alClient
      TabOrder = 7
      Properties.ActivePage = TabSheetIcerik
      Properties.CustomButtons.Buttons = <>
      OnChange = cxPageControl1Change
      ClientRectBottom = 134
      ClientRectLeft = 4
      ClientRectRight = 962
      ClientRectTop = 24
      object TabSheetIcerik: TcxTabSheet
        Caption = #304#231'erik'
        ImageIndex = 0
        object RichEdit1: TJvDBRichEdit
          Left = 0
          Top = 0
          Width = 958
          Height = 110
          DataField = 'YORUM'
          DataSource = DtsNotlar
          Align = alClient
          Enabled = False
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          StreamFormat = sfRichText
          StreamMode = [smPlainRtf, smUnicode]
          TabOrder = 0
        end
      end
      object TabSheetGorunum: TcxTabSheet
        Caption = 'G'#246'r'#252'n'#252'm'
        ImageIndex = 1
        object WebBrowser1: TWebBrowser
          Left = 0
          Top = 0
          Width = 958
          Height = 110
          Align = alClient
          TabOrder = 0
          ExplicitWidth = 963
          ExplicitHeight = 89
          ControlData = {
            4C000000036300005E0B00000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
    object PanelYaziTuru: TPanel
      Left = 1
      Top = 224
      Width = 966
      Height = 39
      Align = alTop
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      TabOrder = 8
      Visible = False
      object RadioGroupYaziTuru: TcxDBRadioGroup
        Left = 80
        Top = 0
        Caption = 'Yaz'#305' T'#252'r'#252
        DataBinding.DataField = 'YAZITURU'
        DataBinding.DataSource = DtsDuyurular
        ParentBackground = False
        ParentColor = False
        Properties.Columns = 3
        Properties.DefaultValue = 0
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Caption = 'D'#252'z Metin'
            Value = 0
          end
          item
            Caption = 'Zengin Metin'
            Value = 1
            Tag = 1
          end
          item
            Caption = 'HTML'
            Value = 2
            Tag = 2
          end>
        Properties.OnEditValueChanged = cxDBRadioGroup1PropertiesEditValueChanged
        Style.BorderColor = clSilver
        Style.Color = clSilver
        Style.Edges = []
        TabOrder = 0
        Height = 36
        Width = 331
      end
    end
  end
  object MemoListeSQL: TMemo
    Left = 536
    Top = 292
    Width = 793
    Height = 50
    Lines.Strings = (
      'declare @Kullanici int'
      'declare @Bugun datetime'
      'set @Kullanici= :P1'
      
        'set @Bugun=convert(datetime,convert(varchar(10), getdate(), 120)' +
        ')'
      ' '
      ''
      
        'select distinct D.ID,D.GECERLILIKTARIHI,OLAYZAMANI,  D.ONEM,D.KA' +
        'TEGORI,DUYURUAD=U.ACIKLAMA,D.EKLEYEN,'
      'PERSONEL=R.FIRMA,'
      'D.KONU,'
      
        'OKUNDU=CONVERT(BIT, CASE WHEN OKUNMATARIHI IS NULL THEN 0 ELSE 1' +
        ' END),'
      'OKUNMATARIHI,'
      
        'ATAC=(case when exists(select * from DUYURUIMAJ  DI where DI.DUY' +
        'URUID=D.ID ) then 1 else 0 end),'
      
        'YORUM=(case when exists(select * from DUYURUYORUM  DY where DY.D' +
        'UYURUID=D.ID ) then 1 else 0 end),'
      'ZAMAN=(select case '
      
        'when convert(float,OLAYZAMANI-@Bugun)<-1 then   cast(abs(convert' +
        '(int,OLAYZAMANI-@Bugun)) as varchar(8))+'#39' g'#252'n '#246'nce'#39
      'when convert(float,OLAYZAMANI-@Bugun)=-1 then '#39'D'#252'n'#39
      
        'when convert(float,OLAYZAMANI-@Bugun) between 0.0 and 0.9999  th' +
        'en '#39'Bug'#252'n'#39
      'when convert(float,OLAYZAMANI-@Bugun)=1 then '#39'Yar'#305'n'#39
      
        'when convert(float,OLAYZAMANI-@Bugun)>1 then cast(convert(int,OL' +
        'AYZAMANI-@Bugun) as varchar(8))+'#39' g'#252'n sonra'#39
      'else'
      #39#39
      'end) '
      'from DUYURU D '
      'left outer join REHBER R on R.ID=D.EKLEYEN'
      'left outer join DUYURUKULLANICI DK on DK.DUYURUID=D.ID '
      'left outer join UYARIAYAR U on D.SABLONID=U.SABLONDUYURUID')
    TabOrder = 3
    Visible = False
  end
  object PanelListe: TPanel
    Left = 0
    Top = 0
    Width = 249
    Height = 583
    Align = alLeft
    TabOrder = 4
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 241
      Height = 26
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 24
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
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object YeniTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni Duyuru'
        ImageIndex = 7
        OnClick = YeniTusClick
      end
      object DuzenleTus: TToolButton
        Left = 67
        Top = 0
        Caption = 'D'#252'zenle'
        ImageIndex = 47
        Visible = False
        OnClick = DuzenleTusClick
      end
      object ListeSilTus: TToolButton
        Left = 134
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        OnClick = ListeSilTusClick
      end
    end
    object PageControl1: TcxPageControl
      Left = 1
      Top = 59
      Width = 247
      Height = 23
      Align = alTop
      TabOrder = 1
      Properties.ActivePage = TabGelen
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControl1Change
      ClientRectBottom = 24
      ClientRectLeft = 4
      ClientRectRight = 243
      ClientRectTop = 24
      object TabGelen: TcxTabSheet
        Caption = 'Gelen'
        ImageIndex = 0
      end
      object TabGiden: TcxTabSheet
        Tag = 1
        Caption = 'Giden'
        ImageIndex = 1
      end
      object TabTaslak: TcxTabSheet
        Tag = 2
        Caption = 'Taslak'
        ImageIndex = 2
      end
      object TabSilinen: TcxTabSheet
        Tag = 4
        Caption = 'Silinen'
        ImageIndex = 3
      end
    end
    object ListeGrid: TcxGrid
      Left = 1
      Top = 82
      Width = 247
      Height = 500
      Align = alClient
      TabOrder = 2
      object ListeGridDBCardView1: TcxGridDBCardView
        Navigator.Buttons.CustomButtons = <>
        OnCellClick = ListeGridDBCardView1CellClick
        DataController.DataSource = DtsListe
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ScrollBars = ssVertical
        OptionsView.CardIndent = 7
        OptionsView.CardWidth = 237
        Styles.OnGetContentStyle = ListeGridDBCardView1StylesGetContentStyle
        object ListeGridDBCardView1Row1: TcxGridDBCardViewRow
          DataBinding.FieldName = 'DUYURUAD'
          Options.Editing = False
          Options.Filtering = False
          Options.Focusing = False
          Options.Moving = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.Width = 10
          IsCaptionAssigned = True
        end
        object ListeGridDBCardView1Row5: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ONEM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 13
              Value = 1
            end>
          Options.Editing = False
          Options.Filtering = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
          Position.Width = 2
        end
        object ListeGridDBCardView1Row3: TcxGridDBCardViewRow
          DataBinding.FieldName = 'OKUNDU'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 5
              Value = False
            end
            item
              ImageIndex = 4
              Value = True
            end>
          Visible = False
          Options.Editing = False
          Options.Filtering = False
          Options.Focusing = False
          Options.Moving = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
          Position.Width = 2
          IsCaptionAssigned = True
        end
        object ListeGridDBCardView1Row6: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ATAC'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 1
              Value = 1
            end>
          Options.Editing = False
          Options.Filtering = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
          Position.Width = 2
        end
        object ListeGridDBCardView1Row8: TcxGridDBCardViewRow
          DataBinding.FieldName = 'YORUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 7
              Value = 1
            end>
          Options.Editing = False
          Options.Filtering = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
          Position.Width = 2
        end
        object ListeGridDBCardView1Row7: TcxGridDBCardViewRow
          DataBinding.FieldName = 'KONU'
          Options.Editing = False
          Options.Filtering = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
        end
        object ListeGridDBCardView1Row4: TcxGridDBCardViewRow
          DataBinding.FieldName = 'PERSONEL'
          PropertiesClassName = 'TcxTextEditProperties'
          Options.Editing = False
          Options.Filtering = False
          Options.Focusing = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.Width = 17
        end
        object ListeGridDBCardView1Row2: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ZAMAN'
          Options.Editing = False
          Options.Filtering = False
          Options.Focusing = False
          Options.Moving = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
          Position.Width = 10
          IsCaptionAssigned = True
        end
        object ListeGridDBCardView1Row9: TcxGridDBCardViewRow
          DataBinding.FieldName = 'KATEGORI'
          Visible = False
          Position.BeginsLayer = True
        end
      end
      object cxGridLevel2: TcxGridLevel
        GridView = ListeGridDBCardView1
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 30
      Width = 247
      Height = 29
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      object EdDuyuruKonu: TcxButtonEdit
        Left = 32
        Top = 4
        Properties.Buttons = <>
        TabOrder = 0
        OnKeyUp = EdDuyuruKonuKeyUp
        Width = 212
      end
      object BtnDuyuruAra: TcxButton
        Left = 4
        Top = 3
        Width = 27
        Height = 23
        OptionsImage.Glyph.Data = {
          E6040000424DE604000000000000360000002800000014000000140000000100
          180000000000B0040000120B0000120B00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4F4F4E4DF
          E0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE1E1E1687180817BA0D4BBC2
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD8E5ED48A2F04C75C1857EA4D8BDC1FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFF4FAFF74C7FF45A5FA4C75C1857EA4D8BDC1FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFF4FAFF74C7FF45A5FA4C75C1857EA4D8BDC1FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFF4FAFF74C7FF45A5FA4C75C18780A4F2E2DFEDD2C8DE
          B5A7DEAF9DE1B8A9EDD2C8F8EDE8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFF4FAFF74C7FF4FA9F8A09497D8B0A2D8AE9BE0BD9FEDDD
          BDEDDBBEDBB6A7DDB3A6F3E2DCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFF4FAFFD8DCE2D2AA9CE4B599FFF0C0FFFFD1FFFFD8FFFFE0
          FFFFEEECDDD0DCB3A4F8EDE8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFEBCFC5DDAD9BFFF3C6FFE8B6F2E6B7C5742DFFFFF8FFFFFEFF
          FFFDD9B7A2E7CABFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFE1B7A8F1D3B2FFECB9F2CD9BF1D09EC5742DEADCCDEADCCDFFFFE7F4E8
          C4DBB0A1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDE
          AE9DFEF1BFFFE1AECC6701C5742DC5742DC5742DC5742DFFFFDAFEFDD1DDAD9B
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFB4A6F6E4
          B9FFEBBEF4D191F4D191C5742DF4DDA9FAEEBFFFFFCEF9E7BEDAAB9AFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8C9C0E4C1A7FFFDE5
          FFEED8F4D191C5742DFFF9C7FFF2C0FFF8C6E2BBA0DFBDB3FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8EDE8D9AB9AF6EADEFFFFFFFF
          EBC9FFE8B8FFE2AFFFF1BEFADAACD9AB9BF8EDE8FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1DED7DAAE9FEACEBBF9E9C5FEF0
          BEF9E5B8EBC4A3DCAE9DF0DDD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8EDE8DEBBB1DAAB9ADDAD9BDAAE9E
          E0BBB1F4E7E2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFF}
        SpeedButtonOptions.Flat = True
        TabOrder = 1
      end
    end
  end
  object SQLDuyuruKullanici: TMemo
    Left = 554
    Top = 146
    Width = 793
    Height = 35
    Lines.Strings = (
      'select '
      '       DK.*, '
      #9'   AD=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DK' +
        '.ALICIID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DK.ALICIID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DK.ALICIID AND DIL=-1 )'
      #9'   END'
      ''
      'from '
      #9'DUYURUKULLANICI DK'
      'where '
      #9'DUYURUID = :PDuyuruId')
    TabOrder = 5
    Visible = False
  end
  object TabDuyurular: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDuyurularAfterOpen
    AfterScroll = TabDuyurularAfterScroll
    OnNewRecord = TabDuyurularNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *'
      'from '
      #9'DUYURU'
      'where '
      #9'ID=:PDuyuruId')
    Left = 129
    Top = 120
  end
  object DtsDuyurular: TDataSource
    DataSet = TabDuyurular
    Left = 89
    Top = 178
  end
  object TabDuyuruKullanici: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      '       DK.*, '
      #9'   AD=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DK' +
        '.ALICIID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DK.ALICIID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DK.ALICIID AND DIL=-1 )'
      #9'   END'
      ''
      'from '
      #9'DUYURUKULLANICI DK'
      'where '
      #9'DUYURUID = :PDuyuruId')
    Left = 137
    Top = 244
  end
  object DtsDuyuruKullanici: TDataSource
    DataSet = TabDuyuruKullanici
    Left = 39
    Top = 259
  end
  object TabDuyuruYorum: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDuyuruYorumAfterOpen
    ParamData = <>
    SQL.Strings = (
      'select *'
      'from '
      #9'DUYURUYORUM'
      'where '
      #9'DUYURUID=:PDuyuruId '
      'and TUR=2'
      'order by ID')
    Left = 203
    Top = 97
  end
  object DtsDuyuruYorum: TDataSource
    DataSet = TabDuyuruYorum
    Left = 196
    Top = 164
  end
  object TabDuyuruImaj: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDuyuruImajAfterOpen
    ParamData = <>
    SQL.Strings = (
      'select D.*,I.BELGEADI,ICDIS=isnull(I.ICDIS,0)'
      'from DUYURUIMAJ D inner join IMAJ I on D.IMAJID=I.ID '
      'where D.DUYURUYORUMID=0 and D.DUYURUID = :PDID')
    Left = 350
    Top = 99
  end
  object DtsDuyuruImaj: TDataSource
    DataSet = TabDuyuruImaj
    Left = 280
    Top = 126
  end
  object OpenDialog1: TOpenDialog
    Left = 335
    Top = 145
  end
  object PopupMenuDosya: TPopupMenu
    Left = 445
    Top = 294
    object Dosyadan1: TMenuItem
      Caption = 'Bilgisayardan'
      OnClick = Dosyadan1Click
    end
    object Dkmandan1: TMenuItem
      Caption = 'Dok'#252'mandan'
      OnClick = Dkmandan1Click
    end
  end
  object TabListe: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabListeAfterScroll
    OnNewRecord = TabDuyurularNewRecord
    ParamData = <>
    SQL.Strings = (
      'declare @Kullanici int'
      'set @Kullanici= :PKullanici'
      ''
      
        'select distinct D.ID,D.GECERLILIKTARIHI,OLAYZAMANI,  D.ONEM,D.KA' +
        'TEGORI,DUYURUAD=U.ACIKLAMA,D.EKLEYEN,'
      'PERSONEL=(select FIRMA from REHBER R where R.ID=D.EKLEYEN),'
      'D.KONU,'
      
        'OKUNDU=CONVERT(BIT, CASE WHEN OKUNMATARIHI IS NULL THEN 0 ELSE 1' +
        ' END),'
      'OKUNMATARIHI,'
      
        'ATAC=(case when exists(select * from DUYURUIMAJ  DI where DI.DUY' +
        'URUID=D.ID ) then 1 else 0 end),'
      
        'YORUM=(case when exists(select * from DUYURUYORUM  DY where DY.D' +
        'UYURUID=D.ID ) then 1 else 0 end),'
      'ZAMAN=(select case '
      
        'when convert(smallint,OLAYZAMANI-getdate())<-1 then   cast(abs(c' +
        'onvert(smallint,OLAYZAMANI-getdate())) as varchar(8))+'#39' g'#252'n '#246'nce' +
        #39
      'when convert(smallint,OLAYZAMANI-getdate())=-1 then '#39'D'#252'n'#39
      'when convert(smallint,OLAYZAMANI-getdate())=0 then '#39'Bug'#252'n'#39
      'when convert(smallint,OLAYZAMANI-getdate())=1 then '#39'Yar'#305'n'#39
      
        'when convert(smallint,OLAYZAMANI-getdate())>1 then cast(convert(' +
        'smallint,OLAYZAMANI-getdate()) as varchar(8))+'#39' g'#252'n sonra'#39
      'else'
      #39#39
      'end) '
      'from DUYURU D '
      'left outer join DUYURUKULLANICI DK on DK.DUYURUID=D.ID'
      'left outer join UYARIAYAR U on D.SABLONID=U.SABLONDUYURUID')
    Left = 33
    Top = 104
  end
  object DtsListe: TDataSource
    DataSet = TabListe
    Left = 17
    Top = 178
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 583
    Top = 156
  end
  object PopupMenuAlici2: TPopupMenu
    Left = 397
    Top = 126
    object MenuBolum: TMenuItem
      Caption = 'B'#246'l'#252'm'
      OnClick = MenuBolumClick
    end
    object MenuKisi: TMenuItem
      Caption = 'Ki'#351'i'
      OnClick = MenuKisiClick
    end
  end
  object TabNotlar: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabNotlarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *'
      'from '
      #9'DUYURUYORUM'
      'where '
      #9'DUYURUID=:PId '
      'AND TUR=1'
      'order by ID')
    Left = 289
    Top = 214
  end
  object DtsNotlar: TDataSource
    DataSet = TabNotlar
    Left = 345
    Top = 209
  end
  object PopupMenuAlici: TPopupMenu
    Left = 501
    Top = 126
    object TumKullanicilarMenu: TMenuItem
      Tag = 5
      Caption = 'T'#252'm Kullan'#305'c'#305'lar'
      OnClick = TumKullanicilarMenuClick
    end
    object SubeMenu: TMenuItem
      Tag = 4
      Caption = #350'ube'
      OnClick = SubeMenuClick
    end
    object DepartmanMenu: TMenuItem
      Tag = 3
      Caption = 'Departman'
      OnClick = SubeMenuClick
    end
    object GorevMenu: TMenuItem
      Tag = 2
      Caption = 'G'#246'rev'
      OnClick = SubeMenuClick
    end
    object KisiMenu: TMenuItem
      Tag = 1
      Caption = 'Ki'#351'i'
      OnClick = SubeMenuClick
    end
  end
end
