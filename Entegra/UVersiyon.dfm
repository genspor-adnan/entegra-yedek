object VersiyonDlg: TVersiyonDlg
  Left = 206
  Top = 104
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Gentegre G'#252'ncellemeleri'
  ClientHeight = 483
  ClientWidth = 783
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = [fsBold]
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 0
    Top = 357
    Width = 783
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 406
    ExplicitWidth = 792
  end
  object Label1: TLabel
    Left = 366
    Top = 291
    Width = 35
    Height = 16
    Caption = 'Label1'
  end
  object OlaylarGrid: TcxGrid
    Left = 0
    Top = 61
    Width = 783
    Height = 296
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    PopupMenu = PmDurum
    TabOrder = 3
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    object OlaylarGridView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = OlaylarGridViewCanFocusRecord
      OnSelectionChanged = OlaylarGridViewSelectionChanged
      DataController.DataSource = DtsTabOlaylar
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      Preview.Visible = True
      object OlaylarGridViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object OlaylarGridViewEKLEMETARIHI: TcxGridDBColumn
        Caption = 'Ekleme Tarihi'
        DataBinding.FieldName = 'EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Sorting = False
        Width = 122
      end
      object OlaylarGridViewBILGINO: TcxGridDBColumn
        Caption = 'Komut No'
        DataBinding.FieldName = 'BILGINO'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Sorting = False
      end
      object OlaylarGridViewBILGI: TcxGridDBColumn
        Caption = 'Bilgi'
        DataBinding.FieldName = 'BILGI'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Options.Sorting = False
        Width = 522
      end
      object OlaylarGridViewDURUM: TcxGridDBColumn
        Caption = 'Sonu'#231
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Images = Tablo.PNGImageList2
        Properties.Items = <
          item
            ImageIndex = 24
            Value = 0
          end
          item
            ImageIndex = 23
            Value = 1
          end>
        HeaderAlignmentHorz = taCenter
        Options.Sorting = False
        Width = 42
      end
    end
    object OlaylarGridLevel3: TcxGridLevel
      GridView = OlaylarGridView
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 360
    Width = 783
    Height = 123
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Memo1: TMemo
      Left = 0
      Top = 0
      Width = 630
      Height = 123
      Align = alClient
      Color = clBtnFace
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
      OnKeyPress = Memo1KeyPress
    end
    object Panel3: TPanel
      Left = 630
      Top = 0
      Width = 153
      Height = 123
      Align = alRight
      TabOrder = 1
      object Image1: TImage
        Left = 16
        Top = 8
        Width = 121
        Height = 25
        Picture.Data = {
          0A544A504547496D61676541050000FFD8FFE000104A46494600010101006000
          600000FFE1001645786966000049492A0008000000000000000000FFDB004300
          080606070605080707070909080A0C140D0C0B0B0C1912130F141D1A1F1E1D1A
          1C1C20242E2720222C231C1C2837292C30313434341F27393D38323C2E333432
          FFDB0043010909090C0B0C180D0D1832211C2132323232323232323232323232
          3232323232323232323232323232323232323232323232323232323232323232
          3232323232FFC00011080019007A03012200021101031101FFC4001F00000105
          01010101010100000000000000000102030405060708090A0BFFC400B5100002
          010303020403050504040000017D010203000411051221314106135161072271
          14328191A1082342B1C11552D1F02433627282090A161718191A25262728292A
          3435363738393A434445464748494A535455565758595A636465666768696A73
          7475767778797A838485868788898A92939495969798999AA2A3A4A5A6A7A8A9
          AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4
          E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F010003010101010101010101
          0000000000000102030405060708090A0BFFC400B51100020102040403040705
          040400010277000102031104052131061241510761711322328108144291A1B1
          C109233352F0156272D10A162434E125F11718191A262728292A35363738393A
          434445464748494A535455565758595A636465666768696A737475767778797A
          82838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6
          B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2
          F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00F7FA2AA5DC93C724662E
          5307700403DB1D4FD6AA49777C4E21B66FAB4C807E99A06A3735A8AE799FC48C
          C4A358AAF6065C9FFD06803C4C7FE5B580FF00811FFE2681F29D0D15CFECF121
          EB75603F3FF0A5F27C447ADF587FDF2D40729BF5C36B5F11AD3C3BE2BB9D3B55
          558AC62891FCF425981233CAFA73DAB61E2F102824EA1A78FAA3FF008D7CDFF1
          74DE9F1FDC7DA6786693C888EE8B217A7A139A395BD8BA7C91BF32BE9F7799ED
          D75F1AFC136CB94BEB9B83E90DAB9FE600AC4D5BE33C52D9B1D1E24B72E3E59E
          F181C7FC001EBF53F857CF2B3DCC2A4432347BC720375AAE525772C4E5BFBCDD
          E8945B564EC5D09D3A72BCE1CDF3B7E47B49F89DE29238F10DA8FF0076C92A36
          F899E293D7C4B18FA59C5FE15E33B65FEF8FFBEE90A39EB22FFDF551ECA5FCCF
          F03ABEB947A518FE3FE67B037C48F13753E2A61F4B5847FECB517FC2CAF1144E
          1DBC5931C73836F160FF00E3B5E48226EF22FE74A236ED2AFE028F64FF0099FE
          01F5DA7D28C7F1FF0033E9FF00871F121FC4BA83E937D730CF73E599229635D8
          580EA197A77ED5E9B5F2EFC0FB3B83F11ADEE70DE4C704A5DB690395C0FE75F5
          003C55A8D96F738EB494E7CCA3CBE4BFE091DC5AC572BB655DC2AB8D26CC1C88
          BF5357A8A7766576551A75A8FF00967FA9A77D86DFFB9FA9AB14517617657FB0
          DBFF0070FE6690D85B9FE03F99AB341A2EC77667CDA3DACCA410C33E8C6BCE7C
          49F0906B7AD35D47766285902918C9E33DEBD5BB525177D471A928EC7901F81B
          68B180976738E772E6A85DFC17BC8E0296D768EA3A2918C57B78E82917BD372B
          E8CA855941DD1F3A7FC299D733CBC7F846B4F5F82FAC91CCEA3FE00B5F44FAD2
          0A9B47B1A7D6667CF63E0B6B39FF008FA03FE023FC2A783E0A6A65C7997AC067
          9C003FA57BF1E9483A5168F60FACCFBFE2CE2BC17E0287C2E1A4F34C92B7563D
          EBB60063A503A52D17309CDC9DD9FFD9}
      end
      object btnKodGetir: TSpeedButton
        Left = 22
        Top = 41
        Width = 108
        Height = 25
        Caption = 'Kod Getir'
        OnClick = btnKodGetirClick
      end
      object btnUygula1: TSpeedButton
        Left = 22
        Top = 72
        Width = 108
        Height = 29
        Caption = 'Uygula'
        OnClick = btnUygula1Click
      end
      object btnUygula: TBitBtn
        Left = 38
        Top = 104
        Width = 51
        Height = 17
        Caption = 'Uygula'
        TabOrder = 0
        Visible = False
        OnClick = btnUygulaClick
      end
    end
  end
  object CheckListBox1: TCheckListBox
    Left = 631
    Top = 114
    Width = 133
    Height = 32
    Color = 13550999
    ItemHeight = 17
    Items.Strings = (
      
        '02.50 CEKSENETLER tablosuna MASRAFID  (smallint), KREDILER tablo' +
        'suna MASRAFID  (smallint) eklendi'
      
        '02.40 PLANLANAN tablosuna MASRAFID  (smallint), MUSTERIHESAPID(i' +
        'nt) eklendi.'
      '02.30 BANKAHESAPLAR TABLOSUNA CEKHESABI (bit) eklendi'
      '02.25 FATBASLIK tablosuna MASRAFID (smallint) eklendi.'
      '02.20 KASA tablosunda SIRANO alan'#305' ID diye de'#287'i'#351'tirildi.')
    PopupMenu = PopupMenu1
    TabOrder = 1
    Visible = False
    OnClick = CheckListBox1Click
  end
  object Ver20090701: TMemo
    Left = 672
    Top = 72
    Width = 52
    Height = 17
    TabOrder = 2
    Visible = False
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 783
    Height = 61
    Align = alTop
    TabOrder = 4
    object cxDateEdit1: TcxDateEdit
      Left = 43
      Top = 19
      EditValue = 40179d
      Properties.ImmediatePost = True
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 0
      Width = 121
    end
    object cxDateEdit2: TcxDateEdit
      Left = 167
      Top = 19
      EditValue = 40909d
      Properties.ImmediatePost = True
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 20
      Caption = 'Tarih:'
      Transparent = True
    end
    object cxTextEdit1: TcxTextEdit
      Left = 334
      Top = 19
      TabOrder = 3
      OnKeyUp = cxTextEdit1KeyUp
      Width = 332
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 737
      Top = 18
      EditValue = -1
      Properties.Images = Tablo.PNGImageList2
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Value = -1
        end
        item
          ImageIndex = 9
          Value = 1
        end
        item
          ImageIndex = 10
          Value = 0
        end>
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 4
      Width = 43
    end
    object cxLabel3: TcxLabel
      Left = 672
      Top = 20
      Caption = 'Sonu'#231':'
      Transparent = True
    end
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 48
    Top = 369
    object Komutugster1: TMenuItem
      Caption = 'Uyguland'#305' olarak i'#351'aretle'
      ImageIndex = 23
    end
  end
  object TabOlaylar: TFDQuery
    BeforeOpen = TabOlaylarBeforeOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from OLAYLAR  where KATEGORI=101 '
      'where BILGI like '#39'%'#39'+:PBilgi+'#39'%'#39
      'order by 1 desc'
      ' ')
    Left = 304
    Top = 88
    ParamData = <
      item
        Name = 'PBilgi+'#39'%'#39
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end>
  end
  object DtsTabOlaylar: TDataSource
    DataSet = TabOlaylar
    Left = 369
    Top = 99
  end
  object PmDurum: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 568
    Top = 64
    object Yapld1: TMenuItem
      Tag = 1
      Caption = 'Yap'#305'ld'#305
      ImageIndex = 15
      OnClick = Yapld1Click
    end
    object Yaplmad1: TMenuItem
      Caption = 'Yap'#305'lmad'#305
      ImageIndex = 15
      OnClick = Yapld1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object HepsiniSe1: TMenuItem
      Caption = 'Hepsini Se'#231
      ImageIndex = 23
      OnClick = HepsiniSe1Click
    end
  end
end
