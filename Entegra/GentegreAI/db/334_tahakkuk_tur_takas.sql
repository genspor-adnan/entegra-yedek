-- 334: TAHAKKUK TÜR KODLARI TAKAS - 13 ALIŞ, 17 SATIŞ.
--
-- Kullanıcı: "17 satış tahakkuku olacak, 13 alış. Küçük rakamlar ALIŞ,
-- büyükler SATIŞ demektir her zaman."
--
-- Numaralandırma deseni gerçekten böyle:
--     alış  9 sipariş · 10 irsaliye · 11 fatura · 12 fiş · 13 TAHAKKUK
--     satış 19 sipariş · 14 irsaliye · 15 fatura · 16 fiş · 17 TAHAKKUK
--
-- Seed bunu ters kurmuştu (13 "Satış Tahakkuku", 17 "Alış Tahakkuku") ve
-- yön de terse yazılmıştı: 13 çıkış (cari borçlanır), 17 giriş. Bu dosya
-- kodların ANLAMINI düzeltir, VERİYİ de taşır - bugüne kadar üretilmiş
-- tahakkuklar satış tarafındaydı (müşteri carileri, kaynakları satış
-- siparişi/başvuru), hepsi 17'ye geçer.

-- ----------------------------------------------------------- tür sözlüğü --
update public.kasa_islem_turu
   set ad = 'Alış Tahakkuku', yon = -1
 where kod = 13;

update public.kasa_islem_turu
   set ad = 'Satış Tahakkuku', yon = 1
 where kod = 17;

-- --------------------------------------------------------------- veri ----
-- Mevcut tahakkuklar SATIS tarafinda uretildi (13 kodu satis sanildigi icin).
--   Alis tahakkuku hic kullanilmamis; ters tasima riski yok.
update public.belge set tur = 17 where tur = 13;

-- Numara sablonlari da tur bazli. AYNI sube+tarih icin 17 sablonu ZATEN
--   varsa tasima yapilmaz (benzersizlik ihlali olurdu); o durumda 13'teki
--   sablon artik ALIS tahakkukunun serisidir - kullanici isterse duzenler.
update public.numara_sablonu n
   set tur = 17
 where n.tur = 13
   and not exists (select 1 from public.numara_sablonu m
                    where m.tur = 17 and m.sube_id = n.sube_id
                      and m.baslama_tarihi = n.baslama_tarihi);

-- Prim planinda belge turu kriteri metin listesidir ("4,14,15"). Iki kod da
--   TAKAS edilir: "13" yazan satis tahakkukunu, "17" yazan alis tahakkukunu
--   kastediyordu. Gecici isaret (917) olmadan ikinci degistirme birincinin
--   sonucunu ezerdi; ikisi birden gecen satirda sonuc degismez.
update public.prim_plani_satir
   set belge_turleri = trim(both ',' from
        replace(replace(replace(',' || belge_turleri || ',',
                ',13,', ',917,'), ',17,', ',13,'), ',917,', ',17,'))
 where ',' || belge_turleri || ',' like '%,13,%'
    or ',' || belge_turleri || ',' like '%,17,%';

-- Hakedis satirinda saklanan belge turu de duzelir (denetim izi tutarli
--   kalsin; onayli/odenmis satirlar da dahil - kodun ANLAMI degisti,
--   satirin degeri degil).
update public.hakedis_satir
   set belge_tur = case belge_tur when 13 then 17 else 13 end
 where belge_tur in (13, 17);

-- -------------------------------------------------- numara türü listeleri -
-- 152'deki gridler: tahakkuk artik dogru tarafta.
create or replace view public.v_numara_turu_satis as
    select kod::integer as id, ad, aktif from public.kasa_islem_turu
     where kod in (17, 14, 15, 16, 19, 119);      -- tahakkuk/irsaliye/fatura/fis/siparis/konsinye

create or replace view public.v_numara_turu_alis as
    select kod::integer as id, ad, aktif from public.kasa_islem_turu
     where kod in (8, 9, 10, 11, 12, 13, 109);    -- gider pusulasi + alis belgeleri

comment on view public.v_numara_turu_satis is
  'Numaralama ekrani satis turleri (152/334: tahakkuk 17).';
comment on view public.v_numara_turu_alis is
  'Numaralama ekrani alis turleri (152/334: tahakkuk 13).';
