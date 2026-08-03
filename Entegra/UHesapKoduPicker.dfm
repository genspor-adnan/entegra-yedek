object HesapKoduPicker: THesapKoduPicker
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Hesap Kodu Se'#231'me Ekran'#305
  ClientHeight = 322
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object cxDBTreeList1: TcxDBTreeList
    Left = 0
    Top = 0
    Width = 318
    Height = 322
    Align = alLeft
    Bands = <
      item
      end>
    DataController.DataSource = DtsPlan
    DataController.ParentField = 'ROOTKOD'
    DataController.KeyField = 'HESAPKODU'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    Navigator.Buttons.CustomButtons = <>
    OptionsBehavior.IncSearch = True
    OptionsBehavior.IncSearchItem = cxDBTreeList1cxDBTreeListColumn4
    OptionsData.Editing = False
    OptionsData.Deleting = False
    ParentFont = False
    RootValue = -1
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 0
    OnClick = cxDBTreeList1Click
    OnDblClick = cxDBTreeList1DblClick
    object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
      DataBinding.FieldName = 'HESAPKODU'
      Width = 127
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
      DataBinding.FieldName = 'HESAPADI'
      Width = 167
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object cxLabel1: TcxLabel
    Left = 324
    Top = 26
    Caption = 'Kod Grubu:'
  end
  object cxLabel2: TcxLabel
    Left = 324
    Top = 116
    Caption = 'Kodu:'
  end
  object cxDBLabel1: TcxDBLabel
    Left = 324
    Top = 45
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object cxDBLabel2: TcxDBLabel
    Left = 324
    Top = 69
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object cxDBLabel3: TcxDBLabel
    Left = 324
    Top = 92
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object LabelYeniKod: TcxLabel
    Left = 324
    Top = 243
    AutoSize = False
    Caption = '.'
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object MemoKodlar: TcxMemo
    Left = 324
    Top = 137
    Lines.Strings = (
      '.')
    Style.Color = clBtnFace
    TabOrder = 7
    Height = 103
    Width = 217
  end
  object cxLabel4: TcxLabel
    Left = 324
    Top = 5
    Caption = 'Sol Taraftan Kodu Se'#231'iniz.'
    Style.TextColor = clMaroon
    Style.TextStyle = [fsBold]
  end
  object EkleTus: TcxButton
    Left = 466
    Top = 267
    Width = 75
    Height = 25
    Caption = 'Ekle'
    TabOrder = 9
    OnClick = EkleTusClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 177
    Width = 530
    Height = 35
    Lines.Strings = (
      'declare @sql nvarchar(2000)'
      
        'if exists (select COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS wh' +
        'ere '
      'TABLE_NAME='#39'&RefTablo'#39
      'and COLUMN_NAME='#39'DIGITSAY'#39')'
      'begin'
      'set @sql = '
      #39
      
        ' Select ROOTKOD=REVERSE( SUBSTRING(REVERSE(&RefKod),CHARINDEX('#39#39 +
        '.'#39#39',REVERSE'
      
        '(&RefKod),1)+1,LEN(&RefKod)-(CHARINDEX('#39#39'.'#39#39',REVERSE(&RefKod),1)' +
        '-1))),'
      ' &RefKod,&RefAd,'
      ' DIGITSAY=isnull(DIGITSAY,0) '
      ' from &RefTablo '
      ' where DURUM=1 and (VARSAYILAN = &KodGrubu)'
      ' order by 1'
      #39
      'end'
      'else '
      'begin'
      'set @sql = '
      #39
      
        ' Select ROOTKOD=REVERSE( SUBSTRING(REVERSE(&RefKod),CHARINDEX('#39#39 +
        '.'#39#39',REVERSE'
      
        '(&RefKod),1)+1,LEN(&RefKod)-(CHARINDEX('#39#39'.'#39#39',REVERSE(&RefKod),1)' +
        '-1))),'
      ' &RefKod,&RefAd,'
      ' DIGITSAY=0'
      ' from &RefTablo '
      ' where DURUM=1 and (VARSAYILAN = &KodGrubu)'
      ' order by 1'
      #39
      'end'
      'exec (@sql)')
    TabOrder = 10
    Visible = False
    WordWrap = False
  end
  object TabPlan: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX('#39 +
        '.'#39',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX('#39'.'#39',REVERSE' +
        '(HESAPKODU),1)-1))),* from HESAPPLANI')
    Left = 149
    Top = 68
  end
  object DtsPlan: TDataSource
    DataSet = TabPlan
    Left = 216
    Top = 66
  end
end
