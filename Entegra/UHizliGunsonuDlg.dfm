object HizliGunsonuDlg: THizliGunsonuDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Say'#305'm Ekran'#305
  ClientHeight = 648
  ClientWidth = 1389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnShow = FormShow
  TextHeight = 13
  object pnlSagUst: TPanel
    Left = 0
    Top = 37
    Width = 1389
    Height = 68
    Align = alTop
    Color = clSilver
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      1389
      68)
    object JvNavPanelButton1: TJvNavPanelButton
      Left = 801
      Top = 6
      Width = 37
      Height = 40
      Anchors = [akRight, akBottom]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = clBtnFace
      Colors.ButtonHotColorFrom = clSilver
      Colors.ButtonHotColorTo = clSilver
      Colors.ButtonSelectedColorFrom = clSilver
      Colors.ButtonSelectedColorTo = clSilver
      Colors.SplitterColorFrom = clSilver
      Colors.SplitterColorTo = clSilver
      Colors.DividerColorFrom = clSilver
      Colors.DividerColorTo = clSilver
      Colors.HeaderColorFrom = clSilver
      Colors.HeaderColorTo = clSilver
      Colors.FrameColor = clSilver
      Colors.ToolPanelHeaderColorTo = clSilver
      ImageIndex = 36
      Images = Tablo.cxImageList1
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = 643
    end
    object Label4: TcxLabel
      Left = 5
      Top = 7
      Caption = #350'ube / Depo'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label5: TcxLabel
      Left = 7
      Top = 32
      Caption = 'Tarih'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cbDepo: TcxImageComboBox
      Left = 172
      Top = 9
      Properties.Items = <>
      Properties.OnCloseUp = cbDepoPropertiesCloseUp
      TabOrder = 0
      Width = 94
    end
    object dateTarih: TcxDateEdit
      Left = 75
      Top = 36
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.OnCloseUp = dateTarihPropertiesCloseUp
      TabOrder = 2
      Width = 189
    end
    object cxImage1: TcxImage
      Left = 391
      Top = 30
      Picture.Data = {
        07544269746D61700E060000424D0E0600000000000036000000280000001600
        0000160000000100180000000000D8050000EF0A0000EF0A0000000000000000
        0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDFDADADAF1F1F1FCFC
        FCFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5C4C27D7D7B7777778E
        8E8EC3C3C3FBFBFB0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEAEAEC6A79ADADA9A6
        8B8B896D6D6D8A8A8AEDEDED0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9E9EB5B74CC206F
        FF8BB6DBEFE7DE8C8B8B7F7F7FDEDEDE0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE6E6E85872CC2B
        76FF54B3FF62CEFFA4CBE4B6B0A77A7A7AD9D9D90000FFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3E3E65570CE
        2D78FF56B4FF6AD2FF5CC0FF3488FE7786B7B2B1AEFBFBFB0000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC8C9CB4A64
        BC2E7BFF57B7FF69D1FF5CBDFF3B8EFF4069DFCBCDD5FFFFFFFFFFFF0000FFFF
        FFFFFFFFFFFFFFFFFFFFF6F6F6D9D9D9C1C1C1B9B9B9BFBFBFDBDBDBD5D5D48C
        8C963367C550B2FE6BD4FF5BBBFF398BFF4369DDD5D6DCFFFFFFFFFFFFFFFFFF
        0000FFFFFFFFFFFFFFFFFFD6D6D693949675777A6666676465666B6E72757677
        8283839D9A95B2B8B95EB0D753B8FF388AFF476CDAD6D7DCFFFFFFFFFFFFFFFF
        FFFFFFFF0000FFFFFFFFFFFFBBBCBC797B7E958D80BEAC8FD1BB95D1B997B8A7
        8B86827D54575CA0A0A1F5F1ECB1BBBE2F6DD44563CCD8D9DEFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF0000FFFFFFC8C8C8858687C1AB89E2C088E1BD83DFBD86E1
        C08BE8C58FE7C591B0A08B797D81AFAFAFB1AEA782879CC5C5CAFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFF0000ECECEC929496C4AF89E2C189DBBE89D9BD8A
        D9BC88DABB85DBBC8BE2C79AECC88FAFA08B53565B838384C9C8C6FEFEFEFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000B9BABBA89E8BE1C491DAC293DAC3
        94DBC395DBC191DABF8DDABA86DABB87E4C99CE7C694837F7A7A7A7AE7E7E7FF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A8A8AAC6B28EE1C99BDB
        C89DDBC79EDCC89DDBC69ADBC497DAC091DABC87DDC192E9C897B2A1886E7174
        CACACAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A3A29ED0BE97
        E1CFA7DECFABDFD1B0DED0AADECCA4DDC99EDCC498DAC091DBBD8AE4C699CCB7
        966F6F72C4C4C4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A8A6
        A1D1C09BE5D9B9E6DBC1E1D8BBDFD5B6DFD2AEDECDA5DDC99EDAC396DABF8EE2
        C594CEB998727374CDCDCDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        0000B0AFB0CABE9DEDE5C9EAE4D1EAE7D5E5DFC8E0D7B8DFD3AFDDCBA3DCC699
        DBC193E6C794B7A88D7D7F81E3E3E3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFF0000D2D3D5B4AD98EDE7CBEFEDE2F5F6F3EDEADCE3DCC0E1D7B7DDCD
        A6DCC79CDBC293E4C898918A7F999A9CF9F9F9FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF0000F7F7F7AEACACD0CCB2F0EFDDF0F0E8EBEAD9E6E1C9E1
        D6B7DDCDA7DDC79DE4C995BFAC8F7A7C80DEDEDEFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFE9EAEBA7A6A1D1CFB8EEEBD4EEEAD4
        E7E0C5E3D5B2E3D1A8E2CB9CC4B290838486C1C1C1FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFEAEAEBAAAAA7B5B1
        9DCAC3A8D2C8A8D2C4A2C7B798A59D8C909194C8C9C9FFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFF3
        F3F4C6C7C8A9A9A9A3A19DA09E9AA1A1A3B2B2B4E8E8E8FFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
      Style.BorderColor = clWhite
      Style.BorderStyle = ebsNone
      Style.Edges = []
      Style.TransparentBorder = True
      TabOrder = 4
      Transparent = True
      Height = 23
      Width = 28
    end
    object EditAra: TcxTextEdit
      Left = 421
      Top = 30
      Properties.OnChange = dateTarihPropertiesCloseUp
      Style.Color = clAqua
      TabOrder = 5
      Width = 189
    end
    object cbSube: TcxImageComboBox
      Left = 79
      Top = 9
      RepositoryItem = Tablo.RepSubeler
      Properties.Items = <>
      Properties.OnCloseUp = cbSubePropertiesCloseUp
      TabOrder = 6
      Width = 94
    end
    object EditFiltre: TcxComboBox
      Left = 421
      Top = 6
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.OnChange = dateTarihPropertiesCloseUp
      TabOrder = 7
      Width = 189
    end
    object cxImage2: TcxImage
      Left = 391
      Top = 6
      Picture.Data = {
        0A544A504547496D61676511040000FFD8FFE000104A46494600010001006000
        600000FFFE001F4C45414420546563686E6F6C6F6769657320496E632E205631
        2E303100FFDB0084000505050805080C07070C0C0909090C0D0C0C0C0C0D0D0D
        0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D
        0D0D0D0D0D0D0D0D0D010508080A070A0C07070C0D0C0A0C0D0D0D0D0D0D0D0D
        0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D
        0D0D0D0D0D0D0D0D0D0DFFC401A2000001050101010101010000000000000000
        0102030405060708090A0B010003010101010101010101000000000000010203
        0405060708090A0B100002010303020403050504040000017D01020300041105
        122131410613516107227114328191A1082342B1C11552D1F02433627282090A
        161718191A25262728292A3435363738393A434445464748494A535455565758
        595A636465666768696A737475767778797A838485868788898A929394959697
        98999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3
        D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FA1100020102
        0404030407050404000102770001020311040521310612415107617113223281
        08144291A1B1C109233352F0156272D10A162434E125F11718191A262728292A
        35363738393A434445464748494A535455565758595A636465666768696A7374
        75767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7A8A9
        AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3E4E5
        E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFC0001108001C001C030111000211010311
        01FFDA000C03010002110311003F00FA2ACEDB43D3749B2B9D42DEDC19E1B74D
        C6D44AEF2BC21B07646EE59B0C724727A9C91900AA75CF06A9C14B5047041B16
        E3FF0025E8025B6D57C21772A5BC31DA3492BAA22FD888CB310AA32600064903
        24803B9C50079E7C4BB2B7B0D4A28ED628E0436C8C56345452C6598124280338
        0067AE001DA803D8B4DD3A0D5743B5B5BA5DF1BDA5BFB1044498653D5594F208
        E9F4A00F21F1678765B232B5C7CD2C28254B80062E62F3628489476B88DA64DC
        E3891796F9B0CC01DBF81FC0E3490B7F7EA0DD1198E33C8841EE7FE9A1FF00C7
        3A0E7268038DF8ADFF002158BFEBD13FF46CF401ECFE1CFF00905597FD7A5BFF
        00E8A4A00E73C73A4DE6AB108ECA233168258CE1E350ACD7167282DE63A70560
        907CBB8EEC020039001DE5007CFF00F15BFE42B17FD7A27FE8D9E802B597C4BD
        4AC2DE2B58E2B62904691A96494B15450A0922603381CE0019E8050059FF0085
        ADAAFF00CF2B4FFBE25FFE3F4007FC2D6D57FE795A7FDF12FF00F1FA00E3FC41
        E20B8F125C2DD5D2C68E9188C08C305DA199812199CE72E7BE318E3D403FFFD9}
      Style.BorderColor = clWhite
      Style.BorderStyle = ebsNone
      Style.Edges = []
      Style.TransparentBorder = True
      TabOrder = 8
      Transparent = True
      Height = 23
      Width = 28
    end
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1389
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object KapatTus: TJvNavPanelButton
      Left = 1265
      Top = 0
      Width = 124
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 120
    end
    object cxLabel1: TcxLabel
      Left = 3
      Top = 6
      Caption = 'G'#252'n Sonu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -19
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 105
    Width = 1389
    Height = 543
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    Properties.Style = 8
    Properties.TabWidth = 100
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    OnChange = cxPageControl1Change
    ClientRectBottom = 543
    ClientRectRight = 1389
    ClientRectTop = 24
    object cxTabSheet1: TcxTabSheet
      Caption = '     Stok     '
      ImageIndex = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gridSayimTutanak: TcxGrid
        Left = 0
        Top = 43
        Width = 665
        Height = 476
        Align = alLeft
        TabOrder = 0
        ExplicitTop = 44
        ExplicitHeight = 475
        object tvSayimTutanak: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsGunSonuStokDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = '###,###,##0.00'
              Kind = skSum
            end
            item
              Format = 'Say'#305' :  ######'
              Kind = skCount
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = Tablo.cxStyle17
          Styles.ContentEven = Tablo.cxStyle18
          object tvSayimTutanakSTOKID: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'STOKID'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.ReadOnly = True
            Visible = False
            Width = 31
          end
          object tvSayimTutanakKATEGORIADI: TcxGridDBColumn
            Caption = 'Kategori'
            DataBinding.FieldName = 'KATEGORIADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Visible = False
            Options.Editing = False
            Width = 116
          end
          object clmSayimStokAdi: TcxGridDBColumn
            Caption = 'Stok Ad'#305' '
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Width = 250
          end
          object tvSayimTutanakBARKOD: TcxGridDBColumn
            Caption = 'Barkod'
            DataBinding.FieldName = 'BARKOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Visible = False
            Options.Editing = False
            Width = 74
          end
          object clmSayimStokBirimAD: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIMAD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Width = 76
          end
          object clmSayimSistemDEVIR: TcxGridDBColumn
            Caption = 'Devir'
            DataBinding.FieldName = 'DEVIR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.AssignedValues.EditFormat = True
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00;-,0.00'
            Properties.ReadOnly = True
            Options.Editing = False
            Width = 80
          end
          object tvSayimTutanakSARF: TcxGridDBColumn
            Caption = 'Giren'
            DataBinding.FieldName = 'GIREN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 80
          end
          object tvSayimTutanakCIKAN: TcxGridDBColumn
            Caption = #199#305'kan'
            DataBinding.FieldName = 'CIKAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.AssignedValues.EditFormat = True
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 80
          end
          object tvSayimTutanakKALAN: TcxGridDBColumn
            Caption = 'Kalan'
            DataBinding.FieldName = 'KALAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00;-,0.00'
            Properties.ReadOnly = True
            Width = 80
          end
        end
        object gridSayimTutanakLevel1: TcxGridLevel
          GridView = tvSayimTutanak
        end
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1383
        Height = 40
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 79
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
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object StokListele: TToolButton
          Left = 0
          Top = 0
          Caption = '     Listele     '
          ImageIndex = 15
          ImageName = 'PngImage15'
          OnClick = StokListeleClick
        end
        object ToolButton3: TToolButton
          Left = 79
          Top = 0
          Width = 8
          Caption = 'ToolButton14'
          ImageIndex = 10
          ImageName = 'PngImage10'
          Style = tbsSeparator
        end
        object StokKaydet: TToolButton
          Left = 87
          Top = 0
          Caption = 'Listeyi Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = StokKaydetClick
        end
        object StokSil: TToolButton
          Left = 166
          Top = 0
          Caption = 'Listeyi Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = StokSilClick
        end
        object ToolButton5: TToolButton
          Left = 245
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 8
          ImageName = 'PngImage15'
          Style = tbsSeparator
        end
      end
      object cxSplitter1: TcxSplitter
        Left = 665
        Top = 43
        Width = 8
        Height = 476
        HotZoneClassName = 'TcxMediaPlayer8Style'
        Control = gridSayimTutanak
        ExplicitTop = 44
        ExplicitHeight = 475
      end
      object Panel1: TPanel
        Left = 673
        Top = 43
        Width = 716
        Height = 476
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 3
        ExplicitTop = 44
        ExplicitHeight = 475
        object cxGrid2: TcxGrid
          Left = 1
          Top = 57
          Width = 714
          Height = 418
          Align = alClient
          TabOrder = 0
          ExplicitHeight = 417
          object cxGridDBTableView2: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsGunSonuStokDetay2
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'GIREN1'
                Column = cxGridDBColumnGIREN1
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'GIREN2'
                Column = cxGridDBColumnGIREN2
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'GIREN'
                Column = cxGridDBColumnGIREN
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                FieldName = 'GIREN1'
                Column = cxGridDBColumnGIREN1
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                FieldName = 'GIREN2'
                Column = cxGridDBColumnGIREN2
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                FieldName = 'GIREN'
                Column = cxGridDBColumnGIREN
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.GroupSummaryLayout = gslAlignWithColumnsAndDistribute
            OptionsView.Indicator = True
            Styles.Content = Tablo.cxStyle17
            Styles.ContentEven = Tablo.cxStyle18
            object cxGridDBTableViewSIRA: TcxGridDBColumn
              DataBinding.FieldName = 'SIRA'
              DataBinding.IsNullValueType = True
              Visible = False
              GroupIndex = 0
              IsCaptionAssigned = True
            end
            object cxGridDBColumnTUR: TcxGridDBColumn
              Caption = 'Giri'#351' T'#252'r'#252
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              Width = 194
            end
            object cxGridDBColumnGIREN1: TcxGridDBColumn
              Caption = 'G'#252'n '#304#231'i'
              DataBinding.FieldName = 'GIREN1'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.00;-,0.00'
              Properties.ReadOnly = True
              Width = 80
            end
            object cxGridDBColumnGIREN2: TcxGridDBColumn
              Caption = 'G'#252'n Sonu'
              DataBinding.FieldName = 'GIREN2'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.00;-,0.00'
              Width = 80
            end
            object cxGridDBColumnGIREN: TcxGridDBColumn
              Caption = 'Toplam'
              DataBinding.FieldName = 'GIREN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.AssignedValues.EditFormat = True
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.00;-,0.00'
              Width = 80
            end
          end
          object cxGridLevel4: TcxGridLevel
            GridView = cxGridDBTableView2
          end
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 714
          Height = 12
          Align = alTop
          TabOrder = 1
        end
        object ToolBarSag: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 16
          Width = 708
          Height = 41
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 39
          ButtonWidth = 86
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
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 2
          Transparent = True
          object SatisTus: TToolButton
            Left = 0
            Top = 0
            Hint = 'Sat'#305#351
            HelpType = htKeyword
            HelpKeyword = 'PSATIS_2'
            Caption = 'Perakende Sat'#305#351
            ImageIndex = 26
            ImageName = 'PngImage26'
            OnClick = SatisTusClick
          end
          object ToolButton2: TToolButton
            Left = 86
            Top = 0
            Width = 8
            Caption = 'ToolButton14'
            ImageIndex = 10
            ImageName = 'PngImage10'
            Style = tbsSeparator
          end
          object ToolButton6: TToolButton
            Left = 94
            Top = 0
            Hint = 'Sarf'
            HelpType = htKeyword
            HelpKeyword = 'SARF_2'
            Caption = 'Sarf'
            ImageIndex = 26
            ImageName = 'PngImage26'
            OnClick = SatisTusClick
          end
          object ToolButton7: TToolButton
            Left = 180
            Top = 0
            Width = 8
            Caption = 'ToolButton4'
            ImageIndex = 9
            ImageName = 'PngImage9'
            Style = tbsSeparator
          end
          object ToolButton8: TToolButton
            Left = 188
            Top = 0
            HelpType = htKeyword
            HelpKeyword = 'BOZUK_2'
            Caption = 'Bayat'
            ImageIndex = 26
            ImageName = 'PngImage26'
            OnClick = SatisTusClick
          end
          object ToolButton10: TToolButton
            Left = 274
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
          object ToolButton9: TToolButton
            Left = 282
            Top = 0
            HelpType = htKeyword
            HelpKeyword = 'URETIM_2'
            Caption = #220'retim'
            ImageIndex = 25
            ImageName = 'PngImage25'
            OnClick = SatisTusClick
          end
          object ToolButton11: TToolButton
            Left = 368
            Top = 0
            Width = 8
            Caption = 'ToolButton11'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object ToolButton1: TToolButton
            Left = 376
            Top = 0
            HelpType = htKeyword
            HelpKeyword = 'IADE_2'
            Caption = #304'ade'
            ImageIndex = 25
            ImageName = 'PngImage25'
            OnClick = SatisTusClick
          end
        end
      end
      object SQLIslem: TcxMemo
        Left = 45
        Top = 146
        Lines.Strings = (
          'select *,'
          
            'STOKID=(select STOKID from STOKGUNSONU SG  where SGI.GUNSONUID=S' +
            'G.ID ),'
          
            'STOKADI=(select STOKADI from STOKGUNSONU SG inner join STOKLAR S' +
            ' on S.ID=SG.STOKID and SGI.GUNSONUID=SG.ID )'
          'from STOKGUNSONUISLEM SGI'
          'where 1=1')
        Properties.WordWrap = False
        TabOrder = 4
        Visible = False
        Height = 41
        Width = 393
      end
      object SQLStokDetay2: TcxMemo
        Left = 45
        Top = 272
        Lines.Strings = (
          
            'select SIRA='#39'Giren'#39', TUR='#39'Devir'#39', GIREN=DEVIR, GIREN1=0, GIREN2=' +
            '0 from STOKGUNSONUDETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39'Giren'#39', TUR='#39'Gelen Transfer'#39', GELEN=GELEN_1+GELEN_2' +
            ',GELEN_1,GELEN_2 from STOKGUNSONUDETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39'Giren'#39', TUR='#39#220'retim'#39', URETIM=URETIM_1+URETIM_2,URET' +
            'IM_1,URETIM_2 from STOKGUNSONUDETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39'Giren'#39', TUR='#39#304'ade'#39', IADE=IADE_1+IADE_2,IADE_1,IADE_' +
            '2 from STOKGUNSONUDETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Perakende Sat'#305#351#39',PSATIS=-1.0*(PSATIS_1' +
            '+PSATIS_2),-1.0*PSATIS_1,-1.0*PSATIS_2 from STOKGUNSONUDETAY WHE' +
            'RE ID=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Cari Sat'#305#351#39', TSATIS=-1.0*(TSATIS_1+TSA' +
            'TIS_2),-1.0*TSATIS_1,-1.0*TSATIS_2  from STOKGUNSONUDETAY WHERE ' +
            'ID=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Giden Transfer'#39', GIDEN=-1.0*(GIDEN_1+G' +
            'IDEN_2),-1.0*GIDEN_1,-1.0*GIDEN_2  from STOKGUNSONUDETAY WHERE I' +
            'D=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Bedelsiz'#39', BEDELSIZ=-1.0*(BEDELSIZ_1+B' +
            'EDELSIZ_2),-1.0*BEDELSIZ_1,-1.0*BEDELSIZ_2  from STOKGUNSONUDETA' +
            'Y WHERE ID=&ID'
          '-- union all'
          
            '-- select SIRA='#39#199#305'kan'#39', TUR='#39'Personel'#39', PERSONEL=-1.0*(PERSONEL_' +
            '1+PERSONEL_2),-1.0*PERSONEL_1,-1.0*PERSONEL_2  from STOKGUNSONUD' +
            'ETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Sarf'#39', SARF=-1.0*(SARF_1+SARF_2),-1.0*' +
            'SARF_1,-1.0*SARF_2  from STOKGUNSONUDETAY WHERE ID=&ID'
          'union all'
          
            'select SIRA='#39#199#305'kan'#39', TUR='#39'Bayat'#39', BOZUK=-1.0*(BOZUK_1+BOZUK_2),-' +
            '1.0*BOZUK_1,-1.0*BOZUK_2  from STOKGUNSONUDETAY WHERE ID=&ID')
        Properties.WordWrap = False
        TabOrder = 5
        Visible = False
        Height = 41
        Width = 393
      end
    end
    object cxTabSheet3: TcxTabSheet
      Caption = '     Kasa     '
      ImageIndex = 2
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object TahsilDetayGrid: TcxGrid
        Left = 0
        Top = 44
        Width = 750
        Height = 475
        Align = alLeft
        TabOrder = 0
        object TahsilDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsTahsilatDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
              FieldName = 'TUTAR1'
              Column = TahsilDetayViewTUTAR1
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
              FieldName = 'TUTAR2'
              Column = TahsilDetayViewTUTAR2
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
              FieldName = 'TOPLAM'
              Column = TahsilDetayViewColumn2
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TUTAR1'
              Column = TahsilDetayViewTUTAR1
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TUTAR2'
              Column = TahsilDetayViewTUTAR2
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TOPLAM'
              Column = TahsilDetayViewColumn2
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.Content = Tablo.cxStyle17
          Styles.ContentEven = Tablo.cxStyle18
          object TahsilDetayViewTAHTUR: TcxGridDBColumn
            Caption = 'Tahsilat T'#252'r'
            DataBinding.FieldName = 'TAHTUR'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object TahsilDetayViewTAHTURAD: TcxGridDBColumn
            DataBinding.FieldName = 'TAHTURAD'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Options.Editing = False
            Width = 74
            IsCaptionAssigned = True
          end
          object TahsilDetayViewADI: TcxGridDBColumn
            Caption = 'Kasa Ad'#305
            DataBinding.FieldName = 'ADI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 146
          end
          object TahsilDetayViewTUTAR1: TcxGridDBColumn
            Caption = 'G'#252'n '#304#231'i'
            DataBinding.FieldName = 'TUTAR1'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DecimalPlaces = 2
            Properties.DisplayFormat = ',0.00;-,0.00'
            Options.Editing = False
            Width = 112
          end
          object TahsilDetayViewTUTAR2: TcxGridDBColumn
            Caption = 'G'#252'n Sonu'
            DataBinding.FieldName = 'TUTAR2'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 164
          end
          object TahsilDetayViewColumn2: TcxGridDBColumn
            Caption = 'Toplam'
            DataBinding.FieldName = 'TOPLAM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Options.Editing = False
            Width = 108
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = TahsilDetayView
        end
      end
      object ToolBar10: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1383
        Height = 41
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 39
        ButtonWidth = 58
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
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object KasaListeleTus: TToolButton
          Left = 0
          Top = 0
          Caption = '   Listele   '
          ImageIndex = 15
          ImageName = 'PngImage15'
          OnClick = KasaListeleTusClick
        end
        object ToolButton14: TToolButton
          Left = 58
          Top = 0
          Width = 8
          Caption = 'ToolButton14'
          ImageIndex = 10
          ImageName = 'PngImage10'
          Style = tbsSeparator
        end
        object KasaSilTus: TToolButton
          Left = 66
          Top = 0
          Caption = 'Listeyi Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = KasaSilTusClick
        end
      end
      object TahsilOzetGrid: TcxGrid
        Left = 750
        Top = 44
        Width = 639
        Height = 475
        Align = alClient
        TabOrder = 2
        object TahsilOzetView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsTahsilatOzet
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TUTAR1'
              Column = cxGridDBTUTAR1
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TUTAR2'
              Column = TahsilOzetViewTUTAR2
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TOPLAM'
              Column = TahsilOzetViewTOPLAM
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = Tablo.cxStyle17
          Styles.ContentEven = Tablo.cxStyle18
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'ADI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 120
          end
          object cxGridDBTUTAR1: TcxGridDBColumn
            Caption = 'Sistem'
            DataBinding.FieldName = 'TUTAR1'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00;-,0.00'
            Options.Editing = False
            Width = 122
          end
          object TahsilOzetViewTUTAR2: TcxGridDBColumn
            Caption = 'Eldeki / Z Raporu'
            DataBinding.FieldName = 'TUTAR2'
            DataBinding.IsNullValueType = True
            Width = 99
          end
          object TahsilOzetViewTOPLAM: TcxGridDBColumn
            Caption = 'Fark'
            DataBinding.FieldName = 'TOPLAM'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 88
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = TahsilOzetView
        end
      end
      object SQLKasaDetayInsert: TcxMemo
        Left = 39
        Top = 74
        Lines.Strings = (
          
            'insert into KASAGUNSONUDETAY(KID, TAHTUR, KASATUR, KASAID,  TUTA' +
            'R1, TUTAR2, TOPLAM, DETAY, EKLEYEN,EKLEMETARIHI)'
          
            'SELECT KID=&KID,TAHTUR, KASATUR,KASAID,TUTAR1=0.0, TUTAR2=0.0, T' +
            'OPLAM=0.0,DETAY=1, EKLEYEN=&EKLEYEN, EKLEMETARIHI=getdate() '
          ' FROM ('
          'select  TAHTUR=1,KASATUR=1,KASAID=0 '
          'union all'
          
            'select  TAHTUR=1,KASATUR=2,KASAID=ID  from POS where DURUM = 1 a' +
            'nd SUBEID=&SUBE'
          'union all'
          
            'select  TAHTUR=1,KASATUR=3,KASAID=ID  from PARA_KUPON where TUR ' +
            '= 26 and DURUM = 1 '
          'union all'
          'select  TAHTUR=2,KASATUR=1,KASAID=0 '
          'union all'
          'select  TAHTUR=3,KASATUR=1,KASAID=0 '
          'union all'
          'select  TAHTUR=11,KASATUR=1,KASAID=0 '
          'union all'
          'select  TAHTUR=12,KASATUR=1,KASAID=0 '
          ')AS TT'
          'order by 1,2,3')
        Properties.WordWrap = False
        TabOrder = 3
        Visible = False
        Height = 41
        Width = 705
      end
      object SQLKasaOzetInsert: TcxMemo
        Left = 18
        Top = 130
        Lines.Strings = (
          
            'insert into KASAGUNSONUDETAY(KID, TAHTUR, KASATUR, KASAID,  TUTA' +
            'R1, TUTAR2, TOPLAM, DETAY, EKLEYEN,EKLEMETARIHI)'
          
            'select KID,TAHTUR=0, KASATUR,KASAID,TUTAR1,TUTAR2=0.0,TOPLAM=0.0' +
            ', DETAY=0, EKLEYEN=&EKLEYEN,EKLEMETARIHI=GETDATE()'
          'from('
          'select KID, KASATUR,KASAID,TUTAR1=SUM(TOPLAM) '
          ' from KASAGUNSONUDETAY K'
          'where KID=&KID'
          ' and DETAY=1'
          'group by KID, KASATUR,KASAID'
          ')as TT'
          'order by 3,4')
        Properties.WordWrap = False
        TabOrder = 4
        Visible = False
        Height = 41
        Width = 705
      end
    end
    object TabSheetCiro: TcxTabSheet
      Caption = 'Ciro'
      ImageIndex = 2
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1383
        Height = 41
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 39
        ButtonWidth = 58
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
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object CiroListeleTus: TToolButton
          Left = 0
          Top = 0
          Caption = '   Listele   '
          ImageIndex = 15
          ImageName = 'PngImage15'
          OnClick = CiroListeleTusClick
        end
        object ToolButton12: TToolButton
          Left = 58
          Top = 0
          Width = 8
          Caption = 'ToolButton14'
          ImageIndex = 10
          ImageName = 'PngImage10'
          Style = tbsSeparator
        end
        object CiroListeSilTus: TToolButton
          Left = 66
          Top = 0
          Caption = 'Listeyi Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = CiroListeSilTusClick
        end
      end
      object GridCiro: TcxGrid
        Left = 0
        Top = 44
        Width = 1389
        Height = 475
        Align = alClient
        TabOrder = 1
        object GridCiroView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsCiro
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'CIRO'
              Column = GridCiroViewCIRO
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'TAHSIL'
              Column = GridCiroViewTAHSIL
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = Tablo.cxStyle17
          Styles.ContentEven = Tablo.cxStyle18
          object GridCiroViewREHBERID: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'REHBERID'
            DataBinding.IsNullValueType = True
            Width = 30
          end
          object GridCiroViewFIRMA: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 300
          end
          object GridCiroViewCIRO: TcxGridDBColumn
            Caption = 'Ciro'
            DataBinding.FieldName = 'CIRO'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 100
          end
          object GridCiroViewTAHSIL: TcxGridDBColumn
            Caption = 'Tahsilat'
            DataBinding.FieldName = 'TAHSIL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 100
          end
          object GridCiroViewFARK: TcxGridDBColumn
            Caption = 'Fark'
            DataBinding.FieldName = 'FARK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 101
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridCiroView
        end
      end
      object SQLCiro: TcxMemo
        Left = 75
        Top = 328
        Lines.Strings = (
          'SELECT REHBERID,FIRMA,CIRO, TAHSIL, FARK = CIRO-TAHSIL FROM'
          '('
          'SELECT '
          'REHBERID,R.FIRMA,CIRO=sum(FATURA_TUTARI), '
          'TAHSIL=(SELECT isnull(SUM(ALACAK),0.0) FROM KASA K  '
          
            'WHERE K.REHBERID=FB.REHBERID AND ISLEMTARIHI BETWEEN '#39'@TARIHBAS'#39 +
            ' AND '#39'@TARIHBIT'#39' AND ISNULL(FATURAID,0)>0 and K.SUBEID=@SUBEID)'
          'FROM FATBASLIK  FB '
          'INNER JOIN REHBER R ON FB.REHBERID=R.ID '
          'WHERE '
          'TUR IN (15,16) '
          'AND FATURATARIH BETWEEN '#39'@TARIHBAS'#39' AND '#39'@TARIHBIT'#39
          'and FB.SUBEID=@SUBEID'
          'GROUP BY REHBERID,R.FIRMA'
          'HAVING sum(FATURA_TUTARI)>0.0'
          ''
          'UNION ALL'
          ''
          'SELECT '
          'REHBERID,R.FIRMA,CIRO=0.0,  isnull(SUM(ALACAK),0.0)'
          'FROM KASA K  INNER JOIN REHBER R ON K.REHBERID=R.ID '
          'WHERE '
          'ISLEMTARIHI BETWEEN '#39'@TARIHBAS'#39' AND '#39'@TARIHBIT'#39
          'AND ISNULL(FATURAID,0)=0'
          'and K.SUBEID=@SUBEID'
          'GROUP BY REHBERID,R.FIRMA'
          ')AS CC'
          'order by 1')
        Properties.WordWrap = False
        TabOrder = 2
        Visible = False
        Height = 41
        Width = 763
      end
    end
  end
  object TabGunSonuStok: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterScroll = TabGunSonuStokAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select * from '
      'STOKGUNSONU SGS'
      'WHERE '
      'TARIH=:PRM1 '
      'AND DEPOID=:PRM2')
    Left = 96
    Top = 246
  end
  object DtsGunSonuStok: TDataSource
    DataSet = TabGunSonuStok
    Left = 97
    Top = 326
  end
  object frxSayimKalemleri: TfrxDBDataset
    UserName = 'frxGunSonuStok'
    CloseDataSource = False
    FieldAliases.Strings = (
      'SAYIMID=SAYIMID'
      'STOKID=STOKID'
      'SKT=SKT'
      'SISTEMDEKIMIKTAR=SISTEMDEKIMIKTAR'
      'SAYIMMIKTAR=SAYIMMIKTAR'
      'BIRIMFIYAT=BIRIMFIYAT'
      'TUTAR=TUTAR'
      'EKLEYEN=EKLEYEN'
      'EKLEMETARIHI=EKLEMETARIHI'
      'DEGISTIREN=DEGISTIREN'
      'DEGISTIRMETARIHI=DEGISTIRMETARIHI'
      'KOD=KOD'
      'ANABIRIM=ANABIRIM'
      'IZLEME=IZLEME'
      'AD=AD'
      'ID=ID'
      'KUR=KUR'
      'BARKOD=BARKOD'
      'MARKA=MARKA'
      'MODEL=MODEL'
      'GRUBU=GRUBU'
      'TIPI=TIPI')
    DataSource = DtsGunSonuStok
    BCDToCurrency = False
    DataSetOptions = []
    Left = 568
    Top = 267
  end
  object DtsTahsilat: TDataSource
    DataSet = TabTahsilat
    Left = 721
    Top = 366
  end
  object TabTahsilat: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select *'
      'from KASAGUNSONU'
      'where TARIH=:Prm1 and SUBEID=:Prm2')
    Left = 712
    Top = 310
  end
  object DtsGunSonuStokDetay: TDataSource
    DataSet = TabGunSonuStokDetay
    Left = 209
    Top = 334
  end
  object TabGunSonuStokDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = TabGunSonuStokDetayAfterOpen
    AfterScroll = TabGunSonuStokDetayAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select * from ('
      'SELECT'
      ''
      'ID,SGSID,STOKID,DEVIR,'
      'GIREN = URETIM_1+URETIM_2+GELEN_1+GELEN_2+IADE_1+IADE_2,'
      
        'CIKAN = PSATIS_1+PSATIS_2+TSATIS_1+TSATIS_2+BOZUK_1+BOZUK_2+GIDE' +
        'N_1+GIDEN_2+SARF_1+SARF_2+BEDELSIZ_1+BEDELSIZ_2+PERSONEL_1+PERSO' +
        'NEL_2,'
      'KALAN,           '
      
        'KATEGORIADI= (SELECT K.AD FROM KATEGORI K INNER JOIN STOKLAR S O' +
        'N S.ID=SGS.STOKID WHERE S.KATEGORI =K.ID),'
      'STOKADI=(SELECT STOKADI FROM STOKLAR S WHERE SGS.STOKID=S.ID),'
      
        'BARKOD=(SELECT BARKOD FROM STOKBARKOD SB WHERE SGS.STOKID=SB.STO' +
        'KID AND SB.VARSAYILAN=1),'
      'BIRIM=(SELECT ANABIRIM FROM STOKLAR S WHERE S.ID=SGS.STOKID ),'
      
        'BIRIMAD=(SELECT G.ANAHTAR FROM GENINI G INNER JOIN STOKLAR S ON ' +
        'S.ID=SGS.STOKID WHERE S.ANABIRIM=G.DEGER AND G.BOLUM=-2702 AND G' +
        '.DIL=-1)'
      ''
      'FROM STOKGUNSONUDETAY SGS'
      'WHERE '
      'SGSID= :PRM1'
      ') as Liste'
      ''
      'where'
      'isnull(STOKADI,'#39#39')  like :PRM2'
      'and isnull(KATEGORIADI,'#39#39')  like :PRM3')
    Left = 200
    Top = 238
  end
  object DtsTahsilatOzet: TDataSource
    DataSet = TabTahsilatOzet
    Left = 1033
    Top = 286
  end
  object TabTahsilatOzet: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    BeforePost = TabTahsilatOzetBeforePost
    ParamData = <>
    SQL.Strings = (
      'select K.*, '
      'ADI=(case when KASATUR=1 then '#39'Nakit'#39' '
      'when KASATUR=2 then (select ADI from POS P where P.ID=K.KASAID) '
      
        'when KASATUR=3 then (select ADI from PARA_KUPON P where P.ID=K.K' +
        'ASAID) end)'
      ' from KASAGUNSONUDETAY K'
      'where KID=:PKID'
      'and DETAY=0'
      'order by 3,4,5')
    Left = 960
    Top = 270
  end
  object DtsTahsilatDetay: TDataSource
    DataSet = TabTahsilatDetay
    Left = 801
    Top = 318
  end
  object TabTahsilatDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = TabTahsilatDetayAfterOpen
    BeforePost = TabTahsilatDetayBeforePost
    AfterPost = TabTahsilatDetayAfterPost
    ParamData = <>
    SQL.Strings = (
      'select '
      
        'ID,KID,TAHTUR,KASATUR,KASAID,TUTAR1,TUTAR2,TOPLAM,DETAY,EKLEYEN,' +
        'EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,'
      'ADI=(case when KASATUR=1 then '#39'Nakit'#39' '
      'when KASATUR=2 then (select ADI from POS P where P.ID=K.KASAID) '
      
        'when KASATUR=3 then (select ADI from PARA_KUPON P where P.ID=K.K' +
        'ASAID) end),'
      
        'TAHTURAD=(select top 1 ANAHTAR from GENINI where BOLUM=-23195 AN' +
        'D DEGER=K.TAHTUR and DIL=-1)'
      ' from KASAGUNSONUDETAY K'
      'where KID=:PKID'
      'and DETAY=1'
      'order by 3,4,5')
    Left = 800
    Top = 262
  end
  object TabGunSonuStokDetay2: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select SIRA='#39'Giren'#39', TUR='#39'Devir'#39', GIREN=DEVIR, GIREN1=0, GIREN2=' +
        '0 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39'Giren'#39', TUR='#39'Gelen Transfer'#39', GELEN=GELEN_1+GELEN_2' +
        ',GELEN_1,GELEN_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39'Giren'#39', TUR='#39#220'retim'#39', URETIM=URETIM_1+URETIM_2,URET' +
        'IM_1,URETIM_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39'Giren'#39', TUR='#39#304'ade'#39', IADE=IADE_1+IADE_2,IADE_1,IADE_' +
        '2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Perakende Sat'#305#351#39', PSATIS=PSATIS_1+PSAT' +
        'IS_2,PSATIS_1,PSATIS_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Toptan Sat'#305#351#39', TSATIS=TSATIS_1+TSATIS_' +
        '2,TSATIS_1,TSATIS_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Giden Transfer'#39', GIDEN=GIDEN_1+GIDEN_2' +
        ',GIDEN_1,GIDEN_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Bedelsiz'#39', BEDELSIZ=BEDELSIZ_1+BEDELSI' +
        'Z_2,BEDELSIZ_1,BEDELSIZ_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Personel'#39', PERSONEL=PERSONEL_1+PERSONE' +
        'L_2,PERSONEL_1,PERSONEL_2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Sarf'#39', SARF=SARF_1+SARF_2,SARF_1,SARF_' +
        '2 from STOKGUNSONUDETAY WHERE ID=5'
      'union all'
      
        'select SIRA='#39#199#305'kan'#39', TUR='#39'Bayat'#39', BOZUK=BOZUK_1+BOZUK_2,BOZUK_1,' +
        'BOZUK_2 from STOKGUNSONUDETAY WHERE ID=5'
      '')
    Left = 392
    Top = 198
  end
  object DtsGunSonuStokDetay2: TDataSource
    DataSet = TabGunSonuStokDetay2
    Left = 393
    Top = 326
  end
  object TabCiro: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT REHBERID,R.FIRMA,CIRO, TAHSIL, FARK = CIRO-TAHSIL FROM'
      '('
      'SELECT '
      'REHBERID,R.FIRMA,CIRO=sum(FATURA_TUTARI), '
      'TAHSIL=(SELECT SUM(ALACAK) FROM KASA K  '
      
        'WHERE K.REHBERID=FB.REHBERID AND ISLEMTARIHI BETWEEN '#39'@TARIHBAS'#39 +
        ' AND '#39'@TARIHBIT'#39' AND ISNULL(FATURAID,0)>0 and K.SUBEID=@SUBEID)'
      'FROM FATBASLIK  FB '
      'INNER JOIN REHBER R ON FB.REHBERID=R.ID '
      'WHERE '
      'TUR IN (15,16) '
      'AND FATURATARIH BETWEEN '#39'@TARIHBAS'#39' AND '#39'@TARIHBIT'#39
      'and FB.SUBEID=@SUBEID'
      'GROUP BY REHBERID,R.FIRMA'
      'HAVING sum(FATURA_TUTARI)>0.0'
      ''
      'UNION ALL'
      ''
      'SELECT '
      'REHBERID,R.FIRMA,CIRO=0.0, SUM(ALACAK)'
      'FROM KASA K  INNER JOIN REHBER R ON K.REHBERID=R.ID '
      'WHERE '
      'ISLEMTARIHI BETWEEN '#39'@TARIHBAS'#39' AND '#39'@TARIHBIT'#39
      'AND ISNULL(FATURAID,0)=0'
      'and K.SUBEID=@SUBEID'
      'GROUP BY REHBERID,R.FIRMA'
      'order by 1'
      ')AS CC')
    Left = 944
    Top = 366
  end
  object DtsCiro: TDataSource
    DataSet = TabCiro
    Left = 1017
    Top = 382
  end
end
