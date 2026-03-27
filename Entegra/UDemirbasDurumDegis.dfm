object DemirbasDurumDegisDlg: TDemirbasDurumDegisDlg
  Left = 0
  Top = 0
  Caption = 'Demirba'#351' Durum De'#287'i'#351'ikli'#287'i'
  ClientHeight = 334
  ClientWidth = 543
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
  object edTarih: TcxDateEdit
    Left = 88
    Top = 15
    Properties.ImmediatePost = True
    Properties.Kind = ckDateTime
    Properties.ShowOnlyValidDates = True
    TabOrder = 0
    Width = 160
  end
  object lblTarih: TcxLabel
    Left = 6
    Top = 16
    Caption = 'Tarih'
  end
  object lbAlanPersonel: TcxLabel
    Left = 6
    Top = 66
    Caption = 'Alan Personel'
  end
  object lbVerenPersonel: TcxLabel
    Left = 6
    Top = 41
    Caption = 'Veren Personel'
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 120
    Width = 543
    Height = 184
    Align = alBottom
    TabOrder = 4
    Properties.ActivePage = SheetAciklama
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 180
    ClientRectLeft = 4
    ClientRectRight = 539
    ClientRectTop = 24
    object SheetAciklama: TcxTabSheet
      Caption = 'A'#231#305'klama'
      ImageIndex = 0
      object MemoAciklama: TcxMemo
        Left = 0
        Top = 0
        Align = alClient
        TabOrder = 0
        Height = 156
        Width = 535
      end
    end
    object SheetDemirbas: TcxTabSheet
      Caption = 'Demirba'#351
      ImageIndex = 4
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 535
        Height = 156
        Align = alClient
        TabOrder = 0
        object cxGrid1DBTableView1: TcxGridDBTableView
          PopupMenu = PopupDemirbas
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = dtsDemirbas
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGrid1DBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object cxGrid1DBTableView1DEMIRBASNO: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'DEMIRBASNO'
            Width = 95
          end
          object cxGrid1DBTableView1DEMIRBASADI: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'DEMIRBASADI'
            Width = 265
          end
          object cxGrid1DBTableView1SERINO: TcxGridDBColumn
            Caption = 'Serino'
            DataBinding.FieldName = 'SERINO'
            Width = 90
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGrid1DBTableView1
        end
      end
    end
    object SheetAlisBelgesi: TcxTabSheet
      Caption = 'Al'#305#351' Belgesi'
      ImageIndex = 0
      object cbAlBelgeTipi: TcxImageComboBox
        Left = 88
        Top = 22
        EditValue = 10
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Al'#305#351' '#304'rsaliyesi'
            ImageIndex = 0
            Value = 10
          end
          item
            Description = 'Al'#305#351' Faturas'#305
            Value = 11
          end
          item
            Description = 'Al'#305#351' Fi'#351'i'
            Value = 12
          end
          item
            Description = 'Di'#287'er Al'#305#351' Belgeleri'
            Value = 3
          end>
        TabOrder = 0
        Width = 121
      end
      object lbAlBelgeTipi: TcxLabel
        Left = 14
        Top = 24
        Caption = 'Belge Tipi'
      end
      object DateAlBelge: TcxDateEdit
        Left = 88
        Top = 49
        Properties.ImmediatePost = True
        Properties.ShowOnlyValidDates = True
        TabOrder = 2
        Width = 121
      end
      object cxLabel3: TcxLabel
        Left = 14
        Top = 50
        Caption = 'Belge Tarihi'
      end
      object CurAlTutar: TcxCurrencyEdit
        Left = 309
        Top = 22
        EditValue = '0'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.Nullable = False
        TabOrder = 4
        Width = 92
      end
      object cxLabel4: TcxLabel
        Left = 270
        Top = 24
        Caption = 'Tutar'
      end
      object cbAlKur: TcxComboBox
        Left = 400
        Top = 22
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        TabOrder = 6
        Width = 49
      end
    end
    object SheetSatisBelgesi: TcxTabSheet
      Caption = 'Sat'#305#351' Belgesi'
      ImageIndex = 1
      object cbVerBelgeTipi: TcxImageComboBox
        Left = 88
        Top = 22
        EditValue = 14
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Sat'#305#351' '#304'rsaliyesi'
            ImageIndex = 0
            Value = 14
          end
          item
            Description = 'Sat'#305#351' Faturas'#305
            Value = 15
          end
          item
            Description = 'Sat'#305#351' Fi'#351'i'
            Value = 16
          end
          item
            Description = 'Di'#287'er Sat'#305#351' Belgeleri'
            Value = 4
          end>
        TabOrder = 0
        Width = 121
      end
      object cxLabel5: TcxLabel
        Left = 14
        Top = 24
        Caption = 'Belge Tipi'
      end
      object DateVerBelge: TcxDateEdit
        Left = 88
        Top = 49
        Properties.ImmediatePost = True
        Properties.ShowOnlyValidDates = True
        TabOrder = 2
        Width = 121
      end
      object cxLabel6: TcxLabel
        Left = 14
        Top = 50
        Caption = 'Belge Tarihi'
      end
      object CurVerTutar: TcxCurrencyEdit
        Left = 307
        Top = 22
        EditValue = '0'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.Nullable = False
        TabOrder = 4
        Width = 92
      end
      object cxLabel7: TcxLabel
        Left = 270
        Top = 24
        Caption = 'Tutar'
      end
      object cbVerKur: TcxComboBox
        Left = 399
        Top = 22
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        TabOrder = 6
        Width = 49
      end
    end
    object SheetCariBilgi: TcxTabSheet
      Caption = 'Cari Bilgisi'
      ImageIndex = 2
      object BeditMusteri: TcxButtonEdit
        Left = 96
        Top = 23
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = BeditMusteriPropertiesButtonClick
        TabOrder = 0
        Width = 254
      end
      object BeditMusteriIlgili: TcxButtonEdit
        Left = 96
        Top = 46
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = BeditMusteriIlgiliPropertiesButtonClick
        TabOrder = 1
        Width = 254
      end
      object lbMusteri: TcxLabel
        Left = 14
        Top = 24
        Caption = 'M'#252#351'teri'
      end
      object lbMusIlgili: TcxLabel
        Left = 14
        Top = 47
        Caption = 'M'#252#351'teri '#304'lgili'
      end
    end
  end
  object EditLokasyon: TcxButtonEdit
    Left = 363
    Top = 65
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.OnButtonClick = EditLokasyonPropertiesButtonClick
    TabOrder = 5
    Width = 160
  end
  object EdBelgeNo: TcxTextEdit
    Left = 363
    Top = 40
    TabOrder = 6
    Width = 160
  end
  object cxLabel1: TcxLabel
    Left = 311
    Top = 41
    Caption = 'Belgeno'
  end
  object cxLabel2: TcxLabel
    Left = 311
    Top = 66
    Caption = 'Lokasyon'
  end
  object Panel1: TPanel
    Left = 0
    Top = 304
    Width = 543
    Height = 30
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 9
    object CancelBtn: TBitBtn
      Left = 383
      Top = 3
      Width = 72
      Height = 24
      Cancel = True
      Caption = 'Ka&pat'
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
      TabOrder = 0
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 304
      Top = 3
      Width = 73
      Height = 24
      Caption = '&Kaydet'
      Default = True
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
      TabOrder = 1
      IsControl = True
    end
  end
  object cbDurum: TcxImageComboBox
    Left = 363
    Top = 15
    Properties.ImmediatePost = True
    Properties.ImmediateUpdateText = True
    Properties.Items = <>
    TabOrder = 10
    Width = 160
  end
  object cxLabel10: TcxLabel
    Left = 311
    Top = 16
    Caption = #304#351'lem'
  end
  object BeditVerenPersonel: TcxButtonEdit
    Left = 88
    Top = 40
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
    Properties.OnButtonClick = BeditAlanPersonelPropertiesButtonClick
    ShowHint = True
    TabOrder = 12
    Width = 160
  end
  object BeditAlanPersonel: TcxButtonEdit
    Left = 88
    Top = 65
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
    Properties.OnButtonClick = BeditAlanPersonelPropertiesButtonClick
    ShowHint = True
    TabOrder = 13
    Width = 160
  end
  object tabDemirbas: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select D.ID,D.DEMIRBASNO,D.DEMIRBASADI,D.SERINO '
      
        'from DEMIRBAS D inner join DEMIRBAS_TUTANAK_DETAY DTD on D.ID=DT' +
        'D.DEMIRBASID '
      'where DTD.TUTANAKID=:PDemirbasTutID ')
    Left = 96
    Top = 232
  end
  object dtsDemirbas: TDataSource
    DataSet = tabDemirbas
    Left = 56
    Top = 224
  end
  object PopupDemirbas: TPopupMenu
    Left = 192
    Top = 240
    object Seilidemirbalistedenkart1: TMenuItem
      Caption = 'Se'#231'ili demirba'#351#305' listeden '#231#305'kart'
      OnClick = Seilidemirbalistedenkart1Click
    end
  end
end

