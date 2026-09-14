-- ============================================================================
--  Gentegre AI — YETKİ MATRİSİ ANA MENÜDEN YENİDEN
--  682_yetki_menuden_yeniden.sql
--
--  Kullanıcı: "roldeki yetki matrisini silip ana menüye göre yeniden oluştur."
--
--  675 matrisi menüden kurmuştu ama iki kural yanlıştı:
--
--   1) Grup "kodun EN ÇOK geçtiği menü grubu" seçiliyordu. `belge` yetkisi
--      Satış'ta altı ekranda, Kayıt Kabul'de bir ekranda geçtiği için
--      "Başvurular" Satış başlığının altında kalıyordu - kayıt kabul görevlisi
--      kendi ekranının yetkisini Satış'ta arıyordu. Artık grup ANA MENÜDEKİ
--      İLK GÖRÜLME yeridir: menüde ne sırada duruyorsa matris de öyle.
--
--   2) Menüde karşılığı olmayan yetkiler (referans, kod listesi, döviz kuru,
--      kullanıcı, depo…) "Yönetim"e toplanıyordu ve menüdeki gerçek Yönetim
--      ekranlarıyla karışıyordu. Artık kendi başlıklarında: "Sistem", ve
--      listenin EN SONUNDA - bunlar ekran değil, altyapı yetkileridir.
--
--  Aksiyon yetkileri (belge.kesinlestir, kasa.kapat…) modüllerinin grubunu ve
--  sırasını devralır; önek ile modül kodu farklı olanların eşlemesi 676'dakiyle
--  aynıdır.
-- ============================================================================
\set ON_ERROR_STOP on

drop table if exists gecici_menu_yetki;
create temporary table gecici_menu_yetki (
    kod varchar(60) primary key,
    ad varchar(120),          -- null = kod birden cok ekranda, mevcut ad kalir
    grup varchar(40) not null,
    modul varchar(40) not null,
    urun_modu smallint not null,
    sira smallint not null
);

insert into gecici_menu_yetki (kod, ad, grup, modul, urun_modu, sira) values
    ('mesaj', 'Mesajlar', 'İletişim & AI', 'mesaj', 0, 10),
    ('ai', 'Yapay Zeka', 'İletişim & AI', 'mesaj', 0, 20),
    ('randevu', null, 'Randevu', 'randevu', 2, 30),
    ('personel', null, 'Kayıt Kabul', '', 0, 40),
    ('belge', null, 'Kayıt Kabul', '', 0, 50),
    ('sigorta', null, 'Cari', 'muayene', 2, 60),
    ('cari', null, 'Cari', '', 0, 70),
    ('kurum', null, 'Cari', '', 2, 80),
    ('lab', 'İstemler', 'Laboratuvar', 'lab', 2, 90),
    ('lab.numune', 'Numune Kabul', 'Laboratuvar', 'lab', 2, 100),
    ('lab.kk', null, 'Laboratuvar', 'lab', 2, 110),
    ('cihaz', null, 'Laboratuvar', 'lab', 2, 120),
    ('lab.cihaz', 'Cihaz Eşleme', 'Laboratuvar', 'lab', 2, 130),
    ('lab.kultur', 'Kültür Çalışma Listesi', 'Laboratuvar', 'lab', 2, 140),
    ('lab.mikro', null, 'Laboratuvar', 'lab', 2, 150),
    ('lab.genetik', null, 'Laboratuvar', 'lab', 2, 160),
    ('lab.gen', null, 'Laboratuvar', 'lab', 2, 170),
    ('lab.sonuc', 'Sonuçlar', 'Laboratuvar', 'lab', 2, 180),
    ('lab.tetkik', null, 'Laboratuvar', 'lab', 2, 190),
    ('lab.dislab', null, 'Laboratuvar', 'lab', 2, 200),
    ('hizmet', 'Hizmet Listesi', 'Stok & Hizmet', 'stok', 0, 210),
    ('fiyat_listesi', null, 'Stok & Hizmet', 'stok', 0, 220),
    ('stok', null, 'Stok & Hizmet', '', 0, 230),
    ('uts', null, 'Stok & Hizmet', 'stok', 0, 240),
    ('muayene', null, 'Muayene', 'muayene', 2, 250),
    ('prim.kendi', 'Hakedişlerim', 'Muayene', 'muayene', 2, 260),
    ('katalog', null, 'Muayene', 'muayene', 2, 270),
    ('radyoloji', null, 'Radyoloji', 'radyoloji', 2, 280),
    ('entegrasyon', null, 'e-Nabız', 'enabiz', 2, 290),
    ('aday', 'Aday Müşteriler', 'CRM', '', 0, 300),
    ('firsat', 'Satış Fırsatları', 'CRM', '', 0, 310),
    ('proje', 'Projeler', 'CRM', '', 0, 320),
    ('gorev', 'Görevler', 'CRM', '', 0, 330),
    ('hesap_plani', 'Hesap Planı', 'Muhasebe', 'muhasebe', 0, 340),
    ('muhasebe_fis', null, 'Muhasebe', 'muhasebe', 0, 350),
    ('masraf_merkezi', 'Masraf Merkezleri', 'Muhasebe', 'muhasebe', 0, 360),
    ('kasa_islem_turu', 'İşlem Türleri', 'Muhasebe', 'muhasebe', 0, 370),
    ('ayar', null, 'Yönetim', '', 0, 380),
    ('islem_log', null, 'Yönetim', '', 0, 390),
    ('onam', null, 'Yönetim', '', 0, 400),
    ('bildirim_sablon', 'Bildirim Şablonları', 'Yönetim', '', 0, 410),
    ('bildirim', 'Bildirim Kuyruğu', 'Yönetim', '', 0, 420),
    ('zamanli_is', 'Zamanlanmış İşler', 'Yönetim', '', 0, 430),
    ('sube', null, 'Yönetim', '', 0, 440),
    ('e_belge', 'e-Belge', 'Satış', 'erp_satis', 0, 450),
    ('kasa_islem', null, 'Kasa', '', 0, 460),
    ('mali_hareket', null, 'Kasa', 'kasa', 0, 470),
    ('hesap', null, 'Kasa', 'kasa', 0, 480),
    ('masraf', 'Masraf Listesi', 'Kasa', 'kasa', 0, 490),
    ('cek_senet', null, 'Banka', 'kasa', 0, 500),
    ('uretim', null, 'Üretim', 'uretim', 0, 510),
    ('rol', 'Roller', 'İK', '', 0, 520),
    ('prim', null, 'İK', '', 2, 530),
    ('demirbas', 'Demirbaş', 'Diğer', '', 0, 540),
    ('dokuman', null, 'Doküman', 'dokuman', 0, 550),
    ('dokuman.onayla', 'Onay Kuyruğu', 'Doküman', 'dokuman', 0, 560);

