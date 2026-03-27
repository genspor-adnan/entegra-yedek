object VerilenSiparisTabloDlg: TVerilenSiparisTabloDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  ClientHeight = 481
  ClientWidth = 1003
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
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 997
    Height = 22
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 20
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
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object btnTamam: TToolButton
      Left = 0
      Top = 0
      Caption = 'Sipari'#351'i Ver'
      ImageIndex = 11
      OnClick = btnTamamClick
    end
    object ToolButton2: TToolButton
      Left = 67
      Top = 0
      Width = 799
      Caption = 'ToolButton2'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 866
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = ToolButton3Click
    end
  end
  object GridSiparis: TcxGrid
    Left = 0
    Top = 25
    Width = 1003
    Height = 456
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object GridSiparisView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsTabDetay
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = '.0.00;'
          Kind = skSum
          FieldName = 'DOVIZ_TUTARI'
        end
        item
          Format = '.0.00;'
          Kind = skSum
          FieldName = 'BIRIMFIYAT'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      Styles.Content = AnaForm.cxStyle1
      Styles.Header = AnaForm.cxStyle1
      Styles.Indicator = AnaForm.cxStyle1
      object GridSiparisViewTESLIMTARIHI: TcxGridDBColumn
        Caption = 'Teslim Tarihi'
        DataBinding.FieldName = 'TESLIMTARIHI'
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.ShowTime = False
        Width = 84
      end
      object GridSiparisViewKOD: TcxGridDBColumn
        DataBinding.FieldName = 'KOD'
      end
      object GridSiparisViewAD: TcxGridDBColumn
        Caption = 'Ad'
        DataBinding.FieldName = 'AD'
        Options.Editing = False
        Width = 87
      end
      object GridSiparisViewACIKLAMA: TcxGridDBColumn
        DataBinding.FieldName = 'ACIKLAMA'
      end
      object GridSiparisViewADET: TcxGridDBColumn
        DataBinding.FieldName = 'ADET'
      end
      object GridSiparisViewBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'BIRIM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repStokAnaBirim
        Width = 42
      end
      object GridSiparisViewDEPODA: TcxGridDBColumn
        DataBinding.FieldName = 'DEPODA'
      end
      object GridSiparisViewYOLDAGELEN: TcxGridDBColumn
        DataBinding.FieldName = 'YOLDAGELEN'
      end
      object GridSiparisViewYOLDAGIDECEK: TcxGridDBColumn
        DataBinding.FieldName = 'YOLDAGIDECEK'
      end
      object GridSiparisViewFARK: TcxGridDBColumn
        DataBinding.FieldName = 'FARK'
      end
      object GridSiparisViewYENISIPARISADET: TcxGridDBColumn
        DataBinding.FieldName = 'YENISIPARISADET'
      end
      object GridSiparisViewFIRMA: TcxGridDBColumn
        DataBinding.FieldName = 'FIRMA'
      end
      object GridSiparisViewSIPBIRIMFIYAT: TcxGridDBColumn
        DataBinding.FieldName = 'SIPBIRIMFIYAT'
      end
    end
    object GridSiparisTableView1: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      OnCanFocusRecord = GridSiparisTableView1CanFocusRecord
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridTESLIMTARIHI: TcxGridColumn
        Caption = 'Teslim Tarihi'
        DataBinding.ValueType = 'DateTime'
        Options.Editing = False
        Width = 75
      end
      object GridKOD: TcxGridColumn
        Caption = 'Kod'
        Options.Editing = False
        Width = 80
      end
      object GridAD: TcxGridColumn
        Caption = 'Ad'
        Options.Editing = False
        Width = 142
      end
      object GridACIKLAMA: TcxGridColumn
        Caption = 'A'#231#305'klama'
        Options.Editing = False
      end
      object GridADET: TcxGridColumn
        Caption = 'Adet'
        DataBinding.ValueType = 'Float'
        Options.Editing = False
        Width = 40
      end
      object GridBIRIM: TcxGridColumn
        Caption = 'Birim'
        DataBinding.ValueType = 'Integer'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repStokAnaBirim
        Options.Editing = False
      end
      object GridDEPODA: TcxGridColumn
        Caption = 'Depoda'
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = '0;'
        Options.Editing = False
        Width = 50
      end
      object GridYOLDAGELEN: TcxGridColumn
        Caption = 'Yolda Gelen'
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = '0;'
        Options.Editing = False
      end
      object GridYOLDAGIDECEK: TcxGridColumn
        Caption = 'Yolda Gidecek'
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = '0;'
        Options.Editing = False
        Width = 73
      end
      object GridFARK: TcxGridColumn
        Caption = 'Fark'
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = '0;'
        Options.Editing = False
        Width = 42
      end
      object GridYENISIPARISADET: TcxGridColumn
        Caption = 'Yeni Sipari'#351
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = '0;'
        Width = 62
      end
      object GridFIRMA: TcxGridColumn
        Caption = 'Firma'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = GridFIRMAPropertiesButtonClick
        Width = 163
      end
      object GridSIPBIRIMFIYAT: TcxGridColumn
        Caption = 'Sip. Fiyat'
        DataBinding.ValueType = 'Float'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.0000;'
        Width = 74
      end
      object GridID: TcxGridColumn
        Caption = 'ID'
        Visible = False
      end
      object GridTEKLIFID: TcxGridColumn
        Caption = 'Teklif ID'
        Visible = False
      end
      object GridSTOKID: TcxGridColumn
        Caption = 'StokID'
        DataBinding.ValueType = 'Integer'
        Visible = False
      end
      object GridKDV: TcxGridColumn
        Caption = 'KDV'
        Visible = False
      end
      object GridRehberID: TcxGridColumn
        Caption = 'Rehber ID'
        DataBinding.ValueType = 'Integer'
        Visible = False
      end
    end
    object GridSiparisLevel1: TcxGridLevel
      GridView = GridSiparisTableView1
    end
  end
  object TabDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Select  T.*,'
      
        'KOD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = T.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID' +
        '= T.URUNID )  END,'
      
        'AD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = T.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = T.URUNID)  END,'
      
        'DEPODA=(select SUM(SD.KALAN) AS KALAN from STOKDURUM SD INNER JO' +
        'IN DEPOLAR D ON SD.DEPOID = D.ID INNER JOIN STOKLAR S ON SD.STOK' +
        'ID=S.ID WHERE S.ID=T.URUNID AND D.DURUM = 1  GROUP BY SD.STOKID,' +
        ' SD.DEPOID, D.DEPOADI   HAVING SUM(KALAN)<>0),'
      
        'YOLDAGELEN=isnull((Select SUM(ADET) from SIPARIS S left outer jo' +
        'in SIPARISDETAY SD on S.ID=SD.SIPARISID Where S.TUR=9 and SD.URU' +
        'NID=T.URUNID),0),'
      
        'YOLDAGIDECEK=isnull((Select SUM(ADET) from SIPARIS S left outer ' +
        'join SIPARISDETAY SD on S.ID=SD.SIPARISID Where S.TUR=19 and SD.' +
        'URUNID=T.URUNID),0),'
      
        'FARK=(isnull ((select SUM(SD.KALAN) AS KALAN from STOKDURUM SD I' +
        'NNER JOIN DEPOLAR D ON SD.DEPOID = D.ID INNER JOIN STOKLAR S ON ' +
        'SD.STOKID=S.ID '
      'WHERE S.ID=T.URUNID AND D.DURUM = 1  '
      'GROUP BY SD.STOKID, SD.DEPOID, D.DEPOADI   '
      'HAVING SUM(KALAN)<>0),0)+'
      
        'isnull((Select SUM(ADET) from SIPARIS S left outer join SIPARISD' +
        'ETAY SD on S.ID=SD.SIPARISID Where S.TUR=9 and SD.URUNID=T.URUNI' +
        'D),0))-'
      
        'isnull((Select SUM(ADET) from SIPARIS S left outer join SIPARISD' +
        'ETAY SD on S.ID=SD.SIPARISID Where S.TUR=19 and SD.URUNID=T.URUN' +
        'ID),0),'
      'YENISIPARISADET=0,'
      'FIRMA='#39#39','
      'SIPBIRIMFIYAT = 0.0'
      'from TEKLIFDETAY T '
      'Where '
      'TEKLIFID =:Param1  and ALTERNATIFNO = 1 '
      'order by KUR,ID')
    Left = 672
    Top = 109
    object TabDetayID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabDetayTEKLIFID: TIntegerField
      FieldName = 'TEKLIFID'
    end
    object TabDetayKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 25
    end
    object TabDetayAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 100
    end
    object TabDetayACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabDetayADET: TFloatField
      FieldName = 'ADET'
    end
    object TabDetayBIRIM: TWideStringField
      FieldName = 'BIRIM'
      Size = 8
    end
    object TabDetayTESLIMTARIHI: TDateTimeField
      FieldName = 'TESLIMTARIHI'
    end
    object TabDetayDEPODA: TFloatField
      FieldName = 'DEPODA'
      ReadOnly = True
    end
    object TabDetayYOLDAGELEN: TFloatField
      FieldName = 'YOLDAGELEN'
      ReadOnly = True
    end
    object TabDetayYOLDAGIDECEK: TFloatField
      FieldName = 'YOLDAGIDECEK'
      ReadOnly = True
    end
    object TabDetayFARK: TFloatField
      FieldName = 'FARK'
      ReadOnly = True
    end
    object TabDetayYENISIPARISADET: TIntegerField
      FieldName = 'YENISIPARISADET'
      ReadOnly = True
    end
    object TabDetayFIRMA: TStringField
      FieldName = 'FIRMA'
      ReadOnly = True
      Size = 1
    end
    object TabDetaySIPBIRIMFIYAT: TBCDField
      FieldName = 'SIPBIRIMFIYAT'
      ReadOnly = True
      Precision = 1
      Size = 1
    end
    object TabDetayURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabDetayKDV: TSmallintField
      FieldName = 'KDV'
    end
  end
  object DtsTabDetay: TDataSource
    DataSet = TabDetay
    Left = 600
    Top = 109
  end
end

