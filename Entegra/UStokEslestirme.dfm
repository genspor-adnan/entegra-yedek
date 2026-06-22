object StokEslestirmeDlg: TStokEslestirmeDlg
  Left = 0
  Top = 0
  Caption = 'Stok / Hizmet E'#351'le'#351'tirme'
  ClientHeight = 480
  ClientWidth = 980
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 18
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblCari: TcxLabel
      Left = 16
      Top = 8
      Caption = 'Cari'
    end
    object beCari: TcxButtonEdit
      Left = 16
      Top = 28
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = beCariPropertiesButtonClick
      TabOrder = 0
      Width = 500
    end
    object lblBilgi: TcxLabel
      Left = 530
      Top = 30
      Caption = 'Sa'#287'daki butonla cari se'#231'in. Sonra '#39'Yeni'#39' ile sat'#305'r ekleyin.'
      Style.TextColor = clGrayText
    end
  end
  object Grid: TcxGrid
    Left = 0
    Top = 60
    Width = 980
    Height = 380
    Align = alClient
    TabOrder = 1
    object GridView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCellClick = GridViewCellClick
      DataController.DataSource = DS
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsSelection.MultiSelect = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
        Options.Editing = False
      end
      object GridViewGELEN_KOD: TcxGridDBColumn
        Caption = 'Gelen Kod'
        DataBinding.FieldName = 'GELEN_KOD'
        DataBinding.IsNullValueType = True
        Width = 110
      end
      object GridViewGELEN_AD: TcxGridDBColumn
        Caption = 'Gelen Ad'
        DataBinding.FieldName = 'GELEN_AD'
        DataBinding.IsNullValueType = True
        Width = 240
      end
      object GridViewTIP: TcxGridDBColumn
        Caption = #220'r'#252'n Tipi'
        DataBinding.FieldName = 'TIP'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Hizmet'
            Value = 0
          end
          item
            Description = 'Stok'
            Value = 1
          end>
        Width = 80
      end
      object GridViewURUNID: TcxGridDBColumn
        DataBinding.FieldName = 'URUNID'
        DataBinding.IsNullValueType = True
        Visible = False
        Options.Editing = False
      end
      object GridViewKARSILIK_KOD: TcxGridDBColumn
        Caption = 'Kar'#351#305'l'#305'k Kod'
        DataBinding.FieldName = 'KARSILIK_KOD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = GridViewKARSILIK_KODPropertiesButtonClick
        Options.Editing = False
        Width = 110
      end
      object GridViewKARSILIK_AD: TcxGridDBColumn
        Caption = 'Kar'#351#305'l'#305'k Ad'
        DataBinding.FieldName = 'KARSILIK_AD'
        DataBinding.IsNullValueType = True
        Options.Editing = False
        Width = 240
      end
      object GridViewESLESME_TURU: TcxGridDBColumn
        Caption = 'E'#351'le'#351'me T'#252'r'#252
        DataBinding.FieldName = 'ESLESME_TURU'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Kod'
            Value = 0
          end
          item
            Description = #220'r'#252'n No'
            Value = 1
          end
          item
            Description = 'KDV Gruplu'
            Value = 2
          end
          item
            Description = 'Ad (LIKE)'
            Value = 3
          end
          item
            Description = 'Ad (Tam)'
            Value = 4
          end>
        Width = 110
      end
      object GridViewAKTIF: TcxGridDBColumn
        Caption = 'Aktif'
        DataBinding.FieldName = 'AKTIF'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
        Width = 50
      end
    end
    object GridLevel: TcxGridLevel
      GridView = GridView
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 440
    Width = 980
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnYeni: TcxButton
      Left = 12
      Top = 6
      Width = 90
      Height = 28
      Caption = '+ Yeni'
      TabOrder = 0
      OnClick = btnYeniClick
    end
    object btnSil: TcxButton
      Left = 108
      Top = 6
      Width = 90
      Height = 28
      Caption = #215' Sil'
      TabOrder = 1
      OnClick = btnSilClick
    end
    object btnKaydet: TcxButton
      Left = 770
      Top = 6
      Width = 90
      Height = 28
      Caption = 'Kaydet'
      TabOrder = 2
      OnClick = btnKaydetClick
    end
    object btnKapat: TcxButton
      Left = 866
      Top = 6
      Width = 100
      Height = 28
      Caption = 'Kapat'
      ModalResult = 2
      TabOrder = 3
      OnClick = btnKapatClick
    end
  end
  object Q: TFDQuery
    OnCalcFields = QCalcFields
    CachedUpdates = True
    Left = 200
    Top = 224
    ParamData = <
      item
        Name = 'R'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object DS: TDataSource
    DataSet = Q
    Left = 304
    Top = 232
  end
end
