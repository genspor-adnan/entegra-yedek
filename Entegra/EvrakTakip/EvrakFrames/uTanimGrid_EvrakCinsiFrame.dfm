inherited EvrakTanimEvrakCinsiFrame: TEvrakTanimEvrakCinsiFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.ColumnAutoWidth = True
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Width = 49
        end
        object ViewTanimADI: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'ADI'
          Width = 199
        end
      end
    end
    inherited GridPanel1: TGridPanel
      ControlCollection = <
        item
          Column = 0
          Control = Label2
          Row = 0
        end
        item
          Column = 1
          Control = editAdi
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
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 95
        Height = 22
        Align = alLeft
        Caption = 'Evrak Cinsi Tan'#305'm'#305
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        Width = 230
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_CINSI')
  end
end

