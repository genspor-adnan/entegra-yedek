object ProjeMaliyetDlg: TProjeMaliyetDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Proje Maliyet Kalemleri'
  ClientHeight = 419
  ClientWidth = 879
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar4: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 873
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
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object BtnYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = BtnYeniClick
    end
    object BtnSil: TToolButton
      Left = 62
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = BtnSilClick
    end
    object BtnKaydet: TToolButton
      Left = 124
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 186
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = BtnIptalClick
    end
  end
  object gridMaliyet: TcxGrid
    Left = 0
    Top = 27
    Width = 879
    Height = 392
    Align = alClient
    TabOrder = 1
    object gridMaliyetView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsMaliyet
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'TUTAR'
          Column = gridMaliyetViewTUTAR
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Appending = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      object gridMaliyetViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Visible = False
      end
      object gridMaliyetViewPROJEID: TcxGridDBColumn
        DataBinding.FieldName = 'PROJEID'
        Visible = False
      end
      object gridMaliyetViewMASRAFID: TcxGridDBColumn
        DataBinding.FieldName = 'MASRAFID'
        Visible = False
      end
      object gridMaliyetViewPROJEKODU: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJEKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Caption = '++'
            Default = True
            Kind = bkText
          end
          item
            Caption = '+'
            Kind = bkText
          end
          item
            Caption = '-'
            Kind = bkText
          end>
        Properties.OnButtonClick = gridMaliyetViewPROJEKODUPropertiesButtonClick
        Width = 165
      end
      object gridMaliyetViewPROJEADI: TcxGridDBColumn
        Caption = 'Proje Ad'#305' '
        DataBinding.FieldName = 'PROJEADI'
        PropertiesClassName = 'TcxTextEditProperties'
        Options.Editing = False
        Width = 141
      end
      object gridMaliyetViewMASRAFKODU: TcxGridDBColumn
        Caption = 'Masraf Kodu'
        DataBinding.FieldName = 'MASRAFKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Caption = '+'
            Default = True
            Kind = bkText
          end
          item
            Caption = '-'
            Kind = bkText
          end>
        Properties.OnButtonClick = gridMaliyetViewMASRAFKODUPropertiesButtonClick
      end
      object gridMaliyetViewMASRAFADI: TcxGridDBColumn
        Caption = 'Masraf Ad'#305
        DataBinding.FieldName = 'MASRAFADI'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.ReadOnly = True
        Options.Editing = False
        Width = 150
      end
      object gridMaliyetViewTUTAR: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 96
      end
      object gridMaliyetViewKUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.DropDownListStyle = lsFixedList
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        Width = 43
      end
    end
    object gridMaliyetLevel1: TcxGridLevel
      GridView = gridMaliyetView
    end
  end
  object SqlMemoMasrafKalemi: TMemo
    Left = 81
    Top = 260
    Width = 436
    Height = 30
    Lines.Strings = (
      
        '  select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),' +
        'CHARINDEX'
      '('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39')'
      '    )-(CHARINDEX('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
      
        ' M.ID,  M.KOD, M.AD,PROJEID,MASRAFID,SUBEID=-1,DURUM=1, GELIRMI=' +
        '0, '
      'BARKOD=0'
      
        ' from PROJEBUTCE PB inner join MASRAFGELIR M on M.ID = PB.MASRAF' +
        'ID ')
    TabOrder = 2
    Visible = False
  end
  object TabMaliyet: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabMaliyetNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *,'
      
        'PROJEKODU=(SELECT PROJEKODU FROM PROJELER P WHERE P.ID=PM.PROJEI' +
        'D),'
      
        'PROJEADI=(SELECT PROJEADI FROM PROJELER P WHERE P.ID=PM.PROJEID)' +
        ','
      
        'MASRAFKODU=(SELECT KOD FROM MASRAFGELIR M WHERE M.ID=PM.MASRAFID' +
        '),'
      'MASRAFADI=(SELECT AD FROM MASRAFGELIR M WHERE M.ID=PM.MASRAFID) '
      'from PROJEMALIYET PM'
      'where YER = :pyer AND YERID=:PYERID '
      ''
      '')
    Left = 245
    Top = 125
    object TabMaliyetID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabMaliyetYER: TIntegerField
      FieldName = 'YER'
    end
    object TabMaliyetYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabMaliyetPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabMaliyetMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabMaliyetTUTAR: TBCDField
      FieldName = 'TUTAR'
      Precision = 19
    end
    object TabMaliyetEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabMaliyetKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabMaliyetEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabMaliyetDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabMaliyetDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabMaliyetPROJEKODU: TWideStringField
      FieldName = 'PROJEKODU'
      ReadOnly = True
      Size = 100
    end
    object TabMaliyetPROJEADI: TWideStringField
      FieldName = 'PROJEADI'
      ReadOnly = True
      Size = 100
    end
    object TabMaliyetMASRAFKODU: TWideStringField
      FieldName = 'MASRAFKODU'
      ReadOnly = True
    end
    object TabMaliyetMASRAFADI: TWideStringField
      FieldName = 'MASRAFADI'
      ReadOnly = True
      Size = 200
    end
  end
  object DtsMaliyet: TDataSource
    DataSet = TabMaliyet
    OnStateChange = DtsMaliyetStateChange
    Left = 349
    Top = 133
  end
end

