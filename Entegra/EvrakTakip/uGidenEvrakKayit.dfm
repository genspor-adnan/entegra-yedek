object frmGidenEvrakKayit: TfrmGidenEvrakKayit
  Left = 0
  Top = 0
  Caption = 'Giden Evrak Kay'#305't'
  ClientHeight = 598
  ClientWidth = 836
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 18
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 836
    Height = 34
    Align = alTop
    ParentColor = True
    TabOrder = 0
    ExplicitWidth = 844
    object buttonKapat: TSpeedButton
      AlignWithMargins = True
      Left = 768
      Top = 4
      Width = 76
      Height = 26
      Action = actKapat
      Align = alRight
      Images = dmEvrakModule.ImagesEvrak
      ExplicitLeft = 504
      ExplicitHeight = 22
    end
    object buttonBarcode: TSpeedButton
      AlignWithMargins = True
      Left = 736
      Top = 4
      Width = 26
      Height = 26
      Align = alRight
      Flat = True
      ExplicitLeft = 528
      ExplicitHeight = 22
    end
    object buttonDosyaEkle: TSpeedButton
      AlignWithMargins = True
      Left = 79
      Top = 4
      Width = 90
      Height = 26
      Action = actDosyaEkle
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      Transparent = False
      ExplicitHeight = 22
    end
    object buttonKaydet: TSpeedButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 69
      Height = 26
      Action = actKaydet
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      ExplicitTop = 2
      ExplicitHeight = 22
    end
    object buttonDosyaEkleri: TSpeedButton
      AlignWithMargins = True
      Left = 175
      Top = 4
      Width = 95
      Height = 26
      Action = actEkDosyalar
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      Transparent = False
      ExplicitHeight = 22
    end
    object SpeedButton1: TSpeedButton
      AlignWithMargins = True
      Left = 276
      Top = 4
      Width = 95
      Height = 26
      Action = actTarama
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      Transparent = False
      ExplicitLeft = 321
      ExplicitTop = 6
      ExplicitHeight = 22
    end
    object SpeedButton2: TSpeedButton
      AlignWithMargins = True
      Left = 377
      Top = 4
      Width = 95
      Height = 26
      Action = actBarkod
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      Transparent = False
      ExplicitLeft = 412
      ExplicitTop = 6
      ExplicitHeight = 22
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 34
    Width = 836
    Height = 30
    Align = alTop
    ParentColor = True
    TabOrder = 1
    ExplicitWidth = 844
    object Label1: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 93
      Height = 18
      Align = alLeft
      Caption = 'Evrak Numaras'#305' : '
      Layout = tlCenter
    end
    object Label2: TLabel
      AlignWithMargins = True
      Left = 281
      Top = 4
      Width = 74
      Height = 18
      Align = alLeft
      Caption = 'Evrak Tarihi : '
      Layout = tlCenter
    end
    object editEvrakNo: TcxDBTextEdit
      AlignWithMargins = True
      Left = 103
      Top = 4
      Align = alLeft
      DataBinding.DataField = 'BELGENO'
      DataBinding.DataSource = dsEvrakTablo
      Style.BorderStyle = ebsNone
      TabOrder = 0
      Width = 172
    end
    object editEvrakTarihi: TcxDBDateEdit
      AlignWithMargins = True
      Left = 361
      Top = 4
      Align = alLeft
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = dsEvrakTablo
      Style.BorderStyle = ebsNone
      TabOrder = 1
      Width = 136
    end
  end
  object PanelInput: TPanel
    Left = 0
    Top = 64
    Width = 590
    Height = 534
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object memoAciklama: TcxDBMemo
      Left = 403
      Top = 299
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 6
      Height = 232
      Width = 185
    end
    object GridDagitim: TcxGrid
      Left = 152
      Top = 299
      Width = 243
      Height = 114
      TabOrder = 7
      object ViewDagitim: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dsilgili
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object ViewDagitimDOSYA_NO: TcxGridDBColumn
          DataBinding.FieldName = 'DOSYA_NO'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewDagitimAlanADI: TcxGridDBColumn
          Caption = 'Alan'
          DataBinding.FieldName = 'AlanADI'
          DataBinding.IsNullValueType = True
          Width = 80
        end
        object ViewDagitimOZEL_ALAN_REF: TcxGridDBColumn
          DataBinding.FieldName = 'OZEL_ALAN_REF'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewDagitimDEGER: TcxGridDBColumn
          Caption = 'De'#287'er'
          DataBinding.FieldName = 'DEGER'
          DataBinding.IsNullValueType = True
          Width = 100
        end
      end
      object DagitimLevel1: TcxGridLevel
        GridView = ViewDagitim
      end
    end
    object cxLabel1: TcxLabel
      Left = 10
      Top = 9
      Caption = 'Yaz'#305' '#350'ekli :'
    end
    object cxLabel13: TcxLabel
      Left = 10
      Top = 209
      Caption = 'Dosya Numaras'#305':'
    end
    object cxLabel14: TcxLabel
      Left = 10
      Top = 237
      Caption = 'Esas No:'
    end
    object cxLabel15: TcxLabel
      Left = 10
      Top = 273
      Caption = #304'mza Yolu :'
    end
    object cxLabel17: TcxLabel
      Left = 10
      Top = 307
      Caption = 'Da'#287#305't'#305'm :'
    end
    object cxLabel18: TcxLabel
      Left = 10
      Top = 417
      Caption = #304'lgi :'
    end
    object cxLabel3: TcxLabel
      Left = 10
      Top = 72
      Caption = 'Konusu'
    end
    object cxLabel5: TcxLabel
      Left = 10
      Top = 99
      Caption = 'Gidece'#287'i Yer :'
    end
    object cxLabel6: TcxLabel
      Left = 10
      Top = 137
      Caption = 'Ek Listesi :'
    end
    object cxLabel8: TcxLabel
      Left = 10
      Top = 180
      Caption = 'Yaz'#305' Durumu:'
    end
    object cxLabel9: TcxLabel
      Left = 318
      Top = 180
      Caption = 'Gizlilik Derecesi :'
    end
    object editEsasNo: TcxDBTextEdit
      Left = 152
      Top = 239
      DataBinding.DataField = 'ESAS_NO'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 5
      Width = 160
    end
    object editKonusu: TcxDBTextEdit
      Left = 157
      Top = 66
      DataBinding.DataField = 'KONU'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 1
      Width = 430
    end
    object evrakDosyaNumarasi: TcxDBTextEdit
      Left = 152
      Top = 209
      DataBinding.DataField = 'DOSYA_NUMARASI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 4
      Width = 160
    end
    object lookupYaziSekli: TcxDBLookupComboBox
      Left = 152
      Top = 8
      DataBinding.DataField = 'GELDIGI_YER_TUR_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.KeyFieldNames = 'ID'
      Properties.ListColumns = <
        item
          FieldName = 'TUR'
        end>
      Properties.ListOptions.ShowHeader = False
      TabOrder = 0
      Width = 118
    end
    object lookupGizlilikDerecesi: TcxDBLookupComboBox
      Left = 428
      Top = 178
      DataBinding.DataField = 'GIZLILIK_DERECESI_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 3
      Width = 160
    end
    object lookupYaziDurumu: TcxDBLookupComboBox
      Left = 152
      Top = 178
      DataBinding.DataField = 'YAZI_DURUMU_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 2
      Width = 160
    end
    object lookupImzaYolu: TcxDBLookupComboBox
      Left = 152
      Top = 269
      DataBinding.DataField = 'IMZA_YOLU_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 19
      Width = 160
    end
    object editDosyaKodu: TcxDBButtonEdit
      Left = 152
      Top = 38
      DataBinding.DataField = 'ILGILI_EVRAK_NUMARASI'
      DataBinding.DataSource = dsEvrakTablo
      Properties.Buttons = <
        item
          Default = True
          ImageIndex = 147
          Kind = bkGlyph
        end>
      Style.LookAndFeel.Kind = lfStandard
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.NativeStyle = False
      TabOrder = 20
      Width = 160
    end
    object Grdilgi: TcxGrid
      Left = 152
      Top = 417
      Width = 243
      Height = 114
      TabOrder = 21
      object Viewilgi: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dsilgili
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object cxGridDBColumn1: TcxGridDBColumn
          DataBinding.FieldName = 'DOSYA_NO'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object cxGridDBColumn2: TcxGridDBColumn
          Caption = 'Alan'
          DataBinding.FieldName = 'AlanADI'
          DataBinding.IsNullValueType = True
          Width = 80
        end
        object cxGridDBColumn3: TcxGridDBColumn
          DataBinding.FieldName = 'OZEL_ALAN_REF'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object cxGridDBColumn4: TcxGridDBColumn
          Caption = 'De'#287'er'
          DataBinding.FieldName = 'DEGER'
          DataBinding.IsNullValueType = True
          Width = 100
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = Viewilgi
      end
    end
    object cxLabel2: TcxLabel
      Left = 10
      Top = 39
      Caption = 'Dosya Kodu :'
    end
    object editEkListe: TcxDBMemo
      Left = 152
      Top = 128
      DataBinding.DataField = 'EK_LISTESI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 23
      Height = 47
      Width = 430
    end
    object cxLabel4: TcxLabel
      Left = 403
      Top = 271
      Caption = 'A'#231#305'klama :'
    end
    object lookupGidecekYer: TcxDBLookupComboBox
      Left = 152
      Top = 98
      DataBinding.DataField = 'GIDECEGI_YER_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 25
      Width = 243
    end
  end
  object PanelEkDosyalar: TPanel
    AlignWithMargins = True
    Left = 593
    Top = 67
    Width = 240
    Height = 528
    Align = alClient
    TabOrder = 3
    ExplicitWidth = 248
    ExplicitHeight = 530
    object GridImaj: TcxGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 244
      Height = 523
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 240
      ExplicitHeight = 522
      object ViewImaj: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dsImaj
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        object ViewImajID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewImajBELGEADI: TcxGridDBColumn
          DataBinding.FieldName = 'BELGEADI'
          DataBinding.IsNullValueType = True
          Width = 120
        end
        object ViewImajBELGE: TcxGridDBColumn
          DataBinding.FieldName = 'BELGE'
          DataBinding.IsNullValueType = True
          Options.CellMerging = True
        end
        object ViewImajYER_ID: TcxGridDBColumn
          Caption = 'Dosya Ref'
          DataBinding.FieldName = 'YER_ID'
          DataBinding.IsNullValueType = True
          Options.CellMerging = True
        end
        object ViewImajDURUM: TcxGridDBColumn
          DataBinding.FieldName = 'DURUM'
          DataBinding.IsNullValueType = True
        end
        object ViewImajBELGENO: TcxGridDBColumn
          DataBinding.FieldName = 'BELGENO'
          DataBinding.IsNullValueType = True
          Options.CellMerging = True
        end
        object ViewImajBOYUT: TcxGridDBColumn
          DataBinding.FieldName = 'BOYUT'
          DataBinding.IsNullValueType = True
        end
        object ViewImajBELGETURU: TcxGridDBColumn
          DataBinding.FieldName = 'BELGETURU'
          DataBinding.IsNullValueType = True
          Width = 72
        end
      end
      object ImajLevel1: TcxGridLevel
        GridView = ViewImaj
      end
    end
  end
  object ActionList1: TActionList
    Images = dmEvrakModule.ImagesEvrak
    Left = 648
    object actKaydet: TAction
      Caption = 'Kaydet'
      ImageIndex = 42
      OnExecute = actKaydetExecute
    end
    object actDosyaEkle: TAction
      Caption = 'Ekle / G'#246'zat'
      ImageIndex = 1
      OnExecute = actDosyaEkleExecute
    end
    object actBarkod: TAction
      Caption = 'actBarkod'
      ImageIndex = 41
      OnExecute = actBarkodExecute
    end
    object actKapat: TAction
      Caption = 'Kapat'
      ImageIndex = 30
      OnExecute = actKapatExecute
    end
    object actEkDosyalar: TAction
      AutoCheck = True
      Caption = 'Dosya Ekleri'
      Checked = True
      ImageIndex = 59
      OnExecute = actEkDosyalarExecute
      OnUpdate = actEkDosyalarUpdate
    end
    object actTarama: TAction
      Caption = 'Tarama'
      ImageIndex = 13
    end
  end
  object qryEvrakTablo: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = qryEvrakTabloAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM DOKUMAN ')
    Left = 501
    Top = 8
  end
  object qryImaj: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM IMAJ WHERE 1=1'
      'AND YER_ID=:DosyaID')
    Left = 570
    Top = 8
  end
  object dsEvrakTablo: TDataSource
    DataSet = qryEvrakTablo
    Left = 463
    Top = 64
  end
  object dsImaj: TDataSource
    DataSet = qryImaj
    Left = 572
    Top = 64
  end
  object qryilgili: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryilgiliBeforePost
    ParamData = <>
    Left = 50
    Top = 408
  end
  object dsilgili: TDataSource
    DataSet = qryilgili
    Left = 100
    Top = 408
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileNameLabel = 'Eklenecek Dosya'
    FileTypes = <>
    OkButtonLabel = 'Ekle'
    Options = []
    Title = 'Eklenecek Dosya Se'#231'imi'
    Left = 416
    Top = 168
  end
  object dsDagitim: TDataSource
    DataSet = qryDagitim
    Left = 100
    Top = 512
  end
  object qryDagitim: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryilgiliBeforePost
    ParamData = <>
    Left = 50
    Top = 512
  end
end
