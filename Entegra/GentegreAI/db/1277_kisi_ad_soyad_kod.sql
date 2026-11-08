-- =============================================================================
--  1277 - KİŞİ KARTI: AD / SOYAD AYRI, ÜNVAN YALNIZ ÖNEK, KİŞİ KODU OTOMATİK  (08.11.2026)
--
--  Kullanıcı: "kişi kartında kişi kodu kaldır.. unvan kısa ve combo olsun.. personel gibi Av., Dr., Prof.Dr. gibi
--  unvanlar gelsin.. sağına Ad ve Soyad editleri ekle.. Unvan(serbest) editi de kaldır" · "kişi koduna arka planda
--  ID ataması yap.. ad soyad baş harfler + Id".
--
--  · Kişi (taraf.kisi = 1) artık personel/dış hekim gibi: `unvan` YALNIZ önek ("Av.", "Dr.") ya da boş; ad / soyad
--    kendi kolonlarında; görünen ad her yerde fn_taraf_ad(unvan, ad, soyad) (940 kuralı).
--  · MEVCUT kişilerde tam ad unvandaydı (ad / soyad boş): ad / soyad unvandan ayrıştırılır (baştaki noktalı önekler
--    atlanır - onlar unvan'da KALIR; son kelime soyad, kalanı ad; tek kelime = ad). 1250 ile aynı kural; farkı:
--    kişi başka bir kartın adı değildir, bu yüzden unvan da öneke indirilir (yoksa fn_taraf_ad "else unvan" dalı
--    eski tam adı göstermeye devam ederdi). Eski değerler _yedek_1277_kisi'de. Yalnız KANITLANABİLİR satırlar:
--    kisi = 1, ad ve soyad boş, unvan dolu.
--  · KİŞİ KODU kartta yok, arka planda: ad + soyad kelimelerinin baş harfleri + id ("Ali Kaya" #4298 -> AK4298).
--    Tetik yalnız BOŞ kodu doldurur (kod kullanıcıya görünen, listede aranan sabit bir kimliktir - ad değişince
--    değişmez). fn_kisi_kod yalnız önek olmayan kelimeleri sayar; önek yoksa unvanın kelimeleri. Mevcutta kod
--    BOŞ ya da Delphi aktarımının varsayılanı olan ÇIPLAK ID ("4298" - aktarımda cari kod = Delphi ID, yani
--    aktarim_id; web'de açılmış kayıtta kendi id'si) ise yeni biçime çevrilir; elle verilmiş başka bir kod dokunulmaz.
--  · "Av." hekim.unvan listesine (kişi kartının combosu aynı listeyi okur; personelde de görünür).
--  · Aktarım salt-okunur tetiği (fn_aktarim_salt_okunur) Delphi kaynaklı satırda UPDATE'i keser: bu onarım
--    `gentegre.aktarim = 1` ile işaretli çalışır (ajanın kendi yolu).
--  İdempotent: ikinci çalışmada aday kalmaz; tetik/fonksiyon `create or replace`.
-- =============================================================================
begin;
set local gentegre.aktarim = '1';

-- ---------------------------------------------------------------- Av. -----------------------------------------
insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select kl.id, 9, 0, 'Av.', 9, 1
  from public.kod_liste kl
 where kl.kod = 'hekim.unvan'
   and not exists (select 1 from public.kod_deger kd where kd.liste_id = kl.id and kd.dil = 0 and kd.ad = 'Av.');

-- ---------------------------------------------------------------- kişi kodu -----------------------------------
create or replace function public.fn_kisi_kod(p_unvan varchar, p_ad varchar, p_soyad varchar, p_id bigint)
returns varchar
language sql immutable parallel safe
as $$
    -- Ad + soyad (yoksa unvan) kelimelerinin baş harfleri (harfle başlamayan "-" / "1" ve noktalı önek kelimeleri
    -- atlanır) + id; kod 20 karakter.
    select left(coalesce((select string_agg(upper(left(k, 1)), '' order by n)
                            from unnest(regexp_split_to_array(btrim(
                                   case when coalesce(btrim(p_ad), '') = '' and coalesce(btrim(p_soyad), '') = ''
                                        then coalesce(p_unvan, '')
                                        else coalesce(p_ad, '') || ' ' || coalesce(p_soyad, '') end), '\s+'))
                                 with ordinality u(k, n)
                           where k ~ '^[[:alpha:]]' and k !~ '^([[:alpha:]]{1,6}\.)+$'), ''), 20 - length(p_id::text))
           || p_id::text
$$;

create or replace function public.tg_taraf_kisi_kod()
returns trigger
language plpgsql
as $$
begin
    if coalesce(new.kisi, 0) = 1 and coalesce(btrim(new.kod), '') = '' then
        new.kod := public.fn_kisi_kod(new.unvan, new.ad, new.soyad, new.id);
    end if;
    return new;
end
$$;

drop trigger if exists tr_taraf_kisi_kod on public.taraf;
create trigger tr_taraf_kisi_kod
    before insert or update on public.taraf
    for each row execute function public.tg_taraf_kisi_kod();

-- ---------------------------------------------------------------- mevcut kişiler -----------------------------
create table if not exists public._yedek_1277_kisi (
    id integer primary key, kod varchar, unvan varchar, ad varchar, soyad varchar,
    yedek_an timestamptz not null default now());

create temporary table _aday on commit drop as
with k as (
    select t.id, t.kod, t.unvan, t.ad, t.soyad, regexp_split_to_array(btrim(t.unvan), '\s+') as w
      from public.taraf t
     where t.kisi = 1
       and coalesce(btrim(t.ad), '') = '' and coalesce(btrim(t.soyad), '') = ''
       and coalesce(btrim(t.unvan), '') <> ''
), p as (
    select k.*, coalesce((select min(n) from unnest(k.w) with ordinality u(x, n)
                           where x !~ '^([[:alpha:]]{1,6}\.)+$'), cardinality(k.w) + 1) as ilk
      from k
)
select id, kod, unvan, ad, soyad,
       array_to_string(w[1:ilk - 1], ' ')              as onek,
       w[ilk:cardinality(w)]                           as adk
  from p;
delete from _aday where cardinality(adk) < 1;   -- yalnız önekten oluşan unvan: dokunma

insert into public._yedek_1277_kisi (id, kod, unvan, ad, soyad)
select id, kod, unvan, ad, soyad from _aday
on conflict (id) do nothing;

update public.taraf t
   set unvan = left(a.onek, 120),
       ad    = left(case when cardinality(a.adk) >= 2 then array_to_string(a.adk[1:cardinality(a.adk) - 1], ' ')
                         else a.adk[1] end, 50),
       soyad = left(case when cardinality(a.adk) >= 2 then a.adk[cardinality(a.adk)] else '' end, 60)
  from _aday a
 where t.id = a.id;

-- Boş ya da çıplak-id kodlu kişilere kod (tetik yalnız boşu doldurur; aktarım varsayılanı burada açıkça).
insert into public._yedek_1277_kisi (id, kod, unvan, ad, soyad)
select id, kod, unvan, ad, soyad from public.taraf
 where kisi = 1 and (coalesce(btrim(kod), '') in ('', id::text) or btrim(kod) = aktarim_id::text)
on conflict (id) do nothing;

update public.taraf
   set kod = public.fn_kisi_kod(unvan, ad, soyad, id)
 where kisi = 1 and (coalesce(btrim(kod), '') in ('', id::text) or btrim(kod) = aktarim_id::text);

do $$ begin
  raise notice '1277: % kişide ad / soyad unvandan ayrıştırıldı; boş kodlu kişi kalmadı (yedek _yedek_1277_kisi)',
    (select count(*) from _aday);
end $$;

commit;
