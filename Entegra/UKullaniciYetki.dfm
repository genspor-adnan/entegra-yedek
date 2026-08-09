object KullaniciYetkiDlg: TKullaniciYetkiDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Kullan'#305'c'#305' D'#252'zenleme ve Yetkilendirme Ekran'#305
  ClientHeight = 602
  ClientWidth = 1220
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClick = FormClick
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object PageYetkilDetay: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 674
    Top = 0
    Width = 546
    Height = 602
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 598
    ClientRectLeft = 4
    ClientRectRight = 542
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Rol'#252'n Yetkileri'
      ImageIndex = 29
      object PanelRol: TPanel
        Left = 0
        Top = 33
        Width = 538
        Height = 538
        Align = alClient
        TabOrder = 0
        object cxDBTreeList1: TcxDBTreeList
          Left = 1
          Top = 1
          Width = 337
          Height = 536
          BorderStyle = cxcbsNone
          Align = alClient
          Bands = <
            item
            end>
          DataController.DataSource = DtsModul
          DataController.ParentField = 'ROOTKOD'
          DataController.KeyField = 'MODULID'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          Navigator.Buttons.CustomButtons = <>
          OptionsData.Editing = False
          OptionsData.Deleting = False
          OptionsSelection.CellSelect = False
          ParentFont = False
          PopupMenu = PopupMenuGurup
          RootValue = -1
          ScrollbarAnnotations.CustomAnnotations = <>
          TabOrder = 0
          OnClick = cxDBTreeList1Click
          object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.ReadOnly = True
            Caption.Text = 'Mod'#252'l Ad'#305
            DataBinding.FieldName = 'MODULADI'
            Width = 289
            Position.ColIndex = 0
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.DisplayFormat = '0;-0'
            Properties.ReadOnly = True
            Visible = False
            Caption.Text = 'Kod'
            DataBinding.FieldName = 'MODULID'
            Width = 117
            Position.ColIndex = 1
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
        end
        object PanelSag: TPanel
          Left = 338
          Top = 1
          Width = 199
          Height = 536
          Align = alRight
          TabOrder = 1
          object GroupDeger: TcxGroupBox
            Left = 1
            Top = 267
            Align = alBottom
            Caption = 'De'#287'er'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Style.BorderStyle = ebsNone
            Style.Color = clSkyBlue
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 0
            Height = 99
            Width = 197
            object cxDBTextEdit1: TcxDBTextEdit
              Left = 35
              Top = 48
              OnFocusChanged = cxDBTextEdit1FocusChanged
              DataBinding.DataField = 'BILGI'
              DataBinding.DataSource = DtsYetkiEk
              TabOrder = 1
              Width = 123
            end
            object LabelBilgi: TcxLabel
              Left = 34
              Top = 24
              Caption = '--'
            end
          end
          object CheckGroupHaklar: TcxCheckGroup
            Left = 1
            Top = 128
            Align = alBottom
            Caption = 'Temel Haklar'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Properties.EditValueFormat = cvfStatesString
            Properties.Items = <>
            Properties.OnChange = CheckGroupHaklarPropertiesChange
            Style.BorderStyle = ebsNone
            Style.Color = clSkyBlue
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 2
            Height = 139
            Width = 197
          end
          object GroupAciklama: TcxGroupBox
            Left = 1
            Top = 1
            Align = alClient
            Caption = 'A'#231#305'klama'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Style.BorderStyle = ebsNone
            Style.Color = clSkyBlue
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 1
            Height = 127
            Width = 197
            object cxDBRichEdit1: TcxDBRichEdit
              Left = 2
              Top = 21
              Align = alClient
              DataBinding.DataField = 'ACIKLAMA'
              DataBinding.DataSource = DtsModul
              Enabled = False
              ParentColor = True
              Style.BorderStyle = ebsNone
              TabOrder = 0
              Height = 104
              Width = 193
            end
          end
          object PageControlSec: TcxPageControl
            Left = 1
            Top = 366
            Width = 197
            Height = 169
            Align = alBottom
            TabOrder = 3
            Properties.ActivePage = TabSheetDemirbas
            Properties.CustomButtons.Buttons = <>
            ClientRectBottom = 165
            ClientRectLeft = 4
            ClientRectRight = 193
            ClientRectTop = 27
            object TabSheetSecim: TcxTabSheet
              Caption = 'Se'#231'im'
              ImageIndex = 19
              object RadioGroupSecim: TcxDBRadioGroup
                Left = 0
                Top = 0
                Align = alClient
                OnFocusChanged = cxDBTextEdit1FocusChanged
                DataBinding.DataField = 'BILGI'
                DataBinding.DataSource = DtsYetkiEk
                ParentBackground = False
                ParentColor = False
                Properties.DefaultValue = 0
                Properties.Items = <
                  item
                    Caption = 'Sadece Kendisinin'
                    Value = 1
                  end
                  item
                    Caption = 'Kendi Departman'#305'ndaki Herkesin'
                    Value = '5'
                  end
                  item
                    Caption = 'Kendi '#350'ubesindeki Herkesin'
                    Value = 10
                  end
                  item
                    Caption = 'T'#252'm '#350'ubelerde Herkesin'
                    Value = 100
                  end>
                Style.Color = clSkyBlue
                TabOrder = 0
                Height = 138
                Width = 189
              end
            end
            object TabSheetDemirbas: TcxTabSheet
              Caption = 'Demirba'#351' Kategori'
              ImageIndex = 12
              object RadioGroupDemirbas: TcxDBRadioGroup
                Left = 0
                Top = 0
                Align = alClient
                OnFocusChanged = RadioGroupDemirbasFocusChanged
                DataBinding.DataField = 'BILGI2'
                DataBinding.DataSource = DtsYetkiEk
                ParentBackground = False
                ParentColor = False
                Properties.DefaultValue = 1
                Properties.ImmediatePost = True
                Properties.Items = <
                  item
                    Caption = 'T'#252'm'#252'n'#252' G'#246'rs'#252'n'
                    Value = '1'
                  end
                  item
                    Caption = 'Hi'#231' G'#246'rmesin'
                    Value = 0
                  end
                  item
                    Caption = 'Se'#231'ilenleri G'#246'rs'#252'n'
                    Value = 2
                  end>
                Style.Color = clSkyBlue
                TabOrder = 1
                Height = 138
                Width = 189
              end
              object ButtonDemirbas: TcxButton
                Left = 126
                Top = 105
                Width = 58
                Height = 20
                Caption = 'Se'#231
                TabOrder = 0
                OnClick = ButtonDemirbasClick
              end
            end
          end
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 538
        Height = 33
        Align = alTop
        Color = clHighlight
        ParentBackground = False
        TabOrder = 1
        Visible = False
        object cxRadioButton2: TcxRadioButton
          Left = 119
          Top = 9
          Width = 113
          Height = 17
          Caption = 'Yetkili olduklar'#305
          TabOrder = 0
        end
        object cxRadioButton1: TcxRadioButton
          Left = 64
          Top = 9
          Width = 43
          Height = 17
          Caption = 'T'#252'm'#252
          TabOrder = 1
        end
        object cxLabel1: TcxLabel
          Left = 23
          Top = 7
          AutoSize = False
          Caption = 'Liste'
          Transparent = True
          Height = 20
          Width = 37
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 385
    Top = 0
    Width = 8
    Height = 602
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = PageOrganizasyon
  end
  object PageKullan: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 393
    Top = 0
    Width = 273
    Height = 602
    Align = alLeft
    TabOrder = 2
    Properties.ActivePage = cxTabSheet2
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 598
    ClientRectLeft = 4
    ClientRectRight = 269
    ClientRectTop = 27
    object cxTabSheet2: TcxTabSheet
      Caption = 'Roldeki Kullan'#305'c'#305'lar'
      ImageIndex = 35
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 259
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 66
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object KulDuzenleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsTextButton
          OnClick = KulDuzenleTusClick
        end
      end
      object GridKullan: TcxGrid
        Left = 0
        Top = 27
        Width = 265
        Height = 544
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridKullanView: TcxGridDBTableView
          OnDblClick = KulDuzenleTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKullanici
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridKullanViewKULLANICI: TcxGridDBColumn
            Caption = 'Ad Soyad'
            DataBinding.FieldName = 'KULLANICI'
            DataBinding.IsNullValueType = True
            Width = 198
          end
          object GridKullanViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 41
          end
          object GridKullanViewDURUM: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            Width = 48
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = GridKullanView
        end
      end
    end
  end
  object cxSplitter2: TcxSplitter
    Left = 666
    Top = 0
    Width = 8
    Height = 602
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = PageKullan
  end
  object PageOrganizasyon: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 385
    Height = 602
    Align = alLeft
    TabOrder = 4
    Properties.ActivePage = cxTabSheet3
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 598
    ClientRectLeft = 4
    ClientRectRight = 381
    ClientRectTop = 27
    object cxTabSheet3: TcxTabSheet
      Caption = 'Organizasyon / Roller'
      ImageIndex = 19
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 371
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 66
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object RolYeniTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = RolYeniTusClick
        end
        object RolSilTus: TToolButton
          Left = 66
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = RolSilTusClick
        end
        object ToolButton3: TToolButton
          Left = 132
          Top = 0
          Width = 8
          Caption = 'ToolButton10'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsSeparator
        end
        object RolDuzenleTus: TToolButton
          Left = 140
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsTextButton
          OnClick = RolDuzenleTusClick
        end
      end
      object TreeListRoller: TcxDBTreeList
        Left = 0
        Top = 27
        Width = 377
        Height = 544
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsRol
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        DragMode = dmAutomatic
        Navigator.Buttons.CustomButtons = <>
        OptionsBehavior.DragDropText = True
        OptionsBehavior.DragFocusing = True
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.CellSelect = False
        PopupMenu = PopupMenuRoller
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        Styles.Background = Tablo.cxStDogruBildirim
        Styles.Inactive = Tablo.cxStSerinoCikilmis
        Styles.Selection = Tablo.cxStSerinoCikilmis
        Styles.ColumnHeader = Tablo.cxstKismiIade
        TabOrder = 1
        OnDblClick = RolDuzenleTusClick
        OnDragOver = TreeListRollerDragOver
        OnSelectionChanged = TreeListRollerSelectionChanged
        object TreeListRollerSUBE: TcxDBTreeListColumn
          Styles.Header = Tablo.cxstSecili
          Caption.Text = #350'ube'
          DataBinding.FieldName = 'SUBE'
          Width = 100
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollerDEPARTMAN: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepBizimDepartman
          Styles.Header = Tablo.cxstSecili
          Caption.Text = 'Departman'
          DataBinding.FieldName = 'DEPARTMAN'
          Width = 100
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollerGOREVID: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepBizimGorev
          Styles.Header = Tablo.cxstSecili
          Caption.Text = 'G'#246'rev / Rol'
          DataBinding.FieldName = 'GOREVID'
          Width = 133
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollerID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ID'
          Width = 100
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollerUSTID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'USTID'
          Width = 100
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollercxTY: TcxDBTreeListColumn
          Styles.Header = Tablo.cxstSecili
          DataBinding.FieldName = 'TY'
          Width = 26
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
  end
  object cxMemo1: TcxMemo
    Left = 32
    Top = 224
    Lines.Strings = (
      '  DECLARE @RolID int, @ModulID nvarchar(20)'
      '  SET @RolID = :PRM1'
      '  SET @ModulID = :PRM2'
      ''
      '  DELETE FROM YETKI'
      '  WHERE ROLID = @RolID'
      '    AND MODULID LIKE @ModulID + '#39'%'#39
      ''
      '  INSERT INTO YETKI (ROLID, MODULID, HAK, TUR)'
      '  SELECT DISTINCT ROLID, MODULID, HAK, TUR'
      '  FROM ('
      '      SELECT @RolID AS ROLID, MODULID, 1 AS HAK, 1 AS TUR'
      '      FROM MODUL M'
      '      WHERE MODULID LIKE @ModulID + '#39'%'#39
      '        AND M.TUR IN (1,2,3,4,6,7,8,9,16,17,18,19)'
      ''
      '      UNION ALL'
      ''
      '      SELECT @RolID, MODULID, 1, 2'
      '      FROM MODUL M'
      '      WHERE MODULID LIKE @ModulID + '#39'%'#39
      '        AND M.TUR IN (2,4,7,9,17,19)'
      ''
      '      UNION ALL'
      ''
      '      SELECT @RolID, MODULID, 1, 3'
      '      FROM MODUL M'
      '      WHERE MODULID LIKE @ModulID + '#39'%'#39
      '        AND M.TUR IN (3,4,8,9,18,19)'
      ''
      '      UNION ALL'
      ''
      
        '      SELECT @RolID, CONVERT(int, CONVERT(nvarchar(4), M.MODULID' +
        ') + CONVERT(nvarchar(10), D.ID)), 1, 1'
      '      FROM MODUL M'
      '      INNER JOIN DOKUMLER D ON M.DOKUMTUR = D.MODUL'
      '      WHERE LEN(M.MODULID) = 4'
      '        AND M.MODULID LIKE '#39'__99'#39
      '        AND MODULID LIKE @ModulID + '#39'%'#39
      ''
      '      UNION ALL'
      ''
      
        '      SELECT @RolID, CONVERT(bigint, CONVERT(varchar(4), M.MODUL' +
        'ID) + CONVERT(varchar(10), -R.ID)), 1, 1'
      '      FROM MODUL M'
      '      INNER JOIN REHBER R ON R.ID < 0 AND R.DURUM > 0'
      '      WHERE LEN(M.MODULID) = 4'
      '        AND M.MODULID LIKE '#39'__98'#39
      '        AND MODULID LIKE @ModulID + '#39'%'#39
      ''
      '      UNION ALL'
      ''
      
        '      SELECT @RolID, CONVERT(bigint, CONVERT(varchar(4), M.MODUL' +
        'ID) + CONVERT(varchar(10), '#39'0'#39')), 1, 1'
      '      FROM MODUL M'
      '      WHERE LEN(M.MODULID) = 4'
      '        AND M.MODULID LIKE '#39'__98'#39
      '        AND MODULID LIKE @ModulID + '#39'%'#39
      ''
      '      UNION ALL'
      ''
      
        '      SELECT @RolID, CONVERT(int, CONVERT(nvarchar(4), M.MODULID' +
        ') + CONVERT(nvarchar(10), D.ID)), 1, 1'
      '      FROM MODUL M'
      '      INNER JOIN DEPOLAR D ON D.DURUM > 0'
      '      WHERE LEN(M.MODULID) = 4'
      '        AND MODULID LIKE @ModulID + '#39'%'#39
      '  ) X'
      '  WHERE NOT EXISTS ('
      '      SELECT 1'
      '      FROM YETKI Y'
      '      WHERE Y.ROLID = X.ROLID'
      '        AND Y.MODULID = X.MODULID'
      '        AND Y.HAK = X.HAK'
      '        AND Y.TUR = X.TUR'
      '  );')
    TabOrder = 5
    Visible = False
    Height = 89
    Width = 593
  end
  object TabRol: TFDQuery
    BeforePost = TabRolBeforePost
    BeforeDelete = TabRolBeforeDelete
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT ROL.*,'
      'SUBE=(SELECT FIRMA FROM REHBER WHERE ID=ROL.SUBEID)'
      ' FROM ROLLER ROL'
      '  WHERE DURUM=1'
      'order by SUBEID DESC, DEPARTMAN ')
    Left = 226
    Top = 177
  end
  object DtsRol: TDataSource
    DataSet = TabRol
    Left = 225
    Top = 124
  end
  object DtsKullanici: TDataSource
    DataSet = TabKullanici
    Left = 274
    Top = 124
  end
  object TabKullanici: TFDQuery
    AfterOpen = TabKullaniciAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select K.*, KULLANICI = R.FIRMA from KULLANICI K '
      'inner join REHBER R on R.ID = K.REHBERID'
      'where '
      'ROLID=:PID'
      'and R.DURUM>0'
      'and R.GRUP=335'
      'order by 1')
    Left = 273
    Top = 178
  end
  object DtsModul: TDataSource
    DataSet = TabModul
    Left = 327
    Top = 124
  end
  object TabModul: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from [dbo].[fn_ModulListesi]()')
    Left = 325
    Top = 178
  end
  object TabYetki: TFDQuery
    BeforePost = TabYetkiBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from YETKI'
      'where ROLID=:PRID'
      'and MODULID=:PMID'
      ''
      'order by TUR')
    Left = 382
    Top = 178
  end
  object DtsYetki: TDataSource
    DataSet = TabYetki
    Left = 381
    Top = 125
  end
  object TabYetkiEk: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from YETKIEK'
      'where ROLID=:PRID'
      'and MODULID=:PMID')
    Left = 439
    Top = 178
  end
  object DtsYetkiEk: TDataSource
    DataSet = TabYetkiEk
    Left = 437
    Top = 126
  end
  object PopupMenuGurup: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 435
    Top = 277
    object mGurubuSe1: TMenuItem
      Caption = 'T'#252'm Gurubu Se'#231
      ImageIndex = 15
      OnClick = mGurubuSe1Click
    end
    object mGurubuKaldr1: TMenuItem
      Caption = 'T'#252'm Gurubu Kald'#305'r'
      ImageIndex = 24
      OnClick = mGurubuKaldr1Click
    end
  end
  object PopupMenuRoller: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 76
    Top = 154
    object Yeni1: TMenuItem
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = RolYeniTusClick
    end
    object Sil1: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = RolSilTusClick
    end
    object Dzenle1: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = RolDuzenleTusClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object BakaBirRoldenYetkiKopyala1: TMenuItem
      Caption = 'Ba'#351'ka Bir Rolden Yetki Kopyala'
      ImageIndex = 10
      OnClick = BakaBirRoldenYetkiKopyala1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object DepertmanListesiDzenle1: TMenuItem
      Caption = 'Departman Listesi D'#252'zenle'
      ImageIndex = 7
      OnClick = DepertmanListesiDzenle1Click
    end
    object GrevListesiDzenle1: TMenuItem
      Caption = 'G'#246'rev Listesi D'#252'zenle'
      ImageIndex = 7
      OnClick = GrevListesiDzenle1Click
    end
  end
end
