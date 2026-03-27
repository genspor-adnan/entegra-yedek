object UTSKontrolDlg: TUTSKontrolDlg
  Left = 0
  Top = 0
  BorderIcons = [biMaximize]
  Caption = #304'zleme '#304#351'lemleri'
  ClientHeight = 460
  ClientWidth = 1129
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
  object GridUTSKontrol: TcxGrid
    Left = 0
    Top = 68
    Width = 1129
    Height = 362
    Align = alClient
    TabOrder = 0
    object GridUTSKontrolView: TcxGridDBTableView
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
      OnCanFocusRecord = GridUTSKontrolViewCanFocusRecord
      DataController.DataSource = DtsUTSKontrol
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.0000;-,0.0000'
          Kind = skSum
          DisplayText = ',0.0000;-,0.0000'
        end
        item
          Format = ',0.0000;-,0.0000'
          Kind = skSum
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
      object GridUTSKontrolViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUTSKontrolViewTARIH: TcxGridDBColumn
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        Width = 56
      end
      object GridUTSKontrolViewUNO: TcxGridDBColumn
        DataBinding.FieldName = 'UNO'
        DataBinding.IsNullValueType = True
        Width = 65
      end
      object GridUTSKontrolViewKOD: TcxGridDBColumn
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
        Width = 77
      end
      object GridUTSKontrolViewAD: TcxGridDBColumn
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        Width = 153
      end
      object GridUTSKontrolViewSERINO: TcxGridDBColumn
        Caption = 'Seri No'
        DataBinding.FieldName = 'SERINO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 52
      end
      object GridUTSKontrolViewLOTNO: TcxGridDBColumn
        Caption = 'Lot No'
        DataBinding.FieldName = 'LOTNO'
        DataBinding.IsNullValueType = True
        Width = 58
      end
      object GridUTSKontrolViewSKT: TcxGridDBColumn
        DataBinding.FieldName = 'SKT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        RepositoryItem = Tablo.cxEditRepository1DateItem1
        Width = 76
      end
      object GridUTSKontrolViewURT: TcxGridDBColumn
        Caption = #220'RT'
        DataBinding.FieldName = 'URT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Width = 72
      end
      object GridUTSKontrolViewADET: TcxGridDBColumn
        DataBinding.FieldName = 'ADET'
        DataBinding.IsNullValueType = True
        Width = 49
      end
      object GridUTSKontrolViewGELENADET: TcxGridDBColumn
        Caption = 'Gelen Adet'
        DataBinding.FieldName = 'GELENADET'
        DataBinding.IsNullValueType = True
        Width = 74
      end
      object GridUTSKontrolViewASKIADET: TcxGridDBColumn
        Caption = 'Ask'#305' Adet'
        DataBinding.FieldName = 'ASKIADET'
        DataBinding.IsNullValueType = True
        Width = 66
      end
      object GridUTSKontrolViewACIKADET: TcxGridDBColumn
        Caption = 'A'#231#305'k'
        DataBinding.FieldName = 'ACIKADET'
        DataBinding.IsNullValueType = True
        Width = 71
      end
      object GridUTSKontrolViewGELENURT: TcxGridDBColumn
        Caption = 'Gelen '#220'RT'
        DataBinding.FieldName = 'GELENURT'
        DataBinding.IsNullValueType = True
        Width = 85
      end
      object GridUTSKontrolViewGELENSKT: TcxGridDBColumn
        Caption = 'Gelen SKT'
        DataBinding.FieldName = 'GELENSKT'
        DataBinding.IsNullValueType = True
        Width = 90
      end
      object GridUTSKontrolViewSONUC: TcxGridDBColumn
        Caption = 'Sonu'#231
        DataBinding.FieldName = 'SONUC'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Images = Tablo.cxImageListPDKS
        Properties.Items = <
          item
            Description = '0'
            ImageIndex = 2
            Value = False
          end
          item
            Description = '1'
            ImageIndex = 1
            Value = True
          end>
        Width = 71
      end
      object GridUTSKontrolViewEKLEYEN: TcxGridDBColumn
        Caption = 'Ekleyen'
        DataBinding.FieldName = 'EKLEYEN'
        DataBinding.IsNullValueType = True
      end
    end
    object GridUTSKontrolLevel1: TcxGridLevel
      GridView = GridUTSKontrolView
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 430
    Width = 1129
    Height = 30
    Align = alBottom
    TabOrder = 1
  end
  object ToolBar5: TToolBar
    Left = 0
    Top = 44
    Width = 1129
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
    Visible = False
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      ImageName = 'PngImage0'
    end
    object SilTus: TToolButton
      Left = 86
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      ImageName = 'PngImage1'
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
    end
    object IptalBtn: TToolButton
      Left = 266
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      ImageName = 'PngImage3'
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
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1129
    Height = 44
    Align = alTop
    TabOrder = 3
    object CancelBtn: TBitBtn
      Left = 921
      Top = 11
      Width = 75
      Height = 24
      Cancel = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 2
      Images = Tablo.cxImageListPDKS
      Margin = 2
      ModalResult = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      OnClick = CancelBtnClick
      IsControl = True
    end
    object UTSKontrolBtn: TBitBtn
      Left = 12
      Top = 11
      Width = 141
      Height = 24
      Caption = #220'TS'#39'den Kontrol'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HotImageIndex = 1
      ImageIndex = 1
      Images = Tablo.cxImageListPDKS
      Margin = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      OnClick = UTSKontrolBtnClick
      IsControl = True
    end
    object LabelKontrolTarihi: TcxLabel
      Left = 159
      Top = 13
      Caption = 'Kontrol Tarihi : '
      Style.Shadow = False
      Style.TransparentBorder = True
      Transparent = True
    end
  end
  object SQLCikanUpdate: TMemo
    Left = 34
    Top = 267
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
      
        ') as x on x.SERINO = tmp.SERINO collate SQL_Latin1_General_CP125' +
        '4_CI_AS AND X.LOTNO = TMP.LOTNO collate SQL_Latin1_General_CP125' +
        '4_CI_AS'
      'AND X.SKT = TMP.skt'
      ''
      ''
      ''
      '--  select * from ##TmpIzleme_52_20181231093356633'
      '--  delete from ##TmpIzleme_52_20181231093356633')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object TabUTSKontrol: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabUTSKontrolAfterOpen
    ParamData = <>
    SQL.Strings = (
      
        'select UK.ID, UK.TARIH, SI.STOKID,UNO=S.URUNNO,S.KOD, AD=S.STOKA' +
        'DI , SLOT.LOTNO, SI.ADET, SLOT.URT, SLOT.SKT,'
      
        'UK.GELENADET, UK.ASKIADET,ACIKADET=UK.GELENADET - UK.ASKIADET, U' +
        'K.GELENURT, UK.GELENSKT, UK.SONUC,'
      'EKLEYEN=(select FIRMA from REHBER where ID=UK.EKLEYEN),'
      'UK.EKLEMETARIHI,'
      'DEGISTIREN = (select FIRMA from REHBER where ID=UK.DEGISTIREN),'
      'UK.DEGISTIRMETARIHI'
      
        'from UTSKONTROL UK inner join STOKIZLEME SI on SI.ID = UK.IZLEMI' +
        'D  '
      
        'inner join STOKLAR S on S.ID=SI.STOKID inner join STOKSERILOT SL' +
        'OT on SI.SERILOTID = SLOT.ID '
      'where BASLIKID=:FID'
      'and  S.BILDIRIM = 2'
      'order by SI.ID ')
    Left = 40
    Top = 89
  end
  object DtsUTSKontrol: TDataSource
    DataSet = TabUTSKontrol
    Left = 160
    Top = 97
  end
  object PopupSeriNo: TPopupMenu
    Left = 264
    Top = 104
    object Listedentoplualma1: TMenuItem
      Caption = 'Listeden toplu alma'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Balamabitivererek1: TMenuItem
      Caption = 'Ba'#351'lama no vererek'
    end
  end
end

