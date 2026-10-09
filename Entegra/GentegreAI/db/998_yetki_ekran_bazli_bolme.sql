-- =============================================================================
--  998 - GENİŞ YETKİ KODLARINI EKRAN BAZINDA BÖLME
--
--  Kullanıcı (09.10.2026): "hasan aydın banko görevlisi olarak login oldum ama
--  yetki dışında menü geldi" ... "yetki matrisinde neler varsa onlar menüde
--  görünmeli" ... "böyle yapalım".
--
--  TEŞHİS. Banko Görevlisi'nin menüsünde Satış, Alış, Stok & Hizmet, Finans ve
--  Kurumlar & Sigorta grupları çıkıyordu. Sebep rolün fazla yetkili olması
--  DEĞİL: tek bir `belge` yetkisi 21 ekran açıyor. Kayıt Kabul'ün ihtiyacı olan
--  "Başvurular" ekranı da `belge` istediği için yetkiyi rolden kaldırmak işi
--  bozardı - kayıt kabul memuru başvuru açamaz hale gelirdi.
--
--  Aynı kabalık üç yerde daha var:
--    `hesap`      -> Finans'ın 7 tanım ekranı (kasa/banka/POS/kredi/ekstre)
--    `kasa_islem` -> Finans'ın 3 ekranı + Kayıt Kabul > Hasta Avansları
--    `sigorta`    -> kurum tanım ekranları + Kayıt Kabul > Provizyonlar
--
--  Bu yalnız bankoyu değil herkesi ilgilendiriyordu: `belge` yetkisi 38 rolde
--  var - hekim, hemşire, eczacı ve danışma da Satış Faturaları menüsünü
--  görüyordu.
--
--  ÇÖZÜM. Geniş kod ÇEKİRDEK işini korur, ekran kümeleri kendi kodunu alır:
--    belge         -> başvuru/hasta belgesi (çekirdek, 38 rolde kalır)
--    belge.satis   -> Satış grubu + kuruma kesilen faturalar
--    belge.alis    -> Alış grubu + alış faturaları
--    belge.stok    -> stok giriş/çıkış/transfer/talep fişleri
--    hesap         -> hesap verisini GÖRME (POS seçimi, kart içi listeler)
--    hesap.tanim   -> Finans'taki hesap tanım ekranları
--    kasa_islem    -> tahsilat/avans yazma (çekirdek)
--    kasa.finans   -> Finans'taki kasa işlem listeleri ve kasa ayarı
--    sigorta       -> provizyon (çekirdek)
--    sigorta.tanim -> kurum hesabı / kod eşlemesi / istek günlüğü
--
--  DAĞITIM İLKESİ: yeni kodlar, o ekranları gerçekten kullanan ERP/mali
--  rollere AÇIK LİSTEYLE verilir. "Eski yetkisi olan herkese ver" demek
--  hekimin ve banko görevlisinin menüsünü olduğu gibi bırakmak olurdu -
--  düzeltmenin amacı tam olarak o.
--
--  MÜŞTERİ VERİSİ KORUNUR: kurumun kendi eklediği roller bu listede yok, onlar
--  yalnız çekirdek kodları taşımaya devam eder; yeni ekran kümesini isteyen
--  kurum yetki matrisinden verir. Betik idempotent.
-- =============================================================================

begin;

-- ---------------------------------------------------------------- yetkiler ---
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
values
  ('belge.satis',   'Satış belgeleri (fatura, irsaliye, sipariş, teklif)',  'Kayıt Kabul', 0,  51, 0, ''),
  ('belge.alis',    'Alış belgeleri (fatura, irsaliye, sipariş, konsinye)', 'Kayıt Kabul', 0,  52, 0, ''),
  ('belge.stok',    'Stok fişleri (giriş, çıkış, transfer, talep)',         'Kayıt Kabul', 0,  53, 0, ''),
  ('sigorta.tanim', 'Kurum hesabı, kod eşlemesi, istek günlüğü',           'Cari',        0,  61, 2, 'muayene'),
  ('kasa.finans',   'Finans kasa işlem listeleri ve kasa ayarı',           'Kasa',        0, 461, 0, ''),
  ('hesap.tanim',   'Kasa / banka / POS / kredi hesap TANIMLARI',          'Kasa',        0, 481, 0, 'kasa')
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur,
       sira = excluded.sira, urun_modu = excluded.urun_modu, modul = excluded.modul;

