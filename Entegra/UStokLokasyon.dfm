object StokLokasyonDlg: TStokLokasyonDlg
  Left = 0
  Top = 0
  Caption = 'Lokasyon '#304#351'lemleri'
  ClientHeight = 468
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 44
    Width = 431
    Height = 397
    Align = alClient
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      OnKeyUp = cxGrid1DBTableView1KeyUp
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = True
      Navigator.Buttons.PriorPage.Visible = True
      Navigator.Buttons.Prior.Visible = True
      Navigator.Buttons.Next.Visible = True
      Navigator.Buttons.NextPage.Visible = True
      Navigator.Buttons.Last.Visible = True
      Navigator.Buttons.Insert.Visible = True
      Navigator.Buttons.Append.Visible = False
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.Edit.Visible = True
      Navigator.Buttons.Post.Visible = True
      Navigator.Buttons.Cancel.Visible = True
      Navigator.Buttons.Refresh.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = True
      Navigator.Buttons.GotoBookmark.Visible = True
      Navigator.Buttons.Filter.Visible = True
      DataController.DataSource = DtsLokasyon
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
          Column = cxGrid1DBTableView1MIKTAR
        end
        item
          Kind = skSum
        end
        item
          Kind = skSum
          Column = cxGrid1DBTableView1DURUM
        end
        item
          Kind = skSum
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnCycle = True
      OptionsData.Appending = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      object cxGrid1DBTableView1KOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cxGrid1DBTableView1Column1PropertiesButtonClick
        Width = 142
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cxGrid1DBTableView1Column1PropertiesButtonClick
        Options.Editing = False
        Width = 176
      end
      object cxGrid1DBTableView1DURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.ReadOnly = True
        Options.Editing = False
        Width = 65
      end
      object cxGrid1DBTableView1MIKTAR: TcxGridDBColumn
        Caption = 'Miktar'
        DataBinding.FieldName = 'MIKTAR'
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 54
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 441
    Width = 431
    Height = 27
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      431
      27)
    object KaydetTus: TBitBtn
      Left = 276
      Top = 1
      Width = 76
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'Kaydet'
      Default = True
      Enabled = False
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
      ModalResult = 1
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      OnClick = KaydetTusClick
      IsControl = True
    end
    object CancelBtn: TBitBtn
      Left = 353
      Top = 1
      Width = 75
      Height = 24
      Anchors = [akTop, akRight]
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
      ModalResult = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      OnClick = CancelBtnClick
      IsControl = True
    end
  end
  object ToolBar5: TToolBar
    Left = 0
    Top = 20
    Width = 431
    Height = 24
    Margins.Bottom = 0
    ButtonWidth = 47
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 2
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 47
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = SilTusClick
    end
    object ToolButton2: TToolButton
      Left = 94
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 5
      Style = tbsSeparator
    end
    object KaydetBtn: TToolButton
      Left = 102
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      OnClick = KaydetBtnClick
    end
    object IptalBtn: TToolButton
      Left = 149
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      OnClick = IptalBtnClick
    end
    object ToolButton1: TToolButton
      Left = 196
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 431
    Height = 20
    Align = alTop
    TabOrder = 3
    object LblGerekliMiktar: TcxLabel
      Left = 0
      Top = 1
      Caption = ' Gerekli Miktar:'
      Transparent = True
    end
    object LblSecileniMiktar: TcxLabel
      Left = 119
      Top = 1
      Caption = ' Se'#231'ilen Miktar:'
      Transparent = True
    end
  end
  object MemoGiris: TcxMemo
    Left = 56
    Top = 136
    Lines.Strings = (
      '--Giri'#351' lokasyon se'#231'imi!!'
      'declare @BelgeTur int, @BaslikID int, '
      '@SatirID int, @StokID int, '
      '@GDepoID int, @CDepoID int'
      'set @BelgeTur = :PBT'
      'set @BaslikID = :PBID'
      'set @SatirID = :PSID'
      'set @StokID = :PSTID'
      'set @GDepoID = :PGDepo'
      'set @CDepoID = :PCDepo'
      '--set @BelgeTur = 11 '
      '--set @BaslikID = 5'
      '--set @SatirID = 3'
      '--set @StokID = 28491'
      '--set @GDepoID = 5'
      '--set @CDepoID = 5'
      ''
      ';WITH TmpLokasyon AS'
      '('
      #9'SELECT ID,KOD,ACIKLAMA=CONVERT(NVARCHAR(500),ACIKLAMA)'
      
        #9'FROM LOKASYON WHERE YERI=349 and YERID=@GDepoID and KOD not lik' +
        'e '#39'%.%'#39
      #9'UNION ALL'
      
        #9'SELECT L.ID,L.KOD,ACIKLAMA=CONVERT(NVARCHAR(500),T.ACIKLAMA+'#39'//' +
        #39'+L.ACIKLAMA)'
      #9'FROM LOKASYON L'
      #9'INNER JOIN TmpLokasyon T ON L.USTKOD = T.KOD'
      #9'WHERE YERI=349 and YERID=@GDepoID and L.KOD like '#39'%.%'#39
      ')'
      'insert into <TabloAdi>'
      '(GIRISLOKASYONID,CIKISLOKASYONID,KOD,ACIKLAMA,DURUM,MIKTAR)'
      'SELECT '
      #9'GIRISLOKASYONID=ID,CIKISLOKASYONID=0,KOD,ACIKLAMA,DURUM=0.0,'
      
        #9'MIKTAR=isnull((select sum(MIKTAR) from STOKLOKASYON SL1 where S' +
        'L1.STOKID=@StokID and SL1.BELGETUR=@BelgeTur and SL1.BASLIKID=@B' +
        'aslikID and SL1.SATIRID=@SatirID and SL1.GIRISLOKASYONID=T.ID),0' +
        '.0) '
      'FROM TmpLokasyon T'
      
        'where isnull((select sum(MIKTAR) from STOKLOKASYON SL1 where SL1' +
        '.STOKID=@StokID and SL1.BELGETUR=@BelgeTur and SL1.BASLIKID=@Bas' +
        'likID and SL1.SATIRID=@SatirID and SL1.GIRISLOKASYONID=T.ID),0.0' +
        ') <> 0.0'
      '')
    Properties.WordWrap = False
    TabOrder = 4
    Visible = False
    Height = 89
    Width = 185
  end
  object MemoCikis: TcxMemo
    Left = 195
    Top = 176
    Lines.Strings = (
      '--'#199#305'k'#305#351' lokasyon se'#231'imi!!'
      'declare @BelgeTur int, @BaslikID int, '
      '@SatirID int, @StokID int, '
      '@GDepoID int, @CDepoID int'
      'set @BelgeTur = :PBT'
      'set @BaslikID = :PBID'
      'set @SatirID = :PSID'
      'set @StokID = :PSTID'
      'set @GDepoID = :PGDepo'
      'set @CDepoID = :PCDepo'
      '--set @BelgeTur = 11 '
      '--set @BaslikID = 5'
      '--set @SatirID = 3'
      '--set @StokID = 28491'
      '--set @GDepoID = 5'
      '--set @CDepoID = 5'
      ''
      ''
      ';WITH TmpLokasyon AS'
      '('
      #9'SELECT ID,KOD,ACIKLAMA=CONVERT(NVARCHAR(500),ACIKLAMA)'
      
        #9'FROM LOKASYON WHERE YERI=349 and YERID=@CDepoID and KOD not lik' +
        'e '#39'%.%'#39
      #9'UNION ALL'
      
        #9'SELECT L.ID,L.KOD,ACIKLAMA=CONVERT(NVARCHAR(500),T.ACIKLAMA+'#39' -' +
        ' '#39'+L.ACIKLAMA)'
      #9'FROM LOKASYON L'
      #9'INNER JOIN TmpLokasyon T ON L.USTKOD = T.KOD'
      #9'WHERE YERI=349 and YERID=@CDepoID and L.KOD like '#39'%.%'#39
      ')'
      'insert into <TabloAdi>'
      '(GIRISLOKASYONID,CIKISLOKASYONID,KOD,ACIKLAMA,DURUM,MIKTAR)'
      'SELECT '
      
        #9'GIRISLOKASYONID=0,CIKISLOKASYONID=ID,KOD,ACIKLAMA,DURUM=Fn.Mikt' +
        'ar,'
      
        #9'MIKTAR=isnull((select sum(MIKTAR) from STOKLOKASYON SL1 where S' +
        'L1.STOKID=@StokID and SL1.BELGETUR=@BelgeTur and SL1.BASLIKID=@B' +
        'aslikID and SL1.SATIRID=@SatirID and SL1.CIKISLOKASYONID=T.ID),0' +
        '.0) '
      'FROM TmpLokasyon T inner join '
      
        ' [dbo].[fn_STOK_LOKASYON_DURUM] (@StokID,@CDepoID) Fn on Fn.Loka' +
        'syon=T.ID'
      
        'where (Fn.Miktar <> 0.0) or (isnull((select sum(MIKTAR) from STO' +
        'KLOKASYON SL1 where SL1.STOKID=@StokID and SL1.BELGETUR=@BelgeTu' +
        'r and SL1.BASLIKID=@BaslikID and SL1.SATIRID=@SatirID and SL1.CI' +
        'KISLOKASYONID=T.ID),0.0) <> 0.0)'
      ''
      ''
      ' --select * from STOKLOKASYON')
    Properties.WordWrap = False
    TabOrder = 5
    Visible = False
    Height = 89
    Width = 185
  end
  object Tablokasyon: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TablokasyonAfterOpen
    BeforePost = TablokasyonBeforePost
    AfterPost = TablokasyonAfterPost
    AfterDelete = TablokasyonAfterDelete
    OnNewRecord = TablokasyonNewRecord
    ParamData = <>
    SQL.Strings = (
      'select '
      #9'STOKID,'
      #9'BELGETUR,'
      #9'BASLIKID,'
      #9'SATIRID,'
      #9'GIRISDEPO,'
      #9'CIKISDEPO,'
      #9'MIKTAR,'
      #9'GIRISLOKASYONID,'
      #9'CIKISLOKASYONID'
      'from '
      #9'STOKLOKASYON'
      'where '
      #9'BELGETUR = :PBT and'
      #9'BASLIKID = :PBID and'
      #9'SATIRID = :PSID and'
      #9'STOKID = :PSTID')
    Left = 72
    Top = 49
  end
  object DtsLokasyon: TDataSource
    DataSet = Tablokasyon
    OnStateChange = DtsLokasyonStateChange
    Left = 112
    Top = 69
  end
end


