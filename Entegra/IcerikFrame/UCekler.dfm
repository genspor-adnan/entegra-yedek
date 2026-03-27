object CekDlg: TCekDlg
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  OnResize = FrameResize
  object Panel5: TPanel
    Left = 0
    Top = 73
    Width = 451
    Height = 304
    Align = alTop
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 0
    ExplicitTop = 32
    object Bevel1: TBevel
      Left = 13
      Top = 194
      Width = 702
      Height = 71
    end
    object Bevel4: TBevel
      Left = 13
      Top = 90
      Width = 702
      Height = 88
    end
    object Label3: TLabel
      Left = 500
      Top = 67
      Width = 62
      Height = 18
      Caption = 'Kay'#305't Tarihi'
    end
    object Label6: TLabel
      Left = 489
      Top = 128
      Width = 71
      Height = 18
      Caption = 'Ke'#351'ide Tarihi'
    end
    object Label7: TLabel
      Left = 527
      Top = 43
      Width = 35
      Height = 18
      Caption = 'Durum'
    end
    object Label17: TLabel
      Left = 24
      Top = 128
      Width = 42
      Height = 18
      Caption = 'M'#252#351'teri'
    end
    object Label18: TLabel
      Left = 295
      Top = 101
      Width = 30
      Height = 18
      Caption = 'Tutar'
    end
    object Label5: TLabel
      Left = 26
      Top = 212
      Width = 40
      Height = 18
      Caption = 'Seri No'
    end
    object Label10: TLabel
      Left = 500
      Top = 102
      Width = 62
      Height = 18
      Caption = 'Ke'#351'ide Yeri'
    end
    object Label13: TLabel
      Left = 19
      Top = 235
      Width = 47
      Height = 18
      Caption = 'A'#231#305'klama'
    end
    object Label15: TLabel
      Left = 278
      Top = 210
      Width = 48
      Height = 18
      Caption = 'Referans'
    end
    object Label8: TLabel
      Left = 513
      Top = 212
      Width = 49
      Height = 18
      Caption = #214'zel Kod'
    end
    object Label9: TLabel
      Left = 502
      Top = 235
      Width = 60
      Height = 18
      Caption = 'Yetki Kodu'
    end
    object Label11: TLabel
      Left = 543
      Top = 17
      Width = 19
      Height = 18
      Caption = 'T'#252'r'
    end
    object Label4: TLabel
      Left = 267
      Top = 127
      Width = 58
      Height = 18
      Caption = 'Para Birimi'
    end
    object Label12: TLabel
      Left = 37
      Top = 102
      Width = 29
      Height = 18
      Caption = 'Hitap'
    end
    object Label2: TLabel
      Left = 270
      Top = 14
      Width = 57
      Height = 18
      Caption = 'Bordro No'
    end
    object Label1: TLabel
      Left = 297
      Top = 40
      Width = 28
      Height = 18
      Caption = 'Kodu'
    end
    object EditCARIKOD: TcxButtonEdit
      Left = 70
      Top = 126
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCARIKODPropertiesButtonClick
      TabOrder = 2
      Width = 121
    end
    object ComboKUR: TcxDBComboBox
      Left = 331
      Top = 125
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsCekler
      Properties.Items.Strings = (
        'Aktif'
        'Pasif')
      TabOrder = 3
      Width = 130
    end
    object EditOZELKOD: TcxDBTextEdit
      Left = 566
      Top = 206
      DataBinding.DataField = 'OZELKOD'
      DataBinding.DataSource = DtsCekler
      TabOrder = 4
      Width = 112
    end
    object EditYETKIKODU: TcxDBTextEdit
      Left = 566
      Top = 232
      DataBinding.DataField = 'YETKIKODU'
      DataBinding.DataSource = DtsCekler
      TabOrder = 5
      Width = 112
    end
    object EditSERINO: TcxDBTextEdit
      Left = 70
      Top = 205
      DataBinding.DataField = 'SERINO'
      DataBinding.DataSource = DtsCekler
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 124
    end
    object EditODEMEYERI: TcxDBTextEdit
      Left = 566
      Top = 100
      DataBinding.DataField = 'ODEMEYERI'
      DataBinding.DataSource = DtsCekler
      TabOrder = 7
      Width = 121
    end
    object EditACIKLAMA: TcxDBTextEdit
      Left = 69
      Top = 233
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsCekler
      TabOrder = 8
      Width = 391
    end
    object EditKEFIL: TcxDBTextEdit
      Left = 330
      Top = 206
      DataBinding.DataField = 'KEFIL'
      DataBinding.DataSource = DtsCekler
      TabOrder = 9
      Width = 130
    end
    object ComboDURUM: TcxDBImageComboBox
      Left = 566
      Top = 39
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsCekler
      Enabled = False
      Properties.Items = <
        item
          Description = 'Portf'#246'yde'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Tahsil Edildi'
          Value = 2
        end
        item
          Description = #304'ptal Edildi'
          Value = 3
        end
        item
          Description = 'Ciro Edildi'
          Value = 4
        end
        item
          Description = 'Tahsile Verildi'
          Value = 5
        end
        item
          Description = 'Teminata Verildi'
          Value = 6
        end
        item
          Description = 'Protesto Edildi'
          Value = 7
        end
        item
          Description = 'Kar'#351#305'l'#305#287#305' Yok'
          Value = 8
        end
        item
          Description = 'Tahsil Edilemiyor'
          Value = 9
        end>
      Properties.ReadOnly = True
      Properties.OnChange = ComboDURUMPropertiesChange
      Style.ButtonTransparency = ebtHideInactive
      TabOrder = 10
      Width = 121
    end
    object ComboTUR: TcxDBImageComboBox
      Left = 566
      Top = 14
      DataBinding.DataField = 'TUR'
      DataBinding.DataSource = DtsCekler
      Enabled = False
      Properties.Items = <
        item
          Description = 'M'#252#351'teri '#199'eki'
          ImageIndex = 0
          Value = 23
        end
        item
          Description = 'M'#252#351'teri Senedi'
          Value = 24
        end
        item
          Description = 'Kendi '#199'ekimiz'
          Value = 33
        end
        item
          Description = 'Kendi Senedimiz'
          Value = 34
        end>
      Style.ButtonTransparency = ebtHideInactive
      TabOrder = 11
      Width = 121
    end
    object DateKesideTarihi: TcxDBDateEdit
      Left = 566
      Top = 126
      DataBinding.DataField = 'VADE'
      DataBinding.DataSource = DtsCekler
      TabOrder = 12
      Width = 121
    end
    object EditTUTAR: TcxDBCurrencyEdit
      Left = 331
      Top = 99
      DataBinding.DataField = 'TUTAR'
      DataBinding.DataSource = DtsCekler
      Properties.DisplayFormat = ',0.00;-,0.00'
      TabOrder = 13
      Width = 130
    end
    object cxDBTextEdit1: TcxDBTextEdit
      Left = 197
      Top = 126
      DataBinding.DataField = 'REHBERID'
      DataBinding.DataSource = DtsCekler
      ParentColor = True
      TabOrder = 14
      Visible = False
      Width = 25
    end
    object ComboHITAP: TcxDBImageComboBox
      Left = 70
      Top = 100
      DataBinding.DataField = 'HITAP'
      DataBinding.DataSource = DtsCekler
      Properties.Items = <
        item
          Description = 'Nama'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Hamiline'
          Value = 1
        end>
      TabOrder = 15
      Width = 121
    end
    object LabelCARIAD: TcxLabel
      Left = 68
      Top = 155
      Caption = '--'
    end
    object Logo: TcxDBImage
      AlignWithMargins = True
      Left = 9
      Top = 11
      DataBinding.DataField = 'LOGO'
      DataBinding.DataSource = DtsBankalar
      Properties.Caption = 'Banka se'#231'mek i'#231'in t'#305'klay'#305'n'
      Properties.GraphicClassName = 'TdxPNGImage'
      Properties.GraphicTransparency = gtTransparent
      Properties.ReadOnly = True
      Properties.Stretch = True
      Style.Shadow = True
      TabOrder = 17
      OnClick = LogoClick
      Height = 62
      Width = 127
    end
    object LabelSubeKodu: TcxDBLabel
      Left = 142
      Top = 30
      DataBinding.DataField = 'SUBEKODU'
      DataBinding.DataSource = DtsBankalar
      Style.TransparentBorder = True
      Height = 15
      Width = 38
    end
    object LabelSubeAdi: TcxDBLabel
      Left = 142
      Top = 51
      AutoSize = True
      DataBinding.DataField = 'SUBEADI'
      DataBinding.DataSource = DtsBankalar
    end
    object DateTARIH: TcxDBDateEdit
      Left = 566
      Top = 64
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = DtsCekler
      TabOrder = 20
      Width = 121
    end
    object BtnCekTarihcesi: TcxButton
      Left = 322
      Top = 271
      Width = 86
      Height = 25
      Caption = #199'ek Tarih'#231'esi'
      TabOrder = 21
      OnClick = BtnCekTarihcesiClick
    end
    object BtnCiroEkle: TcxButton
      Left = 407
      Top = 271
      Width = 23
      Height = 25
      Caption = '+'
      TabOrder = 22
      Visible = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnCiroEkleClick
    end
    object BtnCiroSil: TcxButton
      Left = 429
      Top = 271
      Width = 23
      Height = 25
      Caption = '-'
      Enabled = False
      TabOrder = 23
      Visible = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnCiroSilClick
    end
    object EditBORDRO: TcxDBTextEdit
      Left = 329
      Top = 11
      DataBinding.DataField = 'BORDRO'
      DataBinding.DataSource = DtsCekler
      TabOrder = 0
      Width = 80
    end
    object EditKOD: TcxDBTextEdit
      Left = 330
      Top = 38
      DataBinding.DataField = 'KOD'
      DataBinding.DataSource = DtsCekler
      TabOrder = 1
      Width = 79
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 70
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
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
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 207
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton4: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Wrap = True
      Style = tbsSeparator
    end
    object ResimTus: TToolButton
      Left = 0
      Top = 38
      Caption = 'Resim'
      ImageIndex = 1
      OnClick = CekImajClick
    end
    object ToolButton1: TToolButton
      Left = 69
      Top = 38
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 9
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 77
      Top = 38
      Caption = #199'ek'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      Style = tbsTextButton
    end
    object btnKapat: TToolButton
      Left = 146
      Top = 38
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object CekImaj: TcxDBImage
    Left = 0
    Top = 377
    Align = alClient
    DataBinding.DataField = 'BELGE'
    DataBinding.DataSource = DtsResim
    Properties.Center = False
    Properties.GraphicClassName = 'TJPEGImage'
    TabOrder = 2
    OnClick = CekImajClick
    Height = 109
    Width = 451
  end
  object cxGridTarihce: TcxGrid
    Left = 0
    Top = 377
    Width = 451
    Height = 109
    Align = alClient
    TabOrder = 3
    Visible = False
    LookAndFeel.NativeStyle = True
    object cxGridTarihceDBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DtsCekHareketler
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.CellAutoHeight = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      object cxGridTarihceDBTableView1TARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.Kind = ckDateTime
        Width = 118
      end
      object cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn
        Caption = #304#351'lem'
        DataBinding.FieldName = 'ISLEM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Portf'#246'yde'
            ImageIndex = 0
            Value = '1'
          end
          item
            Description = 'Tahsil Edildi'
            Value = '2'
          end
          item
            Description = #304'ptal Edildi'
            Value = '3'
          end
          item
            Description = 'Ciro Edildi'
            Value = '4'
          end
          item
            Description = 'Tahsile Verildi'
            Value = '5'
          end
          item
            Description = 'Teminata Verildi'
            Value = '6'
          end
          item
            Description = 'Protesto Edildi'
            Value = '7'
          end
          item
            Description = 'Kar'#351#305'l'#305#287#305' Yok'
            Value = '8'
          end
          item
            Description = 'Tahsil Edilemiyor'
            Value = '9'
          end
          item
            Description = #304'craya Verildi'
            Value = '10'
          end
          item
            Description = 'Takasa Verildi'
            Value = '11'
          end>
        Width = 114
      end
      object cxGridTarihceDBTableView1NEREYE: TcxGridDBColumn
        Caption = 'Bilgi'
        DataBinding.FieldName = 'NEREYE'
        Width = 128
      end
      object cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 573
      end
    end
    object cxGridTarihceLevel1: TcxGridLevel
      GridView = cxGridTarihceDBTableView1
    end
  end
  object DtsCekler: TDataSource
    DataSet = TabCekler
    OnStateChange = DtsCeklerStateChange
    Left = 142
    Top = 454
  end
  object TabCekler: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = TabCeklerBeforeEdit
    BeforePost = TabCeklerBeforePost
    AfterPost = TabCeklerAfterPost
    AfterScroll = TabCeklerAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT *'
      '  FROM CEKLER')
    Left = 143
    Top = 408
  end
  object PopupMenuYaz: TPopupMenu
    Left = 224
    Top = 50
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
  object TabBankalar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 100
      end>
    SQL.Strings = (
      'select BS.BANKAKODU, BANKAADI,SUBEKODU,SUBEADI,LOGO'
      '   from BANKASUBELER BS '
      '        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where BS.ID = :PID')
    Left = 277
    Top = 410
  end
  object DtsBankalar: TDataSource
    DataSet = TabBankalar
    Left = 279
    Top = 454
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 100
      end>
    SQL.Strings = (
      
        'select BELGE from IMAJ where YERI=21 and YER_ID=:PID  and VARSAY' +
        'ILAN = 1')
    Left = 413
    Top = 408
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 416
    Top = 453
  end
  object DtsCekHareketler: TDataSource
    DataSet = TabCekHareketler
    Left = 519
    Top = 452
  end
  object TabCekHareketler: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabCekHareketlerAfterScroll
    ParamData = <
      item
        Name = 'pID'
        Size = -1
        Value = Null
      end
      item
        Name = 'pID'
        Size = -1
        Value = Null
      end
      item
        Name = 'pID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select '
      '-- CEKHAREKET tablosundan Ara hareketler'
      #9'SIRALAMA=CH.ID,CEKSENETLERID,TARIH,ISLEM,'
      #9'NEREYE=CASE '
      #9#9'WHEN ISNULL(CH.REHBERID,'#39#39')<>'#39#39' THEN R.FIRMA'
      #9#9'WHEN ISNULL(CH.BANKAHESAPLARID,'#39#39')<>'#39#39' THEN BH.HESAPADI'
      #9'END,'
      #9'ACIKLAMA '
      'from '
      #9'CEKHAREKET CH LEFT OUTER JOIN '#9
      #9'REHBER R ON '
      #9#9'R.ID=CH.REHBERID LEFT OUTER JOIN'
      #9'BANKAHESAPLAR BH ON '
      #9#9'BH.ID=CH.BANKAHESAPLARID'
      'WHERE CEKSENETLERID=:pID'
      #9#9
      'UNION ALL'
      '--CEK tablosundan '#231'ek giri'#351'i'
      'SELECT '
      
        #9'SIRALAMA=0,CEKSENETLERID=ID,TARIH,ISLEM=DURUM,NEREYE='#39'Giri'#351' Kay' +
        'd'#305#39',ACIKLAMA '
      'FROM '
      #9'CEKLER'#9
      'WHERE ID=:pID'
      ''
      ''
      'union all'
      '-- KASA tablosundan '#231'ek '#231#305'k'#305#351#305
      'SELECT '
      
        #9'SIRALAMA=2000000001,CEKSENETLERID=ID,TARIH=ISLEMTARIHI,ISLEM=DU' +
        'RUM,NEREYE='#39#199#305'k'#305#351' Kayd'#305#39',ACIKLAMA '
      'FROM '
      #9'KASA'
      'WHERE ISNULL(CEKSENETID,-1)>0'#9#9
      ' AND CEKSENETID=:pID'
      ''
      'ORDER BY 1'
      ''
      #9#9)
    Left = 518
    Top = 408
  end
  object frxCekler: TfrxDBDataset
    UserName = 'CEKLER'
    CloseDataSource = False
    DataSet = TabCekler
    BCDToCurrency = False
    Left = 234
    Top = 182
  end
end

