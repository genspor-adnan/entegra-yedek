-- 1338 - KURUMLAR listesi + "anlaşmalı" bayrağı (kullanıcı 13.11.2026).
--
-- Kullanıcı: "kurumlar listesinden seçelim ama adı artık anlaşmalı kurumlar listesi yerine kurumlar listesi olsun..
--   anlaşmalı olduklarımızı işaretleyelim ve başvuruda ödeyen listesinde onlar çıksın.. listeye anlaşmalı/anlaşmasız/
--   tümü filtreleri konabilir", "anlaşmalı kurum kartında anlaşmalı ise sözleşme vb sekmeler görünsün".
--
-- Bağlam: dış doktorun çalıştığı kurum da bu listeden seçilir (bag_id → kurum rolü taraf). Hasta gönderen bir
--   hastane sözleşmesiz de olabilir; o yüzden "kurum" rolü ile "anlaşmalı" ayrıldı:
--     taraf.kurum = 1            → Kurumlar listesinde (gönderen kurum, ödeyen kurum, SGK, sigorta...)
--     taraf_kurum.anlasmali = 1  → sözleşmeli: başvuruda ÖDEYEN listesinde çıkar, kartta Sözleşmeler sekmesi açılır.
--   Bugüne kadar listedeki her kurum "anlaşmalı kurum" sayılıyordu; mevcut kayıtlar 1 ile açılır ki ödeyen listesi
--   ve hasta poliçeleri olduğu gibi kalsın. Yeni kurum 0 ile açılır, kullanıcı işaretler.
\set ON_ERROR_STOP on
begin;

alter table public.taraf_kurum add column if not exists anlasmali smallint not null default 0;
comment on column public.taraf_kurum.anlasmali is
  '1338: 1 = sözleşmeli (başvuruda ödeyen kurum olarak seçilebilir, kartta Sözleşmeler sekmesi). 0 = yalnız kurum (ör. hasta gönderen hastane).';

-- Mevcut kurumlar anlaşmalı sayılır (önceki anlam korunur). Yalnız bir kez: kolon yeni açıldıysa hepsi 0'dır.
update public.taraf_kurum k
   set anlasmali = 1
  from public.taraf t
 where t.id = k.id and t.kurum = 1
   and not exists (select 1 from public.taraf_kurum x where x.anlasmali = 1);

-- taraf.kurum = 1 olup taraf_kurum satırı olmayan (eski aktarım) kurumlar: satır açılır, anlaşmalı sayılır.
insert into public.taraf_kurum (id, tur, anlasmali)
select t.id, 0, 1
  from public.taraf t
 where t.kurum = 1 and not exists (select 1 from public.taraf_kurum k where k.id = t.id);

-- ÖDEYEN KURUM seçimi (hasta poliçesi, diş/FTR planı, başvuru): yalnız anlaşmalılar. v_kurum_lookup (940) olduğu gibi
--   bütün kurumları verir (dış hekimin kurumu, SGK carisi).
create or replace view public.v_anlasmali_kurum_lookup as
 select t.id,
        case when t.kod::text = '' then public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
             else (t.kod::text || ' - ') || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
        end as ad,
        case when t.durum = 1 and exists (select 1 from public.kurum_sozlesme s
                                           where s.kurum_id = t.id and s.durum = 1
                                             and (s.baslangic is null or s.baslangic <= current_date)
                                             and (s.bitis is null or s.bitis >= current_date)) then 1 else 0
        end as aktif
   from public.taraf t
   join public.taraf_kurum k on k.id = t.id
  where t.kurum = 1 and k.anlasmali = 1;
comment on view public.v_anlasmali_kurum_lookup is
  '1338: ödeyen kurum seçim listesi - yalnız anlaşmalı (taraf_kurum.anlasmali = 1); aktif = geçerli sözleşmesi var.';

-- Adlar: "Anlaşmalı Kurum" → "Kurum" (menü ve kart başlığı yetki adından gelir).
update public.yetki set ad = 'Kurum Kartı'   where kod = 'kurum'       and ad = 'Anlaşmalı Kurum Kartı';
update public.yetki set ad = 'Kurum Listesi' where kod = 'kurum.liste' and ad = 'Anlaşmalı Kurum Listesi';
update public.yetki set ad = 'Kurumlar'      where kod = 'kurum'       and ad = 'Anlaşmalı Kurumlar';
insert into public.ceviri (kapsam, anahtar, dil, metin)
select c.kapsam, 'Kurumlar', c.dil, 'Institutions'
  from public.ceviri c
 where c.anahtar = 'Anlaşmalı Kurumlar'
   and not exists (select 1 from public.ceviri x where x.kapsam = c.kapsam and x.anahtar = 'Kurumlar' and x.dil = c.dil);

commit;
