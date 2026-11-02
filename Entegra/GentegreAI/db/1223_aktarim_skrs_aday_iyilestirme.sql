-- =============================================================================
--  1223  SKRS EŞLEME - ADAY HESABI İYİLEŞTİRME (1222'nin üstüne)
--
--  KOSUYOLU ilk ölçümünde radyolojide sistematik hatalar (01.11.2026):
--    · modalite eski SUT adlarında BAŞTA değil ("KALÇA EKLEMİ US") - ceza / ödül adın her yerinde aranır,
--    · eski adda kontrast yokken "KONTRASTLI" seçiliyordu - kontrastsız yeğlenir, eski adda olmayan alt yöntem
--      (SWI, DİFÜZYON, PERFÜZYON, SPEKTROSKOPİ, DİNAMİK, ARTROGRAFİ ...) cezalanır,
--    · "iki taraflı" sadeleştirmede atılıyordu ("TEK MEME" seçildi) - BİLATERAL'e çevrilir,
--    · SUT'ta yalnız SAĞ / SOL kalemi varken eski ad taraf söylemiyorsa "taraf seçimi gerekli" uyarısı.
--  Yalnız fonksiyonlar değişir (create or replace). İdempotent.
-- =============================================================================

begin;

create or replace function public.fn_skrs_sade(p text) returns text language sql immutable parallel safe as $$
  select btrim(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
           translate(upper(coalesce(p, '')), 'ÇĞİÖŞÜÂÎÛ', 'CGIOSUAIU'),
           '[^A-Z0-9 ]', ' ', 'g'),
           '\m(MR|MRI|MANYETIK REZONANS)\M', 'MRG', 'g'),
           '\m(US|ULTRASON|ULTRASONOGRAFI|ULTRASONOGRAFIK)\M', 'USG', 'g'),
           '\m(TOMOGRAFI|BILGISAYARLI TOMOGRAFI)\M', 'BT', 'g'),
           '\m(IKI TARAFLI|CIFT TARAFLI|BILATERAL)\M', 'BILATERAL', 'g'),
           '\m(SERUM|PLAZMA|KARSILASTIRMALI|TEK TARAF|TEK TARAFLI)\M', ' ', 'g'),
           '\s+', ' ', 'g'))
$$;

create or replace function public.fn_skrs_hizmet_adaylari(p_ad text, p_tur text, p_modalite smallint, p_n integer default 3)
returns table (kod varchar, ad varchar, puan numeric, dikkat text) language sql stable as $$
  with e as (select public.fn_skrs_sade(p_ad) as s,
                    split_part(public.fn_skrs_sade(p_ad), ' ', 1) as ilk,
                    case p_modalite when 1 then 'BT' when 2 then 'MRG' when 3 then 'USG' else '' end as onek),
  aday as (
    select s.kod, s.ad, public.fn_skrs_sade(s.ad) as ss
      from public.skrs_sut s, e
     where coalesce(s.aktif, 1) = 1
       and case upper(coalesce(p_tur, ''))
             when 'RAD' then s.tip = 'Tetkik ve Radyoloji Bilgileri'
             when 'LAB' then s.tip = 'Tahlil İşlemleri'
             else coalesce(s.tip, '') <> 'Malzemeler' end
       and public.fn_skrs_sade(s.ad) % e.s),
  puanli as (
    select a.kod, a.ad,
           least(1, greatest(0, similarity(a.ss, e.s)
             -- modalite: aynı modalite kelimesi adın herhangi yerinde +0.15, yalnız başka modalite -0.30
             + case when e.onek = '' then 0
                    when a.ss ~ ('\m' || e.onek || '\M') then 0.15
                    when a.ss ~ '\m(BT|MRG|USG|GRAFI|GRAFISI|MAMMOGRAFI|SINTIGRAFI)\M' then -0.30 else 0 end
             -- kontrast: eski adda geçmiyorsa kontrastsız yeğlenir
             + case when e.s ~ '\mKONTRAST' then 0
                    when a.ss ~ '\mKONTRASTSIZ\M' then 0.06
                    when a.ss ~ '\mKONTRASTLI\M' then -0.06 else 0 end
             -- eski adda olmayan alt yöntem / girişimsel terim
             - case when a.ss ~ '\m(SWI|DIFUZYON|PERFUZYON|SPEKTROSKOPI|DINAMIK|ARTROGRAFI|ANJIOGRAFI|ANJIO|VENOGRAFI|BIYOPSI|KILAVUZ\w*|FONKSIYONEL|TRAKTOGRAFI)\M'
                     and e.s !~ '\m(SWI|DIFUZYON|PERFUZYON|SPEKTROSKOPI|DINAMIK|ARTROGRAFI|ANJIOGRAFI|ANJIO|VENOGRAFI|BIYOPSI|KILAVUZ\w*|FONKSIYONEL|TRAKTOGRAFI)\M'
                    then 0.12 else 0 end))::numeric(4,2) as puan,
           concat_ws(' · ',
             case when a.ss ~ '\m(ARTROGRAFI|ANJIOGRAFI|ANJIO|BIYOPSI|KILAVUZ\w*|VENOGRAFI)\M'
                   and e.s !~ '\m(ARTROGRAFI|ANJIOGRAFI|ANJIO|BIYOPSI|KILAVUZ\w*|VENOGRAFI)\M'
                  then 'girişimsel / farklı yöntem terimi' end,
             case when length(e.ilk) >= 4 and position(' ' || e.ilk || ' ' in ' ' || a.ss || ' ') = 0
                   and exists (select 1 from regexp_split_to_table(a.ss, ' ') w
                                where length(w) >= 4 and w <> e.ilk and position(w in e.ilk) > 0)
                  then 'terim farkı: ' || e.ilk end,
             case when a.ss ~ '\m(SAG|SOL)\M' and e.s !~ '\m(SAG|SOL|BILATERAL)\M'
                  then 'taraf seçimi gerekli (SAĞ / SOL)' end) as dikkat
      from aday a, e)
  select kod, ad, puan, nullif(dikkat, '') from puanli order by puan desc, kod limit p_n
$$;

-- Sadeleştirme değişti: indeks ifadesi aynı fonksiyon - yeniden kurulur.
reindex index public.ix_skrs_sut_sade_trgm;

commit;
