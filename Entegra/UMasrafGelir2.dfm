object MasrafGelirDlg: TMasrafGelirDlg
  Left = 0
  Top = 0
<<<<<<< .mine
  Width = 1003
  Height = 426
=======
  Width = 451
  Height = 304
>>>>>>> .r51
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
<<<<<<< .mine
    Width = 997
=======
    Width = 445
    Height = 29
>>>>>>> .r51
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 207
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
  end
  object Panel5: TPanel
    Left = 373
<<<<<<< .mine
    Top = 35
    Width = 630
    Height = 391
=======
    Top = 32
    Width = 78
    Height = 272
>>>>>>> .r51
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 1
    object cxGrid1: TcxGrid
      Left = 6
      Top = 244
<<<<<<< .mine
      Width = 618
      Height = 141
=======
      Width = 66
      Height = 22
>>>>>>> .r51
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
<<<<<<< .mine
      ExplicitTop = 370
      ExplicitWidth = 66
=======
>>>>>>> .r51
      ExplicitHeight = 19
      object cxGridDBTableView1: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = DtsButce
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
            FieldName = 'PLANLANAN'
            Column = cxGridDBTableView1PLANLANAN
          end
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
            FieldName = 'GERCEKLESEN'
            Column = cxGridDBTableView1GERCEKLESEN
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object cxGridDBTableView1AY: TcxGridDBColumn
          Caption = 'Ay'
          DataBinding.FieldName = 'AY'
          Options.Editing = False
          Width = 51
        end
        object cxGridDBTableView1PLANLANAN: TcxGridDBColumn
          Caption = 'Planlanan'
          DataBinding.FieldName = 'PLANLANAN'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Width = 72
        end
        object cxGridDBTableView1GERCEKLESEN: TcxGridDBColumn
          Caption = 'Ger'#231'ekle'#351'en'
          DataBinding.FieldName = 'GERCEKLESEN'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Options.Editing = False
          Width = 70
        end
        object cxGridDBTableView1GECMESIN: TcxGridDBColumn
          Caption = 'Ge'#231'mesin'
          DataBinding.FieldName = 'GECMESIN'
          Width = 61
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = cxGridDBTableView1
      end
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 9
      Top = 220
<<<<<<< .mine
      Width = 612
=======
      Width = 60
>>>>>>> .r51
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 71
      Caption = 'AletCubugu'
      Color = clTeal
      DockSite = True
      DrawingStyle = dsGradient
      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
      EdgeInner = esLowered
      EdgeOuter = esNone
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      Images = AnaForm.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      ExplicitHeight = 150
      object ButceSilTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = ButceSilTusClick
      end
      object ButceKaydetTus: TToolButton
        Left = 71
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
        OnClick = ButceKaydetTusClick
      end
      object ButceIptalTus: TToolButton
        Left = 142
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
        OnClick = ButceIptalTusClick
      end
      object ToolButton1: TToolButton
        Left = 213
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object GirisTus: TToolButton
        Left = 221
        Top = 0
        Caption = 'Giri'#351' Yap'
        ImageIndex = 4
        OnClick = GirisTusClick
      end
      object ToolButton2: TToolButton
        Left = 292
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object YenileTus: TToolButton
        Left = 300
        Top = 0
        Caption = 'Yenile'
        ImageIndex = 6
        OnClick = YenileTusClick
      end
      object ButceEkleTus: TToolButton
        Left = 371
        Top = 0
        Visible = False
      end
    end
    object Panel3: TPanel
      Left = 6
      Top = 6
<<<<<<< .mine
      Width = 618
=======
      Width = 66
