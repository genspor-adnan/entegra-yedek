inherited EvrakTanimEvrakBirimiFrame: TEvrakTanimEvrakBirimiFrame
  Width = 807
  ExplicitWidth = 807
  inherited PanelTop: TPanel
    Width = 801
    ExplicitWidth = 801
  end
  inherited PanelMain: TPanel
    Width = 801
    ExplicitWidth = 801
    inherited GridTanim: TcxGrid
      Width = 382
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 382
      ExplicitHeight = 430
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        OptionsView.HeaderAutoHeight = True
        object ViewTanimID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimBIRIM_KODU: TcxGridDBColumn
          Caption = 'Birim Kodu'
          DataBinding.FieldName = 'BIRIM_KODU'
          HeaderAlignmentHorz = taCenter
          Width = 98
        end
        object ViewTanimIDARE_KURUM_KODU: TcxGridDBColumn
          Caption = #304'dare Kurum Kodu'
          DataBinding.FieldName = 'IDARE_KURUM_KODU'
          HeaderAlignmentHorz = taCenter
          Width = 113
        end
        object ViewTanimBIRIM_ADI: TcxGridDBColumn
          Caption = 'Birim Ad'#305
          DataBinding.FieldName = 'BIRIM_ADI'
          HeaderAlignmentHorz = taCenter
          Width = 147
        end
        object ViewTanimKISA_ADI: TcxGridDBColumn
          Caption = 'K'#305'sa Ad'#305
          DataBinding.FieldName = 'KISA_ADI'
          HeaderAlignmentHorz = taCenter
          Width = 66
        end
        object ViewTanimGENEL_EVRAK_BIRIMI: TcxGridDBColumn
          Caption = 'Genel Evrak m'#305
          DataBinding.FieldName = 'GENEL_EVRAK_BIRIMI'
          Width = 98
        end
        object ViewTanimGELEN_EVRAK_ILK_KAYDEDEDN: TcxGridDBColumn
          DataBinding.FieldName = 'GELEN_EVRAK_ILK_KAYDEDEDN'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimKULLANIM_DURUMU: TcxGridDBColumn
          DataBinding.FieldName = 'KULLANIM_DURUMU'
          Visible = False
        end
        object ViewTanimEPOSTA: TcxGridDBColumn
          DataBinding.FieldName = 'EPOSTA'
          Visible = False
          Width = 150
        end
        object ViewTanimSADECE_KISIYE_HAVALE: TcxGridDBColumn
          DataBinding.FieldName = 'SADECE_KISIYE_HAVALE'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimDETAY_DAGITIM: TcxGridDBColumn
          DataBinding.FieldName = 'DETAY_DAGITIM'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimDAGITIM_BIRIM_KODU: TcxGridDBColumn
          DataBinding.FieldName = 'DAGITIM_BIRIM_KODU'
          Visible = False
          VisibleForCustomization = False
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Left = 382
      ExplicitLeft = 382
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      Left = 390
      Width = 411
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 160.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 300.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = editBirimKodu
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 1
        end
        item
          Column = 1
          Control = editIdareKurumKodu
          Row = 1
        end
        item
          Column = 0
          Control = Label4
          Row = 2
        end
        item
          Column = 1
          Control = editBirimAdi
          Row = 2
        end
        item
          Column = 0
          Control = Label5
          Row = 3
        end
        item
          Column = 1
          Control = editKisaAdi
          Row = 3
        end
        item
          Column = 0
          Control = Label6
          Row = 4
        end
        item
          Column = 1
          Control = editComboGenelEvrakBirimi
          Row = 4
        end
        item
          Column = 0
          Control = Label7
          Row = 5
        end
        item
          Column = 1
          Control = lookupGelenEvrakIlkKayit
          Row = 5
        end
        item
          Column = 0
          Control = Label8
          Row = 6
        end
        item
          Column = 1
          Control = editComboKullanimDurumu
          Row = 6
        end
        item
          Column = 0
          Control = Label9
          Row = 7
        end
        item
          Column = 1
          Control = editEPosta
          Row = 7
        end
        item
          Column = 0
          Control = Label10
          Row = 8
        end
        item
          Column = 1
          Control = editComboDetayDagitim
          Row = 8
        end
        item
          Column = 0
          Control = Label11
          Row = 9
        end
        item
          Column = 1
          Control = editDaigitmBirimKodu
          Row = 9
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
      ExplicitLeft = 390
      ExplicitTop = 0
      ExplicitWidth = 411
      ExplicitHeight = 430
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 59
        Height = 22
        Align = alLeft
        Caption = 'Birim Kodu'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editBirimKodu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 163
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'BIRIM_KODU'
        DataBinding.DataSource = dsEvrak
        TabOrder = 0
        Width = 121
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 31
        Width = 120
        Height = 22
        Align = alLeft
        Caption = #304'dare Kurum Kodu'#9
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editIdareKurumKodu: TcxDBTextEdit
        AlignWithMargins = True
        Left = 163
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'IDARE_KURUM_KODU'
        DataBinding.DataSource = dsEvrak
        TabOrder = 1
        Width = 121
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 59
        Width = 47
        Height = 22
        Align = alLeft
        Caption = 'Birim Ad'#305
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editBirimAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 163
        Top = 59
        Align = alLeft
        DataBinding.DataField = 'BIRIM_ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 2
        Width = 250
      end
      object Label5: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 41
        Height = 22
        Align = alLeft
        Caption = 'K'#305'sa Ad'#305
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editKisaAdi: TcxDBTextEdit
        AlignWithMargins = True
        Left = 163
        Top = 87
        Align = alLeft
        DataBinding.DataField = 'KISA_ADI'
        DataBinding.DataSource = dsEvrak
        TabOrder = 3
        Width = 121
      end
      object Label6: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 115
        Width = 114
        Height = 22
        Align = alLeft
        Caption = 'Genel Evrak Birimi mi'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editComboGenelEvrakBirimi: TcxDBImageComboBox
        AlignWithMargins = True
        Left = 163
        Top = 115
        Align = alLeft
        DataBinding.DataField = 'GENEL_EVRAK_BIRIMI'
        DataBinding.DataSource = dsEvrak
        Properties.Items = <
          item
            Description = 'Evet'
            ImageIndex = 0
            Value = 'E'
          end
          item
            Description = 'Hay'#305'r'
            Value = 'H'
          end>
        TabOrder = 4
        Width = 121
      end
      object Label7: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 143
        Width = 143
        Height = 22
        Align = alLeft
        Caption = 'Gelen Evrak ilk Kay'#305't eden'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupGelenEvrakIlkKayit: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 163
        Top = 143
        Align = alLeft
        DataBinding.DataField = 'GELEN_EVRAK_ILK_KAYDEDEDN'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'FIRMA'
          end>
        Properties.ListSource = dsPersonel
        TabOrder = 5
        Width = 180
      end
      object Label8: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 171
        Width = 91
        Height = 22
        Align = alLeft
        Caption = 'Kullan'#305'm Durumu'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editComboKullanimDurumu: TcxDBImageComboBox
        AlignWithMargins = True
        Left = 163
        Top = 171
        Align = alLeft
        DataBinding.DataField = 'KULLANIM_DURUMU'
        DataBinding.DataSource = dsEvrak
        Properties.Items = <
          item
            Description = 'A'#231#305'k'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kapal'#305
            Value = 0
          end>
        TabOrder = 6
        Width = 180
      end
      object Label9: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 199
        Width = 35
        Height = 22
        Align = alLeft
        Caption = 'EPosta'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editEPosta: TcxDBTextEdit
        AlignWithMargins = True
        Left = 163
        Top = 199
        Align = alLeft
        DataBinding.DataField = 'EPOSTA'
        DataBinding.DataSource = dsEvrak
        TabOrder = 7
        Width = 250
      end
      object Label10: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 227
        Width = 74
        Height = 22
        Align = alLeft
        Caption = 'Detay Da'#287#305't'#305'm'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editComboDetayDagitim: TcxDBImageComboBox
        AlignWithMargins = True
        Left = 163
        Top = 227
        Align = alLeft
        DataBinding.DataField = 'DETAY_DAGITIM'
        DataBinding.DataSource = dsEvrak
        Properties.Items = <
          item
            Description = 'A'#231#305'k'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kapal'#305
            Value = 0
          end>
        TabOrder = 8
        Width = 180
      end
      object Label11: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 255
        Width = 102
        Height = 22
        Align = alLeft
        Caption = 'Da'#287#305't'#305'm Birim Kodu'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editDaigitmBirimKodu: TcxDBButtonEdit
        AlignWithMargins = True
        Left = 163
        Top = 255
        Align = alLeft
        DataBinding.DataField = 'DAGITIM_BIRIM_KODU'
        DataBinding.DataSource = dsEvrak
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        TabOrder = 9
        Width = 180
      end
    end
  end
  inherited ActionListFrame: TActionList
    Left = 304
    Top = 80
  end
  inherited qryEvrak: TFDQuery
    Active = True
    SQL.Strings = (
      'SELECT * FROM EVRAK_BIRIMI')
  end
  object dsPersonel: TDataSource
    DataSet = qryPersonel
    Left = 48
    Top = 328
  end
  object qryPersonel: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT ID,FIRMA FROM REHBER WHERE GRUP=335'
      'Order by FIRMA')
    Left = 96
    Top = 312
  end
end



