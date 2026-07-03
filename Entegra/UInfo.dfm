object InfoDlg: TInfoDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSizeable
  Caption = 'info'
  ClientHeight = 398
  ClientWidth = 920
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 35
    Width = 920
    Height = 363
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 359
    ClientRectLeft = 4
    ClientRectRight = 916
    ClientRectTop = 26
    object cxTabSheet1: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 0
      object PanelUst: TPanel
        Left = 0
        Top = 0
        Width = 912
        Height = 66
        Align = alTop
        TabOrder = 0
        object DateTarihBas: TcxDateEdit
          Left = 4
          Top = 19
          Properties.SaveTime = False
          StyleDisabled.Color = clWhite
          StyleDisabled.TextColor = clBtnText
          TabOrder = 0
          Width = 90
        end
        object cxLabel1: TcxLabel
          Left = 571
          Top = 2
          Caption = 'Kullan'#305'c'#305
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 296
          Top = 2
          Caption = 'B'#246'l'#252'm'
          ParentFont = False
          Transparent = True
        end
        object CheckEkleme: TcxCheckBox
          Left = 202
          Top = 2
          Caption = 'Ekleme'
          ParentFont = False
          Style.TransparentBorder = False
          TabOrder = 3
          Transparent = True
        end
        object CheckDegistirme: TcxCheckBox
          Left = 202
          Top = 23
          Caption = 'De'#287'i'#351'tirme'
          ParentFont = False
          Style.TransparentBorder = False
          TabOrder = 4
          Transparent = True
        end
        object CheckSilme: TcxCheckBox
          Left = 202
          Top = 44
          Caption = 'Silme'
          ParentFont = False
          Style.TransparentBorder = False
          TabOrder = 5
          Transparent = True
        end
        object cxLabel7: TcxLabel
          Left = 471
          Top = 2
          Caption = 'Kay'#305't No'
          Transparent = True
        end
        object EditKayitNo: TcxButtonEdit
          Left = 471
          Top = 19
          Properties.Buttons = <
            item
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          TabOrder = 6
          Width = 94
        end
        object txtTablo: TcxComboBox
          Left = 296
          Top = 19
          Properties.DropDownListStyle = lsFixedList
          TabOrder = 2
          Width = 169
        end
        object Kullanici: TcxButtonEdit
          Left = 571
          Top = 19
          Properties.Alignment.Horz = taLeftJustify
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = False
          TabOrder = 1
          Width = 179
        end
        object txtAlan: TcxButtonEdit
          Left = 756
          Top = 19
          Properties.Buttons = <
            item
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          TabOrder = 7
          Width = 141
        end
        object cxLabel4: TcxLabel
          Left = 756
          Top = 0
          Caption = 'Bilgisayar'
          ParentFont = False
          Transparent = True
        end
        object cxLabel3: TcxLabel
          Left = 4
          Top = 2
          Caption = 'Ba'#351'lama'
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 96
          Top = 2
          Caption = 'Biti'#351
          Transparent = True
        end
        object DateTarihBit: TcxDateEdit
          Left = 96
          Top = 19
          Properties.SaveTime = False
          StyleDisabled.Color = clWhite
          StyleDisabled.TextColor = clBtnText
          TabOrder = 13
          Width = 90
        end
      end
      object GridLOG: TcxGrid
        Left = 0
        Top = 66
        Width = 912
        Height = 267
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridLOGView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCustomDrawCell = GridLOGViewCustomDrawCell
          DataController.DataSource = DsTabLog
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = 'Kay'#305't: 0'
              Kind = skCount
              Column = GridLOGViewTARIH
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.Editing = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridLOGViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 130
          end
          object GridLOGViewISLEM: TcxGridDBColumn
            Caption = #304#351'lem'
            DataBinding.FieldName = 'ISLEM'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 90
          end
          object GridLOGViewTABLO: TcxGridDBColumn
            Caption = 'B'#246'l'#252'm'
            DataBinding.FieldName = 'ANAHTAR'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 150
          end
          object GridLOGViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 100
          end
          object GridLOGViewAD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 180
          end
          object GridLOGViewSATIRID: TcxGridDBColumn
            Caption = 'Kay'#305't'
            DataBinding.FieldName = 'KAYITNO'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 80
          end
          object GridLOGViewFIRMA: TcxGridDBColumn
            Caption = 'Kullan'#305'c'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 160
          end
          object GridLOGViewPCADI: TcxGridDBColumn
            Caption = 'Bilgisayar'
            DataBinding.FieldName = 'PCADI'
            DataBinding.IsNullValueType = True
            Width = 120
          end
          object GridLOGViewISLEMTIPI: TcxGridDBColumn
            DataBinding.FieldName = 'ISLEMTIPI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object GridLOGLevel1: TcxGridLevel
          GridView = GridLOGView
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 1
      object LvGecmis: TListView
        Left = 0
        Top = 73
        Width = 270
        Height = 260
        Align = alLeft
        Columns = <>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnCustomDrawItem = LvGecmisCustomDrawItem
        OnSelectItem = LvGecmisSelectItem
      end
      object LvDetay: TListView
        Left = 270
        Top = 73
        Width = 642
        Height = 260
        Align = alClient
        Columns = <>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 912
        Height = 73
        Align = alTop
        TabOrder = 2
        object Label1: TLabel
          Left = 8
          Top = 13
          Width = 40
          Height = 15
          Caption = 'Ekleyen'
        end
        object Label2: TLabel
          Left = 232
          Top = 13
          Width = 69
          Height = 15
          Caption = 'Ekleme Tarihi'
        end
        object Label3: TLabel
          Left = 8
          Top = 45
          Width = 53
          Height = 15
          Caption = 'De'#287'i'#351'tiren'
        end
        object Label4: TLabel
          Left = 232
          Top = 45
          Width = 88
          Height = 15
          Caption = 'De'#287'i'#351'tirme Tarihi'
        end
        object EditEkleyen: TcxTextEdit
          Left = 72
          Top = 10
          Enabled = False
          Properties.ReadOnly = True
          TabOrder = 0
          Width = 154
        end
        object EditEklemeTrh: TcxDateEdit
          Left = 327
          Top = 10
          Enabled = False
          Properties.ReadOnly = True
          TabOrder = 1
          Width = 121
        end
        object EditDegistiren: TcxTextEdit
          Left = 72
          Top = 39
          Enabled = False
          Properties.ReadOnly = True
          TabOrder = 2
          Width = 154
        end
        object EditDegistirmeTrh: TcxDateEdit
          Left = 327
          Top = 39
          Enabled = False
          Properties.ReadOnly = True
          TabOrder = 3
          Width = 121
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 920
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = -6
    object cxButton1: TcxButton
      Left = 818
      Top = 6
      Width = 98
      Height = 29
      Align = alCustom
      Cancel = True
      Caption = 'Tamam'
      ModalResult = 1
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
        462D38223F3E0D0A3C7376672076657273696F6E3D22312E31222069643D224C
        61796572312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
        323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
        772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
        307078222076696577426F783D2230203020333220333222207374796C653D22
        656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
        2220786D6C3A73706163653D227072657365727665223E262331333B26233130
        3B20203C7374796C6520747970653D22746578742F6373732220786D6C3A7370
        6163653D227072657365727665223E2E426C61636B262331333B262331303B20
        2020207B262331333B262331303B20202020202066696C6C3A23373237323732
        3B262331333B262331303B202020202020666F6E742D66616D696C793A266170
        6F733B64782D666F6E742D69636F6E732661706F733B3B262331333B26233130
        3B202020202020666F6E742D73697A653A333270783B262331333B262331303B
        202020207D262331333B262331303B20203C2F7374796C653E0D0A3C74657874
        20783D22302220793D2233322220636C6173733D22426C61636B223EEE9C913C
        2F746578743E0D0A3C2F7376673E0D0A}
      OptionsImage.ImageIndex = 0
      PaintStyle = bpsCaption
      TabOrder = 0
    end
    object cxLabel8: TcxLabel
      Left = 9
      Top = 6
      Caption = 'Ad/'#304#231'erik ARA'
      Transparent = True
    end
    object EditIcerik: TcxButtonEdit
      Left = 100
      Top = 6
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 369
    end
    object CheckIcerik: TcxCheckBox
      Left = 478
      Top = 8
      Caption = #$0130#$00E7'erikten Ara'
      ParentFont = False
      Style.TransparentBorder = False
      TabOrder = 3
      Transparent = True
    end
  end
  object TabLog: TFDQuery
    Connection = Tablo.FDCnn
    Left = 24
    Top = 120
  end
  object DsTabLog: TDataSource
    DataSet = TabLog
    Left = 272
    Top = 152
  end
end
