object TakvimGidenCekDlg: TTakvimGidenCekDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Giden '#199'ek'
  ClientHeight = 280
  ClientWidth = 705
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
  object Shape4: TShape
    Left = 218
    Top = 70
    Width = 260
    Height = 76
    Brush.Color = 16378589
  end
  object tlb1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 699
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
    object KaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 69
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = IptalTusClick
    end
    object SilTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton2: TToolButton
      Left = 207
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object BelgeTus: TToolButton
      Left = 215
      Top = 0
      Caption = 'Belge'
      ImageIndex = 28
      OnClick = BelgeTusClick
    end
    object btn1: TToolButton
      Left = 284
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object Iptal: TToolButton
      Left = 292
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = IptalClick
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 32
    Width = 705
    Height = 248
    Align = alClient
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 35
    ExplicitHeight = 245
    object cxTextEdit1: TcxTextEdit
      Left = 269
      Top = 3
      AutoSize = False
      Enabled = False
      ParentFont = False
      Properties.ReadOnly = True
      Style.Color = clSilver
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.BorderColor = clWhite
      StyleDisabled.Color = clSilver
      StyleDisabled.TextColor = clBackground
      TabOrder = 0
      Text = 'Giden '#199'ek'
      Height = 28
      Width = 83
    end
    object cxLabel1: TcxLabel
      Left = 14
      Top = 99
      Caption = 'Bu '#199'ek Kar'#351#305'l'#305#287#305'nda'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 574
      Top = 99
      Caption = 'Emrine,'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel3: TcxLabel
      Left = 14
      Top = 131
      Caption = 'Yaln'#305'z'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel4: TcxLabel
      Left = 565
      Top = 130
      Caption = #214'deyiniz.'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel5: TcxLabel
      Left = 541
      Top = 3
      Caption = 'Ke'#351'ide Tarihi:'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 401
      Top = 3
      Caption = 'Ke'#351'ide Yeri:'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBImage1: TcxDBImage
      Left = 3
      Top = 3
      DataBinding.DataField = 'BANKALOGO'
      DataBinding.DataSource = DtsCEK
      ParentColor = True
      Properties.PopupMenuLayout.MenuItems = [pmiLoad]
      Properties.Stretch = True
      TabOrder = 7
      Height = 70
      Width = 147
    end
    object cxLabel8: TcxLabel
      Left = 401
      Top = 30
      Caption = '.........................'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelKASIDEYERI: TcxDBLabel
      Tag = 1
      Left = 389
      Top = 24
      DataBinding.DataField = 'ODEMEYERI'
      DataBinding.DataSource = DtsCEK
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelKASIDETARIHIClick
      Height = 17
      Width = 122
      AnchorX = 450
    end
    object cxLabel10: TcxLabel
      Left = 537
      Top = 30
      Caption = '....................'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel11: TcxLabel
      Left = 128
      Top = 104
      Caption = 
        '................................................................' +
        '..............................................'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel12: TcxLabel
      Left = 59
      Top = 135
      Caption = 
        '................................................................' +
        '.............................................................'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelYAZIYLA: TcxDBLabel
      Left = 56
      Top = 131
      DataBinding.DataField = 'YAZIYLATUTAR'
      DataBinding.DataSource = DtsCEK
      ParentColor = False
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Style.Color = 16378589
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
      Height = 18
      Width = 503
      AnchorX = 308
    end
    object LabelKASIDETARIHI: TcxDBLabel
      Tag = 2
      Left = 541
      Top = 24
      DataBinding.DataField = 'VADE'
      DataBinding.DataSource = DtsCEK
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelKASIDETARIHIClick
      Height = 17
      Width = 78
    end
    object cxLabel7: TcxLabel
      Left = 401
      Top = 74
      Caption = '......................................................'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelFIRMA: TcxDBLabel
      Tag = 1
      Left = 232
      Top = 162
      AutoSize = True
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = Tablo.DtsBizim
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelADRES: TcxDBLabel
      Left = 232
      Top = 177
      DataBinding.DataField = 'ADRES'
      DataBinding.DataSource = Tablo.DtsBizim
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Properties.WordWrap = True
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -9
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
      Height = 32
      Width = 154
    end
    object LabelVERGI: TcxDBLabel
      Left = 232
      Top = 206
      AutoSize = True
      DataBinding.DataField = 'VERGIDAI'
      DataBinding.DataSource = Tablo.DtsBizim
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -9
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelCirolu: TcxLabel
      Left = 269
      Top = 32
      AutoSize = False
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Transparent = True
      Height = 20
      Width = 83
      AnchorX = 311
    end
    object LabelTUTAR: TcxDBLabel
      Tag = 1
      Left = 466
      Top = 66
      AutoSize = True
      DataBinding.DataField = 'TUTAR'
      DataBinding.DataSource = DtsCEK
      ParentColor = False
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Style.Color = 16378589
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelTUTARClick
      AnchorX = 510
      AnchorY = 78
    end
    object LabelVergiNo: TcxDBLabel
      Left = 292
      Top = 206
      AutoSize = True
      DataBinding.DataField = 'VERGINO'
      DataBinding.DataSource = Tablo.DtsBizim
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -9
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ImageGon: TJvDBImage
      Left = 128
      Top = 166
      Width = 98
      Height = 51
      BorderStyle = bsNone
      Color = clBtnFace
      DataField = 'LOGO'
      DataSource = Tablo.DtsBizim
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -1
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      Stretch = True
      TabOrder = 22
      TabStop = False
      BevelInner = bvNone
      BevelOuter = bvNone
      Transparent = True
    end
    object LabelHitap: TcxLabel
      Left = 287
      Top = 96
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -15
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
    end
  end
  object LabelDiyez: TcxLabel
    Left = 449
    Top = 101
    Caption = '# '
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsItalic]
    Style.IsFontAssigned = True
    Transparent = True
  end
  object LabelTLDiyez: TcxLabel
    Left = 560
    Top = 101
    Caption = ' TL. #'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsItalic]
    Style.IsFontAssigned = True
    Transparent = True
    OnClick = LabelTUTARClick
  end
  object TabCEK: TFDQuery
    Connection = Tablo.FDCnn
    AfterPost = TabCEKAfterPost
    ParamData = <>
    SQL.Strings = (
      'select '
      #9'--'#199'EK BANKA B'#304'LG'#304'LER'#304
      #9'BS.BANKAKODU,BS.SUBEKODU,BS.SUBEADI,BANKALOGO=B.LOGO,'
      ''
      #9'--'#199'EK G'#214'NDEREN B'#304'LG'#304'LER'#304
      ''
      #9'R.FIRMA,'
      
        #9'LOGO=(SELECT TOP 1  BELGE FROM IMAJ WHERE VARSAYILAN=1 AND YER_' +
        'ID=R.ID AND YERI=11),'
      ''
      #9'ODEMEYERI,--KA'#350#304'DEYER'#304'??'
      
        '    ADRES=((SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN RE' +
        'HBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER' +
        '_ID=R.ID AND RA.VARSAYILAN=2)+'#39' '#39
      
        '    +(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.' +
        'ID AND RA.VARSAYILAN=4)+'#39' '#39
      
        '    +(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.' +
        'ID AND RA.VARSAYILAN=6)+'#39' '#39
      
        '    +(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.' +
        'ID AND RA.VARSAYILAN=8)),'
      
        '    VERGI=(LTRIM(RTRIM(ISNULL((SELECT  TOP 1 BILGI FROM REHBERAY' +
        'AR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=R' +
        'B.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),'#39#39'))))'
      
        #9'+'#39' / '#39'+LTRIM(RTRIM(ISNULL((SELECT  TOP 1 BILGI FROM REHBERAYAR ' +
        'RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.Y' +
        'ERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),'#39#39'))),'
      #9
      #9'--PARA B'#304'LG'#304'LER'#304' '
      #9'YAZIYLATUTAR='#39'# '#39'+DBO.fn_MoneyToText(TUTAR,'#39'L'#304'RA'#39','#39'KURU'#350#39')+'#39'#'#39','
      #9
      #9'--EK B'#304'LG'#304'LER,'
      '    CEKTUTAR = '#39'#'#39'+DBO.fn_MoneyToVarchar(TUTAR)+'#39'#'#39
      '    ,c.*'
      #9
      '--SELECT *'#9
      'from '
      #9'CEKLER C INNER JOIN'
      #9'REHBER R ON '
      #9#9'R.ID=C.REHBERID INNER JOIN'
      #9'BANKASUBELER BS ON '
      #9#9'C.BANKASUBELERID=BS.ID INNER JOIN'
      #9'BANKALAR B ON'
      #9#9'BS.BANKAKODU=B.BANKAKODU'
      ''
      'where '
      #9'C.ID = :Prm')
    Left = 57
    Top = 41
  end
  object DtsCEK: TDataSource
    DataSet = TabCEK
    OnStateChange = DtsCEKStateChange
    Left = 19
    Top = 40
  end
end


