object HizliGirisDokumDlg: THizliGirisDokumDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Raporlama'
  ClientHeight = 532
  ClientWidth = 979
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDokumListe: TPanel
    Left = 0
    Top = 0
    Width = 305
    Height = 532
    Align = alLeft
    TabOrder = 0
    object Button1: TButton
      Left = 55
      Top = 254
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
    end
    object cxGroupBox1: TcxGroupBox
      Left = 1
      Top = 1
      Align = alClient
      Caption = 'Arama'
      Style.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
      TabOrder = 1
      Height = 530
      Width = 303
      object ScrollBoxListe: TScrollBox
        Left = 2
        Top = 18
        Width = 299
        Height = 510
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Color = clWhite
        Ctl3D = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        object pcArama: TcxPageControl
          Properties.Images = Tablo.PNGImageList2
          Left = 0
          Top = 0
          Width = 299
          Height = 510
          Align = alClient
          TabOrder = 0
          Properties.CustomButtons.Buttons = <>
          Properties.HideTabs = True
          ClientRectBottom = 506
          ClientRectLeft = 4
          ClientRectRight = 295
          ClientRectTop = 4
        end
        object dokumListesi: TCategoryButtons
          Left = 0
          Top = 0
          Width = 299
          Height = 510
          Align = alClient
          ButtonFlow = cbfVertical
          ButtonHeight = 40
          ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
          Categories = <
            item
              Caption = 'Genel'
              Color = clWhite
              Collapsed = False
              GradientColor = clGray
              Items = <
                item
                  Caption = 'fgsdgdsg'
                  ImageIndex = 0
                end>
            end
            item
              Caption = 'G'#252'nel'
              Color = 16053492
              Collapsed = False
              Items = <
                item
                  Caption = 'a'
                end
                item
                  Caption = 'b'
                end
                item
                  Caption = 'c'
                end>
            end>
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          HotButtonColor = 14525318
          RegularButtonColor = clSilver
          SelectedButtonColor = 12303291
          TabOrder = 1
          OnButtonClicked = dokumListesiButtonClicked
        end
      end
    end
  end
  object pnlSol: TPanel
    Left = 305
    Top = 0
    Width = 674
    Height = 532
    Align = alClient
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 672
      Height = 131
      Align = alTop
      BevelOuter = bvLowered
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = -31
      object Label1: TcxLabel
        Left = 5
        Top = 66
        Caption = 'Rap&or Ad'#305' '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label2: TcxLabel
        Left = 5
        Top = 111
        Caption = 'A'#231#305'&klama '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label3: TcxLabel
        Left = 5
        Top = 88
        Caption = 'Grubu '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label4: TcxLabel
        Left = 328
        Top = 67
        Caption = 'Saya'#231' '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label5: TcxLabel
        Left = 328
        Top = 89
        Caption = 'Son Kullanan'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label6: TcxLabel
        Left = 328
        Top = 111
        Caption = 'Son Kul.Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 5
        Top = 43
        Caption = 'Rapor ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label8: TcxLabel
        Left = 328
        Top = 44
        Caption = 'Versiyon '
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelKullanan: TcxLabel
        Left = 466
        Top = 91
        Caption = '---'
        ParentFont = False
        Transparent = True
      end
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 664
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 68
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
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 7
          Visible = False
        end
        object ToolButton3: TToolButton
          Left = 68
          Top = 0
          Caption = 'Sil'
          ImageIndex = 8
          Visible = False
        end
        object ToolButton4: TToolButton
          Left = 136
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          Enabled = False
          ImageIndex = 9
          Style = tbsSeparator
        end
        object DokumTus: TToolButton
          Left = 144
          Top = 0
          Caption = 'Listele'
          ImageIndex = 1
          Visible = False
          OnClick = DokumTusClick
        end
        object ToolButton6: TToolButton
          Left = 212
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 20
          Style = tbsSeparator
        end
        object cxTabControl2: TcxTabControl
          Left = 220
          Top = 0
          Width = 2
          Height = 30
          TabOrder = 0
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 26
          ClientRectLeft = 4
          ClientRectRight = 4
          ClientRectTop = 4
        end
        object YaziciYaz: TToolButton
          Left = 222
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          Style = tbsTextButton
        end
        object ToolButton8: TToolButton
          Left = 290
          Top = 0
          Width = 8
          Caption = 'ToolButton5'
          ImageIndex = 19
          Style = tbsSeparator
        end
      end
      object EditRAPORADI: TcxDBLabel
        Left = 93
        Top = 66
        DataBinding.DataField = 'RAPORADI'
        DataBinding.DataSource = DtsDokumler
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Height = 21
        Width = 210
      end
      object EditGRUBU: TcxDBLabel
        Left = 93
        Top = 89
        DataBinding.DataField = 'GRUBU'
        DataBinding.DataSource = DtsDokumler
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Height = 21
        Width = 229
      end
      object cxDBTextEdit3: TcxDBLabel
        Left = 92
        Top = 42
        DataBinding.DataSource = DtsDokumler
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Height = 21
        Width = 125
      end
      object cxDBTextEdit1: TcxDBLabel
        AlignWithMargins = True
        Left = 466
        Top = 67
        AutoSize = True
        DataBinding.DataField = 'SAYAC'
        DataBinding.DataSource = DtsDokumler
        Properties.Orientation = cxoLeftBottom
        Style.BorderStyle = ebsNone
      end
      object cxDBTextEdit2: TcxDBLabel
        Left = 512
        Top = 89
        DataBinding.DataField = 'SONKULLANAN'
        DataBinding.DataSource = DtsDokumler
        Style.BorderStyle = ebsNone
        Visible = False
        Height = 21
        Width = 113
      end
      object cxDBTextEdit4: TcxDBLabel
        Left = 466
        Top = 111
        DataBinding.DataField = 'SONTARIH'
        DataBinding.DataSource = DtsDokumler
        Style.BorderStyle = ebsNone
        Height = 21
        Width = 113
      end
      object EditRAPORKODU: TcxDBLabel
        Left = 92
        Top = 43
        DataBinding.DataField = 'RAPORID'
        DataBinding.DataSource = DtsDokumler
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Height = 21
        Width = 211
      end
      object cxDBLabel2: TcxDBLabel
        Left = 466
        Top = 44
        DataBinding.DataField = 'VERSIYON'
        DataBinding.DataSource = DtsDokumler
        Style.BorderStyle = ebsNone
        Height = 21
        Width = 77
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 132
      Width = 672
      Height = 399
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object GBox1: TJvPanel
        Left = 0
        Top = 0
        Width = 672
        Height = 399
        HotTrackFont.Charset = DEFAULT_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -11
        HotTrackFont.Name = 'Tahoma'
        HotTrackFont.Style = []
        Align = alClient
        BevelOuter = bvNone
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
      end
    end
  end
  object TabDokum: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabDokumAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM DOKUMLER D '
      'WHERE --MODUL LIKE :M '
      'GRUBU ='#39'Sat'#305#351' Kasas'#305#39
      'ORDER BY GRUBU,RAPORADI')
    Left = 209
    Top = 177
  end
  object TabKosul: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KOSULLAR WHERE DOKUMID = :DID ORDER BY ID')
    Left = 216
    Top = 250
  end
  object qryListe: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 336
    Top = 253
  end
  object dsListe: TDataSource
    DataSet = qryListe
    Left = 398
    Top = 251
  end
  object DtsDokumler: TDataSource
    DataSet = TabDokum
    Left = 273
    Top = 178
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 432
    Top = 182
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
    object MenuItem1: TMenuItem
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
      object MenuItem2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
  end
  object frxSQLKomut: TfrxDBDataset
    UserName = 'SORGU'
    CloseDataSource = False
    DataSource = dsListe
    BCDToCurrency = False
    Left = 511
    Top = 249
  end
  object OpenDialog1: TOpenDialog
    InitialDir = 'c:\'
    Left = 586
    Top = 194
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 532
    Top = 147
  end
end