>>>>>>> .r51
      Height = 211
      Align = alTop
      TabOrder = 2
      object Label2: TLabel
        Left = 63
        Top = 58
        Width = 18
        Height = 13
        Caption = 'Kod'
      end
      object Label3: TLabel
        Left = 68
        Top = 83
        Width = 13
        Height = 13
        Caption = 'Ad'
      end
      object Label4: TLabel
        Left = 32
        Top = 110
        Width = 49
        Height = 13
        Caption = 'Para Birimi'
      end
      object Label6: TLabel
        Left = 40
        Top = 135
        Width = 41
        Height = 13
        Caption = 'A'#231#305'klama'
      end
      object Label7: TLabel
        Left = 211
        Top = 19
        Width = 31
        Height = 13
        Caption = 'Durum'
      end
      object Label8: TLabel
        Left = 39
        Top = 160
        Width = 42
        Height = 13
        Caption = #214'zel Kod'
      end
      object Label9: TLabel
        Left = 31
        Top = 185
        Width = 50
        Height = 13
        Caption = 'Yetki Kodu'
      end
      object DBText1: TDBText
        Left = 87
        Top = 38
        Width = 65
        Height = 17
        DataField = 'ID'
        DataSource = DtsMasrafGelir
      end
      object Label13: TLabel
        Left = 70
        Top = 38
        Width = 11
        Height = 13
        Caption = 'ID'
      end
      object Label5: TLabel
        Left = 192
        Top = 107
        Width = 29
        Height = 13
        Caption = 'Grubu'
      end
      object EditKASAKODU: TDBEdit
        Left = 87
        Top = 56
        Width = 121
        Height = 21
        Ctl3D = True
        DataField = 'KOD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 0
        OnClick = EditKASAKODUClick
      end
      object EditKASAADI: TDBEdit
        Left = 87
        Top = 81
        Width = 225
        Height = 21
        Ctl3D = True
        DataField = 'AD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 1
      end
      object ComboKUR: TDBComboBox
        Left = 87
        Top = 106
        Width = 65
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        DataField = 'KUR'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 2
      end
      object EditHESAPACIKLAMA: TDBEdit
        Left = 87
        Top = 133
        Width = 225
        Height = 21
        Ctl3D = True
        DataField = 'ACIKLAMA'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 4
      end
      object EditOZELKOD: TDBEdit
        Left = 87
        Top = 158
        Width = 121
        Height = 21
        Ctl3D = True
        DataField = 'OZELKOD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 5
      end
      object EditYETKIKODU: TDBEdit
        Left = 87
        Top = 183
        Width = 121
        Height = 21
        Ctl3D = True
        DataField = 'YETKIKODU'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 6
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 248
        Top = 16
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = True
          end
          item
            Description = 'Pasif'
            Value = False
          end>
        Style.BorderStyle = ebs3D
        TabOrder = 7
        Width = 76
      end
      object DBComboBox1: TDBComboBox
        Left = 224
        Top = 104
        Width = 90
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        DataField = 'GRUBU'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 3
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 32
    Width = 373
<<<<<<< .mine
    Height = 391
=======
    Height = 272
>>>>>>> .r51
    Align = alLeft
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 2
    ExplicitTop = 35
    ExplicitHeight = 269
    object Panel1: TPanel
      Left = 6
      Top = 6
      Width = 361
      Height = 27
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 5
        Width = 17
        Height = 13
        Caption = 'Ara'
      end
      object ToolBar1: TToolBar
        Left = 394
        Top = 12
        Width = 90
        Height = 26
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 83
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esNone
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
      end
      object btnSil: TcxButton
        Left = 220
        Top = 2
        Width = 21
        Height = 19
        Caption = #209
        TabOrder = 1
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Wingdings 2'
        Font.Style = []
        ParentFont = False
        OnClick = btnSilClick
      end
      object AraKod: TcxTextEdit
        Left = 39
        Top = 3
        TabOrder = 2
        OnKeyUp = AraKodKeyUp
        Width = 175
      end
    end
    object DBGrid1: TcxGrid
      Left = 6
      Top = 33
      Width = 361
      Height = 352
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      ExplicitHeight = 230
      object DBGrid1DBTableView1: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = DtsMasrafGelir
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Editing = False
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object DBGrid1DBTableView1KOD1: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Width = 70
        end
        object DBGrid1DBTableView1AD1: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'AD'
          Width = 112
        end
        object DBGrid1DBTableView1KUR1: TcxGridDBColumn
          Caption = 'P.Birimi'
          DataBinding.FieldName = 'KUR'
          Width = 42
        end
      end
      object DBGrid1Level1: TcxGridLevel
        GridView = DBGrid1DBTableView1
      end
    end
  end
  object TabMasrafGelir: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabMasrafGelirAfterScroll
    OnNewRecord = TabMasrafGelirNewRecord
    ParamData = <
      item
        Name = 'tur'
        DataType = ftBoolean
        NumericScale = 255
        Precision = 255
        Size = 2
        Value = Null
      end>
    SQL.Strings = (
      'select * from MASRAFGELIR where TUR =:tur order by KOD')
    Left = 180
    Top = 97
  end
  object DtsMasrafGelir: TDataSource
    DataSet = TabMasrafGelir
    OnStateChange = DtsMasrafGelirStateChange
    Left = 96
    Top = 97
  end
  object PopupMenu1: TPopupMenu
    Left = 64
    Top = 155
    object KasaYenileMenu: TMenuItem
      Caption = 'Sadece Bu Kasan'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object BtnKasalarnToplamlarnYenile1: TMenuItem
      Caption = 'B'#252't'#252'n Kasalar'#305'n Toplamlar'#305'n'#305' Yenile'
    end
  end
  object frxMasrafGelir: TfrxDBDataset
    UserName = 'MASRAFGELIR'
    CloseDataSource = False
    BCDToCurrency = False
    Left = 12
    Top = 98
  end
  object TabButce: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabButceBeforePost
    OnNewRecord = TabButceNewRecord
    ParamData = <
      item
        Name = 'Prm1'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end>
    SQL.Strings = (
      'select * from BUTCE where MASRAFID =:Prm1 order by AY')
    Left = 49
    Top = 267
  end
  object DtsButce: TDataSource
    DataSet = TabButce
    OnStateChange = DtsButceStateChange
    Left = 103
    Top = 268
  end
end

