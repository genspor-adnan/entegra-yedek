-- ============================================================================
--  Gentegre AI — YETKİ MATRİSİ MENÜDEN YENİDEN KURULUYOR
--  675_yetki_menuden.sql
--
--  Kullanıcı: "rol matrisini sil menüye göre yeniden oluştur.. bu rol matrisi
--  de aslında kurum profiline bağlı olmalı."
--
--  İKİ SORUN VARDI:
--
--  1) TABLO ESKİ PROGRAMIN ÇÖPÜNÜ TAŞIYORDU. `yetki` içindeki 855 satır
--     Delphi göçünden kalan `eski` / `eski-dinamik` kayıtlarıydı: web ürününde
--     hiçbir ekranın karşılığı yok, matris ağacı onları zaten gizliyordu ama
--     her istekte sunucudan geliyor, bir rolde 855 anlamsız `rol_yetki` satırı
--     tutuyorlardı. Silindiler (rol_yetki'ye cascade).
--
--  2) SATIRIN ADI/GRUBU/SIRASI MENÜYLE İLGİSİZDİ. Matris ağacı istemcide
--     menüye göre kuruluyordu ama sunucudaki `grup` alanı ("kart", "mali",
--     "genel") menüde olmayan başlıklardı; eşleşmeyen her satır "Diğer"e
--     düşüyordu. Artık kaynağın kendisi menüdür: grup = menü grubu, ad = tek
--     ekranlı yetkilerde menüdeki ekran adı, sıra = menüdeki sıra.
--
--  3) KURUM PROFİLİ BAĞI (359). Yeni `modul` kolonu yetkiyi kurum profilindeki
--     modüle bağlar; kapalı modülün yetkisi matriste HİÇ görünmez - kapalı bir
--     modülün ekranı zaten çizilmiyor, yetkisini vermek anlamsız bir kutuydu.
--
--     MODÜL YALNIZ OYBİRLİĞİYLE yazılır: `belge` hem Başvuru (kayıt kabul) hem
--     Teklif/Sipariş/Fatura (ERP satış) ekranlarının yetkisidir - ona "erp_satis"
--     demek, ERP satış kapatılan bir hastanede başvuru yetkisini de gizlerdi.
--     Böyle kodlar modülsüz kalır ve her kurulumda görünür.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.yetki
    add column if not exists modul varchar(40) not null default '';

comment on column public.yetki.modul is
  'Kurum profilindeki modul kodu (kurum_modul.kod). Bos ise yetki her kurulumda gorunur (675).';

-- ---------------------------------------------------------------------------
--  1) Eski programdan gelen yetkiler siliniyor (rol_yetki cascade ile gider).
-- ---------------------------------------------------------------------------
do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.yetki where grup in ('eski', 'eski-dinamik');
    delete from public.yetki where grup in ('eski', 'eski-dinamik');
    raise notice '675: % eski yetki satiri silindi.', v_adet;
end $$;

-- ---------------------------------------------------------------------------
--  2) MENÜDEN gelen tanımlar (web/src/sayfalar/listeTanimlari.*.ts).
--     Sıra menüdeki sıradır; matris ağacı artık menüyle birebir okunur.
-- ---------------------------------------------------------------------------
-- psql her komutu kendi islemine alir: `on commit drop` tabloyu hemen
--   dusururdu - gecici tablo betik sonunda ELLE silinir.
drop table if exists gecici_menu_yetki;
create temporary table gecici_menu_yetki (
    kod varchar(60) primary key,
    ad varchar(120) not null,
    grup varchar(40) not null,
    modul varchar(40) not null,
    urun_modu smallint not null,
    sira smallint not null
);

