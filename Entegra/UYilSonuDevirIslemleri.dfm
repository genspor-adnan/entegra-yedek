object YilSonuDevirIslemleriDlg: TYilSonuDevirIslemleriDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Y'#305'lsonu Devir '#304#351'lemleri'
  ClientHeight = 361
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 294
    Height = 361
    Align = alClient
    TabOrder = 0
    object BtnOlustur: TcxButton
      Left = 30
      Top = 287
      Width = 108
      Height = 26
      Caption = 'Devirleri Olu'#351'tur'
      TabOrder = 8
      OnClick = BtnOlusturClick
    end
    object BtnSil: TcxButton
      Left = 144
      Top = 287
      Width = 108
      Height = 26
      Caption = 'Devirleri Sil'
      TabOrder = 16
      OnClick = BtnSilClick
    end
    object CheckCari: TcxCheckBox
      Tag = 1
      Left = 5
      Top = 79
      Caption = 'Cari Kay'#305'tlar'
      State = cbsChecked
      TabOrder = 3
      Transparent = True
    end
    object CheckKasa: TcxCheckBox
      Tag = 2
      Left = 5
      Top = 99
      Caption = 'Kasalar'
      State = cbsChecked
      TabOrder = 4
      Transparent = True
    end
    object CheckBanka: TcxCheckBox
      Tag = 3
      Left = 5
      Top = 119
      Caption = 'Bankalar'
      State = cbsChecked
      TabOrder = 5
      Transparent = True
    end
    object CheckPos: TcxCheckBox
      Tag = 4
      Left = 5
      Top = 139
      Caption = 'POS'
      State = cbsChecked
      TabOrder = 6
      Transparent = True
    end
    object CheckStok: TcxCheckBox
      Tag = 5
      Left = 5
      Top = 178
      Caption = 'Stoklar'
      State = cbsChecked
      TabOrder = 7
      Transparent = True
    end
    object SpinYil: TcxSpinEdit
      Left = 111
      Top = 41
      Properties.ImmediatePost = True
      Properties.MaxValue = 2049.000000000000000000
      Properties.MinValue = 2010.000000000000000000
      Properties.OnEditValueChanged = SpinYilPropertiesEditValueChanged
      TabOrder = 1
      Value = 2012
      Width = 49
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 42
      Caption = 'Devir Yap'#305'lacak Y'#305'l'
      Transparent = True
    end
    object LbCari: TcxLabel
      Left = 141
      Top = 83
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object LbKasa: TcxLabel
      Left = 141
      Top = 103
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object LbBanka: TcxLabel
      Left = 141
      Top = 123
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object LbPos: TcxLabel
      Left = 141
      Top = 143
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object LbStok: TcxLabel
      Left = 141
      Top = 182
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object cxLabel2: TcxLabel
      Left = 5
      Top = 17
      Caption = 'Devir Ba'#351'lang'#305#231' Tarihi'
      Transparent = True
    end
    object DateBaslangic: TcxDateEdit
      Left = 111
      Top = 16
      Properties.DateButtons = [btnNow]
      Properties.ImmediatePost = True
      TabOrder = 0
      Width = 125
    end
    object CheckDevirleriAl: TcxCheckBox
      Left = 164
      Top = 41
      Caption = 'Eski Devirleri de topla'
      Properties.ImmediatePost = True
      State = cbsChecked
      TabOrder = 2
      Transparent = True
      Visible = False
    end
    object memoStokDurum: TcxMemo
      Left = 189
      Top = 82
      Lines.Strings = (
        
          'SELECT        STOKDEPOID, URUNID, SUM(GIREN) AS GIREN, SUM(CIKAN' +
          ') AS CIKAN, SUM(KALAN) AS KALAN'
        
          'FROM            (SELECT        URUNID, STOKADI,STOKDEPO, STOKDEP' +
          'OID, SUM(CASE WHEN HAREKET = '#39'Giri'#351#39' THEN MIKTAR ELSE 0 END) AS ' +
          'GIREN, '
        
          '                                                    SUM(CASE WHE' +
          'N HAREKET = '#39#199#305'k'#305#351#39' THEN MIKTAR ELSE 0 END) AS CIKAN, SUM(CASE W' +
          'HEN HAREKET = '#39'Giri'#351#39' THEN MIKTAR ELSE 0 END) '
        
          '                                                    - SUM(CASE W' +
          'HEN HAREKET = '#39#199#305'k'#305#351#39' THEN MIKTAR ELSE 0 END) AS KALAN'
        
          '                          FROM            (SELECT        '#39'Giri'#351#39 +
          ' AS HAREKET, FB.TUR, F.FATBASID, F.URUNID, S.STOKADI, F.MIKTAR, ' +
          'F.ADET, F.BIRIM, '
        
          '                                                                ' +
          '              FB.GIRISDEPO, GIRDEPO.DEPOADI AS GIRDEPO, FB.CIKIS' +
          'DEPO, CIKDEPO.DEPOADI AS CIKDEPO, GIRDEPO.ID AS STOKDEPOID, '
        
          '                                                                ' +
          '              GIRDEPO.DEPOADI AS STOKDEPO, FB.FATURATARIH AS HAR' +
          'EKETTARIH'
        
          '                                                    FROM        ' +
          '    dbo.FATURA AS F INNER JOIN'
        
          '                                                                ' +
          '              dbo.FATBASLIK AS FB ON F.FATBASID = FB.ID LEFT OUT' +
          'ER JOIN'
        
          '                                                                ' +
          '              dbo.DEPOLAR AS GIRDEPO ON GIRDEPO.ID = FB.GIRISDEP' +
          'O LEFT OUTER JOIN'
        
          '                                                                ' +
          '              dbo.DEPOLAR AS CIKDEPO ON CIKDEPO.ID = FB.CIKISDEP' +
          'O INNER JOIN'
        
          '                                                                ' +
          '              dbo.STOKLAR AS S ON F.URUNID = S.ID'
        
          '                                                    WHERE       ' +
          ' (F.TUR = 1) AND (FB.TUR IN (3, 8, 10, 11, 12, 20)) AND (F.STOKD' +
          'URUMDEGIS = 1) and (YEAR(FB.FATURATARIH)<@Yil) '
        '                                                    UNION ALL'
        
          '                                                    SELECT      ' +
          '  '#39'Giri'#351#39' AS HAREKET, FB.TUR, F.FATBASID, F.URUNID, S.STOKADI, F' +
          '.MIKTAR, F.ADET, F.BIRIM, '
        
          '                                                                ' +
          '             FB.GIRISDEPO, GIRDEPO.DEPOADI AS GIRDEPO, FB.CIKISD' +
          'EPO, CIKDEPO.DEPOADI AS CIKDEPO, GIRDEPO.ID AS STOKDEPOID, '
        
          '                                                                ' +
          '             GIRDEPO.DEPOADI AS STOKDEPO, FB.FATURATARIH AS HARE' +
          'KETTARIH'
        
          '                                                    FROM        ' +
          '    dbo.FATURA AS F INNER JOIN'
        
          '                                                                ' +
          '             dbo.FATBASLIK AS FB ON F.FATBASID = FB.ID LEFT OUTE' +
          'R JOIN'
        
          '                                                                ' +
          '             dbo.DEPOLAR AS GIRDEPO ON GIRDEPO.ID = FB.GIRISDEPO' +
          ' LEFT OUTER JOIN'
        
          '                                                                ' +
          '             dbo.DEPOLAR AS CIKDEPO ON CIKDEPO.ID = FB.CIKISDEPO' +
          ' INNER JOIN'
        
          '                                                                ' +
          '             dbo.STOKLAR AS S ON F.URUNID = S.ID'
        
          '                                                    WHERE       ' +
          ' (F.TUR = 1) AND (FB.TUR = 7) AND (F.MIKTAR > 0) AND (F.STOKDURU' +
          'MDEGIS = 1) and (YEAR(FB.FATURATARIH)<@Yil) '
        '                                                    UNION ALL'
        
          '                                                    SELECT      ' +
          '  '#39#199#305'k'#305#351#39' AS HAREKET, FB.TUR, F.FATBASID, F.URUNID, S.STOKADI, F' +
          '.MIKTAR, F.ADET, F.BIRIM,  '
        
          '                                                                ' +
          '             FB.GIRISDEPO, GIRDEPO.DEPOADI AS GIRDEPO, FB.CIKISD' +
          'EPO, CIKDEPO.DEPOADI AS CIKDEPO, CIKDEPO.ID AS STOKDEPOID, '
        
          '                                                                ' +
          '             CIKDEPO.DEPOADI AS STOKDEPO, FB.FATURATARIH AS HARE' +
          'KETTARIH'
        
          '                                                    FROM        ' +
          '    dbo.FATURA AS F INNER JOIN'
        
          '                                                                ' +
          '             dbo.FATBASLIK AS FB ON F.FATBASID = FB.ID LEFT OUTE' +
          'R JOIN'
        
          '                                                                ' +
          '             dbo.DEPOLAR AS GIRDEPO ON GIRDEPO.ID = FB.GIRISDEPO' +
          ' LEFT OUTER JOIN'
        
          '                                                                ' +
          '             dbo.DEPOLAR AS CIKDEPO ON CIKDEPO.ID = FB.CIKISDEPO' +
          ' INNER JOIN'
        
          '                                                                ' +
          '             dbo.STOKLAR AS S ON F.URUNID = S.ID'
        
          '                                                    WHERE       ' +
          ' (F.TUR = 1) AND (FB.TUR IN (4, 14, 15, 16, 20)) AND (F.STOKDURU' +
          'MDEGIS = 1) and (YEAR(FB.FATURATARIH)<@Yil) '
        '                                                    UNION ALL'
        
          '                                                    SELECT      ' +
          '  '#39#199#305'k'#305#351#39' AS HAREKET, FB.TUR, F.FATBASID, F.URUNID, S.STOKADI, -' +
          ' (1 * F.MIKTAR) AS MIKTAR, - (1 * F.ADET) AS ADET, F.BIRIM, '
        
          '                                                                ' +
          '              FB.GIRISDEPO, GIRDEPO.DEPOADI AS GIRDEPO, FB.GIRIS' +
          'DEPO AS CIKISDEPO, '
        
          '                                                                ' +
          '             GIRDEPO.DEPOADI AS CIKDEPO, GIRDEPO.ID AS STOKDEPOI' +
          'D, GIRDEPO.DEPOADI AS STOKDEPO, '
        
          '                                                                ' +
          '             FB.FATURATARIH AS HAREKETTARIH'
        
          '                                                    FROM        ' +
          '    dbo.FATURA AS F INNER JOIN'
        
          '                                                                ' +
          '             dbo.FATBASLIK AS FB ON F.FATBASID = FB.ID LEFT OUTE' +
          'R JOIN'
        
          '                                                                ' +
          '             dbo.DEPOLAR AS GIRDEPO ON GIRDEPO.ID = FB.GIRISDEPO' +
          ' INNER JOIN'
        
          '                                                                ' +
          '             dbo.STOKLAR AS S ON F.URUNID = S.ID'
        
          '                                                    WHERE       ' +
          ' (F.TUR = 1) AND (FB.TUR = 7) AND (F.STOKDURUMDEGIS = 1) AND (F.' +
          'MIKTAR < 0) and (YEAR(FB.FATURATARIH)<@Yil) ) AS HAREKETLER'
        
          '                          GROUP BY URUNID, STOKADI, STOKDEPO, ST' +
          'OKDEPOID) AS HAREKETTOPLAM'
        'GROUP BY STOKDEPOID, URUNID')
      Properties.WordWrap = False
      TabOrder = 17
      Visible = False
      Height = 70
      Width = 818
    end
    object CheckKredi: TcxCheckBox
      Tag = 6
      Left = 5
      Top = 198
      Caption = 'Krediler'
      State = cbsChecked
      TabOrder = 18
      Transparent = True
    end
    object lbKrediler: TcxLabel
      Left = 141
      Top = 202
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object CheckKrediKartlari: TcxCheckBox
      Tag = 7
      Left = 5
      Top = 159
      Caption = 'Kredi Kartlar'#305
      State = cbsChecked
      TabOrder = 20
      Transparent = True
    end
    object LbKK: TcxLabel
      Left = 141
      Top = 163
      Caption = '(Yap'#305'ld'#305')'
      Transparent = True
      Visible = False
    end
    object ButunPersYillikIzinEkle: TcxButton
      Left = 30
      Top = 319
      Width = 222
      Height = 25
      Caption = 'B'#252't'#252'n personelin y'#305'll'#305'k izinlerini ekle'
      TabOrder = 22
      OnClick = ButunPersYillikIzinEkleClick
    end
    object cbIsYapKur: TcxComboBox
      Left = 107
      Top = 226
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items.Strings = (
        'ALIS'
        'SATIS'
        'EFALIS'
        'EFSATIS')
      TabOrder = 23
      Text = 'ALIS'
      Width = 76
    end
    object cxLabel3: TcxLabel
      Left = 5
      Top = 227
      Caption = #304#351'lem Yap'#305'lacak Kur'
    end
    object checkKurFarki: TcxCheckBox
      Left = 5
      Top = 250
      Caption = 'Devirlere kur fark'#305' da ekle.'
      Properties.ImmediatePost = True
      TabOrder = 25
      Transparent = True
    end
  end
end
