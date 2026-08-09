object ReplikasyonDlg: TReplikasyonDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Replikasyon Arac'#305
  ClientHeight = 432
  ClientWidth = 805
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    805
    432)
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 0
    Width = 604
    Height = 432
    Align = alLeft
    PopupMenu = PopupMenu1
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsAktarilacak
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.MultiSelect = True
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1NAME: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.ValueType = 'Boolean'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        MinWidth = 10
        Options.Sorting = False
        Width = 23
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxGroupBox1: TcxGroupBox
    Left = 604
    Top = 0
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Ba'#287'lant'#305
    TabOrder = 1
    Height = 76
    Width = 200
    object BtnEntCnn: TcxButton
      Left = 100
      Top = 17
      Width = 90
      Height = 25
      Caption = 'Ba'#287'lan(Entegra)'
      TabOrder = 0
      OnClick = BtnEntCnnClick
    end
    object BtnGenCnn: TcxButton
      Left = 6
      Top = 17
      Width = 88
      Height = 25
      Caption = 'Ba'#287'lan(Kaynak)'
      TabOrder = 1
      OnClick = BtnGenCnnClick
    end
    object cxLabel1: TcxLabel
      Left = 12
      Top = 48
      Caption = '..'
    end
    object cxLabel2: TcxLabel
      Left = 104
      Top = 48
      Caption = '..'
    end
  end
  object cxGroupBox3: TcxGroupBox
    Left = 604
    Top = 75
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Aktar'#305'm Tipi'
    Enabled = False
    TabOrder = 2
    Height = 59
    Width = 200
    object cxImageComboBox1: TcxImageComboBox
      Left = 6
      Top = 26
      Properties.Items = <
        item
          Description = 'Genot'#305'pdan Rehber Al'
          ImageIndex = 0
          Value = 'Genot'#305'pdan Rehber Al'
        end
        item
          Description = 'Genot'#305'pa Rehber Ver'
          Value = 'Genot'#305'pa Rehber Ver'
        end
        item
          Description = 'Genot'#305'pdan Stok Faturas'#305' Al'
          Value = 'Genot'#305'pdan Stok Faturas'#305' Al'
        end
        item
          Description = 'Gentegre Devir(Cari,Banka,Kasa)'
          Value = 'Gentegre Devir(Cari,Banka,Kasa)'
        end
        item
          Description = 'Gentegre Devir('#199'ek,Senet)'
          Value = 'Gentegre Devir('#199'ek,Senet)'
        end
        item
          Description = 'Gentegre Devir(Cari Y'#305'l Detay)'
          Value = 'Gentegre Devir(Cari Y'#305'l Detay)'
        end
        item
          Description = 'Genot'#305'pdan Stok Kart Al'
          Value = 'Genot'#305'pdan Stok Kart Al'
        end
        item
          Description = 'Genot'#305'pa Stok Kart Ver'
          Value = 'Genot'#305'pa Stok Kart Ver'
        end>
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 0
      Width = 182
    end
  end
  object cxGroupBox4: TcxGroupBox
    Left = 604
    Top = 133
    Anchors = [akLeft, akTop, akRight]
    Caption = 'A'#231#305'klama'
    TabOrder = 3
    Height = 268
    Width = 200
    object cxRichEdit1: TcxRichEdit
      Left = 2
      Top = 18
      Align = alClient
      Properties.ReadOnly = True
      Lines.Strings = (
        'Rehber entegrasyonunda '#39'KOD'#39' ve '
        #39'FIRMA'#39' alanlar'#305' zorunlu alanlard'#305'r. '
        'di'#287'er t'#252'm alanlar opsiyoneldir. '
        'Aktar'#305'mda zorunlu alanlardan '
        'birinin bo'#351' kalmas'#305' durumunda o '
        'kay'#305't atlanacak ve bir sonraki '
        'kay'#305'ttan devam edilecektir..')
      TabOrder = 0
      Height = 248
      Width = 196
    end
  end
  object cxButton2: TcxButton
    Left = 607
    Top = 403
    Width = 194
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Aktar'#305'm'#305' Ba'#351'lat'
    Enabled = False
    TabOrder = 4
    OnClick = cxButton2Click
  end
  object TabAktarilacak: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '')
    Left = 478
    Top = 98
  end
  object DtsAktarilacak: TDataSource
    DataSet = TabAktarilacak
    Left = 477
    Top = 142
  end
  object CNNGenotip: TFDConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=GENOTIP;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=GEN2005;Data Source=.'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    AfterConnect = CNNGenotipAfterConnect
    AfterDisconnect = CNNGenotipAfterDisconnect
    Left = 548
    Top = 2
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 45
    Top = 47
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ImageIndex = 23
      OnClick = mnSe1Click
    end
    object mnTemizle1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Temizle'
      ImageIndex = 9
      OnClick = mnTemizle1Click
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = cxGrid1
    PopupMenus = <
      item
        GridView = cxGrid1DBTableView1
        HitTypes = []
        Index = 0
        PopupMenu = PopupMenu1
      end>
    Left = 45
    Top = 2
  end
  object ADOQuery1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 551
    Top = 100
  end
  object DataSource1: TDataSource
    DataSet = TabAktarilacak
    Left = 553
    Top = 143
  end
  object CNNEntegra: TFDConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=GENOTIP;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=GEN2005;Data Source=.'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    AfterConnect = CNNEntegraAfterConnect
    AfterDisconnect = CNNEntegraAfterDisconnect
    Left = 487
    Top = 2
  end
  object TabBizim: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '--------TABBIZIM---------'
      'select '
      #9'KOD,'
      #9'FIRMA,'
      #9'GRUP,'
      #9'KATEGORI,'
      #9'DURUM,'#9
      #9'OZELKOD,'#9
      #9'NOTLAR,'
      #9'YETKIKODU,'
      
        #9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERB' +
        'ILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-' +
        '1 AND RA.VARSAYILAN=40),'
      
        #9'CEP=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1' +
        ' AND RA.VARSAYILAN=42),'
      
        #9'FAX=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1' +
        ' AND RA.VARSAYILAN=41),'
      
        #9'ADRES=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBER' +
        'BILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=' +
        '-1 AND RA.VARSAYILAN=2),'#9
      
        #9'ILCE=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERB' +
        'ILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-' +
        '1 AND RA.VARSAYILAN=6),'#9
      
        #9'IL=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBIL' +
        'GI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 ' +
        'AND RA.VARSAYILAN=8),'#9
      
        #9'PK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBIL' +
        'GI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 ' +
        'AND RA.VARSAYILAN=4),'
      
        #9'VERGIDAI=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REH' +
        'BERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_' +
        'ID=-1 AND RA.VARSAYILAN=20),'
      
        #9'VERGINO=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=-1 AND RA.VARSAYILAN=22),'
      
        #9'WEB=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBI' +
        'LGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1' +
        ' AND RA.VARSAYILAN=48),'
      
        #9'EMAIL=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBER' +
        'BILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=' +
        '-1 AND RA.VARSAYILAN=46),'
      
        #9'FATURABASLIK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN' +
        ' REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.' +
        'YER_ID=-1 AND RA.VARSAYILAN=10),'
      
        #9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 AND Y' +
        'ERI=11 AND YER_ID=-1 ),'
      
        #9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE VD.VD' +
        ' = (SELECT BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON' +
        ' RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.V' +
        'ARSAYILAN=20)),'
      #9'--SELECT * FROM dbo.REHBERAYAR  SELECT * FROM dbo.REHBERBILGI'#9#9
      
        '                  VERGI=(SELECT TOP 1  BILGI FROM REHBERAYAR RA ' +
        'INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI' +
        ' WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=20)'
      
        #9'+'#39' / '#39'+(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=-1 AND RA.VARSAYILAN=22)'
      ''
      ''
      ''
      'from '
      #9'REHBER R '
      'WHERE '
      '                ID=-1'
      '--------TABBIZIM---------'
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      '')
    Left = 397
    Top = 29
  end
end

