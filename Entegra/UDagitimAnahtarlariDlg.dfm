object DagitimAnahtarlariDlg: TDagitimAnahtarlariDlg
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 29
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
    object ToolButton5: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 215
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 32
    Width = 451
    Height = 272
    Align = alClient
    TabOrder = 1
    object ScrollBox1: TScrollBox
      Left = 209
      Top = 1
      Width = 241
      Height = 270
      Align = alClient
      TabOrder = 0
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 237
        Height = 83
        Align = alTop
        TabOrder = 0
        object Label2: TcxLabel
          Left = 27
          Top = 18
          Caption = 'Da'#287#305't'#305'm anahtar'#305' Kodu'
          FocusControl = EditKOD
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
          Left = 27
          Top = 45
          Caption = 'Da'#287#305't'#305'm anahtar'#305' Ad'#305
          FocusControl = EditAD
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label23: TcxLabel
          Left = 413
          Top = 44
          Caption = 'Ba'#351'lama tarihi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object DBEdit1: TcxDBLabel
          Left = 314
          Top = 18
          DataBinding.DataField = 'ID'
          DataBinding.DataSource = DtsTabDagitim
          Transparent = True
          Height = 21
          Width = 47
        end
        object EditKOD: TcxDBTextEdit
          Left = 166
          Top = 18
          DataBinding.DataField = 'KOD'
          DataBinding.DataSource = DtsTabDagitim
          TabOrder = 4
          Width = 104
        end
        object EditAD: TcxDBTextEdit
          Left = 166
          Top = 45
          DataBinding.DataField = 'AD'
          DataBinding.DataSource = DtsTabDagitim
          TabOrder = 5
          Width = 209
        end
        object DateBaslamaTarihi: TcxDBDateEdit
          Left = 505
          Top = 44
          DataBinding.DataField = 'BASLAMATARIHI'
          DataBinding.DataSource = DtsTabDagitim
          TabOrder = 6
          Width = 172
        end
        object LblSube: TcxLabel
          Left = 413
          Top = 19
          Caption = #350'ube'
          Transparent = True
        end
        object ComboSube: TcxDBImageComboBox
          Left = 505
          Top = 18
          RepositoryItem = Tablo.RepSubelerKendiSubesi
          DataBinding.DataField = 'SUBEID'
          DataBinding.DataSource = DtsTabDagitim
          Properties.Alignment.Horz = taLeftJustify
          Properties.Items = <
            item
              Description = 'Yeni'
              ImageIndex = 0
              Value = 4
            end
            item
              Description = 'Zimmet'
              Value = 1
            end
            item
              Description = 'Kay'#305'p'
              Value = 2
            end
            item
              Description = 'Hurda'
              Value = 3
            end
            item
              Description = 'Transfer'
              Value = 5
            end
            item
              Description = 'Bo'#351
              Value = 9
            end
            item
              Description = 'Serviste'
              Value = 6
            end
            item
              Description = 'Servis '#304'ade'
              Value = 7
            end>
          StyleDisabled.Color = clWhite
          StyleDisabled.TextColor = clBlack
          TabOrder = 8
          Width = 172
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 83
        Width = 237
        Height = 183
        Align = alClient
        TabOrder = 1
        ExplicitHeight = 180
        object GridDagitim: TcxGrid
          Left = 1
          Top = 28
          Width = 780
          Height = 444
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          ExplicitWidth = 235
          ExplicitHeight = 151
          object GridDagitimDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = DtsTabDagitimDetay
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.AlwaysShowEditor = True
            OptionsBehavior.FocusCellOnTab = True
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridDagitimDBTVMASRAFADI: TcxGridDBColumn
              Caption = 'Masraf Merkezi'
              DataBinding.FieldName = 'MASRAF'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.OnButtonClick = GridDagitimDBTVMASRAFKODUPropertiesButtonClick
              Width = 126
            end
            object GridDagitimDBTVMERKEZADI: TcxGridDBColumn
              Caption = 'Sorumluluk Merkezi'
              DataBinding.FieldName = 'MERKEZ'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.OnButtonClick = GridDagitimDBTVMERKEZADIPropertiesButtonClick
              Width = 167
            end
            object GridDagitimDBTVPUAN: TcxGridDBColumn
              Caption = 'Puan'
              DataBinding.FieldName = 'PUAN'
            end
          end
          object GridDagitimLevel1: TcxGridLevel
            GridView = GridDagitimDBTableView1
          end
        end
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 774
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 62
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
          Font.Name = 'Trebuchet MS'
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
          ExplicitWidth = 229
          ExplicitHeight = 46
          object SatirEkle: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            OnClick = SatirEkleClick
          end
          object SatirSil: TToolButton
            Left = 62
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            OnClick = SatirSilClick
          end
          object ToolButton1: TToolButton
            Left = 124
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            OnClick = ToolButton1Click
          end
          object ToolButton2: TToolButton
            Left = 186
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            OnClick = ToolButton2Click
          end
        end
      end
    end
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 208
      Height = 270
      Align = alLeft
      TabOrder = 1
      ExplicitHeight = 267
      object cxGrid1DBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.First.Visible = True
        Navigator.Buttons.PriorPage.Visible = True
        Navigator.Buttons.Prior.Visible = True
        Navigator.Buttons.Next.Visible = True
        Navigator.Buttons.NextPage.Visible = True
        Navigator.Buttons.Last.Visible = True
        Navigator.Buttons.Insert.Visible = True
        Navigator.Buttons.Append.Visible = False
        Navigator.Buttons.Delete.Visible = True
        Navigator.Buttons.Edit.Visible = True
        Navigator.Buttons.Post.Visible = True
        Navigator.Buttons.Cancel.Visible = True
        Navigator.Buttons.Refresh.Visible = True
        Navigator.Buttons.SaveBookmark.Visible = True
        Navigator.Buttons.GotoBookmark.Visible = True
        Navigator.Buttons.Filter.Visible = True
        DataController.DataSource = DtsTabDagitim
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnCycle = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.InvertSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        object cxGrid1DBTableView1Column1: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
        end
        object cxGrid1DBTableView1Column2: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'AD'
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = cxGrid1DBTableView1
      end
    end
  end
  object TabDagitim: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabDagitimBeforePost
    AfterScroll = TabDagitimAfterScroll
    OnNewRecord = TabDagitimNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from DAGITIM Where GELIRMI =:Par1')
    Left = 680
    Top = 198
  end
  object DtsTabDagitim: TDataSource
    DataSet = TabDagitim
    OnStateChange = DtsTabDagitimStateChange
    Left = 734
    Top = 222
  end
  object DtsTabDagitimDetay: TDataSource
    DataSet = TabDagitimDetay
    OnStateChange = DtsTabDagitimDetayStateChange
    Left = 742
    Top = 310
  end
  object TabDagitimDetay: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabDagitimDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *,'
      
        #9'MASRAF=ISNULL((select KOD+'#39' / '#39'+AD from MASRAFGELIR where ID=DD' +
        '.MASRAFID),'#39#39'),'
      
        #9'MERKEZ=ISNULL((select MERKEZKODU+'#39' / '#39'+MERKEZADI from SRMMERKEZ' +
        'I where ID=DD.MERKEZID),'#39#39')'
      ' from DAGITIMDETAY DD  where DAGITIMID= :Par and GELIRMI = :Par2')
    Left = 680
    Top = 278
  end
end

