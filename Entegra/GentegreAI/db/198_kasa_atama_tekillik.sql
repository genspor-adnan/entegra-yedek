-- ============================================================================
--  Gentegre AI — KASA ATAMASI TEKİLLİĞİ
--  198_kasa_atama_tekillik.sql
--
--  Kullanıcı: "bir personel birden fazla kasaya atanmaz."
--
--  197'de tekillik (tür, şube, atama) üçlüsündeydi: aynı personel farklı
--  şubede ya da farklı hesap türünde (kasa/banka) ikinci kez atanabiliyordu.
--  Artık atama GLOBAL tekil - bir personelin tek kasası olur, hangi şube ya da
--  tür olursa olsun. Nakit işlemde "hangi kasa" sorusunun tek cevabı kalır.
--
--  ANA KASA (-1) tekilliği ŞUBE + TÜR bazında kalır: çok şubeli firmada her
--  şubenin kendi ana kasası olmalı, yoksa İstanbul'daki tahsilat Ankara
--  kasasına düşer. Tek şubeli kurulumda bu zaten "tek tane" demektir.
-- ============================================================================
\set ON_ERROR_STOP on

drop index if exists public.ux_hesap_personel_kasa;

create unique index if not exists ux_hesap_personel_kasa
    on public.hesap (atama) where atama > 0 and durum = 1;

comment on index public.ux_hesap_personel_kasa is
  'Bir personel yalniz BIR kasaya atanabilir (198) - sube/tur fark etmez.';

do $$
declare v_c integer;
begin
    select count(*) into v_c from public.hesap where atama > 0 and durum = 1;
    raise notice '198 tamam: personel atamasi global tekil; su an % personel kasasi var.', v_c;
end $$;
