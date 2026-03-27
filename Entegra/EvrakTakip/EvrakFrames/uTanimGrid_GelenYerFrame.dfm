inherited EvrakTanimGelenYerFrame: TEvrakTanimGelenYerFrame
  Width = 802
  ExplicitWidth = 802
  inherited PanelTop: TPanel
    Width = 796
  end
  inherited PanelMain: TPanel
    Width = 796
    inherited GridTanim: TcxGrid
      Width = 472
      LookAndFeel.SkinName = ''
      ExplicitWidth = 472
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Width = 49
        end
        object ViewTanimBIRIM_ID: TcxGridDBColumn
          Caption = 'Evrak Birimi'
          DataBinding.FieldName = 'BIRIM_ID'
          PropertiesClassName = 'TcxLookupComboBoxProperties'
          Properties.KeyFieldNames = 'ID'
          Properties.ListColumns = <
            item
              FieldName = 'BIRIM_ADI'
            end>
          Properties.ListSource = dsBirimKodu
          Width = 163
        end
        object ViewTanimYER: TcxGridDBColumn
          Caption = 'Yer'
          DataBinding.FieldName = 'YER'
          Width = 141
        end
        object ViewTanimYER_BIRIM_KODU: TcxGridDBColumn
          Caption = 'Yer Birim Kodu'
          DataBinding.FieldName = 'YER_BIRIM_KODU'
          Width = 100
        end
        object ViewTanimYER_TUR_ID: TcxGridDBColumn
          Caption = 'Yer T'#252'r'#252
          DataBinding.FieldName = 'YER_TUR_ID'
          PropertiesClassName = 'TcxLookupComboBoxProperties'
          Properties.KeyFieldNames = 'ID'
          Properties.ListColumns = <
            item
              FieldName = 'TUR'
            end>
          Properties.ListSource = dsLookupYerTur
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Left = 473
    end
    inherited GridPanel1: TGridPanel
      Left = 481
      Width = 314
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = editYer
          Row = 1
        end
        item
          Column = 0
          Control = Label2
          Row = 1
        end
        item
          Column = 1
          Control = lookupBirimKodu
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 2
        end
        item
          Column = 1
          Control = editYerBirimKodu
          Row = 2
        end
        item
          Column = 0
          Control = Label4
          Row = 3
        end
        item
          Column = 1
          Control = lookupYerTur
          Row = 3
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end>
      ExplicitLeft = 344
      ExplicitWidth = 451
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 69
        Height = 22
        Align = alLeft
        Caption = 'Evrak Birimi'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editYer: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'YER'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        ExplicitLeft = 209
        ExplicitTop = 3
        ExplicitHeight = 21
        Width = 181
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 19
        Height = 22
        Align = alLeft
        Caption = 'Yer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupBirimKodu: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'BIRIM_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'BIRIM_ADI'
          end>
        Properties.ListOptions.ShowHeader = False
        Properties.ListSource = dsBirimKodu
        TabOrder = 1
        ExplicitLeft = 197
        ExplicitTop = 31
        ExplicitHeight = 21
        Width = 181
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 85
        Height = 22
        Align = alLeft
        Caption = 'Yer Birim Kodu'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editYerBirimKodu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 59
        Align = alLeft
        DataBinding.DataField = 'YER_BIRIM_KODU'
        DataBinding.DataSource = dsEvrak
        TabOrder = 2
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 181
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 49
        Height = 22
        Align = alLeft
        Caption = 'Yer T'#252'r'#252
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupYerTur: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 87
        Align = alLeft
        DataBinding.DataField = 'YER_TUR_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'TUR'
          end>
        Properties.ListOptions.ShowHeader = False
        Properties.ListSource = dsLookupYerTur
        TabOrder = 3
        ExplicitLeft = 197
        ExplicitHeight = 21
        Width = 145
      end
    end
  end
  inherited ActionListFrame: TActionList
    Left = 488
    Top = 200
  end
  inherited qryEvrak: TFDQuery
    SQL.Strings = (
      'SELECT * FROM EVRAK_GELEN_YER ORDER BY ID')
    Left = 155
    Top = 103
  end
  object qryLookupBirimKodu: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT ID,*'
      'FROM EVRAK_BIRIMI'
      'Order by BIRIM_KODU')
    Left = 88
    Top = 200
  end
  object dsBirimKodu: TDataSource
    AutoEdit = False
    DataSet = qryLookupBirimKodu
    Left = 80
    Top = 280
  end
  object qryLookupYerTur: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT ID,TUR'
      'FROM EVRAK_GELEN_YER_TUR'
      'Order by TUR')
    Left = 216
    Top = 208
  end
  object dsLookupYerTur: TDataSource
    AutoEdit = False
    DataSet = qryLookupYerTur
    Left = 240
    Top = 272
  end
end