-- Menüde olup tabloda olmayan yetki eklenir (yeni ekran açıldıysa).
insert into public.yetki (kod, ad, grup, modul, tur, urun_modu, sira, aktif)
select m.kod, coalesce(m.ad, m.kod), m.grup, m.modul, 0, m.urun_modu, m.sira, 1
  from gecici_menu_yetki m
 where not exists (select 1 from public.yetki y where y.kod = m.kod);

update public.yetki y
   set ad = coalesce(m.ad, y.ad),
       grup = m.grup, modul = m.modul,
       urun_modu = m.urun_modu, sira = m.sira
  from gecici_menu_yetki m
 where y.kod = m.kod;

-- ---------------------------------------------------------------------------
--  MENÜSÜZ KAYNAKLAR -> "Sistem" (en sonda). Silinmezler: ekranları menüde
--  değil ama yetki kontrolleri onlara bakar (referans okuma, kod listesi,
--  kullanıcı yönetimi, depo…).
-- ---------------------------------------------------------------------------
update public.yetki y
   set grup = 'Sistem',
       sira = (9000 + (row_sira * 10))::smallint
  from (select id, row_number() over (order by kod) as row_sira
          from public.yetki
         where tur = 0 and kod not like '%.%'
           and not exists (select 1 from gecici_menu_yetki m where m.kod = yetki.kod)) s
 where y.id = s.id;

-- ---------------------------------------------------------------------------
--  AKSİYONLAR modüllerinin grubunu/sırasını devralır (676 eşlemesiyle).
-- ---------------------------------------------------------------------------
drop table if exists gecici_aksiyon_ust;
create temporary table gecici_aksiyon_ust (onek varchar(30) primary key,
                                           ust varchar(60) not null);
insert into gecici_aksiyon_ust (onek, ust) values
    ('rad', 'radyoloji'), ('kasa', 'kasa_islem'), ('ebelge', 'e_belge'),
    ('ceksenet', 'cek_senet'), ('muhasebe', 'muhasebe_fis'), ('fis', 'muhasebe_fis'),
    ('basvuru', 'belge'), ('veri', 'ayar'), ('log', 'islem_log');

update public.yetki a
   set grup = u.grup,
       modul = case when a.modul = '' then u.modul else a.modul end,
       sira = (u.sira + 1)::smallint
  from public.yetki u
 where a.kod like '%.%'
   and u.tur = 0
   and u.kod = coalesce((select m.ust from gecici_aksiyon_ust m
                          where m.onek = split_part(a.kod, '.', 1)),
                        split_part(a.kod, '.', 1));

drop table if exists gecici_menu_yetki;
drop table if exists gecici_aksiyon_ust;

do $$
begin
    raise notice '682 tamam: matris ana menu sirasina gore kuruldu (% satir).',
                 (select count(*) from public.yetki where aktif = 1);
end $$;
