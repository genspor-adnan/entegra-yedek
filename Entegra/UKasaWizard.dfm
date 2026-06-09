object KasaWizardDlg: TKasaWizardDlg
  Left = 0
  Top = 0
  ActiveControl = KasaTarihi
  BorderIcons = []
  Caption = 'Kasa '#304#351'lemleri'
  ClientHeight = 571
  ClientWidth = 1111
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 18
  object Label54: TcxLabel
    Left = 282
    Top = 79
    Caption = 'Portf'#246'y'
  end
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 1111
    Height = 571
    ActivePage = MenuEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &'#214'nceki'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Sonraki >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Biti'#351
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.ModalResult = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      1111
      571)
    object MenuEkr: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'G'#252'nl'#252'k Aksiyonlar'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #304#351'lem Se'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clRed
      Header.Subtitle.Font.Height = -12
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = [fsBold]
      Panel.BorderWidth = 3
      VisibleButtons = [bkNext, bkCancel]
      OnEnterPage = MenuEkrEnterPage
      OnNextButtonClick = MenuEkrNextButtonClick
      object Label3: TcxLabel
        Left = 494
        Top = 36
        Caption = #304#351'lem Tarihi'
      end
      object KasaTarihi: TcxDateEdit
        Left = 581
        Top = 35
        Properties.Kind = ckDateTime
        Properties.SaveTime = False
        Properties.ShowTime = False
        TabOrder = 0
        Width = 140
      end
      object PanelSol: TPanel
        Left = 164
        Top = 70
        Width = 397
        Height = 459
        Align = alLeft
        Caption = 'PanelSol'
        TabOrder = 2
        object MenuMusTree: TcxTreeView
          Left = 1
          Top = 20
          Width = 395
          Height = 438
          Align = alClient
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clActiveCaption
          Style.IsFontAssigned = True
          TabOrder = 1
          OnClick = MenuMusTreeClick
          OnDblClick = MenuVarTreeDblClick
          AutoExpand = True
          Items.NodeData = {
            070400000009540054007200650065004E006F00640065003700000000000000
            00000000FFFFFFFFFFFFFFFFFFFFFFFF000000000004000000010C420065006C
            0067006500200047006900720069005F01690000002B000000000000000B0000
            00FFFFFFFFFFFFFFFF0000000000000000000000000001064600610074007500
            72006100000025000000000000000C000000FFFFFFFFFFFFFFFF000000000000
            000000000000000103460069005F0100002F000000000000000A000000FFFFFF
            FFFFFFFFFF00000000000000000000000000010830017200730061006C006900
            7900650000003F000000000000000D000000FFFFFFFFFFFFFFFF000000000000
            00000000000000011041006C006100630061006B00200054006100680061006B
            006B0075006B0075000000370000000000000001000000FFFFFFFFFFFFFFFFFF
            FFFFFF000000000004000000010C420065006C00670065002000C70031016B00
            31015F01310100002B000000000000000F000000FFFFFFFFFFFFFFFF00000000
            0000000000000000000106460061007400750072006100000025000000000000
            0010000000FFFFFFFFFFFFFFFF00000000000000000000000000010346006900
            5F0100002F000000000000000E000000FFFFFFFFFFFFFFFF0000000000000000
            0000000000010830017200730061006C0069007900650000003B000000000000
            0011000000FFFFFFFFFFFFFFFF00000000000000000000000000010E42006F00
            7200E700200054006100680061006B006B0075006B0075000000390000000000
            000015000000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000000010D430061
            00720069002000540061006800730069006C0061007400000033000000000000
            001F000000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000000010A43006100
            720069002000D600640065006D006500}
          ReadOnly = True
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 395
          Height = 19
          Align = alTop
          Caption = 'M'#252#351'teri '#304#351'lemleri'
          Color = clActiveBorder
          ParentBackground = False
          TabOrder = 0
        end
      end
      object PanelSag: TPanel
        Left = 561
        Top = 70
        Width = 550
        Height = 459
        Align = alClient
        TabOrder = 3
        object MenuVarTree: TcxTreeView
          Left = 1
          Top = 20
          Width = 548
          Height = 438
          Align = alClient
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          Style.BorderStyle = cbsFlat
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clActiveCaption
          Style.IsFontAssigned = True
          TabOrder = 1
          OnClick = MenuVarTreeClick
          OnDblClick = MenuVarTreeDblClick
          AutoExpand = True
          Items.NodeData = {
            070300000009540054007200650065004E006F00640065002F00000000000000
            00000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000900000001085400720061
            006E0073006600650072000000510000000000000028000000FFFFFFFFFFFFFF
            FFFFFFFFFF00000000000000000001194B006100730061006C00610072002000
            4100720061007300310120005400720061006E0073006600650072006C006500
            72000000430000000000000029000000FFFFFFFFFFFFFFFFFFFFFFFF00000000
            00000000000112420061006E006B006100790061002000500061007200610020
            0059006100740031017200000041000000000000002A000000FFFFFFFFFFFFFF
            FFFFFFFFFF0000000000000000000111420061006E006B006100640061006E00
            200050006100720061002000C70065006B00000061000000000000002B000000
            FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000121420061006E006B0061
            002000480065007300610070006C006100720031012000410072006100730031
            0120005400720061006E0073006600650072006C006500720000004B00000000
            00000031000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000001164300
            6100720069006C00650072002000410072006100730031012000540072006100
            6E007300660065007200000035000000000000003A000000FFFFFFFFFFFFFFFF
            FFFFFFFF000000000000000000010B4B0072006500640069002000D600640065
            006D0065000000410000000000000039000000FFFFFFFFFFFFFFFFFFFFFFFF00
            000000000000000001114B00720065006400690020004B006100720074003101
            2000D600640065006D00650000004F0000000000000057000000FFFFFFFFFFFF
            FFFFFFFFFFFF00000000000000000001184B00720065006400690020004B0061
            007200740031012000D600640065006D00650020003001610064006500730069
            00000037000000000000002C000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000
            00000000010C50004F005300200041006B0074006100720031016D0031010000
            2B0000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000050000
            0001064400F600760069007A00200000003F000000000000002D000000FFFFFF
            FFFFFFFFFFFFFFFFFF00000000000000000001104B0061007300610064006100
            6E0020004400F600760069007A00200041006C00000041000000000000002E00
            0000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000001114B006100730061
            00640061006E0020004400F600760069007A0020005300610074000000410000
            00000000002F000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000111
            420061006E006B006100640061006E0020004400F600760069007A0020004100
            6C000000430000000000000030000000FFFFFFFFFFFFFFFFFFFFFFFF00000000
            00000000000112420061006E006B006100640061006E0020004400F600760069
            007A00200053006100740000003B0000000000000032000000FFFFFFFFFFFFFF
            FFFFFFFFFF000000000000000000010E420061006E006B006100200041007200
            620069007400720061006A0000003B0000000000000000000000FFFFFFFFFFFF
            FFFF00000000000000000005000000010E4D006100730072006100660020002F
            002000470065006C00690072000000470000000000000083000000FFFFFFFFFF
            FFFFFFFFFFFFFF00000000000000000001144B00610073006100640061006E00
            20004D00610073007200610066002000D600640065006D006500000049000000
            0000000084000000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000000011542
            0061006E006B006100640061006E0020004D00610073007200610066002000D6
            00640065006D0065000000570000000000000087000000FFFFFFFFFFFFFFFFFF
            FFFFFF000000000000000000011C4B00720065006400690020004B0061007200
            740031016E00640061006E0020004D00610073007200610066002000D6006400
            65006D00650000004B0000000000000079000000FFFFFFFFFFFFFFFFFFFFFFFF
            00000000000000000001164B00610073006100790061002000470065006C0069
            0072002000540061006800730069006C0061007400310100004D000000000000
            007A000000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000000011742006100
            6E006B006100790061002000470065006C006900720020005400610068007300
            69006C00610074003101}
          ReadOnly = True
        end
        object Panel4: TPanel
          Left = 1
          Top = 1
          Width = 548
          Height = 19
          Align = alTop
          Caption = 'Varl'#305'k '#304#351'lemleri'
          Color = clActiveBorder
          ParentBackground = False
          TabOrder = 0
        end
      end
      object ComboSube: TcxImageComboBox
        Left = 792
        Top = 34
        RepositoryItem = Tablo.RepSubeler
        Properties.Items = <>
        TabOrder = 4
        Width = 151
      end
      object LblSube: TcxLabel
        Left = 746
        Top = 36
        Caption = #350'ube'
        Transparent = True
      end
    end
    object FaturaPlanSecEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Planlanm'#305#351' '#246'deme veya Faturas'#305'n'#305' se'#231'in'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Tahsilat ya da '#246'deme yaparken '#246'nceden girilmi'#351' plan ya da fatura' +
        'yla e'#351'le'#351'tirme yapar'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'FaturaPlanSecEkr'
      OnEnterPage = FaturaPlanSecEkrEnterPage
      OnPage = FaturaPlanSecEkrPage
      OnNextButtonClick = FaturaPlanSecEkrNextButtonClick
      object GridTakvimPlan: TcxGrid
        Left = 0
        Top = 277
        Width = 1111
        Height = 252
        Align = alClient
        TabOrder = 4
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object TakvimPlanView: TcxGridDBTableView
          OnDblClick = TakvimPlanViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = TakvimPlanViewCellClick
          DataController.DataSource = DtsTakvimPlan
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object TakvimPlanViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object TakvimPlanViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Giren Fatura'
                ImageIndex = 0
                Value = 11
              end
              item
                Description = #199#305'kan Fatura'
                Value = 15
              end
              item
                Description = 'Tahsilat Plan'#305
                ImageIndex = 0
                Value = 61
              end
              item
                Description = #214'deme Plan'#305
                Value = 71
              end>
            Width = 91
          end
          object TakvimPlanViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Tahmin'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = 'Fatural'#305
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 2
              end>
          end
          object TakvimPlanViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object TakvimPlanViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 132
          end
          object TakvimPlanViewHESAPADI: TcxGridDBColumn
            Caption = #214'deme Yeri'
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 150
          end
          object TakvimPlanViewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            Width = 69
          end
          object TakvimPlanViewKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 34
          end
        end
        object cxGridLevel5: TcxGridLevel
          GridView = TakvimPlanView
        end
      end
      object PanelPlanOde: TPanel
        Left = 0
        Top = 236
        Width = 1111
        Height = 41
        Align = alTop
        Alignment = taLeftJustify
        Caption = 'Daha '#246'nce yap'#305'lm'#305#351' '#246'deme planlar'#305
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 3
        object PlanSilTus: TcxButton
          Left = 773
          Top = 6
          Width = 197
          Height = 25
          Caption = #214'deme Plan'#305'n'#305' Sil'
          TabOrder = 0
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          OnClick = PlanSilTusClick
        end
      end
      object GridTakvimFat: TcxGrid
        Left = 0
        Top = 111
        Width = 1111
        Height = 125
        Align = alTop
        TabOrder = 2
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object TakvimFatView: TcxGridDBTableView
          OnDblClick = TakvimPlanViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = TakvimFatViewCellClick
          DataController.DataSource = DtsTakvimFat
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Giren Fatura'
                ImageIndex = 0
                Value = 11
              end
              item
                Description = #199#305'kan Fatura'
                Value = 15
              end
              item
                Description = 'Tahsilat Plan'#305
                ImageIndex = 0
                Value = 61
              end
              item
                Description = #214'deme Plan'#305
                Value = 71
              end>
            Width = 69
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Tahmin'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = 'Fatural'#305
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 2
              end>
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 132
          end
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            Width = 69
          end
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 34
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = TakvimFatView
        end
      end
      object PanelPlanFat: TPanel
        Left = 0
        Top = 70
        Width = 1111
        Height = 41
        Align = alTop
        Alignment = taLeftJustify
        Caption = '  Daha '#246'nce kesilmi'#351' faturalar'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 1
      end
      object DisindaTus: TcxButton
        Left = 775
        Top = 35
        Width = 197
        Height = 25
        Caption = 'A'#351'a'#287#305'dakilerin d'#305#351#305'nda >'
        TabOrder = 0
        OnClick = DisindaTusClick
      end
    end
    object CekSenetKrediAraEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #199'ek/Senet/Kredi/KrediKart'#305' Arama '
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      OnEnterPage = CekSenetKrediAraEkrEnterPage
      OnPage = CekSenetKrediAraEkrPage
      OnExitPage = CekSenetKrediAraEkrExitPage
      object GridCekSenetKrediAra: TcxGrid
        Left = 0
        Top = 104
        Width = 1111
        Height = 425
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        object TVCekSenetKrediAra: TcxGridDBTableView
          OnDblClick = TVCekSenetKrediAraDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dsCekSenet
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
        end
        object GLCekSenetKrediAra: TcxGridLevel
          GridView = TVCekSenetKrediAra
        end
      end
      object CekSenetAramaPanel: TPanel
        Left = 0
        Top = 70
        Width = 1111
        Height = 34
        Align = alTop
        TabOrder = 0
        object LabelCariKodAra: TcxLabel
          Left = 13
          Top = 4
          Caption = 'Kod'
        end
        object LabelCariAdAra: TcxLabel
          Left = 151
          Top = 6
          Caption = 'Ad'
        end
        object Label10: TcxLabel
          Left = 401
          Top = 6
          Caption = 'Durum'
        end
        object edCarikod: TcxTextEdit
          Left = 56
          Top = 3
          TabOrder = 1
          OnKeyUp = edCarikodKeyUp
          Width = 75
        end
        object edCariAd: TcxTextEdit
          Left = 181
          Top = 3
          TabOrder = 2
          OnKeyUp = edCariAdKeyUp
          Width = 209
        end
        object CekSenetAraTus: TBitBtn
          Left = 633
          Top = 4
          Width = 75
          Height = 25
          Caption = 'Listele'
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
          TabOrder = 0
          OnClick = CekSenetAraTusClick
        end
        object ComboCekSenetKrediDurum: TcxImageComboBox
          Left = 446
          Top = 3
          Properties.Items = <>
          Properties.OnCloseUp = ComboCekSenetKrediDurumPropertiesCloseUp
          TabOrder = 6
          Width = 181
        end
      end
      object MemoCekSQL: TMemo
        Left = 2
        Top = 314
        Width = 560
        Height = 41
        Lines.Strings = (
          'declare @CekTipi  smallint'
          'declare @CekKodu varchar(20)'
          'declare @CekAdi varchar(50)'
          'declare @IslemTuru smallint'
          ''
          'set @CekTipi = :PCekTipi'
          'set @CekKodu = :PCekKodu'
          'set @CekAdi = :PCekAdi'
          'set @IslemTuru = :PIslemTuru'
          'select '
          #9'C.ID,'
          #9'VADE, '
          #9'C.SERINO, '
          #9'C.DURUM, '
          #9'REHBERID, '
          #9'CARIKOD=R.KOD, '
          #9'CARIAD=R.FIRMA,'
          #9'TUTAR , '
          #9'KUR, '
          #9'NOTLAR'
          'FROM '
          #9'CEKLER C inner join '
          #9'REHBER R on '
          #9#9'C.REHBERID = R.ID'#9#9
          'where '
          ''
          #9'R.KOD like '#39'%'#39'+@CekKodu+'#39'%'#39
          #9'AND R.FIRMA like '#39'%'#39'+@CekAdi+'#39'%'#39
          #9'and C.DURUM<>3'
          #9'and C.TUR = @IslemTuru'#9
          #9'and C.CEKSENET=@CekTipi ')
        TabOrder = 2
        Visible = False
      end
      object MemoSenetSQL: TMemo
        Left = 1
        Top = 355
        Width = 560
        Height = 43
        Lines.Strings = (
          'declare @SenetDurum smallint'
          'declare @SenetKodu varchar(20)'
          'declare @SenetAdi varchar(50)'
          'declare @IslemTuru smallint'
          'set @SenetDurum = :PSenetDurum'
          'set @SenetKodu = :PSenetKodu'
          'set @SenetAdi = :PSenetAdi'
          'set @IslemTuru = :PIslemTuru'
          'select '
          #9'C.ID,'
          #9'VADE, '
          #9'C.DURUM, '
          #9'REHBERID, '
          #9'CARIKOD=R.KOD, '
          #9'CARIAD=R.FIRMA,'
          #9'TUTAR , '
          #9'KUR, '
          #9'NOTLAR'
          'FROM '
          #9'SENETLER C inner join '
          #9'REHBER R on '
          #9#9'C.REHBERID = R.ID'#9#9
          'where '
          #9'1 = case '
          #9#9'when @SenetDurum = 0 then 1 '
          #9#9'when @SenetDurum in(1,2,4,5,6,7,8,9)and '
          #9#9#9'C.DURUM=@SenetDurum then 1  '
          #9#9'else 0 end'
          #9'AND R.KOD like '#39'%'#39'+@SenetKodu+'#39'%'#39
          #9'AND R.FIRMA like '#39'%'#39'+@SenetAdi+'#39'%'#39
          #9'and C.TUR = @IslemTuru'#9
          #9'and C.CEKSENET=121')
        TabOrder = 3
        Visible = False
      end
      object MemoKrediler: TMemo
        Left = 3
        Top = 400
        Width = 560
        Height = 41
        Lines.Strings = (
          'declare @KrediDurum smallint'
          'declare @KrediKodu varchar(20)'
          'declare @KrediAdi varchar(50)'
          'declare @KrediId varchar(10)'
          ''
          ''
          'set @KrediDurum =:PKrediDurum'
          'set @KrediAdi = :PKrediAdi'
          'set @KrediKodu = :PKrediKodu'
          'set @KrediId = :PKrediId'
          ''
          ''
          'SELECT'
          'K.KREDIKODU,KS.BELGENO,K.ADI, KS.ISLEMTARIHI,KS.BORC,'
          'ODENEN=(select isnull(SUM(ALACAK),0.0)from KASA KS2'
          'where K.ID=KS2.HESAPID AND KS2.HESAPTURU='#39'R'#39
          'AND KS2.TUR=58 and KS2.BELGENO=KS.BELGENO),'
          'BAKIYE=KS.BORC-(select isnull(SUM(ALACAK),0.0)from KASA KS2'
          'where K.ID=KS2.HESAPID AND KS2.HESAPTURU='#39'R'#39
          'AND KS2.TUR=58 and KS2.BELGENO=KS.BELGENO),'
          'K.KUR,ACIKLAMA,GENELKREDITIPI,'
          'MASRAF=(select AD from MASRAFGELIR where ID=K.MASRAFID),'
          'FAIZMASRAF=(select AD from MASRAFGELIR where ID=K.FAIZMASRAFID),'
          
            'K.ID as KREDIID,KS.ID AS DETAYID,BANKATICARIHESAPID, KASAYA_DETA' +
            'YLI,K.MASRAFID'
          ',K.FAIZMASRAFID,K.REHBERID,KREDIREFERANSNO=KS.ACIKLAMA'
          'FROM KREDILER K'
          
            'INNER JOIN KASA KS ON K.ID=KS.HESAPID AND KS.HESAPTURU='#39'R'#39' AND K' +
            'S.TUR=59'
          'where'
          'K.GENELKREDITIPI = 2'
          '--where TUTAR>0'
          ' --and 1= case'
          ' --'#9#9'when @KrediDurum = 0 then 1'
          ' -- '#9#9'when @KrediDurum = 1 and ODENMIS=1 then 1'
          ' --'#9#9'when @KrediDurum = 2 and ODENMIS=0 then 1'
          ' --'#9#9'else 2 end'
          ' AND K.KREDIKODU like '#39'%'#39'+@KrediKodu+'#39'%'#39
          ' AND K.ADI like '#39'%'#39'+@KrediAdi+'#39'%'#39
          ' and K.ID like @KrediId'
          ''
          'union all'
          ''
          'SELECT'
          
            #9'K.KREDIKODU,BELGENO=K.SOZLESMENO,K.ADI,TARIH,KO.TAKSIT,ODENEN=0' +
            ',BAKIYE'
          #9',K.KUR,ACIKLAMA,GENELKREDITIPI,'
          #9'MASRAF=(select AD from MASRAFGELIR where ID=K.MASRAFID),'
          
            #9'FAIZMASRAF=(select AD from MASRAFGELIR where ID=K.FAIZMASRAFID)' +
            ','
          'K.ID as KREDIID,KO.ID AS'
          
            #9'DETAYID,BANKATICARIHESAPID, KASAYA_DETAYLI,K.MASRAFID,K.FAIZMAS' +
            'RAFID,K.REHBERID,'
          'KREDIREFERANSNO=null'
          '  FROM KREDILER K '
          '       INNER JOIN PLANKREDI KO ON K.ID=KO.KREDIID '
          '       --INNER JOIN BANKAHESAPLAR BH on '
          '       --BH.ID = K.BANKATICARIHESAPID'
          'where KO.TAKSIT>0 '
          ' and 1= case '
          #9#9'when @KrediDurum = 0 then 1'
          #9#9'when @KrediDurum = 1 and ODENMIS=1 then 1'
          #9#9'when @KrediDurum = 2 and ODENMIS=0 then 1'
          #9#9'else 2 end'
          ' AND K.KREDIKODU like '#39'%'#39'+@KrediKodu+'#39'%'#39
          ' AND K.ADI like '#39'%'#39'+@KrediAdi+'#39'%'#39
          ' and K.ID like @KrediId'
          '')
        TabOrder = 4
        Visible = False
      end
    end
    object PlanlamaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Planlama Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Hangi tarihte '#246'deme yap'#305'laca'#287#305' bilgisi girilir'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkFinish, bkCancel]
      OnEnterPage = PlanlamaEkrEnterPage
      OnPage = PlanlamaEkrPage
      OnNextButtonClick = PlanlamaEkrNextButtonClick
      object PanelTaksit: TPanel
        Left = 0
        Top = 70
        Width = 1111
        Height = 459
        Align = alClient
        TabOrder = 0
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 1109
          Height = 176
          Align = alTop
          TabOrder = 0
          object Yenilebtn: TSpeedButton
            Left = 597
            Top = 95
            Width = 158
            Height = 20
            Caption = #214'deme Takvimini Yenile'
            Flat = True
            Visible = False
            OnClick = YenilebtnClick
          end
          object LabelKanal: TcxLabel
            Left = 487
            Top = 6
            Caption = #214'deme Kanal'#305
            Transparent = True
            Visible = False
          end
          object Label5: TcxLabel
            Left = 5
            Top = 131
            Caption = 'A'#231#305'klama'
          end
          object LabelUyariGun: TcxLabel
            Left = 443
            Top = 134
            Caption = 'g'#252'n '#246'nceden'
          end
          object Label32: TcxLabel
            Left = 5
            Top = 9
            Caption = 'Toplam'
            Transparent = True
          end
          object LabelPesin: TcxLabel
            Left = 5
            Top = 42
            Caption = 'Pe'#351'in'
            Visible = False
          end
          object LabelPlanlananTarih: TcxLabel
            Left = 5
            Top = 40
            Caption = 'Planlanan Tarih'
            Transparent = True
          end
          object ComboBoxOdemeYeri: TcxImageComboBox
            Left = 596
            Top = 3
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                ImageIndex = 0
                Value = -1
              end
              item
                Description = 'Kasa'
                ImageIndex = 0
                Value = 100
              end
              item
                Description = 'Banka'
                Value = 102
              end
              item
                Description = 'Al'#305'nacak '#199'ek'
                Value = 101
              end
              item
                Description = 'Verilecek '#199'ek'
                Value = 103
              end>
            Properties.OnCloseUp = ComboBoxOdemeYeriPropertiesCloseUp
            TabOrder = 2
            Visible = False
            Width = 158
          end
          object ComboPlanAciklama: TcxComboBox
            Left = 79
            Top = 130
            Properties.MaxLength = 0
            TabOrder = 13
            Width = 241
          end
          object CheckBitisUyar: TcxCheckBox
            Left = 327
            Top = 130
            Caption = 'Uyar'#305' ver'
            State = cbsChecked
            TabOrder = 15
            Transparent = True
            OnClick = CheckBitisUyarClick
          end
          object SpinUYARIGUN: TcxSpinEdit
            Left = 400
            Top = 130
            Properties.MinValue = 1.000000000000000000
            TabOrder = 14
            Value = 1
            Width = 42
          end
          object cxLabel2: TcxLabel
            Left = 528
            Top = 134
            Caption = 'Resmi tatilse'
          end
          object RadioOnceSonra1: TRadioButton
            Left = 607
            Top = 137
            Width = 63
            Height = 17
            Caption = 'Etkileme'
            TabOrder = 17
          end
          object RadioOnceSonra2: TRadioButton
            Left = 697
            Top = 137
            Width = 102
            Height = 17
            Caption = 'Bir '#246'nceki g'#252'n'
            TabOrder = 18
          end
          object RadioOnceSonra3: TRadioButton
            Left = 834
            Top = 137
            Width = 113
            Height = 17
            Caption = 'Bir sonraki g'#252'n'
            Checked = True
            TabOrder = 20
            TabStop = True
          end
          object EditTutar: TcxCurrencyEdit
            Left = 139
            Top = 8
            Properties.AssignedValues.DisplayFormat = True
            Properties.AssignedValues.EditFormat = True
            TabOrder = 0
            OnKeyUp = EditTutarKeyUp
            Width = 121
          end
          object ComboKurPlan: TcxComboBox
            Left = 262
            Top = 8
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            Properties.DropDownListStyle = lsFixedList
            Properties.MaxLength = 0
            Properties.OnCloseUp = YenilebtnClick
            TabOrder = 1
            Width = 58
          end
          object DatePesinat: TcxDateEdit
            Left = 139
            Top = 36
            Properties.OnCloseUp = YenilebtnClick
            TabOrder = 6
            Width = 121
          end
          object EditPesinTutar: TcxCurrencyEdit
            Left = 140
            Top = 36
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            TabOrder = 5
            Visible = False
            Width = 120
          end
          object CheckTaksit: TCheckBox
            Left = 5
            Top = 70
            Width = 85
            Height = 17
            Caption = 'Taksitli Plan'
            TabOrder = 10
            OnClick = CheckTaksitClick
          end
          object TaksitPanel: TPanel
            Left = 3
            Top = 91
            Width = 512
            Height = 30
            BevelOuter = bvNone
            TabOrder = 11
            Visible = False
            object Label13: TcxLabel
              Left = 5
              Top = 5
              Caption = 'Taksit Say'#305's'#305
              Transparent = True
            end
            object Label61: TcxLabel
              Left = 336
              Top = 3
              Caption = 'Ara'
              Transparent = True
            end
            object Label62: TcxLabel
              Left = 421
              Top = 1
              Caption = 'ay'
            end
            object TaksitSay: TcxSpinEdit
              Left = 76
              Top = 0
              Properties.ImmediatePost = True
              Properties.MaxValue = 100.000000000000000000
              Properties.MinValue = 1.000000000000000000
              Properties.OnEditValueChanged = YenilebtnClick
              TabOrder = 0
              Value = 1
              Width = 38
            end
            object EditTaksitTutar: TcxCurrencyEdit
              Left = 114
              Top = 0
              ParentColor = True
              Properties.DisplayFormat = ',0.00 ;-,0.00 '
              TabOrder = 1
              Width = 78
            end
            object DateTaksit: TcxDateEdit
              Left = 196
              Top = 0
              Properties.OnCloseUp = YenilebtnClick
              TabOrder = 2
              Width = 121
            end
            object AraSay: TcxSpinEdit
              Left = 380
              Top = 0
              Properties.LargeIncrement = 1.000000000000000000
              Properties.MaxValue = 12.000000000000000000
              Properties.MinValue = 1.000000000000000000
              Properties.OnChange = YenilebtnClick
              TabOrder = 3
              Value = 1
              Width = 38
            end
          end
          object PanelOdemeKanali: TPanel
            Left = 489
            Top = 31
            Width = 323
            Height = 66
            Alignment = taLeftJustify
            BevelOuter = bvNone
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            TabOrder = 9
            object LabelBanka: TcxLabel
              Left = 0
              Top = 5
              Caption = 'G'#246'nderen'
              Transparent = True
            end
            object LabelPlanBankaHesapNoGon: TcxLabel
              Left = 273
              Top = 2
              Caption = '---'
            end
            object LabelPlanBankaHesapIdGon: TcxLabel
              Left = 311
              Top = -1
              Caption = '-1'
              Visible = False
            end
            object Label14: TcxLabel
              Left = 0
              Top = 35
              Caption = 'Al'#305'c'#305
              Transparent = True
            end
            object LabelPlanBankaHesapNoAl: TcxLabel
              Left = 273
              Top = 32
              Caption = '---'
            end
            object LabelPlanBankaHesapIdAl: TcxLabel
              Left = 312
              Top = 29
              Caption = '-1'
              Visible = False
            end
            object EditPlanBankaHesapGon: TcxButtonEdit
              Tag = -99
              Left = 108
              Top = 1
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.MaxLength = 0
              Properties.OnButtonClick = EditPlanBankaHesapAdiPropertiesButtonClick
              TabOrder = 0
              Width = 158
            end
            object EditPlanBankaHesapAlici: TcxButtonEdit
              Left = 108
              Top = 30
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.MaxLength = 0
              Properties.OnButtonClick = EditPlanBankaHesapAliciPropertiesButtonClick
              TabOrder = 4
              Width = 158
            end
          end
          object ComboPlanSecim: TcxComboBox
            Left = 353
            Top = 7
            Enabled = False
            Properties.DropDownListStyle = lsFixedList
            Properties.Items.Strings = (
              'Plan Olu'#351'tur'
              'Senet Olu'#351'tur'
              'Plan+Senet Olu'#351'tur')
            Properties.MaxLength = 0
            Properties.OnCloseUp = ComboSecimPropertiesCloseUp
            TabOrder = 21
            Width = 109
          end
          object LabelCekSenetKod: TcxLabel
            Left = 353
            Top = 39
            Cursor = crHandPoint
            Caption = '-----'
            Transparent = True
            OnClick = LabelCekSenetKodClick
          end
          object cxLabel8: TcxLabel
            Left = 822
            Top = 5
            Caption = 'Kay'#305't Tarihi'
          end
          object CekSenetKayitTarihi: TcxDateEdit
            Left = 909
            Top = 4
            Properties.Kind = ckDateTime
            Properties.SaveTime = False
            Properties.ShowTime = False
            TabOrder = 24
            Width = 140
          end
        end
        object GridTaksit: TcxGrid
          Left = 1
          Top = 177
          Width = 1109
          Height = 281
          Align = alClient
          TabOrder = 1
          Visible = False
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object PlanTview: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = PlanTviewCanFocusRecord
            DataController.DataSource = DtsOdemeTakvimi
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                FieldName = 'TUTAR'
                Column = ColumnTUTAR
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            object ColumnSozId: TcxGridDBColumn
              Caption = 'No'
              DataBinding.FieldName = 'SOZID'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object ColumnTarih: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxDateEditProperties'
              Properties.ImmediatePost = True
              Width = 79
            end
            object ColumnTUTAR: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Width = 93
            end
            object ColumnKur: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object ColumnACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 306
            end
            object PlanTviewUYAR: TcxGridDBColumn
              Caption = 'Uyar'
              DataBinding.FieldName = 'UYAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Visible = False
              Options.Editing = False
              Width = 36
            end
            object PlanTviewUYARIGUN: TcxGridDBColumn
              Caption = 'G'#252'n Say'#305's'#305
              DataBinding.FieldName = 'UYARIGUN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxSpinEditProperties'
              Properties.MaxValue = 30.000000000000000000
              Visible = False
              Options.Editing = False
              Width = 67
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = PlanTview
          end
        end
        object SQLPlan: TcxMemo
          Left = 46
          Top = 198
          Lines.Strings = (
            'DECLARE @TAKSIT SMALLINT,     '
            '@I SMALLINT,                    '
            '@BASLANGIC SMALLDATETIME,      '
            '@TUTAR MONEY,                  '
            '@KUR VARCHAR(5),'
            '@ACIKLAMA VARCHAR(50),'
            '@UYAR BIT,'
            '@UYARIGUN SMALLINT,        '
            '@ONCESONRA SMALLINT        '
            '                                    '
            'SET @TAKSIT= :PTAKSIT        '
            'SET @I=1                           '
            'SET @BASLANGIC= :PBASLANGIC '
            'SET @TUTAR= :PTUTAR    '
            'SET @KUR= :PKUR               '
            'SET @ACIKLAMA = :PACIKLAMA'
            'SET @UYAR = :PUYAR'
            'SET @UYARIGUN = :PUYARIGUN'
            'SET @ONCESONRA = :PONCESONRA '
            ''
            'CREATE TABLE #GECICIODEME_:SPID_           '
            ' ( SOZID'#9'INT,                       '
            '   TARIH SMALLDATETIME,             '
            '   TUTAR MONEY,                      '
            '   KUR VARCHAR(5),                   '
            '   ACIKLAMA VARCHAR(50) ,'
            '   UYAR BIT,'
            '   UYARIGUN SMALLINT                 '
            ' )      -- '#214'NCE '#304'LK TAKS'#304'D'#304' AYNEN'
            ''
            
              'INSERT INTO #GECICIODEME_:SPID_ (SOZID, TARIH, TUTAR, KUR, ACIKL' +
              'AMA,UYAR, UYARIGUN)                         '
            
              'VALUES (1,@BASLANGIC, ROUND(@TUTAR/@TAKSIT,2), @KUR, @ACIKLAMA,@' +
              'UYAR,@UYARIGUN)  '
            'SET @I=@I+1  '
            
              'WHILE @I <= @TAKSIT                                             ' +
              '                         '
            
              'BEGIN                                                           ' +
              '                         '
            
              '  INSERT INTO #GECICIODEME_:SPID_ (SOZID, TARIH, TUTAR, KUR, ACI' +
              'KLAMA, UYAR, UYARIGUN)                         '
            
              '  VALUES (1,[dbo].[fn_GT_UygunTarihBul](DATEADD(month, @I-1, @BA' +
              'SLANGIC), @ONCESONRA), ROUND(@TUTAR/@TAKSIT,2), @KUR, '
            '@ACIKLAMA,@UYAR,@UYARIGUN)  '
            
              '  SET @I=@I+1                                                   ' +
              '                         '
            
              'END                                                             ' +
              '                         '
            
              '                                                                ' +
              '                         '
            
              'select * from #GECICIODEME_:SPID_                               ' +
              '                                '
            'drop table #GECICIODEME_:SPID_ ')
          TabOrder = 2
          Visible = False
          Height = 30
          Width = 788
        end
        object SQLPesin: TMemo
          Left = 44
          Top = 258
          Width = 816
          Height = 29
          Lines.Strings = (
            'DECLARE '
            '@TAKSIT SMALLINT,    '
            '@I SMALLINT,                   '
            '@ARA SMALLINT,            '
            '@TARIH_PESIN SMALLDATETIME,     '
            '@TARIH_TAKSIT SMALLDATETIME,     '
            '@TUTAR MONEY,@TUTAR_PESIN MONEY,'
            '@KUR VARCHAR(5),'
            '@UYAR SMALLINT,'
            '@UYARIGUN SMALLINT,'
            '@ONCESONRA SMALLINT               '
            '                '
            'SQLKOMUT                     '
            '--SET @TAKSIT=4'
            '--SET @TARIH_PESIN='#39'2010-01-01'#39
            '--sET @TARIH_TAKSIT='#39'2010-01-15'#39
            '--SET @TUTAR=900 '
            '--SET @TUTAR_PESIN=100'
            '--SET @TAKSIT=4'
            '--SET @KUR= '#39'TL'#39
            '--set @UYAR =1'
            '--set @UYARIGUN =1'
            '--SET @ONCESONRA = 1'
            ''
            'CREATE TABLE #GECICIODEME          '
            ' ( ID'#9'INT,                      '
            '   TARIH SMALLDATETIME,            '
            '  TUTAR MONEY,                     '
            '  KUR VARCHAR(5),                  '
            '   ACIKLAMA VARCHAR(50),  '
            '  UYAR bit,'
            '  UYARIGUN SMALLINT               '
            ' )'
            'SET @I=1      '
            '-- '#214'NCE PE'#350#304'NATI s'#305'f'#305'rdan b'#252'y'#252'kse eklensin'
            'if @TUTAR_PESIN > 0 '
            'begin'
            
              '  INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYA' +
              'R, UYARIGUN )            '
            
              '            VALUES (1, [dbo].[fn_GT_UygunTarihBul](@TARIH_PESIN,' +
              '@ONCESONRA), ROUND'
            '    (@TUTAR_PESIN,2), @KUR, '#39'Pe'#351'inat'#39', @UYAR, @UYARIGUN) '
            'end'
            ''
            
              'SET @TUTAR = @TUTAR - @TUTAR_PESIN                              ' +
              '  '
            ''
            '--'#304'LK TAKS'#304'T'
            
              'INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYAR,' +
              ' UYARIGUN )     '
            '                   '
            
              '     VALUES (1,  [dbo].[fn_GT_UygunTarihBul] (@TARIH_TAKSIT, @ON' +
              'CESONRA ), ROUND'
            '(@TUTAR/@TAKSIT,2), @KUR, '
            '       CONVERT(VARCHAR(10),@I)+'#39'. taksit'#39', @UYAR, @UYARIGUN) '
            '--SONRAK'#304' TAKS'#304'TLER  '
            
              'WHILE @I <= @TAKSIT - 1                                         ' +
              '                           '
            
              'BEGIN                                                           ' +
              '                        '
            
              '  INSERT INTO #GECICIODEME (ID, TARIH, TUTAR, KUR, ACIKLAMA, UYA' +
              'R, UYARIGUN )          '
            '              '
            
              '  VALUES (1,[dbo].[fn_GT_UygunTarihBul](DATEADD(month, @I*@ARA,@' +
              'TARIH_TAKSIT),@ONCESONRA), ROUND(@TUTAR/@TAKSIT,2), @KUR, '
            '  CONVERT(VARCHAR(10),@I+1)+'#39'. taksit'#39', @UYAR, @UYARIGUN) '
            
              '  SET @I=@I+1                                                   ' +
              '                        '
            
              'END                                                             ' +
              '                        '
            
              '                                                                ' +
              '                        '
            
              'select * from #GECICIODEME                                      ' +
              '                        '
            'drop table #GECICIODEME ;')
          TabOrder = 3
          Visible = False
        end
      end
    end
    object TahsilatEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Tahsilat Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      Caption = 'TahsilatEkr'
      OnEnterPage = TahsilatEkrEnterPage
      OnPage = TahsilatEkrPage
      OnNextButtonClick = TahsilatEkrNextButtonClick
      object Panel5: TPanel
        Left = 0
        Top = 70
        Width = 1111
        Height = 228
        Align = alClient
        TabOrder = 0
        object Label15: TcxLabel
          Left = 192
          Top = 8
          Caption = 'A'#231#305'klama'
          Transparent = True
        end
        object lbl29: TcxLabel
          Left = 192
          Top = 38
          Caption = 'Tutar'
          Transparent = True
        end
        object LabelFaizTutar: TcxLabel
          Left = 192
          Top = 66
          Caption = 'Faiz'
          Transparent = True
          Visible = False
        end
        object EditTahsilatTutar: TcxCurrencyEdit
          Left = 286
          Top = 36
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          Properties.OnChange = EditTahsilatTutarPropertiesChange
          TabOrder = 2
          Width = 121
        end
        object EditFaizTutar: TcxCurrencyEdit
          Left = 286
          Top = 65
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          TabOrder = 8
          Visible = False
          Width = 121
        end
        object PanelFisBilgi: TPanel
          Left = 192
          Top = 94
          Width = 234
          Height = 64
          BevelOuter = bvNone
          TabOrder = 11
          object lbl27: TcxLabel
            Left = 1
            Top = 2
            Caption = 'Fi'#351' Tarihi'
            Transparent = True
          end
          object lbl28: TcxLabel
            Left = 2
            Top = 31
            Caption = 'Fi'#351' No'
            Transparent = True
          end
          object EditFisNo: TcxTextEdit
            Left = 94
            Top = 30
            TabOrder = 3
            Width = 121
          end
          object DateFisTarihi: TcxDateEdit
            Left = 94
            Top = 1
            TabOrder = 0
            Width = 121
          end
        end
        object ComboBoxTahAciklama: TcxComboBox
          Left = 286
          Top = 7
          Properties.MaxLength = 0
          Properties.OnChange = ComboBoxTahAciklamaPropertiesChange
          TabOrder = 0
          OnDblClick = ComboBoxTahAciklamaDblClick
          Width = 241
        end
        object LabelDovizTutar: TcxLabel
          Left = 533
          Top = 38
          Caption = 'D'#246'viz Tutar'#305' >>>'
          Transparent = True
          OnClick = LabelDovizTutarClick
        end
        object EditDovizTutar: TcxCurrencyEdit
          Left = 624
          Top = 37
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          TabOrder = 4
          Visible = False
          Width = 85
        end
        object ComboDovizTutar: TcxComboBox
          Left = 710
          Top = 37
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          Properties.DropDownListStyle = lsFixedList
          Properties.MaxLength = 0
          TabOrder = 5
          Visible = False
          Width = 58
        end
        object ComboKurTah: TcxComboBox
          Left = 409
          Top = 36
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          Properties.DropDownListStyle = lsFixedList
          Properties.MaxLength = 0
          Properties.OnChange = EditTahsilatTutarPropertiesChange
          TabOrder = 3
          Width = 58
        end
        object PanelTaksitBilgisi: TPanel
          Left = 4
          Top = 79
          Width = 190
          Height = 66
          BevelOuter = bvNone
          TabOrder = 9
          Visible = False
          object Label59: TcxLabel
            Left = 5
            Top = 41
            Caption = 'Taksit Say'#305's'#305
            Properties.WordWrap = True
            Transparent = True
            Width = 68
          end
          object Label60: TcxLabel
            Left = 5
            Top = 15
            Caption = 'Avans Geri '#214'deme'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object SpinAvansSay: TcxSpinEdit
            Left = 82
            Top = 39
            Properties.MaxValue = 100.000000000000000000
            Properties.MinValue = 1.000000000000000000
            Properties.OnChange = SpinAvansSayPropertiesChange
            TabOrder = 1
            Value = 1
            Width = 38
          end
        end
        object EditDovizKuru: TcxCurrencyEdit
          Left = 625
          Top = 63
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          TabOrder = 12
          Visible = False
          Width = 85
        end
      end
      object GridAvansTaksit: TcxGrid
        Left = 0
        Top = 298
        Width = 1111
        Height = 231
        Align = alBottom
        TabOrder = 1
        Visible = False
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridAvansTaksitView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsAvansTakvimi
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn6: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'KASAID'
            DataBinding.IsNullValueType = True
            Options.Editing = False
          end
          object cxGridDBColumn9: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBColumn11: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
          end
          object cxGridDBColumn12: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 258
          end
        end
        object cxGridLevel8: TcxGridLevel
          GridView = GridAvansTaksitView
        end
      end
      object SQLAvanGeriOdeme: TMemo
        Left = 74
        Top = 314
        Width = 816
        Height = 29
        Lines.Strings = (
          ''
          'DECLARE @TAKSIT SMALLINT,                                    '
          '@I SMALLINT,                    '
          '@BASLANGIC SMALLDATETIME,      '
          '@TUTAR MONEY,                  '
          '@KUR VARCHAR(5),'
          '@ACIKLAMA VARCHAR(50),'
          '@ONCESONRA SMALLINT        '
          ''
          'SQLKOMUT'
          '      '
          'CREATE TABLE #GECICIODEME:SPID_           '
          ' ( KASAID '#9'INT,                       '
          '   TARIH SMALLDATETIME,             '
          '   TUTAR MONEY,                      '
          '   KUR VARCHAR(5),                   '
          '   ACIKLAMA VARCHAR(50) ,'
          '  TAKSITNO SMALLINT, '
          '  TAKSITSAY SMALLINT'
          ' )     '
          ''
          
            'WHILE @I <= @TAKSIT                                             ' +
            '                         '
          
            'BEGIN                                                           ' +
            '                         '
          
            '  INSERT INTO #GECICIODEME:SPID_ (KASAID, TARIH, TUTAR, KUR, ACI' +
            'KLAMA, TAKSITNO, TAKSITSAY )                         '
          
            '  VALUES (1,[dbo].[fn_GT_UygunTarihBul](@BASLANGIC, @ONCESONRA),' +
            ' ROUND(@TUTAR/@TAKSIT,2), @KUR,'
          
            'cast(@I as varchar(2))+'#39'/'#39'+cast(@TAKSIT as varchar(2))+'#39'. '#39'+@ACI' +
            'KLAMA,@I, @TAKSIT)  '
          '  SET @I=@I+1       '
          
            'set @BASLANGIC = DATEADD(month, 1, @BASLANGIC)                  ' +
            '                                                   '
          
            'END                                                             ' +
            '                         '
          
            '                                                                ' +
            '                         '
          
            'select * from #GECICIODEME:SPID_                                ' +
            '                               '
          'drop table #GECICIODEME:SPID_ ')
        TabOrder = 2
        Visible = False
      end
    end
    object KasaSecimEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Kasa Se'#231'im Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = #304#351'lem yapmak istedi'#287'iniz kasay'#305' se'#231'in'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      OnEnterPage = KasaSecimEkrEnterPage
      OnPage = KasaSecimEkrPage
      OnExitPage = KasaSecimEkrExitPage
      object KasaGrid: TcxGrid
        Left = 0
        Top = 70
        Width = 1111
        Height = 459
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object KasaGridTableView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dsKasaQuery
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
          OptionsView.GroupByBox = False
        end
        object cxGridLevel3: TcxGridLevel
          GridView = KasaGridTableView
        end
      end
    end
    object VirmanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Virman Ekran'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Kendi hesaplar'#305'm'#305'z aras'#305'ndaki i'#351'lemler i'#231'in kullan'#305'l'#305'r.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      OnEnterPage = VirmanEkrEnterPage
      OnFinishButtonClick = VirmanEkrFinishButtonClick
      object pnl2: TPanel
        Left = 561
        Top = 185
        Width = 42
        Height = 344
        Align = alLeft
        TabOrder = 2
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 1
          Top = 152
          Width = 39
          Height = 30
          Margins.Bottom = 0
          Align = alNone
          ButtonHeight = 20
          ButtonWidth = 15
          Caption = 'AletCubugu'
          DockSite = True
          DrawingStyle = dsGradient
          EdgeInner = esNone
          EdgeOuter = esNone
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          List = True
          ParentFont = False
          ShowCaptions = True
          AllowTextButtons = True
          TabOrder = 0
          object AylikTus: TToolButton
            Tag = 3
            Left = 0
            Top = 0
            ImageIndex = 14
            Style = tbsTextButton
          end
        end
      end
      object GridHedef: TcxGrid
        Left = 603
        Top = 185
        Width = 508
        Height = 344
        Align = alClient
        TabOrder = 3
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridHedefView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dsKurNereyeQuery
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
          OptionsSelection.HideFocusRectOnExit = False
          OptionsView.GroupByBox = False
        end
        object cxGridLevel6: TcxGridLevel
          GridView = GridHedefView
        end
      end
      object PanelVirman: TPanel
        Left = 0
        Top = 70
        Width = 1111
        Height = 115
        Align = alTop
        TabOrder = 0
        object EditArbitrajKarsilik: TcxCurrencyEdit
          Left = 274
          Top = 2
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          Properties.EditFormat = ',0.0000 ;-,0.0000 '
          Properties.ReadOnly = False
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 13
          Visible = False
          Width = 68
        end
        object Label26: TcxLabel
          Left = 3
          Top = 6
          Caption = 'Kaynak Miktar'
          Transparent = True
        end
        object Label51: TcxLabel
          Left = 288
          Top = 38
          Caption = 'A'#231#305'klama'
          Transparent = True
        end
        object VirmanMiktar: TcxCurrencyEdit
          Left = 85
          Top = 3
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          Properties.EditFormat = ',0.0000 ;-,0.0000 '
          Properties.ReadOnly = False
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 0
          OnKeyUp = VirmanMiktarKeyUp
          Width = 68
        end
        object ComboVirmanAciklama: TcxComboBox
          Left = 345
          Top = 35
          Properties.MaxLength = 0
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 5
          Width = 297
        end
        object VirmanKomisyon: TcxCurrencyEdit
          Left = 343
          Top = 3
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          Properties.ReadOnly = False
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 3
          Visible = False
          Width = 57
        end
        object LabelKomisyon: TcxLabel
          Left = 281
          Top = 6
          Caption = 'Komisyon'
          Transparent = True
          Visible = False
        end
        object RadioBankaKasa: TcxRadioGroup
          Left = 419
          Top = -20
          ParentBackground = False
          Properties.Columns = 2
          Properties.Items = <
            item
              Caption = 'Banka'
            end
            item
              Caption = 'Kasa'
            end>
          Properties.OnChange = RadioBankaKasaPropertiesChange
          ItemIndex = 0
          Style.Edges = []
          TabOrder = 4
          Height = 49
          Width = 132
        end
        object ComboVirmanKur: TcxComboBox
          Left = 155
          Top = 2
          Properties.DropDownListStyle = lsFixedList
          Properties.MaxLength = 0
          Properties.OnCloseUp = ComboVirmanKurPropertiesCloseUp
          TabOrder = 1
          Width = 54
        end
        object EditVirmanlKur: TcxCurrencyEdit
          Left = 215
          Top = 2
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.0000 ;-,0.0000 '
          Properties.EditFormat = ',0.0000 ;-,0.0000 '
          Properties.ReadOnly = False
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 2
          Visible = False
          OnKeyUp = VirmanMiktarKeyUp
          Width = 57
        end
        object PanelKarsilik: TPanel
          Left = 3
          Top = 32
          Width = 213
          Height = 31
          BevelOuter = bvNone
          TabOrder = 6
          Visible = False
          object LabelKarsiligi: TcxLabel
            Left = 2
            Top = 5
            Caption = 'Kar'#351#305'l'#305#287#305
            Transparent = True
          end
          object EditKarsiligi: TcxCurrencyEdit
            Left = 83
            Top = 2
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            Properties.EditFormat = ',0.0000;-,0.0000'
            Properties.ReadOnly = False
            Style.Color = clWhite
            Style.TransparentBorder = True
            TabOrder = 1
            OnKeyUp = EditKarsiligiKeyUp
            Width = 68
          end
          object ComboKarsiligiKur: TcxComboBox
            Left = 154
            Top = 2
            Properties.DropDownListStyle = lsFixedList
            Properties.MaxLength = 0
            Properties.OnCloseUp = ComboKarsiligiKurPropertiesCloseUp
            TabOrder = 2
            Width = 54
          end
        end
        object PanelKaynak: TPanel
          Left = 3
          Top = 85
          Width = 962
          Height = 30
          BevelOuter = bvNone
          TabOrder = 7
          Visible = False
          object Label47: TcxLabel
            Left = 3
            Top = 4
            Caption = 'Kaynak Kodu'
            Transparent = True
          end
          object Label50: TcxLabel
            Left = 579
            Top = 3
            Caption = 'Hedef Kodu'
            Transparent = True
          end
          object EditKaynakKod: TcxTextEdit
            Left = 83
            Top = 2
            TabOrder = 2
            OnKeyUp = EditKaynakKodKeyUp
            Width = 100
          end
          object EditHedefKod: TcxTextEdit
            Left = 662
            Top = 1
            TabOrder = 3
            OnKeyUp = EditHedefKodKeyUp
            Width = 99
          end
          object cxLabel3: TcxLabel
            Left = 188
            Top = 4
            Caption = 'Kaynak Ad'#305
            Transparent = True
          end
          object EditKaynakAd: TcxTextEdit
            Left = 253
            Top = 2
            TabOrder = 5
            OnKeyUp = EditKaynakKodKeyUp
            Width = 121
          end
          object cxLabel4: TcxLabel
            Left = 772
            Top = 3
            Caption = 'Hedef Ad'#305
            Transparent = True
          end
          object EditHedefAd: TcxTextEdit
            Left = 857
            Top = 1
            TabOrder = 7
            OnKeyUp = EditHedefKodKeyUp
            Width = 102
          end
          object CbNakitVarlikTipi: TcxImageComboBox
            Left = 448
            Top = 4
            RepositoryItem = Tablo.repKasaVarlikTipi
            EditValue = 0
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <
              item
                Description = 'Nakit'
                ImageIndex = 0
                Value = 0
              end>
            Style.Color = clBtnFace
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Arial'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 8
            Visible = False
            Width = 33
          end
          object LbVarlikTipi: TcxLabel
            Left = 380
            Top = 5
            Caption = 'Varl'#305'k Tipi'
            Transparent = True
            Visible = False
          end
        end
        object LabelRehberId: TcxLabel
          Left = 664
          Top = 35
          Caption = '-'
          Transparent = True
        end
        object LabelRehberAd: TcxLabel
          Left = 722
          Top = 35
          Caption = '-'
          Transparent = True
        end
        object EditKarsiligiKur: TcxCurrencyEdit
          Left = 218
          Top = 34
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.0000 ;-,0.0000 '
          Properties.EditFormat = ',0.0000 ;-,0.0000 '
          Properties.ReadOnly = False
          Style.Color = clWhite
          Style.TransparentBorder = True
          TabOrder = 14
          Visible = False
          OnKeyUp = EditKarsiligiKurKeyUp
          Width = 57
        end
        object CheckR: TcxCheckBox
          Left = 641
          Top = 38
          TabOrder = 15
          Transparent = True
        end
        object PanelHedef: TPanel
          Left = 679
          Top = 3
          Width = 280
          Height = 61
          BevelOuter = bvNone
          TabOrder = 16
          Visible = False
          object cxLabel1: TcxLabel
            Left = 13
            Top = 5
            Caption = 'Hedef Miktar'
            Transparent = True
          end
          object VirmanMiktarHedef: TcxCurrencyEdit
            Left = 93
            Top = 2
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.00 ;-,0.00 '
            Properties.EditFormat = ',0.0000 ;-,0.0000 '
            Properties.ReadOnly = False
            Style.Color = clWhite
            Style.TransparentBorder = True
            TabOrder = 1
            OnKeyUp = VirmanMiktarHedefKeyUp
            Width = 68
          end
          object ComboVirmanKurHedef: TcxComboBox
            Left = 163
            Top = 1
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            Properties.DropDownListStyle = lsFixedList
            Properties.MaxLength = 0
            Properties.OnCloseUp = ComboVirmanKurHedefPropertiesCloseUp
            TabOrder = 2
            Width = 54
          end
          object EditVirmanlKurHedef: TcxCurrencyEdit
            Left = 221
            Top = 1
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.0000 ;-,0.0000 '
            Properties.EditFormat = ',0.0000 ;-,0.0000 '
            Properties.ReadOnly = False
            Style.Color = clWhite
            Style.TransparentBorder = True
            TabOrder = 3
            Visible = False
            OnKeyUp = VirmanMiktarHedefKeyUp
            Width = 57
          end
          object PanelKarsilikHedef: TPanel
            Left = 7
            Top = 28
            Width = 274
            Height = 29
            BevelOuter = bvNone
            TabOrder = 4
            Visible = False
            object cxLabel5: TcxLabel
              Left = 7
              Top = 5
              Caption = 'Kar'#351#305'l'#305#287#305
              Transparent = True
            end
            object EditKarsiligiHedef: TcxCurrencyEdit
              Left = 86
              Top = 3
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.00 ;-,0.00 '
              Properties.EditFormat = ',0.0000;-,0.0000'
              Properties.ReadOnly = False
              Style.Color = clWhite
              Style.TransparentBorder = True
              TabOrder = 1
              OnKeyUp = EditKarsiligiHedefKeyUp
              Width = 68
            end
            object ComboKarsiligiKurHedef: TcxComboBox
              Left = 157
              Top = 2
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Properties.DropDownListStyle = lsFixedList
              Properties.MaxLength = 0
              Properties.OnCloseUp = ComboKarsiligiKurPropertiesCloseUp
              TabOrder = 2
              Width = 54
            end
            object cxCurrencyEdit4: TcxCurrencyEdit
              Left = 215
              Top = 2
              Properties.DecimalPlaces = 4
              Properties.DisplayFormat = ',0.0000 ;-,0.0000 '
              Properties.EditFormat = ',0.0000 ;-,0.0000 '
              Properties.ReadOnly = False
              Style.Color = clWhite
              Style.TransparentBorder = True
              TabOrder = 3
              Visible = False
              Width = 57
            end
          end
        end
      end
      object GridKaynak: TcxGrid
        Left = 0
        Top = 185
        Width = 561
        Height = 344
        Align = alLeft
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridKaynakView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridKaynakViewCellClick
          DataController.DataSource = dsVirmanNerdenQuery
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
          OptionsSelection.HideFocusRectOnExit = False
          OptionsView.GroupByBox = False
        end
        object cxGridLevel7: TcxGridLevel
          GridView = GridKaynakView
        end
      end
      object VirmanTarihi: TcxDateEdit
        Left = 576
        Top = 38
        Properties.Kind = ckDateTime
        TabOrder = 4
        Width = 121
      end
      object LabelVirmanSube: TcxLabel
        Left = 868
        Top = 40
        Caption = #350'ube'
        Transparent = True
      end
      object VirmanSube: TcxImageComboBox
        Left = 904
        Top = 38
        RepositoryItem = Tablo.RepSubeler
        Properties.Items = <>
        TabOrder = 6
        Width = 151
      end
      object cxLabel6: TcxLabel
        Left = 705
        Top = 42
        Caption = #304#351'lem No'
        Transparent = True
      end
      object EditIslemNo: TcxTextEdit
        Left = 759
        Top = 38
        TabOrder = 8
        OnKeyUp = EditKaynakKodKeyUp
        Width = 100
      end
      object cxLabel7: TcxLabel
        Left = 507
        Top = 42
        Caption = #304#351'lem Tarihi'
        Transparent = True
      end
    end
    object Label35: TcxLabel
      Left = 617
      Top = 40
      Caption = #304#351'lem Tarihi'
    end
  end
  object KasaQuery: TFDQuery
    Connection = Tablo.FDCnn
    Left = 907
    Top = 318
  end
  object dsKasaQuery: TDataSource
    AutoEdit = False
    DataSet = KasaQuery
    Left = 875
    Top = 262
  end
  object VirmanNereyeQuery: TFDQuery
    AfterScroll = VirmanNereyeQueryAfterScroll
    Connection = Tablo.FDCnn
    Left = 748
    Top = 202
  end
  object dsKurNereyeQuery: TDataSource
    AutoEdit = False
    DataSet = VirmanNereyeQuery
    Left = 303
    Top = 1
  end
  object dsCekSenet: TDataSource
    DataSet = CekSenetKrediQuery
    Left = 132
    Top = 378
  end
  object CekSenetKrediQuery: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @KrediDurum smallint'
      'declare @KrediKodu varchar(20)'
      'declare @KrediAdi varchar(50)'
      ''
      'set @KrediDurum =:PKrediDurum'
      'set @KrediKodu = :PKrediKodu'
      'set @KrediAdi = :PKrediAdi'
      ''
      'select '
      #9'KOD='#39'K'#39'+convert(varchar(10),ID),'
      #9'ROOTKOD='#39'0'#39','
      #9'ADI,'
      #9'TARIH=ALINISTARIHI,'
      #9'TUTAR=TUTARI,'
      #9'ODENEN='#39'-'#39','
      #9'BAKIYE='#39'-'#39','
      #9'KALANFAIZ='#39'-'#39','
      #9'KUR=ISNULL(KUR,'#39'TL'#39'),'
      #9'ACIKLAMA=ADI,'
      #9'ODENMIS=0,'
      #9'GENELKREDITIPI,'
      #9'KASAYA_DETAYLI,'
      #9'MASRAFID,'
      #9'KREDIID=ID,'
      #9'DETAYID=-1,'
      #9'BANKATICARIHESAPID'
      'from  KREDILER K'
      'where '
      #9'1 = case '
      'when @KrediDurum = 2 then 1 '
      'when @KrediDurum = 1 and K.DURUM=@KrediDurum then 1  '
      'when @KrediDurum = 0 and K.DURUM=@KrediDurum then 1 '
      'else 0 end'
      #9'AND K.KREDIKODU like '#39'%'#39'+@KrediKodu+'#39'%'#39
      #9'AND K.ADI like '#39'%'#39'+@KrediAdi+'#39'%'#39
      '--SELECT * FROM KREDILER'#9
      'union all'
      ''
      'SELECT  '
      #9'KOD='#39'D'#39'+convert(varchar(10),KR.ID),'
      #9'ROOTKOD='#39'K'#39'+convert(varchar(10),K.ID),'
      #9'K.ADI, TARIH,TUTAR,'
      #9'ODENEN=(select isnull(SUM(ODENEN),0.0) '
      #9#9'from KREDIROTATIF KRT '
      #9#9'where KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
      #9'BAKIYE=TUTAR-(select isnull(SUM(ODENEN),0.0) '
      #9#9'from KREDIROTATIF KRT '
      #9#9'where KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
      #9'KALANFAIZ=(select isnull(SUM(TOPLAM-ODENENFAIZ),0.0) '
      #9#9'from KREDIROTATIF KRT '
      #9#9'where KR.KREDIREFERANSNO=KRT.KREDIREFERANSNO),'
      #9'K.KUR,ACIKLAMA,ODENMIS,GENELKREDITIPI,KASAYA_DETAYLI, '
      #9'MASRAFID, K.ID as KREDIID,KR.ID AS '
      #9'DETAYID,BANKATICARIHESAPID'
      '  FROM KREDILER K '
      '      INNER JOIN KREDIROTATIF KR ON '
      'K.ID=KR.KREDIID'
      'where TUTAR>0 '
      ' and ODENMIS = 0'
      ' and '#9'1 = case '
      'when @KrediDurum = 2 then 1 '
      'when @KrediDurum = 1 and K.DURUM=@KrediDurum then 1  '
      'when @KrediDurum = 0 and K.DURUM=@KrediDurum then 1 '
      'else 0 end'
      ' AND K.KREDIKODU like '#39'%'#39'+@KrediKodu+'#39'%'#39
      ' AND K.ADI like '#39'%'#39'+@KrediAdi+'#39'%'#39
      ' '
      'union all'
      ''
      'SELECT '
      #9'KOD='#39'D'#39'+convert(varchar(10),KO.ID),'
      #9'ROOTKOD='#39'K'#39'+convert(varchar(10),K.ID),'
      #9'K.ADI,TARIH,K.TAKSIT,ODENEN=0,BAKIYE  '
      #9',KALANFAIZ=0,K.KUR,ACIKLAMA,ODENMIS,GENELKREDITIPI'
      #9', KASAYA_DETAYLI, '
      #9'MASRAFID, K.ID as KREDIID,KO.ID AS '
      #9'DETAYID,BANKATICARIHESAPID '
      '  FROM KREDILER K '
      '       INNER JOIN PLANKREDI KO ON K.ID=KO.KREDIID '
      '       --INNER JOIN BANKAHESAPLAR BH on '
      '       --BH.ID = K.BANKATICARIHESAPID'
      'where K.TAKSIT>0 '
      ' and ODENMIS = 0'
      ' and '#9'1 = case '
      'when @KrediDurum = 2 then 1 '
      'when @KrediDurum = 1 and K.DURUM=@KrediDurum then 1  '
      'when @KrediDurum = 0 and K.DURUM=@KrediDurum then 1 '
      'else 0 end'
      ' AND K.KREDIKODU like '#39'%'#39'+@KrediKodu+'#39'%'#39
      ' AND K.ADI like '#39'%'#39'+@KrediAdi+'#39'%'#39
      ''
      '')
    Left = 367
    Top = 442
  end
  object DtsOdemeTakvimi: TDataSource
    DataSet = TabOdemeTakvimi
    Left = 114
    Top = 433
  end
  object TabOdemeTakvimi: TFDQuery
    Connection = Tablo.FDCnn
    Left = 18
    Top = 440
  end
  object TabTakvimFat: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ID,TUR,TARIH,REHBERID,ACIKLAMA,HESAPID=null,'
      'FATURA_TUTARI as TUTAR,KUR,FATURAID=ID,DURUM,MASRAFID'
      'from FATBASLIK  '
      'where REHBERID = :pRId2 '
      'and TUR between :P2 and :P3'
      'and durum <= 1'
      'order by 3 desc')
    Left = 921
    Top = 264
  end
  object DtsTakvimFat: TDataSource
    DataSet = TabTakvimFat
    Left = 362
    Top = 296
  end
  object TabDuzenliOdeme: TFDQuery
    Connection = Tablo.FDCnn
    Left = 818
    Top = 172
  end
  object TabTakvimPlan: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select ID,TUR,PLANTARIHI as TARIH,REHBERID,ACIKLAMA,HESAPID,'
      '   TUTAR = case when TUR =61 then BORC else ALACAK   end,'
      '   KUR,FATURAID,DURUM,MASRAFID'
      'from KASA'
      'where REHBERID = :pRId1 '
      'and TUR between :P2 and :P3'
      'order by 3')
    Left = 856
    Top = 172
  end
  object DtsTakvimPlan: TDataSource
    DataSet = TabTakvimPlan
    Left = 350
    Top = 371
  end
  object dsVirmanNerdenQuery: TDataSource
    AutoEdit = False
    DataSet = VirmanNerdenQuery
    Left = 432
    Top = 65533
  end
  object VirmanNerdenQuery: TFDQuery
    Connection = Tablo.FDCnn
    Left = 918
    Top = 174
  end
  object DtsAvansTakvimi: TDataSource
    DataSet = TabAvansTakvimi
    Left = 565
    Top = 409
  end
  object TabAvansTakvimi: TFDQuery
    Connection = Tablo.FDCnn
    Left = 465
    Top = 410
  end
end
