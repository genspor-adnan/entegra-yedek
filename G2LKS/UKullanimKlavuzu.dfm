object KullanimKlavuzu: TKullanimKlavuzu
  Left = 0
  Top = 0
  Caption = 'Kullan'#305'm Klavuzu'
  ClientHeight = 466
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cxMemo1: TcxMemo
    Left = 0
    Top = 0
    Align = alClient
    Enabled = False
    Lines.Strings = (
      #304'lk i'#351'lemler'
      '1.'#9#214'n Kontrol'
      '2.'#9'XML Olu'#351'tur'
      '3.'#9'Son Kontrol    bu s'#305'ralama her zaman takip edilmelidir.'
      ''
      '--Fatura XML Olu'#351'turma--'
      
        'Se'#231'ilen faturalar'#305'n logo'#39'ya daha '#246'nceden aktar'#305'l'#305'p aktar'#305'lmad'#305#287#305 +
        ' '#8220#214'n Kontrol'#8221' butonu ile kontrol edilir.'
      
        'E'#287'er Logo'#39'ya aktar'#305'lm'#305#351' ise bu faturalar'#305'n Durumu '#8216'Zaten Var'#8217' ol' +
        'arak de'#287'i'#351'tirilir.'
      
        'Faturalarda bulunan Cari Hesaplar veya Stoklar e'#287'er logo'#8217'ya akta' +
        'r'#305'lmam'#305#351' ise hata mesaj'#305' olarak kullan'#305'c'#305'ya belirtilir.'
      'Bu faturalar se'#231'ilenler listesinden '#231#305'kar'#305'l'#305'r. '
      ''
      
        #214'n kontrolu tamamlanm'#305#351' faturalar'#305'n 2. A'#351'ama olarak '#8220'XML Olu'#351'tur' +
        #8221' butonuna t'#305'klan'#305'r.'
      
        'B'#246'ylece se'#231'ilen faturalar'#305'n Durumlar'#305' '#8216'Xml Olu'#351'turuldu'#8217'  olarak ' +
        'de'#287'i'#351'ir. '
      
        'Olu'#351'an bu XML dosyas'#305' ile logo'#39'ya  veri aktar'#305'm'#305'(i'#231'eri) sa'#287'lan'#305'r' +
        '.'
      
        'Logo'#39'ya aktar'#305'm'#305' sa'#287'lanm'#305#351' bu faturalar'#305'n 3.a'#351'amas'#305' olarak '#8220'Son ' +
        'Kontrol'#8221' butonuna t'#305'klanmas'#305' beklenir. '
      
        'Bu a'#351'amada faturalar'#305'n logo'#8217'ya aktar'#305'l'#305'p aktar'#305'lmad'#305#287#305' kontrol e' +
        'dilir.'
      
        'E'#287'er d'#252'zg'#252'n bir '#351'ekilde aktar'#305'lm'#305#351' ise se'#231'ilen faturalar'#305'n Durum' +
        'lar'#305' '#8216'Aktar'#305'ld'#305#8217' olarak de'#287'i'#351'tirilir.'
      ''
      '--Cari hesaplar'#305' ve Stok kartlar'#305' XML olu'#351'turma--'
      
        'Se'#231'ilen bu Cari veya Stoklar'#305'n logo'#8217'ya daha '#246'nceden aktar'#305'l'#305'p ak' +
        'tar'#305'lmad'#305#287#305' '#8220#214'n Kontrol'#8221' butonu ile kontrol edilir.'
      
        'E'#287'er Logo'#39'ya aktar'#305'lm'#305#351' ise bu Carilerin veya Stoklar'#305'n Durumu '#8216 +
        'Zaten Var'#8217' olarak de'#287'i'#351'tirilir.'
      'Zaten var olanlar se'#231'ilenler listesinden '#231#305'kart'#305'l'#305'r.'
      ''
      
        #214'n Kontrolu tamamlanm'#305#351' Cariler ve Stoklar  2. A'#351'ama olarak '#8220'XML' +
        ' Olu'#351'tur'#8221' butonuna t'#305'klan'#305'r.'
      
        'B'#246'ylece se'#231'ilen Carilerin veya Stoklar'#305'n Durumlar'#305' '#8216'Xml Olu'#351'turu' +
        'ldu'#8217'  olarak de'#287'i'#351'tirilir.'
      
        'Olu'#351'an bu XML dosyas'#305' ile logo'#39'ya  veri aktar'#305'm'#305'(i'#231'eri) sa'#287'lan'#305'r' +
        '.'
      
        'Logo'#39'ya aktar'#305'm'#305' sa'#287'lanm'#305#351' bu Carilerin veya Stoklar'#305'n 3.a'#351'amas'#305 +
        ' olarak '#8220'Son Kontrol'#8221' butonuna t'#305'klanmas'#305' beklenir. '
      
        'Bu a'#351'amada Carilerin ve Stoklar'#305'n logo'#8217'ya aktar'#305'l'#305'p aktar'#305'lmad'#305#287 +
        #305' kontrol edilir.'
      
        'E'#287'er d'#252'zg'#252'n bir '#351'ekilde aktar'#305'lm'#305#351' ise se'#231'ilenlerin Durumlar'#305' '#8216'A' +
        'ktar'#305'ld'#305#8217' olarak de'#287'i'#351'ir. '
      ''
      
        'Stok kartlar'#305' Xml olu'#351'tururken Birim Seti Kodu istenmektedir.Log' +
        'oda birimler sekmesinde birim seti kodu'
      'ne ise bunun bilgisi girilmelidir.')
    StyleDisabled.TextColor = clBackground
    TabOrder = 0
    Height = 466
    Width = 592
  end
end
