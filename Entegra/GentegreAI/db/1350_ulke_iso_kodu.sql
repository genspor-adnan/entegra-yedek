-- 1350 - Hasta kartı ülke / uyruk tek SKRS listesi + şube ülkesi varsayılanı (16.11.2026).
--   Kullanıcı: "hasta kartında uyruk ülke listesi ile aynı olsun.. ülke ve uyruk defaultu şube hangi ülkedeyse o olsun".
--
--   1) SKRS KODLARI HER KURULUMDA: uyruk kutusu `ulke.skrs_kod` dolu satırları gösteriyor. 617 kodu yalnız adı birebir
--      tutan 10 eski satıra verebildi; geri kalanı Entegrasyonlar › SKRS eşitlemesi ekliyordu (EntegrasyonUclari
--      UlkeYazAsync). Eşitleme çalışmamış kurulumda (KOSUYOLU, sunucular) uyrukta Türkiye bile yoktu. Kaynak her DB'de
--      var: `hasta.uyruk` kod listesi (SKRS MERNİS, 614). Eşitlemeyle AYNI kural: adı (fn_ara_metin) tutan satıra kod
--      yazılır, tutmayan SKRS adı yeni satır olarak eklenir.
--   2) ISO KÖPRÜSÜ: şube ülkesini ISO 3166 iki harfle tutar (sube.ulke_kod, 666). Şube kartında seçilebilen ülkelerin
--      (KartKatalogu.Firma UlkeKodlari) SKRS satırına `iso2` yazılır; istemci aktif şubeninkini bulup varsayılan yapar.
alter table public.ulke add column if not exists iso2 varchar(2);
comment on column public.ulke.iso2 is
  'ISO 3166-1 alpha-2 (1350). sube.ulke_kod ile eşleşir; hasta kartı ülke/uyruk varsayılanı buradan çözülür.';

with skrs as (
    select d.deger as kod, d.ad
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = 'hasta.uyruk' and d.dil = 0 and d.deger > 0
)
update public.ulke u
   set skrs_kod = s.kod
  from skrs s
 where public.fn_ara_metin(u.ad) = public.fn_ara_metin(s.ad)
   and u.skrs_kod is null
   and not exists (select 1 from public.ulke x where x.skrs_kod = s.kod);

insert into public.ulke (id, ad, skrs_kod)
select (select coalesce(max(id), 0) from public.ulke) + row_number() over (order by s.kod), s.ad, s.kod
  from (select d.deger as kod, d.ad
          from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = 'hasta.uyruk' and d.dil = 0 and d.deger > 0) s
 where not exists (select 1 from public.ulke x where x.skrs_kod = s.kod)
   and not exists (select 1 from public.ulke x where public.fn_ara_metin(x.ad) = public.fn_ara_metin(s.ad));

update public.ulke u
   set iso2 = v.iso
  from (values ('TR', 9980), ('DE', 9893), ('GB', 9985), ('NL', 9938), ('BE', 9852), ('AT', 9847),
               ('CH', 9974), ('FR', 9890), ('RU', 9831), ('UA', 9837), ('AZ', 9814), ('IQ', 9908),
               ('SY', 9975), ('SA', 9960), ('US', 9988), ('AF', 9840)) as v(iso, skrs)
 where u.skrs_kod = v.skrs
   and u.iso2 is distinct from v.iso;

create unique index if not exists ux_ulke_iso2 on public.ulke (iso2) where iso2 is not null;
