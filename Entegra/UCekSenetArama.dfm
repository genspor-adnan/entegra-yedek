object CekSenetAramaDlg: TCekSenetAramaDlg
  Left = 266
  Top = 260
  Caption = #199'ek Senet Arama Ekran'#305
  ClientHeight = 438
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 820
    Height = 438
    ActivePage = shtCek
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 816
    ExplicitHeight = 437
    object shtCek: TTabSheet
      Caption = #199'ek Arama'
      object Panel2: TPanel
        Left = 0
        Top = 89
        Width = 812
        Height = 321
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 0
        ExplicitWidth = 808
        ExplicitHeight = 320
        object cxGrid1: TcxGrid
          Left = 1
          Top = 1
          Width = 810
          Height = 319
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          ExplicitWidth = 806
          ExplicitHeight = 318
          object cxgrdceksenetarama: TcxGridDBTableView
            OnDblClick = cxgrdceksenetaramaDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dsCekSenet
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            object cxgrdceksenetaramaSIRANO: TcxGridDBColumn
              DataBinding.FieldName = 'SIRANO'
              Visible = False
            end
            object cxgrdceksenetaramaTARIH: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Width = 109
            end
            object cxgrdceksenetaramaCARIKOD: TcxGridDBColumn
              Caption = 'Cari Kod'
              DataBinding.FieldName = 'CARIKOD'
              Width = 70
            end
            object cxgrdceksenetaramaCARIAD: TcxGridDBColumn
              Caption = 'Cari Ad'#305
              DataBinding.FieldName = 'CARIAD'
              Width = 62
            end
            object cxgrdceksenetaramaACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
            end
            object cxgrdceksenetaramaHESAPKODU: TcxGridDBColumn
              Caption = 'Hesap Kodu'
              DataBinding.FieldName = 'HESAPKODU'
            end
            object cxgrdceksenetaramaHESAPADI: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              Width = 165
            end
            object cxgrdceksenetaramaSERINO: TcxGridDBColumn
              Caption = 'Seri No'
              DataBinding.FieldName = 'SERINO'
              Width = 68
            end
            object cxgrdceksenetaramaDURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              Width = 43
            end
            object cxgrdceksenetaramaSEC: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.FieldName = 'SEC'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.DisplayChecked = '1'
              Properties.DisplayUnchecked = '0'
              Properties.DisplayGrayed = '0'
              Properties.NullStyle = nssUnchecked
              Properties.ValueChecked = '1'
              Properties.ValueUnchecked = '0'
            end
          end
          object cxGrid1Level1: TcxGridLevel
            GridView = cxgrdceksenetarama
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 812
        Height = 89
        Align = alTop
        TabOrder = 1
        ExplicitWidth = 808
        object Label1: TcxLabel
          Left = 5
          Top = 11
          Caption = 'Cari Kod'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label2: TcxLabel
          Left = 5
          Top = 40
          Caption = 'Cari Ad'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label3: TcxLabel
          Left = 270
          Top = 11
          Caption = 'Hesap Kodu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label4: TcxLabel
          Left = 270
          Top = 40
          Caption = 'Hesap Ad'#305
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object edCarikod: TEdit
          Left = 56
          Top = 11
          Width = 121
          Height = 21
          TabOrder = 0
        end
        object edCariAd: TEdit
          Left = 56
          Top = 40
          Width = 209
          Height = 21
          TabOrder = 1
        end
        object edHesapKodu: TEdit
          Left = 344
          Top = 11
          Width = 161
          Height = 21
          TabOrder = 2
        end
        object edHesapAdi: TEdit
          Left = 344
          Top = 40
          Width = 201
          Height = 21
          TabOrder = 3
        end
        object BitBtn1: TBitBtn
          Left = 555
          Top = 37
          Width = 75
          Height = 25
          Caption = 'Arama'
          Glyph.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            08000000000000010000320B0000320B000000010000000100005A6B7300AD7B
            73004A637B00EFBD8400B58C8C00A5948C00C6948C00B59C8C00BD9C8C00F7BD
            8C00BD949400C6949400CE949400C69C9400CEAD9400F7CE9400C6A59C00CEA5
            9C00D6A59C00C6AD9C00CEAD9C00D6AD9C00F7CE9C00F7D69C004A7BA500CEAD
            A500D6B5A500DEBDA500F7D6A500DEBDAD00DEC6AD00E7C6AD00FFDEAD00FFE7
            AD00CEB5B500F7DEB500F7E7B500FFE7B500FFEFB500D6BDBD00DED6BD00E7DE
            BD00FFE7BD006B9CC600EFDEC600FFEFC600FFF7C600F7E7CE00FFF7CE00F7EF
            D600F7F7D600FFF7D600FFFFD6002184DE00F7F7DE00FFFFDE001884E700188C
            E700FFFFE700188CEF00218CEF00B5D6EF00F7F7EF00FFF7EF00FFFFEF00FFFF
            F700FF00FF004AB5FF0052B5FF0052BDFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0042020A424242
            424242424242424242422B39180B42424242424242424242424243443C180B42
            4242424242424242424242444438180B42424242424242424242424244433918
            0A424242424242424242424242444335004201101A114242424242424242453D
            05072F343434291942424242424242221A2D34343437403E0442424242424206
            231C303437404146284242424242421B210F30373A414140310D42424242421F
            20032434373A3A37321342424242421D25030F2D37373737311042424242420D
            2D2D1C162430333429424242424242421E463F0F0316252E0842424242424242
            4227312D21252314424242424242424242420E141B1B42424242}
          TabOrder = 4
          OnClick = BitBtn1Click
        end
        object GroupOdemeDurum: TRadioGroup
          Left = 5
          Top = 57
          Width = 322
          Height = 30
          Columns = 2
          ItemIndex = 0
          Items.Strings = (
            #214'denmemi'#351'leri g'#246'ster'
            'T'#252'm'#252'n'#252' g'#246'ster')
          TabOrder = 5
        end
      end
    end
    object shtTaksit: TTabSheet
      Caption = 'Taksit Arama'
      ImageIndex = 1
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 812
        Height = 89
        Align = alTop
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object Label5: TcxLabel
          Left = 5
          Top = 11
          Caption = 'Cari Kod'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label6: TcxLabel
          Left = 5
          Top = 36
          Caption = 'Cari Ad'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label7: TcxLabel
          Left = 5
          Top = 61
          Caption = 'Ba'#351'lang'#305#231' '
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label8: TcxLabel
          Left = 208
          Top = 61
          Caption = 'Biti'#351
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object EditTaksitCariKod: TEdit
          Left = 103
          Top = 6
          Width = 121
          Height = 24
          TabOrder = 0
        end
        object EditTaksitCariAd: TEdit
          Left = 103
          Top = 34
          Width = 219
          Height = 24
          TabOrder = 1
        end
        object BitBtn2: TBitBtn
          Left = 338
          Top = 60
          Width = 75
          Height = 25
          Caption = 'Arama'
          Glyph.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            08000000000000010000320B0000320B000000010000000100005A6B7300AD7B
            73004A637B00EFBD8400B58C8C00A5948C00C6948C00B59C8C00BD9C8C00F7BD
            8C00BD949400C6949400CE949400C69C9400CEAD9400F7CE9400C6A59C00CEA5
            9C00D6A59C00C6AD9C00CEAD9C00D6AD9C00F7CE9C00F7D69C004A7BA500CEAD
            A500D6B5A500DEBDA500F7D6A500DEBDAD00DEC6AD00E7C6AD00FFDEAD00FFE7
            AD00CEB5B500F7DEB500F7E7B500FFE7B500FFEFB500D6BDBD00DED6BD00E7DE
            BD00FFE7BD006B9CC600EFDEC600FFEFC600FFF7C600F7E7CE00FFF7CE00F7EF
            D600F7F7D600FFF7D600FFFFD6002184DE00F7F7DE00FFFFDE001884E700188C
            E700FFFFE700188CEF00218CEF00B5D6EF00F7F7EF00FFF7EF00FFFFEF00FFFF
            F700FF00FF004AB5FF0052B5FF0052BDFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0042020A424242
            424242424242424242422B39180B42424242424242424242424243443C180B42
            4242424242424242424242444438180B42424242424242424242424244433918
            0A424242424242424242424242444335004201101A114242424242424242453D
            05072F343434291942424242424242221A2D34343437403E0442424242424206
            231C303437404146284242424242421B210F30373A414140310D42424242421F
            20032434373A3A37321342424242421D25030F2D37373737311042424242420D
            2D2D1C162430333429424242424242421E463F0F0316252E0842424242424242
            4227312D21252314424242424242424242420E141B1B42424242}
          TabOrder = 2
          OnClick = BitBtn2Click
        end
        object Datetaksitbas: TDateTimePicker
          Left = 103
          Top = 61
          Width = 84
          Height = 24
          Date = 39619.000000000000000000
          Time = 0.718074363423511400
          TabOrder = 3
        end
        object datetaksitbit: TDateTimePicker
          Left = 239
          Top = 61
          Width = 83
          Height = 24
          Date = 39619.000000000000000000
          Time = 0.718074363423511400
          TabOrder = 4
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 89
        Width = 812
        Height = 321
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 1
        object cxGrid2: TcxGrid
          Left = 1
          Top = 1
          Width = 810
          Height = 319
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          object tvTaksit: TcxGridDBTableView
            OnDblClick = cxgrdceksenetaramaDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsTaksit
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            object cxGridDBColumn1: TcxGridDBColumn
              DataBinding.FieldName = 'SIRANO'
              Visible = False
              Options.Editing = False
            end
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Width = 109
            end
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = 'Cari Kod'
              DataBinding.FieldName = 'CARIKOD'
              Options.Editing = False
              Width = 70
            end
            object cxGridDBColumn4: TcxGridDBColumn
              Caption = 'Cari Ad'
              DataBinding.FieldName = 'CARIAD'
              Options.Editing = False
              Width = 62
            end
            object cxGridDBColumn5: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              Options.Editing = False
            end
            object cxGridDBColumn6: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              Options.Editing = False
            end
            object tvTaksitDBColumn1: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              Options.Editing = False
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = tvTaksit
          end
        end
      end
    end
  end
  object dsCekSenet: TDataSource
    DataSet = qryCekSenet
    Left = 725
    Top = 70
  end
  object qryCekSenet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = ()
    Left = 759
    Top = 36
  end
  object DtsTaksit: TDataSource
    DataSet = qryTaksit
    Left = 725
    Top = 36
  end
  object qryTaksit: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select SIRANO, TARIH, CARIKOD, CARIAD, ACIKLAMA, GIREN AS TUTAR,' +
        ' KUR, SOZID'
      'FROM  KASA'
      'WHERE '
      ' TARIH BETWEEN :PBASTAR AND :PBITTAR AND'
      ' CARIKOD LIKE :PCARIKOD AND'
      ' CARIAD LIKE :PCARIAD AND'
      'ISNULL(SOZID,'#39#39') LIKE '#39'T-:%'#39
      'ORDER BY TARIH')
    Left = 759
    Top = 70
  end
end

