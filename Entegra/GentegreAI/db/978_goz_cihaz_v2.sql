-- =====================================================================
-- 978 — GÖZ CİHAZLARI v2 (mockup Ekranlar/Goz/goz_goruntuleme_cihazlar_v2.html
--       + goz_cihaz_karti_v2.html)
--
-- Cihaz kartı bugün yalnız kimlik + tek satır "baglanti" metni tutuyordu.
-- Mockup'ın istediği şey cihazın ÇALIŞMA KURALLARI: nerede duruyor, kim
-- sorumlu, hangi tetkikleri yapar, gelen ölçüm hangi alana yazılır, hasta
-- eşleşmesi hangi anahtarla kurulur ve eşleşmezse ne olur.
--
-- Kalibrasyon ve bakım BURAYA EKLENMEZ (kullanıcı kararı 05.10.2026):
-- cihaz `demirbas_id` ile biyomedikal modülüne bağlı, bütün bakım bilgisi
-- oradan salt okuma gelir (demirbas · demirbas_kalibrasyon · demirbas_is_emri).
-- =====================================================================

-- --------------------------------------------------------------- alanlar --
alter table public.goz_cihaz add column if not exists oda              varchar(60);
alter table public.goz_cihaz add column if not exists sorumlu_id       integer;
alter table public.goz_cihaz add column if not exists yazilim_surum    varchar(40);
-- ÇEKİM SÜRESİ sıra tahmini içindir (görüntüleme listesinde "sırada 3."),
--   kısıt değil: cihaz doluysa hekim yine istem yazabilir.
alter table public.goz_cihaz add column if not exists cekim_dk         smallint;
alter table public.goz_cihaz add column if not exists dilatasyon_ister smallint not null default 0;
/* AYARLAR (jsonb): protokole göre anlamı değişen alanlar tek sütunda.
   DICOM  → {"ip":"","port":104,"ae":"","bizim_ae":"","timeout_sn":30,"deneme":3}
   Dosya  → {"klasor":"","desen":"*.xml","islenen":"arsiv","kod_sayfa":"UTF-8"}
   Ortak  → {"anahtar":"protokol","yedek_anahtar":"hasta_no",
             "eslesmezse":"beklet","gun_penceresi":1}
   Her protokol için ayrı kolon açmak, dosya cihazında boş duran altı DICOM
   kolonu demekti; jsonb'nin bedeli şu: anahtarları KOD doğrular, veritabanı
   değil (Cekirdek/Goz/CihazAyarlari.cs). */
alter table public.goz_cihaz add column if not exists ayarlar          jsonb not null default '{}'::jsonb;
/* TETKİK EŞLEMESİ (jsonb dizi): bu cihazın yapabildiği tetkikler.
   [{"tetkik":2,"cihaz_kod":"RNFL_GCC","mwl":"OPT/RNFL","goz":"istem"}]
   Eşlemesi olmayan tetkik bu cihaza GÖNDERİLEMEZ - istem ekranındaki cihaz
   kutusunda hiç görünmez (yanlış cihaza düşen istem cihazda hiç çıkmaz). */
alter table public.goz_cihaz add column if not exists tetkik_esleme    jsonb not null default '[]'::jsonb;
-- SON SINAMA: "bağlantıyı sına" sonucu. Sonuç saklanmazsa ekran her açılışta
--   "bilinmiyor" der ve kullanıcı aynı sınamayı tekrar tekrar çalıştırır.
alter table public.goz_cihaz add column if not exists son_sinama       timestamptz;
alter table public.goz_cihaz add column if not exists son_sinama_sonuc varchar(200);

comment on column public.goz_cihaz.ayarlar is
  'Protokole göre bağlantı ve hasta eşleştirme ayarları (bkz. CihazAyarlari).';
comment on column public.goz_cihaz.tetkik_esleme is
  'Cihazın yapabildiği tetkikler ve MWL karşılıkları; boşsa cihaza istem yönlendirilemez.';

create index if not exists ix_goz_cihaz_sorumlu on public.goz_cihaz (sorumlu_id)
  where sorumlu_id is not null;

