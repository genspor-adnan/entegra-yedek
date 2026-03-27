inherited EvrakTanimGridFrame: TEvrakTanimGridFrame
  inherited PanelTop: TPanel
    inherited buttonKaydet: TSpeedButton
      Images = dmEvrakModule.ImagesEvrak
    end
    inherited buttonListele: TSpeedButton
      Images = dmEvrakModule.ImagesEvrak
    end
    inherited buttonYeniKayit: TSpeedButton
      Images = dmEvrakModule.ImagesEvrak
    end
    inherited buttonSil: TSpeedButton
      Width = 51
      Images = dmEvrakModule.ImagesEvrak
      ExplicitLeft = 236
      ExplicitWidth = 51
    end
    inherited buttonDetay: TSpeedButton
      Left = 292
      Images = dmEvrakModule.ImagesEvrak
      ExplicitLeft = 293
    end
    inherited buttonYazdir: TSpeedButton
      Left = 400
      Images = dmEvrakModule.ImagesEvrak
      ExplicitLeft = 401
    end
    inherited buttonReset: TSpeedButton
      Left = 468
      ExplicitLeft = 468
    end
  end
  object PanelMain: TPanel [1]
    AlignWithMargins = True
    Left = 3
    Top = 47
    Width = 634
    Height = 430
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object GridTanim: TcxGrid
      Left = 0
      Top = 0
      Width = 250
      Height = 430
      Align = alLeft
      TabOrder = 0
      LookAndFeel.Kind = lfUltraFlat
      LookAndFeel.NativeStyle = False
      LookAndFeel.SkinName = ''
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 428
      object ViewTanim: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.ImmediateEditor = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
      end
      object Level1: TcxGridLevel
        GridView = ViewTanim
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 250
      Top = 0
      Width = 8
      Height = 430
      HotZoneClassName = 'TcxSimpleStyle'
      HotZone.SizePercent = 10
      Control = GridPanel1
      ExplicitLeft = 251
      ExplicitTop = 1
      ExplicitHeight = 428
    end
    object GridPanel1: TGridPanel
      Left = 258
      Top = 0
      Width = 376
      Height = 430
      Align = alClient
      BevelOuter = bvNone
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 120.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 300.000000000000000000
        end>
      ControlCollection = <>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end>
      TabOrder = 2
      ExplicitLeft = 259
      ExplicitTop = 1
      ExplicitWidth = 374
      ExplicitHeight = 428
    end
  end
  inherited ActionListFrame: TActionList
    inherited actKaydet: TAction
      OnExecute = actKaydetExecute
      OnUpdate = actKaydetUpdate
    end
    inherited actYeniKayit: TAction
      OnExecute = actYeniKayitExecute
      OnUpdate = actYeniKayitUpdate
    end
    inherited actSil: TAction
      OnExecute = actSilExecute
      OnUpdate = actSilUpdate
    end
    inherited actYazdir: TAction
      OnExecute = actYazdirExecute
    end
  end
  object qryEvrak: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 187
    Top = 127
  end
  object dsEvrak: TDataSource
    DataSet = qryEvrak
    Left = 171
    Top = 191
  end
end
