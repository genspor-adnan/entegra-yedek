object TalimatOnayDlg: TTalimatOnayDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Talimat Onay Ekran'#305
  ClientHeight = 364
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 144
    Top = 41
    Width = 518
    Height = 282
    Align = alClient
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsKasa
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1KOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 101
      end
      object cxGrid1DBTableView1FIRMA: TcxGridDBColumn
        Caption = 'Alacakl'#305
        DataBinding.FieldName = 'FIRMA'
        Width = 168
      end
      object cxGrid1DBTableView1ALACAK: TcxGridDBColumn
        Caption = 'Alacak'
        DataBinding.FieldName = 'ALACAK'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 49
      end
      object cxGrid1DBTableView1KUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        Width = 24
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 278
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 144
    Height = 282
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      144
      282)
    object cxDBLabel3: TcxDBLabel
      Left = 5
      Top = 61
      DataBinding.DataField = 'HESAPNO'
      DataBinding.DataSource = DtsOzet
      Transparent = True
      Height = 21
      Width = 133
    end
    object cxDBLabel4: TcxDBLabel
      Left = 5
      Top = 76
      DataBinding.DataField = 'IBAN'
      DataBinding.DataSource = DtsOzet
      Properties.WordWrap = True
      Transparent = True
      Height = 51
      Width = 133
    end
    object cxDBLabel6: TcxDBLabel
      Left = 42
      Top = 257
      Anchors = [akLeft, akBottom]
      DataBinding.DataField = 'ALACAK'
      DataBinding.DataSource = DtsOzet
      ParentFont = False
      Properties.Alignment.Horz = taRightJustify
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
      Height = 21
      Width = 50
      AnchorX = 92
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 257
      Anchors = [akLeft, akBottom]
      Caption = 'Toplam:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel2: TcxDBLabel
      Left = 5
      Top = 34
      DataBinding.DataField = 'HESAPADI'
      DataBinding.DataSource = DtsOzet
      Properties.WordWrap = True
      Transparent = True
      Height = 32
      Width = 133
    end
    object cxDBLabel7: TcxDBLabel
      Left = 5
      Top = 21
      DataBinding.DataField = 'HESAPKODU'
      DataBinding.DataSource = DtsOzet
      Transparent = True
      Height = 18
      Width = 133
    end
    object cxDBLabel8: TcxDBLabel
      Left = 92
      Top = 257
      Anchors = [akLeft, akBottom]
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsOzet
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
      Height = 21
      Width = 26
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 323
    Width = 662
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      662
      41)
    object BtnOnay: TButton
      Left = 443
      Top = 6
      Width = 104
      Height = 31
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Anchors = [akTop, akRight]
      Caption = 'Onay'
      DisabledImageIndex = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 11
      ImageIndex = 11
      ImageMargins.Left = 1
      ImageMargins.Top = 1
      ImageMargins.Right = 1
      ImageMargins.Bottom = 1
      ParentFont = False
      ParentShowHint = False
      PressedImageIndex = 11
      SelectedImageIndex = 11
      ShowHint = True
      TabOrder = 0
      OnClick = BtnOnayClick
    end
    object BtnRet: TButton
      Left = 553
      Top = 6
      Width = 104
      Height = 31
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Anchors = [akTop, akRight]
      Caption = 'Ret'
      DisabledImageIndex = 31
      DoubleBuffered = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 31
      ImageIndex = 31
      ImageMargins.Left = 1
      ImageMargins.Top = 1
      ImageMargins.Right = 1
      ImageMargins.Bottom = 1
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = BtnRetClick
    end
    object BtnBelge: TButton
      Left = 333
      Top = 6
      Width = 104
      Height = 31
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Anchors = [akTop, akRight]
      Caption = 'Belgeyi A'#231
      DisabledImageIndex = 30
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 30
      ImageIndex = 30
      ImageMargins.Left = 1
      ImageMargins.Top = 1
      ImageMargins.Right = 1
      ImageMargins.Bottom = 1
      ParentFont = False
      ParentShowHint = False
      PressedImageIndex = 30
      SelectedImageIndex = 30
      ShowHint = True
      TabOrder = 2
      OnClick = BtnBelgeClick
    end
    object LabelParmakIzi: TcxLabel
      Left = 5
      Top = 2
      Caption = '                 '
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 662
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object cxDBLabel1: TcxDBLabel
      Left = 144
      Top = 1
      DataBinding.DataField = 'BANKAADI'
      DataBinding.DataSource = DtsOzet
      Transparent = True
      Height = 21
      Width = 353
    end
    object cxDBLabel5: TcxDBLabel
      Left = 144
      Top = 17
      DataBinding.DataField = 'SUBEADI'
      DataBinding.DataSource = DtsOzet
      Transparent = True
      Height = 21
      Width = 353
    end
  end
  object JvDBImage1: TJvDBImage
    Left = 0
    Top = 1
    Width = 103
    Height = 59
    BorderStyle = bsNone
    DataField = 'LOGO'
    DataSource = DtsOzet
    Stretch = True
    TabOrder = 4
    BevelInner = bvNone
    BevelOuter = bvNone
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PTalimatID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
    SQL.Strings = (
      'select R.KOD,R.FIRMA,K.ALACAK,K.KUR,K.ACIKLAMA'
      ''
      'from KASA K '
      'inner join REHBER R on K.REHBERID=R.ID'
      'inner join TALIMATDETAY TD on K.ID=TD.KASAID'
      ''
      ''
      ''
      'where TD.TALIMATID=:PTalimatID')
    Left = 259
    Top = 69
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    Left = 258
    Top = 123
  end
  object TabOzet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pTalimatID'
        DataType = ftWideString
        Size = 1
        Value = '0'
      end>
    SQL.Strings = (
      'SELECT'
      ' ASD.HESAPID,'
      ' B.LOGO,'
      ' B.BANKAADI,'
      ' ASD.SUBEADI,  '
      ' asd.HESAPKODU,'
      ' HESAPNO=LTRIM(RTRIM(ASD.SUBEKODU))+'#39' - '#39'+ASD.HESAPNO,'
      ' ASD.HESAPADI,'
      ' ASD.IBAN,'
      ' ALACAK=convert(varchar(20),(ASD.ALACAK)),'
      ' ASD.KUR,'
      ' ASD.FIRMANO,'
      'ASD.TALIMATID'
      ''
      'FROM'
      'BANKALAR B INNER JOIN'
      '('
      'select DISTINCT'
      ''
      
        'ALACAK=SUM(P.ALACAK),P.KUR,P.HESAPID,B.BANKAKODU,BS.SUBEKODU,BS.' +
        'SUBEADI,BH.HESAPNO,'
      
        'BH.MUSTERINO,BH.FIRMANO,BH.EPOSTA,BH.HESAPADI,BH.IBAN,bh.HESAPKO' +
        'DU,TD.TALIMATID'
      ''
      'FROM'
      'KASA P'
      'inner join BANKAHESAPLAR BH on BH.ID = P.HESAPID'
      'inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU = BS.BANKAKODU'
      'inner join TALIMATDETAY TD on P.ID=TD.KASAID'
      'WHERE'
      'TD.TALIMATID=:pTalimatID'
      'GROUP BY '
      
        'B.BANKAKODU,BS.SUBEKODU,BS.SUBEADI,BH.HESAPNO,P.HESAPID,BH.HESAP' +
        'KODU,'
      
        'BH.MUSTERINO,BH.FIRMANO,BH.EPOSTA,BH.HESAPADI,BH.IBAN,P.KUR,TD.T' +
        'ALIMATID'
      ') ASD ON'
      'B.BANKAKODU=ASD.BANKAKODU'
      '')
    Left = 201
    Top = 69
  end
  object DtsOzet: TDataSource
    DataSet = TabOzet
    Left = 201
    Top = 125
  end
end

