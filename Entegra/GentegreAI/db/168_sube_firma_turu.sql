-- ============================================================================
--  Gentegre AI — FIRMA TURU kod listesi
--  168_sube_firma_turu.sql
--
--  Kullanici: "firma kimligi mockuptaki kimlik sekmesi gibi olsun."
--  Mockup'ta Firma Turu bir COMBO ("Anonim Şirket"); 165'te serbest metin
--  acilmisti. Serbest birakilirsa ayni sirket turu on farkli yazilir ve
--  unvan/tur kontrolu yapilamaz.
--
--  NOT: Bu dosya once "Yetkili / İmza" tablosunu da kuruyordu; kullanici o
--  bolumu ISTEMEDI (iptal). Tablo ve kod listesi asagida geri alinir - dosya
--  daha once calistirilmis kurulumlarda da temiz sonuc versin diye.
-- ============================================================================
\set ON_ERROR_STOP on

-- Iptal edilen "Yetkili / İmza" bolumunun izleri (kullanici karari).
drop table if exists public.sube_yetkili;
delete from public.kod_deger d
 using public.kod_liste l
 where l.id = d.liste_id and l.kod = 'sube_yetkili.imza';
delete from public.kod_liste where kod = 'sube_yetkili.imza';

-- FIRMA TURU: mockup'ta combo ("Anonim Şirket"). Serbest metin birakilirsa ayni
--   sirket turu on farkli yazilir ve e-Belge unvan kontrolunde ise yaramaz.
insert into public.kod_liste (kod, ad)
select 'sube.firma_turu', 'Firma Türü'
 where not exists (select 1 from public.kod_liste where kod = 'sube.firma_turu');

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, -1, v.ad, v.sira, 1
  from public.kod_liste l,
       (values (1,  'Anonim Şirket',                    1::smallint),
               (2,  'Limited Şirket',                   2::smallint),
               (3,  'Şahıs İşletmesi',                  3::smallint),
               (4,  'Kollektif Şirket',                 4::smallint),
               (5,  'Komandit Şirket',                  5::smallint),
               (6,  'Kooperatif',                       6::smallint),
               (7,  'Adi Ortaklık',                     7::smallint),
               (8,  'Dernek / Vakıf',                   8::smallint),
               (9,  'Kamu Kurumu',                      9::smallint),
               (10, 'Serbest Meslek',                  10::smallint))
         as v(deger, ad, sira)
 where l.kod = 'sube.firma_turu'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = -1);

-- 165'te `firma_turu` VARCHAR acilmisti; kod listesine gecilirken metin degerler
--   esleneni varsa koda cevrilir. Blok kolon HALA metinse calisir - yeniden
--   calistirmada kolon smallint oldugundan atlanir (idempotent).
do $$
declare v_tip text;
begin
    select data_type into v_tip
      from information_schema.columns
     where table_schema = 'public' and table_name = 'sube' and column_name = 'firma_turu';

    if v_tip is null then
        alter table public.sube add column firma_turu smallint not null default 0;
        return;
    end if;
    if v_tip <> 'character varying' then
        return;                                   -- zaten kod kolonu
    end if;

    alter table public.sube add column if not exists firma_turu_kod smallint not null default 0;

    update public.sube s
       set firma_turu_kod = d.deger
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id and l.kod = 'sube.firma_turu'
     where s.firma_turu_kod = 0
       and lower(btrim(s.firma_turu)) = lower(d.ad);

    alter table public.sube drop column firma_turu;
    alter table public.sube rename column firma_turu_kod to firma_turu;
end $$;

comment on column public.sube.firma_turu is
  'sube.firma_turu kod listesi (168): 1 A.Ş. · 2 Ltd. · 3 şahıs …';

do $$
begin
    raise notice '168 tamam: sube.firma_turu kod listesi.';
end $$;
