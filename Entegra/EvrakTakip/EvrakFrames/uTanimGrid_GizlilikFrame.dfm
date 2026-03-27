inherited EvrakTanimGizlilikFrame: TEvrakTanimGizlilikFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.ColumnAutoWidth = True
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
        end
        object ViewTanimADI: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'ADI'
        end
      end
    end
    inherited GridPanel1: TGridPanel
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = cxDBTextEdit2
          Row = 0
        end>
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 72
        Height = 22
        Align = alLeft
        Caption = 'Gizlilik Tan'#305'm'#305
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object cxDBTextEdit2: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 176
      end
    end
  end
  inherited ActionListFrame: TActionList
    inherited actReset: TAction
      OnExecute = actResetExecute
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_GIZLILIK')
  end
end