-- ------------------------------------------------------------ rol dağıtımı ---
--  Haklar eski geniş yetkideki hakların AYNISI - kimse hak kazanmıyor ya da
--  kaybetmiyor, yalnızca hangi EKRANI göreceği daralıyor.
with dagitim(rol_kod, yetki_kod, gor, ekle, degistir, sil) as (
  values
    ('yonetici',           'belge.satis',   1,1,1,1), ('yonetici',           'belge.alis',    1,1,1,1),
    ('yonetici',           'belge.stok',    1,1,1,1), ('yonetici',           'hesap.tanim',   1,1,1,1),
    ('yonetici',           'kasa.finans',   1,1,1,1), ('yonetici',           'sigorta.tanim', 1,1,1,1),
    ('muhasebe',           'belge.satis',   1,1,1,1), ('muhasebe',           'belge.alis',    1,1,1,1),
    ('muhasebe',           'belge.stok',    1,1,1,1), ('muhasebe',           'hesap.tanim',   1,1,1,1),
    ('muhasebe',           'kasa.finans',   1,1,1,1), ('muhasebe',           'sigorta.tanim', 1,0,0,0),
    ('muhasebe_sorumlu',   'belge.satis',   1,1,1,1), ('muhasebe_sorumlu',   'belge.alis',    1,1,1,1),
    ('muhasebe_sorumlu',   'belge.stok',    1,1,1,1), ('muhasebe_sorumlu',   'hesap.tanim',   1,1,1,1),
    ('muhasebe_sorumlu',   'kasa.finans',   1,1,1,1), ('muhasebe_sorumlu',   'sigorta.tanim', 1,0,0,0),
    ('erp_alis',           'belge.alis',    1,1,1,0), ('erp_alis',           'belge.stok',    1,1,1,0),
    ('erp_servis',         'belge.stok',    1,0,0,0),
    ('eczane_depo',        'belge.stok',    1,1,1,0),
    ('medikal_muhasebe',   'belge.satis',   1,1,1,0), ('medikal_muhasebe',   'sigorta.tanim', 1,0,0,0),
    ('ust_yonetim',        'belge.satis',   1,0,0,0), ('ust_yonetim',        'belge.alis',    1,0,0,0),
    ('ust_yonetim',        'belge.stok',    1,0,0,0), ('ust_yonetim',        'hesap.tanim',   1,0,0,0),
    ('ust_yonetim',        'kasa.finans',   1,0,0,0), ('ust_yonetim',        'sigorta.tanim', 1,0,0,0),
    ('hastane_muduru',     'belge.satis',   1,0,0,0), ('hastane_muduru',     'belge.alis',    1,0,0,0),
    ('hastane_muduru',     'belge.stok',    1,0,0,0), ('hastane_muduru',     'kasa.finans',   1,0,0,0),
    ('nobetci_mudur',      'kasa.finans',   1,0,0,0), ('nobetci_mudur',      'hesap.tanim',   1,0,0,0),
    ('rapor_goruntuleyici','belge.satis',   1,0,0,0), ('rapor_goruntuleyici','belge.alis',    1,0,0,0),
    ('rapor_goruntuleyici','belge.stok',    1,0,0,0), ('rapor_goruntuleyici','hesap.tanim',   1,0,0,0),
    ('rapor_goruntuleyici','kasa.finans',   1,0,0,0), ('rapor_goruntuleyici','sigorta.tanim', 1,0,0,0)
)
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, d.gor, d.ekle, d.degistir, d.sil
  from dagitim d
  join public.rol r   on r.kod = d.rol_kod
  join public.yetki y on y.kod = d.yetki_kod
on conflict (rol_id, yetki_id) do update
   set gor = excluded.gor, ekle = excluded.ekle,
       degistir = excluded.degistir, sil = excluded.sil;

-- -------------------------------------------- banko görevlisi sadeleştirme ---
--  Kullanıcı: "kayit_kabul / banko görevlisine kayıtkabul ve randevu yetkisi
--  verdim sadece". Rolde duran Cari & CRM / Kurumlar / Cari Ekstre yetkileri
--  menüde o grupları açıyordu. Banko işinin ihtiyacı olanlar (hasta, belge,
--  banko, banko_oturum, kasa_islem, hesap-görme, sigorta provizyon, randevu)
--  KALIR - onlar olmadan tahsilat ve başvuru yapılamaz.
delete from public.rol_yetki ry
 using public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and r.kod in ('kayit_kabul', 'danisma')
   and (y.kod in ('cari', 'aday', 'gorev', 'kurum', 'mali_hareket')
        -- 871 gocu Acil ve Cagri Merkezi modullerini eklerken yetkilerini
        --   kayit kabul rollerine topluca vermisti: triyaj, acil yatak
        --   tanimi, santral/IVR ayari, kalite-ses kaydi ve supervizor
        --   panosu banko gorevlisinin isi degil.
        or y.kod like 'acil%' or y.kod like 'cagri%');

commit;

-- Kontrol:
--   select y.grup, string_agg(y.kod, ', ' order by y.kod)
--     from rol_yetki ry join rol r on r.id = ry.rol_id join yetki y on y.id = ry.yetki_id
--    where r.kod = 'kayit_kabul' and ry.gor = 1 group by y.grup order by y.grup;
