-- =============================================================================
--  1003 - FARKLI MENÜ GRUPLARINI AÇAN YETKİ KODLARINI BÖLME
--
--  Kullanıcı (09.10.2026): "genprofil ile seçtiğim menüler yetki matrisinde
--  görünecek.. yetki matrisinde gor dediğim menüler de kullanıcı menüsünde
--  görünecek" -> "menü koduyla yetki matrisi kodları aynı olmalı" -> (liste
--  çıkarıldıktan sonra) "A grubunun hepsini böl".
--
--  TEŞHİS. 182 yetki kodunun 60'ı birden çok ekranı açıyor; bunlardan 8'i
--  FARKLI menü gruplarındaki ekranları birlikte açıyordu. Matristeki tek
--  kutu menüde iki ayrı yeri açıp kapatıyordu:
--
--    belge.satis      -> Satış grubu + Kurumlar & Sigorta > Faturalar
--    belge.alis       -> Alış grubu + Stok & Hizmet > Alış Faturaları
--    stok             -> Stok & Hizmet + Eczane > Miad & Tüketim
--    ayar             -> Yönetim + Kayıt Kabul > Ayarlar > Kayıt Kabul
--    cari             -> Cari & CRM + Stok & Hizmet > Tedarikçiler
--    personel         -> İK + Kurumlar & Sigorta > Dış Doktorlar
--    medula.provizyon -> Medula + Kayıt Kabul > Medula Kabul
--    dokum            -> 28 grubun Dökümler ekranı
--
--  ÇÖZÜM. Ana gruptaki ekranlar eski kodu korur; dışarıdaki ekran kendi
--  kodunu alır. Kod haritası tek yerde: Gentegre.Cekirdek/Yetki/EkranKodlari
--  (sunucu kapısı + standart rol şablonu) ve web listeTanimlari.
--
--  DAĞITIM: rolde eski kod varsa yeni kod AYNI haklarla (gör/ekle/değiştir/
--  sil/değer/kapsam) eklenir - kimse yetki kazanmaz ya da kaybetmez, yalnız
--  kutular ayrılır. Kurumun kendi rolleri de dahil: bu bir yeniden
--  adlandırma, menüyü daraltma değil (998'deki açık listeden farkı bu).
--  Daraltmak isteyen kurum yeni kutuyu matristen kapatır.
--
--  Betik idempotent: var olan rol_yetki satırına dokunmaz (on conflict do
--  nothing) - ikinci çalıştırmada kurumun sonradan kapattığı kutuyu geri
--  açmaz.
-- =============================================================================

begin;

-- ------------------------------------------------------------ kod haritası ---
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40), sira smallint, urun_modu smallint)
  on commit drop;

