object MaliyetlerListeFrame: TMaliyetlerListeFrame
  Left = 0
  Top = 0
  Width = 882
  Height = 562
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
  ExplicitWidth = 451
  ExplicitHeight = 304
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 876
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 56
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
    ExplicitWidth = 445
  end
  object DBPivotGridMaliyet: TcxDBPivotGrid
    Left = 0
    Top = 27
    Width = 882
    Height = 535
    Customization.AvailableFieldsSorted = True
    Customization.FormStyle = cfsAdvanced
    Align = alClient
    DataSource = DtsMaliyet
    Groups = <>
    PopupMenu = PopupMenu1
    TabOrder = 1
    ExplicitWidth = 451
    ExplicitHeight = 277
    object DBPivotGridMaliyetKOD: TcxDBPivotGridField
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Stok Kodu'
      DataBinding.FieldName = 'KOD'
      Visible = True
      UniqueName = 'Stok Kodu'
    end
    object DBPivotGridMaliyetSTOKADI: TcxDBPivotGridField
      Area = faRow
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Stok Ad'#305
      DataBinding.FieldName = 'STOKADI'
      Visible = True
      Width = 137
      UniqueName = 'Stok Ad'#305
    end
    object DBPivotGridMaliyetTARIH: TcxDBPivotGridField
      Area = faRow
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = 'Tarih'
      DataBinding.FieldName = 'TARIH'
      Visible = True
      UniqueName = 'Giri'#351' Tarihi'
    end
    object DBPivotGridMaliyetFATURANO: TcxDBPivotGridField
      AreaIndex = 2
      IsCaptionAssigned = True
      Caption = 'Belge No'
      DataBinding.FieldName = 'FATURANO'
      Visible = True
      UniqueName = 'Giri'#351' No'
    end
    object DBPivotGridMaliyetKULLANICI: TcxDBPivotGridField
      AreaIndex = 4
      IsCaptionAssigned = True
      Caption = 'Kullan'#305'c'#305
      DataBinding.FieldName = 'KULLANICI'
      Visible = True
      UniqueName = 'Sat'#305'nalan'
    end
    object DBPivotGridMaliyetSUBE: TcxDBPivotGridField
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = #350'ube'
      DataBinding.FieldName = 'SUBE'
      Visible = True
      UniqueName = 'Sat'#305#351' '#350'ube'
    end
    object DBPivotGridMaliyetFIRMA: TcxDBPivotGridField
      AreaIndex = 3
      IsCaptionAssigned = True
      Caption = 'Kurum'
      DataBinding.FieldName = 'FIRMA'
      Visible = True
      UniqueName = 'Al'#305'nan Kurum'
    end
    object DBPivotGridMaliyetMIKTAR: TcxDBPivotGridField
      Area = faData
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Miktar'
      DataBinding.FieldName = 'MIKTAR'
      Visible = True
      UniqueName = 'Miktar'
    end
    object DBPivotGridMaliyetKALAN: TcxDBPivotGridField
      Area = faData
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = 'Kalan'
      DataBinding.FieldName = 'KALAN'
      Visible = True
      UniqueName = 'Kalan'
    end
    object DBPivotGridMaliyetBIRIMMALIYET: TcxDBPivotGridField
      Area = faData
      AreaIndex = 2
      IsCaptionAssigned = True
      Caption = 'Birim Maliyet'
      DataBinding.FieldName = 'BIRIMMALIYET'
      Visible = True
      UniqueName = 'Giri'#351' Tutar'#305
    end
    object DBPivotGridMaliyetBIRIMTUTAR: TcxDBPivotGridField
      Area = faData
      AreaIndex = 3
      IsCaptionAssigned = True
      Caption = 'Birim Tutar'
      DataBinding.FieldName = 'BIRIMTUTAR'
      Visible = True
      UniqueName = #199#305'k'#305#351' Tutar'#305
    end
    object DBPivotGridMaliyetBIRIMKARLILIK: TcxDBPivotGridField
      Area = faData
      AreaIndex = 4
      IsCaptionAssigned = True
      Caption = 'Birim K'#226'rl'#305'l'#305'k'
      DataBinding.FieldName = 'BIRIMKARLILIK'
      Visible = True
      UniqueName = 'Birim K'#226'rl'#305'l'#305'k'
    end
    object DBPivotGridMaliyetKARLILIK: TcxDBPivotGridField
      Area = faData
      AreaIndex = 5
      IsCaptionAssigned = True
      Caption = 'K'#226'rl'#305'l'#305'k'
      DataBinding.FieldName = 'KARLILIK'
      Visible = True
      UniqueName = 'K'#226'rl'#305'l'#305'k'
    end
  end
  object TabMaliyet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PDepoID'
        Size = -1
        Value = Null
      end
      item
        Name = 'Tarih'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select '
      #9'ST.KOD,'
      #9'ST.STOKADI,'
      #9'SM.TARIH  ,'
      #9'FBA.FATURANO,'#9
      #9'KULLANICI=RST.FIRMA,'
      #9'SUBE=RSB.FIRMA,'
      #9'FIRMA=RF.FIRMA,'
      #9'SM.MIKTAR,'
      #9'SM.KALAN,'
      #9'SM.BIRIMMALIYET ,'
      #9'SM.BIRIMTUTAR ,'
      
        #9'BIRIMKARLILIK= case when SM.MIKTAR < 0.0 then SM.BIRIMTUTAR-SM.' +
        'BIRIMMALIYET else 0.0 end,'
      
        #9'KARLILIK = case when SM.MIKTAR < 0.0 then SM.BIRIMTUTAR-SM.BIRI' +
        'MMALIYET else 0.0 end*-SM.MIKTAR'
      'from '
      #9'STOK_ORT_MALIYET SM inner join '
      #9'STOKLAR ST on ST.ID=SM.STOKID left outer join'
      #9'FATURA FA on SM.FATURAID=FA.ID left outer join--al'#305#351' fatura'
      
        #9'FATBASLIK FBA on FA.FATBASID=FBA.ID left outer join--al'#305#351' fatba' +
        #351'l'#305'k'
      #9'REHBER RST on RST.ID=FBA.SATICIKODU left outer join--sat'#305'c'#305
      #9'REHBER RSB on RSB.ID=FBA.GIRISSUBE left outer join--sube'
      #9'REHBER RF on RF.ID=FBA.REHBERID--firma'
      'where SM.DEPOID=:PDepoID and SM.TARIH <= :Tarih'
      ''
      'order by SM.DEPOID,SM.STOKID,SM.TARIH'
      '')
    Left = 192
    Top = 176
  end
  object DtsMaliyet: TDataSource
    DataSet = TabMaliyet
    Left = 208
    Top = 280
  end
  object ExcelSaveDlg: TSaveDialog
    DefaultExt = 'xls'
    Filter = '*.xls|*.xls'
    InitialDir = '%USERPROFILE%\Desktop'
    Left = 288
    Top = 232
  end
  object PopupMenu1: TPopupMenu
    Left = 296
    Top = 192
    object Exceleaktar1: TMenuItem
      Caption = 'Excele aktar'
      OnClick = Exceleaktar1Click
    end
  end
end

