object EkipmanListeDlg: TEkipmanListeDlg
  Left = 0
  Top = 0
  Width = 1095
  Height = 577
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
    Width = 1089
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 74
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
    object DegisTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
    object SilTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 222
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 230
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
  end
  object TreeListEkipman: TcxDBTreeList
    Left = 0
    Top = 35
    Width = 1095
    Height = 542
    Align = alClient
    Bands = <
      item
      end>
    DataController.DataSource = DtsEkipmanlar
    DataController.ParentField = 'USTID'
    DataController.KeyField = 'ALTID'
    LookAndFeel.ScrollbarMode = sbmClassic
    Navigator.Buttons.CustomButtons = <>
    OptionsCustomizing.DynamicSizing = True
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsSelection.CellSelect = False
    OptionsView.Indicator = True
    RootValue = -1
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 1
    OnDblClick = TreeListEkipmanDblClick
    object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
      Caption.Text = 'Kodu'
      DataBinding.FieldName = 'KOD'
      Width = 100
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn
      Caption.Text = 'Ad'#305
      DataBinding.FieldName = 'AD'
      Width = 215
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn6: TcxDBTreeListColumn
      RepositoryItem = Tablo.RepServisEkipmanTur
      Caption.Text = 'T'#252'r'#252
      DataBinding.FieldName = 'EKIPMANTUR'
      Width = 100
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object TreeListEkipmancxDBTreeListSTOKLU: TcxDBTreeListColumn
      PropertiesClassName = 'TcxImageComboBoxProperties'
      Properties.Images = Tablo.imgScheduler
      Properties.Items = <
        item
          Value = False
        end
        item
          ImageIndex = 14
          Value = True
        end>
      Caption.Text = 'Stoklu'
      DataBinding.FieldName = 'STOKLU'
      Width = 41
      Position.ColIndex = 3
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn7: TcxDBTreeListColumn
      Caption.Text = 'A'#231#305'klama'
      DataBinding.FieldName = 'ACIKLAMA'
      Width = 300
      Position.ColIndex = 7
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListSAHIP: TcxDBTreeListColumn
      PropertiesClassName = 'TcxImageComboBoxProperties'
      Properties.Images = Tablo.PNGImageList2
      Properties.Items = <
        item
          ImageIndex = 27
          Value = False
        end
        item
          ImageIndex = 28
          Value = True
        end>
      Caption.Text = 'Sahibi'
      DataBinding.FieldName = 'SAHIP'
      Width = 100
      Position.ColIndex = 4
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListMARKA: TcxDBTreeListColumn
      Caption.Text = 'Marka'
      DataBinding.FieldName = 'MARKAAD'
      Width = 100
      Position.ColIndex = 5
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListMODEL: TcxDBTreeListColumn
      Caption.Text = 'Model'
      DataBinding.FieldName = 'MODELAD'
      Width = 100
      Position.ColIndex = 6
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 141
    Top = 131
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
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabEkipmanlar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'WITH PagesList (EkipmanID,TreeID) AS'
      ''
      '('#9'SELECT -- Anchor member definition'
      #9#9'E.ID,'
      #9#9'TreeID=convert(nvarchar(254),E.ID)'
      #9'FROM EKIPMANLAR E '
      #9'UNION ALL'#9
      #9'SELECT -- Recursive member definition'
      #9#9'ED.EKIPMANID,'
      
        #9#9'TreeID =  convert(nvarchar(254),TreeID+N'#39'.'#39'+convert(nvarchar(2' +
        '00),ED.EKIPMANID)) '
      
        #9'From EKIPMANDETAY as ED INNER JOIN PagesList as p ON ED.USTEKIP' +
        'MANID = p.EkipmanID'
      ')-- Statement that executes the CTE'
      ''
      ''
      'SELECT '
      'ALTID=TreeID,'
      'USTID=case when CHARINDEX('#39'.'#39',TreeID,1)=0 then '#39#39' else'
      
        'REVERSE(SUBSTRING(REVERSE(TreeID),CHARINDEX('#39'.'#39',REVERSE(TreeID),' +
        '1)+1,LEN(TreeID)-(CHARINDEX('#39'.'#39',REVERSE(TreeID),1)-1)))'
      'end ,E2.*,'
      
        'STOKLU=convert(bit, case when isnull(URUNID,'#39#39')<>'#39#39' then 1 else ' +
        '0 end),'
      
        'MARKAAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=-2727 and DEGER=E2.MARKA and DIL=-1)'
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
        'DEGER=E2.MARKA and DIL=-1) end) ,'
      
        'MODELAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),E2.MA' +
        'RKA)) and DEGER=E2.MODEL and DIL=-1) '
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
        't,'#39'-2701'#39'+convert(varchar(10),E2.MARKA)) and DEGER=E2.MODEL and ' +
        'DIL=-1) end)'
      'FROM PagesList p '
      'inner join EKIPMANLAR E2 on E2.ID = p.EkipmanID'
      'order by 2,AD'
      '')
    Left = 283
    Top = 133
  end
  object DtsEkipmanlar: TDataSource
    DataSet = TabEkipmanlar
    Left = 292
    Top = 203
  end
  object frxEkipmanlar: TfrxDBDataset
    Description = 'Ekipmanlar'
    UserName = 'Ekipmanlar'
    CloseDataSource = False
    DataSet = TabEkipmanlar
    BCDToCurrency = False
    DataSetOptions = []
    Left = 146
    Top = 209
  end
end

