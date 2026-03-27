object SatinAlmaTalep: TSatinAlmaTalep
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Satinalma Talep'
  ClientHeight = 547
  ClientWidth = 732
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox4: TcxGroupBox
    Left = 0
    Top = 0
    Align = alTop
    Style.LookAndFeel.Kind = lfOffice11
    Style.LookAndFeel.NativeStyle = True
    Style.Shadow = False
    StyleDisabled.LookAndFeel.Kind = lfOffice11
    StyleDisabled.LookAndFeel.NativeStyle = True
    StyleFocused.LookAndFeel.Kind = lfOffice11
    StyleFocused.LookAndFeel.NativeStyle = True
    StyleHot.LookAndFeel.Kind = lfOffice11
    StyleHot.LookAndFeel.NativeStyle = True
    TabOrder = 0
    Height = 97
    Width = 732
    object cxLabel16: TcxLabel
      Left = 279
      Top = 46
      Caption = 'Tarih'
      Transparent = True
    end
    object Date: TcxDBDateEdit
      Left = 323
      Top = 45
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = DtsTeklif
      Properties.Kind = ckDateTime
      TabOrder = 1
      Width = 148
    end
    object ComboHazirlayan: TcxButtonEdit
      Left = 72
      Top = 48
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Hint = 'Temizle'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = TalepComboHazirlayanPropertiesButtonClick
      ShowHint = True
      TabOrder = 2
      Width = 147
    end
    object cxLabel20: TcxLabel
      Left = 3
      Top = 49
      Caption = 'Haz'#305'rlayan'
      Transparent = True
    end
    object TeklifNo: TcxDBTextEdit
      Left = 72
      Top = 25
      DataBinding.DataField = 'TEKLIFNO'
      DataBinding.DataSource = DtsTeklif
      TabOrder = 4
      Width = 147
    end
    object cxLabel21: TcxLabel
      Left = 3
      Top = 26
      Caption = 'Talep No'
      Transparent = True
    end
    object ComboSube: TcxDBImageComboBox
      Left = 323
      Top = 22
      Hint = 'Teklif_Durum'
      RepositoryItem = Tablo.RepSubeler
      DataBinding.DataField = 'SUBEID'
      DataBinding.DataSource = DtsTeklif
      Properties.Items = <>
      TabOrder = 6
      Width = 148
    end
    object LblSube: TcxLabel
      Left = 279
      Top = 23
      Caption = #350'ube'
      ParentFont = False
      Transparent = True
    end
    object lblTumunuSec: TcxLabel
      Left = 501
      Top = 22
      Cursor = crHandPoint
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ParentColor = False
      ParentFont = False
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextColor = clNavy
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LblTumunuKaldir: TcxLabel
      Left = 501
      Top = 43
      Cursor = crHandPoint
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      ParentColor = False
      ParentFont = False
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextColor = clNavy
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 97
    Width = 732
    Height = 450
    Align = alClient
    TabOrder = 1
    object ToolBar5: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 724
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 62
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
      Images = AnaForm.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object SatirEkle: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        OnClick = SatirEkleClick
      end
      object SatirSil: TToolButton
        Left = 62
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = SatirSilClick
      end
      object ToolButton4: TToolButton
        Left = 124
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object SatirKaydet: TToolButton
        Left = 132
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Visible = False
        OnClick = SatirKaydetClick
      end
    end
    object GridTeklif: TcxGrid
      Left = 1
      Top = 28
      Width = 730
      Height = 372
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      LookAndFeel.SkinName = 'LondonLiquidSky'
      object GridTeklifView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsTeklifDetay
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
        object GridTeklifViewONAY: TcxGridDBColumn
          Caption = 'Onay'
          DataBinding.FieldName = 'ONAY'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.OnEditValueChanged = GridTeklifViewONAYPropertiesEditValueChanged
          Width = 39
        end
        object GridTeklifViewKOD: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Options.Editing = False
          Width = 100
        end
        object GridTeklifViewAD: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'AD'
          Options.Editing = False
          Width = 200
        end
        object GridTeklifViewADET: TcxGridDBColumn
          Caption = 'Adet'
          DataBinding.FieldName = 'MIKTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = '0;'
          Width = 45
        end
        object GridTeklifViewBIRIM: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.repStokAnaBirim
          Options.Editing = False
          Width = 54
        end
        object GridTeklifViewMIKTAR: TcxGridDBColumn
          Caption = 'Onaylanan Miktar'
          DataBinding.FieldName = 'ADET'
          Width = 102
        end
        object GridTeklifViewDEGISTIREN: TcxGridDBColumn
          Caption = 'Onaylayan'
          DataBinding.FieldName = 'DEGISTIREN'
          Visible = False
          Options.Editing = False
          Width = 68
        end
        object GridTeklifViewDEGISTIRMETARIHI: TcxGridDBColumn
          Caption = 'Onay Tarihi'
          DataBinding.FieldName = 'DEGISTIRMETARIHI'
          Options.Editing = False
        end
      end
      object GridTeklifLevel1: TcxGridLevel
        GridView = GridTeklifView
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 400
      Width = 730
      Height = 49
      Align = alBottom
      TabOrder = 2
      object btnKapat: TcxButton
        Left = 626
        Top = 6
        Width = 69
        Height = 32
        Caption = 'Kapat'
        ModalResult = 11
        TabOrder = 0
        OnClick = btnKapatClick
      end
      object btnOnayla: TcxButton
        Left = 500
        Top = 6
        Width = 112
        Height = 32
        Caption = 'Se'#231'ilenleri Onayla'
        TabOrder = 1
        Visible = False
      end
    end
  end
  object TabTeklifDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    BeforePost = TabTeklifDetayBeforePost
    OnNewRecord = TabTeklifDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      ' '
      'Select T.* ,'
      
        'AD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = T.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = T.URUNID)  END,'
      
        'KOD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = T.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID' +
        '= T.URUNID )  END'
      ''
      'from TEKLIFDETAY T '
      'Where '
      'TEKLIFID = :Par1'
      ' '
      ' order by SIRALAMA,KUR,ID')
    Left = 88
    Top = 325
    object TabTeklifDetayID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTeklifDetayTEKLIFID: TIntegerField
      FieldName = 'TEKLIFID'
    end
    object TabTeklifDetayREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabTeklifDetaySIRALAMA: TSmallintField
      FieldName = 'SIRALAMA'
    end
    object TabTeklifDetayURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabTeklifDetayACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabTeklifDetayADET: TFloatField
      FieldName = 'ADET'
    end
    object TabTeklifDetayBIRIMFIYAT: TFloatField
      FieldName = 'BIRIMFIYAT'
    end
    object TabTeklifDetayBIRIM: TWideStringField
      FieldName = 'BIRIM'
      Size = 8
    end
    object TabTeklifDetayMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object TabTeklifDetayISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabTeklifDetayKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabTeklifDetayTUTAR: TFloatField
      FieldName = 'TUTAR'
    end
    object TabTeklifDetayMALIYET: TFloatField
      FieldName = 'MALIYET'
    end
    object TabTeklifDetayKAR_YUZDE: TFloatField
      FieldName = 'KAR_YUZDE'
    end
    object TabTeklifDetayOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 10
    end
    object TabTeklifDetayMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabTeklifDetayKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabTeklifDetayEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabTeklifDetayEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabTeklifDetayDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabTeklifDetayDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabTeklifDetayALTERNATIFNO: TWordField
      FieldName = 'ALTERNATIFNO'
    end
    object TabTeklifDetayKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabTeklifDetayDOVIZ_TUTARI: TFloatField
      FieldName = 'DOVIZ_TUTARI'
    end
    object TabTeklifDetayDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabTeklifDetayISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabTeklifDetayYERI: TIntegerField
      FieldKind = fkCalculated
      FieldName = 'YERI'
      Calculated = True
    end
    object TabTeklifDetayYERID: TIntegerField
      FieldKind = fkCalculated
      FieldName = 'YERID'
      Calculated = True
    end
    object TabTeklifDetayISKTUTAR: TFloatField
      FieldKind = fkCalculated
      FieldName = 'ISKTUTAR'
      Calculated = True
    end
    object TabTeklifDetayKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
    end
    object TabTeklifDetayAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 100
    end
    object TabTeklifDetayTESLIMTARIHI: TDateTimeField
      FieldName = 'TESLIMTARIHI'
    end
    object TabTeklifDetayDOVIZ_BIRIMFIYAT: TFloatField
      FieldName = 'DOVIZ_BIRIMFIYAT'
    end
    object TabTeklifDetayKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabTeklifDetayVADE: TWordField
      FieldName = 'VADE'
    end
    object TabTeklifDetaySUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabTeklifDetaySIPBIRIMFIYAT: TFloatField
      FieldName = 'SIPBIRIMFIYAT'
    end
    object TabTeklifDetaySIPTUTAR: TFloatField
      FieldName = 'SIPTUTAR'
    end
    object TabTeklifDetayMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object TabTeklifDetayPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabTeklifDetayTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabTeklifDetayDOVIZKURDEGERI: TFloatField
      FieldName = 'DOVIZKURDEGERI'
    end
    object TabTeklifDetayRESIMGOSTER: TBooleanField
      FieldName = 'RESIMGOSTER'
    end
    object TabTeklifDetayONAY: TBooleanField
      FieldName = 'ONAY'
    end
  end
  object TabTeklif: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    OnNewRecord = TabTeklifNewRecord
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM '
      #9'TEKLIF T '
      ''
      'WHERE '
      #9'T.ID = :ID '
      'ORDER BY T.ID')
    Left = 19
    Top = 326
  end
  object DtsTeklif: TDataSource
    DataSet = TabTeklif
    Left = 15
    Top = 379
  end
  object DtsTeklifDetay: TDataSource
    DataSet = TabTeklifDetay
    OnStateChange = DtsTeklifDetayStateChange
    Left = 88
    Top = 381
  end
end
