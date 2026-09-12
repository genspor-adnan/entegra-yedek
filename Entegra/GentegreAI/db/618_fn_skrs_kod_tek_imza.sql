-- =====================================================================
--  618_fn_skrs_kod_tek_imza.sql
--  `fn_skrs_kod` İKİ KEZ TANIMLANMIŞTI - tek imzaya indirilir.
--
--  503 fonksiyonu `text` parametresiyle yazmış, 610 ise farkında olmadan
--  `varchar` ile ikinci bir sürümünü açmış. PostgreSQL bunları AYRI
--  fonksiyonlar sayar: `fn_skrs_kod('hasta.cinsiyet', 1)` çağrısında
--  literalin tipi belirsiz olduğu için hangisinin çalışacağı çözücünün
--  keyfine kalıyordu - ikisinin davranışı da aynı değil:
--
--    503: skrs_kod boşsa YEREL DEĞERİ döndürür (deger::text)
--    610: skrs_kod boşsa BOŞ döndürür
--
--  Fark önemli. e-Nabız'a yerel değeri SKRS koduymuş gibi yazmak, tam da
--  kaçınmaya çalıştığımız şey: eşlenmemiş alan boş gitmeli. Ama 503'ün
--  davranışı 609 ÖNCESİ için doğruydu - o zaman listelerin içeriği SKRS
--  değildi ve `deger` ile `skrs_kod` aynı kod uzayında olabiliyordu.
--  609'dan sonra liste SKRS'nin kendisi: eşi olmayan değerin SKRS kodu
--  YOKTUR, uydurulmaz.
--
--  Bu yüzden `text` imzalı olan 610 davranışıyla yeniden yazılır,
--  `varchar` olan kaldırılır. Çağıranlar değişmez (literal ikisine de
--  uyuyordu); artık tek bir anlam var.
-- =====================================================================

drop function if exists public.fn_skrs_kod(varchar, integer);
drop function if exists public.fn_skrs_ad(varchar, integer);
drop function if exists public.fn_skrs_guid(varchar);
drop function if exists public.fn_skrs_hedef_ad(varchar, integer);

create or replace function public.fn_skrs_kod(p_liste text, p_deger integer)
returns varchar
language sql stable as $$
    select coalesce(d.skrs_kod, '')
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = p_liste and d.deger = p_deger and d.dil = 0
$$;

create or replace function public.fn_skrs_ad(p_liste text, p_deger integer)
returns varchar
language sql stable as $$
    select coalesce(d.ad, '')
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = p_liste and d.deger = p_deger and d.dil = 0
$$;

create or replace function public.fn_skrs_guid(p_liste text)
returns varchar
language sql stable as $$
    select coalesce(l.skrs_liste, '')
      from public.kod_liste l
     where l.kod = p_liste
$$;

create or replace function public.fn_skrs_hedef_ad(p_liste text, p_deger integer)
returns varchar
language sql stable as $$
    with kaynak as (
        select d.skrs_kod, d.ad as yerel_ad, l.skrs_liste
          from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = p_liste and d.deger = p_deger and d.dil = 0
    )
    select coalesce(
        (select hd.ad
           from kaynak k
           join public.kod_liste hl on hl.skrs_liste = k.skrs_liste
           join public.kod_deger hd on hd.liste_id = hl.id and hd.dil = 0
                                   and hd.skrs_kod = k.skrs_kod
                                   and hd.deger::varchar = hd.skrs_kod
          limit 1),
        (select k.yerel_ad from kaynak k),
        '')
$$;

comment on function public.fn_skrs_kod(text, integer) is
  '618: yerel kod degerinin SKRS kodu; eslenmemisse BOS (uydurulmaz).';
comment on function public.fn_skrs_ad(text, integer) is
  '618: yerel kod degerinin listedeki adi.';
comment on function public.fn_skrs_guid(text) is
  '618: kod listesinin SKRS codeSystemGuid degeri.';
comment on function public.fn_skrs_hedef_ad(text, integer) is
  '618: degerin SKRS kod sistemindeki adi (value alani).';

do $$
begin
    raise notice '618 tamam: fn_skrs_kod imza sayisi %',
        (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
          where n.nspname = 'public' and p.proname = 'fn_skrs_kod');
end $$;
