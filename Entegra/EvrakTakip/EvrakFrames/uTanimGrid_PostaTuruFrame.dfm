inherited EvrakTanimPostaTurFrame: TEvrakTanimPostaTurFrame
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
          Control = editYaziDurumuAdi
          Row = 0
        end>
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 97
        Height = 22
        Align = alLeft
        Caption = 'Yaz'#305' Durum Tan'#305'm'#305
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editYaziDurumuAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 149
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_POSTA_TUR ORDER BY ID')
  end
end

