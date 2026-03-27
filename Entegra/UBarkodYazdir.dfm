object BarkodYazdirDlg: TBarkodYazdirDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Barkod Yazd'#305'rma'
  ClientHeight = 528
  ClientWidth = 826
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GridBarkod: TcxGrid
    Left = 0
    Top = 63
    Width = 826
    Height = 434
    Align = alClient
    TabOrder = 0
    ExplicitTop = 60
    ExplicitHeight = 437
    object GridBarkodDBTableView4: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsBarkodYazdir
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsView.Footer = True
      OptionsView.FooterAutoHeight = True
      OptionsView.FooterMultiSummaries = True
      OptionsView.GroupByBox = False
    end
    object GridBarkodLevel8: TcxGridLevel
      GridView = GridBarkodDBTableView4
    end
  end
  object ToolBar3: TToolBar
    Left = 0
    Top = 31
    Width = 826
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
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
      Style = tbsTextButton
    end
  end
  object PanelBarkod: TPanel
    Left = 0
    Top = 0
    Width = 826
    Height = 31
    Align = alTop
    TabOrder = 2
    object Label1: TLabel
      Left = 424
      Top = 8
      Width = 52
      Height = 13
      Caption = 'Barkod Tipi'
    end
    object ComboBoyutKategoriler: TcxImageComboBox
      Left = 481
      Top = 6
      RepositoryItem = Tablo.RepStokKartBarkodAyarlar
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboBoyutKategorilerPropertiesEditValueChanged
      TabOrder = 0
      Width = 121
    end
  end
  object MemoBoyutIzleme: TMemo
    Left = 8
    Top = 288
    Width = 481
    Height = 89
    Color = clBlue
    Lines.Strings = (
      'declare @Dil int, @StokID int, @GDepoID int, @CDepoID int'
      'declare @IzlemTur int, @IzlemBaslik int, @IzlemSatir int'
      'set @StokID= :PStokID'
      'set @GDepoID=:PGDepoID'
      'set @CDepoID=:PCDepoID'
      'set @Dil=:PDil'
      'set @IzlemTur =:PIzlemTur'
      'set @IzlemBaslik =:PIzlemBaslik '
      'set @IzlemSatir=:PIzlemSatir'
      ''
      
        'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##S' +
        'TOKBOYUTDURUMLAR_SPID_%'#39') '
      'DROP TABLE ##STOKBOYUTDURUMLAR_SPID_ '
      'CREATE TABLE ##STOKBOYUTDURUMLAR_SPID_ ( '
      #9'ID int,'
      #9'STOKID int,'
      #9'ACIKLAMA nvarchar(200),'
      #9'GDEPODURUM float,'
      #9'CDEPODURUM float,'
      #9'MIKTAR float)'
      ''
      'insert into ##STOKBOYUTDURUMLAR_SPID_'
      'select '
      #9'ID=SBK.ID,'
      #9'STOKID=S.ID,'
      
        #9'ACIKLAMA=isnull(G1.ANAHTAR,'#39#39')+'#39' '#39'+isnull(G2.ANAHTAR,'#39#39')+'#39' '#39'+is' +
        'null(G3.ANAHTAR,'#39#39'),'
      
        #9'GIRISDEPO=isnull((select sum(MIKTAR) from STOKBOYUTHAREKET SBH2' +
        ' where SBH2.STOKBOYUTKOMBINASYONID=SBK.ID and GIRISDEPO=@GDepoID' +
        ' and GIRISDEPO<>0),0.0)'
      
        #9#9#9#9'-isnull((select sum(MIKTAR) from STOKBOYUTHAREKET SBH2 where' +
        ' SBH2.STOKBOYUTKOMBINASYONID=SBK.ID and CIKISDEPO=@GDepoID and C' +
        'IKISDEPO<>0),0.0),'
      
        #9'CIKISDEPO=isnull((select sum(MIKTAR) from STOKBOYUTHAREKET SBH2' +
        ' where SBH2.STOKBOYUTKOMBINASYONID=SBK.ID and GIRISDEPO=@CDepoID' +
        ' and GIRISDEPO<>0),0.0)'
      
        #9#9#9#9'-isnull((select sum(MIKTAR) from STOKBOYUTHAREKET SBH2 where' +
        ' SBH2.STOKBOYUTKOMBINASYONID=SBK.ID and CIKISDEPO=@CDepoID and C' +
        'IKISDEPO<>0),0.0),'
      #9'MIKTAR=isnull(SBH.MIKTAR,0.0)'
      'from '
      #9'STOKLAR S inner join '
      #9'STOKBOYUTKOMBINASYON SBK on S.ID=SBK.STOKID inner join'
      #9'STOKBOYUTGRUPLARI SBG on SBG.ID=SBK.SBGID left outer join'
      
        #9'GENINI G1 on G1.BOLUM=SBK.BOLUM1 and G1.DEGER=SBK.DEGER1 and G1' +
        '.DIL=@Dil left outer join'
      
        #9'GENINI G2 on G2.BOLUM=SBK.BOLUM2 and G2.DEGER=SBK.DEGER2 and G2' +
        '.DIL=@Dil left outer join'
      
        #9'GENINI G3 on G3.BOLUM=SBK.BOLUM3 and G3.DEGER=SBK.DEGER3 and G3' +
        '.DIL=@Dil left outer join  '
      
        #9'STOKBOYUTHAREKET SBH on SBH.STOKBOYUTKOMBINASYONID=SBK.ID and (' +
        'SBH.GIRISDEPO = @GDepoID or SBH.CIKISDEPO = @CDepoID) and SBH.TU' +
        'R=@IzlemTur and SBH.BASLIKID=@IzlemBaslik and SBH.SATIRID=@Izlem' +
        'Satir left outer join'
      
        #9'FATURA F on SBH.SATIRID=F.ID and SBH.BASLIKID=F.FATBASID and F.' +
        'STOKDURUMDEGIS=1'
      ''
      'where '
      #9'S.ID=@StokID '
      #9
      'select * from ##STOKBOYUTDURUMLAR_SPID_'
      ''
      ''
      ''
      ''
      ''
      '')
    TabOrder = 3
    Visible = False
    WordWrap = False
  end
  object PanelIzleme: TPanel
    Left = 0
    Top = 497
    Width = 826
    Height = 31
    Align = alBottom
    TabOrder = 4
    Visible = False
    object cxButton1: TcxButton
      Left = 353
      Top = 3
      Width = 121
      Height = 25
      Caption = 'Tamam'
      TabOrder = 0
      OnClick = cxButton1Click
    end
    object cxButton2: TcxButton
      Left = 482
      Top = 3
      Width = 121
      Height = 25
      Caption = #304'ptal'
      TabOrder = 1
      OnClick = cxButton2Click
    end
    object LabelTakipSayisi: TcxLabel
      Left = 8
      Top = 6
      Caption = 'LabelTakipSayisi'
    end
  end
  object TabBarkodYazdir: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterPost = TabBarkodYazdirAfterPost
    ParamData = <>
    SQL.Strings = (
      'select * '
      'from BARKODYAZDIR'
      'where '
      'TARIHID = :PTID and'
      'EKLEYEN = :PEkleyen'
      ''
      #9#9
      #9#9
      #9#9' ')
    Left = 57
    Top = 116
  end
  object DtsBarkodYazdir: TDataSource
    DataSet = TabBarkodYazdir
    Left = 57
    Top = 162
  end
  object frxBarkodYazdir: TfrxDBDataset
    UserName = 'BarkodYazdir'
    CloseDataSource = False
    DataSet = TabBarkodYazdir
    BCDToCurrency = False
    DataSetOptions = []
    Left = 63
    Top = 216
  end
  object PopupMenuYaz: TPopupMenu
    Left = 138
    Top = 126
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabBarkodYazdirDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        ' select * from [dbo].[fn_BarkodBaskiDetay2] ( :PStkID,'#39':PTrhID'#39',' +
        ' :PKullanan, :PDil)'
      #9#9
      #9#9
      #9#9' ')
    Left = 235
    Top = 131
  end
  object DtsBarkodYazdirDetay: TDataSource
    DataSet = TabBarkodYazdirDetay
    Left = 237
    Top = 179
  end
  object frxBarkodYazdirDetay: TfrxDBDataset
    UserName = 'BarkodYazdirDetay'
    CloseDataSource = False
    DataSet = TabBarkodYazdirDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 241
    Top = 228
  end
end


