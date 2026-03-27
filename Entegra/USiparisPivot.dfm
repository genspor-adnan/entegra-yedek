object SiparisPivotDlg: TSiparisPivotDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsNone
  Caption = 'SiparisPivotDlg'
  ClientHeight = 590
  ClientWidth = 989
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 164
    Top = 132
    Width = 32
    Height = 13
    Caption = 'FIRMA'
  end
  object Label2: TLabel
    Left = 28
    Top = 150
    Width = 44
    Height = 13
    Caption = 'STOKADI'
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 989
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
    ExplicitWidth = 759
    object KapatTus: TJvNavPanelButton
      Left = 909
      Top = 0
      Width = 80
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
      ExplicitLeft = 1087
      ExplicitTop = 1
    end
    object YaziciYaz: TJvNavPanelButton
      Left = 773
      Top = 0
      Width = 136
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Yazd'#305'r'
      DropDownMenu = PopupMenuYaz
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
      ImageIndex = 0
      Images = Tablo.cxImageList2
      ExplicitLeft = 543
      ExplicitTop = -1
    end
    object cxLabel9: TcxLabel
      Left = 6
      Top = 1
      AutoSize = False
      Caption = 'Sipari'#351'ler'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -24
      Style.Font.Name = 'Microsoft Sans Serif'
      Style.Font.Style = [fsBold, fsItalic]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Transparent = True
      Height = 33
      Width = 164
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 37
    Width = 989
    Height = 41
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 759
    object Panel2: TPanel
      Left = 3
      Top = 5
      Width = 155
      Height = 31
      Align = alCustom
      Caption = 'Panel1'
      TabOrder = 3
      object BtnOnceki: TJvNavPanelButton
        Tag = -1
        Left = 1
        Top = 1
        Width = 51
        Height = 29
        Align = alLeft
        Alignment = taCenter
        Caption = '<<'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 1
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        ImageIndex = 3
        OnClick = BtnBugunClick
        ExplicitLeft = 0
      end
      object BtnDun: TJvNavPanelButton
        Tag = 1
        Left = 103
        Top = 1
        Width = 51
        Height = 29
        Align = alLeft
        Alignment = taCenter
        Caption = '>>'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 1
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        ImageIndex = 3
        OnClick = BtnBugunClick
        ExplicitLeft = 132
        ExplicitTop = 3
      end
      object BtnBugun: TJvNavPanelButton
        Left = 52
        Top = 1
        Width = 51
        Height = 29
        Align = alLeft
        Alignment = taCenter
        Caption = 'Bug'#252'n'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 1
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        ImageIndex = 3
        OnClick = BtnBugunClick
        ExplicitLeft = 78
        ExplicitTop = -4
      end
    end
    object LabelBastar: TJvDateTimePicker
      Left = 175
      Top = 4
      Width = 150
      Height = 33
      Date = 41430.577444641200000000
      Time = 41430.577444641200000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = LabelBastarChange
      DropDownDate = 41430.000000000000000000
      NullDate = 36526.000000000000000000
    end
    object LabelBittar: TJvDateTimePicker
      Left = 329
      Top = 3
      Width = 150
      Height = 33
      Date = 41430.577444641200000000
      Time = 41430.577444641200000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = LabelBastarChange
      DropDownDate = 41430.000000000000000000
      NullDate = 36526.000000000000000000
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 486
      Top = 4
      RepositoryItem = Tablo.RepStokKaynakUretimYeri
      ParentFont = False
      Properties.Items = <>
      Properties.OnChange = LabelBastarChange
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -21
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 2
      Width = 225
    end
  end
  object cxDBPivotGrid1: TcxDBPivotGrid
    Left = 0
    Top = 78
    Width = 989
    Height = 512
    Align = alClient
    DataSource = DtsPivot
    Groups = <>
    OptionsView.ColumnGrandTotalText = 'Toplam'
    OptionsView.RowGrandTotalText = 'Toplam'
    TabOrder = 2
    ExplicitWidth = 759
    ExplicitHeight = 409
    object cxDBPivotGrid1FIRMA: TcxDBPivotGridField
      Area = faColumn
      AreaIndex = 0
      DataBinding.FieldName = 'FIRMA'
      Visible = True
      Width = 76
      UniqueName = 'FIRMA'
    end
    object cxDBPivotGrid1STOKADI: TcxDBPivotGridField
      Area = faRow
      AreaIndex = 0
      DataBinding.FieldName = 'STOKADI'
      Visible = True
      UniqueName = 'STOKADI'
    end
    object cxDBPivotGrid1ADET: TcxDBPivotGridField
      Area = faData
      AreaIndex = 0
      DataBinding.FieldName = 'ADET'
      Visible = True
      UniqueName = 'ADET'
    end
    object cxDBPivotGrid1URETICIID: TcxDBPivotGridField
      AreaIndex = 0
      DataBinding.FieldName = 'URETICIID'
      Styles.Content = Tablo.cxstKismiIade
      Visible = True
      UniqueName = 'URETICIID'
    end
    object cxDBPivotGrid1BIRIMAD: TcxDBPivotGridField
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = 'BIRIM'
      DataBinding.FieldName = 'BIRIMAD'
      Visible = True
      UniqueName = 'BIRIM'
    end
  end
  object Memo1: TMemo
    Left = 22
    Top = 218
    Width = 630
    Height = 41
    Color = clHighlight
    Lines.Strings = (
      'SELECT'
      #9'FIRMA,STOKADI,URETICIID,SUM(ADET) AS ADET,BIRIMAD'
      'FROM('
      'select '
      #9'R.FIRMA,'
      
        #9'STK.STOKADI, URETICIID =(select top 1 ANAHTAR from GENINI  G wh' +
        'ere STK.URETICIID=G.DEGER and BOLUM=-'
      '2791 '
      'and DIL=-1 ),'
      #9'ADET=CASE WHEN ISNULL(ADET,'#39#39')='#39#39' THEN 0 ELSE ADET END,'
      
        #9'BIRIMAD=(select  ANAHTAR from GENINI  G where SD.BIRIM=G.DEGER ' +
        'and BOLUM=-2702 and DIL=-1 )'
      'from '
      #9'SIPARISDETAY SD '
      #9#9'INNER JOIN SIPARIS S ON '
      #9#9#9'SD.SIPARISID=S.ID'
      #9#9'INNER JOIN REHBER R ON SD.REHBERID=R.ID'
      #9#9'INNER JOIN STOKLAR STK ON SD.URUNID=STK.ID'
      'WHERE'
      '  S.TARIH BETWEEN :Baslangic AND :Bitis AND '#9
      '    S.TUR=19'
      '    --URETICIID'
      ') AS X'
      'GROUP BY'
      #9'FIRMA, STOKADI, URETICIID, BIRIMAD'
      #9
      'ORDER BY STOKADI,FIRMA')
    TabOrder = 3
    Visible = False
  end
  object DtsPivot: TDataSource
    DataSet = TabPivot
    Left = 467
    Top = 180
  end
  object TabPivot: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 264
    Top = 197
    object TabPivotFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabPivotSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabPivotADET: TFloatField
      FieldName = 'ADET'
      ReadOnly = True
    end
    object TabPivotURETICIID: TWideStringField
      FieldName = 'URETICIID'
      ReadOnly = True
      Size = 100
    end
    object TabPivotBIRIMAD: TWideStringField
      FieldName = 'BIRIMAD'
      ReadOnly = True
      Size = 100
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.cxImageList2
    Left = 633
    Top = 51
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 0
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
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxPivot: TfrxDBDataset
    UserName = 'frxSiparis'
    CloseDataSource = False
    DataSet = TabPivot
    BCDToCurrency = False
    Left = 400
    Top = 126
  end
  object JvPopupMenu1: TJvPopupMenu
    Images = Tablo.cxImageList1
    ImageMargin.Left = 0
    ImageMargin.Top = 0
    ImageMargin.Right = 0
    ImageMargin.Bottom = 0
    ImageSize.Height = 0
    ImageSize.Width = 0
    Left = 505
    Top = 261
    object ddd1: TMenuItem
      Caption = 'ddd'
      ImageIndex = 33
    end
  end
end
