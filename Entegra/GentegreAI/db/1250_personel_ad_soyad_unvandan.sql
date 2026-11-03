-- =============================================================================
--  1250  PERSONEL AD / SOYAD - TAM ADI UNVANDA KALMIŞ KAYITLAR
--
--  Kullanıcı 03.11.2026: "personel listesinde herhangi bir satıra tıklayınca sekmede pers kartı açıldı ama
--  boş geldi".
--
--  TEŞHİS. Delphi aktarımı (1144 fn_aktar_ek_kisi) kullanıcının rehber kartını personel yapıyor ama adı
--  ayrıştırmıyor: tam ad taraf.unvan'da, ad / soyad boş. 940'tan beri personel kartında Ünvan YALNIZ önek
--  (Dr., Prof.Dr.) - tam ad hiçbir alana düşmüyor, kart boş görünüyordu (Ad * / Soyad * da boş olduğundan
--  kaydedilemiyordu). UNIVERSE: 8 personelin 8'i.
--
--  ONARIM yalnız KANITLANABİLİR satırlarda: personel = 1, ad ve soyad BOŞ, unvan en az iki kelime. Baştaki
--  noktalı önek(ler) ("Dr.", "Uzm.Dr.") atlanır; SON kelime soyad, kalanı ad. UNVAN DEĞİŞMEZ: aktarılan
--  personel çoğunlukla aynı zamanda müşteri ve unvan o kartın adı; görünen ad (fn_taraf_ad: ad + soyad dolu
--  ve unvan önek değilse unvan) hiçbir yerde değişmez. Kart ilk kaydedişte unvanı öneke indirir (kartGovdesi).
--  Eski değerler _yedek_1250_personel_ad tablosunda. İdempotent: ikinci çalışmada aday kalmaz.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public._yedek_1250_personel_ad (
    id integer primary key, unvan varchar, ad varchar, soyad varchar, yedek_an timestamptz not null default now());

create temporary table _aday on commit drop as
select t.id, t.unvan, t.ad, t.soyad,
       -- Baştaki önek kelimeleri (yalnız noktalı kısaltma: "Dr.", "Prof.Dr.") atlanır: ilk önek olmayan kelimeden.
       array(select k from unnest(regexp_split_to_array(btrim(t.unvan), '\s+')) with ordinality u(k, n)
              where n >= (select coalesce(min(n2), 1) from unnest(regexp_split_to_array(btrim(t.unvan), '\s+'))
                                                           with ordinality o(k2, n2)
                           where k2 !~ '^([[:alpha:]]{1,6}\.)+$')
              order by n) as kelime
  from public.taraf t
 where t.personel = 1
   and coalesce(btrim(t.ad), '') = '' and coalesce(btrim(t.soyad), '') = ''
   and btrim(t.unvan) ~ '\s';
delete from _aday where cardinality(kelime) < 2;

insert into public._yedek_1250_personel_ad (id, unvan, ad, soyad)
select id, unvan, ad, soyad from _aday
on conflict (id) do nothing;

update public.taraf t
   set ad = left(array_to_string(a.kelime[1:cardinality(a.kelime) - 1], ' '), 50),
       soyad = left(a.kelime[cardinality(a.kelime)], 60)
  from _aday a
 where t.id = a.id;

do $$ begin
  raise notice '1250: % personelin adı / soyadı unvandan ayrıştırıldı (yedek _yedek_1250_personel_ad)',
    (select count(*) from _aday);
end $$;

commit;
