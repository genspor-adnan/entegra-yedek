object ServisKoduPicker: TServisKoduPicker
  Left = 0
  Top = 0
  Caption = 'ServisKoduPicker'
  ClientHeight = 287
  ClientWidth = 543
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cxDBTreeList1: TcxDBTreeList
    Left = 0
    Top = 0
    Width = 318
    Height = 287
    Align = alLeft
    Bands = <
      item
      end>
    DataController.DataSource = DtsPlan
    DataController.ParentField = 'ROOTKOD'
    DataController.KeyField = 'HESAPKODU'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    OptionsBehavior.IncSearch = True
    OptionsBehavior.IncSearchItem = cxDBTreeList1cxDBTreeListColumn4
    OptionsData.Editing = False
    OptionsData.Deleting = False
    ParentFont = False
    RootValue = -1
    TabOrder = 0
    OnClick = cxDBTreeList1Click
    OnDblClick = cxDBTreeList1DblClick
    object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
      Caption.Text = 'Kodu'
      DataBinding.FieldName = 'HESAPKODU'
      Width = 127
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
      Caption.Text = 'A'#231#305'klama'
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
    Top = 114
    Caption = 'Kodu:'
  end
  object cxDBLabel1: TcxDBLabel
    Left = 324
    Top = 44
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object cxDBLabel2: TcxDBLabel
    Left = 324
    Top = 66
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object cxDBLabel3: TcxDBLabel
    Left = 324
    Top = 88
    DataBinding.DataSource = DtsPlan
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object LabelYeniKod: TcxLabel
    Left = 324
    Top = 237
    AutoSize = False
    Caption = '.'
    Style.BorderStyle = ebsUltraFlat
    Height = 21
    Width = 216
  end
  object MemoKodlar: TcxMemo
    Left = 324
    Top = 133
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
    Top = 262
    Width = 75
    Height = 25
    Caption = 'Ekle'
    TabOrder = 9
    OnClick = EkleTusClick
  end
  object Memo1: TMemo
    Left = -11
    Top = 118
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
      ' where  BASLIK=1 and (&RefKod LIKE '#39#39'&KodGrubu%'#39#39' )'
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
      ' where  BASLIK=1 and (&RefKod LIKE '#39#39'&KodGrubu%'#39#39' )'
      ' order by 1'
      #39
      'end'
      'exec (@sql)')
    TabOrder = 10
    Visible = False
  end
  object TabPlan: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
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

