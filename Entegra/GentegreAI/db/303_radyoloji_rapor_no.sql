-- 303: Radyoloji raporuna RESMI RAPOR NUMARASI + cikti icin gereken alanlar.
--
-- Rapor cikti mockupu (Ekranlar/radyoloji_rapor_onizleme.html) ust bilgide
-- "Rapor No: RAD-2026-004317" gosteriyor. Accession no (ACC-...) TETKIGIN
-- numarasidir - ayni tetkigin ek raporu (addendum) ayni accession'i tasir;
-- hastaya verilen belgede raporun kendi numarasi gerekir.
--
-- Numara ONAYDA atanir: taslak/on rapor asamasinda numara vermek, vazgecilen
-- raporlarda numara bosluğu birakirdi (belge sayaclarinda ayni kural).

create sequence if not exists public.radyoloji_rapor_no_seq;

alter table public.radyoloji_rapor
  add column if not exists rapor_no varchar(30) not null default '';

comment on column public.radyoloji_rapor.rapor_no is
  'Resmi rapor numarasi (303) - ONAYDA atanir: RAD-<yil>-<6 hane>.';

create unique index if not exists ux_radyoloji_rapor_no
    on public.radyoloji_rapor (rapor_no) where rapor_no <> '';

-- Numarayi ureten yardimci: onay ucundan cagrilir.
create or replace function public.fn_radyoloji_rapor_no(p_tarih date default current_date)
returns varchar
language sql
volatile
as $function$
    select 'RAD-' || to_char(p_tarih, 'YYYY') || '-'
         || lpad(nextval('public.radyoloji_rapor_no_seq')::text, 6, '0');
$function$;

-- ONAYLI ama numarasiz raporlar (bu goc oncesi onaylananlar) numaralandirilir.
do $$
declare r record; n integer := 0;
begin
  for r in select id from public.radyoloji_rapor
            where durum = 3 and rapor_no = '' order by onay_tarihi, id
  loop
    update public.radyoloji_rapor
       set rapor_no = public.fn_radyoloji_rapor_no(coalesce(onay_tarihi::date, current_date))
     where id = r.id;
    n := n + 1;
  end loop;
  raise notice '303: % onayli rapora numara verildi', n;
end $$;
