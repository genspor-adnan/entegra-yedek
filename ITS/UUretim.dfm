object UretimDlg: TUretimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #220'retim'
  ClientHeight = 490
  ClientWidth = 1027
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlAlt: TPanel
    Left = 0
    Top = 35
    Width = 1027
    Height = 54
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 924
    object lblHataMesaj: TcxLabel
      Left = 4
      Top = 39
      AutoSize = False
      Style.TextColor = clRed
      Properties.WordWrap = True
      Transparent = True
      Height = 38
      Width = 375
    end
    object cxDBLabel1: TcxDBLabel
      Left = 606
      Top = 3
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Transparent = True
      Height = 21
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 565
      Top = 3
      Caption = 'Tarih :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 11
      Top = 3
      Caption = 'Id :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel2: TcxDBLabel
      Left = 38
      Top = 3
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Transparent = True
      Height = 21
      Width = 35
    end
    object cxLabel9: TcxLabel
      Left = 11
      Top = 26
      Caption = 'Firma :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel3: TcxDBLabel
      Left = 54
      Top = 26
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object cxDBLabel4: TcxDBLabel
      Left = 298
      Top = 26
      DataBinding.DataField = 'STOKADI'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object cxLabel10: TcxLabel
      Left = 260
      Top = 26
      Caption = #220'r'#252'n :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object TbAletCubugu: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1021
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 111
    Caption = 'TbAletCubugu'
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
    ExplicitWidth = 918
    object BtnUret: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni '#220'ret'
      ImageIndex = 7
      Style = tbsTextButton
      OnClick = BtnUretClick
    end
    object ToolButton10: TToolButton
      Left = 111
      Top = 0
      Width = 8
      Caption = 'ToolButton10'
      ImageIndex = 20
      Style = tbsSeparator
    end
    object btnIptal: TToolButton
      Left = 119
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Visible = False
      OnClick = btnIptalClick
    end
    object BtnKapat: TToolButton
      Left = 230
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Visible = False
      OnClick = BtnKapatClick
    end
    object BtnUretimEtiketYazdir: TToolButton
      Left = 341
      Top = 0
      Caption = 'Karekod Yazd'#305'r'
      ImageIndex = 16
      OnClick = BtnUretimEtiketYazdirClick
    end
    object ToolButton1: TToolButton
      Left = 452
      Top = 0
      Caption = 'T'#252'm'#252'n'#252' Sil'
      ImageIndex = 31
      Visible = False
      OnClick = ToolButton1Click
    end
    object BtnUretimBildir: TToolButton
      Left = 563
      Top = 0
      Caption = #220'retim Bildir'
      ImageIndex = 12
      OnClick = BtnUretimBildirClick
    end
    object ToolButton3: TToolButton
      Left = 674
      Top = 0
      Caption = 'Oto Sat'#305#351' Bildir'
      ImageIndex = 12
      Visible = False
      OnClick = ToolButton3Click
    end
  end
  object Panel1: TPanel
    Left = 609
    Top = 154
    Width = 418
    Height = 336
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 506
    object GridAyniKAyitlar: TcxGrid
      Left = 1
      Top = 25
      Width = 416
      Height = 310
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      object TvAyniKayitlar: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsAyniKayit
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            FieldName = 'FATURA_MATRAHI'
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            FieldName = 'KDV_TUTARI'
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            FieldName = 'FATURA_TUTARI'
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        OptionsView.FooterAutoHeight = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object TvAyniKayitlarSIRANO: TcxGridDBColumn
          DataBinding.FieldName = 'SIRANO'
          PropertiesClassName = 'TcxTextEditProperties'
        end
        object TvAyniKayitlarBARKOD: TcxGridDBColumn
          DataBinding.FieldName = 'BARKOD'
          PropertiesClassName = 'TcxTextEditProperties'
        end
        object TvAyniKayitlarID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          PropertiesClassName = 'TcxTextEditProperties'
        end
      end
      object GlAyniKayitlar: TcxGridLevel
        GridView = TvAyniKayitlar
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 416
      Height = 24
      Align = alTop
      Caption = #199'ift s'#305'ra numaralar'#305
      TabOrder = 1
    end
  end
  object MemoCreate: TMemo
    Left = 508
    Top = 255
    Width = 335
    Height = 34
    Lines.Strings = (
      
        'IF EXISTS (select * from sys.objects where type ='#39'U'#39' AND name ='#39 +
        'GECICI_KAREKOD'#39')'
      'BEGIN'
      '    DROP TABLE GECICI_KAREKOD'
      'END'
      'CREATE TABLE GECICI_KAREKOD'
      '('
      '   BARKOD VARCHAR(14),'
      '   SIRANO VARCHAR(20)'
      ')')
    TabOrder = 3
    Visible = False
    WordWrap = False
  end
  object Panel4: TPanel
    Left = 0
    Top = 89
    Width = 1027
    Height = 30
    Align = alTop
    TabOrder = 4
    ExplicitWidth = 924
    object ToolBar5: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1019
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 77
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
      TabOrder = 0
      Transparent = True
      ExplicitWidth = 916
      object KarekodEkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        Visible = False
        OnClick = KarekodEkleTusClick
      end
      object KarekodSilTus: TToolButton
        Left = 77
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = KarekodSilTusClick
      end
      object KarekodKaydetTus: TToolButton
        Left = 154
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
        OnClick = KarekodKaydetTusClick
      end
      object KarekodIptalTus: TToolButton
        Left = 231
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
        OnClick = KarekodIptalTusClick
      end
      object ToolButton2: TToolButton
        Left = 308
        Top = 0
        Caption = 'Se'#231'ileni Sil'
        ImageIndex = 1
        OnClick = ToolButton2Click
      end
    end
  end
  object GridUretimListesi: TcxGrid
    Left = 0
    Top = 154
    Width = 609
    Height = 336
    Align = alClient
    TabOrder = 5
    ExplicitWidth = 506
    object TvUretimListesi: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      OnCellClick = TvUretimListesiCellClick
      OnCustomDrawCell = TvUretimListesiCustomDrawCell
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = Tablo.DtsUretim
      DataController.KeyFieldNames = 'ID'
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
          FieldName = 'SIRANO'
          Column = vUretimListesiColumn3
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsData.Appending = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.Footer = True
      OptionsView.FooterAutoHeight = True
      OptionsView.FooterMultiSummaries = True
      OptionsView.GroupByBox = False
      Styles.OnGetContentStyle = TvUretimListesiStylesGetContentStyle
      object vUretimListesiColumn2: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.FieldName = 'SEC'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.NullStyle = nssUnchecked
        Visible = False
      end
      object TvUretimListesiURUNBARKOD: TcxGridDBColumn
        Caption = 'Barkod'
        DataBinding.FieldName = 'URUNBARKOD'
        Options.Editing = False
        Width = 69
      end
      object TvUretimListesiSIRANO: TcxGridDBColumn
        Caption = 'S'#305'ra No'
        DataBinding.FieldName = 'SIRANO'
        Options.Editing = False
        Width = 68
      end
      object TvUretimListesiLOTNO: TcxGridDBColumn
        Caption = 'Lot No'
        DataBinding.FieldName = 'LOTNO'
        Options.Editing = False
        Width = 69
      end
      object TvUretimListesiSONKULLANIM: TcxGridDBColumn
        Caption = 'Son Kullan'#305'm'
        DataBinding.FieldName = 'SONKULLANIM'
        Options.Editing = False
        Width = 62
      end
      object vUretimListesiColumn1: TcxGridDBColumn
        Caption = #220'retim Tarihi'
        DataBinding.FieldName = 'URETIMTARIHI'
        Options.Editing = False
        Width = 62
      end
      object TvUretimListesiColumn1: TcxGridDBColumn
        Caption = #220'r'#252'n No'
        DataBinding.FieldName = 'URUNNO'
        Width = 45
      end
      object vUretimListesiColumn3: TcxGridDBColumn
        Caption = #220'retim Durum'
        DataBinding.FieldName = 'URETIM_DURUM'
        Width = 129
      end
    end
    object GlUretimListesi: TcxGridLevel
      GridView = TvUretimListesi
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 119
    Width = 1027
    Height = 35
    Align = alTop
    TabOrder = 6
    ExplicitWidth = 924
    object TxtSiraNo: TcxTextEdit
      Left = 56
      Top = 8
      TabOrder = 0
      Width = 121
    end
    object cxLabel3: TcxLabel
      Left = 7
      Top = 9
      Caption = 'S'#305'ra No'
    end
    object cxLabel4: TcxLabel
      Left = 184
      Top = 9
      Caption = 'Adet'
    end
    object EdtAdet: TcxSpinEdit
      Left = 217
      Top = 8
      TabOrder = 3
      Value = 1
      Width = 48
    end
    object BitBtn1: TBitBtn
      Left = 271
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Getir'
      TabOrder = 4
      OnClick = BitBtn1Click
    end
  end
  object TabAyniKayit: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'SIRABASLA'
        Size = -1
        Value = Null
      end
      item
        Name = 'ADET'
        Size = -1
        Value = Null
      end
      item
        Name = 'SIRAEK'
        Size = -1
        Value = Null
      end
      item
        Name = 'BARKOD'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'IF EXISTS (select * from sys.objects where type ='#39'U'#39' AND name ='#39 +
        'GECICI_KAREKOD'#39')'
      'BEGIN'
      '    DROP TABLE GECICI_KAREKOD'
      'END'
      'CREATE TABLE GECICI_KAREKOD'
      '('
      '   BARKOD VARCHAR(14),'
      '   SIRANO VARCHAR(20)'
      ')'
      ''
      'DECLARE @BARKOD VARCHAR(14)'
      ''
      'DECLARE @SIRABASLA INT'
      'DECLARE @ADET INT'
      'DECLARE @SIRAEK VARCHAR(20)'
      'DECLARE @ARTIR INT'
      'DECLARE @SIRANO VARCHAR(20)'
      'DECLARE @OLANSIRANOLAR VARCHAR(500)'
      ''
      ''
      ''
      ''
      'SET @SIRABASLA =:SIRABASLA'
      'SET @ADET =:ADET'
      'SET @SIRAEK =:SIRAEK'
      'SET @ARTIR  = 1'
      'SET @BARKOD = :BARKOD'
      ''
      
        '--'#304'LK OLARAK EKLENECEK KAREKODLAR B'#304'R TEMP TABLOYA ATILIYOR VE K' +
        'ONTROL ETMEK '#304#199#304'N'
      
        'DECLARE CRS_PERSONEL CURSOR FOR SELECT  @BARKOD,@SIRABASLA,@ADET' +
        ',@SIRAEK,@ARTIR'
      'OPEN CRS_PERSONEL'
      
        'FETCH NEXT FROM CRS_PERSONEL INTO @BARKOD,@SIRABASLA,@ADET,@SIRA' +
        'EK,@ARTIR'
      '    WHILE @@FETCH_STATUS = 0'
      #9'BEGIN'
      #9#9'WHILE @SIRABASLA + @ARTIR  <= @SIRABASLA + @ADET '
      #9#9'BEGIN'
      
        #9#9#9'SET @SIRANO = @SIRAEK+CONVERT(VARCHAR(20),@SIRABASLA + @ARTIR' +
        ')'
      
        #9#9#9'INSERT INTO GECICI_KAREKOD (BARKOD,SIRANO)VALUES (@BARKOD,@SI' +
        'RANO)'
      #9#9#9
      
        '                                                  SET @ARTIR = @' +
        'ARTIR + 1'
      #9#9'END'
      
        #9'FETCH NEXT FROM CRS_PERSONEL INTO @BARKOD,@SIRABASLA,@ADET,@SIR' +
        'AEK,@ARTIR'
      #9'END'#9#9#9
      'CLOSE CRS_PERSONEL'
      'DEALLOCATE CRS_PERSONEL'
      
        '----------------------------------------------------------------' +
        '--------------------'#9
      
        '-----Olan Kay'#305'tlar getiriyor------------------------------------' +
        '-------------------'#9#9
      'SELECT SI.URUNBARKOD AS BARKOD,SI.SIRANO,SI.ID FROM STOKID SI '
      'WHERE  URUNBARKOD+SIRANO IN ('
      'SELECT BARKOD+SIRANO FROM GECICI_KAREKOD GK '
      'Where GK.BARKOD = SI.URUNBARKOD '
      'AND GK.SIRANO=SI.SIRANO)'#9#9#9
      
        '----------------------------------------------------------------' +
        '--------------------'#9)
    Left = 637
    Top = 67
    object TabAyniKayitSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabAyniKayitBARKOD: TStringField
      FieldName = 'BARKOD'
    end
    object TabAyniKayitID: TIntegerField
      FieldName = 'ID'
    end
  end
  object DtsAyniKayit: TDataSource
    DataSet = TabAyniKayit
    Left = 708
    Top = 67
  end
  object DtsUretim: TDataSource
    Left = 716
    Top = 112
  end
  object TabUretim: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'GIRISTURU'
        Size = -1
        Value = Null
      end
      item
        Name = 'STOKID'
        Size = -1
        Value = Null
      end
      item
        Name = 'GIRFATBASID'
        Size = -1
        Value = Null
      end
      item
        Name = 'GIRFATURAID'
        Size = -1
        Value = Null
      end
      item
        Name = 'SONKULLANIM'
        Size = -1
        Value = Null
      end
      item
        Name = 'LOTNO'
        Size = -1
        Value = Null
      end
      item
        Name = 'URETIMTIPI'
        Size = -1
        Value = Null
      end
      item
        Name = 'URUNCINSI'
        Size = -1
        Value = Null
      end
      item
        Name = 'URETIMTARIHI'
        Size = -1
        Value = Null
      end
      item
        Name = 'DEPOID'
        Size = -1
        Value = Null
      end
      item
        Name = 'URUNNO'
        Size = -1
        Value = Null
      end
      item
        Name = 'GLN'
        Size = -1
        Value = Null
      end
      item
        Name = 'GIRFATBASIDKAREKOD'
        Size = -1
        Value = Null
      end
      item
        Name = 'GIRFATURAIDKAREKOD'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'INSERT INTO STOKID (GIRISTURU,STOKID,GIRFATBASID,GIRFATURAID,URU' +
        'NBARKOD,SIRANO,GARANTIBITIS,IZLEMTURU,ONAY,SONKULLANIM,LOTNO,URE' +
        'TIMTIPI,URUNCINSI,URETIMTARIHI,DEPOID,URUNNO)'
      
        'SELECT :GIRISTURU,:STOKID,:GIRFATBASID,:GIRFATURAID,BARKOD,SIRAN' +
        'O,GETDATE(),3,1,:SONKULLANIM,:LOTNO,:URETIMTIPI,:URUNCINSI,:URET' +
        'IMTARIHI,:DEPOID,:URUNNO FROM GECICI_KAREKOD '
      ''
      'INSERT INTO KAREKOD (STOKIDID,STOKID,MALALINANGLN,URUNKODU) '
      
        'SELECT ID,STOKID,ISNULL(:GLN,0),STOKID  FROM STOKID WHERE GIRFAT' +
        'BASID=:GIRFATBASIDKAREKOD AND GIRFATURAID = :GIRFATURAIDKAREKOD'
      ''
      '')
    Left = 629
    Top = 114
    object TabUretimURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabUretimSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabUretimLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabUretimSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 466
    Top = 146
    object pmHepsiSec: TMenuItem
      Tag = 1
      Caption = 'Hepsini Se'#231
      OnClick = pmHepsiSecClick
    end
    object pmTumunuKaldir: TMenuItem
      Tag = 2
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = pmHepsiSecClick
    end
    object pmSecimiTersCevir: TMenuItem
      Tag = 3
      Caption = 'Se'#231'imi Ters '#199'evir'
      OnClick = pmHepsiSecClick
    end
  end
end
