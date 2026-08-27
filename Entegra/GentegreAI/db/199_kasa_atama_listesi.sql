-- ============================================================================
--  Gentegre AI — KASA ATAMA LİSTESİ: KULLANICILAR DA GÖRÜNSÜN
--  199_kasa_atama_listesi.sql
--
--  197'de atama listesi yalnız `personel = 1 and durum = 1` olan tarafları
--  gösteriyordu. Ekran testinde çıktı: oturum açan kullanıcının taraf kaydı
--  personel işaretli ama PASİF olduğu için listede yoktu - kendi kullanıcısına
--  kasa atanamıyordu, atama yapılsa bile nakit işlemde kendi kasası bulunamıyor
--  ve ana kasa açılıyordu.
--
--  Kasa ataması "bu kasadan kim tahsilat yapacak" sorusudur; cevabı KULLANICI.
--  Bu yüzden liste artık iki kümenin birleşimi:
--    * aktif personeller (kullanıcı olmayan kasa sorumlusu da atanabilsin)
--    * AKTİF KULLANICISI olan taraflar (taraf kaydı pasif olsa bile)
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_hesap_atama_lookup as
    select -1 as id, '★ Ana Kasa (varsayılan)'::text as ad, 1 as aktif
    union
    select t.id, t.unvan::text, 1
      from public.taraf t
     where t.personel = 1 and t.durum = 1
    union
    -- Kullanicisi aktif olan taraf: kasayi kullanacak kisi budur.
    select t.id, t.unvan::text, 1
      from public.taraf t
      join public.taraf_kullanici k on k.id = t.id
     where k.aktif = 1;

comment on view public.v_hesap_atama_lookup is
  'Kasa atama secenekleri (199): Ana Kasa (-1) + aktif personeller + aktif kullanicilar.';

do $$
declare v_c integer;
begin
    select count(*) into v_c from public.v_hesap_atama_lookup;
    raise notice '199 tamam: kasa atama listesinde % secenek (Ana Kasa + personel + kullanicilar).', v_c;
end $$;