-- ------------------------------------------------------------- görünüm ----
/* v_goz_cihaz_ozet — liste kolonları ve gösterge AYNI tanımdan okunur:
   iki ayrı sorgu yazıldığında "gösterge 3 diyor, liste 2 satır veriyor"
   durumu kaçınılmaz oluyor.

   Kalibrasyon alanları DEMİRBAŞTAN gelir (left join): cihaz demirbaşa bağlı
   değilse null kalır - "kalibrasyonu yok" değil "takip edilmiyor" demektir,
   ekran da "—" gösterir. */
drop view if exists public.v_goz_cihaz_ozet;
create view public.v_goz_cihaz_ozet as
select c.id                                                            as cihaz_id,
       -- Bugünkü çekim: istemi bu cihazda tamamlanan / değerlendirilen kayıt.
       (select count(*) from public.goz_goruntuleme g
         where g.cihaz_id = c.id and g.durum <> 0
           and (g.cekim_zamani at time zone 'Europe/Istanbul')::date
               = (now() at time zone 'Europe/Istanbul')::date)          as bugun_cekim,
       -- Sonuç bekleyen: istem bu cihaza düştü, çekim kaydı dönmedi.
       (select count(*) from public.goz_goruntuleme g
         where g.cihaz_id = c.id and g.durum = 1)                       as bekleyen,
       (select count(*) from public.goz_cihaz_mesaj m
         where m.cihaz_id = c.id and m.islem_durum in (0, 2))           as eslenmeyen,
       (select count(*) from public.goz_cihaz_mesaj m
         where m.cihaz_id = c.id and m.islem_durum = 3)                 as hatali,
       (select count(*) from public.goz_cihaz_mesaj m
         where m.cihaz_id = c.id and m.zaman >= now() - interval '24 hours') as mesaj_24s,
       (select count(*) from public.goz_cihaz_mesaj m
         where m.cihaz_id = c.id and m.islem_durum = 1
           and m.zaman >= now() - interval '24 hours')                  as islenen_24s,
       -- ÇEKİM → EKRAN gecikmesi: mesajın gelişi ile çekim zamanı arasındaki
       --   fark. Cihaz "çalışıyor" görünüp 20 dakika gecikmeyle veri
       --   gönderiyorsa hekim ölçümü muayene bitmeden göremiyor demektir.
       (select round(avg(extract(epoch from (m.zaman - g.cekim_zamani))))
          from public.goz_cihaz_mesaj m
          join public.goz_goruntuleme g on g.cihaz_mesaj_id = m.id
         where m.cihaz_id = c.id and g.cekim_zamani is not null
           and m.zaman >= now() - interval '7 days')                    as gecikme_sn,
       jsonb_array_length(coalesce(c.tetkik_esleme, '[]'::jsonb))       as tetkik_say,
       (select count(*) from jsonb_object_keys(coalesce(c.olcum_esleme, '{}'::jsonb)))
                                                                        as esleme_say,
       d.kod                                                            as demirbas_kod,
       d.kalibrasyon_periyot_ay,
       d.son_kalibrasyon,
       d.kalibrasyon_gecerlilik,
       d.son_bakim,
       d.sonraki_bakim,
       d.garanti_bitis,
       case when d.id is null then 0
            when d.kalibrasyon_gecerlilik is null then 0
            when d.kalibrasyon_gecerlilik < current_date then 1
            else 0 end::smallint                                        as kalibrasyon_gecikmis
  from public.goz_cihaz c
  left join public.demirbas d on d.id = c.demirbas_id;

comment on view public.v_goz_cihaz_ozet is
  'Göz cihazı sayıları (çekim · mesaj · gecikme) + demirbaştan kalibrasyon durumu; liste ve gösterge aynı tanımı kullanır.';

-- Yardım kaydı (ai_rehber_ekran) goz-cihaz için ZATEN VAR - yeniden
-- eklenmiyor; açıklaması yardım belgesinden (dokuman/yardim) okunur.
