inherited EvrakTanimAltBilgiFrame: TEvrakTanimAltBilgiFrame
  Height = 475
  ExplicitHeight = 475
  inherited PanelMain: TPanel
    Height = 425
    inherited GridTanim: TcxGrid
      Width = 160
      Height = 423
      Visible = False
      LookAndFeel.SkinName = ''
      ExplicitWidth = 160
    end
    inherited cxSplitter1: TcxSplitter
      Left = 161
      Height = 423
      Visible = False
      ExplicitLeft = 161
    end
    inherited GridPanel1: TGridPanel
      Left = 169
      Width = 464
      Height = 423
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 130.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 170.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 136.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 170.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = cxDBTextEdit1
          Row = 0
        end
        item
          Column = 2
          Control = Label2
          Row = 0
        end
        item
          Column = 3
          Control = cxDBTextEdit2
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 1
        end
        item
          Column = 1
          Control = cxDBTextEdit3
          Row = 1
        end
        item
          Column = 2
          Control = Label4
          Row = 1
        end
        item
          Column = 3
          Control = cxDBTextEdit4
          Row = 1
        end
        item
          Column = 0
          Control = Label5
          Row = 2
        end
        item
          Column = 1
          Control = cxDBTextEdit5
          Row = 2
        end
        item
          Column = 2
          Control = Label6
          Row = 2
        end
        item
          Column = 3
          Control = cxDBTextEdit6
          Row = 2
        end
        item
          Column = 0
          Control = Label7
          Row = 3
        end
        item
          Column = 1
          Control = cxDBTextEdit7
          Row = 3
        end
        item
          Column = 2
          Control = Label8
          Row = 3
        end
        item
          Column = 3
          Control = cxDBTextEdit8
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
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end>
      ExplicitLeft = 169
      ExplicitWidth = 464
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 124
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Kurum Adres Sat'#305'r 1 :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 4
        ExplicitTop = 4
      end
      object cxDBTextEdit1: TcxDBTextEdit
        AlignWithMargins = True
        Left = 133
        Top = 3
        Align = alClient
        DataBinding.DataField = 'KURUM_ADRES1'
        DataBinding.DataSource = dsEvrak
        StyleHot.BorderColor = clHighlight
        TabOrder = 0
        Width = 164
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 303
        Top = 3
        Width = 130
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Ayr'#305'nt'#305'l'#305' Bilgi / '#304'rtibat 1:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 283
        ExplicitTop = 6
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit2: TcxDBTextEdit
        AlignWithMargins = True
        Left = 439
        Top = 3
        Align = alClient
        DataBinding.DataField = 'AYRINTI_IRTIBAT1'
        DataBinding.DataSource = dsEvrak
        TabOrder = 1
        Width = 164
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 124
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Kurum Adres Sat'#305'r 2 :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 33
        ExplicitTop = 34
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit3: TcxDBTextEdit
        AlignWithMargins = True
        Left = 133
        Top = 31
        Align = alClient
        DataBinding.DataField = 'KURUM_ADRES2'
        DataBinding.DataSource = dsEvrak
        StyleHot.BorderColor = clHighlight
        TabOrder = 2
        Width = 164
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 303
        Top = 31
        Width = 130
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Ayr'#305'nt'#305'l'#305' Bilgi / '#304'rtibat 2:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 283
        ExplicitTop = 6
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit4: TcxDBTextEdit
        AlignWithMargins = True
        Left = 439
        Top = 31
        Align = alClient
        DataBinding.DataField = 'AYRINTI_IRTIBAT2'
        DataBinding.DataSource = dsEvrak
        TabOrder = 3
        Width = 164
      end
      object Label5: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 124
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Telefon :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 33
        ExplicitTop = 34
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit5: TcxDBTextEdit
        AlignWithMargins = True
        Left = 133
        Top = 59
        Align = alClient
        DataBinding.DataField = 'TELEFON'
        DataBinding.DataSource = dsEvrak
        TabOrder = 4
        Width = 164
      end
      object Label6: TLabel
        AlignWithMargins = True
        Left = 303
        Top = 59
        Width = 130
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Faks :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 283
        ExplicitTop = 6
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit6: TcxDBTextEdit
        AlignWithMargins = True
        Left = 439
        Top = 59
        Align = alClient
        DataBinding.DataField = 'FAKS'
        DataBinding.DataSource = dsEvrak
        TabOrder = 5
        Width = 164
      end
      object Label7: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 124
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'E-posta :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 33
        ExplicitTop = 34
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit7: TcxDBTextEdit
        AlignWithMargins = True
        Left = 133
        Top = 87
        Align = alClient
        DataBinding.DataField = 'EPOSTA'
        DataBinding.DataSource = dsEvrak
        TabOrder = 6
        Width = 164
      end
      object Label8: TLabel
        AlignWithMargins = True
        Left = 303
        Top = 87
        Width = 130
        Height = 22
        Align = alClient
        AutoSize = False
        Caption = 'Elektronik A'#287' :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 283
        ExplicitTop = 6
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object cxDBTextEdit8: TcxDBTextEdit
        AlignWithMargins = True
        Left = 439
        Top = 87
        Align = alClient
        DataBinding.DataField = 'ELEKTRONIKAG'
        DataBinding.DataSource = dsEvrak
        TabOrder = 7
        Width = 164
      end
    end
  end
  inherited qryEvrak: TFDQuery
    SQL.Strings = (
      'SELECT * FROM EVRAK_TANIMLAR')
  end
end

