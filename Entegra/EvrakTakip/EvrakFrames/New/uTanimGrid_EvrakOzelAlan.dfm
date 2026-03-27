inherited EvrakTanimGridFrame1: TEvrakTanimGridFrame1
  inherited PanelMain: TPanel
    ExplicitLeft = 27
    ExplicitTop = 231
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 430
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.Header = False
        object ViewTanimID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimEVRAK_BIRIM_REF: TcxGridDBColumn
          DataBinding.FieldName = 'EVRAK_BIRIM_REF'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimDOSYA_NO: TcxGridDBColumn
          DataBinding.FieldName = 'DOSYA_NO'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimGOSTERME_SIRASI: TcxGridDBColumn
          DataBinding.FieldName = 'GOSTERME_SIRASI'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimADI: TcxGridDBColumn
          DataBinding.FieldName = 'ADI'
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      ExplicitLeft = 250
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      BevelEdges = []
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = comboEvrakBirim
          Row = 0
        end
        item
          Column = 0
          Control = Label2
          Row = 1
        end
        item
          Column = 1
          Control = cxDBLookupComboBox2
          Row = 1
        end
        item
          Column = 0
          Control = Label3
          Row = 2
        end
        item
          Column = 1
          Control = editGostermeSirasi
          Row = 2
        end
        item
          Column = 0
          Control = Label4
          Row = 3
        end
        item
          Column = 1
          Control = editAdi
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
      ExplicitLeft = 378
      ExplicitTop = 152
      ExplicitWidth = 376
      ExplicitHeight = 430
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 114
        Height = 22
        Align = alClient
        Caption = 'Evrak Birimi :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 77
        ExplicitHeight = 18
      end
      object comboEvrakBirim: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'EVRAK_BIRIM_REF'
        DataBinding.DataSource = dsEvrak
        Properties.DropDownWidth = 300
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'BIRIM_KODU'
          end
          item
            FieldName = 'BIRIM_ADI'
          end>
        Properties.ListSource = dsLookupBirim
        TabOrder = 0
        Width = 200
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 114
        Height = 22
        Align = alClient
        Caption = 'Dosya Kodu :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 73
        ExplicitHeight = 18
      end
      object cxDBLookupComboBox2: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'DOSYA_NO'
        DataBinding.DataSource = dsEvrak
        Properties.ListColumns = <>
        TabOrder = 1
        Width = 200
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 114
        Height = 22
        Align = alClient
        Caption = 'G'#246'sterme S'#305'ras'#305' :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 96
        ExplicitHeight = 18
      end
      object editGostermeSirasi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 59
        Align = alLeft
        DataBinding.DataField = 'GOSTERME_SIRASI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 2
        ExplicitLeft = 209
        ExplicitHeight = 26
        Width = 121
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 114
        Height = 22
        Align = alClient
        Caption = 'Ad'#305' :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 27
        ExplicitHeight = 18
      end
      object editAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 87
        Align = alLeft
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 3
        Width = 200
      end
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_OZEL_ALAN')
  end
  object qryLookupBirim: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_BIRIMI ORDER BY BIRIM_ADI')
    Left = 349
    Top = 327
  end
  object dsLookupBirim: TDataSource
    DataSet = qryLookupBirim
    Left = 357
    Top = 375
  end
end



