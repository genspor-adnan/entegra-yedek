inherited EvrakTanimDosyaTasnifPlanGrupFrame: TEvrakTanimDosyaTasnifPlanGrupFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 430
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Width = 40
        end
        object ViewTanimTASNIF_GRUP: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'TASNIF_GRUP'
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      ExplicitLeft = 250
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 130.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 260.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = editPlanKodu
          Row = 0
        end>
      ExplicitLeft = 258
      ExplicitTop = 0
      ExplicitWidth = 376
      ExplicitHeight = 430
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 115
        Height = 22
        Align = alLeft
        Caption = 'Tasnif Grubu Tan'#305'm'#305' :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editPlanKodu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 133
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'TASNIF_GRUP'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        ExplicitLeft = 199
        ExplicitHeight = 21
        Width = 198
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_DOSYATASNIF_PLAN_GRUP')
  end
end

