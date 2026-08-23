-- ============================================================================
--  Gentegre AI — Ekstre satirindan KAYNAK KAYDA gitmek
--  097_ekstre_kaynak_kayit.sql
--
--  Ekstre satirina cift tiklayinca onu ureten kayit acilmali (kasa islemi ya da
--  belge). v_hesap_ekstre'de ne kasa_islem_id ne belge_id vardi; v_cari_ekstre'de
--  yalniz belge_id. Ikisine de her iki bag eklenir - alt kaynak
--  (v_mali_hareket_ek -> mali_hareket) zaten tasiyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- Kolon SIRASI degistigi icin "create or replace" yetmez (PG kolon adi
-- degistirmeye izin vermez) - once dusurulur. Bagimli nesne yok.
drop view if exists public.v_hesap_ekstre;
drop view if exists public.v_cari_ekstre;

create view public.v_hesap_ekstre as
select id, hesap_id, hesap_adi, hesap_dovizi, islem_tarihi, tur, tur_adi,
       islem_no, belge_no,
       -- Cift tik hedefi: once kasa islemi, yoksa belge.
       kasa_islem_id, belge_id,
       taraf_id, taraf_unvan, aciklama, doviz_cinsi, doviz_kuru,
       borc as giris, alacak as cikis, yerel_borc, yerel_alacak,
       proje_id, sube_id,
       sum(borc - alacak) over (partition by hesap_id order by islem_tarihi, id
           rows between unbounded preceding and current row) as bakiye,
       sum(yerel_borc - yerel_alacak) over (partition by hesap_id order by islem_tarihi, id
           rows between unbounded preceding and current row) as yerel_bakiye
  from public.v_mali_hareket_ek e
 where hesap_id is not null and hesap_ekstre = 1 and islem_durum = 2;

comment on view public.v_hesap_ekstre is
  'Hesap (kasa/banka/POS/kart/kredi) ekstresi - yurumeli bakiye; kasa_islem_id / belge_id ile kaynak kayda gidilir.';

create view public.v_cari_ekstre as
select id, taraf_id, taraf_unvan, islem_tarihi, plan_tarihi, tur, tur_adi, tur_grup,
       islem_no, belge_no, belge_id, kasa_islem_id,
       aciklama, doviz_cinsi, borc, alacak, doviz_kuru, yerel_borc, yerel_alacak,
       bakiye_dahil, proje_id, sube_id,
       sum(case when bakiye_dahil = 1 then yerel_borc - yerel_alacak else 0::numeric end)
           over (partition by taraf_id order by islem_tarihi, id
                 rows between unbounded preceding and current row) as yerel_bakiye,
       sum(case when bakiye_dahil = 1 then borc - alacak else 0::numeric end)
           over (partition by taraf_id order by islem_tarihi, id
                 rows between unbounded preceding and current row) as bakiye
  from public.v_mali_hareket_ek e
 where hesap_turu = 'C' and cari_ekstre = 1 and islem_durum in (1, 2);

comment on view public.v_cari_ekstre is
  'Cari (musteri/tedarikci/hasta) ekstresi - yurumeli bakiye; kasa_islem_id / belge_id ile kaynak kayda gidilir.';

do $$
declare v_h integer; v_c integer;
begin
    select count(*) into v_h from public.v_hesap_ekstre where kasa_islem_id is not null;
    select count(*) into v_c from public.v_cari_ekstre  where belge_id is not null;
    raise notice '097 tamam: hesap ekstresinde kasa bagi %, cari ekstresinde belge bagi %', v_h, v_c;
end $$;
