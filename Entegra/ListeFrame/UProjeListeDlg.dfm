object ProjeListeDlg: TProjeListeDlg
  Left = 0
  Top = 0
  Width = 976
  Height = 525
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 970
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 83
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 83
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 166
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 174
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = GorTusClick
    end
    object ToolButton2: TToolButton
      Left = 257
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 265
      Top = 0
      Caption = 'YaziciYaz'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 233
    Width = 976
    Height = 292
    Align = alBottom
    TabOrder = 3
    object PageControlSekme: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 1
      Top = 1
      Width = 974
      Height = 290
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = TabSheetGorevler
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControlSekmeChange
      ClientRectBottom = 286
      ClientRectLeft = 4
      ClientRectRight = 970
      ClientRectTop = 27
      object TabSheetGorevler: TcxTabSheet
        Caption = #304#351' Listesi'
        ImageIndex = 54
        object TreeListGorev: TcxDBTreeList
          Left = 0
          Top = 41
          Width = 966
          Height = 218
          Align = alClient
          Bands = <
            item
            end>
          DataController.DataSource = DtsGorevler
          DataController.ParentField = 'BAGIDUST'
          DataController.KeyField = 'ID'
          DragMode = dmAutomatic
          Images = Tablo.KlasorResimleri
          LookAndFeel.ScrollbarMode = sbmClassic
          Navigator.Buttons.CustomButtons = <>
          OptionsCustomizing.ColumnsQuickCustomization = True
          OptionsData.Editing = False
          OptionsData.Deleting = False
          OptionsSelection.MultiSelect = True
          OptionsView.GridLines = tlglBoth
          OptionsView.Indicator = True
          OptionsView.TreeLineStyle = tllsNone
          PopupMenu = GorevlerMenu
          PopupMenus.ColumnHeaderMenu.PopupMenu = AnaForm.PopupMenuTree
          RootValue = -1
          ScrollbarAnnotations.CustomAnnotations = <>
          TabOrder = 0
          OnClick = TreeListGorevClick
          OnDblClick = TreeListGorevDblClick
          object TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn
            Visible = False
            DataBinding.FieldName = 'ID'
            Width = 100
            Position.ColIndex = 8
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn
            Tag = 1
            PropertiesClassName = 'TcxCheckBoxProperties'
            Caption.Glyph.SourceDPI = 96
            Caption.Glyph.Data = {
              424D360400000000000036000000280000001000000010000000010020000000
              000000000000C40E0000C40E0000000000000000000000000000000000000000
              000000000002000000070000000C0000001000000012000000110000000E0000
              0008000000020000000000000000000000000000000000000000000000010000
              0004000101120D2A1D79184E36C6216B4BFF216B4BFF216C4BFF1A533AD20F2F
              218400010115000000050000000100000000000000000000000000000005050F
              0A351C5B40DC24805CFF29AC7EFF2CC592FF2DC894FF2DC693FF2AAE80FF2585
              60FF1A563DD405110C3D00000007000000010000000000000003040E0A312065
              48ED299D74FF2FC896FF2EC996FF56D4ACFF68DAB5FF3BCD9DFF30C996FF32CA
              99FF2BA479FF227050F805110C3D00000005000000000000000A1A573DD02EA5
              7CFF33CA99FF2EC896FF4CD2A8FF20835CFF00673BFF45BE96FF31CB99FF31CB
              98FF34CC9CFF31AD83FF1B5C41D300010113000000020B23185E2E8A66FF3BCD
              9EFF30CA97FF4BD3A9FF349571FF87AF9DFFB1CFC1FF238A60FF45D3A8FF36CF
              9FFF33CD9BFF3ED0A3FF319470FF0F32237F00000007184D37B63DB38CFF39CD
              9FFF4BD5A9FF43A382FF699782FFF8F1EEFFF9F3EEFF357F5DFF56C4A1FF43D5
              A8FF3ED3A4FF3CD1A4FF41BC95FF1B5C43CD0000000B1C6446DF4BCAA4FF44D2
              A8FF4FB392FF4E826AFFF0E9E6FFC0C3B5FFEFE3DDFFCEDDD4FF1B754FFF60DC
              B8FF48D8ACFF47D6AAFF51D4ACFF247A58F80000000E217050F266D9B8FF46D3
              A8FF0B6741FFD2D2CBFF6A8F77FF116B43FF73967EFFF1E8E3FF72A28BFF46A6
              85FF5EDFBAFF4CD9AFFF6BE2C2FF278460FF020604191E684ADC78D9BEFF52DA
              B1FF3DBA92FF096941FF2F9C76FF57DEB8FF2D9973FF73967EFFF0EAE7FF4F88
              6CFF5ABB9AFF5BDEB9FF7FE2C7FF27835FF80000000C19523BAB77C8B0FF62E0
              BCFF56DDB7FF59DFBAFF5CE1BDFF5EE2BEFF5FE4C1FF288C67FF698E76FFE6E1
              DCFF176B47FF5FD8B4FF83D5BDFF1E674CC60000000909201747439C7BFF95EC
              D6FF5ADFBAFF5EE2BDFF61E4BFFF64E6C1FF67E6C5FF67E8C7FF39A17EFF1F6D
              4AFF288B64FF98EFD9FF4DAC8CFF1036286D00000004000000041C5F46B578C6
              ADFF9AEED9FF65E5C0FF64E7C3FF69E7C6FF6BE8C8FF6CE9C9FF6BEAC9FF5ED6
              B6FF97EDD7FF86D3BBFF237759D20102010C0000000100000001030A0718247B
              5BDA70C1A8FFB5F2E3FF98F0DAFF85EDD4FF75EBCEFF88EFD6FF9CF2DDFFBAF4
              E7FF78CDB3FF2A906DEA0615102E00000002000000000000000000000001030A
              07171E694FB844AB87FF85D2BBFFA8E6D6FFC5F4EBFFABE9D8FF89D8C1FF4BB6
              92FF237F60CB05130E2700000003000000000000000000000000000000000000
              0001000000030A241B411B60489D258464CF2C9D77EE258867CF1F7156B00E32
              26560000000600000002000000000000000000000000}
            Caption.ShowEndEllipsis = False
            Caption.Text = '*'
            DataBinding.FieldName = 'ACKAPA'
            Options.Editing = False
            Width = 61
            Position.ColIndex = 0
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn
            Caption.Text = 'L'#304'STE'
            DataBinding.FieldName = 'LISTEADI'
            Options.Editing = False
            Width = 62
            Position.ColIndex = 1
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn
            DataBinding.FieldName = 'KONUSU'
            Options.Editing = False
            Width = 139
            Position.ColIndex = 2
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn
            Caption.Text = 'T'#220'R'#220
            DataBinding.FieldName = 'TURU'
            Options.Editing = False
            Width = 65
            Position.ColIndex = 3
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListCARIAD: TcxDBTreeListColumn
            Caption.Text = 'CAR'#304' AD'
            DataBinding.FieldName = 'CARIAD'
            Options.Editing = False
            Width = 100
            Position.ColIndex = 4
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListATANAN1: TcxDBTreeListColumn
            Caption.Text = 'ATANAN'
            DataBinding.FieldName = 'ATANAN1'
            Options.Editing = False
            Width = 100
            Position.ColIndex = 5
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListTARIH: TcxDBTreeListColumn
            PropertiesClassName = 'TcxDateEditProperties'
            Caption.Text = 'TAR'#304'H'
            DataBinding.FieldName = 'BITISTARIHI'
            Options.Editing = False
            Width = 100
            Position.ColIndex = 6
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListNOTLAR_BIT: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.KlasorResimleri
            Properties.Items = <
              item
                Value = False
              end
              item
                ImageIndex = 27
                Value = True
              end>
            Caption.Glyph.SourceDPI = 96
            Caption.Glyph.Data = {
              424D360400000000000036000000280000001000000010000000010020000000
              000000000000C40E0000C40E0000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000200000
              002100000023000000240000002600000027000000290000002A0000002C0000
              002D0000002F0000003100000032000000340000000000000000000000140000
              00150000001600000017000000190000001A0000001B0000001D0000001E0000
              0020000000210000002300000024000000260000000000000000000000090000
              000A0000000B0000000C0000000E0000000F0000001000000011000000120000
              0014000000150000001600000017000000190000000000000000000000000000
              000000000000000000040000000F000000110000000B00000004000000010000
              0000000000000000000000000000000000000000000000000000402A1FFF402A
              1FFF3E291FFF0000000E421C11FF31140CE1190A0698030407420000000C0000
              0002000000000000000000000000000000000000000000000000422B20FF0000
              0000000000000000000D663C2BDCB9C7D2FF7889A2FF244182FF051033960000
              000F000000020000000000000000000000000000000000000000442D22FF0000
              0000000000000000000841261B91879AB2FFC8E3F5FF1F66B6FF2B6BA8FF0512
              36950000000E0000000200000000000000000000000000000000452E23FF0000
              000000000000000000031113163E488BC3FFDEFEFDFF51B4E3FF1F68B7FF3173
              AEFF061538940000000D00000002000000000000000000000000483022FF0000
              00000000000000000001000000081D44618D479FD2FFDEFEFDFF59BFE9FF216B
              B9FF367BB3FF07173A920000000C000000020000000000000000493224FF0000
              0000000000000000000000000001000000091D44618C4BA5D5FFDEFEFDFF61CA
              EFFF246FBCFF3B83B9FF08193D900000000A00000002000000004A3225FF0000
              000000000000000000000000000000000001000000081D44618A4EAAD7FFDEFE
              FDFF68D4F4FF2875BEFF3F8BBEFF091B3F8E00000006000000004C3426FF4B33
              26FF4B3225FF4A3225FF493225FF483124FF483124FF000000071C44618951AE
              DAFFDEFEFDFF6EDDF8FF2C7BC2FF18448BFF0000000800000000000000000000
              0000000000000000000000000000000000000000000000000001000000061D44
              618754B1DCFFDEFEFDFF4FA6D4FF112B4E880000000400000000000000000000
              0000000000000000000000000000000000000000000000000000000000010000
              00051D456185357FBCFF173A5986000000050000000100000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00010000000200000004000000030000000100000000}
            Caption.Text = 'N'
            DataBinding.FieldName = 'NOTLAR_BIT'
            Width = 22
            Position.ColIndex = 7
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListYORUM_BIT: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.KlasorResimleri
            Properties.Items = <
              item
                Value = False
              end
              item
                ImageIndex = 26
                Value = True
              end>
            Caption.Text = 'Y'
            DataBinding.FieldName = 'YORUM_BIT'
            Width = 22
            Position.ColIndex = 9
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListTEKRAR_BIT: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.KlasorResimleri
            Properties.Items = <
              item
                Value = False
              end
              item
                ImageIndex = 20
                Value = True
              end>
            Caption.Text = 'T'
            DataBinding.FieldName = 'TEKRAR_BIT'
            Width = 22
            Position.ColIndex = 10
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListANIMSAT_BIT: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.KlasorResimleri
            Properties.Items = <
              item
                Value = False
              end
              item
                ImageIndex = 23
                Value = True
              end>
            Caption.Text = 'A'
            DataBinding.FieldName = 'ANIMSAT_BIT'
            Width = 22
            Position.ColIndex = 11
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListBAYRAK: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.KlasorResimleri
            Properties.Items = <
              item
                Value = False
              end
              item
                ImageIndex = 21
                Value = True
              end>
            Caption.Text = 'B'
            DataBinding.FieldName = 'BAYRAK'
            Width = 22
            Position.ColIndex = 12
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListDURUM: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepGorevDurum
            DataBinding.FieldName = 'DURUM'
            Width = 100
            Position.ColIndex = 13
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn
            DataBinding.FieldName = 'PROJEKODU'
            Width = 100
            Position.ColIndex = 14
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn
            DataBinding.FieldName = 'EKLEYENAD'
            Width = 100
            Position.ColIndex = 15
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn
            PropertiesClassName = 'TcxDateEditProperties'
            DataBinding.FieldName = 'EKLEMETARIHI'
            Width = 100
            Position.ColIndex = 16
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn
            Visible = False
            DataBinding.FieldName = 'EKLEYEN'
            Position.ColIndex = 17
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn
            Visible = False
            DataBinding.FieldName = 'LISTEID'
            Position.ColIndex = 18
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 966
          Height = 41
          Align = alTop
          Caption = 'Panel9'
          TabOrder = 1
          object ToolBar4: TToolBar
            Left = 1
            Top = 1
            Width = 146
            Height = 39
            Margins.Bottom = 0
            Align = alLeft
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 46
            Caption = 'AletCubugu'
            Color = clTeal
            Ctl3D = False
            DockSite = True
            DrawingStyle = dsGradient
            EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
            EdgeInner = esNone
            EdgeOuter = esNone
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            GradientEndColor = 11776947
            GradientStartColor = 14540253
            HotTrackColor = 65408
            Images = Tablo.PNGImageList2
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object GorevEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = GorevEkleTusClick
            end
            object GorevSilTus: TToolButton
              Left = 46
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = GorevSilTusClick
            end
            object ToolButton8: TToolButton
              Left = 92
              Top = 0
              Width = 8
              Caption = 'ToolButton6'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object GorevDuzenleTus: TToolButton
              Left = 100
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = TreeListGorevDblClick
            end
          end
          object JvNavPanelHeader1: TJvNavPanelHeader
            Left = 147
            Top = 1
            Width = 818
            Height = 39
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -16
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ColorFrom = 14540253
            ColorTo = 11776947
            ImageIndex = 0
            object CheckTamamlanan: TcxCheckBox
              Left = 47
              Top = 12
              Caption = 'Tamamlananlar'#305' da g'#246'ster'
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 0
              Transparent = True
              OnClick = CheckTamamlananClick
            end
            object ComboTamamlanan: TcxImageComboBox
              Left = 229
              Top = 12
              RepositoryItem = Tablo.RepGorevSonKac
              Properties.Items = <>
              Properties.OnEditValueChanged = CheckTamamlananClick
              Style.Color = clSilver
              TabOrder = 1
              Visible = False
              Width = 115
            end
          end
        end
      end
      object TabYorumMedya: TcxTabSheet
        Caption = 'Yorum/Medya'
        ImageIndex = 38
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Panel4: TPanel
          Left = 0
          Top = 218
          Width = 966
          Height = 41
          Align = alBottom
          TabOrder = 0
          object MemoChat: TcxRichEdit
            Left = 1
            Top = 1
            Align = alClient
            Properties.ScrollBars = ssVertical
            TabOrder = 1
            Height = 39
            Width = 818
          end
          object BtnMesajGonder: TcxButton
            Left = 819
            Top = 1
            Width = 85
            Height = 39
            Align = alRight
            OptionsImage.ImageIndex = 39
            OptionsImage.Images = Tablo.cxImageList1
            TabOrder = 0
            OnClick = BtnMesajGonderClick
          end
          object BtnDosyaGonder: TcxButton
            Left = 904
            Top = 1
            Width = 61
            Height = 39
            Align = alRight
            DropDownMenu = YorumAtacMenu
            Kind = cxbkDropDown
            OptionsImage.ImageIndex = 38
            OptionsImage.Images = Tablo.cxImageList1
            TabOrder = 2
          end
        end
        object labelFileName: TcxLabel
          Left = 0
          Top = 198
          ParentCustomHint = False
          Align = alBottom
          ParentColor = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = False
          Style.Edges = [bLeft, bRight]
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.Shadow = False
          Style.IsFontAssigned = True
          Properties.Alignment.Horz = taRightJustify
          Transparent = True
          Visible = False
          ExplicitTop = 197
          AnchorX = 966
        end
        object GridYorum: TcxGrid
          Left = 0
          Top = 0
          Width = 966
          Height = 198
          Align = alClient
          TabOrder = 2
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridYorumDBCardView1: TcxGridDBCardView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCellDblClick = GridYorumDBCardView1CellDblClick
            DataController.DataSource = DtsYorum
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            LayoutDirection = ldVertical
            OptionsView.CardBorderWidth = 1
            OptionsView.CardIndent = 2
            OptionsView.CardWidth = 900
            OptionsView.CategoryIndent = 1
            OptionsView.CategorySeparatorWidth = 1
            OptionsView.CellAutoHeight = True
            OptionsView.CellTextMaxLineCount = 5
            Styles.Content = Tablo.cxStyle6
            Styles.CardBorder = Tablo.cxStyle19
            object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Position.Width = 120
            end
            object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YAZAN'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
            end
            object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
              DataBinding.FieldName = 'ATAC'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repFileExtensionList
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 25
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
              DataBinding.FieldName = 'DOKUMANAD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = False
              Position.Width = 300
              IsCaptionAssigned = True
            end
            object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
              DataBinding.FieldName = 'YORUM'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxRichEditProperties'
              Options.Editing = False
              Options.Focusing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Styles.Content = Tablo.cxStyle12
              Styles.CategoryRow = Tablo.cxStyle4
            end
          end
          object GridYorumLevel1: TcxGridLevel
            GridView = GridYorumDBCardView1
          end
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 225
    Width = 976
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = Panel1
  end
  object PageControlUst: TcxPageControl
    Left = 0
    Top = 35
    Width = 976
    Height = 190
    Align = alClient
    TabOrder = 4
    Properties.ActivePage = TabSheetListe
    Properties.CustomButtons.Buttons = <>
    Properties.Images = Tablo.cxImageList3
    OnChange = PageControlUstChange
    ClientRectBottom = 186
    ClientRectLeft = 4
    ClientRectRight = 972
    ClientRectTop = 27
    object TabSheetListe: TcxTabSheet
      Caption = 'Liste'
      ImageIndex = 0
      object GridProjeler: TcxGrid
        Left = 0
        Top = 0
        Width = 968
        Height = 159
        Align = alClient
        PopupMenu = PopupMenu1
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridProjeler: TcxGridDBTableView
          OnDblClick = GorTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridProjelerCanFocusRecord
          OnSelectionChanged = cxGridProjelerSelectionChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsProjeler
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = '###,###,##0.00'
              Kind = skSum
              Position = spFooter
              FieldName = 'LISTEFIYATI'
            end
            item
              Format = '###,###,##0.00'
              Kind = skSum
              Position = spFooter
              FieldName = 'SATISFIYATI'
              Column = cxGridProjelerSATISFIYATI
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = '###,###,##0.00'
              Kind = skSum
              FieldName = 'SATISFIYATI'
              Column = cxGridProjelerSATISFIYATI
            end
            item
              Format = '###,###,##0.00'
              Kind = skSum
              FieldName = 'LISTEFIYATI'
            end
            item
              Kind = skCount
              FieldName = 'FIRMA'
              Column = cxGridProjelerFIRMA
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.CellHints = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupFooterMultiSummaries = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Preview.MaxLineCount = 0
          Styles.OnGetContentStyle = cxGridProjelerStylesGetContentStyle
          object cxGridProjelerBASTARIHI: TcxGridDBColumn
            Caption = 'Ba'#351'lama Tarihi'
            DataBinding.FieldName = 'BASLAMATARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Width = 77
          end
          object cxGridProjelerPROJEKODU: TcxGridDBColumn
            Caption = 'Proje Kodu'
            DataBinding.FieldName = 'PROJEKODU'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerFIRMA: TcxGridDBColumn
            Caption = 'M'#252#351'teri'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 132
          end
          object cxGridProjelerTURU: TcxGridDBColumn
            Caption = 'T'#252'r'#252
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repProjeTuru
            Width = 69
          end
          object cxGridProjelerKONU: TcxGridDBColumn
            Caption = 'Konusu'
            DataBinding.FieldName = 'KONUSU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 109
          end
          object cxGridProjelerTIPI: TcxGridDBColumn
            Caption = 'Tipi'
            DataBinding.FieldName = 'PROJETIPI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
          end
          object cxGridProjelerSATISFIYATI: TcxGridDBColumn
            Caption = 'B'#252't'#231'esi'
            DataBinding.FieldName = 'SATISFIYATI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            HeaderAlignmentHorz = taRightJustify
            Width = 95
          end
          object cxGridProjelerPROJEKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'SATISKUR'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repProjeDurum
            Width = 51
          end
          object cxGridProjelerBelgeVar: TcxGridDBColumn
            Caption = 'Dkmn'
            DataBinding.FieldName = 'DOSYAVAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                ImageIndex = 1
                Value = '1'
              end>
            Width = 34
          end
          object cxGridProjelerILGILI1: TcxGridDBColumn
            Caption = 'M'#252#351'teri '#304'lgili'
            DataBinding.FieldName = 'ADSOYAD'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object cxGridProjelerASAMA: TcxGridDBColumn
            Caption = 'A'#351'ama'
            DataBinding.FieldName = 'ASAMA'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repProjeAsama
          end
          object cxGridProjelerNOTLAR: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'NOTLAR'
            DataBinding.IsNullValueType = True
            Width = 228
          end
          object cxGridProjelerBITTARIHI: TcxGridDBColumn
            Caption = 'Biti'#351' Tarihi'
            DataBinding.FieldName = 'BITISTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Width = 71
          end
          object cxGridProjelerSONUC: TcxGridDBColumn
            Caption = 'Sonu'#231
            DataBinding.FieldName = 'SONUC'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFirsatSonuc
          end
          object cxGridProjelerSONUCACIKLAMA: TcxGridDBColumn
            Caption = 'Sonu'#231' Notu'
            DataBinding.FieldName = 'SONUCACIKLAMA'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerSONAKTKONUSU: TcxGridDBColumn
            Caption = 'Son '#304#351' Konusu'
            DataBinding.FieldName = 'SONAKTIVITEKONUSU'
            DataBinding.IsNullValueType = True
            Width = 74
          end
          object cxGridProjelerSONAKTTARIHI: TcxGridDBColumn
            Caption = 'Son '#304#351' Tarihi'
            DataBinding.FieldName = 'SONAKTIVITETARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Width = 81
          end
          object cxGridProjelerDEGISTIRMETARIHI: TcxGridDBColumn
            Caption = 'De'#287'i'#351'tirme Tarihi'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridProjelerDEGISTIREN: TcxGridDBColumn
            Caption = 'De'#287'i'#351'tiren'
            DataBinding.FieldName = 'DEGISTIREN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repGenelPersonelListesi
            Visible = False
          end
          object cxGridProjelerEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Ekleme Tarihi'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridProjelerEKLEYEN: TcxGridDBColumn
            Caption = 'Ekleyen'
            DataBinding.FieldName = 'EKLEYEN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repGenelPersonelListesi
            Visible = False
          end
          object cxGridProjelerSUBEID: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
          end
          object cxGridProjelerASAMASORUMLU: TcxGridDBColumn
            Caption = 'A'#351'ama Sorumlusu'
            DataBinding.FieldName = 'ASAMASORUMLU'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerPROJEADI: TcxGridDBColumn
            Caption = 'Proje Ad'#305
            DataBinding.FieldName = 'PROJEADI'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerPRJ_SORUMLUSU_ID: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'SORUMLUAD'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerBASLAMAAY: TcxGridDBColumn
            Caption = 'Ba'#351'. Ay'
            DataBinding.FieldName = 'BASLAMAAY'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerBASLAMAYIL: TcxGridDBColumn
            Caption = 'Ba'#351'. Y'#305'l'
            DataBinding.FieldName = 'BASLAMAYIL'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerBITISAY: TcxGridDBColumn
            Caption = 'Bit. Ay'
            DataBinding.FieldName = 'BITISAY'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerBITISYIL: TcxGridDBColumn
            Caption = 'Bit. Y'#305'l'
            DataBinding.FieldName = 'BITISYIL'
            DataBinding.IsNullValueType = True
          end
          object cxGridProjelerID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridProjeler
        end
      end
    end
    object TabSheetGrup: TcxTabSheet
      Caption = 'Grup'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object FTileControl: TdxTileControl
        Left = 0
        Top = 0
        Width = 968
        Height = 159
        ActionBars.IndentHorz = 10
        OptionsBehavior.FocusItemOnCycle = False
        OptionsView.GroupMaxRowCount = 20
        OptionsView.IndentHorz = 5
        OptionsView.IndentVert = 5
        OptionsView.ItemHeight = 75
        OptionsView.ItemIndent = 5
        OptionsView.ItemWidth = 100
        TabOrder = 0
        OnItemDragBegin = FTileControlItemDragBegin
        OnItemDragEnd = FTileControlItemDragEnd
        object FTileControlActionBarItem1: TdxTileControlActionBarItem
          Caption = 'qqqqq'
        end
      end
    end
  end
  object DtsProjeler: TDataSource
    DataSet = PROJELER
    Left = 117
    Top = 164
  end
  object PROJELER: TFDQuery
    Connection = Tablo.FDCnn
    BeforeOpen = PROJELERBeforeOpen
    AfterOpen = PROJELERAfterOpen
    ParamData = <
      item
        Name = 'PKullanan'
        DataType = ftInteger
        ParamType = ptInput
        Value = 0
      end>
    SQL.Strings = (
      ''
      'declare @PERSONEL int'
      'set @PERSONEL=:PKullanan'
      'select '
      #9'P.*,'
      
        #9'FIRMA= CASE WHEN LEN(LTRIM(RTRIM(R1.FIRMA)))-LEN(REPLACE(LTRIM(' +
        'RTRIM(R1.FIRMA)),'#39' '#39','#39#39'))<2 THEN FIRMA ELSE SUBSTRING(R1.FIRMA, ' +
        '0, CHARINDEX('#39' '#39', R1.FIRMA, CHARINDEX('#39' '#39', R1.FIRMA, 0)+1)) END,'
      ''
      #9'ProjeTipi.ANAHTAR PROJETIPI, '
      #9'RP.ADSOYAD,'
      
        #9'SORUMLUAD=(select top 1 FIRMA from REHBER RSOR where RSOR.ID=P.' +
        'PRJ_SORUMLUSU_ID),'
      
        #9'ASAMASORUMLU=(select top 1 FIRMA from REHBER R5 inner join PROJ' +
        'EASAMA PA on R5.ID=PA.REHBERID'
      
        '                        where PA.PROJEID=P.ID and PA.ASAMA=P.ASA' +
        'MA),'
      #9'BASLAMAAY=month(P.BASLAMATARIHI),'
      #9'BASLAMAYIL=year(P.BASLAMATARIHI),'
      #9'BITISAY=month(P.BITISTARIHI),'
      #9'BITISYIL=year(P.BITISTARIHI),'
      
        '    DOSYAVAR = CASE WHEN  (SELECT TOP 1 COUNT(ID) FROM DOKUMAN W' +
        'HERE MODUL = 70 AND MODULID = P.ID AND KLASOR <> -1 ) >0  THEN 1' +
        ' ELSE 0 END,'
      
        '    SONAKTIVITEKONUSU = (SELECT TOP 1 KONUSU FROM AKTIVITELER A ' +
        'WHERE PROJEID = P.ID AND '
      '       A.DURUM  in (8,9)  ORDER BY BITISTARIHI DESC ),'
      
        '    SONAKTIVITETARIHI =  convert(DateTime,(SELECT TOP 1 BITISTAR' +
        'IHI FROM AKTIVITELER A WHERE PROJEID = P.ID AND '
      '       A.DURUM  in (8,9)  ORDER BY BITISTARIHI DESC ),103)'
      ' '
      'from PROJELER P'
      #9'inner join REHBER R1 on R1.ID=P.REHBERID'
      #9'left outer join REHBERPERSONEL RP on RP.ID=P.ILGILI'
      
        '    LEFT OUTER JOIN GENINI ProjeTipi ON ProjeTipi.DEGER = P.TIPI' +
        ' AND ProjeTipi.BOLUM=convert(int,'#39'-2112'#39'+convert(varchar(10),P.T' +
        'URU))'
      'WHERE'
      'P.MODUL=11'
      '--1=case'
      '--when @PERSONEL = P.EKLEYEN then 1'
      '--when @PERSONEL = P.PRJ_SORUMLUSU_ID then 1'
      
        '--when @PERSONEL in (select REHBERID from KULLANICI where ROLID=' +
        '-1)then 1'
      
        '--when @PERSONEL in (select REHBERID from PROJEASAMA PA where PA' +
        '.PROJEID=P.ID and PA.AKTIF=1)then 1'
      
        '--when @PERSONEL in (select REHBERID from PROJEASAMA PA where PA' +
        '.PROJEID=P.ID and PA.ASAMA=P.ASAMA)then 1'
      
        '--when (select ROLID from KULLANICI where REHBERID=@PERSONEL) = ' +
        '(select USTID from ROLLER where ID=(select ROLID from KULLANICI ' +
        'where'
      '--REHBERID=P.EKLEYEN)) then 1  else 0 end'
      ''
      ''
      '')
    Left = 119
    Top = 104
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 30
    Top = 104
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxPROJELER: TfrxDBDataset
    UserName = 'PROJELER'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 118
    Top = 218
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 28
    Top = 167
    object ProjeInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = ProjeInfoMenuClick
    end
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object GrupA1: TMenuItem
      Tag = 1
      Caption = 'Grup A'#231'(-)'
      ImageIndex = 32
      OnClick = GrupA1Click
    end
    object GrupKapa1: TMenuItem
      Caption = 'Grup Kapat(+)'
      ImageIndex = 32
      OnClick = GrupA1Click
    end
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 681
    Top = 192
  end
  object TabGorevler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'RehberId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4322
      end
      item
        Name = 'AcKapa'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end
      item
        Name = 'GunSay'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 9999
      end
      item
        Name = 'ListeId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        'exec sp_Prg_IsListesi_Projeler  :RehberId, :AcKapa , :GunSay, :L' +
        'isteId')
    Left = 229
    Top = 309
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 315
    Top = 312
  end
  object GorevlerMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 584
    Top = 308
    object DuzenleMenu: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = DuzenleMenuClick
    end
    object TamamlandiIsaretleMenu: TMenuItem
      Caption = #304#351'aretliler Tamamland'#305' / Tamamlanmad'#305
      ImageIndex = 23
      OnClick = TamamlandiIsaretleMenuClick
    end
    object Bayraklaretle1: TMenuItem
      Caption = #304#351'aretliler  Bayrakl'#305' / Bayraks'#305'z'
      ImageIndex = 31
      OnClick = Bayraklaretle1Click
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object TarihBugunMenu: TMenuItem
      Caption = #304#351'aretlilerin Tarihi Bug'#252'n'
      ImageIndex = 21
    end
    object arihYarn1: TMenuItem
      Tag = 1
      Caption = #304#351'aretlilerin Tarihi Yar'#305'n'
      ImageIndex = 21
    end
    object TarihiKaldirMenu: TMenuItem
      Tag = -1
      Caption = #304#351'aretlilerin Tarihini Kald'#305'r'
      ImageIndex = 24
    end
    object MenuItem5: TMenuItem
      Caption = '-'
    end
    object Atamayap1: TMenuItem
      Caption = #304#351'aretlilere Atama yap'
      ImageIndex = 15
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object BuiiEPostaGnder1: TMenuItem
      Caption = 'Bu i'#351'i E-Posta G'#246'nder'
      ImageIndex = 17
    end
    object BuiYazdr1: TMenuItem
      Caption = 'Bu '#304#351'i Yazd'#305'r'
      ImageIndex = 8
    end
    object MenuItem9: TMenuItem
      Caption = '-'
    end
    object IsiKopyalaMenu: TMenuItem
      Caption = #304#351'i Kopyala'
      ImageIndex = 10
      OnClick = IsiKopyalaMenuClick
    end
    object IsiSilMenu: TMenuItem
      Caption = #304#351'i Sil'
      ImageIndex = 1
      OnClick = IsiSilMenuClick
    end
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 1020
    Top = 396
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 37
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 43
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 1003
    Top = 337
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 423
    Top = 276
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
end



