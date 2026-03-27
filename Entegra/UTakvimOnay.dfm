object TakvimOnayDlg: TTakvimOnayDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Aksiyon Bilgi Ekran'#305
  ClientHeight = 563
  ClientWidth = 1003
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object Panel2: TPanel
    Left = 0
    Top = 201
    Width = 1003
    Height = 243
    Align = alClient
    TabOrder = 9
    ExplicitTop = 198
    ExplicitHeight = 246
    object cxLabel14: TcxLabel
      Left = 3
      Top = 3
      AutoSize = False
      Caption = 'Alacakl'#305' Bilgileri'
      Style.Shadow = True
      Height = 23
      Width = 121
    end
    object cxLabel3: TcxLabel
      Left = 5
      Top = 30
      Caption = 'Cari Kod'
      Transparent = True
    end
    object EditCariKod: TcxButtonEdit
      Left = 103
      Top = 26
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Style.Color = clWindow
      TabOrder = 2
      Width = 121
    end
    object cxLabel4: TcxLabel
      Left = 261
      Top = 30
      Caption = 'Cari Ad'
      Transparent = True
    end
    object EditCariAd: TcxTextEdit
      Left = 348
      Top = 26
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 4
      Width = 251
    end
    object EditREHBERID: TcxDBTextEdit
      Left = 261
      Top = 6
      DataBinding.DataField = 'REHBERID'
      DataBinding.DataSource = DtsKasa
      ParentColor = True
      Properties.ReadOnly = False
      TabOrder = 5
      Visible = False
      Width = 58
    end
    object PanelMusBankaHesap: TPanel
      Left = 1
      Top = 192
      Width = 1001
      Height = 50
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 6
      ExplicitTop = 195
      object cxLabel17: TcxLabel
        Left = 5
        Top = 5
        Caption = 'Banka Hesap Kodu'
        Transparent = True
      end
      object EditMusHesapKodu: TcxButtonEdit
        Left = 157
        Top = 4
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditMusHesapKoduPropertiesButtonClick
        TabOrder = 1
        Width = 121
      end
      object EditMUSTERIHESAPID: TcxDBTextEdit
        Left = 282
        Top = 4
        DataBinding.DataField = 'MUSTERIHESAPID'
        DataBinding.DataSource = DtsKasa
        ParentColor = True
        Properties.ReadOnly = False
        TabOrder = 2
        Visible = False
        Width = 58
      end
      object cxLabel16: TcxLabel
        Left = 347
        Top = 5
        Caption = 'Hesap Ad'#305
        Transparent = True
      end
      object EditMusHesapAdi: TcxTextEdit
        Left = 465
        Top = 4
        Properties.ReadOnly = True
        Style.Color = clBtnFace
        TabOrder = 4
        Width = 251
      end
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 997
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 5
    Transparent = True
    object SilTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 138
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 207
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object btnIptal: TToolButton
      Left = 215
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnIptalClick
    end
  end
  object ToolBarAlt: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 541
    Width = 997
    Height = 22
    Margins.Bottom = 0
    Align = alBottom
    AutoSize = True
    ButtonHeight = 20
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 6
    Transparent = True
    object NakitTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Nakit'
      ImageIndex = 8
      OnClick = NakitTusClick
    end
    object HavaleTus: TToolButton
      Left = 66
      Top = 0
      Caption = 'Havale/EFT'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object CekTus: TToolButton
      Left = 132
      Top = 0
      Caption = #199'ek'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnIptalClick
    end
    object SenetTus: TToolButton
      Left = 198
      Top = 0
      Caption = 'Senet'
      ImageIndex = 19
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 1003
    Height = 166
    Align = alTop
    TabOrder = 8
    object cxLabel1: TcxLabel
      Left = 5
      Top = 40
      Caption = 'T'#252'r'
      Transparent = True
    end
    object ComboTUR: TcxDBImageComboBox
      Left = 103
      Top = 38
      DataBinding.DataField = 'TUR'
      DataBinding.DataSource = DtsKasa
      ParentColor = True
      Properties.Items = <
        item
          Description = 'Devir'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Devir'
          Value = 2
        end
        item
          Description = 'Devir'
          Value = 3
        end
        item
          Description = 'Al'#305#351' Faturas'#305
          ImageIndex = 0
          Value = 11
        end
        item
          Description = 'Al'#305#351' Fi'#351'i'
          Value = 12
        end
        item
          Description = 'Sat'#305#351' Faturas'#305
          Value = 15
        end
        item
          Description = 'Sat'#305#351' Fi'#351'i'
          Value = 16
        end
        item
          Description = 'Kasa Tahsilat'
          Value = 21
        end
        item
          Description = 'Banka Tahsilat'
          Value = 22
        end
        item
          Description = #199'ekle Tahsilat'
          Value = 23
        end
        item
          Description = 'Senetle Tahsilat'
          Value = 24
        end
        item
          Description = 'Kasa '#214'deme'
          Value = 31
        end
        item
          Description = 'Banka '#214'deme'
          Value = 32
        end
        item
          Description = #199'ekle '#214'deme'
          Value = 33
        end
        item
          Description = 'Senetle '#214'deme'
          Value = 34
        end
        item
          Description = 'Tahsilat Plan'#305
          Value = 61
        end
        item
          Description = #214'deme Plan'#305
          Value = 71
        end
        item
          Description = 'Kredi '#214'deme'
          Value = 75
        end>
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object cxLabel9: TcxLabel
      Left = 5
      Top = 67
      Caption = 'Durum'
      Transparent = True
    end
    object ComboDURUM: TcxDBImageComboBox
      Left = 103
      Top = 65
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsKasa
      ParentColor = True
      Properties.Items = <
        item
          Description = 'Onay Bekliyor'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = #304'mza Bekliyor'
          Value = 1
        end
        item
          Description = 'G'#246'nderiliyor'
          Value = 2
        end
        item
          Description = 'Tamamland'#305
          Value = 3
        end>
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 121
    end
    object cxLabel13: TcxLabel
      Left = 6
      Top = 2
      AutoSize = False
      Caption = #304#351'lem Bilgileri'
      Style.Shadow = True
      Properties.LabelEffect = cxleFun
      Properties.LabelStyle = cxlsRaised
      Properties.PenWidth = 5
      Height = 24
      Width = 121
    end
    object cxDBDateEdit1: TcxDBDateEdit
      Left = 103
      Top = 110
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = DtsKasa
      TabOrder = 5
      Width = 121
    end
    object cxDBLabel1: TcxDBLabel
      Left = 348
      Top = 40
      DataBinding.DataField = 'KAYITTARIH'
      DataBinding.DataSource = DtsKasa
      Height = 16
      Width = 121
    end
    object cxLabel12: TcxLabel
      Left = 261
      Top = 39
      Caption = 'Kay'#305't Tarihi'
    end
    object EditMasrafKod: TcxButtonEdit
      Left = 348
      Top = 110
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditMasrafKodPropertiesButtonClick
      TabOrder = 8
      Width = 121
    end
    object cxLabel10: TcxLabel
      Left = 261
      Top = 111
      Caption = 'Masraf Kodu'
    end
    object cxDBTextEdit5: TcxDBTextEdit
      Left = 103
      Top = 137
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsKasa
      Properties.ReadOnly = False
      TabOrder = 10
      Width = 121
    end
    object cxLabel5: TcxLabel
      Left = 5
      Top = 138
      Caption = 'A'#231#305'klama'
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 5
      Top = 111
      Caption = #304#351'lem Tarihi'
      Transparent = True
    end
    object EditMASRAFID: TcxDBTextEdit
      Left = 418
      Top = 110
      DataBinding.DataField = 'MASRAFID'
      DataBinding.DataSource = DtsKasa
      Properties.ReadOnly = False
      TabOrder = 13
      Visible = False
      Width = 42
    end
    object cxLabel8: TcxLabel
      Left = 261
      Top = 67
      Caption = 'Tutar'
    end
    object EditTutar: TcxDBCurrencyEdit
      Left = 348
      Top = 66
      DataBinding.DataField = 'GIREN'
      DataBinding.DataSource = DtsKasa
      Properties.DisplayFormat = ',0.00;-,0.00'
      TabOrder = 15
      Width = 82
    end
    object cxDBComboBox1: TcxDBComboBox
      Left = 433
      Top = 66
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsKasa
      TabOrder = 16
      Width = 51
    end
    object cxButtonEdit1: TcxButtonEdit
      Left = 348
      Top = 137
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Style.Color = clWindow
      TabOrder = 17
      Width = 121
    end
    object cxLabel18: TcxLabel
      Left = 261
      Top = 138
      Caption = 'Fatura/Fi'#351' Id'
    end
    object LabelMasrafAd: TcxLabel
      Left = 484
      Top = 111
      Caption = '---'
    end
  end
  object MemoPlan: TMemo
    Left = 610
    Top = 94
    Width = 478
    Height = 35
    Ctl3D = False
    Lines.Strings = (
      '   select '
      
        'P.TUR,P.DURUM,P.EKLEMETARIHI as KAYITTARIH,P.PLANTARIHI as TARIH' +
        ',P.REHBERID,'
      'P.ACIKLAMA,P.HESAPTURU,P.HESAPID, '
      'MUSTERIHESAPID,'
      'P.GIREN,P.CIKAN,P.KUR,MASRAFID,'
      'P.EKLEYEN,P.DEGISTIREN'
      'from KASA P '
      'where P.ID =')
    ParentCtl3D = False
    TabOrder = 4
    Visible = False
  end
  object MemoPersonel: TMemo
    Left = 610
    Top = 299
    Width = 478
    Height = 35
    Ctl3D = False
    Lines.Strings = (
      '   select '
      
        'P.TUR,P.DURUM,P.TARIH as KAYITTARIH,P.TARIH,P.REHBERID,CARIKOD =' +
        ' R.KOD,'
      'CARIAD=R.FIRMA,ACIKLAMA=null,HESAPID=null,'
      'GIREN=0,CIKAN=MAAS,P.KUR,MASRAFID=NULL,'
      'P.EKLEYEN,P.DEGISTIREN'
      'from PLANMAAS P inner join REHBER R on R.ID = P.REHBERID'
      'where P.ID =')
    ParentCtl3D = False
    TabOrder = 7
    Visible = False
  end
  object MemoKasa: TMemo
    Left = 610
    Top = 135
    Width = 478
    Height = 35
    Lines.Strings = (
      'select '
      #9'K.TUR,K.DURUM,K.ISLEMTARIHI as KAYITTARIH,ISLEMTARIHI as '
      'TARIH,REHBERID,'
      #9'ACIKLAMA,HESAPTURU, HESAPID,MUSTERIHESAPID,'
      #9'GIREN,CIKAN,K.KUR,K.MASRAFID,'
      #9'K.EKLEYEN,K.DEGISTIREN'
      'from '
      '     KASA K (NOLOCK)'
      'where '
      #9'K.ID ='
      ''
      '')
    TabOrder = 0
    Visible = False
  end
  object MemoCek: TMemo
    Left = 610
    Top = 176
    Width = 478
    Height = 35
    Lines.Strings = (
      'select '
      #9'C.TUR,C.DURUM,C.TARIH as '
      'KAYITTARIH,TARIH=VADE,REHBERID,'
      #9
      'ACIKLAMA,HESAPTURU='#39'B'#39',HESAPID=BANKASUBELERID,'
      #9'HESAPTURU=NULL,MUSTERIHESAPID=NULL,'
      #9
      'GIREN=case when TUR in (23,24) then TUTAR else 0 end,'
      #9'CIKAN=case when TUR in (33,34) then TUTAR else 0 end,'
      #9'KUR,MASRAFID,'
      #9'C.EKLEYEN,C.DEGISTIREN'
      'from '
      #9'CEKSENETLER C  '
      'where C.ID =')
    TabOrder = 1
    Visible = False
  end
  object MemoKredi: TMemo
    Left = 610
    Top = 217
    Width = 478
    Height = 35
    Lines.Strings = (
      'select '
      'TUR=75,DURUM=ODENMIS,K.TARIH as '
      'KAYITTARIH,TARIH,REHBERID=BANKAKREDIHESAPID,'
      'ACIKLAMA, HESAPTURU='#39'B'#39','
      'HESAPID=BANKATICARIHESAPID,'
      'MUSTERIHESAPID=NULL,'
      'GIREN=0,CIKAN=TAKSIT,BH1.KUR,'
      'MASRAFID,'
      'K.EKLEYEN,K.DEGISTIREN'
      '    from KREDILER K inner join PLANKREDI KO on K.ID =KO.KREDIID'
      
        '    left outer join BANKAHESAPLAR BH1 on BH1.ID = K.BANKAKREDIHE' +
        'SAPID    '
      '    where KO.ID =    ')
    TabOrder = 2
    Visible = False
  end
  object MemoFat: TMemo
    Left = 610
    Top = 258
    Width = 478
    Height = 35
    Lines.Strings = (
      'select'
      #9'TUR,F.DURUM,F.TARIH as KAYITTARIH,FATURATARIH AS '
      'TARIH,REHBERID,ACIKLAMA, HESAPTURU=NULL,'
      #9'HESAPID=null,'
      #9'MUSTERIHESAPID=NULL,'
      #9'GIREN=case when TUR in (11,12)  then FATURA_TUTARI else 0 end, '
      #9'CIKAN=case when TUR in (15,16)  then FATURA_TUTARI else 0 end,'
      #9'KUR,MASRAFID,F.EKLEYEN,F.DEGISTIREN'
      'from '
      #9'FATBASLIK F'
      'where '
      #9'F.ID =')
    TabOrder = 3
    Visible = False
  end
  object Panel3: TPanel
    Left = 0
    Top = 444
    Width = 1003
    Height = 94
    Align = alBottom
    TabOrder = 10
    ExplicitLeft = 8
    object Label17: TcxLabel
      Left = 3
      Top = 30
      Caption = #214'deme Yeri'
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 5
      Top = 57
      Caption = 'Hesap Kodu'
      Transparent = True
    end
    object cxLabel7: TcxLabel
      Left = 345
      Top = 57
      Caption = 'Hesap Ad'#305
      Transparent = True
    end
    object EditHesapAdi: TcxTextEdit
      Left = 466
      Top = 56
      Properties.ReadOnly = True
      Style.Color = clBtnFace
      TabOrder = 2
      Width = 251
    end
    object EditHesapKodu: TcxButtonEdit
      Left = 157
      Top = 56
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxDBButtonEdit1PropertiesButtonClick
      TabOrder = 3
      Width = 121
    end
    object cxDBTextEdit2: TcxDBTextEdit
      Left = 467
      Top = 26
      DataBinding.DataField = 'HESAPID'
      DataBinding.DataSource = DtsKasa
      Properties.ReadOnly = True
      TabOrder = 4
      Visible = False
      Width = 42
    end
    object ComboBoxODEMEYERI: TcxDBImageComboBox
      Left = 157
      Top = 28
      DataBinding.DataField = 'HESAPTURU'
      DataBinding.DataSource = DtsKasa
      Properties.Items = <
        item
          Description = 'Kasa'
          ImageIndex = 0
          Value = 'K'
        end
        item
          Description = 'Banka'
          Value = 'B'
        end>
      TabOrder = 5
      Width = 121
    end
    object cxLabel15: TcxLabel
      Left = 9
      Top = 3
      AutoSize = False
      Caption = 'Bizim Bilgilerimiz'
      Style.Shadow = True
      Height = 23
      Width = 121
    end
    object EditHESAPID: TcxDBTextEdit
      Left = 348
      Top = 26
      DataBinding.DataField = 'HESAPID'
      DataBinding.DataSource = DtsKasa
      ParentColor = True
      Properties.ReadOnly = False
      TabOrder = 7
      Visible = False
      Width = 82
    end
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabKasaAfterOpen
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KASA where ID = :Prm')
    Left = 303
    Top = 35
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    OnStateChange = DtsKasaStateChange
    Left = 368
    Top = 35
  end
end


