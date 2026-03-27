inherited EvrakTanimMetaBilgileriFrame: TEvrakTanimMetaBilgileriFrame
  Width = 645
  ExplicitWidth = 645
  inherited PanelTop: TPanel
    Width = 639
    inherited buttonKaydet: TSpeedButton
      ImageIndex = -1
    end
    inherited buttonListele: TSpeedButton
      ImageIndex = -1
    end
    inherited buttonYeniKayit: TSpeedButton
      ImageIndex = -1
    end
    inherited buttonSil: TSpeedButton
      ImageIndex = -1
    end
    inherited buttonDetay: TSpeedButton
      ImageIndex = -1
    end
    inherited buttonYazdir: TSpeedButton
      ImageIndex = -1
    end
  end
  inherited PanelMain: TPanel
    Width = 639
    inherited GridPanel1: TGridPanel
      Width = 379
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 100.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end>
      object Label1: TLabel
        Left = 22
        Top = 7
        Width = 58
        Height = 15
        Anchors = []
        Caption = 'Label Meta'
        ExplicitLeft = 1
      end
    end
  end
end