insert into gecici_menu_yetki (kod, ad, grup, modul, urun_modu, sira) values
    ('mesaj', 'Mesajlar', 'İletişim & AI', 'mesaj', 0, 10),
    ('ai', 'Yapay Zeka', 'İletişim & AI', 'mesaj', 0, 20),
    ('randevu', 'Randevular', 'Randevu', 'randevu', 2, 30),
    ('personel', 'Personel', 'Kayıt Kabul', '', 0, 40),
    ('sigorta', 'Özel sigorta (provizyon)', 'Cari', 'muayene', 2, 50),
    ('kurum', 'Anlaşmalı Kurumlar', 'Cari', '', 2, 60),
    ('cari', 'Cari (musteri/tedarikci)', 'Cari', '', 0, 70),
    ('cihaz', 'Cihaz entegrasyonu', 'Laboratuvar', 'lab', 2, 80),
    ('lab', 'İstemler', 'Laboratuvar', 'lab', 2, 90),
    ('lab.numune', 'Numune Kabul', 'Laboratuvar', 'lab', 2, 100),
    ('lab.sonuc', 'Sonuçlar', 'Laboratuvar', 'lab', 2, 110),
    ('lab.tetkik', 'Tetkik kataloğu', 'Laboratuvar', 'lab', 2, 120),
    ('lab.kultur', 'Kültür Çalışma Listesi', 'Laboratuvar', 'lab', 2, 130),
    ('lab.genetik', 'Genetik vaka çalışması', 'Laboratuvar', 'lab', 2, 140),
    ('lab.kk', 'Kalite kontrol (İKK/DKK)', 'Laboratuvar', 'lab', 2, 150),
    ('lab.dislab', 'Dış laboratuvar gönderimi', 'Laboratuvar', 'lab', 2, 160),
    ('lab.gen', 'Gen / panel kataloğu', 'Laboratuvar', 'lab', 2, 170),
    ('lab.mikro', 'Mikrobiyoloji kataloğu', 'Laboratuvar', 'lab', 2, 180),
    ('lab.cihaz', 'Cihaz Eşleme', 'Laboratuvar', 'lab', 2, 190),
    ('stok', 'Stok', 'Stok & Hizmet', '', 0, 200),
    ('fiyat_listesi', 'Fiyat listesi', 'Stok & Hizmet', 'stok', 0, 210),
    ('hizmet', 'Hizmet Listesi', 'Stok & Hizmet', 'stok', 0, 220),
    ('uts', 'ÜTS (Ürün Takip Sistemi)', 'Stok & Hizmet', 'stok', 0, 230),
    ('muayene', 'Muayene', 'Muayene', 'muayene', 2, 240),
    ('prim.kendi', 'Hakedişlerim', 'Muayene', 'muayene', 2, 250),
    ('katalog', 'Klinik kataloglar (ICD / ilaç)', 'Muayene', 'muayene', 2, 260),
    ('radyoloji', 'Radyoloji', 'Radyoloji', 'radyoloji', 2, 270),
    ('entegrasyon', 'Entegrasyon hesaplari', 'e-Nabız', 'enabiz', 2, 280),
    ('proje', 'Projeler', 'CRM', '', 0, 290),
    ('gorev', 'Görevler', 'CRM', '', 0, 300),
    ('firsat', 'Satış Fırsatları', 'CRM', '', 0, 310),
    ('aday', 'Aday Müşteriler', 'CRM', '', 0, 320),
    ('hesap_plani', 'Hesap Planı', 'Muhasebe', 'muhasebe', 0, 330),
    ('muhasebe_fis', 'Muhasebe fisi', 'Muhasebe', 'muhasebe', 0, 340),
    ('masraf_merkezi', 'Masraf Merkezleri', 'Muhasebe', 'muhasebe', 0, 350),
    ('kasa_islem_turu', 'İşlem Türleri', 'Muhasebe', 'muhasebe', 0, 360),
    ('islem_log', 'Islem gunlugu', 'Yönetim', '', 0, 370),
    ('onam', 'Onam (metin ve kayıtlar)', 'Yönetim', '', 0, 380),
    ('bildirim_sablon', 'Bildirim Şablonları', 'Yönetim', '', 0, 390),
    ('bildirim', 'Bildirim Kuyruğu', 'Yönetim', '', 0, 400),
    ('zamanli_is', 'Zamanlanmış İşler', 'Yönetim', '', 0, 410),
    ('sube', 'Subeler', 'Yönetim', '', 0, 420),
    ('ayar', 'Genel ayarlar', 'Yönetim', '', 0, 430),
    ('belge', 'Belgeler', 'Satış', '', 0, 440),
    ('e_belge', 'e-Belge', 'Satış', 'erp_satis', 0, 450),
    ('kasa_islem', 'Kasa islemi (tahsilat/odeme/virman)', 'Kasa', '', 0, 460),
    ('mali_hareket', 'Kasa / banka hareketi', 'Kasa', 'kasa', 0, 470),
    ('masraf', 'Masraf Listesi', 'Kasa', 'kasa', 0, 480),
    ('hesap', 'Kasa / banka / POS / kredi hesabi', 'Banka', 'kasa', 0, 490),
    ('cek_senet', 'Cek ve senet', 'Banka', 'kasa', 0, 500),
    ('uretim', 'Üretim (ağaç ve emir)', 'Üretim', 'uretim', 0, 510),
    ('prim', 'Prim / hakedis', 'İK', '', 2, 520),
    ('rol', 'Roller', 'İK', '', 0, 530),
    ('demirbas', 'Demirbaş', '', '', 0, 540),
    ('dokuman', 'Doküman yönetimi', 'Doküman', 'dokuman', 0, 550),
    ('dokuman.onayla', 'Onay Kuyruğu', 'Doküman', 'dokuman', 0, 560);

