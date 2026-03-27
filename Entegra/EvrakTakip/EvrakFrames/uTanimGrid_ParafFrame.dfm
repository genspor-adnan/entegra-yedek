inherited EvrakTanimParafFrame: TEvrakTanimParafFrame
  Width = 725
  ExplicitWidth = 725
  inherited PanelTop: TPanel
    Width = 719
    ExplicitWidth = 719
  end
  inherited PanelMain: TPanel
    Width = 719
    ExplicitWidth = 719
    inherited GridTanim: TcxGrid
      Width = 216
      BevelOuter = bvNone
      LookAndFeel.SkinName = ''
      ExplicitWidth = 216
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.ColumnAutoWidth = True
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kod ID'
          DataBinding.FieldName = 'ID'
          Width = 34
        end
        object ViewTanimADI: TcxGridDBColumn
          Caption = 'Paraf Ad'#305
          DataBinding.FieldName = 'ADI'
          Width = 180
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Left = 216
      ExplicitLeft = 216
    end
    inherited GridPanel1: TGridPanel
      Left = 224
      Width = 495
      ControlCollection = <
        item
          Column = 0
          Control = editVeklaetVeren
          Row = 0
        end
        item
          Column = 1
          Control = editParafAdi
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 1
        end
        item
          Column = 1
          Control = PanelPersonel
          Row = 1
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 280.000000000000000000
        end>
      ExplicitLeft = 224
      ExplicitTop = 0
      ExplicitWidth = 495
      object editVeklaetVeren: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 57
        Height = 22
        Align = alLeft
        Caption = 'Paraf Ad'#305': '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editParafAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alClient
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        Width = 294
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 60
        Width = 93
        Height = 245
        Margins.Top = 32
        Align = alLeft
        Caption = 'Personel Se'#231'imi:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitHeight = 18
      end
      object PanelPersonel: TPanel
        Left = 120
        Top = 28
        Width = 300
        Height = 280
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Panelbutton: TPanel
          Left = 0
          Top = 0
          Width = 300
          Height = 29
          Align = alTop
          BevelEdges = [beBottom]
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 0
          object buttonPersonelEkle: TSpeedButton
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 110
            Height = 21
            Action = actPersonelEkle
            Align = alLeft
            Flat = True
            ExplicitLeft = 139
            ExplicitTop = 2
            ExplicitHeight = 23
          end
        end
        object GridPers: TcxGrid
          AlignWithMargins = True
          Left = 3
          Top = 32
          Width = 294
          Height = 245
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = cxcbsNone
          TabOrder = 1
          object ViewPers: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dsPersonelList
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            object ViewPersPARAF_ID: TcxGridDBColumn
              DataBinding.FieldName = 'PARAF_ID'
              Visible = False
              VisibleForCustomization = False
            end
            object ViewPersPERSONEL_ID: TcxGridDBColumn
              Caption = 'Personel'
              DataBinding.FieldName = 'PERSONEL_ID'
              PropertiesClassName = 'TcxLookupComboBoxProperties'
              Properties.KeyFieldNames = 'ID'
              Properties.ListColumns = <
                item
                  FieldName = 'FIRMA'
                end>
              Properties.ListSource = dsLookupVekalet
              Width = 157
            end
            object ViewPersColumnKaldir: TcxGridDBColumn
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  ImageIndex = 119
                  Glyph.SourceDPI = 96
                  Glyph.Data = {
                    89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
                    61000002AF49444154785EA5925B48545B1CC6879A3D7BF6DE7343CC4B264297
                    635A074D6D26B538A6354E6299E6A5330E39929A8E664A8E3992860347B31823
                    A51B68133DC8143D08611A9AE23D1CCC1B5ED2D0A2A85E7B08B3D4AFB53B5B1F
                    82ECA105BF87FDC1FFF7B1F67F8900FC11AB6723414260042821A3094A822BC1
                    85C0F2F9CF022A2AA5C014AD3FDFA535142F44269DEBDD17633493DC3DE490DE
                    127634D3792021EF8B4697FE6277F831AB205B9388A292F3732FDF68FCD6D13B
                    8477EF3FA2BDDB898A1AFB92FA485A4BF9D5FAA527ED7D7835F71A8F9F76A3E4
                    BF9BCB3B35BA2A2250AC09B4A4B9A36F08D63A07F48536249FAD46A2A912C733
                    2B109B5E06DD290B0EFD5B841C8B0D4D2D9D0838983241045E6B82C37AF302DF
                    9C9C5F8D86FB0EC46759C19F89E9190C8F8E419B6A46B5AD0EA147B330393D8B
                    105DDA57220822287F08FE3991D7DFD63588D22B76A1B10487496344623E4263
                    4F43EFAFC6191F5F9CCC34A3F1513376046BE74D2C3B90C6320DB3419C48A48E
                    36145FB2DD5D6AEDECC7DC9BB7686EEF4169D5EDE55DE171034591BA9567812E
                    B06F51A13C588D2463EE8A51E5F2E18E9B1CAD5B395859AE90DF82223022F1A2
                    26C638141697BD18AC358CF869622A49BED7B4C963FE9EB70A53FB55A8F754A0
                    58265FE487270264B8E5CAA18C61EDBC60038115D6E3457027C885ECEF5C4EE6
                    6C20C3536A051EF8C83119F8FFB091960ECFF84945BF7B651C21D2C2C93E3D24
                    C3B3413238367328A099CF248F9FF98BFEB540788DBE390C3B78C74D419A3938
                    BC388CFB33A8554A914A49465F6E93AC2B70CD63B91EFECE93C29D0BA4CCE7EB
                    4A06E3DB695C93D328A224F67505D92CDBD6B2955BBDF308C91252296AAC860C
                    37B951B820A16AD71348087E198CB42383963E2741004141D863108B9D7A31D5
                    3DED2DFEED4F94085BF120D04246133C79F8EFEF6BABDB90CF7763F500000000
                    49454E44AE426082}
                  Hint = 'Personel '#304'li'#351'kisini Siler'
                  Kind = bkGlyph
                end>
              Properties.ClickKey = 0
              Properties.ViewStyle = vsButtonsOnly
              Properties.OnButtonClick = ViewPersColumnKaldirPropertiesButtonClick
              Options.Filtering = False
              Options.FilteringAddValueItems = False
              Options.ShowEditButtons = isebAlways
              Options.ExpressionEditing = False
              Options.Grouping = False
              Options.Sorting = False
              Width = 52
              IsCaptionAssigned = True
            end
          end
          object LevelPers: TcxGridLevel
            GridView = ViewPers
          end
        end
      end
    end
  end
  inherited ActionListFrame: TActionList
    object actPersonelEkle: TAction
      Tag = 1000
      Caption = 'Personel Ekle'
      ImageIndex = 64
      OnExecute = actPersonelEkleExecute
      OnUpdate = actPersonelEkleUpdate
    end
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_PARAF')
  end
  object qryPersonelList: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    BeforePost = qryPersonelListBeforePost
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_PARAF_PERSONEL '
      'WHERE PARAF_ID=:parafID')
    Left = 304
    Top = 204
  end
  object dsPersonelList: TDataSource
    DataSet = qryPersonelList
    Left = 304
    Top = 260
  end
  object qryLookupVekalet: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT ID,FIRMA FROM REHBER WHERE GRUP=335'
      'Order by FIRMA')
    Left = 128
    Top = 240
  end
  object dsLookupVekalet: TDataSource
    AutoEdit = False
    DataSet = qryLookupVekalet
    Left = 136
    Top = 296
  end
end
