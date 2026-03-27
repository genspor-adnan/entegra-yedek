object AlanlarDlg: TAlanlarDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  ClientHeight = 604
  ClientWidth = 902
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object gridaAlanTanim: TcxGrid
    Left = 0
    Top = 35
    Width = 902
    Height = 569
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    object tvAlanlTanim: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DsTabAlanlar
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Appending = True
      OptionsView.GroupByBox = False
      object TvAlanId: TcxGridDBColumn
        Caption = 'Id'
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 45
      end
      object TvAlanKONUM: TcxGridDBColumn
        Caption = 'Konum'
        DataBinding.FieldName = 'KONUM'
        DataBinding.IsNullValueType = True
        Width = 115
      end
      object TvAlanTuru: TcxGridDBColumn
        Caption = 'Alan Tipi'
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        Properties.OnCloseUp = TvAlanTuruPropertiesCloseUp
        RepositoryItem = Tablo.RepCompenentTurleri
        Width = 103
      end
      object tvAlanlTanimALANADI: TcxGridDBColumn
        Caption = 'Alan Ad'#305
        DataBinding.FieldName = 'ALANADI'
        DataBinding.IsNullValueType = True
      end
      object tvAlanlTablo: TcxGridDBColumn
        Caption = 'Tablo'
        DataBinding.FieldName = 'TABLO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.Items.Strings = (
          'DEMIRBAS'
          'DOKUMAN'
          'FATBASLIK'
          'REHBER'
          'SERVIS'
          'SERVISHAREKET'
          'SIPARIS'
          'STOK'
          'TEKLIF'
          'URETIMOPERASYONPERSONEL')
        Width = 85
      end
      object TvAlanCaption: TcxGridDBColumn
        Caption = 'Etiket'
        DataBinding.FieldName = 'CAPTION'
        DataBinding.IsNullValueType = True
        Width = 155
      end
      object TvAlanIcerik: TcxGridDBColumn
        Caption = #304#231'erik'
        DataBinding.FieldName = 'SQL'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = TvAlanIcerikPropertiesButtonClick
        Width = 170
      end
      object tvAlanlLEFT: TcxGridDBColumn
        Caption = 'Left'
        DataBinding.FieldName = 'LEFT'
        DataBinding.IsNullValueType = True
      end
      object tvAlanlTOP: TcxGridDBColumn
        Caption = 'Top'
        DataBinding.FieldName = 'TOP'
        DataBinding.IsNullValueType = True
      end
      object tvAlanlHEIGHT: TcxGridDBColumn
        Caption = 'Height'
        DataBinding.FieldName = 'HEIGHT'
        DataBinding.IsNullValueType = True
      end
      object tvAlanlWIDTH: TcxGridDBColumn
        Caption = 'Width'
        DataBinding.FieldName = 'WIDTH'
        DataBinding.IsNullValueType = True
      end
      object TvAlanFont: TcxGridDBColumn
        Caption = 'Font'
        DataBinding.FieldName = 'FONT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxFontNameComboBoxProperties'
        Properties.FontPreview.ShowButtons = False
        Properties.ImmediatePost = True
        Width = 72
      end
      object TvAlanlPunto: TcxGridDBColumn
        Caption = 'Punto'
        DataBinding.FieldName = 'FONTSIZE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.ImmediatePost = True
        Properties.LargeIncrement = 2.000000000000000000
        Properties.MaxValue = 14.000000000000000000
        Properties.MinValue = 6.000000000000000000
      end
      object TvAlanBold: TcxGridDBColumn
        Caption = 'Bold'
        DataBinding.FieldName = 'BOLD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
      end
      object TvAlanItalik: TcxGridDBColumn
        Caption = #304'talik'
        DataBinding.FieldName = 'ITALIK'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
      end
      object TvAlanAltCizgi: TcxGridDBColumn
        Caption = 'Alt '#199'izgi'
        DataBinding.FieldName = 'ALTCIZGI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Width = 45
      end
      object TvAlanFontRenk: TcxGridDBColumn
        Caption = 'Font Rengi'
        DataBinding.FieldName = 'FONTCOLOR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxColorComboBoxProperties'
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Width = 139
      end
      object TvAlanArkaRenk: TcxGridDBColumn
        Caption = 'Arka Plan Rengi'
        DataBinding.FieldName = 'ARKARENK'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxColorComboBoxProperties'
        Properties.CustomColors = <>
        Width = 117
      end
    end
    object gridaAlanTanimLevel1: TcxGridLevel
      GridView = tvAlanlTanim
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 896
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object btnTamamTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Tamam'
      ImageIndex = 11
      ImageName = 'PngImage10'
      OnClick = btnTamamTusClick
    end
    object ToolButton3: TToolButton
      Left = 69
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsSeparator
    end
    object btnSilTus: TToolButton
      Left = 77
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = btnSilTusClick
    end
    object btnKaydetTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Visible = False
      OnClick = btnKaydetTusClick
    end
    object ToolButton2: TToolButton
      Left = 215
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 4
      ImageName = 'PngImage2'
      Style = tbsSeparator
    end
    object btnIptalTus: TToolButton
      Left = 223
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Visible = False
      OnClick = btnIptalTusClick
    end
  end
  object TabAlanlar: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabAlanlarBeforePost
    AfterPost = TabAlanlarAfterPost
    OnNewRecord = TabAlanlarNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from ALANLAR'
      ' Where EKRANADI=:Par1 ')
    Left = 184
    Top = 160
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 16
    Top = 104
  end
  object DsTabAlanlar: TDataSource
    DataSet = TabAlanlar
    OnStateChange = DsTabAlanlarStateChange
    Left = 192
    Top = 208
  end
  object TabLabel: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabLabelNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from ALANLAR')
    Left = 24
    Top = 176
  end
end

