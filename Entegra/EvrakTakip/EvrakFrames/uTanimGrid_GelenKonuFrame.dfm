inherited EvrakTanimGelenKonuFrame: TEvrakTanimGelenKonuFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      Width = 304
      LookAndFeel.SkinName = ''
      ExplicitLeft = 3
      ExplicitTop = 0
      ExplicitWidth = 304
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.ColumnAutoWidth = True
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Width = 44
        end
        object ViewTanimBIRIM_ID: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM_ID'
          Width = 93
        end
        object ViewTanimKONU: TcxGridDBColumn
          Caption = 'Konu'
          DataBinding.FieldName = 'KONU'
          Width = 165
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Left = 305
    end
    inherited GridPanel1: TGridPanel
      Left = 313
      Width = 320
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 100.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 300.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = editKonu
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
        end>
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 70
        Height = 22
        Align = alLeft
        Caption = 'Evrak Birimi :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editKonu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 103
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'KONU'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        ExplicitLeft = 123
        Width = 190
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 36
        Height = 22
        Align = alLeft
        Caption = 'Konu :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupBirimKodu: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 103
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'BIRIM_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'BIRIM_KODU'
          end
          item
            FieldName = 'BIRIM_ADI'
          end>
        Properties.ListSource = dsBirimKodu
        TabOrder = 1
        ExplicitLeft = 123
        Width = 190
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT *  FROM EVRAK_GELENEVRAK_KONU Order by ID')
  end
  object qryLookupBirimKodu: TFDQuery
    Active = True
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
    Left = 160
    Top = 288
  end
end



