-- =====================================================================
-- 806 - IS SOHBETI: KAYDA BAGLI YAZISMA (teleradyoloji istegi)
--
-- Kullanici: *"mesajlaşmayla devam et"*. Tasarim notu (797) bunu bastan
-- soylemisti: *"ayri tablo yerine mesaj_sohbet.kaynak_tur/kaynak_id de
-- yeterli"* - `telerad_mesaj` diye ayri bir tablo YAZILMADI.
--
-- NEDEN AYRI TABLO DEGIL: mesajlasma modulu (341/342) okunmamis sayaci,
-- uyelik, yanitlama, ek dosya, kayit ilistirme ve arsivi zaten cozuyor.
-- Teleradyolojiye ozel ikinci bir yazisma altyapisi, bu ozelliklerin
-- ikincisini de yazmak (ve birini unutmak) demekti.
--
-- YENI OLAN TEK SEY: sohbetin BIR KAYDA ait olabilmesi. Boylece istek
-- kartindan "bu isin yazismasi" tek tikla acilir ve ayni is icin ikinci bir
-- sohbet acilmaz.
-- =====================================================================

alter table public.mesaj_sohbet
    add column if not exists kaynak_tur varchar(30) not null default '',
    add column if not exists kaynak_id  integer;

comment on column public.mesaj_sohbet.kaynak_tur is
  '806: sohbet bir KAYDA bagliysa modul anahtari ("telerad-istek"). Bos = '
  'serbest sohbet (kisi/grup).';
comment on column public.mesaj_sohbet.kaynak_id is
  '806: bagli kaydin kimligi. (kaynak_tur, kaynak_id) benzersiz - ayni is '
  'icin ikinci sohbet acilmaz.';

-- AYNI IS ICIN TEK SOHBET: ikincisi acilsaydi yazisma iki listeye bolunur ve
--   "yazdim ama gormedi" durumu dogardi (kisi sohbetindeki kuralin aynisi).
create unique index if not exists ux_mesaj_sohbet_kaynak
    on public.mesaj_sohbet (kaynak_tur, kaynak_id)
 where kaynak_tur <> '';

-- TIP 3 = IS SOHBETI: kisi (1) ve grup (2) disinda ucuncu tur. Listede
--   basligi kaydin kendisinden gelir - iki kisilik bir is sohbetinde karsi
--   tarafin adini baslik yapmak, hangi ise ait oldugunu gizlerdi.
create or replace view public.v_mesaj_sohbet as
select s.id,
       u.kullanici_id,
       s.tip,
       case when s.tip in (2, 3) then s.ad::text
            else coalesce((select coalesce(nullif(btrim(t.unvan::text), ''), t.kod::text)
                             from public.mesaj_uye u2
                             join public.taraf t on t.id = u2.kullanici_id
                            where u2.sohbet_id = s.id and u2.kullanici_id <> u.kullanici_id
                            order by u2.kullanici_id limit 1), '(boş sohbet)')
       end as baslik,
       case when s.tip = 1
            then (select u3.kullanici_id
                    from public.mesaj_uye u3
                   where u3.sohbet_id = s.id and u3.kullanici_id <> u.kullanici_id
                   order by u3.kullanici_id limit 1)
            else null::integer end as karsi_id,
       s.son_mesaj_tarihi,
       (select m.metin from public.mesaj m
         where m.sohbet_id = s.id and m.durum = 1
         order by m.tarih desc, m.id desc limit 1) as son_metin,
       (select m.gonderen_id from public.mesaj m
         where m.sohbet_id = s.id and m.durum = 1
         order by m.tarih desc, m.id desc limit 1) as son_gonderen_id,
       ((select count(*) from public.mesaj m
          where m.sohbet_id = s.id and m.durum = 1
            and m.gonderen_id <> u.kullanici_id
            and (u.son_okuma is null or m.tarih > u.son_okuma)))::integer as okunmamis,
       ((select count(*) from public.mesaj_uye u4
          where u4.sohbet_id = s.id and u4.ayrilma_tarihi is null))::integer as uye_sayisi,
       u.favori, u.sabit, u.sessiz, u.arsiv, u.rol, u.son_okuma,
       -- KAYNAK BILGISI EKRANA: "Kartı Aç" dugmesi bunu kullanir.
       s.kaynak_tur, s.kaynak_id
  from public.mesaj_sohbet s
  join public.mesaj_uye u on u.sohbet_id = s.id and u.ayrilma_tarihi is null
 where s.durum = 1;

comment on view public.v_mesaj_sohbet is
  '341/806: kullanici basina sohbet satiri - baslik, son mesaj, okunmamis '
  'sayaci, bayraklar ve (varsa) bagli kayit.';

-- ------------------------------------------------------- portal yetkisi ----
-- DIS KURUM ROLU ARTIK MESAJLASABILIR. 795'te `mesaj` yetkisi BILEREK
--   kaldirilmisti: kapsam kurali yoktu, portal kullanicisi kurum ici butun
--   sohbetleri gorurdu. Simdi kapsam UYELIK: sohbet listesi zaten
--   `v_mesaj_sohbet.kullanici_id` ile suzuluyor, her uc `mesaj_uye`
--   kontrolunden geciyor.
--
-- DEGISTIR/SIL YOK: portal kullanicisi baskasinin mesajini duzenlemez,
--   sohbeti arsivlemez. Serbest sohbet ACMASI da API'de kapali (806) -
--   sohbet yalnizca bir ISIN uzerinde dogar, uyelerini sunucu belirler.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 1, 0, 0, ''
  from public.rol r
  cross join public.yetki y
 where r.kod = 'dis_istem_kurumu' and y.kod = 'mesaj'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi from public.mesaj_sohbet where kaynak_tur <> '';
    raise notice '806: kayda bagli sohbet sayisi %.', v_sayi;
end $$;
