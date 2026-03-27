object CekListeDlg: TCekListeDlg
  Left = 80
  Top = 149
  Caption = #199'ek Listesi'
  ClientHeight = 513
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1008
    Height = 121
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 1004
    object BtnListele: TSpeedButton
      Left = 719
      Top = 13
      Width = 120
      Height = 33
      Caption = 'Listele'
      Glyph.Data = {
        76060000424D7606000000000000360400002800000015000000180000000100
        08000000000040020000030F0000030F0000000100000001000031310000FF84
        0000DE944A0052525200E7A55A0063636300B5848400EFBD84009C9C9C00C6A5
        A500FFD6A500C6C6C600CECECE00FFE7CE00D6D6D600DEDEDE00E7E7E700EFEF
        EF00FFF7EF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00131313131313
        1313130508131313131313131313130000001313131313131313130301051313
        1313131313131300000013131313131313131303040013131313131313131300
        0000131313131313131308020201081313131313131313000000131313131313
        1308080D040201081313131313131300000013131313131308020D0A0A040203
        0813131313131300000013131313130808120D0D0A0407020108131313131300
        000013131313080212120D0A0407070702030813131313000000131313080212
        04010105010103030101010813131300000013130803030305050B1111110905
        0303030308131300000013080301010511111111111109050101010103081300
        0000080301010311111111080811090805030101010308000000080301010108
        081111111111090F080301010103080000000803010308111111111111110910
        0C08030101030800000013080306111111080808110910100F0C030303081300
        00001313060811111111111111091010100F0505131313000000131306081111
        11111111090810101010090513131300000013091111110808090909050C1010
        10080803081313000000130909090909090C090C141409090908080903131300
        00000809050808080B0C0509090911141414141409131300000008030908080B
        0C0C0C0C0C0E14141414140C09131300000013080809080B0C0C0C0C0C11140C
        0C08090513131300000013131313090905080805080805090908131313131300
        0000131313131313090909090909091313131313131313000000}
      OnClick = BtnListeleClick
    end
    object Label1: TcxLabel
      Left = 5
      Top = 13
      Caption = 'Vade Ba'#351'lang'#305#231
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object Label2: TcxLabel
      Left = 5
      Top = 43
      Caption = 'Vade Biti'#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object Label4: TcxLabel
      Left = 5
      Top = 67
      Caption = 'Hesap Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object DateBaslangic: TDateTimePicker
      Left = 120
      Top = 12
      Width = 89
      Height = 24
      Date = 39613.000000000000000000
      Time = 0.025735856492246970
      TabOrder = 0
    end
    object DateBitis: TDateTimePicker
      Left = 120
      Top = 39
      Width = 89
      Height = 24
      Date = 39613.000000000000000000
      Time = 0.025872754631564020
      TabOrder = 1
    end
    object GrupCekTuru: TRadioGroup
      Left = 344
      Top = 8
      Width = 353
      Height = 33
      Caption = #199'ek T'#252'r'#252
      Columns = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'T'#252'm'#252
        'Verilen'
        'Al'#305'nan')
      ParentFont = False
      TabOrder = 2
      OnClick = GrupCekTuruClick
    end
    object GrupCekDurum: TRadioGroup
      Left = 344
      Top = 43
      Width = 353
      Height = 34
      Caption = #199'ek Durumu'
      Columns = 3
      Enabled = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'T'#252'm'#252)
      ParentFont = False
      TabOrder = 3
    end
    object EditHesapKod: TEdit
      Left = 120
      Top = 66
      Width = 145
      Height = 24
      TabOrder = 4
    end
    object ToolBar1: TToolBar
      Left = 857
      Top = 9
      Width = 149
      Height = 40
      Align = alNone
      ButtonHeight = 24
      ButtonWidth = 51
      Caption = 'ToolBar1'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      ShowCaptions = True
      TabOrder = 5
      object EkranYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'CekListe'
        ImageIndex = 2
        OnClick = EkranYazClick
      end
      object YaziciYaz: TToolButton
        Left = 51
        Top = 0
        Caption = 'CekListe'
        ImageIndex = 1
        OnClick = EkranYazClick
      end
      object ToolButton2: TToolButton
        Left = 102
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 110
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 3
        OnClick = ToolButton1Click
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 121
    Width = 1008
    Height = 392
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 1004
    ExplicitHeight = 391
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 1006
      Height = 335
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.ScrollbarMode = sbmClassic
      ExplicitWidth = 1002
      ExplicitHeight = 334
      object CekListesiTableview: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsCekListesi
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = '###,##0.00'
            Kind = skSum
            FieldName = 'GIREN'
            Column = ColumnGIREN
          end
          item
            Format = '###,##0.00'
            Kind = skSum
            FieldName = 'CIKAN'
            Column = ColumnCIKAN
          end
          item
            Kind = skCount
            FieldName = 'HESAPKODU'
            Column = CekListesiTableviewDBColumn1
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        Preview.Column = CekListesiTableviewDBColumn1
        Preview.Place = ppTop
        object CekListesiTableviewDBColumn14: TcxGridDBColumn
          Caption = 'S'#305'rano'
          DataBinding.FieldName = 'SIRANO'
        end
        object CekListesiTableviewDBColumn7: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
        end
        object CekListesiTableviewDBColumn1: TcxGridDBColumn
          DataBinding.FieldName = 'TARIH'
        end
        object CekListesiTableviewDBColumn2: TcxGridDBColumn
          Caption = 'Cari Kod'
          DataBinding.FieldName = 'CARIKOD'
        end
        object CekListesiTableviewDBColumn3: TcxGridDBColumn
          Caption = 'Cari Ad'
          DataBinding.FieldName = 'CARIAD'
        end
        object CekListesiTableviewDBColumn4: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
        end
        object CekListesiTableviewDBColumn5: TcxGridDBColumn
          Caption = 'Hesap Kodu'
          DataBinding.FieldName = 'HESAPKODU'
        end
        object CekListesiTableviewDBColumn6: TcxGridDBColumn
          Caption = 'Hesap Ad'#305
          DataBinding.FieldName = 'HESAPADI'
        end
        object ColumnGIREN: TcxGridDBColumn
          Caption = 'Giren'
          DataBinding.FieldName = 'GIREN'
        end
        object ColumnCIKAN: TcxGridDBColumn
          Caption = #199#305'kan'
          DataBinding.FieldName = 'CIKAN'
        end
        object CekListesiTableviewDBColumn9: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
        end
        object CekListesiTableviewDBColumn10: TcxGridDBColumn
          Caption = 'Masraf Ad'#305
          DataBinding.FieldName = 'MASRAFAD'
        end
        object CekListesiTableviewDBColumn11: TcxGridDBColumn
          Caption = 'Masraf Kodu'
          DataBinding.FieldName = 'MASRAFKOD'
        end
        object CekListesiTableviewDBColumn12: TcxGridDBColumn
          Caption = 'Vade'
          DataBinding.FieldName = 'VADE'
        end
        object CekListesiTableviewDBColumn13: TcxGridDBColumn
          Caption = #214'deme Tarihi'
          DataBinding.FieldName = 'ODEMETARIH'
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = CekListesiTableview
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 336
      Width = 1006
      Height = 55
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 335
      ExplicitWidth = 1002
      object LabelGiren: TcxLabel
        Left = 512
        Top = 32
        Caption = 'Giren'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
      end
      object LabelCikan: TcxLabel
        Left = 512
        Top = 9
        Caption = #199#305'kan'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
      end
      object Label5: TcxLabel
        Left = 368
        Top = 9
        Caption = 'Verilen '#199'ekler Toplam'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
      end
      object Label6: TcxLabel
        Left = 368
        Top = 32
        Caption = 'Al'#305'nan '#199'ekler Toplam'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
      end
      object LabelSayi: TcxLabel
        Left = 136
        Top = 16
        Caption = 'LabelSayi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
      end
    end
  end
  object TabCekListesi: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabCekListesiAfterOpen
    ParamData = <>
    SQL.Strings = (
      'SELECT '
      
        'TARIH, CARIKOD, CARIAD, ACIKLAMA, GIREN, CIKAN, HESAPKODU, HESAP' +
        'ADI, KUR, MASRAFKOD, MASRAFAD '
      '                                   FROM KASA')
    Left = 136
    Top = 241
  end
  object DtsCekListesi: TDataSource
    DataSet = TabCekListesi
    Left = 104
    Top = 201
  end
end