insert into _bolme values
  ('belge.kurum_fatura', 'belge.satis',      'Kurum faturaları (Kurumlar & Sigorta › Faturalar)', 'Kurumlar & Sigorta', 54, 2),
  ('belge.alis_fatura',  'belge.alis',       'Alış faturaları (Stok & Hizmet › Alış Faturaları)', 'Stok & Hizmet',      55, 0),
  ('eczane.miad',        'stok',             'Miad & tüketim (Eczane)',                            'Eczane',            231, 2),
  ('kayit_kabul.ayar',   'ayar',             'Kayıt Kabul ayarları',                               'Kayıt Kabul',       381, 2),
  ('cari.tedarikci',     'cari',             'Tedarikçiler (Stok & Hizmet)',                       'Stok & Hizmet',      71, 0),
  ('dis_doktor',         'personel',         'Dış doktorlar (Kurumlar & Sigorta)',                 'Kurumlar & Sigorta',521, 2),
  ('medula.kabul',       'medula.provizyon', 'Medula kabul (Kayıt Kabul)',                         'Kayıt Kabul',         2, 2),
  ('dokum.yonetim',            'dokum', 'Dökümler — Yönetim',             'Yönetim',             386, 0),
  ('dokum.randevu',            'dokum', 'Dökümler — Randevu',             'Randevu',             386, 0),
  ('dokum.kayit_kabul',        'dokum', 'Dökümler — Kayıt Kabul',         'Kayıt Kabul',         386, 0),
  ('dokum.muayene',            'dokum', 'Dökümler — Muayene',             'Muayene',             386, 0),
  ('dokum.laboratuvar',        'dokum', 'Dökümler — Laboratuvar',         'Laboratuvar',         386, 0),
  ('dokum.radyoloji',          'dokum', 'Dökümler — Radyoloji',           'Radyoloji',           386, 0),
  ('dokum.goz',                'dokum', 'Dökümler — Göz',                 'Göz',                 386, 0),
  ('dokum.yatan_hasta',        'dokum', 'Dökümler — Yatan Hasta',         'Yatan Hasta',         386, 0),
  ('dokum.dis',                'dokum', 'Dökümler — Diş',                 'Diş',                 386, 0),
  ('dokum.ftr',                'dokum', 'Dökümler — FTR',                 'FTR',                 386, 0),
  ('dokum.isyeri_hekimligi',   'dokum', 'Dökümler — İşyeri Hekimliği',    'İşyeri Hekimliği',    386, 0),
  ('dokum.cagri_merkezi',      'dokum', 'Dökümler — Çağrı Merkezi',       'Çağrı Merkezi',       386, 0),
  ('dokum.medula',             'dokum', 'Dökümler — Medula',              'Medula',              386, 0),
  ('dokum.ameliyathane',       'dokum', 'Dökümler — Ameliyathane',        'Ameliyathane',        386, 0),
  ('dokum.acil',               'dokum', 'Dökümler — Acil',                'Acil',                386, 0),
  ('dokum.kurumlar_sigorta',   'dokum', 'Dökümler — Kurumlar & Sigorta',  'Kurumlar & Sigorta',  386, 0),
  ('dokum.cari_crm',           'dokum', 'Dökümler — Cari & CRM',          'Cari & CRM',          386, 0),
  ('dokum.satis',              'dokum', 'Dökümler — Satış',               'Satış',               386, 0),
  ('dokum.alis',               'dokum', 'Dökümler — Alış',                'Alış',                386, 0),
  ('dokum.stok_hizmet',        'dokum', 'Dökümler — Stok & Hizmet',       'Stok & Hizmet',       386, 0),
  ('dokum.eczane',             'dokum', 'Dökümler — Eczane',              'Eczane',              386, 0),
  ('dokum.satinalma',          'dokum', 'Dökümler — Satınalma',           'Satınalma',           386, 0),
  ('dokum.uretim',             'dokum', 'Dökümler — Üretim',              'Üretim',              386, 0),
  ('dokum.finans',             'dokum', 'Dökümler — Finans',              'Finans',              386, 0),
  ('dokum.muhasebe',           'dokum', 'Dökümler — Muhasebe',            'Muhasebe',            386, 0),
  ('dokum.ik',                 'dokum', 'Dökümler — İK',                  'İK',                  386, 0),
  ('dokum.dokuman',            'dokum', 'Dökümler — Doküman',             'Doküman',             386, 0),
  ('dokum.teknik_servis',      'dokum', 'Dökümler — Teknik Servis',       'Teknik Servis',       386, 0);

-- ---------------------------------------------------------------- yetkiler ---
--  API açılışında YetkiSenkronu katalogdaki yeni kodları (eczane.miad,
--  dis_doktor) kendisi de ekleyebilir; ad/grup burada doğru değere çekilir.
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, b.sira, b.urun_modu, ''
  from _bolme b
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0,
       sira = excluded.sira, urun_modu = excluded.urun_modu, aktif = 1;

-- ------------------------------------------------------------ rol dağıtımı ---
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

-- Yetki önbelleği rol sürümüyle geçersizlenir (YetkiCozucu).
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

do $$
declare n int;
begin
  select count(*) into n from public.rol_yetki ry
    join public.yetki y on y.id = ry.yetki_id
   where y.kod in ('belge.kurum_fatura','belge.alis_fatura','eczane.miad','kayit_kabul.ayar',
                   'cari.tedarikci','dis_doktor','medula.kabul') or y.kod like 'dokum.%';
  raise notice '1003: bölünmüş ekran kodu rol satırı = %', n;
end $$;

commit;
