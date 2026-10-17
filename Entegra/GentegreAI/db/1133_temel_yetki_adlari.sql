-- =============================================================================
--  1133  TEMEL YETKİ ADLARI
--
--  Kullanıcı (17.10.2026): "yetki matrisinde temel yetkiler ne demek" -> "adları düzelt".
--  Matrisin Temel Yetkiler kutusundaki menüsüz çekirdek yetkilerin adları ne açtıklarını
--  söylemiyordu ("Ayarlar" aslında Lab / Acil kartlarının referans kodları; "Kartlar (tumu)"
--  kişi / kurum kartlarının ortak çekirdeği) ve Türkçe karakter / büyük harf eksikti.
--
--  Yalnız ad değişir; kod ve haklar aynen kalır. Ad bugünkü adından farklıysa (kurum elle
--  değiştirmiş) dokunulmaz. İdempotent.
-- =============================================================================

update public.yetki y
   set ad = v.yeni
  from (values
    ('referans',         'Ayarlar',                       'Referans Kodları (Lab / Acil seçim listeleri)'),
    ('taraf',            'Kartlar (tumu)',                'Kişi / Kurum Kartları (ortak çekirdek)'),
    ('belge_satir',      'Belge satirlari',               'Belge / Başvuru Ücret Satırları'),
    ('departman',        'Bölüm / birim listesi (seçim)', 'Bölüm / Birim Seçimi'),
    ('depo',             'Depo',                          'Depo Tanımları'),
    ('doviz_kur',        'Doviz kuru',                    'Döviz Kuru'),
    ('kasa_kapatma',     'Fatura - tahsilat kapatma',     'Fatura - Tahsilat Kapatma'),
    ('kod_liste',        'Kod listeleri',                 'Kod Listeleri'),
    ('kredi',            'Banka kredisi',                 'Banka Kredisi'),
    ('kredi.taksit-ode', 'Kredi taksiti ode',             'Kredi Taksiti Öde')
  ) v(kod, eski, yeni)
 where y.kod = v.kod and y.ad = v.eski;
