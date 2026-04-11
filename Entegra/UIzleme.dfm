object IzlemeDlg: TIzlemeDlg
  Left = 0
  Top = 0
  BorderIcons = [biMaximize]
  Caption = #304'zleme '#304#351'lemleri'
  ClientHeight = 459
  ClientWidth = 1125
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object GridFatIzlem: TcxGrid
    Left = 0
    Top = 86
    Width = 1125
    Height = 343
    Align = alClient
    TabOrder = 0
    object GridFatIzlemView: TcxGridDBTableView
      OnKeyUp = GridFatIzlemViewKeyUp
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
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridFatIzlemViewCanFocusRecord
      OnCellClick = GridFatIzlemViewCellClick
      OnCellDblClick = GridFatIzlemViewCellDblClick
      DataController.DataSource = DtsIzlem
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.0000;-,0.0000'
          Kind = skSum
          Column = GridFatIzlemViewMIKTAR
          DisplayText = ',0.0000;-,0.0000'
        end
        item
          Format = ',0.0000;-,0.0000'
          Kind = skSum
          Column = GridFatIzlemViewDURUM
          DisplayText = ',0.0000;-,0.0000'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnCycle = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Inserting = False
      OptionsSelection.MultiSelect = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      object GridFatIzlemViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridFatIzlemViewSERINO: TcxGridDBColumn
        Caption = 'Seri No'
        DataBinding.FieldName = 'SERINO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 128
      end
      object GridFatIzlemViewLOTNO: TcxGridDBColumn
        Caption = 'Lot No'
        DataBinding.FieldName = 'LOTNO'
        DataBinding.IsNullValueType = True
        Width = 167
      end
      object GridFatIzlemViewSKT: TcxGridDBColumn
        DataBinding.FieldName = 'SKT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        RepositoryItem = Tablo.cxEditRepository1DateItem1
        Width = 83
      end
      object GridFatIzlemViewURT: TcxGridDBColumn
        Caption = #220'RT'
        DataBinding.FieldName = 'URT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Width = 75
      end
      object GridFatIzlemViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.0000;-,0.0000'
        Options.Editing = False
        Width = 121
      end
      object GridFatIzlemViewSEC: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.FieldName = 'SEC'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.OnChange = GridFatIzlemViewSECPropertiesChange
        RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
        Width = 78
      end
      object GridFatIzlemViewMIKTAR: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'KALAN'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyAdetGenel
        Width = 197
      end
    end
    object GridFatIzlemLevel1: TcxGridLevel
      GridView = GridFatIzlemView
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 429
    Width = 1125
    Height = 30
    Align = alBottom
    TabOrder = 1
    object KaydetTus: TBitBtn
      Left = 239
      Top = 6
      Width = 76
      Height = 24
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
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      OnClick = KaydetTusClick
      IsControl = True
    end
    object CancelBtn: TBitBtn
      Left = 321
      Top = 4
      Width = 75
      Height = 24
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
    Top = 62
    Width = 1125
    Height = 24
    Margins.Bottom = 0
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
      ImageName = 'PngImage0'
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 86
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      ImageName = 'PngImage1'
      OnClick = SilTusClick
    end
    object ToolButton2: TToolButton
      Left = 172
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 5
      ImageName = 'PngImage5'
      Style = tbsSeparator
    end
    object KaydetBtn: TToolButton
      Left = 180
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      ImageName = 'PngImage2'
      OnClick = KaydetBtnClick
    end
    object IptalBtn: TToolButton
      Left = 266
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      ImageName = 'PngImage3'
      OnClick = IptalBtnClick
    end
    object BtnTopluSerino: TToolButton
      Left = 352
      Top = 0
      Caption = 'Toplu Serino'
      DropdownMenu = PopupSeriNo
      ImageIndex = 4
      ImageName = 'PngImage4'
    end
    object ToolButton1: TToolButton
      Left = 438
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      ImageName = 'PngImage4'
      Style = tbsSeparator
    end
    object BtnLotNoVer: TToolButton
      Left = 446
      Top = 0
      Caption = 'LotNo Ver'
      ImageIndex = 4
      ImageName = 'PngImage4'
      OnClick = BtnLotNoVerClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1125
    Height = 62
    Align = alTop
    TabOrder = 3
    object LblGerekliMiktar: TcxLabel
      Left = 5
      Top = 3
      Caption = ' Gerekli Miktar:'
      Transparent = True
    end
    object LblSecilenMiktar: TcxLabel
      Left = 5
      Top = 20
      Caption = ' Se'#231'ilen:'
      Transparent = True
    end
    object ChecktumKayitlar: TcxCheckBox
      Left = 254
      Top = 11
      Caption = 'T'#252'm Durumlar'#305' G'#246'ster'
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
      Properties.ValueGrayed = 'False'
      Properties.OnEditValueChanged = ChecktumKayitlarPropertiesEditValueChanged
      TabOrder = 2
      Visible = False
    end
    object EditAra: TcxTextEdit
      Left = 255
      Top = 35
      Properties.OnEditValueChanged = EditAraPropertiesEditValueChanged
      TabOrder = 3
      OnKeyUp = EditAraKeyUp
      Width = 168
    end
    object cxLabel1: TcxLabel
      Left = 218
      Top = 37
      Caption = 'Ara'
      OnDblClick = cxLabel1DblClick
    end
    object EditBarkod: TcxTextEdit
      Left = 554
      Top = 35
      Properties.OnEditValueChanged = EditAraPropertiesEditValueChanged
      TabOrder = 5
      OnKeyUp = EditBarkodKeyUp
      Width = 321
    end
    object cxLabel2: TcxLabel
      Left = 556
      Top = 18
      Caption = 'Barkod Giri'#351'i'
      OnDblClick = cxLabel1DblClick
    end
    object cxLabel3: TcxLabel
      Left = 429
      Top = 18
      Caption = 'Barkod Se'#231'imi'
      OnDblClick = cxLabel1DblClick
    end
    object ComboBarkod: TcxImageComboBox
      Left = 429
      Top = 35
      RepositoryItem = Tablo.repStokKartBarkodTipi
      Properties.Items = <>
      Properties.OnCloseUp = ComboBarkodPropertiesCloseUp
      Properties.OnInitPopup = ComboBarkodPropertiesInitPopup
      TabOrder = 8
      Width = 121
    end
    object LabelSec: TcxLabel
      Left = 888
      Top = 5
      Cursor = crHandPoint
      Caption = #304#351'aretlileri Se'#231
      Style.TextColor = clNavy
      Properties.LabelEffect = cxleFun
      Properties.LabelStyle = cxlsRaised
      Properties.PenWidth = 2
      Transparent = True
      OnClick = LabelSecClick
    end
    object cxLabel5: TcxLabel
      Left = 888
      Top = 21
      Cursor = crHandPoint
      Caption = #304#351'aretlilerin Se'#231'imini B'#305'rak'
      Style.TextColor = clNavy
      Properties.LabelEffect = cxleFun
      Properties.LabelStyle = cxlsRaised
      Properties.PenWidth = 2
      Transparent = True
      OnClick = LabelSecClick
    end
    object LblKalanMiktar: TcxLabel
      Left = 5
      Top = 38
      Cursor = crHandPoint
      Caption = ' Kalan:'
      Transparent = True
      OnClick = LblKalanMiktarClick
    end
  end
  object SQLGiren: TMemo
    Left = 42
    Top = 151
    Width = 401
    Height = 52
    Color = clBtnHighlight
    Lines.Strings = (
      'insert into :TabloAdi'
      '(STOKID, SERINO, DURUM, KALAN, SEC, LOTNO, SKT, URT,SERILOTID )'
      ''
      
        'SELECT SI1.STOKID,SERINO,DURUM=0.0,KALAN=SUM(KALAN),SEC=1,LOTNO,' +
        'SKT,URT,SERILOTID '
      ' from STOKIZLEME SI1 '
      ' INNER JOIN STOKSERILOT SSL ON SI1.SERILOTID = SSL.ID '
      ' where SI1.STOKID=@StokID and SI1.IZLEMTUR=@IzlemTur '
      'and SI1.BASLIKID=@BaslikID and SI1.SATIRID=@SatirID'
      'group by '#9'SI1.STOKID, SERILOTID, SERINO,LOTNO,SKT,URT')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object SQLDonusKaynak: TMemo
    Left = 474
    Top = 281
    Width = 401
    Height = 52
    Color = clBtnHighlight
    Lines.Strings = (
      '  insert into :TabloAdi'
      ''
      
        'SELECT  STOKID, SERINO,DURUM=sum(DURUM),KALAN=sum(KALAN),SEC=0,L' +
        'OTNO, SKT, URT, IZLEMID=0, BASLIKID=0, SATIRID=0,UPDID=0,SERILOT' +
        'ID=0  from'
      ' ('
      ' '
      
        '  SELECT  SI1.STOKID,SSL.SERINO,DURUM=abs(SI1.KALAN),KALAN=abs(S' +
        'I1.KALAN),SEC=0,SSL.LOTNO,SSL.SKT,SSL.URT, SERILOTID=SSL.ID '
      '--, SI1.BASLIKID,SI1.SATIRID,SI1.DONUSID '
      ' from STOKIZLEME SI1 '
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '
      ' where '
      ' SI1.SATIRID=@SatirID '
      ''
      ''
      ' union all'
      
        ' SELECT  SI1.STOKID,SSL.SERINO,DURUM=abs(SI2.KALAN),KALAN=abs(SI' +
        '2.KALAN),SEC=0,SSL.LOTNO,SSL.SKT, SSL.URT, SERILOTID=SSL.ID '
      ' --, SI1.BASLIKID,SI1.SATIRID,SI1.DONUSID, SERILOTID=SSL.ID  '
      ' from STOKIZLEME SI1 '
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '
      ' left join STOKIZLEME SI2 on SI1.ID=SI2.DONUSID '
      ' where '
      ' SI1.SATIRID=@SatirID '
      ' ) as Liste'
      '  where DURUM>0.0'
      ' group by  STOKID, SERINO,KALAN,SEC,LOTNO, SKT, URT ')
    TabOrder = 5
    Visible = False
    WordWrap = False
  end
  object SQLCikanUpdate: TMemo
    Left = 34
    Top = 307
    Width = 409
    Height = 66
    Color = clBtnHighlight
    Lines.Strings = (
      ''
      'update Tmp set KALAN=X.DURUM, SEC=1, UPDID= X.ID'
      '--select Tmp.*,X.DURUM,X.ID'
      ''
      'from :TabloAdi Tmp inner join '
      ''
      '('
      'select * from ('
      ''
      
        'SELECT SI1.STOKID, DURUM=SUM(SI1.ADET), SERINO,LOTNO,SKT,URT,SI1' +
        '.ID '
      ' from STOKIZLEME SI1'
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID'
      '-- inner join STOKIZLEMEDEPO SD on SI1.ID=SD.IZLEMID '
      
        '--and SD.ADET= (select top 1 SD2.ADET from STOKIZLEMEDEPO SD2 wh' +
        'ere SD2.IZLEMID=SD.IZLEMID)'
      ' where SI1.STOKID=@StokID --and SI1.IZLEMTUR=@IzlemTur '
      '   and SI1.BASLIKID=@BaslikID and SI1.SATIRID=@SatirID '
      'group by '#9'SI1.STOKID,SERINO,LOTNO,SKT,URT,SI1.ID   '
      ''
      ''
      ') as List where DURUM >= 0.0 '
      ''
      ') as x ON ('
      
        '    X.SERINO = TMP.SERINO COLLATE SQL_Latin1_General_CP1254_CI_A' +
        'S'
      '    OR (X.SERINO IS NULL AND TMP.SERINO IS NULL)'
      ')'
      'AND ('
      '    X.LOTNO = TMP.LOTNO COLLATE SQL_Latin1_General_CP1254_CI_AS'
      '    OR (X.LOTNO IS NULL AND TMP.LOTNO IS NULL)'
      ')'
      'AND ('
      '    X.SKT = TMP.SKT'
      '    OR (X.SKT IS NULL AND TMP.SKT IS NULL)'
      ')'
      ''
      ''
      '--  select * from ##TmpIzleme_52_20181231093356633'
      '--  delete from ##TmpIzleme_52_20181231093356633')
    TabOrder = 6
    Visible = False
    WordWrap = False
  end
  object SQLDonusCikanHedef_2: TMemo
    Left = 449
    Top = 151
    Width = 401
    Height = 52
    Color = clBtnHighlight
    Lines.Strings = (
      'insert into :TabloAdi'
      
        '(STOKID, SERINO, DURUM, KALAN, SEC, LOTNO, SKT, URT,IZLEMID, BAS' +
        'LIKID, SATIRID,UPDID, SERILOTID )'
      
        ' SELECT  SI1.STOKID,SSL.SERINO,DURUM=abs(SDI.KALAN),KALAN=SI1.KA' +
        'LAN,SEC=0,SSL.LOTNO,SSL.SKT, SSL.URT, '
      ' SI1.ID, SI1.BASLIKID,SI1.SATIRID,SI1.DONUSID, SERILOTID=SSL.ID '
      ' from STOKIZLEME SI1 '
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '
      ' INNER JOIN STOKDURUMIZLEME SDI ON SDI.SERILOTID=SI1.SERILOTID'
      ' where '
      ' SI1.SATIRID=@SatirID')
    TabOrder = 7
    Visible = False
    WordWrap = False
  end
  object SQLDonusCikanHedefUpdate: TMemo
    Left = 449
    Top = 209
    Width = 401
    Height = 52
    Color = clBtnHighlight
    Lines.Strings = (
      ''
      
        'update  tmp  SET DURUM=DURUM+ADET, KALAN=ADET,SEC=1, UPDID= IZLE' +
        'M1 '
      '--select DURUM=DURUM+ADET, KALAN=ADET,SEC=1,IZLEMID= IZLEM1 '
      'from  :TabloAdi Tmp '
      'inner join ('
      
        ' SELECT SI1.STOKID,ADET=SI1.ADET,SERINO,LOTNO,SKT,URT,IZLEM1=SI1' +
        '.ID '
      ' from STOKIZLEME SI1  '
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '
      ' where '
      '-- SI1.BASLIKID=@BaslikID  AND'
      ' SI1.SATIRID=@SatirID '
      ' ) as x'
      ''
      'ON ('
      
        '    X.SERINO = TMP.SERINO COLLATE SQL_Latin1_General_CP1254_CI_A' +
        'S'
      '    OR (X.SERINO IS NULL AND TMP.SERINO IS NULL)'
      ')'
      'AND ('
      '    X.LOTNO = TMP.LOTNO COLLATE SQL_Latin1_General_CP1254_CI_AS'
      '    OR (X.LOTNO IS NULL AND TMP.LOTNO IS NULL)'
      ')'
      'AND ('
      '    X.SKT = TMP.SKT'
      '    OR (X.SKT IS NULL AND TMP.SKT IS NULL)'
      ')')
    TabOrder = 8
    Visible = False
    WordWrap = False
  end
  object SQLCikan: TMemo
    Left = 42
    Top = 209
    Width = 401
    Height = 92
    Color = clBtnHighlight
    Lines.Strings = (
      ''
      '  insert into :TabloAdi'
      ''
      
        '(STOKID,SERILOTID, SERINO, DURUM, KALAN, SEC, LOTNO, SKT, URT,IZ' +
        'LEMID, BASLIKID, SATIRID )'
      ''
      
        'select Toplam.STOKID, SERILOTID,SERINO, DURUM=SUM(DURUM), KALAN=' +
        '0.0,SEC=0,LOTNO,SKT,URT ,IZLEMID=0, BASLIKID=0, SATIRID=0 '
      'from ('
      '--stok durum izleme tablosunda '#351'u anki stok durumu getirelim'
      'select SD.STOKID, SERILOTID, DURUM=SD.KALAN'
      'from  STOKDURUMIZLEME SD '
      'where '
      'SD.STOKID=@StokID'
      'and DEPOID = @DepoID'
      
        'and ((@BaslikTur<>99 and SD.KALAN <> 0) or (@BaslikTur=99 and 1=' +
        '1)) '
      'union all'
      
        '--durumu '#231#305'k'#305#351' veya giri'#351' ne olduysa onu ekleyelim. '#199#305'k'#305#351' ise gi' +
        'ri'#351', Giri'#351' ise '#231#305'k'#305#351' yapmam'#305'z laz'#305'm'
      'SELECT SI1.STOKID,SERILOTID, DURUM=-1.0*SUM(SD.ADET)'
      ' from STOKIZLEME SI1'
      ' inner join STOKIZLEMEDEPO SD ON SI1.ID=SD.IZLEMID'
      ' where '
      '   SI1.SATIRID=@SatirID '
      '   and DEPOID = @DepoID'
      'group by '#9'SI1.STOKID,SERILOTID'
      ''
      '  '
      ')as Toplam '
      'inner join [STOKSERILOT] SSL ON Toplam.SERILOTID=SSL.ID '
      'group by '#9'Toplam.STOKID,SERILOTID,SERINO,LOTNO,SKT,URT')
    TabOrder = 9
    Visible = False
    WordWrap = False
  end
  object Memo1: TMemo
    Left = 874
    Top = 151
    Width = 401
    Height = 52
    Color = clBtnHighlight
    TabOrder = 10
    Visible = False
    WordWrap = False
  end
  object SQLDonusCikanHedef: TMemo
    Left = 474
    Top = 339
    Width = 401
    Height = 52
    Color = clBtnHighlight
    Lines.Strings = (
      'insert into :TabloAdi'
      
        '(STOKID, SERINO, DURUM, KALAN, SEC, LOTNO, SKT, URT,IZLEMID, BAS' +
        'LIKID, SATIRID,UPDID, SERILOTID )'
      
        ' SELECT  SI1.STOKID,SSL.SERINO,DURUM=abs(SI1.KALAN),KALAN=0.0,SE' +
        'C=0,SSL.LOTNO,SSL.SKT, SSL.URT, '
      ' SI1.ID, SI1.BASLIKID,SI1.SATIRID,SI1.DONUSID, SERILOTID=SSL.ID '
      ' from STOKIZLEME SI1 '
      ' INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '
      ' where '
      ' SI1.SATIRID=@SatirID')
    TabOrder = 11
    Visible = False
    WordWrap = False
  end
  object TabIzlem: TFDQuery
    AfterOpen = TabIzlemAfterOpen
    BeforeEdit = TabIzlemBeforeEdit
    BeforePost = TabIzlemBeforePost
    AfterPost = TabIzlemAfterPost
    BeforeDelete = TabIzlemBeforeDelete
    AfterDelete = TabIzlemAfterDelete
    OnNewRecord = TabIzlemNewRecord
    Connection = Tablo.FDCnn
    Left = 40
    Top = 89
  end
  object DtsIzlem: TDataSource
    DataSet = TabIzlem
    OnStateChange = DtsIzlemStateChange
    Left = 88
    Top = 89
  end
  object PopupSeriNo: TPopupMenu
    Left = 264
    Top = 104
    object Listedentoplualma1: TMenuItem
      Caption = 'Listeden toplu alma'
      OnClick = Listedentoplualma1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Balamabitivererek1: TMenuItem
      Caption = 'Ba'#351'lama no vererek'
      OnClick = Balamabitivererek1Click
    end
  end
end
