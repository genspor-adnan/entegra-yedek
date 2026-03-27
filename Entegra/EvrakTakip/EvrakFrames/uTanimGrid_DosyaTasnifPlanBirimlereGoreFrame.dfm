inherited EvrakTanimDosyaTasnifPlanBirimlererGoreFrame: TEvrakTanimDosyaTasnifPlanBirimlererGoreFrame
  inherited PanelMain: TPanel
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
      ExplicitLeft = 258
      ExplicitTop = 0
      ExplicitWidth = 376
      ExplicitHeight = 430
    end
  end
  inherited qryEvrak: TFDQuery
    SQL.Strings = (
      'SELECT * FROM EVRAK_DOSYATASNIF_PLAN_GRUP')
  end
end

