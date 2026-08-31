-- 309: Hekimin calistigi kurum taraf_personel'den TARAF'a tasindi.
--
-- Kullanici: "taraf_personel.kurum_id de kaldır, onun yerine taraf.kurum_id
-- kullan" - yani kurum bagi PERSONEL uzantisinin degil TARAFIN kendisinin
-- alani olsun.
--
-- taraf'ta bu bag ZATEN VAR: bag_id ("Bağlı Kurum"). Kisi kartinda "Cariye
-- Bağla" ile kullaniliyor, jenerik arama ekraninda kolon olarak gorunuyor.
-- Ayni anlamda ikinci bir kolon (kurum_id) acmak, ayni bilgiyi iki yerde
-- tutmak olurdu; kurum bagi bag_id'ye tasinip personel kolonu dusuruluyor.
--
-- Kazanc: dis hekimin kurumu artik jenerik taraf aramasinda ("Bağlı Kurum")
-- ve kisi/cari ekranlariyla AYNI alandan okunur - uzantiya bakmak gerekmez.

-- 1) Yedek (geri donus icin; silinmemeli).
create table if not exists public.taraf_personel_kurum_id_yedek_309 as
select id, kurum_id, current_timestamp as yedek_zaman
  from public.taraf_personel
 where kurum_id is not null;

comment on table public.taraf_personel_kurum_id_yedek_309 is
  'taraf_personel.kurum_id kolonu dusurulmeden onceki degerler (309).';

-- 2) Degerleri taraf.bag_id'ye tasi. Dolu bag_id'ye DOKUNULMAZ: kisi kartindan
--    kurulmus bir bag varsa o daha eskidir, ustune yazilmaz.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'taraf_personel'
                and column_name = 'kurum_id') then
    update public.taraf t
       set bag_id = p.kurum_id
      from public.taraf_personel p
     where p.id = t.id
       and p.kurum_id is not null
       and t.bag_id is null;
  end if;
end $$;

-- 3) Gorunum artik taraf.bag_id'den okur (kolon dusmeden ONCE degismeli).
create or replace view public.v_dis_hekim_lookup as
select t.id,
       t.unvan as ad,
       coalesce(k.unvan, '')::text as kurum,
       coalesce(kd.ad, '') as brans,
       t.durum as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
  left join public.taraf k on k.id = t.bag_id
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id
                               and kd.deger::text = nullif(p.brans, '')
 where p.dis_hekim = 1 and coalesce(t.durum, 1) = 1;

comment on view public.v_dis_hekim_lookup is
  'Kayitli DIS hekimler (305) - kurum bagi taraf.bag_id (309).';

-- 4) Kolonu dusur.
drop index if exists public.ix_taraf_personel_kurum;
alter table public.taraf_personel drop column if exists kurum_id;
