-- 308: Dis hekimin calistigi kurum YALNIZ KAYITLI CARIDEN gelir.
--
-- Kullanici: "kurum_ad kaldır, sadece listeden aramadan gelsin" + "tablodan da
-- çıkar".
--
-- 305'te iki alan birden tutuluyordu (kurum_id = kayitli cari, kurum_ad =
-- serbest metin). Iki kaynak tek bilgi icin: listede hangisinin gosterilecegi
-- coalesce'a kaliyor, ayni hastane bir kayitta cari bir kayitta metin olarak
-- duruyordu - "hangi kurumdan kac hasta geldi" sorusu bu ikilikle
-- cevaplanamaz. Kurum artik cari kartidir; kayitli degilse once cari acilir
-- (arama ekranindaki "+ Yeni" ile).
--
-- VERI KAYBI KORUMASI: metin degerler once yedeklenir, tek eslesen cari varsa
-- otomatik baglanir, sonra kolon dusurulur. Yedek tablo geri donus icindir -
-- silinmemeli.

-- 1) Yedek (bir kez; script tekrar calisirsa mevcut yedek korunur).
create table if not exists public.taraf_personel_kurum_ad_yedek_308 as
select id, kurum_ad, kurum_id, current_timestamp as yedek_zaman
  from public.taraf_personel
 where coalesce(kurum_ad, '') <> '';

comment on table public.taraf_personel_kurum_ad_yedek_308 is
  'taraf_personel.kurum_ad kolonu dusurulmeden onceki serbest metin degerler (308).';

-- 2) Metni cariye bagla - YALNIZ TEK eslesme varsa. Iki cari ayni unvanla
--    duruyorsa hangisi oldugunu bilemeyiz, dokunmayiz (yedekte durur).
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'taraf_personel'
                and column_name = 'kurum_ad') then
    update public.taraf_personel p
       set kurum_id = (select min(k.id) from public.taraf k
                        where upper(btrim(k.unvan)) = upper(btrim(p.kurum_ad)))
     where p.kurum_id is null
       and coalesce(p.kurum_ad, '') <> ''
       and (select count(*) from public.taraf k
             where upper(btrim(k.unvan)) = upper(btrim(p.kurum_ad))) = 1;
  end if;
end $$;

-- 3) Gorunum artik yalniz cariden okur (kolon dusmeden ONCE degismeli).
create or replace view public.v_dis_hekim_lookup as
select t.id,
       t.unvan as ad,
       -- ::text sart: eski gorunumde kolon text'ti, varchar'a donerse
       --   "cannot change data type of view column" ile replace reddedilir.
       coalesce(k.unvan, '')::text as kurum,
       coalesce(kd.ad, '') as brans,
       t.durum as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
  left join public.taraf k on k.id = p.kurum_id
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id
                               and kd.deger::text = nullif(p.brans, '')
 where p.dis_hekim = 1 and coalesce(t.durum, 1) = 1;

comment on view public.v_dis_hekim_lookup is
  'Kayitli DIS hekimler (305) - kurum artik yalniz kayitli cariden (308).';

-- 4) Kolonu dusur.
alter table public.taraf_personel drop column if exists kurum_ad;
