-- ============================================================================
--  Gentegre AI — KASA ATAMASI BOŞ BIRAKILABİLSİN
--  200_kasa_atama_bos.sql
--
--  Ekran testinde çıktı: atama seçimi "—" yapılıp kaydedilince
--  "atama boş bırakılamaz" hatası alınıyordu. Kolon `not null default 0` idi;
--  kart boş seçimi NULL gönderiyor, NOT NULL kısıtı reddediyordu. Kullanıcı
--  bir kez atama verdikten sonra geri alamıyordu.
--
--  BOŞ = NULL: 0 da "boş" sayılmaya devam eder (eski kayıtlar), yeni kayıtlarda
--  alan boş bırakılır. Kısıtlar ve seçim kuralı etkilenmez - ikisi de yalnız
--  `= -1` ve `> 0` değerlerine bakıyor, NULL hiçbirine eşleşmez.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.hesap alter column atama drop not null;
alter table public.hesap alter column atama drop default;

-- Sifirlar da bos anlamina geliyordu; tek gosterime indir.
update public.hesap set atama = null where atama = 0;

comment on column public.hesap.atama is
  'Kasa atamasi (200): bos (NULL) · -1 Ana Kasa (varsayilan) · >0 personel/kullanici taraf kimligi.';

do $$
declare v_bos integer; v_ana integer; v_per integer;
begin
    select count(*) into v_bos from public.hesap where atama is null;
    select count(*) into v_ana from public.hesap where atama = -1;
    select count(*) into v_per from public.hesap where atama > 0;
    raise notice '200 tamam: atama bos birakilabilir; % bos, % ana kasa, % personel kasasi.',
                 v_bos, v_ana, v_per;
end $$;