-- Menüde olup tabloda olmayan yetki: eklenir (ileride menüye ekran eklenirse
--   bu betiğin yeni numaralı kopyası aynı şeyi yapar).
insert into public.yetki (kod, ad, grup, modul, tur, urun_modu, sira, aktif)
select m.kod, m.ad, m.grup, m.modul, 0, m.urun_modu, m.sira, 1
  from gecici_menu_yetki m
 where not exists (select 1 from public.yetki y where y.kod = m.kod);

update public.yetki y
   set ad = m.ad, grup = m.grup, modul = m.modul,
       urun_modu = m.urun_modu, sira = m.sira
  from gecici_menu_yetki m
 where y.kod = m.kod;

-- ---------------------------------------------------------------------------
--  3) AKSİYON yetkileri (belge.kesinlestir, lab.onay, basvuru.iskonto...)
--     ait oldukları modülün grubunu ve modülünü devralır: ağaçta zaten o
--     modülün altında çiziliyorlar, ayrı bir grupta durmaları listeyi
--     "Diğer" başlığına dağıtıyordu.
-- ---------------------------------------------------------------------------
update public.yetki a
   set grup = u.grup,
       modul = case when a.modul = '' then u.modul else a.modul end,
       sira = (u.sira + 1)::smallint
  from public.yetki u
 where a.kod like '%.%'
   and u.kod = split_part(a.kod, '.', 1)
   and u.tur = 0;

-- ---------------------------------------------------------------------------
--  4) Menüde karşılığı olmayan ama koddan kullanılan yetkiler (panel, ayar,
--     kullanici, referans, kod_liste, taraf, depo, doviz_kur...). Silinmezler:
--     ekranları menüde değil ama yetki kontrolleri onlara bakar. Yalnız
--     grupları "Yönetim"e toplanır ki matrisin sonunda tek yerde dursunlar.
-- ---------------------------------------------------------------------------
update public.yetki
   set grup = 'Yönetim', sira = (900 + id % 90)::smallint
 where tur = 0
   and kod not like '%.%'
   and not exists (select 1 from gecici_menu_yetki m where m.kod = public.yetki.kod)
   and grup not in ('Yönetim');

drop table if exists gecici_menu_yetki;

do $$
begin
    raise notice '675 tamam: yetki matrisi menuden kuruldu (% satir).',
                 (select count(*) from public.yetki where aktif = 1);
end $$;
