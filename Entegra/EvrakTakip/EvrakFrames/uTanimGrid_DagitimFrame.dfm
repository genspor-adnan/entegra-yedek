inherited EvrakTanimDagitimFrame: TEvrakTanimDagitimFrame
  Width = 918
  ExplicitWidth = 918
  inherited PanelTop: TPanel
    Width = 912
  end
  inherited PanelMain: TPanel
    Width = 912
    inherited GridTanim: TcxGrid
      Width = 185
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
      ExplicitHeight = 430
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimADI: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'ADI'
          Width = 180
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Left = 185
      ExplicitLeft = 250
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      Left = 235
      Top = 40
      Width = 50
      Height = 73
      Align = alNone
      Visible = False
      ExplicitLeft = 235
      ExplicitTop = 40
      ExplicitWidth = 50
      ExplicitHeight = 73
    end
    object PanelRight: TPanel
      Left = 193
      Top = 0
      Width = 719
      Height = 430
      Align = alClient
      TabOrder = 3
      ExplicitLeft = 128
      ExplicitTop = 88
      ExplicitWidth = 185
      ExplicitHeight = 145
      object PanelRightTop: TPanel
        Left = 1
        Top = 1
        Width = 717
        Height = 31
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 439
        object Label1: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 89
          Height = 25
          Align = alLeft
          AutoSize = False
          Caption = 'Da'#287#305't'#305'm Ad'#305' :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 35
        end
        object cxDBTextEdit1: TcxDBTextEdit
          AlignWithMargins = True
          Left = 98
          Top = 3
          Align = alLeft
          DataBinding.DataField = 'ADI'
          DataBinding.DataSource = dsEvrak
          TabOrder = 0
          ExplicitHeight = 27
          Width = 199
        end
      end
      object Panel1: TPanel
        Left = 1
        Top = 32
        Width = 717
        Height = 397
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitTop = 289
        ExplicitWidth = 482
        ExplicitHeight = 246
        object PanelAlanLeft: TPanel
          Left = 0
          Top = 0
          Width = 209
          Height = 397
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitLeft = -2
          ExplicitTop = 3
          object Label2: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 36
            Width = 127
            Height = 18
            Caption = 'Kurum '#304#231'i / Kurum D'#305#351#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
            Layout = tlCenter
          end
          object Label8: TLabel
            Left = 4
            Top = 86
            Width = 116
            Height = 18
            Caption = 'Da'#287#305't'#305'm Evrak Birimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label9: TLabel
            Left = 4
            Top = 136
            Width = 47
            Height = 18
            Caption = 'Alan Ad'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label3: TLabel
            Left = 4
            Top = 186
            Width = 55
            Height = 18
            Caption = 'Arz / Rica'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 209
            Height = 35
            Align = alTop
            BevelEdges = [beBottom]
            TabOrder = 0
            ExplicitWidth = 185
            object SpeedButton1: TSpeedButton
              AlignWithMargins = True
              Left = 122
              Top = 4
              Width = 83
              Height = 27
              Align = alRight
              Caption = 'Ekle'
              ImageIndex = 62
              Images = dmEvrakModule.ImagesEvrak
              OnClick = SpeedButton1Click
              ExplicitLeft = 96
              ExplicitHeight = 25
            end
            object Label4: TLabel
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 101
              Height = 27
              Align = alLeft
              AutoSize = False
              Caption = 'Da'#287#305't'#305'm Ayr'#305'nt'#305'lar'#305' :'
              Layout = tlCenter
              ExplicitHeight = 25
            end
          end
          object editAlanAdi: TcxDBTextEdit
            Left = 4
            Top = 156
            DataBinding.DataField = 'ALAN_ADI'
            DataBinding.DataSource = dsDetay
            TabOrder = 1
            Width = 200
          end
          object comboArzRica: TcxDBImageComboBox
            Left = 4
            Top = 206
            DataBinding.DataField = 'ARZ_RICA'
            DataBinding.DataSource = dsDetay
            Properties.Items = <
              item
                Description = 'Arz'
                ImageIndex = 0
                Value = 'A'
              end
              item
                Description = 'Rica'
                Value = 'R'
              end>
            TabOrder = 2
            Width = 121
          end
          object comboEvrakBirimi: TcxDBLookupComboBox
            Left = 4
            Top = 106
            DataBinding.DataField = 'EVRAK_BIRIM_REF'
            DataBinding.DataSource = dsDetay
            Properties.DropDownWidth = 250
            Properties.KeyFieldNames = 'ID'
            Properties.ListColumns = <
              item
                FieldName = 'DAGITIM_BIRIM_KODU'
              end
              item
                FieldName = 'BIRIM_ADI'
              end>
            Properties.ListSource = dsLookupBirim
            TabOrder = 3
            Width = 200
          end
          object comboKurumIcDis: TcxDBImageComboBox
            Left = 4
            Top = 56
            DataBinding.DataField = 'KURUM_ICI_DISI'
            DataBinding.DataSource = dsDetay
            Properties.Items = <
              item
                Description = 'Kurum '#304#231'i'
                ImageIndex = 0
                Value = 'I'
              end
              item
                Description = 'Kurum D'#305#351#305
                Value = 'D'
              end>
            TabOrder = 4
            Width = 121
          end
        end
        object PanelAlanRgiht: TPanel
          Left = 209
          Top = 0
          Width = 508
          Height = 397
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = 185
          ExplicitWidth = 254
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 508
            Height = 35
            Align = alTop
            BevelEdges = [beBottom]
            TabOrder = 0
            ExplicitWidth = 532
            object SpeedButton2: TSpeedButton
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 85
              Height = 27
              Align = alLeft
              Caption = #199#305'kart'
              ImageIndex = 63
              Images = dmEvrakModule.ImagesEvrak
              OnClick = SpeedButton2Click
              ExplicitHeight = 25
            end
          end
          object GridDagitim: TcxGrid
            AlignWithMargins = True
            Left = 3
            Top = 38
            Width = 502
            Height = 356
            Align = alClient
            TabOrder = 1
            ExplicitTop = 36
            ExplicitWidth = 248
            ExplicitHeight = 358
            object ViewDagitim: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dsDetay
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              object ViewDagitimID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Visible = False
                VisibleForCustomization = False
                Width = 80
              end
              object ViewDagitimKURUM_ICI_DISI: TcxGridDBColumn
                Caption = 'Kurum '#304#231'/D'#305#351
                DataBinding.FieldName = 'KURUM_ICI_DISI'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Kurum '#304#231'i'
                    ImageIndex = 0
                    Value = 'I'
                  end
                  item
                    Description = 'Kurum D'#305#351#305
                    Value = 'D'
                  end>
                Width = 85
              end
              object ViewDagitimDAGITIM_REF: TcxGridDBColumn
                DataBinding.FieldName = 'DAGITIM_REF'
                Visible = False
                VisibleForCustomization = False
                Width = 80
              end
              object ViewDagitimALAN_ADI: TcxGridDBColumn
                Caption = 'Alan Ad'#305
                DataBinding.FieldName = 'ALAN_ADI'
                Width = 108
              end
              object ViewDagitimARZ_RICA: TcxGridDBColumn
                Caption = 'Arz/Rica'
                DataBinding.FieldName = 'ARZ_RICA'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Arz'
                    ImageIndex = 0
                    Value = 'A'
                  end
                  item
                    Description = 'Rica'
                    Value = 'R'
                  end>
                Width = 80
              end
              object ViewDagitimEVRAK_BIRIM_REF: TcxGridDBColumn
                Caption = 'Da'#287#305't'#305'm Evrak Birimi'
                DataBinding.FieldName = 'EVRAK_BIRIM_REF'
                PropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.KeyFieldNames = 'ID'
                Properties.ListColumns = <
                  item
                    FieldName = 'DAGITIM_BIRIM_KODU'
                  end
                  item
                    FieldName = 'BIRIM_ADI'
                  end>
                Properties.ListOptions.ShowHeader = False
                Properties.ListSource = dsLookupBirim
                Width = 125
              end
            end
            object LevelD1: TcxGridLevel
              GridView = ViewDagitim
            end
          end
        end
      end
    end
  end
  inherited ActionListFrame: TActionList
    Left = 536
    Top = 48
  end
  inherited qryEvrak: TFDQuery
    Active = True
    AfterScroll = qryEvrakAfterScroll
    SQL.Strings = (
      'SELECT * FROM EVRAK_DAGITIM')
    Left = 83
    Top = 119
  end
  inherited dsEvrak: TDataSource
    Left = 75
  end
  object qryDetay: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryDetayBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_DAGITIM_DETAY WHERE DAGITIM_REF=:ref')
    Left = 237
    Top = 327
  end
  object dsDetay: TDataSource
    DataSet = qryDetay
    Left = 235
    Top = 367
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
