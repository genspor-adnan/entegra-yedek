object MekanMasaDizaynDlg: TMekanMasaDizaynDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsNone
  Caption = 'DizaynForm'
  ClientHeight = 584
  ClientWidth = 945
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 37
    Width = 233
    Height = 528
    Align = alLeft
    TabOrder = 0
    ExplicitTop = 31
    object Label3: TLabel
      Left = 12
      Top = 150
      Width = 38
      Height = 13
      Caption = 'Mekan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 88
      Top = 151
      Width = 65
      Height = 16
      Caption = 'Mekan '#304'smi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Shape1: TShape
      Left = 181
      Top = 477
      Width = 46
      Height = 66
      Shape = stCircle
      Visible = False
    end
    object Label9: TLabel
      Left = 32
      Top = 10
      Width = 30
      Height = 13
      Caption = 'Masa'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label10: TLabel
      Left = 16
      Top = 262
      Width = 53
      Height = 13
      Caption = 'Masa Se'#231
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ToolBar10: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 225
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 59
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object iletisimEkle: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        OnClick = iletisimEkleClick
      end
      object iletisimSil: TToolButton
        Left = 59
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = iletisimSilClick
      end
      object ToolButton14: TToolButton
        Left = 118
        Top = 0
        Width = 8
        Caption = 'ToolButton14'
        ImageIndex = 10
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 126
        Top = 0
        Caption = 'D'#252'zelt'
        ImageIndex = 10
        OnClick = ToolButton1Click
      end
    end
    object cxButton1: TcxButton
      Left = 85
      Top = 229
      Width = 118
      Height = 25
      Caption = 'Yeni Masa'
      Enabled = False
      TabOrder = 1
      OnClick = cxButton1Click
    end
    object DizaynKaydet: TcxButton
      Left = 12
      Top = 462
      Width = 193
      Height = 25
      Caption = 'Dizayn'#305' Kaydet'
      TabOrder = 4
      OnClick = DizaynKaydetClick
    end
    object ComboMasaListe: TcxComboBox
      Left = 83
      Top = 260
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 16
      TabOrder = 2
      Width = 121
    end
    object PanelBilgi: TPanel
      Left = 13
      Top = 287
      Width = 214
      Height = 153
      TabOrder = 3
      Visible = False
      object Label1: TLabel
        Left = 33
        Top = 33
        Width = 13
        Height = 13
        Caption = 'En'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label5: TLabel
        Left = 33
        Top = 56
        Width = 21
        Height = 13
        Caption = 'Boy'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label6: TLabel
        Left = 33
        Top = 7
        Width = 27
        Height = 13
        Caption = #350'ekil'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label7: TLabel
        Left = 33
        Top = 78
        Width = 17
        Height = 13
        Caption = 'Sol'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label8: TLabel
        Left = 33
        Top = 101
        Width = 19
        Height = 13
        Caption = #220'st'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object EditEn: TcxSpinEdit
        Left = 76
        Top = 28
        Properties.MinValue = 20.000000000000000000
        Properties.OnChange = EditEnPropertiesChange
        TabOrder = 1
        Value = 20
        Width = 120
      end
      object EditBoy: TcxSpinEdit
        Left = 76
        Top = 51
        Properties.MinValue = 20.000000000000000000
        Properties.OnChange = EditBoyPropertiesChange
        TabOrder = 2
        Value = 20
        Width = 120
      end
      object ComboSekil: TcxImageComboBox
        Left = 76
        Top = 5
        EditValue = -1
        Properties.DefaultImageIndex = 0
        Properties.Items = <
          item
            Description = 'Daire'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Elips'
            Value = 2
          end
          item
            Description = 'Dikd'#246'rtgen'
            Value = 3
          end>
        Properties.OnChange = ComboSekilPropertiesChange
        TabOrder = 0
        Width = 120
      end
      object EditSol: TcxSpinEdit
        Left = 76
        Top = 73
        Properties.OnChange = EditSolPropertiesChange
        TabOrder = 3
        Width = 120
      end
      object EditUst: TcxSpinEdit
        Left = 76
        Top = 96
        Properties.OnChange = EditUstPropertiesChange
        TabOrder = 4
        Width = 120
      end
      object cxButton4: TcxButton
        Left = 9
        Top = 126
        Width = 89
        Height = 25
        Caption = #304'sim De'#287'i'#351'tir'
        Enabled = False
        TabOrder = 5
        OnClick = cxButton4Click
      end
      object btnsil: TcxButton
        Left = 112
        Top = 126
        Width = 83
        Height = 25
        Caption = 'Masay'#305' Sil'
        Enabled = False
        TabOrder = 6
        OnClick = btnsilClick
      end
    end
    object GridMekan: TcxGrid
      Left = 1
      Top = 28
      Width = 231
      Height = 116
      Align = alTop
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      TabOrder = 5
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      object GridMekanView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsMekan
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.ScrollBars = ssNone
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = glNone
        OptionsView.GroupByBox = False
        OptionsView.Header = False
        object GridMekanViewID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object GridMekanViewMEKAN: TcxGridDBColumn
          DataBinding.FieldName = 'MEKAN'
        end
        object GridMekanViewSUBEID: TcxGridDBColumn
          DataBinding.FieldName = 'SUBEID'
          Visible = False
        end
        object GridMekanViewSUBE: TcxGridDBColumn
          DataBinding.FieldName = 'SUBE'
        end
      end
      object cxGridLevel5: TcxGridLevel
        GridView = GridMekanView
      end
    end
    object ZeminResimTus: TcxButton
      Left = 85
      Top = 173
      Width = 124
      Height = 25
      Caption = 'Zemin Resim Y'#252'kle'
      TabOrder = 6
      OnClick = ZeminResimTusClick
    end
    object LabelResmiSil: TcxLabel
      Left = 13
      Top = 176
      Cursor = crHandPoint
      Caption = 'Resmi Sil'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlue
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      OnClick = LabelResmiSilClick
    end
  end
  object ZeminResim: TcxImage
    Left = 233
    Top = 37
    Align = alClient
    Properties.Center = False
    Properties.GraphicClassName = 'TJPEGImage'
    Properties.Stretch = True
    TabOrder = 1
    Transparent = True
    Height = 528
    Width = 712
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 945
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object KapatTus: TJvNavPanelButton
      Left = 835
      Top = 0
      Width = 110
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 1060
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 565
    Width = 945
    Height = 19
    Panels = <>
  end
  object TabMekan: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabMekanAfterOpen
    AfterScroll = TabMekanAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select distinct ID,MEKAN,SUBEID,SUBE from ('
      
        'select ID=DEGER,MEKAN=ANAHTAR,SUBEID=DIL,SUBE=R.FIRMA  from GENI' +
        'NI G'
      'left outer join REHBER R on G.DIL=R.ID '
      ' where BOLUM=-4444'
      'union all'
      
        'select ID=M.MEKAN, MEKAN=G.ANAHTAR, SUBEID=G.DIL, SUBE=R.FIRMA f' +
        'rom MASALAR M '
      'left outer join GENINI G on G.BOLUM=-4444 and G.DEGER=M.MEKAN'
      'left outer join REHBER R on G.DIL=R.ID '
      'group by  M.MEKAN, G.ANAHTAR , G.DIL, R.FIRMA'
      ''
      ') as T'
      'order by 3')
    Left = 164
    Top = 47
  end
  object DtsMekan: TDataSource
    DataSet = TabMekan
    Left = 131
    Top = 107
  end
end

