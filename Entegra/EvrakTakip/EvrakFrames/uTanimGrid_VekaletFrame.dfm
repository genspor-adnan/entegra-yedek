inherited EvrakTanimVekaletFrame: TEvrakTanimVekaletFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimVEKALET_VEREN_ID: TcxGridDBColumn
          Caption = 'Vekalet Veren'
          DataBinding.FieldName = 'VEKALET_VEREN_ID'
          PropertiesClassName = 'TcxLookupComboBoxProperties'
          Properties.KeyFieldNames = 'ID'
          Properties.ListColumns = <
            item
              FieldName = 'FIRMA'
            end>
          Properties.ListSource = dsLookupVekalet
        end
        object ViewTanimVEKALET_ALAN_ID: TcxGridDBColumn
          Caption = 'Vekalet Alan'
          DataBinding.FieldName = 'VEKALET_ALAN_ID'
          PropertiesClassName = 'TcxLookupComboBoxProperties'
          Properties.KeyFieldNames = 'ID'
          Properties.ListColumns = <
            item
              FieldName = 'FIRMA'
            end>
          Properties.ListSource = dsLookupVekalet
        end
        object ViewTanimBASLANGIC_TARIHI: TcxGridDBColumn
          Caption = 'Ba'#351'lang'#305#231
          DataBinding.FieldName = 'BASLANGIC_TARIHI'
        end
        object ViewTanimBITIS_TARIHI: TcxGridDBColumn
          Caption = 'Biti'#351
          DataBinding.FieldName = 'BITIS_TARIHI'
        end
      end
    end
    inherited GridPanel1: TGridPanel
      ControlCollection = <
        item
          Column = 0
          Control = editVeklaetVeren
          Row = 0
        end
        item
          Column = 1
          Control = lookupVekaletVeren
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 1
        end
        item
          Column = 1
          Control = lookupVekaletAlan
          Row = 1
        end
        item
          Column = 0
          Control = Label4
          Row = 2
        end
        item
          Column = 1
          Control = editBaslangicTarihi
          Row = 2
        end
        item
          Column = 0
          Control = Label5
          Row = 3
        end
        item
          Column = 1
          Control = editBitisTarihi
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
        end>
      ExplicitLeft = 257
      ExplicitTop = 0
      object editVeklaetVeren: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 80
        Height = 22
        Align = alLeft
        Caption = 'Vekalet Veren'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupVekaletVeren: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'VEKALET_VEREN_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'FIRMA'
          end>
        Properties.ListSource = dsLookupVekalet
        TabOrder = 0
        ExplicitLeft = 197
        ExplicitHeight = 21
        Width = 189
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 71
        Height = 22
        Align = alLeft
        Caption = 'Vekalet Alan'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupVekaletAlan: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'VEKALET_ALAN_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'FIRMA'
          end>
        Properties.ListSource = dsLookupVekalet
        TabOrder = 1
        ExplicitLeft = 197
        ExplicitHeight = 21
        Width = 189
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 87
        Height = 22
        Align = alLeft
        Caption = 'Ba'#351'lang'#305#231' Tarihi'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editBaslangicTarihi: TcxDBDateEdit
        AlignWithMargins = True
        Left = 123
        Top = 59
        Align = alLeft
        DataBinding.DataField = 'BASLANGIC_TARIHI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 2
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 121
      end
      object Label5: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 61
        Height = 22
        Align = alLeft
        Caption = 'Biti'#351' Tarihi'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editBitisTarihi: TcxDBDateEdit
        AlignWithMargins = True
        Left = 123
        Top = 87
        Align = alLeft
        DataBinding.DataField = 'BITIS_TARIHI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 3
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 121
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'select * from EVRAK_VEKALET')
  end
  object qryLookupVekalet: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM REHBER where GRUP = 335 AND DURUM=1 ORDER BY FIRMA')
    Left = 302
    Top = 168
  end
  object dsLookupVekalet: TDataSource
    DataSet = qryLookupVekalet
    Left = 299
    Top = 239
  end
end


