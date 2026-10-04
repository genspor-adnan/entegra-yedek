-- ============================================================================
--  Gentegre AI — İZİN TALEP KARTI
--  959_izin_karti.sql
--
--  Kullanıcı: "İzin Talepleri listesinde izin talep kartı için mockup yap" →
--  "mockup uygun, uygula" (Ekranlar/IK/izin_talep_karti.html).
--
--  1. personel_izin.izin_adres / izin_tel: izindeyken nerede, nasıl ulaşılır.
--  2. referans `ik.izin_bolum_en_az`: kartın "ekipte aynı günler" uyarısı -
--     bölümde o gün en az kaç kişi kalmalı (0 = denetim yok). ENGEL DEĞİL,
--     uyarı: onaycı görür, karar onundur.
--  Yalnız dev docker.
-- ============================================================================

alter table public.personel_izin add column if not exists izin_adres varchar(200) not null default '';
alter table public.personel_izin add column if not exists izin_tel   varchar(40)  not null default '';

insert into public.referans (anahtar, deger, aciklama)
select 'ik.izin_bolum_en_az', '2',
       'Izin kartinda bolumde o gun en az kac kisi kalmali (0 = denetim yok). '
       'Engel degil, uyari - onayci gorur.'
 where not exists (select 1 from public.referans where anahtar = 'ik.izin_bolum_en_az');

-- Bölüm arkadaşları: aynı bölümlerden birine giren diğer aktif kullanıcılar.
create or replace function public.fn_bolum_arkadaslari(p_kullanici integer)
returns setof integer language sql stable as $fn$
    select distinct k.id
      from public.taraf_kullanici k
     where k.aktif = 1 and k.id <> p_kullanici and coalesce(k.portal_taraf_id, 0) = 0
       and exists (select 1 from public.fn_kullanici_bolumleri(k.id) b(id)
                    where b.id in (select public.fn_kullanici_bolumleri(p_kullanici)))
$fn$;
