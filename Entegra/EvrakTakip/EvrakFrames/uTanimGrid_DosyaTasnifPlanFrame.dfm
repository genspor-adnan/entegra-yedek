inherited EvrakTanimDosyaTasnifPlanFrame: TEvrakTanimDosyaTasnifPlanFrame
  Width = 736
  ExplicitWidth = 736
  inherited PanelTop: TPanel
    Width = 730
  end
  inherited PanelMain: TPanel
    Width = 730
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited cxSplitter1: TcxSplitter
      ExplicitLeft = 250
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      Width = 472
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
        end
        item
          Column = 0
          Control = Label2
          Row = 1
        end
        item
          Column = 1
          Control = editPlanAdi
          Row = 1
        end
        item
          Column = 0
          Control = Label3
          Row = 2
        end
        item
          Column = 1
          Control = comboKullanimDurumu
          Row = 2
        end
        item
          Column = 0
          Control = Label4
          Row = 3
        end
        item
          Column = 1
          Control = GridPanel2
          Row = 3
        end
        item
          Column = 0
          Control = Label8
          Row = 4
        end
        item
          Column = 1
          Control = lookupTasnifGrup
          Row = 4
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
          Value = 56.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end>
      ExplicitLeft = 258
      ExplicitTop = 0
      ExplicitWidth = 376
      ExplicitHeight = 430
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 63
        Height = 22
        Align = alLeft
        Caption = 'Plan Kodu :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editPlanKodu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'PLAN_KODU'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        Width = 198
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 51
        Height = 22
        Align = alLeft
        Caption = 'Plan Ad'#305' :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editPlanAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'PLAN_ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 1
        ExplicitLeft = 209
        ExplicitHeight = 21
        Width = 198
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 99
        Height = 22
        Align = alLeft
        Caption = 'Kullan'#305'm Durumu :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object comboKullanimDurumu: TcxDBImageComboBox
        AlignWithMargins = True
        Left = 123
        Top = 59
        Align = alLeft
        DataBinding.DataField = 'KULLANIM_DURUMU'
        DataBinding.DataSource = dsEvrak
        Properties.Items = <
          item
            Description = 'Kullan'#305'labilir'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kullan'#305'lamaz'
            Value = 0
          end>
        TabOrder = 2
        ExplicitLeft = 209
        ExplicitHeight = 26
        Width = 121
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 80
        Height = 50
        Align = alLeft
        Caption = 'Saklama Plan'#305' :'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object GridPanel2: TGridPanel
        Left = 120
        Top = 84
        Width = 300
        Height = 56
        Align = alClient
        ColumnCollection = <
          item
            SizeStyle = ssAbsolute
            Value = 90.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 90.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 120.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 1
            Control = cxDBImageComboBox1
            Row = 0
          end
          item
            Column = 2
            Control = cxDBImageComboBox2
            Row = 0
          end
          item
            Column = 0
            Control = Label5
            Row = 1
          end
          item
            Column = 1
            Control = Label6
            Row = 1
          end
          item
            Column = 2
            Control = Label7
            Row = 1
          end
          item
            Column = 0
            Control = cxDBTextEdit1
            Row = 0
          end>
        RowCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        TabOrder = 3
        ExplicitWidth = 337
        object cxDBImageComboBox1: TcxDBImageComboBox
          Left = 91
          Top = 1
          Align = alClient
          DataBinding.DataField = 'SAKLAMA_KRITER'
          DataBinding.DataSource = dsEvrak
          Properties.Items = <>
          TabOrder = 0
          ExplicitLeft = 85
          ExplicitTop = 3
          Width = 90
        end
        object cxDBImageComboBox2: TcxDBImageComboBox
          Left = 181
          Top = 1
          Align = alClient
          DataBinding.DataField = 'SAKLAMA_SURE_BASLANGIC'
          DataBinding.DataSource = dsEvrak
          Properties.Items = <>
          TabOrder = 1
          ExplicitLeft = 187
          ExplicitTop = -5
          Width = 120
        end
        object Label5: TLabel
          Left = 1
          Top = 28
          Width = 58
          Height = 27
          Align = alLeft
          Caption = 'S'#252'resi (Y'#305'l)'
          Layout = tlCenter
          ExplicitHeight = 18
        end
        object Label6: TLabel
          Left = 91
          Top = 28
          Width = 35
          Height = 27
          Align = alLeft
          Caption = 'Kriteri'
          Layout = tlCenter
          ExplicitHeight = 18
        end
        object Label7: TLabel
          Left = 181
          Top = 28
          Width = 82
          Height = 27
          Align = alLeft
          Caption = 'S'#252're Ba'#351'lang'#305'c'#305
          Layout = tlCenter
          ExplicitHeight = 18
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 1
          Top = 1
          Align = alClient
          DataBinding.DataField = 'SAKLAMA_SURESI'
          DataBinding.DataSource = dsEvrak
          TabOrder = 2
          ExplicitTop = 4
          ExplicitWidth = 121
          ExplicitHeight = 26
          Width = 90
        end
      end
      object Label8: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 143
        Width = 67
        Height = 22
        Align = alLeft
        Caption = 'Tasfiye Plan'#305
        ExplicitHeight = 18
      end
      object lookupTasnifGrup: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 143
        Align = alLeft
        DataBinding.DataField = 'TASFIYE_PLAN_GRUP'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'TASNIF_GRUP'
          end>
        Properties.ListSource = dsLookupTasnifGrup
        TabOrder = 4
        ExplicitLeft = 197
        ExplicitHeight = 26
        Width = 145
      end
    end
  end
  inherited ActionListFrame: TActionList
    Left = 504
    Top = 296
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_DOSYATASNIF_PLANI')
  end
  object dsLookupTasnifGrup: TDataSource
    DataSet = qryLookupTasnifGrup
    Left = 315
    Top = 351
  end
  object qryLookupTasnifGrup: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_DOSYATASNIF_PLAN_GRUP')
    Left = 315
    Top = 279
  end
end



