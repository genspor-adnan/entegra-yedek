object frmGelenEvrakKayit: TfrmGelenEvrakKayit
  Left = 0
  Top = 0
  Caption = 'Gelen Evrak Kay'#305't'
  ClientHeight = 552
  ClientWidth = 832
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
  TextHeight = 18
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 832
    Height = 34
    Align = alTop
    ParentColor = True
    TabOrder = 0
    ExplicitWidth = 836
    object buttonKapat: TSpeedButton
      AlignWithMargins = True
      Left = 760
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
      Left = 728
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
      Width = 138
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
      Left = 223
      Top = 4
      Width = 138
      Height = 26
      Action = actEkDosyalar
      Align = alLeft
      Images = dmEvrakModule.ImagesEvrak
      Flat = True
      Transparent = False
      ExplicitLeft = 271
      ExplicitTop = 2
      ExplicitHeight = 22
    end
    object checkHizliKaydet: TCheckBox
      Left = 617
      Top = 1
      Width = 108
      Height = 32
      Align = alRight
      Caption = 'H'#305'zl'#305' Kaydet'
      TabOrder = 0
      ExplicitLeft = 613
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 34
    Width = 832
    Height = 30
    Align = alTop
    ParentColor = True
    TabOrder = 1
    ExplicitWidth = 836
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
    object cxDBTextEdit1: TcxDBTextEdit
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
    Width = 586
    Height = 488
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object memoAciklama: TcxDBMemo
      Left = 152
      Top = 422
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 17
      Height = 65
      Width = 185
    end
    object GridOzelAlan: TcxGrid
      Left = 343
      Top = 338
      Width = 243
      Height = 149
      TabOrder = 18
      object ViewOzelAlan: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dsOzelAlan
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object ViewOzelAlanDOSYA_NO: TcxGridDBColumn
          DataBinding.FieldName = 'DOSYA_NO'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewOzelAlanAlanADI: TcxGridDBColumn
          Caption = 'Alan'
          DataBinding.FieldName = 'AlanADI'
          DataBinding.IsNullValueType = True
          Width = 80
        end
        object ViewOzelAlanOZEL_ALAN_REF: TcxGridDBColumn
          DataBinding.FieldName = 'OZEL_ALAN_REF'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewOzelAlanDEGER: TcxGridDBColumn
          Caption = 'De'#287'er'
          DataBinding.FieldName = 'DEGER'
          DataBinding.IsNullValueType = True
          Width = 100
        end
      end
      object GridOzelAlanLevel1: TcxGridLevel
        GridView = ViewOzelAlan
      end
    end
    object cxLabel1: TcxLabel
      Left = 10
      Top = 42
      Caption = 'Geldi'#287'i Yer'
    end
    object cxLabel10: TcxLabel
      Left = 316
      Top = 222
      Caption = 'Cevap S'#252'resi (g'#252'n)'
    end
    object cxLabel11: TcxLabel
      Left = 10
      Top = 252
      Caption = #304'lgili Evrak Nuamaras'#305':'
    end
    object cxLabel12: TcxLabel
      Left = 315
      Top = 252
      Caption = 'Evrak Adedi:'
    end
    object cxLabel13: TcxLabel
      Left = 316
      Top = 282
      Caption = 'Dosya Numaras'#305':'
    end
    object cxLabel14: TcxLabel
      Left = 316
      Top = 312
      Caption = 'Esas No:'
    end
    object cxLabel15: TcxLabel
      Left = 10
      Top = 282
      Caption = 'Evrak Dosya Kodu:'
    end
    object cxLabel16: TcxLabel
      Left = 10
      Top = 312
      Caption = 'Evrak Cinsi:'
    end
    object cxLabel17: TcxLabel
      Left = 10
      Top = 340
      Caption = 'Evrak '#304#231'eri'#287'i:'
    end
    object cxLabel18: TcxLabel
      Left = 10
      Top = 422
      Caption = 'A'#231#305'klama:'
    end
    object cxLabel3: TcxLabel
      Left = 10
      Top = 72
      Caption = 'Konusu'
    end
    object cxLabel4: TcxLabel
      Left = 10
      Top = 102
      Caption = 'Gelen Evrak Tarihi'
    end
    object cxLabel5: TcxLabel
      Left = 10
      Top = 132
      Caption = 'Gelen Evrak'#305'n Numaras'#305':'
    end
    object cxLabel6: TcxLabel
      Left = 10
      Top = 162
      Caption = 'Havale Edilece'#287'i Birim:'
    end
    object cxLabel7: TcxLabel
      Left = 10
      Top = 192
      Caption = 'Geli'#351' '#350'ekli:'
    end
    object cxLabel8: TcxLabel
      Left = 316
      Top = 192
      Caption = 'Yaz'#305' Durumu:'
    end
    object cxLabel9: TcxLabel
      Left = 10
      Top = 222
      Caption = 'Gizlilik Derecesi :'
    end
    object editCevapSuresi: TcxDBTextEdit
      Left = 426
      Top = 218
      DataBinding.DataField = 'CEVAP_SURESI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 9
      Width = 160
    end
    object editEsasNo: TcxDBTextEdit
      Left = 426
      Top = 308
      DataBinding.DataField = 'ESAS_NO'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 15
      Width = 160
    end
    object editEvrakAdedi: TcxTextEdit
      Left = 426
      Top = 248
      Properties.ReadOnly = True
      TabOrder = 11
      Width = 160
    end
    object editEvrakDosyaKodu: TcxDBButtonEdit
      Left = 152
      Top = 278
      DataBinding.DataField = 'EVRAK_DOSYA_KODU'
      DataBinding.DataSource = dsEvrakTablo
      Properties.Buttons = <
        item
          Default = True
          ImageIndex = 147
          Kind = bkGlyph
        end>
      TabOrder = 12
      Width = 160
    end
    object editEvrakInsertDate: TcxDBDateEdit
      Left = 152
      Top = 98
      DataBinding.DataField = 'EKLEMETARIHI'
      DataBinding.DataSource = dsEvrakTablo
      Style.BorderStyle = ebsOffice11
      TabOrder = 3
      Width = 118
    end
    object editGelenEvrakNo: TcxDBTextEdit
      Left = 152
      Top = 128
      DataBinding.DataField = 'GELEN_EVRAK_NUMARASI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 4
      Width = 434
    end
    object editIlgiliEvrakNo: TcxDBButtonEdit
      Left = 152
      Top = 248
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
      TabOrder = 10
      Width = 160
    end
    object editKonusu: TcxDBTextEdit
      Left = 152
      Top = 68
      DataBinding.DataField = 'KONU'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 2
      Width = 434
    end
    object evrakDosyaNumarasi: TcxDBTextEdit
      Left = 426
      Top = 278
      DataBinding.DataField = 'DOSYA_NUMARASI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 13
      Width = 160
    end
    object lookupEvrakCinsi: TcxDBLookupComboBox
      Left = 152
      Top = 308
      DataBinding.DataField = 'EVRAK_CINSI_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 14
      Width = 160
    end
    object lookupGeldigiYerTur: TcxDBLookupComboBox
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
    object lookupGelisSekli: TcxDBLookupComboBox
      Left = 152
      Top = 188
      DataBinding.DataField = 'GIZLILIK_DERECESI_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 6
      Width = 160
    end
    object lookupGizlilikDerecesi: TcxDBLookupComboBox
      Left = 152
      Top = 218
      DataBinding.DataField = 'GIZLILIK_DERECESI_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 8
      Width = 160
    end
    object lookupHavaleEdilecekBirim: TcxDBLookupComboBox
      Left = 152
      Top = 158
      DataBinding.DataField = 'HAVALE_EDILECEK_BIRIM_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.KeyFieldNames = 'ID'
      Properties.ListColumns = <
        item
          FieldName = 'BIRIM_KODU'
        end>
      TabOrder = 5
      Width = 434
    end
    object lookupYaziDurumu: TcxDBLookupComboBox
      Left = 426
      Top = 188
      DataBinding.DataField = 'YAZI_DURUMU_REF'
      DataBinding.DataSource = dsEvrakTablo
      Properties.ListColumns = <>
      TabOrder = 7
      Width = 160
    end
    object memoEvrakIcerik: TcxDBMemo
      Left = 152
      Top = 338
      DataBinding.DataField = 'EVRAK_ICERIGI'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 16
      Height = 78
      Width = 185
    end
    object editGeldigiYer: TcxDBTextEdit
      Left = 152
      Top = 40
      DataBinding.DataField = 'GELDIGI_YER'
      DataBinding.DataSource = dsEvrakTablo
      TabOrder = 1
      Width = 434
    end
  end
  object PanelEkDosyalar: TPanel
    AlignWithMargins = True
    Left = 589
    Top = 67
    Width = 240
    Height = 482
    Align = alClient
    TabOrder = 3
    ExplicitWidth = 244
    ExplicitHeight = 483
    object GridImaj: TcxGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 240
      Height = 476
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 236
      ExplicitHeight = 475
      object ViewImaj: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = dsImaj
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object ViewImajID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          DataBinding.IsNullValueType = True
          Visible = False
          VisibleForCustomization = False
        end
        object ViewImajBELGEADI: TcxGridDBColumn
          DataBinding.FieldName = 'BELGEADI'
          DataBinding.IsNullValueType = True
          Width = 100
        end
        object ViewImajBELGE: TcxGridDBColumn
          DataBinding.FieldName = 'BELGE'
          DataBinding.IsNullValueType = True
        end
        object ViewImajYER_ID: TcxGridDBColumn
          DataBinding.FieldName = 'YER_ID'
          DataBinding.IsNullValueType = True
        end
        object ViewImajDURUM: TcxGridDBColumn
          DataBinding.FieldName = 'DURUM'
          DataBinding.IsNullValueType = True
        end
        object ViewImajBELGENO: TcxGridDBColumn
          DataBinding.FieldName = 'BELGENO'
          DataBinding.IsNullValueType = True
        end
        object ViewImajBOYUT: TcxGridDBColumn
          DataBinding.FieldName = 'BOYUT'
          DataBinding.IsNullValueType = True
        end
        object ViewImajSURUM: TcxGridDBColumn
          DataBinding.FieldName = 'SURUM'
          DataBinding.IsNullValueType = True
        end
        object ViewImajBELGETURU: TcxGridDBColumn
          DataBinding.FieldName = 'BELGETURU'
          DataBinding.IsNullValueType = True
        end
      end
      object ImajLevel1: TcxGridLevel
        GridView = ViewImaj
      end
    end
  end
  object ActionList1: TActionList
    Images = dmEvrakModule.ImagesEvrak
    Left = 608
    Top = 40
    object actKaydet: TAction
      Caption = 'Kaydet'
      ImageIndex = 42
      OnExecute = actKaydetExecute
    end
    object actDosyaEkle: TAction
      Caption = 'Dosya Ekle / G'#246'zat'
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
      Caption = 'Dosya Ekleri G'#246'ster'
      Checked = True
      ImageIndex = 59
      OnExecute = actEkDosyalarExecute
      OnUpdate = actEkDosyalarUpdate
    end
  end
  object qryEvrakTablo: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = qryEvrakTabloAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM DOKUMAN ')
    Left = 93
    Top = 40
  end
  object qryImaj: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM IMAJ WHERE 1=1'
      'AND YER_ID=:DosyaID')
    Left = 434
    Top = 56
  end
  object dsEvrakTablo: TDataSource
    DataSet = qryEvrakTablo
    Left = 95
    Top = 88
  end
  object dsImaj: TDataSource
    DataSet = qryImaj
    Left = 428
    Top = 112
  end
  object qryOzelAlan: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryOzelAlanBeforePost
    ParamData = <>
    SQL.Strings = (
      
        'SELECT OZ.DOSYA_NO, OZ.ADI AlanADI,  DEG.OZEL_ALAN_REF, DEG.DEGE' +
        'R'
      ' from EVRAK_OZEL_ALAN OZ'
      
        '  INNER JOIN EVRAK_OZEL_ALAN_DEGER DEG ON DEG.OZEL_ALAN_REF= OZ.' +
        'ID'
      'WHERE OZ.DOSYA_NO = :DosyaNo')
    Left = 90
    Top = 432
  end
  object dsOzelAlan: TDataSource
    DataSet = qryOzelAlan
    Left = 236
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
    Top = 280
  end
end
