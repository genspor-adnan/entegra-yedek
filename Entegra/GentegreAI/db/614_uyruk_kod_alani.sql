-- =====================================================================
--  614_uyruk_kod_alani.sql
--  UYRUK ARTIK BİR KOD ALANI.
--
--  Alan serbest metindi ("TC", "TR", ülke adı...). 609 değerleri SKRS
--  MERNİS koduna çevirdi; metin olarak tutmayı sürdürmenin bir anlamı
--  kalmadı - kart onu artık SKRS ÜLKE listesinden seçtirecek ve kod
--  alanları bu üründe tam sayıdır.
--
--  Dönüşüm yazıyı ayıklar: rakam olmayan her şey atılır, 'TC'/'TR' gibi
--  eski harf kodları MERNİS 9980'e (TÜRKİYE CUMHURİYETİ) düşer - alan
--  zorunlu olduğu ve eski varsayılanı zaten 'TC' olduğu için.
--
--  ALTER ... TYPE satır satır UPDATE etmediği için `taraf_hasta`daki
--  NOT VALID doğum-tarihi kısıtına takılmaz; 609'da bu yüzden atlanmış
--  olan kayıtlar da burada düzelir.
-- =====================================================================

-- Alan NOT NULL ve varsayılanı 'TC' idi; varsayılan da çevrilmeli, yoksa
-- PG "default for column "uyruk" cannot be cast automatically" der.
-- Çözülemeyen metin 9980'e düşer: alan zorunlu ve eski varsayılanı zaten
-- 'TC' (=9980) idi, yani bu bir tahmin değil, eski varsayılanın aynısı.
alter table public.taraf_hasta  alter column uyruk drop default;
alter table public.taraf_personel alter column uyruk drop default;

alter table public.taraf_hasta
  alter column uyruk type integer
  using coalesce(case
          when upper(trim(coalesce(uyruk, ''))) in ('TC', 'TR', 'TURKIYE', 'TÜRKİYE')
               then 9980
          else nullif(regexp_replace(coalesce(uyruk, ''), '\D', '', 'g'), '')::integer
        end, 9980);

alter table public.taraf_personel
  alter column uyruk type integer
  using coalesce(case
          when upper(trim(coalesce(uyruk, ''))) in ('TC', 'TR', 'TURKIYE', 'TÜRKİYE')
               then 9980
          else nullif(regexp_replace(coalesce(uyruk, ''), '\D', '', 'g'), '')::integer
        end, 9980);

alter table public.taraf_hasta    alter column uyruk set default 9980;
alter table public.taraf_personel alter column uyruk set default 9980;

comment on column public.taraf_hasta.uyruk is
  '614: SKRS ULKE KODLARI - MERNIS kodu (kod_deger[hasta.uyruk]). '
  'USS 101 UYRUK alani ISO harf kodunu (TR) kabul etmiyor, MERNIS ister.';
comment on column public.taraf_personel.uyruk is
  '614: SKRS ULKE KODLARI - MERNIS kodu (kod_deger[hasta.uyruk]).';

do $$
begin
    raise notice '614 tamam: uyrugu olan % hasta, % personel',
        (select count(*) from public.taraf_hasta where uyruk is not null),
        (select count(*) from public.taraf_personel where uyruk is not null);
end $$;
