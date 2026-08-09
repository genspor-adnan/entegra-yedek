object DokumDlg: TDokumDlg
  Left = 0
  Top = 0
  Width = 1011
  Height = 543
  Align = alClient
  Color = clSilver
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 163
    Width = 1011
    Height = 380
    Align = alClient
    AutoSize = True
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object GBox1: TJvPanel
      Left = 0
      Top = 0
      Width = 1011
      Height = 201
      Align = alTop
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      PopupMenu = pmDokumSartlari
      TabOrder = 0
      object Panel2: TPanel
        Left = 504
        Top = -136
        Width = 185
        Height = 41
        Caption = 'Panel2'
        TabOrder = 0
      end
    end
    object DBGrid1: TcxGrid
      Left = 0
      Top = 201
      Width = 1011
      Height = 179
      Align = alClient
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.ScrollbarMode = sbmClassic
      object DBTable: TcxGridDBTableView
        OnMouseUp = DBTableMouseUp
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = DBTableCanFocusRecord
        DataController.DataSource = dsListe
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            Column = DBTableColumn1
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.ColumnHeaderHints = False
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.Footer = True
        OptionsView.FooterMultiSummaries = True
        OptionsView.GroupFooterMultiSummaries = True
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.GroupSummaryLayout = gslAlignWithColumnsAndDistribute
        OptionsView.Indicator = True
        Styles.Header = cxStyle1
        object DBTableColumn1: TcxGridDBColumn
          DataBinding.IsNullValueType = True
        end
      end
      object DBGrid1Level1: TcxGridLevel
        GridView = DBTable
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 1011
    Height = 33
    Align = alTop
    Caption = 'Panel3'
    TabOrder = 1
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 298
      Height = 31
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 68
      Color = clTeal
      DockSite = True
      DrawingStyle = dsGradient
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
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object YeniTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 7
        ImageName = 'PngImage6'
        OnClick = YeniTusClick
      end
      object SilTus: TToolButton
        Left = 68
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        ImageName = 'PngImage7'
        OnClick = SilTusClick
      end
      object ToolButton2: TToolButton
        Left = 136
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        Enabled = False
        ImageIndex = 9
        ImageName = 'PngImage8'
        Style = tbsSeparator
      end
      object DokumTus: TToolButton
        Left = 144
        Top = 0
        Caption = 'Listele'
        ImageIndex = 1
        ImageName = 'PngImage0'
        OnClick = DokumTusClick
      end
      object ToolButton1: TToolButton
        Left = 212
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 20
        ImageName = 'PngImage20'
        Style = tbsSeparator
      end
      object cxTabControl1: TcxTabControl
        Left = 220
        Top = 0
        Width = 2
        Height = 30
        TabOrder = 0
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 26
        ClientRectLeft = 4
        ClientRectRight = 4
        ClientRectTop = 4
      end
      object YaziciYaz: TToolButton
        Left = 222
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        ImageName = 'PngImage15'
        Style = tbsTextButton
      end
      object ToolButton5: TToolButton
        Left = 290
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 19
        ImageName = 'PngImage19'
        Style = tbsSeparator
      end
    end
    object PanelBaslik: TJvNavPanelHeader
      Left = 299
      Top = 1
      Width = 711
      Height = 31
      Align = alClient
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8404992
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
    end
  end
  object PanelBilgi: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 36
    Width = 1005
    Height = 116
    Align = alTop
    BevelOuter = bvLowered
    Color = clSilver
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    object Label1: TcxLabel
      Left = 5
      Top = 47
      Caption = 'Rap&or Ad'#305' '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label2: TcxLabel
      Left = 5
      Top = 91
      Caption = 'A'#231#305'&klama '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      OnDblClick = Label2DblClick
    end
    object Label3: TcxLabel
      Left = 5
      Top = 69
      Caption = 'Grubu '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label4: TcxLabel
      Left = 642
      Top = 47
      AutoSize = False
      Caption = 'Saya'#231' '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      Height = 17
      Width = 41
    end
    object Label5: TcxLabel
      Left = 642
      Top = 69
      AutoSize = False
      Caption = 'Son Kullanan'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      Height = 17
      Width = 76
    end
    object Label6: TcxLabel
      Left = 642
      Top = 91
      AutoSize = False
      Caption = 'Son Kul.Tarihi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      OnDblClick = Label6DblClick
      Height = 17
      Width = 80
    end
    object Label8: TcxLabel
      Left = 642
      Top = 25
      AutoSize = False
      Caption = 'Versiyon '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      Height = 17
      Width = 56
    end
    object LabelKullanan: TcxLabel
      Left = 764
      Top = 70
      AutoSize = False
      Caption = '---'
      ParentFont = False
      Transparent = True
      Height = 17
      Width = 80
    end
    object EditRAPORADI: TcxDBLabel
      Left = 92
      Top = 46
      DataBinding.DataField = 'RAPORADI'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Height = 21
      Width = 252
    end
    object EditGRUBU: TcxDBLabel
      Left = 92
      Top = 68
      DataBinding.DataField = 'GRUBU'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Height = 21
      Width = 229
    end
    object cxDBTextEdit3: TcxDBLabel
      Left = 92
      Top = 90
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Height = 21
      Width = 509
    end
    object cxDBTextEdit1: TcxDBLabel
      Left = 764
      Top = 47
      DataBinding.DataField = 'SAYAC'
      DataBinding.DataSource = DtsDokumler
      Properties.Orientation = cxoLeftBottom
      Style.BorderStyle = ebsNone
      Height = 17
      Width = 27
    end
    object cxDBTextEdit2: TcxDBLabel
      Left = 972
      Top = 69
      AutoSize = True
      DataBinding.DataField = 'SONKULLANAN'
      DataBinding.DataSource = DtsDokumler
      Style.BorderStyle = ebsNone
      Visible = False
    end
    object cxDBTextEdit4: TcxDBLabel
      Left = 764
      Top = 91
      DataBinding.DataField = 'SONTARIH'
      DataBinding.DataSource = DtsDokumler
      Style.BorderStyle = ebsNone
      Height = 17
      Width = 91
    end
    object EditRAPORKODU: TcxDBLabel
      Left = 175
      Top = 24
      DataBinding.DataField = 'RAPORID'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
      Height = 22
      Width = 78
    end
    object cxDBLabel2: TcxDBLabel
      Left = 764
      Top = 25
      DataBinding.DataField = 'VERSIYON'
      DataBinding.DataSource = DtsDokumler
      Style.BorderStyle = ebsNone
      Height = 17
      Width = 51
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 25
      Caption = 'Rap&or No'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditRAPORNO: TcxDBLabel
      Left = 92
      Top = 24
      DataBinding.DataField = 'RAPORNO'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Height = 21
      Width = 77
    end
    object LabelOzel: TcxLabel
      Left = 348
      Top = 5
      Caption = #214'  Z  E  L    D  '#214'  K  '#220'  M '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBCheckBox1: TcxDBCheckBox
      Left = 637
      Top = 3
      Caption = 'Mobil'
      DataBinding.DataField = 'MOBIL'
      DataBinding.DataSource = DtsDokumler
      TabOrder = 19
      OnClick = cxDBCheckBox1Click
    end
    object cxDBCheckBox2: TcxDBCheckBox
      Left = 757
      Top = 3
      Caption = 'Kullan'#305'mda'
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsDokumler
      Properties.ValueChecked = '9'
      Properties.ValueGrayed = '1'
      Properties.ValueUnchecked = '0'
      TabOrder = 20
      OnClick = cxDBCheckBox1Click
    end
  end
  object Splitter1: TcxSplitter
    Left = 0
    Top = 155
    Width = 1011
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salTop
    Control = PanelBilgi
    Color = clNavy
    ParentColor = False
    ExplicitWidth = 8
  end
  object pmDokumSartlari: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 256
    Top = 160
    object DosyaAyarlar1: TMenuItem
      Caption = 'Dosya Ayarlar'#305
      ImageIndex = 11
      OnClick = DosyaAyarlar1Click
    end
    object DosyayaYazdr1: TMenuItem
      Caption = 'Dosyaya Yazd'#305'r'
      ImageIndex = 8
      OnClick = DosyayaYazdr1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object RaporKaydet1: TMenuItem
      Caption = 'Rapor Kaydet (Text)'
      ImageIndex = 2
      OnClick = RaporKaydet1Click
    end
    object RaporEkle2: TMenuItem
      Caption = 'Rapor Al (Text)'
      ImageIndex = 32
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object BuRapor1: TMenuItem
      Caption = 'Bu Rapor'
      ImageIndex = 32
      object HerkesteGrnsn1: TMenuItem
        Caption = 'Herkeste G'#246'r'#252'ns'#252'n'
        ImageIndex = 10
        OnClick = HerkesteGrnsn1Click
      end
      object KimsedeGrnmesin1: TMenuItem
        Caption = 'Kimsede G'#246'r'#252'nmesin'
        ImageIndex = 12
        OnClick = KimsedeGrnmesin1Click
      end
    end
    object Moduller: TMenuItem
      Caption = 'Mod'#252'ller'
      ImageIndex = 15
      OnClick = ModullerClick
      object R: TMenuItem
        Caption = 'CRM'
        ImageIndex = 15
        OnClick = CClick
      end
      object C: TMenuItem
        Caption = 'Cari'
        ImageIndex = 35
        OnClick = CClick
      end
      object K: TMenuItem
        Caption = 'Kasa'
        ImageIndex = 15
        OnClick = CClick
      end
      object B: TMenuItem
        Caption = 'Banka'
        ImageIndex = 15
        OnClick = CClick
      end
      object F: TMenuItem
        Caption = 'Al'#305#351'/Sat'#305#351
        ImageIndex = 15
        OnClick = CClick
      end
      object S: TMenuItem
        Caption = 'Stok'
        ImageIndex = 12
        OnClick = CClick
      end
      object U: TMenuItem
        Caption = #220'retim'
        ImageIndex = 15
        OnClick = CClick
      end
      object D: TMenuItem
        Caption = 'Demirba'#351
        ImageIndex = 6
        OnClick = CClick
      end
      object T: TMenuItem
        Caption = 'Teklif'
        ImageIndex = 4
        OnClick = CClick
      end
      object P: TMenuItem
        Caption = #304'K'
        ImageIndex = 15
        OnClick = CClick
      end
      object E: TMenuItem
        Caption = 'Teknik Servis'
        ImageIndex = 15
        OnClick = CClick
      end
      object O: TMenuItem
        Caption = 'Dok'#252'man'
        ImageIndex = 15
        OnClick = CClick
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object BuDkmzelBlmeKopyala1: TMenuItem
      Caption = 'Bu D'#246'k'#252'm'#252' "'#214'zel" B'#246'l'#252'me Kopyala '
      ImageIndex = 10
      OnClick = BuDkmzelBlmeKopyala1Click
    end
  end
  object DtsDokumler: TDataSource
    DataSet = TabDokum
    Left = 425
    Top = 117
  end
  object OpenDialog1: TOpenDialog
    InitialDir = 'c:\'
    Left = 529
    Top = 231
  end
  object PopupMenu2: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupMenu2Popup
    Left = 572
    Top = 163
    object OrjinalExcel1: TMenuItem
      Caption = 'Orjinal Excel'
      ImageIndex = 32
      Visible = False
      OnClick = OrjinalExcel1Click
    end
    object Excel1: TMenuItem
      Caption = 'Excel'
      ImageIndex = 8
      OnClick = Excel1Click
    end
    object Text1: TMenuItem
      Caption = 'Text'
      ImageIndex = 5
      OnClick = Text1Click
    end
    object HTML1: TMenuItem
      Caption = 'HTML'
      ImageIndex = 7
      OnClick = HTML1Click
    end
    object XML1: TMenuItem
      Caption = 'XML'
      ImageIndex = 16
      OnClick = XML1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CariKartAcMenu: TMenuItem
      Tag = 1
      Caption = 'Cari Kart'#305'n'#305' A'#231
      ImageIndex = 35
      Visible = False
      OnClick = CariKartAcMenuClick
    end
    object StokKartAcMenu: TMenuItem
      Tag = 2
      Caption = 'Stok Kart'#305'n'#305' A'#231
      ImageIndex = 12
      Visible = False
      OnClick = CariKartAcMenuClick
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 373
    Top = 161
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
    end
  end
  object GridPopupMenu: TcxGridPopupMenu
    Grid = DBGrid1
    PopupMenus = <
      item
        GridView = DBTable
        HitTypes = [gvhtCell, gvhtExpandButton, gvhtRecord]
        Index = 0
        PopupMenu = PopupMenu2
      end>
    Left = 484
    Top = 160
  end
  object TabDokum: TFDQuery
    BeforeEdit = TabDokumBeforeEdit
    BeforePost = TabDokumBeforePost
    AfterPost = TabDokumAfterPost
    AfterScroll = TabDokumAfterScroll
    OnNewRecord = TabDokumNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @MODUL nvarchar(5),@ROL int,@STNDRT bit, @DRM int'
      'set @MODUL=:Mod'
      'set @ROL=:Rol'
      'set @STNDRT=:Stn'
      'set @DRM=:Drm'
      ''
      'SELECT D.*,Y.* FROM'
      #9'DOKUMLER D left outer join'
      #9'YETKI Y on'
      
        #9#9'D.ID=convert(int,substring(convert(nvarchar(20),Y.MODULID),5,1' +
        '5)) and'
      #9#9'Y.MODULID like '#39'__99_%'#39' and'
      #9#9'isnull(Y.ROLID,0)=@ROL and'
      #9#9'isnull(Y.TUR,0)=1 and'
      #9#9'isnull(Y.HAK,0)=1'
      'WHERE D.MODUL LIKE @MODUL'
      'and STANDART=@STNDRT'
      'and isnull(PRGVERSIYON,0)>=0'
      'and DURUM>=@DRM'
      'and 1=case'
      #9'when @ROL=-1 then 1 '
      'when (select TY from ROLLER where ID = @ROL)=1 then 1'
      #9'when Y.HAK=1 then 1'
      #9'else 0 end'
      ''
      'ORDER BY GRUBU,RAPORADI')
    Left = 164
    Top = 299
    ParamData = <
      item
        Name = 'Mod'
        Size = -1
        Value = Null
      end
      item
        Name = 'Rol'
        Size = -1
        Value = Null
      end
      item
        Name = 'Stn'
        Size = -1
        Value = Null
      end
      item
        Name = 'Drm'
        Size = -1
        Value = Null
      end>
  end
  object TabKosul: TFDQuery
    BeforeEdit = TabKosulBeforeEdit
    BeforePost = TabKosulBeforePost
    AfterPost = TabKosulAfterPost
    OnNewRecord = TabKosulNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM KOSULLAR WHERE DOKUMID = :DID ORDER BY ID')
    Left = 103
    Top = 300
    ParamData = <
      item
        Name = 'DID'
        Size = -1
        Value = Null
      end>
  end
  object qryListe: TFDQuery
    Connection = Tablo.FDCnn
    Left = 224
    Top = 302
  end
  object dsListe: TDataSource
    DataSet = qryListe
    Left = 342
    Top = 364
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 437
    Top = 300
  end
  object TabKomut: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ' set nocount on'
      'DECLARE @RAPORADI VARCHAR(50)'
      'SET @RAPORADI = '#39#304#351'lem Say'#305#39
      'SELECT CONVERT( TEXT,ALAN ) FROM ('
      ''
      
        'SELECT  ALAN = '#39'DELETE FROM AYARLAR  WHERE RAPORADI LIKE '#39#39#39'+ @R' +
        'APORADI +'#39#39#39#39'  '
      'UNION'
      'SELECT  ALAN = '
      
        #39'INSERT INTO AYARLAR (RAPORADI, SIRANO, ALANTURU, TABLO, ALANADI' +
        ', BANDNO, SOL, UST, EN, BOY, FONT, PUNTO, RENK, OZELLIK, YANASIK' +
        ', TRANSPARENT,[FORMAT] ) VALUES('#39'+'
      
        'CASE WHEN RAPORADI    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (RAPORADI , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHAR(3' +
        '9) END + CHAR(44)+ '
      
        'CASE WHEN SIRANO      IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  SIRANO     ) END + CHAR(44) + '
      
        'CASE WHEN ALANTURU    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (ALANTURU     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN TABLO       IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (TABLO        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN ALANADI     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (ALANADI      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN BANDNO      IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  BANDNO     ) END + CHAR(44) + '
      
        'CASE WHEN SOL         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  SOL        ) END + CHAR(44) + '
      
        'CASE WHEN UST         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  UST        ) END + CHAR(44) + '
      
        'CASE WHEN EN          IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  EN         ) END + CHAR(44) + '
      
        'CASE WHEN BOY         IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  BOY        ) END + CHAR(44) + '
      
        'CASE WHEN FONT        IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (FONT        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHA' +
        'R(39) END + CHAR(44)+ '
      
        'CASE WHEN PUNTO       IS NULL THEN '#39'NULL'#39' ELSE CONVERT(VARCHAR, ' +
        '  PUNTO        ) END + CHAR(44) + '
      
        'CASE WHEN RENK        IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (RENK        , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CHA' +
        'R(39) END + CHAR(44)+ '
      
        'CASE WHEN OZELLIK     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (OZELLIK      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN YANASIK     IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (YANASIK      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN TRANSPARENT IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E (TRANSPARENT  , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + CHAR(44)+ '
      
        'CASE WHEN [FORMAT]    IS NULL THEN '#39'NULL'#39' ELSE CHAR(39) + REPLAC' +
        'E ([FORMAT]     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + CH' +
        'AR(39) END + '#39')'#39'+CHAR(13)+CHAR(10)'
      'FROM AYARLAR'
      'WHERE RAPORADI LIKE @RAPORADI'
      ''
      'UNION'
      'SELECT ALAN = '
      
        #39'DELETE FROM DOKUMLER WHERE RAPORADI LIKE '#39#39#39'+ RAPORADI +'#39#39#39' '#39'+ ' +
        'CHAR(13) + CHAR(10)'
      'FROM DOKUMLER'
      'WHERE SQL NOT LIKE '#39'%\RTF1\%'#39
      'AND RAPORADI LIKE @RAPORADI'
      'UNION'
      'SELECT ALAN = '
      
        #39'INSERT INTO DOKUMLER (RAPORADI,GRUBU,MODUL,ACIKLAMA,FIELDLIST,S' +
        'QL,SIRALAMA1,YON1,SIRALAMA2,YON2,DOKUMTIPI,AYNIKAYITLAR,ETIKETLI' +
        'ST,GRUPBY,EKBAGLIST) VALUES('#39' + '
      
        'CASE WHEN RAPORADI     IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (RAPORADI      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN GRUBU        IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (GRUBU         , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN MODUL        IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (MODUL         , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN ACIKLAMA     IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (ACIKLAMA      , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN FIELDLIST    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),FIELDLIST   ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN SQL          IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),SQL        ), CHAR(39) ,CHAR' +
        '(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR(' +
        '10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN SIRALAMA1    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (SIRALAMA1     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN YON1         IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (YON1          , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN SIRALAMA2    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (SIRALAMA2     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN YON2         IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (YON2          , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN DOKUMTIPI    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (DOKUMTIPI     , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN AYNIKAYITLAR IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (AYNIKAYITLAR  , CHAR(39) ,CHAR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)) + ' +
        'CHAR(39) END + CHAR(44)+ '
      
        'CASE WHEN ETIKETLIST   IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),ETIKETLIST  ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN GRUPBY       IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),GRUPBY      ), CHAR(39) ,CHA' +
        'R(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHAR' +
        '(10)+'#39#39#39') + CHAR(39) END + CHAR(44)+'
      
        'CASE WHEN EKBAGLIST    IS NULL THEN '#39#39#39#39#39#39' ELSE CHAR(39) + REPLA' +
        'CE (REPLACE ( CONVERT(VARCHAR(8000),EKBAGLIST    ), CHAR(39) ,CH' +
        'AR(39)+'#39'+CHAR(39)+'#39'+CHAR(39)),CHAR(13)+CHAR(10),'#39#39#39'+CHAR(13)+CHA' +
        'R(10)+'#39#39#39') + CHAR(39) END +'#39')'#39'+ CHAR(13) + CHAR(10)'
      'FROM DOKUMLER'
      'WHERE SQL NOT LIKE '#39'%\rtf1\%'#39
      'and raporad'#305' LIKE @RAPORADI'
      ''
      'UNION'
      ''
      'select alan = '
      
        #39'DELETE FROM KOSULLAR WHERE RAPORADI LIKE '#39#39#39'+ raporad'#305' +'#39#39#39' '#39'+ ' +
        'char(13) + char(10)'
      'FROM KOSULLAR'
      'where raporad'#305' LIKE @RAPORADI'
      'UNION'
      ''
      'SELECT '
      
        #39'INSERT INTO KOSULLAR (RAPORADI, SIRANO, BAGLAC, TABLO, ALAN, ES' +
        'ITLIK, DEGER, COMBOICERIK) VALUES('#39'+'
      
        'case when RAPORADI    is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (RAPORADI      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + c' +
        'har(39) end + char(44)+ '
      
        'case when SIRANO      is NULL then '#39'NULL'#39' else convert(varchar, ' +
        '  SIRANO      ) end + char(44) + '
      
        'case when BAGLAC      is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (BAGLAC      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when TABLO      is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (TABLO        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when ALAN       is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (ALAN        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + char' +
        '(39) end + char(44)+ '
      
        'case when ESITLIK    is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (ESITLIK      , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when DEGER      is NULL then '#39'NULL'#39' else char(39) + REPLACE' +
        ' (DEGER        , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + cha' +
        'r(39) end + char(44)+ '
      
        'case when COMBOICERIK is NULL then '#39'NULL'#39' else char(39) + REPLAC' +
        'E (COMBOICERIK  , char(39) ,char(39)+'#39'+char(39)+'#39'+char(39)) + ch' +
        'ar(39) end + '#39')'#39'+char(13)+ char(10)'
      'FROM KOSULLAR'
      'where raporad'#305' LIKE @RAPORADI'
      ') AS SORGU')
    Left = 280
    Top = 255
  end
  object Table1: TFDTable
    Connection = Tablo.FDCnn
    TableName = 'KIMLIK'
    Left = 371
    Top = 302
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 129
    Top = 192
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
    object MenuItem1: TMenuItem
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
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object PDFAyri: TMenuItem
        Tag = 11
        Caption = 'PDF Ayr'#305' Dosya'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object MenuItem2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
  end
  object frxSQLKomut: TfrxDBDataset
    UserName = 'SORGU'
    CloseDataSource = False
    DataSource = dsListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 740
    Top = 203
  end
end
